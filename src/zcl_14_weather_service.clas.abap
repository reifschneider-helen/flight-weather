CLASS zcl_14_weather_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      zif_14_weather_service,
      zif_14_weather_constants.

    ALIASES:
      c_weather_text FOR zif_14_weather_constants~c_weather_text.

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

    METHODS:
      fetch_api_weather
        IMPORTING iv_latitude       TYPE z14_latitude
                  iv_longitude      TYPE z14_longitude
                  iv_date           TYPE /dmo/flight_date
        RETURNING VALUE(rs_weather) TYPE zif_14_weather_service=>ty_weather_data
        RAISING   cx_static_check,

      execute_http_get
        IMPORTING iv_url       TYPE string
        RETURNING VALUE(rv_json) TYPE string
        RAISING   cx_static_check,

      map_wmo_code_to_text
        IMPORTING iv_code        TYPE i
        RETURNING VALUE(rv_text) TYPE string,

      get_mock_weather
        IMPORTING iv_latitude       TYPE z14_latitude
                  iv_longitude      TYPE z14_longitude
        RETURNING VALUE(rs_weather) TYPE zif_14_weather_service=>ty_weather_data.
ENDCLASS.


CLASS zcl_14_weather_service IMPLEMENTATION.
  METHOD zif_14_weather_service~get_weather.
    TRY.
*       get mock weather for the flight LH 400 to avoid frequently API calls
        rs_weather = get_mock_weather( iv_latitude = iv_latitude
                                       iv_longitude = iv_longitude ).
        IF rs_weather IS NOT INITIAL. RETURN. ENDIF.

        rs_weather = fetch_api_weather( iv_latitude = iv_latitude
                                        iv_longitude = iv_longitude
                                        iv_date = iv_date ).

      CATCH cx_root.
        rs_weather = VALUE #( status = 'API Error' ).
    ENDTRY.
  ENDMETHOD.

  METHOD fetch_api_weather.

    DATA(lv_date_ISO) = |{ iv_date DATE = ISO }|.

    DATA(lv_url) = |https://api.open-meteo.com/v1/forecast?latitude={ iv_latitude }| &
                   |&longitude={ iv_longitude }&daily=temperature_2m_max,weather_code| &
                   |&start_date={ lv_date_ISO }&end_date={ lv_date_ISO }&timezone=auto|.
    DATA(lv_json) = execute_http_get( lv_url ).

    DATA ls_api_response TYPE ty_open_meteo_response.

    /ui2/cl_json=>deserialize(
       EXPORTING  json        = lv_json
                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case
       CHANGING   data        = ls_api_response ).

    IF ls_api_response IS NOT INITIAL.
        rs_weather = VALUE #( temperature = ls_api_response-daily-temperature_2m_max[ 1 ]
                              status = map_wmo_code_to_text( ls_api_response-daily-weather_code[ 1 ] ) ).
    ELSE.
      rs_weather = VALUE #( status = 'No data in Open-Meteo' ).
    ENDIF.
  ENDMETHOD.

  METHOD execute_http_get.
    DATA(lo_destination) = cl_http_destination_provider=>create_by_url( iv_url ).
    DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
    DATA(lo_response) = lo_client->execute( if_web_http_client=>get ).
    rv_json = lo_response->get_text(  ).
    lo_client->close(  ).
  ENDMETHOD.

  METHOD map_wmo_code_to_text.
    rv_text = COND #(
        WHEN iv_code = 0                     THEN c_weather_text-clear
        WHEN iv_code BETWEEN 1 AND 2         THEN c_weather_text-cloudy
        WHEN iv_code = 3                     THEN c_weather_text-overcast
        WHEN iv_code = 45 OR iv_code = 48    THEN c_weather_text-foggy
        WHEN iv_code BETWEEN 51 AND 67       THEN c_weather_text-rain
        WHEN iv_code BETWEEN 71 AND 77       THEN c_weather_text-snow
        WHEN iv_code BETWEEN 80 AND 82       THEN c_weather_text-showers
        WHEN iv_code BETWEEN 95 AND 99       THEN c_weather_text-thunderstorm
        ELSE                                      |Code { iv_code }| ).
  ENDMETHOD.

  METHOD get_mock_weather.
    "Departure City: Frankfurt Airport (FRA)
    IF iv_latitude BETWEEN '50.0' AND '50.2'
     AND iv_longitude BETWEEN '8.5' AND '8.8'.

      rs_weather-status      = 'Rain / Drizzle (test)'.
      rs_weather-temperature = '26.0'.

      "Arrival City: New York JFK Airport (JFK)
    ELSEIF iv_latitude BETWEEN '40.5' AND '40.8'
     AND iv_longitude BETWEEN '-73.9' AND '-73.6'.

      rs_weather-status      = 'Thunderstorm (test)'.
      rs_weather-temperature = '-40.0'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
