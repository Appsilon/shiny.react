import PropTypes from 'prop-types';

export default function ReactContext({ children }) {
  return children;
}

ReactContext.propTypes = {
  children: PropTypes.node,
};

ReactContext.defaultProps = {
  children: null,
};
