INTERFACE zif_14_weather_service
  PUBLIC .

  TYPES:
    BEGIN OF ty_weather_data,
      status      TYPE z14_weather_status,
      temperature TYPE z14_temperature,
    END OF ty_weather_data.

  METHODS:
    get_weather
      IMPORTING iv_latitude          TYPE z14_latitude
                iv_longitude         TYPE z14_longitude
                iv_date              TYPE /dmo/flight_date
      RETURNING VALUE(rs_weather) TYPE ty_weather_data
      RAISING   cx_static_check.

ENDINTERFACE.
