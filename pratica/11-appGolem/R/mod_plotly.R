#' plotly UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_plotly_ui <- function(id){
  ns <- NS(id)
  tagList(
    titlePanel(
      "PNUD - Programa das Nações Unidas para o Desenvolvimento"
    ),
    hr(),
    fluidRow(
      column(
        width = 3,
        selectInput(
          inputId = ns("ano"),
          label = "Selecione um ano",
          choices = c(1991, 2000, 2010)
        )
      )
    ),
    fluidRow(
      column(
        width = 8,
        plotly::plotlyOutput(ns("grafico"))
      ),
      column(
        width = 4,
        reactable::reactableOutput(ns("tabela"))
      )
    )
  )
}

#' plotly Server Functions
#'
#' @noRd
mod_plotly_server <- function(id, con) {
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    pnud <- dplyr::tbl(con, "pnud")

    pnud_filtrada <- reactive({
      pnud |>
        dplyr::filter(ano == !!input$ano)
    })

    output$grafico <- plotly::renderPlotly({
      pnud_filtrada() |>
        dplyr::select(rdpc, espvida) |>
        dplyr::collect() |>
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
        head(num_linha + 1) |>
        dplyr::select(
          "Nome do município" = muni_nm,
          "UF" = uf_sigla,
          "IDHM" = idhm,
          "Esperança de vida" = espvida,
          "Renda per capita" = rdpc,
          "Índice de GINI" = gini
        ) |>
        dplyr::collect() |>
        dplyr::slice(num_linha + 1) |>
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

  })
}

## To be copied in the UI
# mod_plotly_ui("plotly_1")

## To be copied in the server
# mod_plotly_server("plotly_1")
