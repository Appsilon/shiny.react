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
