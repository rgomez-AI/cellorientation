if (!require("tcltk")) install.packages('tcltk',                                           
                                     dependencies = TRUE, 
                                     repos = 'https://cran.r-project.org')
if (!require("readr")) install.packages('readr',                                           
                                     dependencies = TRUE, 
                                     repos = 'https://cran.r-project.org')
if (!require("dplyr")) install.packages('dplyr',                                           
                                     dependencies = TRUE, 
                                     repos = 'https://cran.r-project.org')
if (!require("tidyr")) install.packages('tidyr',                                           
                                     dependencies = TRUE, 
                                     repos = 'https://cran.r-project.org')
if (!require("circular")) install.packages('circular',
                                           dependencies = TRUE, 
                                           repos = 'https://cran.r-project.org')
if (!require("DT")) install.packages('DT',                                           
                                     dependencies = TRUE, 
                                     repos = 'https://cran.r-project.org')
if (!require("scales")) install.packages('scales',
                                         dependencies = TRUE,
                                         repos = 'https://cran.r-project.org')
                                                                             
library(tcltk)
library(readr)
library(dplyr)
library(tidyr)
library(circular)
library(DT)
library(scales)
library(stats)


# Specify the file path for headless Mode
# dirPath <- commandArgs(trailingOnly = TRUE)[1]

# Constants definition
ANGULAR_APERTURE = 150
min_range = 180 + (180-ANGULAR_APERTURE)/2
max_range = 360 - (180-ANGULAR_APERTURE)/2

# Specify the files path
dirPath <- tk_choose.dir(default = "", caption = "Select directory")

# Load "Image.csv" file  and create the dataframe
file_Image <- file.path(dirPath, "Image.csv")
df_Image <- read.csv(file_Image)

# Load "Nuclei.csv" file  and create the dataframe
file_Nuclei <- file.path(dirPath, "Nuclei.csv")
df_Nuclei <- read.csv(file_Nuclei)

# sort objects from small to large for each ImageNumber
df_Nuclei <- df_Nuclei %>% arrange(ImageNumber, ObjectNumber) 

# Load "TrueCentrosome.csv" file  and create the dataframe
file_Centrosome <- file.path(dirPath, "TrueCentrosome.csv")
df_Centrosome <- read.csv(file_Centrosome)

# sort objects from small to large for each ImageNumber
df_Centrosome <- df_Centrosome %>% arrange(ImageNumber, ObjectNumber) 

# Short Summary for Nuclei
Nuclei_summary_df <- df_Nuclei %>%
                    group_by(ImageNumber) %>%
                    summarise(TotalNuclei = max(ObjectNumber),
                              NucleiINNER = max(Parent_Cell_IN),
                              NucleiOUTTER = max(Parent_Cell_OUT))

# Short Summary for Centrosome after Data Wrangling (cleaning)
Centrosome_summary_df <- df_Centrosome %>%
                         group_by(ImageNumber) %>%
                         summarise(TotalCentrosome = max(ObjectNumber),
                                   NucleiAndCtrINNER = sum(unique(Parent_Cell_IN) > 0),
                                   NucleiAndCtrOUTTER = sum(unique(Parent_Cell_OUT) > 0))

joinNclAndCtr <- left_join(Nuclei_summary_df, Centrosome_summary_df, 
                           by = "ImageNumber")

summary <- joinNclAndCtr %>%
           mutate(FileName = df_Image$FileName_DAPI, .before = ImageNumber)

# Export the Results as .HTML file
out <- file.path(dirPath, paste("Summary",".html", sep = ""))
data_HTML <- datatable(data = summary,
                       rownames = FALSE,
                       options = list( columnDefs = list(list(className = 'dt-center',
                                                              targets = "_all"))))
# Save Summary as html file
saveWidget(widget = data_HTML, 
           file = out, 
           selfcontained = TRUE,
           libdir = "lib",
           title = "Summary")

# Centrosome located at inner cells mass
df_Centrosome_IN <- df_Centrosome %>%
                    select(-ObjectNumber, -Parent_Cell_OUT) %>%
                    filter(Parent_Cell_IN > 0) %>%
                    distinct(ImageNumber, Parent_Cell_IN, .keep_all = TRUE)

# Centrosome located at outter cells mass
df_Centrosome_OUT <- df_Centrosome %>%
                     select(-ObjectNumber, -Parent_Cell_IN) %>%
                     filter(Parent_Cell_OUT > 0) %>%
                     distinct(ImageNumber, Parent_Cell_OUT, .keep_all = TRUE)                    

# Nuclei located at inner cells mass
df_Nuclei_IN <- df_Nuclei %>%
                select(-ObjectNumber, -Parent_Cell_OUT) %>%
                filter(Parent_Cell_IN > 0) %>%
                distinct(ImageNumber, Parent_Cell_IN, .keep_all = TRUE)

# Nuclei located at outter cells mass
df_Nuclei_OUT <- df_Nuclei %>%
                 select(-ObjectNumber, -Parent_Cell_IN) %>%
                 filter(Parent_Cell_OUT > 0) %>%
                 distinct(ImageNumber, Parent_Cell_OUT, .keep_all = TRUE)

# Table with coordinates from nuclei and centrosomes located at inner
# cells mass and the angle between them
joinNclAndCtr_IN <- left_join(df_Centrosome_IN, df_Nuclei_IN, 
                              by = c("ImageNumber", "Parent_Cell_IN"))
  
Cell_IN <- left_join(joinNclAndCtr_IN, df_Image[1:2], 
                     by = "ImageNumber") %>%
           mutate(FileName = FileName_DAPI, .before = ImageNumber) %>%
           select(-FileName_DAPI) %>%
           relocate(Parent_Cell_IN, .after = ImageNumber) %>%
           rename("CtrLocation_X" = "Location_Center_X.x",
                  "CtrLocation_Y" = "Location_Center_Y.x",
                  "NucleiLocation_X" = "Location_Center_X.y",
                  "NucleiLocation_Y" = "Location_Center_Y.y") 
Cell_IN <- Cell_IN %>%
           mutate(Angle = c(deg(atan2(Cell_IN$NucleiLocation_Y - Cell_IN$CtrLocation_Y,
                                  Cell_IN$CtrLocation_X - Cell_IN$NucleiLocation_X))))

# Table with coordinates from nuclei and centrosomes located at outter
# cells mass and the angle between them        
joinNclAndCtr_OUT <- left_join(df_Centrosome_OUT, df_Nuclei_OUT, 
                              by = c("ImageNumber", "Parent_Cell_OUT"))

Cell_OUT <- left_join(joinNclAndCtr_OUT, df_Image[1:2], 
                     by = "ImageNumber") %>%
            mutate(FileName = FileName_DAPI, .before = ImageNumber) %>%
            select(-FileName_DAPI) %>%
            relocate(Parent_Cell_OUT, .after = ImageNumber) %>%
            rename("CtrLocation_X" = "Location_Center_X.x",
                   "CtrLocation_Y" = "Location_Center_Y.x",
                   "NucleiLocation_X" = "Location_Center_X.y",
                   "NucleiLocation_Y" = "Location_Center_Y.y")
Cell_OUT <- Cell_OUT %>%          
            mutate(Angle = c(deg(atan2(Cell_OUT$NucleiLocation_Y - Cell_OUT$CtrLocation_Y, 
                                  Cell_OUT$CtrLocation_X - Cell_OUT$NucleiLocation_X)))) 

# Plot angle distribution inner cells mass
out <- file.path(dirPath, paste("INNERCells",".pdf", sep = ""))
pdf(out, width = 9, height = 5)
crc = circular(Cell_IN$Angle, type="angles", units = "degrees")
plot.circular(crc)
rose.diag(crc, bins=24, col="green",  prop=2.5, add=TRUE)
title('Orientation of cells located at the inner region')

# % of Cells with the orientation between 180 and 360 degrees
theta <- (360 + Cell_IN$Angle) %% 360
ratio <- sum(theta>min_range & theta<max_range)/length(Cell_IN$Angle)

# Kuiper Test of Uniformity
k <- kuiper.test(crc, alpha = 0.05)
p <- capture.output(k)
text(x = -2.4, y = 1, 
     labels = sprintf("%s",trimws(p[2])),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.8, 
     labels = sprintf("%s n: %3d",p[4], length(Cell_IN$Angle)),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.6, 
     labels = sprintf("%s",p[5]),
     col = "red",
     cex = 0.7, 
     adj= 0)
text(x = -2.4, y = 0.4, 
     labels = sprintf("Cells oriented [%1d\u00B0 - %1d\u00B0]: %s ", 
                      min_range,
                      max_range,
                      percent(ratio,1)),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.2, 
     labels = p[6],
     col = "red",
     cex = 0.7, adj = 0)

dev.off()

# Plot angle distribution from outter cells mass
out <- file.path(dirPath, paste("OUTTERCells",".pdf", sep = ""))
pdf(out, width = 9, height = 5)
crc = circular(Cell_OUT$Angle, type="angles", units = "degrees")
plot.circular(crc)
rose.diag(crc, bins=24, col="yellow",  prop=2.5, add=TRUE)
title('Orientation of cells located at the leading edge')

# % of Cells with the orientation between 180 and 360 degrees
theta <- (360 + Cell_OUT$Angle) %% 360
ratio <- sum(theta>min_range & theta<max_range)/length(Cell_OUT$Angle)

# Kuiper Test of Uniformity
k <- kuiper.test(crc, alpha = 0.05)
p <- capture.output(k)
text(x = -2.4, y = 1, 
     labels = sprintf("%s",trimws(p[2])),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.8, 
     labels = sprintf("%s n: %3d",p[4], length(Cell_OUT$Angle)),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.6, 
     labels = sprintf("%s",p[5]),
     col = "red",
     cex = 0.7, 
     adj= 0)
text(x = -2.4, y = 0.4, 
     labels = sprintf("Cells oriented [%1d\u00B0 - %1d\u00B0]: %s ", 
                      min_range,
                      max_range,
                      percent(ratio,1)),
     col = "red",
     cex = 0.7, 
     adj = 0)
text(x = -2.4, y = 0.2, 
     labels = p[6],
     col = "red",
     cex = 0.7, adj = 0)

dev.off()


## 2-sample test for equality of proportions with continuity correction
## H0: The null hypothesis is that the population of cells taken from the 
##     edge region after scratch assay in the present of "eIF2A" have the 
##     same proportion of orientation towards down direction as the control
##     
## A:  The alternative is that this proportion is bigger in the control.

# This correspont at 30 min timepoint (180-360)
#x <- c(70, 57)
#n <- c(92, 85)

# This correspont at 1h timepoint (180-360)
#x <- c(101, 55)
#n <- c(149, 85)

# This correspont at 30 min timepoint (195-345)
#x <- c(61, 45)
#n <- c(92, 85)

# This correspont at 1h timepoint (195-345)
#x <- c(92, 49)
#n <- c(149, 85)

# 2-sample test for equality of proportions with continuity correction
#res <- prop.test(x, n, alternative = "greater")
#res




