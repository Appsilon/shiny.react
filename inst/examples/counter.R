library(shiny.react)

centerStyle <- "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"

shinyApp(
  ui = div(style = centerStyle,
    checkboxInput("render", label = "Render UI?"),
    uiOutput("ui")
  ),
  server = function(input, output) {
    output$ui <- renderUI({
      if (input$render) Box(
        checkboxInput("renderNested", label = "Render nested UI?"),
        uiOutput("nested")
      )
    })
    output$nested <- renderUI({
      if (input$renderNested) div(
        p("Note how Bootstrap was added only just now."),
        Box(
          bootstrapLib(),
          h4("Counter"),
          Counter(defaultValue = 42, onChange = setInput("counter")),
          h4("Pinger"),
          Pinger(),
        )
      )
    })
    observeEvent(input$counter, showNotification(paste(input$counter)))
  }
)
