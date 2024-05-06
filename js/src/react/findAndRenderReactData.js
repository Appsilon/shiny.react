import ReactDOM from 'react-dom/client';
import onceShinyInitialized from './onceShinyInitialized';
import mapReactData from './mapReactData';
import { Shiny, isShiny } from './Shiny';

// ReactDOM.createRoot can be called only once on a container, it serves as a lookup of all created roots.
// To unmount a component, we need the reference to the root from the lookup.
// The key is a `data-react-id` which uniquely identifies the container.
const roots = {};

if (isShiny()) {
  const binding = new Shiny.OutputBinding();
  binding.find = (scope) => scope.find('.react-container');
  binding.renderValue = (container, { data, deps }) => {
    Shiny.renderDependencies(deps);
    const id = container.getAttribute('data-react-id');
    if (!roots[id]) {
      roots[id] = ReactDOM.createRoot(container);
    }
    roots[id].render(mapReactData(data));
  };
  Shiny.outputBindings.register(binding, 'shiny.react');
}

function unmount(node) {
  const id = node.getAttribute('data-react-id');
  if (roots[id]) {
    roots[id].unmount();
    delete roots[id];
  }
}

function unmountContainersAtNode(node) {
  if (node instanceof Element) {
    [].forEach.call(node.getElementsByClassName('react-container'), (container) => {
      unmount(container);
    });
    // The getElementsByClassName() method only returns descendants - check the node itself too.
    if (node.classList.contains('react-container')) {
      unmount(node);
    }
  }
}

function cleanupRemovedNodes(mutations) {
  mutations.forEach(({ removedNodes }) => {
    removedNodes.forEach(unmountContainersAtNode);
  });
}

new MutationObserver(cleanupRemovedNodes).observe(document, { childList: true, subtree: true });

export default function findAndRenderReactData(id) {
  onceShinyInitialized(() => {
    const container = document.querySelector(`[data-react-id=${id}]`);
    const data = JSON.parse(container.querySelector('.react-data').innerHTML);
    roots[id] = ReactDOM.createRoot(container);
    roots[id].render(mapReactData(data));
  });
}
