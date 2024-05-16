# shiny.react 0.4.0

- Upgrade React to 18.3.1:
  - Replace deprecated React API. React 18 deprecates (React 19 removes) `ReactDOM.render` and `ReactDOM.unmountComponentAtNode`. `ReactDOM.createRoot` is used in place of those functions according to the [React 19 migration guide](https://react.dev/blog/2024/04/25/react-19-upgrade-guide#removed-deprecated-react-dom-apis).
  - Changed rendering mechanism of React components. This change is motivated by the fact that it's impossible to call `ReactDOM.createRoot` on a container more than one time while `ReactDOM.render` allowed that. A `data-react-id` attribute is used to find and render React roots in place iterating over all nodes with `.react-data` class.

# shiny.react 0.3.0

1. Render React asynchronously and only once Shiny is fully initialized:
    * `reactOutput()` can now be nested.
    * `ShinyProxy` is no longer needed and was removed from the JavaScript API.
2. Support rate limiting (debounce and throttle) in `InputAdapter`.
3. `updateReactInput()` now works correctly with tibbles.

# shiny.react 0.2.3

Improved documentation, including a tutorial vignette.

# shiny.react 0.2.2

* `updateReactInput()` applies namespace automatically.
* `updateReactInput()` can be used to update components created with ButtonAdapter.

# shiny.react 0.2.1

Minor changes for CRAN resubmission.

# shiny.react 0.2.0

This is the first public release, with several big interface changes:

* Removed `withReact()`. Components now work without it!
* Removed `make_input()`, `make_output()` and `mark_as_react_tag()`.
  Components can now be defined by combining `reactElement()` and `asProps()`.
* Removed `reactWidget()` - no longer applicable / necessary.
* Renamed `ShinyComponentWrapper` to `ShinyBindingWrapper` and made it internal.
* Added `setInput()` and `triggerEvent()` helpers.

# shiny.react 0.1.0

Initial release made available to the early access group.
