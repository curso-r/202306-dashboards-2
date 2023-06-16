library(shiny)

# source("R/mod_grafico_dispersao.R")
# source("R/mod_histograma.R")

ui <- fluidPage(
  mod_grafico_dispersao_ui("mod_grafico_dispersao_1"),
  hr(),
  mod_histograma_ui("mod_histograma_1")
)

server <- function(input, output, session) {

  mod_grafico_dispersao_server("mod_grafico_dispersao_1")
  mod_histograma_server("mod_histograma_1")

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
