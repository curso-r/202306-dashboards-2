library(shiny)

dados <- readRDS("pkmn.rds")

ui <- fluidPage(
  theme = bslib::bs_theme(version = 4),
  titlePanel("Relatório em R Markdown dentro do Shiny"),
  hr(),
  fluidRow(
    class = "align-items-center mt-4",
    column(
      width = 3,
      selectInput(
        "pokemon",
        label = "Selecione um pokemon",
        choices = unique(dados$pokemon)
      )
    ),
    column(
      width = 3,
      downloadButton(
        "download",
        label = "Baixar relatório"
      )
    )
  )
)

server <- function(input, output, session) {

  output$download <- downloadHandler(
    filename = function() {
      glue::glue("relatorio_{input$pokemon}.pdf")
    },
    content = function(file) {

      withProgress(message = "Renderizando relatório...", {
        html_file <- tempfile(fileext = ".html")

        incProgress(0.1)

        rmarkdown::render(
          input = "template_relatorio.Rmd",
          output_file = html_file,
          params = list(pokemon = input$pokemon)
        )

        incProgress(0.4)

        pagedown::chrome_print(
          input = html_file,
          output = file
        )

        incProgress(0.5)
      })


    }
  )

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
