# SensorHub

**Description**  
This is the code for my weather app that I will make using the book {Build a Weather Station with Elixir and Nerves}(https://pragprog.com/titles/passweather/build-a-weather-station-with-elixir-and-nerves/).  
  
This will use Nerves and Elixir you will also need to buy a {Rasberry Pi}(https://www.pishop.us/product/raspberry-pi-zero-2w-with-headers/?searchid=0&search_query=zero+w) and an {evironmental hat}(https://www.pishop.us/product/environment-sensor-hat-for-raspberry-pi-i2c-bus/?searchid=0&search_query=i2c+hat) that will keep scan the envrionment and upload the data to a database.  

**Workflow**  
```mermaid
erDiagram
Weather Station 1 {
}

Weather Station 2 {

}

Weather Station N {
}

Public Internet {
}

Phoenix REST API {
}

Time-series Database {
}

Grafana {
}

Weather Station 1 |O--O| Public Internet: ""
Weather Station 2 |O--O| Public Internet: ""
Weather Station N |O--O| Public Internet: ""
Public Internet }O--O{ Phoenix REST API: ""
Phoenix REST API ||--O{ Time-series Database: ""
Grafana ||--|| Time-series Database: ""
```