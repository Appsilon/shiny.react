library(shiny.react)

depx <- htmltools::htmlDependency("depx", "1.0.0", "www", script = "js/x.js")
depy <- htmltools::htmlDependency("depy", "1.0.0", "www", script = "js/y.js")
depz <- htmltools::htmlDependency("depz", "1.0.0", "www", script = "js/z.js")

# The app should output X, Y, Z (in that order) to the console.

shinyApp(
  ui = reactOutput("ui"),
  server = function(input, output) {
    output$ui <- renderReact(
      div(
        Box(depx, htmltools::attachDependencies("Hello!", depy)),
        depz
      )
    )
  }
)
