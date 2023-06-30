library(shiny)

# source("R/mod_grafico_dispersao.R")
# source("R/mod_histograma.R")

ui <- fluidPage(
  tags$head(
    tags$link(href = "custom.css", rel = "stylesheet")
  ),
  h1(
    "App com exemplo de módulos",
    style = "color: purple; text-align: center;"
  ),
  hr(),
  mod_grafico_dispersao_ui("mod_grafico_dispersao_1"),
  hr(),
  mod_histograma_ui("mod_histograma_1"),
  hr(),
  div(
    class = "rodape",
    div(
      class = "bloco-logos",
      img(src = "hex-torchaudio.webp"),
      img(src = "stockfish.webp"),
      img(src = "treesnip.webp")
    )
  )
)

server <- function(input, output, session) {

  mod_grafico_dispersao_server("mod_grafico_dispersao_1")
  mod_histograma_server("mod_histograma_1")

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
