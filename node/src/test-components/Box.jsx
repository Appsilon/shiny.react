import PropTypes from 'prop-types';
import React, { useState } from 'react';

export default function Box({ style, children, ...rest }) {
  const [visible, setVisible] = useState(false);
  return (
    <>
      <button type="button" onClick={() => setVisible(!visible)}>
        {visible ? 'Hide' : 'Show'}
      </button>
      <div
        style={{ padding: '5px', border: 'solid black 1px', ...style }}
        {...rest} // eslint-disable-line react/jsx-props-no-spreading
      >
        {visible && children}
      </div>
    </>
  );
}

Box.propTypes = {
  style: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  children: PropTypes.node,
};

Box.defaultProps = {
  style: undefined,
  children: undefined,
};
