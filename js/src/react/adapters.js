import React, { useState, useCallback, useEffect } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';
import throttle from 'lodash.throttle';
import ShinyProxy from './ShinyProxy';
import mapReactData from './mapReactData';

// The higher-level components in this file can be used to adapt the interface of React components
// to make it in line with what is expected from Shiny inputs / buttons. The adapters add
// an `inputId` prop and use `Shiny.setInputValue()` to send value / clicks to the R backend.
// Each input adapter instance registers an update handler with its `inputId` so it can be updated
// using Shiny's `session$sendCustomMessage()` mechanism. The wrapped component is used
// in a controlled manner, which allows also for the value to be updated from R.

const updateHandlers = {};

function shinySetInputValue() {
  return (inputId, value) => ShinyProxy.setInputValue(inputId, value);
}

function debouncedSetInputValue(debounceValue) {
  return useCallback(debounce((inputId, value) => {
    ShinyProxy.setInputValue(inputId, value);
  }, debounceValue), []);
}

function throttledSetInputValue(throttleValue) {
  return useCallback(throttle((inputId, value) => {
    ShinyProxy.setInputValue(inputId, value);
  }, throttleValue), []);
}

function selectSetInputValueFunction(props) {
  const { inputId, throttle, debounce } = props; // eslint-disable-line
  if (throttle && debounce) {
    throw new Error(`Attempted to use throttle and debounce at the same time for React input ${inputId}`);
  }
  if (throttle) return throttledSetInputValue(throttle);
  if (debounce) return debouncedSetInputValue(debounce);
  return shinySetInputValue();
}

ShinyProxy.addCustomMessageHandler('updateReactInput', ({ inputId, data }) => {
  if (inputId in updateHandlers) {
    updateHandlers[inputId](mapReactData(data));
  } else throw new Error(`Attempted to update non-existent React input '${inputId}'`);
});

function useValue(inputId, defaultValue, setInputValueFunction) {
  const [value, setValue] = useState(defaultValue);
  useEffect(() => {
    setInputValueFunction(inputId, value);
  }, [inputId, value]);
  return [value, setValue];
}

function useUpdatedProps(inputId, setValue) {
  const [updatedProps, setUpdatedProps] = useState();
  useEffect(() => {
    const updateHandler = (props) => {
      const { value, ...newProps } = props;
      if (value !== undefined) setValue(value);
      setUpdatedProps({ ...updatedProps, ...newProps });
    };
    updateHandlers[inputId] = updateHandler;
    return () => {
      // When the component is rerendered inside `renderUI()`, the new instance is initialised
      // (and registers its update handler) *before* the old one is cleaned up. Here we ensure
      // that the old instance only removes its own update handler.
      if (updateHandlers[inputId] === updateHandler) delete updateHandlers[inputId];
    };
  }, [inputId]);
  return updatedProps;
}

export function InputAdapter(Component, valueProps) {
  function Adapter({ inputId, value: defaultValue, ...otherProps }) {
    const updateFunction = selectSetInputValueFunction({ inputId, ...otherProps });
    const [value, setValue] = useValue(inputId, defaultValue, updateFunction);
    const updatedProps = useUpdatedProps(inputId, setValue);
    let props = { id: inputId, ...otherProps, ...updatedProps };
    props = { ...valueProps(value, setValue, props), ...props };
    return React.createElement(Component, props);
  }
  Adapter.propTypes = {
    inputId: PropTypes.string.isRequired,
    value: PropTypes.any.isRequired, // eslint-disable-line react/forbid-prop-types
  };
  return Adapter;
}

export function ButtonAdapter(Component) {
  function Adapter({ inputId, ...otherProps }) {
    const updateFunction = selectSetInputValueFunction({ inputId, ...otherProps });
    const [value, setValue] = useValue(inputId, null, updateFunction);
    const updatedProps = useUpdatedProps(inputId, setValue);
    const props = {
      id: inputId,
      onClick: () => setValue(value + 1),
      ...otherProps,
      ...updatedProps,
    };
    return React.createElement(Component, props);
  }
  Adapter.propTypes = { inputId: PropTypes.string.isRequired };
  return Adapter;
}
