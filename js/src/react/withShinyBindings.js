import Shiny from '@/shiny';
import React, { useEffect, useRef } from 'react';

// Wrap the `element` in a "sandbox" div for the duration of the `callback`.
// The "sandbox" div is passed as the only argument to the `callback`.
function sandbox(element, callback) {
  const box = document.createElement('div');
  element.replaceWith(box);
  box.appendChild(element);
  try {
    callback(box);
  } finally {
    box.replaceWith(element);
  }
}

// Ensure that when React renders the `Component`, it is properly bound to Shiny inputs / outputs.
export default function withShinyBindings(Component) {
  return (props) => {
    const ref = useRef();
    useEffect(() => {
      const element = ref.current;
      sandbox(element, (box) => {
        // Unlike `Shiny.unbindAll()`, these functions do not support an `includeSelf` argument,
        // so we use a "sandbox":
        Shiny.initializeInputs(box);
        Shiny.bindAll(box);
      });
      // Cleanup is necessary to avoid resource leaks and "Duplicate binding" exceptions from Shiny.
      // We must use `element` here, as `ref.current` will be `null` when the cleanup function runs.
      return () => Shiny.unbindAll(element, true);
    }, []);
    return React.createElement(Component, { ref, ...props });
  };
}
