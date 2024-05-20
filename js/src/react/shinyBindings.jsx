import PropTypes from 'prop-types';
import React, { useEffect, useRef } from 'react';
import { Shiny } from './Shiny';

const shinyNodeClassRegex = new RegExp([
  // `shiny::actionButton()` and `shiny::actionLink()`.
  'action-button',
  // All Shiny inputs, e.g. `shiny::textInput()`.
  'shiny-input-container',
  // All Shiny outputs, e.g. `shiny::textOutput()`.
  'shiny-\\w*-output',
  // Outputs created with the `htmlwidgets` package, e.g. `leaflet::leafletOutput()`.
  'html-widget-output',
  // `shiny.react::reactOutput()`.
  'react-container',
].join('|'));

export function needsBindingWrapper(className) {
  return shinyNodeClassRegex.test(className);
}

export function ShinyBindingWrapper({ component, props }) {
  const ref = useRef();
  useEffect(() => {
    // The node that is of class matching `shinyNodeClassRegex`
    const shinyNode = ref.current;
    // Get the scope in which the Shiny input is located and initialize.
    Shiny.initializeInputs(shinyNode.parent);
    Shiny.bindAll(shinyNode.parent);
    // When the component is unmounted, unbind the Shiny input.
    return () => Shiny.unbindAll(shinyNode, true);
  }, []);

  return React.createElement(component, { ...props, ref });
}

ShinyBindingWrapper.propTypes = {
  component: PropTypes.node,
  props: PropTypes.object,
};
