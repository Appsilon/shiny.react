import ReactDOM from 'react-dom';
import Shiny from '@/shiny';
import ShinyProxy from './ShinyProxy';
import mapReactData from './mapReactData';

const binding = new Shiny.OutputBinding();
binding.find = (scope) => scope.find('.react-container');
binding.renderValue = (container, { data, deps }) => {
  Shiny.renderDependencies(deps);
  ReactDOM.render(mapReactData(data), container);
};
Shiny.outputBindings.register(binding);

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

function isShinyOutput(className) {
  const regex = /(shiny-\w*-output)/;
  return regex.test(className);
}

function removeOutputBinding(mutations) {
  const elements = mutations.map((x) => x.target);
  const outputElements = elements.filter((x) => isShinyOutput(x.className));
  outputElements.forEach((el) => {
    ShinyProxy.unbindAll(el.querySelector('.react-container'), true);
  });
}

// Removes bindings of React inputs inside of `uiOutput` containers
new MutationObserver(removeOutputBinding).observe(document, { childList: true, subtree: true });

function getInputIdFromData(reactData) {
  const { props: { value: { inputId } } } = reactData;
  return inputId;
}

export default function findAndRenderReactData() {
  [].forEach.call(document.getElementsByClassName('react-data'), (dataElement) => {
    // The script tag with the JSON data is nested in the container which we render to. This will
    // replace the container contents and thus remove the script tag, which is desireable (we only
    // need to render the data once).
    const data = JSON.parse(dataElement.innerHTML);
    const container = dataElement.parentElement;
    ReactDOM.render(mapReactData(data), container);
    // Get inputId of created component and unbind it from Shiny
    // This prevents Shiny from setting input values itself and allows InputAdapter to set the value
    const inputId = getInputIdFromData(data);
    const inputElement = document.getElementById(inputId);
    ShinyProxy.unbindAll(inputElement, true);
  });
}
