library(shiny)
library(bs4Dash)
library(dplyr)
library(ggplot2)

ssp <- readRDS(here::here("dados/ssp.rds")) |>
  filter(regiao_nome %in% c("Capital", "Grande São Paulo", "Santos"))

ui <- dashboardPage(
  dashboardHeader(title = "Segurança Pública"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        text = "Sobre",
        tabName = "sobre",
        icon = icon("info")
      ),
      menuItem(
        text = "Visão geral",
        tabName = "visao_geral",
        icon = icon("eye")
      ),
      menuItem(
        text = "Regiões",
        menuSubItem(
          text = "Capital",
          tabName = "regiao_sao_paulo"
        ),
        menuSubItem(
          text = "Grande São Paulo",
          tabName = "regiao_grande_sp"
        ),
        menuSubItem(
          text = "Santos",
          tabName = "regiao_santos"
        )
      )
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(href = "custom.css", rel = "stylesheet")
    ),
    tabItems(
      tabItem(
        tabName = "sobre",
        titlePanel("Sobre")
      ),
      tabItem(
        tabName = "visao_geral",
        titlePanel("Visão geral"),
        p("Os dados que você vai ver neste aplicativo correspondem a:"),
        fluidRow(
          valueBoxOutput(outputId = "num_regioes", width = 4),
          valueBoxOutput(outputId = "num_cidades", width = 4),
          valueBoxOutput(outputId = "num_delegacias", width = 4)
        ),
        fluidRow(
          tabBox(
            title = "Destaques",
            width = 12,
            tabPanel(
              title = "Roubo de carro",
              plotOutput("grafico_roubo_carros", height = "600px")
            ),
            tabPanel(
              title = "Ocorrência 2"
            ),
            tabPanel(
              title = "Ocorrência 3"
            )
          )
        )
      ),
      tabItem(
        tabName = "regiao_sao_paulo",
        titlePanel("Dados para a Capital"),
        fluidRow(
          box(
            title = "Filtros",
            width = 12,
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "delegacia_sp",
                  label = "Selecione uma delegacia",
                  choices = ssp |>
                    filter(regiao_nome == "Capital") |>
                    distinct(delegacia_nome) |>
                    pull()
                )
              ),
              column(
                width = 4,
                selectInput(
                  inputId = "ocorrencia_sp",
                  label = "Selecione uma ocorrência",
                  choices = ssp |>
                    select(estupro:vit_latrocinio) |>
                    names()
                )
              )
            )
          )
        ),
        plotOutput("serie_sp")
      ),
      tabItem(
        tabName = "regiao_grande_sp",
        titlePanel("Dados para a Grande São Paulo"),
        fluidRow(
          box(
            width = 12,
            fluidRow(
              column(
                width = 4,
                selectInput(
                  inputId = "municipio_grande_sp",
                  label = "Selecione um município",
                  choices = ssp |>
                    filter(regiao_nome == "Grande São Paulo") |>
                    distinct(municipio_nome) |>
                    pull()
                )
              ),
              column(
                width = 4,
                uiOutput("filtro_delegacia_grande_sp")
              ),
              column(
                width = 4,
                selectInput(
                  inputId = "ocorrencia_grande_sp",
                  label = "Selecione uma ocorrência",
                  choices = ssp |>
                    select(estupro:vit_latrocinio) |>
                    names()
                )
              )
            )
          )
        ),
        plotOutput("serie_grande_sp"),
        img(src = "https://media.tenor.com/wgkPy8pGP6UAAAAd/true-its-true.gif")
      )
    )
  )
)

server <- function(input, output, session) {

  output$num_regioes <- renderValueBox({
    num_regioes <- n_distinct(ssp$regiao_nome)
    valueBox(
      value = num_regioes,
      subtitle = "Número de regiões",
      icon = icon("map"),
      color = "primary"
    )
  })

  output$num_cidades <- renderValueBox({
    num_cidades <- n_distinct(ssp$municipio_nome)
    valueBox(
      value = num_cidades,
      subtitle = "Número de cidades",
      icon = icon("city"),
      color = "purple"
    )
  })


  output$num_delegacias <- renderValueBox({
    num_delegacias <- n_distinct(ssp$delegacia_nome)
    valueBox(
      value = num_delegacias,
      subtitle = "Número de delegacias",
      icon = icon("shield-alt"),
      color = "fuchsia",
      href = "http://www.ssp.sp.gov.br/"
    )
  })

  output$grafico_roubo_carros <- renderPlot({
    ssp |>
      filter(ano >= 2018) |>
      group_by(mes, ano, regiao_nome) |>
      summarise(
        total_roubo_carro = sum(roubo_veiculo)
      ) |>
      mutate(
        data = lubridate::make_date(
          year = ano,
          month = mes,
          day = 1
        )
      ) |>
      ggplot(aes(x = data, y = total_roubo_carro)) +
      geom_col(color = "black", fill = "royalblue") +
      facet_wrap(vars(regiao_nome), nrow = 3)
  })



  output$serie_sp <- renderPlot({
    ssp |>
      filter(
        municipio_nome == "São Paulo",
        delegacia_nome == input$delegacia_sp
      ) |>
      mutate(
        data = lubridate::make_date(
          year = ano,
          month = mes,
          day = 1
        )
      ) |>
      ggplot(aes(x = data, y = .data[[input$ocorrencia_sp]])) +
      geom_col(color = "black", fill = "royalblue")
  })

  output$filtro_delegacia_grande_sp <- renderUI({
    selectInput(
      inputId = "delegacia_grande_sp",
      label = "Selecione uma delegacia",
      choices = ssp |>
        filter(municipio_nome == input$municipio_grande_sp) |>
        distinct(delegacia_nome) |>
        pull()
    )
  })

  output$serie_grande_sp <- renderPlot({
    ssp |>
      filter(
        municipio_nome == input$municipio_grande_sp,
        delegacia_nome == input$delegacia_grande_sp
      ) |>
      mutate(
        data = lubridate::make_date(
          year = ano,
          month = mes,
          day = 1
        )
      ) |>
      ggplot(aes(x = data, y = .data[[input$ocorrencia_grande_sp]])) +
      geom_col(color = "black", fill = "royalblue")
  })

}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
