library(readr)
cotahist_list <- list.files()
assets_full <- data.frame()
assets <- data.frame()

for (cotahist in cotahist_list) 
  {
  rprintf("Processing file: %s", cotahist)
  # if the merged dataset assets_full doesn"t exist, create it
  if (!exists("assets_full"))
    {
    assets_full <- read_fwf(file, 
                     fwf_widths(c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3)), 
                     col_names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")
                     progress=interactive())
  }
  
  # if the merged dataset assets_full does exist, append to it
  if (exists("assets_full"))
    {
    temp_dataset <- read_fwf(cotahist, 
                     fwf_widths(c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3)), 
                     col_names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")
                     progress=interactive())
    assets_full <- rbind(assets_full, temp_dataset)
    rm(temp_dataset)
    }
}

# slice and dice observations to what means something
# TIPREG "00" and "99" are header and trailer records. "01" is asset historical data (what we are interested in)
# CODBDI "02" and "96" are the types of assets that we want to further analyze
assets <- subset(assets_full, TIPREG == "01" & CODBDI %in% c("02","96"))
