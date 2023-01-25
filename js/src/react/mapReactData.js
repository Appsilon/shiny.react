import Shiny from '@/shiny';
import React from 'react';

import { needsBindingWrapper, ShinyBindingWrapper } from './shinyBindings';

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

// This function maps an inline CSS string to an object understood by React. It relies on the
// undocumented behavior of React: it accepts CSS property names with dashes and lower case letters.
// For example, `style: { 'background-color': 'red' }` works.
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

// There are a number of attributes that work differently between React and HTML. This function
// does not provide full compatibility, but does a fairly good job. To some extent this relies
// on the undocumented behavior of react: the tag / attribute names which are renamed in React
// (usually to camelCase), actually work just fine withhout renaming. For example, these work:
//   * `React.createElement('font-size')`
//   * `React.createElement('label', { 'for': 'target', 'class': 'nice' })`
//
// This function should be improved in the future, probably using some external library to do
// the translation. Full list of differences between React and HTML is available here:
// https://reactjs.org/docs/dom-elements.html
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

// Used to implement `triggerEvent()` R function.
// The returned function just sets the Shiny input to `TRUE`
// on every call (this works thanks to `priority: 'event'`).
dataMappers.event = ({ id }) => (
  () => {
    Shiny.setInputValue(id, true, { priority: 'event' });
  }
);

// Used to implement `setInput()` R function.
dataMappers.input = ({ id, jsAccessor }) => (
  () => { // used to be (...args) , see below
    //
    let value = true;
    if (jsAccessor !== undefined) {
      // Needs to use arguments inside eval string, otherwise webpack
      // won't translate args => arguments
      value = eval(`arguments${jsAccessor}`); // eslint-disable-line no-eval
    }
    Shiny.setInputValue(id, value, { priority: 'event' });
  }
);
