CLASS z14_test_open_meteo_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z14_test_open_meteo_api IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TYPES:
      BEGIN OF ty_weathercode,
        weathercode TYPE i,
      END OF ty_weathercode,

      BEGIN OF ty_weather_data,
        latitude        TYPE p LENGTH 8 DECIMALS 6,
        longitude       TYPE p LENGTH 9 DECIMALS 6,
        current_weather TYPE ty_weathercode,
      END OF ty_weather_data.

    DATA:
      ls_weather_data TYPE ty_weather_data,

      lv_url          TYPE string.

    CONSTANTS:
      lc_latitude  TYPE string VALUE '50.1109',
      lc_longitude TYPE string VALUE '8.6821'.

    TRY.

        lv_url = |https://api.open-meteo.com/v1/forecast?latitude={ lc_latitude }&longitude={ lc_longitude }&current_weather=true|.

        DATA(lo_destination) = cl_http_destination_provider=>create_by_url( lv_url ).
        DATA(lo_client)      = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        DATA(lo_response)    = lo_client->execute( if_web_http_client=>get ).
        DATA(lv_json_result) = lo_response->get_text( ).

        out->write( '--- HTTP Status ---' ).
        out->write( lo_response->get_status( )-code ).
        out->write( '--- JSON Antwort der API ---' ).
        out->write( lv_json_result ).


       /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_json_result
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data        = ls_weather_data
        ).

        out->write( '' ).
        out->write( '--- JSON Antwort deserialized ---' ).
        out->write( ls_weather_data ).



        select
        from /DMO/AIRPORT
        fields *
        into table @data(lt_scarr).

        out->write( lt_scarr ).


      CATCH cx_root INTO DATA(lx_error).
        out->write( '--- Fehler bei der Verbindung ---' ).
        out->write( lx_error->get_text( ) ).


    ENDTRY.
  ENDMETHOD.
ENDCLASS.
