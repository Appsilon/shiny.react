import React, { useState } from 'react';
import PropTypes from 'prop-types';

export default function Counter({ defaultValue, onChange }) {
  const [value, setValue] = useState(defaultValue);
  const handleClick = () => {
    setValue(value + 1);
    if (onChange) onChange(value + 1);
  };
  return <button type="button" onClick={handleClick}>{value}</button>;
}

Counter.propTypes = {
  defaultValue: PropTypes.number,
  onChange: PropTypes.func,
};

Counter.defaultProps = {
  defaultValue: 0,
  onChange: undefined,
};
