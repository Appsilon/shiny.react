import isShiny from './isShiny';

// Shiny initializes some functions after a delay:
// https://github.com/rstudio/shiny/blob/cda59da698eba1deda20ba09ca8b7f0b0b149f87/srcts/src/shiny/index.ts#L101
function shinyInitialized() {
  return isShiny() ? window.Shiny.setInputValue !== undefined : true;
}

// Run `callback` and keep retrying with exponential backoff until it returns true.
function retry(callback, retryDelay = 1) {
  if (!callback()) setTimeout(retry, retryDelay, callback, retryDelay * 2);
}

const callbackQueue = [];

// Run `callback` asynchronously (in another event loop iteration)
// and only once Shiny is fully initialized.
export default function onceShinyInitialized(callback) {
  if (shinyInitialized()) {
    setTimeout(callback);
  } else {
    callbackQueue.push(callback);
  }
}

retry(() => {
  if (shinyInitialized()) {
    callbackQueue.forEach((callback) => setTimeout(callback));
    callbackQueue.length = 0;
    return true;
  }
  return false;
});
