CLASS zcl_14_weather_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_14_weather_service.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_daily,
        temperature_2m_max TYPE STANDARD TABLE OF decfloat16 WITH DEFAULT KEY,
        weather_code       TYPE STANDARD TABLE OF i WITH DEFAULT KEY,
      END OF ty_daily,

      BEGIN OF ty_open_meteo_response,
        daily TYPE ty_daily,
      END OF ty_open_meteo_response.

    METHODS map_wmo_code_to_text
      IMPORTING iv_code        TYPE i
      RETURNING VALUE(rv_text) TYPE string.
ENDCLASS.



CLASS zcl_14_weather_service IMPLEMENTATION.
  METHOD zif_14_weather_service~get_weather.
    TRY.
        DATA(lv_date_ISO) = |{ iv_date DATE = ISO }|.

        DATA(lv_url) = |https://api.open-meteo.com/v1/forecast?latitude={ iv_latitude }| &
                       |&longitude={ iv_longitude }&daily=temperature_2m_max,weather_code| &
                       |&start_date={ lv_date_ISO }&end_date={ lv_date_ISO }&timezone=auto|.

        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        DATA(lo_response) = lo_client->execute( if_web_http_client=>get ).
        DATA(lv_json_result) = lo_response->get_text(  ).

        lo_client->close(  ).

        DATA ls_api_response TYPE ty_open_meteo_response.

        /ui2/cl_json=>deserialize(
       EXPORTING
         json        = lv_json_result
         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
       CHANGING
         data        = ls_api_response
     ).

        IF ls_api_response IS NOT INITIAL.
          rs_weather-temperature = ls_api_response-daily-temperature_2m_max[ 1 ].

          DATA(lv_weather_code) = ls_api_response-daily-weather_code[ 1 ].
          rs_weather-status = map_wmo_code_to_text( lv_weather_code ).

        ELSE.
          rs_weather-temperature = '0.0'.
          rs_weather-status = 'No data in Open-Meteo'.
        ENDIF.


      CATCH cx_root INTO DATA(lx_error).
        "lx_error->get_text()
        rs_weather-temperature = '0.0'.
        rs_weather-status = 'API Error'.

    ENDTRY.
  ENDMETHOD.



  METHOD map_wmo_code_to_text.
    rv_text = COND #(
        WHEN iv_code = 0                     THEN 'Clear / Sunny'
        WHEN iv_code BETWEEN 1 AND 2         THEN 'Partly Cloudy'
        WHEN iv_code = 3                     THEN 'Overcast'
        WHEN iv_code = 45 OR iv_code = 48    THEN 'Foggy'
        WHEN iv_code BETWEEN 51 AND 67       THEN 'Rain / Drizzle'
        WHEN iv_code BETWEEN 71 AND 77       THEN 'Snowfall'
        WHEN iv_code BETWEEN 80 AND 82       THEN 'Rain Showers'
        WHEN iv_code BETWEEN 95 AND 99       THEN 'Thunderstorm'
        ELSE                                      |Code { iv_code }| ).
  ENDMETHOD.

ENDCLASS.
