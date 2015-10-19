library(rprintf)
cotahist_list <- list.files()
assets <- data.frame()

  temp_dataset<-read.fwf(cotahist_list, 
                  widths = c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3), 
                  col.names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")
    )
  
  assets<-rbind(assets, temp_dataset)
  rm(temp_dataset)
  
nrow(assets)
