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
  fluidRow(
    column(
      width = 5,
      reactable::reactableOutput("tabela")
    ),
    column(
      width = 7,
      leaflet::leafletOutput("mapa") |> shinycssloaders::withSpinner()
    )
  )
)

server <- function(input, output, session) {

  tab_reactable <- reactive({
    pnud |>
      dplyr::filter(ano == input$ano) |>
      dplyr::arrange(desc(.data[[input$indice]])) |>
      dplyr::slice(1:10)
  })

  output$tabela <- reactable::renderReactable({

    linhas <- isolate(
      reactable::getReactableState(
        outputId = "tabela",
        name = "selected"
      )
    )

    if (is.null(linhas)) {
      linhas <- 1
    }

    print("Rodei tabela")

    tab_reactable() |>
      dplyr::select(
        muni_nm,
        uf_sigla,
        input$indice,
        idhm,
        espvida,
        rdpc,
        gini
      ) |>
      reactable::reactable(
        selection = "multiple",
        defaultSelected = linhas
      )
  })

  output$mapa <- leaflet::renderLeaflet({

    linhas <- reactable::getReactableState(
      outputId = "tabela",
      name = "selected"
    )

    validate(
      need(
        !is.null(linhas),
        "Selecione ao menos uma linha para ver o mapa."
      )
    )

    print("Rodei o mapa")

    tab_reactable() |>
      dplyr::slice(linhas) |>
      leaflet::leaflet() |>
      leaflet::addTiles() |>
      leaflet::addMarkers(
        lng = ~lon,
        lat = ~lat,
        label = ~muni_nm,
        popup = ~muni_nm
      )

  })

}



shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
