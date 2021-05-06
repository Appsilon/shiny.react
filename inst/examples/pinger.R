library(shiny.react)

colors <- list("Gold", "Lavender", "Salmon")

shinyApp(
  ui = bootstrapPage(
    reactOutput("ui"),
    selectInput("color", label = "Background color", choices = colors)
  ),
  server = function(input, output) {
    output$ui <- renderReact(
      Box(style = list(backgroundColor = input$color),
        Pinger()
      )
    )
  }
)
