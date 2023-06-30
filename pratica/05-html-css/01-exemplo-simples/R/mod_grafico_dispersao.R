mod_grafico_dispersao_ui <- function(id) {
  ns <- NS(id)

  tagList(
    titlePanel("Gráfico de dispersão"),
    fluidRow(
      column(
        width = 4,
        selectInput(
          ns("variavel_x"),
          label = "Selecione a variável do eixo X",
          choices = names(mtcars)
        )
      ),
      column(
        width = 4,
        selectInput(
          ns("variavel_y"),
          label = "Selecione a variável do eixo Y",
          choices = names(mtcars)
        )
      )
    ),
    plotOutput(ns("grafico_dispersao"))
  )
}

mod_grafico_dispersao_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$grafico_dispersao <- renderPlot({
      plot(x = mtcars[[input$variavel_x]], y = mtcars[[input$variavel_y]])
    })

  })
}
