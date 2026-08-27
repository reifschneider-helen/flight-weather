CLASS zcl_14_flight_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      tt_flights TYPE TABLE FOR READ RESULT z14_i_flightwithgeo,
      tt_updates TYPE TABLE FOR UPDATE z14_i_flightwithgeo.

    METHODS:
      get_master_data_updates IMPORTING it_flights        TYPE tt_flights
                              RETURNING VALUE(rt_updates) TYPE tt_updates,
      get_weather_updates IMPORTING it_flights        TYPE tt_flights
                          RETURNING VALUE(rt_updates) TYPE tt_updates,
      validate_dates.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_connections_geo,
        carrier_id          TYPE /dmo/carrier_id,
        connection_id       TYPE /dmo/connection_id,
        airport_from_id     TYPE /dmo/airport_from_id,
        airport_to_id       TYPE /dmo/airport_to_id,
        departure_latitude  TYPE z14_latitude,
        departure_longitude TYPE z14_longitude,
        arrival_latitude    TYPE z14_latitude,
        arrival_longitude   TYPE z14_latitude,
      END OF ty_connections_geo,

      tt_connections_geo TYPE HASHED TABLE OF ty_connections_geo WITH UNIQUE KEY carrier_id connection_id,

      tt_currencies      TYPE HASHED TABLE OF /dmo/i_carrier WITH UNIQUE KEY AirlineID.

    METHODS:
      fetch_connections IMPORTING it_flights            TYPE tt_flights
                        RETURNING VALUE(rt_connections) TYPE tt_connections_geo,
      fetch_currencies IMPORTING it_flights           TYPE tt_flights
                       RETURNING VALUE(rt_currencies) TYPE tt_currencies,
      fetch_weather_api_data,
      build_update_structure IMPORTING it_flights        TYPE tt_flights
                                       it_currencies     TYPE tt_currencies
                                       it_connections    TYPE tt_connections_geo
                             RETURNING VALUE(rt_updates) TYPE tt_updates.

ENDCLASS.



CLASS zcl_14_flight_service IMPLEMENTATION.
  METHOD get_master_data_updates.
    IF it_flights IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_flights) = it_flights.
    DATA(lt_currencies) = fetch_currencies( lt_flights ).
    DATA(lt_connections) = fetch_connections( lt_flights ).

    rt_updates = build_update_structure( it_flights = lt_flights
                                         it_currencies = lt_currencies
                                         it_connections = lt_connections ).
  ENDMETHOD.

  METHOD get_weather_updates.
    IF it_flights IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_weather_svc) = CAST zif_14_weather_service( NEW zcl_14_weather_service( ) ).

    LOOP AT it_flights ASSIGNING FIELD-SYMBOL(<ls_flight>).
      " Guard clause: Skip weather call if required inputs are missing
      IF <ls_flight>-DepartureLatitude IS INITIAL OR <ls_flight>-FlightDate IS INITIAL.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(ls_departure_weather) = lo_weather_svc->get_weather(
                                          iv_latitude = <ls_flight>-DepartureLatitude
                                          iv_longitude = <ls_flight>-DepartureLongitude
                                          iv_date = <ls_flight>-FlightDate ).

          DATA(ls_arrival_weather) = lo_weather_svc->get_weather(
                                           iv_latitude = <ls_flight>-ArrivalLatitude
                                           iv_longitude = <ls_flight>-ArrivalLongitude
                                           iv_date = <ls_flight>-FlightDate ).

          APPEND VALUE #( %tky = <ls_flight>-%tky
                           DepartureWeatherStatus = ls_departure_weather-Status
                           DepartureTemperature = ls_departure_weather-Temperature
                           ArrivalWeatherStatus =  ls_arrival_weather-Status
                           ArrivalTemperature = ls_arrival_weather-Temperature
                          ) TO rt_updates.

        CATCH cx_static_check.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_dates.

  ENDMETHOD.

  METHOD fetch_connections.
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

      FOR ALL ENTRIES IN @it_flights
      WHERE carrier_id = @it_flights-CarrierId
            AND connection_id = @it_flights-ConnectionId
      INTO TABLE @rt_connections.

  ENDMETHOD.

  METHOD fetch_currencies.
    SELECT
    FROM /dmo/i_carrier
    FIELDS AirlineId,
           CurrencyCode
    FOR ALL ENTRIES IN @it_flights
    WHERE AirlineId = @it_flights-CarrierId
    INTO CORRESPONDING FIELDS OF TABLE @rt_currencies.

  ENDMETHOD.

  METHOD fetch_weather_api_data.

  ENDMETHOD.

  METHOD build_update_structure.
    LOOP AT it_flights ASSIGNING FIELD-SYMBOL(<ls_flight>).
      READ TABLE it_connections ASSIGNING FIELD-SYMBOL(<ls_connection>)
      WITH TABLE KEY carrier_id = <ls_flight>-CarrierId
                     connection_id = <ls_flight>-ConnectionId.

      READ TABLE it_currencies ASSIGNING FIELD-SYMBOL(<ls_currency>)
      WITH TABLE KEY AirlineId = <ls_flight>-CarrierId.

      APPEND VALUE #(
      %tky = <ls_flight>-%tky
      CurrencyCode = COND #( WHEN sy-subrc = 0 THEN <ls_currency>-CurrencyCode )

      AirportFromId = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-airport_from_id )
      AirportToId = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-airport_to_id )

      DepartureLatitude = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-departure_latitude )
      DepartureLongitude = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-departure_longitude )
      ArrivalLatitude = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-arrival_latitude )
      ArrivalLongitude = COND #( WHEN sy-subrc = 0 THEN <ls_connection>-arrival_longitude )
      )
      TO rt_updates.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
