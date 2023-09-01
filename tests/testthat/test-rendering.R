initDriver <- function(app) {
  shinytest2::AppDriver$new(app, variant = shinytest2::platform_variant())
}

describe("rendering with htmltools::HTML", {
  it("renders HTML strings in React context from ui function when wrapped with `htmltools::HTML`", {
    skip_on_cran()

    # Arrange
    app <- initDriver(shiny::shinyApp(
      ui = ReactContext(htmltools::HTML(
        '<span id="test">Hello<span style="font-weight: bold;"> World</span></span>'
      )),
      server = function(input, output) {}
    ))
    withr::defer(app$stop())

    # Act
    html <- app$get_html("#test")

    # Assert
    expect_equal(
      html,
      '<span id="test">Hello<span style="font-weight: bold;"> World</span></span>'
    )
  })

  it("renders HTML strings from renderReact when wrapped with `htmltools::HTML`", {
    skip_on_cran()

    # Arrange
    app <- initDriver(shiny::shinyApp(
      ui = reactOutput("react_output"),
      server = function(input, output) {
        output$react_output <- renderReact({
          htmltools::HTML(
            '<span id="test">Hello<span style="font-weight: bold;"> World</span></span>'
          )
        })
      }
    ))
    withr::defer(app$stop())

    # Act
    html <- app$get_html("#test")

    # Assert
    expect_equal(
      html,
      '<span id="test">Hello<span style="font-weight: bold;"> World</span></span>'
    )
  })

  it("doesn't render HTML strings in React context without `htmltools::HTML`", {
    skip_on_cran()

    # Arrange
    app <- initDriver(shiny::shinyApp(
      ui = ReactContext(
        '<span id="test">Hello<span style="font-weight: bold;"> World</span></span>'
      ),
      server = function(input, output) {}
    ))
    withr::defer(app$stop())

    # Act
    html <- app$get_html("#test")
    htmlContainer <- app$get_html(".react-container")

    # Assert
    # Span hasn't been rendered as HTML, so it's null
    expect_null(html)
    # The container div has been rendered as HTML, but the span is escaped
    expect_equal(
      htmlContainer,
      '<div class="react-container">&lt;span id="test"&gt;Hello&lt;span style="font-weight: bold;"&gt; World&lt;/span&gt;&lt;/span&gt;</div>' #nolint
    )
  })
})
