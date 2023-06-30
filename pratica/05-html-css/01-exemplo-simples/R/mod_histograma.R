mod_histograma_ui <- function(id) {
  ns <- NS(id)
  tagList(
    titlePanel("Histograma"),
    fluidRow(
      column(
        width = 4,
        selectInput(
          ns("variavel"),
          label = "Selecione a variável do histograma",
          choices = names(mtcars)
        )
      )
    ),
    plotOutput(ns("histograma"))
  )
}

mod_histograma_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$histograma <- renderPlot({
      hist(mtcars[[input$variavel]])
    })

  })
}
