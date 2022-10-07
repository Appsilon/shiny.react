import Shiny from '@/shiny';
import PropTypes from 'prop-types';
import React, { useEffect, useRef } from 'react';

const regex = new RegExp([
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
  return regex.test(className);
}

export function ShinyBindingWrapper({ children }) {
  const ref = useRef();
  useEffect(() => {
    const wrapper = ref.current;
    Shiny.initializeInputs(wrapper);
    Shiny.bindAll(wrapper);
    return () => Shiny.unbindAll(wrapper);
  }, []);

  return (
    // Mark with a CSS class for HTML readability.
    <div ref={ref} className="shiny-binding-wrapper">
      {children}
    </div>
  );
}

ShinyBindingWrapper.propTypes = {
  children: PropTypes.node,
};

ShinyBindingWrapper.defaultProps = {
  children: null,
};
