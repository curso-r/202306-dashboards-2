library(shiny)
library(sf)

geo_estados <- readRDS(here::here("dados/geo_estados.rds"))
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
      width = 7,
      leaflet::leafletOutput("mapa")
    ),
    column(
      width = 5,
      reactable::reactableOutput("tabela")
    )
  )
)

server <- function(input, output, session) {

  pnud_filtrada <- reactive({
    pnud |>
      dplyr::filter(ano == input$ano)
  })

  output$mapa <- leaflet::renderLeaflet({

    tab <- pnud_filtrada() |>
      dplyr::group_by(uf_sigla) |>
      dplyr::summarise(
        indice_medio = mean(.data[[input$indice]], na.rm = TRUE)
      ) |>
      dplyr::right_join(
        geo_estados,
        by = c("uf_sigla" = "abbrev_state")
      ) |>
      sf::st_as_sf()

    pegar_cor <- leaflet::colorNumeric(
      palette = rev(viridis::plasma(8)),
      domain = tab$indice_medio
    )

    tab |>
      leaflet::leaflet() |>
      leaflet::addTiles() |>
      leaflet::addPolygons(
        fillColor = ~ pegar_cor(indice_medio),
        color = "black",
        weight = 1,
        fillOpacity = 0.8,
        label = ~ name_state,
        layerId = ~uf_sigla
      ) |>
      leaflet::addLegend(
        pal = pegar_cor,
        values = ~indice_medio,
        opacity = 0.7,
        title = NULL,
        position = "bottomright"
      )

  })

  output$tabela <- reactable::renderReactable({

    estado <- input$mapa_shape_click$id

    validate(
      need(
        !is.null(estado),
        glue::glue(
          "Clique em um estado para ver os 10 municípios com o maior valor de {input$indice}."
        )
      )
    )

    pnud_filtrada() |>
      dplyr::filter(uf_sigla == estado) |>
      dplyr::arrange(desc(.data[[input$indice]])) |>
      dplyr::slice(1:10) |>
      dplyr::select(
        muni_nm,
        uf_sigla,
        input$indice,
        idhm,
        espvida,
        rdpc,
        gini
      ) |>
      reactable::reactable()

  })


}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
