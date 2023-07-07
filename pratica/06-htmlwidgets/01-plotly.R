library(shiny)

pnud <- readRDS(here::here("dados/pnud_min.rds"))

ui <- fluidPage(
  titlePanel(
    "PNUD - Programa das Nações Unidas para o Desenvolvimento"
  ),
  hr(),
  fluidRow(
    column(
      width = 3,
      selectInput(
        inputId = "ano",
        label = "Selecione um ano",
        choices = sort(unique(pnud$ano))
      )
    )
  ),
  fluidRow(
    column(
      width = 8,
      plotly::plotlyOutput("grafico")
    ),
    column(
      width = 4,
      reactable::reactableOutput("tabela")
    )
  )
)

server <- function(input, output, session) {

  pnud_filtrada <- reactive({
    pnud |>
      dplyr::filter(ano == input$ano)
  })

  output$grafico <- plotly::renderPlotly({
    pnud_filtrada() |>
      plotly::plot_ly(
        type = "scatter",
        x = ~rdpc,
        y = ~espvida
      )
  })

  output$tabela <- reactable::renderReactable({

    num_linha <- plotly::event_data("plotly_click")$pointNumber

    validate(
      need(
        !is.null(num_linha),
        "Clique em um ponto do gráfico para saber mais sobre o município."
      )
    )

    pnud_filtrada() |>
      dplyr::slice(num_linha + 1) |>
      dplyr::select(
        "Nome do município" = muni_nm,
        "UF" = uf_sigla,
        "IDHM" = idhm,
        "Esperança de vida" = espvida,
        "Renda per capita" = rdpc,
        "Índice de GINI" = gini
      ) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
      tidyr::pivot_longer(
        cols = dplyr::everything(),
        names_to = "variavel",
        values_to = "valor"
      ) |>
      reactable::reactable(
        columns = list(
          variavel = reactable::colDef(
            name = ""
          ),
          valor = reactable::colDef(
            name = ""
          )
        )
      )

  })


}

shinyApp(ui, server)
