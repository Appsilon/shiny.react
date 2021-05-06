import ReactDOM from 'react-dom';
import Shiny from '@/shiny';

import mapReactData from './mapReactData';

const binding = new Shiny.OutputBinding();
binding.find = (scope) => scope.find('.react-container');
binding.renderValue = (container, { data, deps }) => {
  Shiny.renderDependencies(deps);
  ReactDOM.render(mapReactData(data), container);
};
Shiny.outputBindings.register(binding);

new MutationObserver((mutations) => {
  mutations.forEach(({ removedNodes }) => {
    removedNodes.forEach((node) => {
      if (node instanceof Element) {
        [].forEach.call(node.getElementsByClassName('react-container'), (container) => {
          ReactDOM.unmountComponentAtNode(container);
        });
        // The getElementsByClassName() method only returns descendants - check the node itself too.
        if (node.classList.contains('react-container')) {
          ReactDOM.unmountComponentAtNode(node);
        }
      }
    });
  });
}).observe(document, { childList: true, subtree: true });

export default function renderReact() {
  [].forEach.call(document.getElementsByClassName('react-data'), (dataElement) => {
    const data = JSON.parse(dataElement.innerHTML);
    const container = dataElement.parentElement;
    ReactDOM.render(mapReactData(data), container);
  });
}
