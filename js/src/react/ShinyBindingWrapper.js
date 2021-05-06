import PropTypes from 'prop-types';
import React, { useEffect, useRef } from 'react';

import ShinyProxy from './ShinyProxy';

export default function ShinyBindingWrapper({ children }) {
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
