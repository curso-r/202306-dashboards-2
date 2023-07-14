library(shiny)

e_tooltip <- function (e, trigger = c("item", "axis"), ...) {
  if (missing(e)) {
    stop("must pass e", call. = FALSE)
  }
  tooltip <- list(trigger = trigger[1], ...)
  if (!e$x$tl) {
    e$x$opts$tooltip <- tooltip
  }
  else {
    e$x$opts$baseOption$tooltip <- tooltip
  }
  e
}

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
    ),
    column(
      width = 3,
      selectInput(
        inputId = "indice",
        label = "Selecione um índice",
        choices = c(
          "IDHM" = "idhm",
          "Expectativa de vida" = "espvida",
          "Renda per capita" = "rdpc",
          "Índice de GINI" = "gini"
        )
      )
    )
  ),
  echarts4r::echarts4rOutput("grafico")
)

server <- function(input, output, session) {

  output$grafico <- echarts4r::renderEcharts4r({
    pnud |>
      dplyr::filter(ano == input$ano) |>
      dplyr::group_by(uf_sigla) |>
      dplyr::summarise(
        indice_medio = mean(.data[[input$indice]], na.rm = TRUE)
      ) |>
      dplyr::arrange(desc(indice_medio)) |>
      echarts4r::e_chart(x = uf_sigla) |>
      echarts4r::e_bar(serie = indice_medio) |>
      echarts4r::e_legend(show = FALSE) |>
      echarts4r::e_color(color = "purple") |>
      echarts4r::e_title(
        text = glue::glue("{input$indice} por estado"),
        left = "center",
        textStyle = list(
          color = "orange",
          fontSize = 24
        )
      ) |>
      echarts4r::e_x_axis(
        name = "Estado",
        nameLocation = "center",
        nameGap = 35
      ) |>
      echarts4r::e_y_axis(
        name = input$indice,
        nameLocation = "center",
        nameGap = 35
      ) |>
      e_tooltip(
        trigger  = "item"
      )
  })

}

shinyApp(ui, server,  options = list(launch.browser = FALSE, port = 4242))












