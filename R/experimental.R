testComponent <- function(name) {
  function(...) {
    reactElement(
      module = "@/shiny.react/test-components", name = name,
      props = asProps(...)
    )
  }
}

# nolint start
Box <- testComponent("Box")
Counter <- testComponent("Counter")
Pinger <- testComponent("Pinger")
# nolint end

ShinyBindingWrapper <- function(...) reactElement( # nolint
  module = "@/shiny.react", name = "ShinyBindingWrapper", props = asProps(...)
)
