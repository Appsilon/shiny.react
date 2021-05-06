import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import ShinyProxy from './ShinyProxy';
import mapReactData from './mapReactData';

// The higher-level components in this file can be used to adapt the interface of React components
// to make it in line with what is expected from Shiny inputs / buttons. The adapters add
// an `inputId` prop and use `Shiny.setInputValue()` to send value / clicks to the R backend.
// Each input adapter instance registers an update handler with its `inputId` so it can be updated
// using Shiny's `session$sendCustomMessage()` mechanism. The wrapped component is used
// in a controlled manner, which allows also for the value to be updated from R.

const updateHandlers = {};

ShinyProxy.addCustomMessageHandler('updateReactInput', ({ inputId, data }) => {
  if (inputId in updateHandlers) {
    updateHandlers[inputId](mapReactData(data));
  } else throw new Error(`Attempted to update non-existent React input '${inputId}'`);
});

export function InputAdapter(Component, valueProps) {
  function Adapter({ inputId, value: defaultValue, ...otherProps }) {
    const [value, setValue] = useState(defaultValue);
    const [updatedProps, setUpdatedProps] = useState();

    useEffect(() => {
      ShinyProxy.setInputValue(inputId, value);
    }, [inputId, value]);

    // Register / cleanup update handlers (used to implement updateX.shinyInput functions).
    useEffect(() => {
      const updateHandler = ({ value: newValue, ...newProps }) => {
        if (newValue !== undefined) setValue(newValue);
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
    const [value, setValue] = useState(null);
    useEffect(() => {
      ShinyProxy.setInputValue(inputId, value);
    }, [value]);
    const props = {
      id: inputId,
      onClick: () => setValue(value + 1),
      ...otherProps,
    };
    return React.createElement(Component, props);
  }
  Adapter.propTypes = { inputId: PropTypes.string.isRequired };
  return Adapter;
}
