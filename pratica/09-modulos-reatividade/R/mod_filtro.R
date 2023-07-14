mod_filtro_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      shinydashboard::box(
        title = "Filtros",
        width = 12,
        fluidRow(
          column(
            width = 3,
            selectInput(
              ns("status"),
              label = "Tipo de cliente",
              choices = c("bom", "ruim")
            )
          ),
          column(
            width = 3,
            sliderInput(
              ns("valor"),
              label = "Valor do empréstimo",
              min = 100,
              max = 5000,
              value = c(1000, 2000),
              step = 100
            )
          )
        )
      )
    )
  )
}

mod_filtro_server <- function(id, credito) {
  moduleServer(id, function(input, output, session) {

    # valores_filtro <- reactive({
    #   list(status = input$status, valor = input$valor)
    # })
    #
    # return(valores_filtro)

    dados_filtrados <- reactive({
      credito |>
        dplyr::filter(
          status == input$status,
          valor_emprestimo >= input$valor[1],
          valor_emprestimo <= input$valor[2]
        )
    })

    return(dados_filtrados)

  })
}







