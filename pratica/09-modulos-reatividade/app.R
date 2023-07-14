library(shiny)
library(ggplot2)

ui <- navbarPage(
  title = "Análise de crédito",
  tabPanel(
    "Idade",
    mod_idade_ui("mod_idade_1")
  ),
  tabPanel(
    "Renda",
    # Módulo da página de renda
  ),
  tabPanel(
    "Estado civil",
    # Módulo da página de estado civil
  )
)

server <- function(input, output, session) {

  credito <- readRDS(here::here("dados/credito.rds"))

  mod_idade_server("mod_idade_1", credito)

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
