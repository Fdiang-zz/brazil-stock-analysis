library(rprintf)
cotahist_list <- list.files()
assets <- data.frame()

for (cotahist in cotahist_list) 
  {
  rprintf("Processing file: %s", cotahist)
  # if the merged dataset assets doesn"t exist, create it
  if (!exists("assets"))
    {
    assets<-read.fwf(file, 
                     widths = c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3), 
                     col.names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES"))
    
  }
  
  
  # if the merged dataset assets does exist, append to it
  if (exists("assets"))
    {
    temp_dataset<-read.fwf(cotahist, 
                    widths = c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3), 
                    col.names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")
    )
                    assets<-rbind(assets, temp_dataset)
    rm(temp_dataset)
    }
}
nrow(assets)
