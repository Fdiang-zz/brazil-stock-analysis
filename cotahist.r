library(readr)
library(data.table)
library(sqldf)

cotahist_list <- list.files()

assets_full <- data.frame() # Concatenation of DAILY transactions on Ibovespa from 2000-2015
assets <- data.frame()      # Subset of assets_full with only relevant observations (but all columns)

# Let's get those files concatenated
  for (cotahist in cotahist_list){
    # if the merged dataset assets_full doesn't exist, create it
    if (!exists("assets_full"))
    {
      assets_full <- read_fwf(cotahist, 
                              fwf_widths(c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3), 
                              col_names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")),
                              progress=interactive())
      
    }
    
    #if the merged dataset assets_full does exist, append to it
    if (exists("assets_full"))
    {
      temp_dataset <- read_fwf(cotahist, 
                               fwf_widths(c(2, 8, 2, 12, 3, 12, 10, 3, 4, 13, 13, 13, 13, 13, 13, 13, 5, 18, 18, 13, 1, 8, 7, 13, 12, 3), 
                               col_names = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES")),
                              progress=interactive())
      assets_full <- rbind(assets_full, temp_dataset)
      rm(temp_dataset)
    }
  }

# assets_full shall NOT be used past this point! 
# slice and dice observations to what means something
  # TIPREG "00" and "99" are header and trailer records. "01" is asset historical data (what we are interested in)
  # CODBDI "02" and "96" (Standard and Fraction) are the types of assets that we want to further analyze
  assets <- subset(assets_full, TIPREG == "01" & CODBDI %in% c("02","96"))


# Beautify dates and values with decimal places
  assets$DATE <- as.Date(assets$DATE,"%Y-%m-%d")
  assets$NOMRES <- factor(assets$NOMRES) 
  assets <- transform(assets,
                      PREABE = as.numeric(PREABE)/100,
                      PREMAX = as.numeric(PREMAX)/100,
                      PREMIN = as.numeric(PREMIN)/100,
                      PREMED = as.numeric(PREMED)/100,
                      PREULT = as.numeric(PREULT)/100,
                      PREOFC = as.numeric(PREOFC)/100,
                      PREOFV = as.numeric(PREOFV)/100,
                      TOTNEG = as.numeric(TOTNEG),
                      QUATOT = as.numeric(QUATOT),
                      VOLTOT = as.numeric(VOLTOT)/100,
                      PREEXE = as.numeric(PREEXE)/100
  )

# Getting interesting; let's calculate some daily P&L over assets
  assets$dayPL <- assets$PREULT - assets$PREABE
  assets$dayPL_pct <- (assets$dayPL / assets$PREABE)

# Slice the starting position of each asset on day 01 of each month (beggining of mont = BOM)  
  assets_BOM <- subset(assets, format(assets$DATE,"%d") == "01")
  setnames(assets_BOM, old = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES", "dayPL", "dayPL_pct")
                    ,new = c("TIPREG_BOM", "DATE_BOM", "CODBDI_BOM", "CODNEG_BOM", "TPMERC_BOM", "NOMERES_BOM", "ESPECI_BOM", "PRAZOT_BOM", "MODREF_BOM", "PREABE_BOM", "PREMAX_BOM", "PREMIN_BOM", "PREMED_BOM", "PREULT_BOM", "PREOFC_BOM", "PREOFV_BOM", "TOTNEG_BOM", "QUATOT_BOM", "VOLTOT_BOM", "PREEXE_BOM", "INDOPC_BOM", "DATVEN_BOM", "FATCOT_BOM", "PTOEXE_BOM", "CODISI_BOM", "DISMES_BOM","dayPL_BOM", "dayPL_pct_BOM")
  )
  
# And insert a Year-Month column as well
  assets_BOM$BOM <- format(assets_BOM$DATE,"%Y-%m")

# Same happens with the ending position of each month
  assets_EOM <- subset(assets, as.numeric(substr(as.Date(assets$DATE)+1,9,10)) < as.numeric(substr(assets$DATE,9,10)))
  setnames(assets_EOM, old = c("TIPREG", "DATE", "CODBDI", "CODNEG", "TPMERC", "NOMRES", "ESPECI", "PRAZOT", "MODREF", "PREABE", "PREMAX", "PREMIN", "PREMED", "PREULT", "PREOFC", "PREOFV", "TOTNEG", "QUATOT", "VOLTOT", "PREEXE", "INDOPC", "DATVEN", "FATCOT", "PTOEXE", "CODISI", "DISMES", "dayPL","dayPL_pct")
         ,new = c("TIPREG_EOM", "DATE_EOM", "CODBDI_EOM", "CODNEG_EOM", "TPMERC_EOM", "NOMERES_EOM", "ESPECI_EOM", "PRAZOT_EOM", "MODREF_EOM", "PREABE_EOM", "PREMAX_EOM", "PREMIN_EOM", "PREMED_EOM", "PREULT_EOM", "PREOFC_EOM", "PREOFV_EOM", "TOTNEG_EOM", "QUATOT_EOM", "VOLTOT_EOM", "PREEXE_EOM", "INDOPC_EOM", "DATVEN_EOM", "FATCOT_EOM", "PTOEXE_EOM", "CODISI_EOM", "DISMES_EOM", "dayPL_EOM","dayPL_pct_EOM")
  )

  assets_EOM$EOM <- format(assets_EOM$DATE,"%Y-%m")

# What a shame, merge wasn't working so used SQL instead :(
#assets_MONTH = merge(assets_BOM, assets_EOM, by.x=c("NOMERES_BOM","BOM"), by.y=c("NOMERES_EOM","EOM"))

# Put on the same observation, initial and final position of each month
  assets_MONTH <- sqldf("SELECT * 
                FROM assets_BOM, assets_EOM
                WHERE CODNEG_BOM == CODNEG_EOM and BOM == EOM")

  assets_MONTH_TOP10 <- sqldf("SELECT * FROM assets_MONTH WHERE (CODNEG_BOM ||	ESPECI_BOM) IN ('UCOP4PN *','CBMA4PN *','BELG4PN *','BELG3ON *','AVIL3ON *','PNVL3ON','NIKE34DRN','BBDC4PN *    N1','TMCP3ON *','CRTP5PNA*')")

#write.table(assets[1:100,c("PREULT","PREABE","dayPL","dayPL_pct")], "C:/users/fabio.d.gianizella/desktop/sample_assets.txt",sep="\t")
write.table(assets_MONTH_TOP10,"C:/users/fabio.d.gianizella/desktop/TOP10_assets.txt",sep="\t")
write.table(assets_MONTH,"C:/users/fabio.d.gianizella/desktop/assets_month.txt",sep="\t")
min_open <- assets_BOM

min_open <- data.table(assets_BOM)
min_open <- min_open[, .SD[which.min(assets_BOM$DATE_BOM)], by=list(CODNEG_BOM, ESPECI_BOM)]
write.table(min_open,"C:/users/fabio.d.gianizella/desktop/min_open.txt",sep="\t")

max_close <- assets_EOM
max_close <- data.table(assets_EOM)
max_close <- max_close[, .SD[which.max(assets_EOM$DATE_EOM)], by=list(CODNEG_EOM, ESPECI_EOM)]
write.table(max_close,"C:/users/fabio.d.gianizella/desktop/max_close.txt",sep="\t")
