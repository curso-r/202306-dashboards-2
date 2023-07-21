library(shiny)

pnud <- readRDS(here::here("dados/pnud_min.rds"))

ui <- fluidPage(
  titlePanel("Aplicativo Shiny com SidebarLayout"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "estado",
        label = "Selecione um estado",
        choices = sort(unique(pnud$uf_sigla))
      )
    ),
    mainPanel(
      esquisse::esquisse_ui(id = "esquisse")
    )
  )
)

server <- function(input, output) {

  pnud_rv <- reactiveValues(data = pnud, name = "pnud")

  observe({
    pnud_rv$data <- pnud |> dplyr::filter(uf_sigla == input$estado)
    pnud_rv$name <- glue::glue("pnud-{input$estado}")
  })

  esquisse::esquisse_server(
    id = "esquisse",
    data_rv = pnud_rv,
    import_from = c("file", "copypaste", "googlesheets")
  )

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
