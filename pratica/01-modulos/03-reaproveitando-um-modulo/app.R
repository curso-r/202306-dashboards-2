library(shiny)
library(dplyr)

dados <- readRDS(here::here("dados/pkmn.rds"))

tipos <- dados |>
  pull(tipo_1) |>
  unique() |>
  sort()

ui <- navbarPage(
  title = "Pokemon",
  id = "menu"
)

# ui <- fluidPage(
#   purrr::map(
#     tipos,
#     ~ mod_imagem_pokemon_ui(glue::glue("mod_imagem_pokemon_{.x}"), dados, .x),
#     # function(tipo) {
#     #   mod_imagem_pokemon_server(glue::glue("mod_imagem_pokemon_{tipo}"), dados, tipo)
#     # }
#   )
# )

server <- function(input, output, session) {

  purrr::walk(
    tipos,
    ~ insertTab(
      inputId = "menu",
      tabPanel(
        title = stringr::str_to_title(.x),
        mod_imagem_pokemon_ui(glue::glue("mod_imagem_pokemon_{.x}"), dados, .x)
      ),
      select = TRUE
    )
  )

  purrr::walk(
    tipos,
    ~ mod_imagem_pokemon_server(glue::glue("mod_imagem_pokemon_{.x}"), dados),
  )

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
