import Shiny from '@/shiny';
import ReactDOM from 'react-dom';

import onceShinyInitialized from './onceShinyInitialized';
import mapReactData from './mapReactData';

const binding = new Shiny.OutputBinding();
binding.find = (scope) => scope.find('.react-container');
binding.renderValue = (container, { data, deps }) => {
  Shiny.renderDependencies(deps);
  ReactDOM.render(mapReactData(data), container);
};
Shiny.outputBindings.register(binding);

function unmountContainers(element) {
  [].forEach.call(element.getElementsByClassName('react-container'), (container) => {
    ReactDOM.unmountComponentAtNode(container);
  });
  // The getElementsByClassName() method only returns descendants - check the element itself too.
  if (element.classList.contains('react-container')) {
    ReactDOM.unmountComponentAtNode(element);
  }
}

function cleanupRemovedNodes(mutations) {
  mutations.forEach(({ removedNodes }) => {
    removedNodes.forEach((node) => {
      // If a node is removed and reinserted into the document
      // it will still be listed as a removed node in the mutations.
      // Thus we need to check if it is actually connected or not.
      if (!node.isConnected && node instanceof Element) {
        unmountContainers(node);
      }
    });
  });
}

new MutationObserver(cleanupRemovedNodes).observe(document, { childList: true, subtree: true });

export default function findAndRenderReactData() {
  onceShinyInitialized(() => {
    [].forEach.call(document.getElementsByClassName('react-data'), (dataElement) => {
      // The script tag with the JSON data is nested in the container which we render to. This will
      // replace the container contents and thus remove the script tag, which is desireable (we only
      // need to render the data once).
      const data = JSON.parse(dataElement.innerHTML);
      const container = dataElement.parentElement;
      ReactDOM.render(mapReactData(data), container);
    });
  });
}
