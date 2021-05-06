import React, { useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import ShinyProxy from './ShinyProxy';

const dataMappers = {};

export default function mapReactData(data) {
  const { type } = data;
  if (type in dataMappers) {
    return dataMappers[type](data);
  }
  throw new TypeError(`Unknown React data type '${type}'`);
}

function mapValues(object, func) {
  return Object.fromEntries(Object.entries(object).map(
    ([key, val]) => [key, func(val)],
  ));
}

function styleStringToObject(styleString) {
  const style = {};
  styleString.split(';').forEach((attribute) => {
    const match = attribute.match(/^\s*([\w-]*)\s*:(.*)$/);
    if (match) {
      const [, name, value] = match;
      style[name.toLowerCase()] = value;
    }
  });
  return style;
}

function renameKey(object, from, to) {
  if (from in object && from !== to) {
    object[to] = object[from]; // eslint-disable-line no-param-reassign
    delete object[from]; // eslint-disable-line no-param-reassign
  }
  return object;
}

function prepareProps(elementName, propsData) {
  const props = mapReactData(propsData);
  renameKey(props, 'class', 'className');
  // https://reactjs.org/docs/uncontrolled-components.html#default-values
  if (['input', 'select', 'textarea'].includes(elementName)) {
    renameKey(props, 'value', 'defaultValue');
    renameKey(props, 'checked', 'defaultChecked');
  }
  if (typeof props.style === 'string') {
    props.style = styleStringToObject(props.style);
  }
  return props;
}

function needsBindingWrapper(className) {
  const regex = /(shiny-input-container|html-widget-output|shiny-\w*-output)/;
  return regex.test(className);
}

function ShinyBindingWrapper({ children }) {
  const ref = useRef();
  useEffect(() => {
    const wrapper = ref.current;
    ShinyProxy.initializeInputs(wrapper);
    ShinyProxy.bindAll(wrapper);
    return () => ShinyProxy.unbindAll(wrapper);
  }, []);
  return React.createElement('div', { ref }, children);
}

ShinyBindingWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};

dataMappers.raw = ({ value }) => value;
dataMappers.expr = ({ value }) => eval(`(${value})`); // eslint-disable-line no-eval
dataMappers.array = ({ value }) => value.map(mapReactData);
dataMappers.object = ({ value }) => mapValues(value, mapReactData);

// eslint-disable-next-line react/prop-types
dataMappers.element = ({ module, name, props: propsData }) => {
  const component = module ? window.jsmodule[module][name] : name;
  const props = prepareProps(name, propsData);
  let element = React.createElement(component, props);
  if (needsBindingWrapper(props.className)) {
    element = React.createElement(ShinyBindingWrapper, {}, element);
  }
  return element;
};

// Used to implement `setInput()` and `triggerEvent()` R functions. In case of `triggerEvent()`,
// we have `argIdx === null` and the returned function just sets the Shiny input to `TRUE`
// on every call (this works thanks to `priority: 'event'`).
dataMappers.input = ({ id, argIdx }) => (
  (...args) => {
    const value = argIdx === null ? true : args[argIdx];
    ShinyProxy.setInputValue(id, value, { priority: 'event' });
  }
);
