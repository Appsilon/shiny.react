init_driver <- function(app) {
  shinytest2::AppDriver$new(app, variant = shinytest2::platform_variant())
}

describe("rendering with htmltools::HTML", {
  it("renders HTML strings in React context from ui function when wrapped with `htmltools::HTML`", {
    skip_on_cran()

    app <- init_driver(shiny::shinyApp(
      ui = ReactContext(htmltools::HTML(
        "<span style='font-weight: bold;'>Hello <span style='font-weight: normal;'>from ReactContext in UI</span></span>"
      )),
      server = function(input, output) {}
    ))

    app$expect_screenshot(
      name = "render_html_from_ui",
      cran = FALSE
    )
  })

  it("renders HTML strings from renderReact when wrapped with `htmltools::HTML`", {
    skip_on_cran()

    app <- init_driver(shiny::shinyApp(
      ui = reactOutput("react_output"),
      server = function(input, output) {
        output$react_output <- renderReact({
          htmltools::HTML(
            "<span style='font-weight: bold;'>Hello <span style='font-weight: normal;'>from ReactContext in renderReact</span></span>"
          )
        })
      }
    ))

    app$expect_screenshot(
      name = "render_html_from_server",
      cran = FALSE
    )
  })

  it("doesn't render HTML strings in React context without `htmltools::HTML`", {
    skip_on_cran()

    app <- init_driver(shiny::shinyApp(
      ui = ReactContext(
        "<span style='font-weight: bold;'>Hello <span style='font-weight: normal;'>from ReactContext in UI without htmltools::HTML</span></span>"
      ),
      server = function(input, output) {}
    ))

    app$expect_screenshot(
      name = "doesnt_render_html_from_ui",
      cran = FALSE
    )
  })
})
