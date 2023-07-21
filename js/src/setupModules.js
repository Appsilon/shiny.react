/* eslint-disable global-require, quote-props */
window.jsmodule = {
  ...window.jsmodule,
  'prop-types': require('prop-types'),
  'react': require('react'),
  'react-dom': require('react-dom'),
  '@/shiny.react': require('./react'),
  '@/shiny.react/test-components': require('./test-components'),
};
