library(shiny)

con <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  here::here("pratica/07-banco-de-dados/exemplo-simples/pnud_min.sqlite")
)

# DBI::dbListTables(con)
# DBI::dbWriteTable(con, "mtcars", mtcars)
#
# DBI::dbReadTable(con, "mtcars")

ui <- fluidPage(
  titlePanel("IDH para os estados brasileiros"),
  fluidRow(
    column(
      width = 6,
      selectInput(
        "ano",
        label = "Ano",
        choices = c(1991, 2000, 2010)
      )
    ),
    column(
      width = 6,
      selectInput(
        "estado",
        label = "Estado",
        choices = c("Carregando..." = "")
      )
    )
  ),
  hr(),
  reactable::reactableOutput("tabela")
)

server <- function(input, output, session) {

  estados <- dplyr::tbl(con, "pnud") |>
    dplyr::distinct(uf_sigla) |>
    # dplyr::collect()
    dplyr::pull(uf_sigla) |>
    sort()

  updateSelectInput(
    inputId = "estado",
    choices = estados
  )

  output$tabela <- reactable::renderReactable({
    dplyr::tbl(con, "pnud") |>
      dplyr::filter(ano == !!input$ano, uf_sigla == !!input$estado) |>
      dplyr::arrange(desc(idhm)) |>
      head(10) |>
      dplyr::select(
        muni_nm,
        idhm
      ) |>
      dplyr::collect() |>
      reactable::reactable()
  })

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
