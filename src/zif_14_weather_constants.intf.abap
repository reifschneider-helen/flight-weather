INTERFACE zif_14_weather_constants
  PUBLIC .
  CONSTANTS:
    BEGIN OF c_weather_text,
        clear TYPE string VALUE 'Clear / Sunny',
        cloudy TYPE string VALUE 'Partly Cloudy',
        overcast TYPE string VALUE 'Overcast',
        foggy TYPE string VALUE 'Foggy',
        rain TYPE string VALUE 'Rain / Drizzle',
        snow TYPE string VALUE 'Snowfall',
        showers TYPE string VALUE 'Rain Showers',
        thunderstorm TYPE string VALUE 'Thunderstorm',
    END of c_weather_text.

ENDINTERFACE.
