import Shiny from '@/shiny';
import PropTypes from 'prop-types';
import React, { useEffect, useRef } from 'react';

export default function ShinyBindingWrapper({ children }) {
  const ref = useRef();
  useEffect(() => {
    const wrapper = ref.current;
    Shiny.initializeInputs(wrapper);
    Shiny.bindAll(wrapper);
    return () => Shiny.unbindAll(wrapper);
  }, []);
  return React.createElement('div', { ref }, children);
}

ShinyBindingWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};
