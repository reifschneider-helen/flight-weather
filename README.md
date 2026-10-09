# SAP RAP Flight & Weather Integration App

A custom SAP ABAP RESTful Application Programming Model (RAP) application built on ABAP Cloud that integrates live weather data from the Open-Meteo API into flight records and presents them via an SAP Fiori Elements UI.

## Features

- **Flight Data Management**: Track flight details including Carrier ID, Connection ID, Flight Date, and Price.
- **Geographical Data Integration**: Automatically retrieves and displays departure and arrival coordinates (Latitude & Longitude) joined from database tables.
- **Live Weather Integration**: Automatically fetches real-time weather forecasts (temperature and conditions) for both departure and arrival locations using the external [Open-Meteo API](https://open-meteo.com/).
- **Dynamic Date & Weather Updates**: Flexibly adjust the flight date directly within the app to re-fetch live weather forecasts, allowing users to reschedule if poor weather conditions are retrieved.
- **WMO Weather Code Mapping**: Translates numerical WMO weather interpretation codes into clear, human-readable text (e.g., Clear / Sunny, Rain / Drizzle, Overcast, Thunderstorm).
- **Structured SAP Fiori UI**: Cleanly organized object page layout using Metadata Extensions, featuring dedicated sections (Facets and Field Groups) for General Information, Geodata, and Weather Information.

## Architecture & Components

- **Data Model**: Core Data Services (CDS) views and Metadata Extensions (`Z14_I_FlightWithGeo`, `Z14_C_FlightWithGeo`) utilizing rich UI annotations (`@UI.facet`, `@UI.fieldGroup`, `@UI.lineItem`, `@EndUserText.label`).
- **Value Help Annotations**: Uses `@Consumption.valueHelpDefinition` configured with `#FILTER_AND_RESULT` to automatically pre-filter valid Connection IDs based on the entered Carrier ID.
- **Business Logic**: RAP behavior implementation featuring a determination (`setWeatherData`) to dynamically query and update weather fields whenever flight details or dates change.
- **External Service Integration**: Uses ABAP HTTP destination and client providers (`cl_http_destination_provider`, `cl_web_http_client_manager`) combined with `/ui2/cl_json` for robust JSON parsing and deserialization.

## Technical Highlights

- **API Communication**: Performs HTTP GET requests to Open-Meteo using dynamic geographical coordinates and ISO-formatted dates (`YYYY-MM-DD`).
- **Resilience & Error Handling**: Gracefully catches API or network exceptions within local service classes, assigning fallback status texts to ensure a smooth user experience without interrupting transaction execution.
- **UX & Data Integrity Safeguards**: Restricts editing on sensitive auto-populated fields (such as coordinates and weather details) while allowing core attributes like Flight Date and Flight Price to be modified.

---

## Screenshots & Application Flow

### 1. Main List Report Page
Displays the primary list of flight records with high-level overview details and quick action buttons.
<img width="2516" height="1064" alt="Main page with flight records" src="https://github.com/user-attachments/assets/5111f88e-e86d-48c2-93e2-e00565564540" />

---

### 2. Record Creation Window
Prompting mandatory fields required prior to object page initialization.
<img width="2482" height="1234" alt="Creation window filling mandatory fields" src="https://github.com/user-attachments/assets/51bf7eb1-ec13-4a7b-9de5-a4b6e3f4ccd4" />

---

### 3. Smart Value Help (Carrier & Connection Filtering)
Utilizes `@Consumption.valueHelpDefinition` with `#FILTER_AND_RESULT` usage to dynamically filter available Connection IDs based on the selected Carrier ID.
<img width="2486" height="1240" alt="Value help prefiltering connections by carrier ID" src="https://github.com/user-attachments/assets/b7a4eaf8-5d95-4cb8-9928-55ae03b7a3b7" />


---

### 4. Flight Detail Object Page
Displays editable and read-only fields. To ensure UI security and data integrity, key calculated fields remain read-only. Currency auto-adjusts based on the carrier, and users can adjust the **Flight Date** to automatically fetch updated weather data if bad weather is forecast.
<img width="2520" height="1142" alt="Flight detail object page with date modification logic" src="https://github.com/user-attachments/assets/7f208ec6-e0c9-415d-b0b5-8dc44195f67b" />

---

### 5. Geodata & Weather Information Facets
Displays joined database geodata alongside the real-time departure and arrival weather forecasts fetched dynamically from Open-Meteo.
<img width="2492" height="802" alt="Geodata and Open-Meteo weather integration display" src="https://github.com/user-attachments/assets/46c140b3-fb2c-47d2-aae9-c0c718d47216" />
