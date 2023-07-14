#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  cetesb <- readRDS(
    app_sys("cetesb.rds")
  )

  estacoes <- cetesb |>
    dplyr::distinct(estacao_cetesb) |>
    dplyr::pull(estacao_cetesb) |>
    sort()

  updateSelectInput(
    inputId = "estacao",
    choices = estacoes
  )

  observe({
    req(input$estacao)

    poluentes <- cetesb |>
      dplyr::filter(estacao_cetesb == input$estacao) |>
      dplyr::pull(poluente) |>
      unique() |>
      sort()

    updateSelectInput(
      inputId = "poluente",
      choices = poluentes
    )

  })

  output$grafico <- echarts4r::renderEcharts4r({
    cetesb |>
      dplyr::filter(
        estacao_cetesb == input$estacao,
        poluente == input$poluente
      ) |>
      dplyr::filter(
        hora %in% c(12:17)
      ) |>
      dplyr::mutate(
        data = lubridate::floor_date(data, unit = "month")
      ) |>
      dplyr::group_by(data) |>
      dplyr::summarise(
        concentracao_media = mean(concentracao, na.rm = TRUE)
      ) |>
      echarts4r::e_chart(x = data) |>
      echarts4r::e_line(serie = concentracao_media)
  })

}





