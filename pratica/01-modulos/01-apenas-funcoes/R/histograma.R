ui_histograma <- function() {
  tagList(
    titlePanel("Histograma"),
    fluidRow(
      column(
        width = 4,
        selectInput(
          "variavel",
          label = "Selecione a variável do histograma",
          choices = names(mtcars)
        )
      )
    ),
    plotOutput("histograma")
  )
}
