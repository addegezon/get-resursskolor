###
# Program för att hämta alla skolor kodade som
# resursskolor från Skolverkets API

library(httr)
library(jsonlite)

# Hämta samtliga skolenhetskoder
url <- "https://api.skolverket.se/skolenhetsregistret/v1/skolenhet/"
headers <- c("accept" = "application/json")
response <- GET(url, headers = headers)
data <- content(response, "parsed")
skolenhetskoder <- unlist(lapply(data$Skolenheter, function(lst) lst[[1]]))

# Skapa en data frame för att hålla information om skolor
dframe <- data.frame()

# Loopa över all skolenhetskoder och hämta data
for (skolenhetskod in skolenhetskoder) {

    # Definiera API-url
    url_skolenhet <- paste0(
        "https://api.skolverket.se/skolenhetsregistret/v1/skolenhet/", 
        skolenhetskod
    )

  # Definiera headers
  headers_skolenhet <- c("accept" = "application/json")

  # Hämta datan
  response_skolenhet <- GET(url_skolenhet, headers = headers_skolenhet)
  data_skolenhet <- content(response_skolenhet, "parsed")

  # Extrahera skolenhetskod och resursskole-status
  filtered_list <- lapply(data_skolenhet$SkolenhetInfo$Skolformer, function(entry) {
    if (entry$type == "Grundskola") {
      return(entry)
    } else {
      return(NULL)
    }
  })
  filtered_list <- filtered_list[!sapply(filtered_list, is.null)]

  if(length(filtered_list) == 0) next

  skolenhetskod_value <- data_skolenhet$SkolenhetInfo$Skolenhetskod
  skolenhetsnamn_value <- data_skolenhet$SkolenhetInfo$Namn
  resursskola_value <- filtered_list[[1]]$Resursskola


  # Lägg till en ny rad i data frame om skolan är en resursskola
    new_row <- data.frame(
        skolenhetskod = skolenhetskod_value,
        namn = skolenhetsnamn_value,
        resursskola = resursskola_value
    )
    dframe <- rbind(dframe, new_row)
  
}

# Spara datan som en .csv-fil
write.csv(dframe, "resursskolor.csv", row.names=FALSE)







filtered_list <- lapply(data_skolenhet$SkolenhetInfo$Skolformer, function(entry) {
  if (entry$type == "Grundskola") {
    return(entry)
  } else {
    return(NULL)
  }
})
filtered_list <- filtered_list[!sapply(filtered_list, is.null)]
