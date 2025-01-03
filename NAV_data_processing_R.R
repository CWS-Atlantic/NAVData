############################################
##  Code to process NAV data in to a csv  ##
############################################

##Load in required packages. If not installed use: install.packages("dplyr") and "install.packages("stringr")

require(dplyr)
require(stringr)


################
##  NAV data  ##
################

start.time <- Sys.time()

#set your working directory to be one of the batches of files received, unzipped
setwd("C:/Users/englishm/Desktop/2024004_NAV-20241008T124531Z-002")

#create a list of all files named "Offset.txt"
offset_files <- dir("C:/Users/englishm/Desktop/2024004_NAV-20241008T124531Z-002", recursive=TRUE, full.names=TRUE, pattern="Offset.txt$")

#create a blank datafram
nav.data <- NULL

#run a loop to read all Offset.txt files and append them to each other, retaining the file name
for (f in offset_files) {
  dat <- read.csv(f, header=F)
  dat$file <- unlist(strsplit(f,split=".",fixed=T))[1] #this line retains the filename
  nav.data <- rbind(nav.data, dat)
}

#check the structure - it'll be big and messy
str(nav.data)

#rename columns so they're easier to work with
names(nav.data) <-
  c("GSCA_ID",
    "UNKNOWN",
    "TIME_LAT",
    "LON",
    "EASTING",
    "NORTHING",
    "UTM_ZONE",
    "HEADING",
    "FILE_NAME")


#fix latitudes
nav.data$LAT <- nav.data$TIME_LAT

nav.data$LAT <- sub(".*Lat:  ", "", nav.data$TIME_LAT)

nav.data$LAT <- as.numeric(nav.data$LAT)


#fix longitudes
nav.data$LON <- gsub("Lon:", "", nav.data$LON)

nav.data$LON <- as.numeric(nav.data$LON)


#fix northings
nav.data$NORTHING <- gsub("N:  ", "", nav.data$NORTHING)

nav.data$NORTHING <- as.numeric(nav.data$NORTHING)


#fix eastings
nav.data$EASTING <- gsub("E:  ", "", nav.data$EASTING)

nav.data$EASTING <- as.numeric(nav.data$EASTING)


#fix heading
nav.data$HEADING <- gsub("heading:  ", "", nav.data$HEADING)

nav.data$HEADING <- as.numeric(nav.data$HEADING)

#fix utm zone
nav.data$UTM_ZONE <- gsub("zone: ", "", nav.data$UTM_ZONE)

nav.data$UTM_ZONE <- as.numeric(nav.data$UTM_ZONE)


#fix times: extract the time between T(time) and Z (zulu) in the large string (TIME_LAT)
nav.data$TIME <- str_match(nav.data$TIME_LAT, "T\\s*(.*?)\\s*Z")

nav.data$TIME <- nav.data$TIME[,2]

str(nav.data)


#extract the date between CALC and T(time) in the large string
nav.data$DATE <- str_match(nav.data$TIME_LAT, "CALC\\s*(.*?)\\s*T")

#fix date
nav.data$DATE <- gsub("CALC\\|", "", nav.data$DATE)

nav.data$DATE <- gsub("T", "", nav.data$DATE)

nav.data$DATE <- gsub("\\|", "", nav.data$DATE)

nav.data$DATE <- nav.data$DATE[,2]


#subset based on GPGLL substring
nav.data.sub <- nav.data[grep(paste("GPGLL", collapse = "|"), nav.data$GSCA_ID),]

#select columns worth retaining
nav.data.sub <- select(nav.data.sub,
                   GSCA_ID,
                   #UNKNOWN,
                   #TIME_LAT,
                   LON,
                   LAT,
                   EASTING,
                   NORTHING,
                   HEADING,
                   UTM_ZONE,
                   FILE_NAME,
                   TIME,
                   DATE)

# #create a unique ID to calculate positions within a day - DOESNT WORK YET
# nav.data.sub$UNIQUE_ID <- paste(nav.data.sub$DATE, nav.data.sub$LON, nav.data.sub$LAT, sep = "_")
# 
# #str(nav.data.sub)
# 
# pos_id <- unique(nav.data.sub$UNIQUE_ID)
# 
# #subset out based on unique_id
# nav.data.sub <- nav.data.sub[nav.data.sub$UNIQUE_ID %in% pos_id,]
# 
# length(unique(nav.data.sub$LAT))


#write out CSV
write.csv(nav.data.sub, "NAV_DATA_2024004_NAV-20241008T124531Z-002.csv", row.names = F)

end.time <- Sys.time()


#run processing time
end.time - start.time 

