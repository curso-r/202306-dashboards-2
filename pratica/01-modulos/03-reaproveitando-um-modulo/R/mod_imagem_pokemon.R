mod_imagem_pokemon_ui <- function(id, dados, tipo) {
  ns <- NS(id)

  opcoes <- dados |>
    filter(tipo_1 == tipo | tipo_2 == tipo) |>
    pull(pokemon)

  tagList(
    titlePanel(glue::glue("Pokemon do tipo {tipo}")),
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = ns("pokemon"),
          label = "Selecione um pokemon",
          choices = opcoes
        )
      ),
      mainPanel(
        uiOutput(ns("imagem"))
      )
    )
  )
}

mod_imagem_pokemon_server <- function(id, dados) {
  moduleServer(id, function(input, output, session) {

    output$imagem <- renderUI({
      id <- dados |>
        filter(pokemon == input$pokemon) |>
        pull(id) |>
        stringr::str_pad(width = 3, side = "left", pad = 0)


      url <- glue::glue(
        "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/{id}.png"
      )

      img(src = url, width = "50%")

    })

  })
}
