CLASS lhc_FlightWithGeo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    METHODS setAirportData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setAirportData.

    METHODS setWeatherData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setWeatherData.

ENDCLASS.

CLASS lhc_FlightWithGeo IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setAirportData.
    "if CarrierId ConnectionId not intital
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( CarrierId ConnectionId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_flights).

    SELECT
    FROM /dmo/connection AS Connection
         LEFT OUTER JOIN z14_airports_geo AS Departure
            ON Connection~airport_from_id = Departure~airport_id
         LEFT OUTER JOIN z14_airports_geo AS Arrival
            ON Connection~airport_to_id = Arrival~airport_id
    FIELDS Connection~carrier_id,
           Connection~connection_id,
           Connection~airport_from_id,
           Connection~airport_to_id,

           Departure~latitude AS departure_latitude,
           Departure~longitude AS departure_longitude,

           Arrival~latitude AS arrival_latitude,
           Arrival~longitude AS arrival_longitude
    FOR ALL ENTRIES IN @lt_flights
    WHERE carrier_id = @lt_flights-CarrierId
          AND connection_id = @lt_flights-ConnectionId
    INTO TABLE @DATA(lt_connections).

    MODIFY ENTITIES OF Z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    UPDATE FIELDS ( AirportFromId
                    AirportToId
                    DepartureLatitude
                    DepartureLongitude
                    ArrivalLatitude
                    ArrivalLongitude
                     )
    WITH VALUE #( FOR ls_flight IN lt_flights (
                    %tky = ls_flight-%tky
                    AirportFromId = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-airport_from_id )
                    AirportToId = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-airport_to_id )
                    DepartureLatitude = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-departure_latitude OPTIONAL )
                    DepartureLongitude = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-departure_longitude OPTIONAL )
                    ArrivalLatitude = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-arrival_latitude OPTIONAL )
                    ArrivalLongitude = VALUE #(
                        lt_connections[ carrier_id = ls_flight-CarrierId
                                        connection_id = ls_flight-ConnectionId ]-arrival_longitude OPTIONAL )
                    ) ).



  ENDMETHOD.

  METHOD setWeatherData.
*  IF DepartureLatitude, DepartureLongitude,
*    ArrivalLatitude, ArrivalLongitude, FlightDate not initial
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( DepartureLatitude DepartureLongitude
            ArrivalLatitude ArrivalLongitude FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_flights).

    DATA(lo_weather_svc) = CAST zif_14_weather_service( NEW zcl_14_weather_service( ) ).

    LOOP AT lt_flights ASSIGNING FIELD-SYMBOL(<ls_flight>).
      TRY.
*          TEST CASE for LH 0400 to prevent often API calls
           IF <ls_flight>-CarrierId = 'LH'
              AND <ls_flight>-ConnectionId = '0400'.

            MODIFY ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
            ENTITY flightWithGeo
            UPDATE FIELDS ( DepartureWeatherStatus DepartureTemperature
                            ArrivalWeatherStatus ArrivalTemperature )

            WITH VALUE #( (  %tky =  <ls_flight>-%tky
                             DepartureWeatherStatus =  'Rain / Drizzle (test)'
                             DepartureTemperature = '26.0'
                             ArrivalWeatherStatus =  'Thunderstorm'
                             ArrivalTemperature = '-40' ) ).
          ELSE.


            DATA(ls_departure_weather) = lo_weather_svc->get_weather(
                                            iv_latitude = <ls_flight>-DepartureLatitude
                                            iv_longitude = <ls_flight>-DepartureLongitude
                                            iv_date = <ls_flight>-FlightDate
                                            ).

            DATA(ls_arrival_weather) = lo_weather_svc->get_weather(
                                             iv_latitude = <ls_flight>-ArrivalLatitude
                                             iv_longitude = <ls_flight>-ArrivalLongitude
                                             iv_date = <ls_flight>-FlightDate
                                             ).

            MODIFY ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
            ENTITY flightWithGeo
            UPDATE FIELDS ( DepartureWeatherStatus DepartureTemperature
                            ArrivalWeatherStatus ArrivalTemperature )

            WITH VALUE #( (  %tky =  <ls_flight>-%tky
                             DepartureWeatherStatus =  ls_departure_weather-status
                             DepartureTemperature = ls_departure_weather-temperature
                             ArrivalWeatherStatus =  ls_arrival_weather-status
                             ArrivalTemperature = ls_arrival_weather-temperature ) ).
          ENDIF.
        CATCH cx_static_check.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
