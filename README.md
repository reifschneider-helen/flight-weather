# SAP RAP Flight & Weather Integration App

A custom SAP ABAP RESTful Application Programming Model (RAP) application built on ABAP Cloud that integrates live weather data from the Open-Meteo API into flight records and presents them via an SAP Fiori Elements UI.

## Features

* **Flight Data Management**: Track flight details including Carrier ID, Connection ID, Flight Date, and Price.
* **Geographical Data**: Stores and displays departure and arrival coordinates (Latitude & Longitude).
* **Live Weather Integration**: Automatically fetches real-time weather forecasts (temperature and conditions) for both departure and arrival locations using the external [Open-Meteo API](https://open-meteo.com/).
* **WMO Weather Code Mapping**: Translates numerical WMO weather interpretation codes into readable English text (e.g., Clear / Sunny, Rain / Drizzle, Overcast, Thunderstorm).
* **Structured SAP Fiori UI**: Cleanly organized object page layout using Metadata Extensions, featuring dedicated sections (Facets and Field Groups) for General Information, Geodata, and Weather Information.

## Architecture & Components

* **Data Model**: Core Data Services (CDS) views and Metadata Extensions (`Z14_I_FlightWithGeo`, `Z14_C_FlightWithGeo`) utilizing UI annotations (`@UI.facet`, `@UI.fieldGroup`, `@UI.lineItem`, `@EndUserText.label`).
* **Business Logic**: RAP behavior implementation featuring a determination (`setWeatherData`) to dynamically query and update weather fields.
* **External Service Integration**: Uses ABAP HTTP destination and client providers (`cl_http_destination_provider`, `cl_web_http_client_manager`) combined with `/ui2/cl_json` for robust JSON parsing and deserialization.

## Technical Highlights

* **API Communication**: Performs HTTP GET requests to Open-Meteo with dynamic parameters and ISO-formatted dates (`YYYY-MM-DD`).
* **Resilience & Error Handling**: Gracefully catches API or network exceptions within local service classes, assigning fallback status texts to ensure a smooth user experience without crashing transactions.
