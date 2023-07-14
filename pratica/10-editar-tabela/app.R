library(shiny)

con <- DBI::dbConnect(
  RSQLite::SQLite(),
  here::here("pratica/09-editar-tabela/mtcars.sqlite")
)

ui <- fluidPage(
  titlePanel("Editando tabela de dados"),
  hr(),
  DT::DTOutput("tabela"),
  hr(),
  actionButton("salvar", label = "Salvar tabela"),
  hr(),
  plotOutput("grafico")
)

server <- function(input, output, session) {

  tab <- dplyr::tbl(con, "mtcars") |>
    dplyr::collect()

  tabela_reativa <- reactiveVal(tab)


  output$tabela <- DT::renderDT({
    tabela_reativa() |>
      DT::datatable(
        editable = TRUE
      )
  })

  proxy <- DT::dataTableProxy("tabela")

  observeEvent(input$tabela_cell_edit, {

    tab_atual <- tabela_reativa()
    tab_atualizada <- DT::editData(tab_atual, input$tabela_cell_edit)

    tabela_reativa(tab_atualizada)

    DT::replaceData(
      proxy,
      tab_atualizada
    )

  })

  output$grafico <- renderPlot({
    tabela_reativa() |>
      ggplot2::ggplot(ggplot2::aes(x = wt, y = mpg)) +
      ggplot2::geom_point()
  })


  observeEvent(input$salvar, {

    DBI::dbWriteTable(con, "mtcars", tabela_reativa(), overwrite = TRUE)

    # showModal(
    #   modalDialog(
    #     title = "Sucesso!",
    #     "A tabela foi salva!!"
    #   )
    # )

    shinyWidgets::show_alert(
      title = "Sucesso!",
      text = "A tabela foi salva!!",
      type = "success"
    )

  })

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
