#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  con <- DBI::dbConnect(
    RSQLite::SQLite(),
    app_sys("pnud_min.sqlite")
  )


  mod_plotly_server("plotly_1", con)

}
