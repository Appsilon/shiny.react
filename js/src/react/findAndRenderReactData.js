import { createRoot } from 'react-dom/client';
import onceShinyInitialized from './onceShinyInitialized';
import mapReactData from './mapReactData';
import { Shiny, isShiny } from './Shiny';

const rootPropertyName = '__reactRootContainer$';

if (isShiny()) {
  const binding = new Shiny.OutputBinding();
  binding.find = (scope) => scope.find('.react-container');
  binding.renderValue = (container, { data, deps }) => {
    Shiny.renderDependencies(deps);
    if (!container[rootPropertyName]) {
      container[rootPropertyName] = createRoot(container);
    }
    container[rootPropertyName].render(mapReactData(data));
  };
  Shiny.outputBindings.register(binding);
}

function unmountContainersAtNode(node) {
  if (node instanceof Element) {
    [].forEach.call(node.getElementsByClassName('react-container'), (container) => {
      if (container[rootPropertyName]) {
        container[rootPropertyName].unmount();
        delete container[rootPropertyName]; // Clean up after unmounting
      }
    });
    if (node.classList.contains('react-container') && node[rootPropertyName]) {
      node[rootPropertyName].unmount();
      delete node[rootPropertyName]; // Clean up after unmounting
    }
  }
}

function cleanupRemovedNodes(mutations) {
  mutations.forEach(({ removedNodes }) => {
    removedNodes.forEach(unmountContainersAtNode);
  });
}

new MutationObserver(cleanupRemovedNodes).observe(document, { childList: true, subtree: true });

export default function findAndRenderReactData() {
  onceShinyInitialized(() => {
    [].forEach.call(document.getElementsByClassName('react-data'), (dataElement) => {
      const data = JSON.parse(dataElement.innerHTML);
      const container = dataElement.parentElement;
      if (!container[rootPropertyName]) {
        container[rootPropertyName] = createRoot(container);
      }
      container[rootPropertyName].render(mapReactData(data));
    });
  });
}

