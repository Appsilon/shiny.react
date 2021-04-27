import React, { useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import ShinyProxy from './ShinyProxy';

const map = {};

export default function mapReactData(data) {
  const { type } = data;
  if (type in map) {
    return map[type](data);
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
  // useEffect(() => {
  //   wrapper.dispatchEvent(new Event('resize'));
  // })
  return React.createElement('div', { ref }, children);
}

ShinyBindingWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};

map.raw = ({ value }) => value;
map.expr = ({ value }) => eval(`(${value})`); // eslint-disable-line no-eval
map.array = ({ value }) => value.map(mapReactData);
map.object = ({ value }) => mapValues(value, mapReactData);

map.element = ({ module, name, props: propsData }) => { // eslint-disable-line react/prop-types
  const component = module ? window.jsmodule[module][name] : name;
  const props = mapReactData(propsData);
  renameKey(props, 'class', 'className');
  // https://reactjs.org/docs/uncontrolled-components.html#default-values
  if (['input', 'select', 'textarea'].includes(name)) {
    renameKey(props, 'value', 'defaultValue');
    renameKey(props, 'checked', 'defaultChecked');
  }
  if (typeof props.style === 'string') {
    props.style = styleStringToObject(props.style);
  }
  let element = React.createElement(component, props);
  if (needsBindingWrapper(props.className)) {
    element = React.createElement(ShinyBindingWrapper, {}, element);
  }
  return element;
};

map.input = ({ id, argIdx }) => (
  (...args) => {
    ShinyProxy.setInputValue(id, argIdx === null || args[argIdx], { priority: 'event' });
  }
);
