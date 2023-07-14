cetesb <- readRDS(
  "inst/cetesb.rds"
)


cetesb |>
  dplyr::filter(estacao_cetesb == "Ibirapuera", poluente == "O3") |>
  dplyr::filter(
    hora %in% c(12:17)
  ) |>
  dplyr::mutate(
    data = lubridate::floor_date(data, unit = "month")
  ) |>
  dplyr::group_by(data) |>
  dplyr::summarise(
    concentracao_media = mean(concentracao, na.rm = TRUE)
  ) |>
  echarts4r::e_chart(x = data) |>
  echarts4r::e_line(serie = concentracao_media)
