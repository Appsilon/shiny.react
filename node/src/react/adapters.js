import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import ShinyProxy from './ShinyProxy';
import mapReactData from './mapReactData';

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
    }, [value]);
    useEffect(() => {
      const update = ({ value: newValue, ...newProps }) => {
        if (newValue !== undefined) setValue(newValue);
        setUpdatedProps({ ...updatedProps, ...newProps });
      };
      updateHandlers[inputId] = update;
      return () => {
        if (updateHandlers[inputId] === update) delete updateHandlers[inputId];
      };
    }, [inputId]);

    let props = { ...otherProps, ...updatedProps };
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
      onClick: () => setValue(value + 1),
      ...otherProps,
    };
    return React.createElement(Component, props);
  }
  Adapter.propTypes = { inputId: PropTypes.string.isRequired };
  return Adapter;
}
