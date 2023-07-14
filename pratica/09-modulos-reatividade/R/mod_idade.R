mod_idade_ui <- function(id) {
  ns <- NS(id)
  tagList(
    mod_filtro_ui(ns("mod_filtro_ui_1")),
    shinyWidgets::useShinydashboard(),
    plotOutput(ns("grafico"))
  )
}

mod_idade_server <- function(id, credito) {
  moduleServer(id, function(input, output, session) {

    dados_filtrados <-  mod_filtro_server("mod_filtro_ui_1", credito)

    output$grafico <- renderPlot({
      dados_filtrados() |>
        dplyr::group_by(estado_civil) |>
        dplyr::summarise(idade_media = mean(idade)) |>
        ggplot(aes(y = idade_media, x = estado_civil)) +
        geom_col()
    })

  })
}
