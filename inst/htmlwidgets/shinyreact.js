// This file is automatically discovered by HTMLWidgets.
// See HTMLWidgets docs for details.

window.HTMLWidgets.widget({
  name: "shinyreact",
  type: "output",
  factory: function(el, width, height) {
    function renderValue(value) {
      const nodes = window.ShinyReact.hydrateJsxAndHtmlTags(value.tag);
      const component = ReactDOM.render(nodes, el);
    };
    return {
      renderValue: renderValue,
      resize: function(newWidth, newHeight) {
      },
    };
  },
});
