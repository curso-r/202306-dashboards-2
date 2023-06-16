ui_grafico_dispersao <- function() {
  tagList(
    titlePanel("Gráfico de dispersão"),
    fluidRow(
      column(
        width = 4,
        selectInput(
          "variavel_x",
          label = "Selecione a variável do eixo X",
          choices = names(mtcars)
        )
      ),
      column(
        width = 4,
        selectInput(
          "variavel_y",
          label = "Selecione a variável do eixo Y",
          choices = names(mtcars)
        )
      )
    ),
    plotOutput("grafico_dispersao")
  )
}
