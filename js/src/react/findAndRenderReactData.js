import ReactDOM from 'react-dom';
import onceShinyInitialized from './onceShinyInitialized';
import mapReactData from './mapReactData';
import { Shiny, isShiny } from './Shiny';

if (isShiny()) {
  const binding = new Shiny.OutputBinding();
  binding.find = (scope) => scope.find('.react-container');
  binding.renderValue = (container, { data, deps }) => {
    Shiny.renderDependencies(deps);
    ReactDOM.render(mapReactData(data), container);
  };
  Shiny.outputBindings.register(binding);
}

function unmountContainersAtNode(node) {
  if (node instanceof Element) {
    [].forEach.call(node.getElementsByClassName('react-container'), (container) => {
      ReactDOM.unmountComponentAtNode(container);
    });
    // The getElementsByClassName() method only returns descendants - check the node itself too.
    if (node.classList.contains('react-container')) {
      ReactDOM.unmountComponentAtNode(node);
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
      // The script tag with the JSON data is nested in the container which we render to. This will
      // replace the container contents and thus remove the script tag, which is desireable (we only
      // need to render the data once).
      const data = JSON.parse(dataElement.innerHTML);
      const container = dataElement.parentElement;
      ReactDOM.render(mapReactData(data), container);
    });
  });
}
