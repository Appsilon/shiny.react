import React, { useEffect, useRef } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { domToReact } from 'html-react-parser';
import Shiny from 'shiny';
import $ from 'jquery';

import { reactShinyInput } from './inputs.jsx';

// Returns a CSS class name used to select DOM elements when installing Shiny input bindings.
// It must be indentical to the name returned by `input_class_name()` in `inputs.R`.
export function inputClassName(packageName, componentName) {
  return `${packageName.replace(/\./g, '-')}-${componentName}`;
}

function makeStandardInput(packageName, componentName, propsMapping, options = {}) {
  const selector = `.${inputClassName(packageName, componentName)}`;
  const component = ({ value, setValue, configuration }) => {
    const props = {
      ...configuration,
      ...propsMapping({ value, setValue, configuration }),
    };
    return React.createElement(window[packageName][componentName], props);
  };
  // eslint-disable-next-line no-use-before-define
  reactShinyInput(selector, component, options, processAttributes);
}

function makeButtonInput(packageName, componentName) {
  const propsMapping = ({ value, setValue }) => {
    const intValue = parseInt(value, 10) || 0;
    return {
      value: intValue,
      onClick: () => setValue(intValue + 1),
    };
  };
  // Same as for standard Shiny actionButtons. See motivation here:
  // https://github.com/rstudio/shiny/blob/59759398a66557470c005c53f33abf8c6f519902/R/input-action.R#L46
  const options = {
    type: 'shiny.action',
  };
  return makeStandardInput(packageName, componentName, propsMapping, options);
}

// Binds and unbinds Shiny components as they appear.
function ShinyComponentWrapper(props) {
  const { children } = props;
  const ref = useRef(null);

  useEffect(() => {
    Shiny.initializeInputs(ref.current);
    Shiny.bindAll(ref.current);
    $(window).resize(); // Make sure that components like leaflet map render properly.
    return () => {
      Shiny.unbindAll(ref.current);
    };
  });

  return <div ref={ref}>{children}</div>;
}

ShinyComponentWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};

// Converts JSX and HTML tags representation serialized from R into the format
// expected by html-react-parser's domToReact function.
function tagsToDom(tag) {
  if (typeof tag === 'string') return { type: 'text', data: tag };

  if (tag.$$shiny_react_type === 'list') {
    return tag.content.map(tagsToDom).flat();
  }

  if (tag.name !== undefined) {
    const children = tag.children.flat().map(tagsToDom).filter((x) => x !== null).flat();

    return {
      type: 'tag',
      name: tag.name,
      attribs: tag.attribs,
      children,
      packageName: tag.packageName,
    };
  }
  return null;
}

function objectMap(obj, fn) {
  const entries = Object.entries(obj).map(([k, v], i) => [k, fn(v, k, i)]);
  return Object.fromEntries(entries);
}

function processAttribute(attrib) {
  if (typeof attrib === 'object') {
    if (attrib.$$shiny_react_type === 'javascript') {
      // The attribute may be a JS object.
      // eslint-disable-next-line no-new-func
      return Function(`return ${attrib.content}`)();
    }
    if (attrib.$$shiny_react_type !== undefined) {
      // If the attribute is a React component, we need to recursively hydrate it.
      // eslint-disable-next-line no-use-before-define
      return hydrateJsxAndHtmlTags(attrib);
    }
  }
  return attrib;
}

function processAttributes(attribs) {
  return objectMap(attribs, processAttribute);
}

// Converts DOM representation of HTML tags into React elements,
// recognizing nodes representing custom React components and creating them.
function jsxAndHtmlDomToReact(dom) {
  return domToReact(dom, {
    replace(domNode) {
      if (domNode && domNode.packageName) {
        const component = window[domNode.packageName][domNode.name];
        const children = jsxAndHtmlDomToReact(domNode.children);

        // React needs to get undefined if there are no children,
        // because empty list has a different behavior for some components.
        const childrenOrUndefined = (children.length !== 0) ? children : undefined;
        const attribs = processAttributes(domNode.attribs);

        return React.createElement(component, attribs, childrenOrUndefined);
      }
      return undefined;
    },
  });
}

// Converts JSX and HTML tags representation serialized from R into React components.
export function hydrateJsxAndHtmlTags(jsonJsxAndHtmlTags) {
  const tagList = (Array.isArray(jsonJsxAndHtmlTags)) ? jsonJsxAndHtmlTags : [jsonJsxAndHtmlTags];
  const domTags = tagList.map(tagsToDom).flat();
  return jsxAndHtmlDomToReact(domTags);
}

// Renders nodes representation into DOM element with id = targetId.
export function render(nodes, targetId) {
  let retries = 10;
  function renderOrWait() {
    // Shiny initialization happens after a timeout.
    // Rendering may fail if Shiny is not yet initialized.
    // If this is the case give it time to initialize.
    // See: https://github.com/rstudio/shiny/blob/a1ff7652358a14f717b0b9f49f7385b164f762af/srcjs/init_shiny.js#L587
    const isShinyInitialized = Shiny.initializeInputs !== undefined;
    if (isShinyInitialized) {
      const reactNodes = window.ShinyReact.hydrateJsxAndHtmlTags(nodes);
      ReactDOM.render(reactNodes, document.getElementById(targetId));
    } else {
      retries -= 1;
      if (retries > 0) {
        setTimeout(renderOrWait, 1);
      } else {
        throw new Error('shiny.react render failed: waited too long for Shiny to initialize.');
      }
    }
  }
  renderOrWait();
}

window.ShinyReact = {
  makeStandardInput,
  makeButtonInput,
  ShinyComponentWrapper,
  hydrateJsxAndHtmlTags,
  render,
};
