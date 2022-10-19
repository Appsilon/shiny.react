import Shiny from '@/shiny';
import PropTypes from 'prop-types';
import React, { useEffect, useState, useRef } from 'react';
import { throttle as lodashThrottle, debounce as lodashDebounce } from 'lodash';

import mapReactData from './mapReactData';

// The higher-level components in this file can be used to adapt the interface of React components
// to make it in line with what is expected from Shiny inputs / buttons. The adapters add
// an `inputId` prop and use `Shiny.setInputValue()` to send value / clicks to the R backend.
// Each input adapter instance registers an update handler with its `inputId` so it can be updated
// using Shiny's `session$sendCustomMessage()` mechanism. The wrapped component is used
// in a controlled manner, which allows also for the value to be updated from R.

const updateHandlers = {};
const rateFunctions = {
  debounce: lodashDebounce,
  throttle: lodashThrottle,
};

Shiny.addCustomMessageHandler('updateReactInput', ({ inputId, data }) => {
  if (inputId in updateHandlers) {
    updateHandlers[inputId](mapReactData(data));
  } else throw new Error(`Attempted to update non-existent React input '${inputId}'`);
});

function useValue(inputId, defaultValue) {
  const [value, setValue] = useState(defaultValue);
  useEffect(() => {
    Shiny.setInputValue(inputId, value);
  }, [inputId, value]);
  return [value, setValue];
}

function useRatedValue(inputId, defaultValue, rateLimit) {
  const setInputValue = (value) => Shiny.setInputValue(inputId, value);
  const { policy, value: rateValue } = rateLimit;
  if (!(policy in rateFunctions)) {
    throw new Error(`Undefined rate function: ${policy}`);
  }
  const rateFunction = rateFunctions[policy];
  const [value, setValue] = useState(defaultValue);
  const rated = useRef(rateFunction((newValue) => {
    setInputValue(newValue);
  }, rateValue));
  useEffect(() => {
    rated.current(value);
  }, [inputId, value]);
  useEffect(() => {
    setInputValue(value);
    return () => rated.current.flush();
  }, [inputId]);
  return [value, setValue];
}

useRatedValue.propTypes = {
  inputId: PropTypes.string.isRequired,
  defaultValue: PropTypes.any.isRequired, // eslint-disable-line react/forbid-prop-types
  rateLimit: PropTypes.shape({
    policy: PropTypes.string.isRequired,
    value: PropTypes.number.isRequired,
  }),
};

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

export function InputAdapter(Component, valueProps, rateLimit) {
  function Adapter({ inputId, value: defaultValue, ...otherProps }) {
    const [value, setValue] = rateLimit
      ? useRatedValue(inputId, defaultValue, rateLimit)
      : useValue(inputId, defaultValue);
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
    const [value, setValue] = useValue(inputId, null);
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
