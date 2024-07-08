library(here)
library(tidyverse)

path <- "\\\\nimhlabstore.nimh.nih.gov\\SBN\\Chudasama\\Lowrie\\SWOP photometry\\Data\\data AUC"


# regex patterns
brain_rgn <- "(CA1|vPFC)"
gain_ptn <- "(Gain|Loss)"
event_ptn <- "(PrtA[0-9]+)"
id_ptn <- "(?:/[^/]*){3}/([0-9]{3})"

# Get all csv files in the folder
data_files <- list.files(path = path, pattern = "*AUCData.csv$",
                          full.names = TRUE, recursive = TRUE)

named_data_files <- purrr::set_names(data_files, nm = str_extract(data_files, pattern = "/(.+)\\.csv$"))

df_ <- named_data_files |>
  map_dfr(read_csv, .id = "file", col_types = "iid_", skip_empty_rows = TRUE) |> 
  na.omit()

df <- df_ |>
  dplyr::mutate(brain_region = str_extract(file, brain_rgn) |> factor(), .after = file) |> 
  dplyr::mutate(gain_loss = str_extract(file, gain_ptn) |> factor(), .after = brain_region) |> 
  dplyr::mutate(event = str_extract(file, event_ptn) |> factor(), .after = gain_loss) |> 
  dplyr::mutate(animal_id = str_extract(file, id_ptn), animal_id = str_extract(animal_id, "[0-9]{3}$") |> factor(), .after = file)

path <- "\\\\nimhlabstore.nimh.nih.gov\\SBN\\Chudasama\\Lowrie\\SWOP photometry\\gain_loss_AUC.csv"
write_csv(df, path)