CLASS zcl_14_flight_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      tt_flights TYPE TABLE FOR READ RESULT z14_i_flightwithgeo,
      tt_updates TYPE TABLE FOR UPDATE z14_i_flightwithgeo.

    METHODS:
      get_master_data_updates
        IMPORTING it_flights        TYPE tt_flights
        RETURNING VALUE(rt_updates) TYPE tt_updates,

      get_weather_updates
        IMPORTING it_flights         TYPE tt_flights
                  io_weather_service TYPE REF TO zif_14_weather_service OPTIONAL
        RETURNING VALUE(rt_updates)  TYPE tt_updates.

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

      BEGIN OF ty_weather_data,
        departure_status      TYPE z14_weather_status,
        departure_temperature TYPE z14_temperature,
        arrival_status        TYPE z14_weather_status,
        arrival_temperature   TYPE z14_temperature,
      END OF ty_weather_data,

      tt_connections_geo TYPE HASHED TABLE OF ty_connections_geo WITH UNIQUE KEY carrier_id connection_id,

      tt_currencies      TYPE HASHED TABLE OF /dmo/i_carrier WITH UNIQUE KEY AirlineID.

    METHODS:
      build_update_structure
        IMPORTING it_flights        TYPE tt_flights
                  it_currencies     TYPE tt_currencies
                  it_connections    TYPE tt_connections_geo
        RETURNING VALUE(rt_updates) TYPE tt_updates,

      fetch_flight_weather
        IMPORTING is_flight         TYPE z14_i_flightwithgeo
                  io_weather_svc    TYPE REF TO zif_14_weather_service
        RETURNING VALUE(rs_weather) TYPE ty_weather_data,

      fetch_connections
        IMPORTING it_flights            TYPE tt_flights
        RETURNING VALUE(rt_connections) TYPE tt_connections_geo,

      fetch_currencies
        IMPORTING it_flights           TYPE tt_flights
        RETURNING VALUE(rt_currencies) TYPE tt_currencies.

ENDCLASS.


CLASS zcl_14_flight_service IMPLEMENTATION.
  METHOD get_master_data_updates.
    IF it_flights IS INITIAL. RETURN. ENDIF.

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

    DATA(lo_weather_svc) = COND #( WHEN io_weather_service IS BOUND
                                   THEN io_weather_service
                                   ELSE NEW zcl_14_weather_service(  ) ).

    LOOP AT it_flights ASSIGNING FIELD-SYMBOL(<ls_flight>).
      IF <ls_flight>-DepartureLatitude IS INITIAL OR <ls_flight>-ArrivalLatitude
       OR <ls_flight>-FlightDate IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(ls_weather) = fetch_flight_weather( is_flight = CORRESPONDING #( <ls_flight> )
                                               io_weather_svc = lo_weather_svc ).

      APPEND VALUE #( %tky = <ls_flight>-%tky
                       DepartureWeatherStatus = ls_weather-departure_status
                       DepartureTemperature = ls_weather-departure_temperature
                       ArrivalWeatherStatus =  ls_weather-arrival_status
                       ArrivalTemperature = ls_weather-arrival_temperature
                      ) TO rt_updates.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_update_structure.
    LOOP AT it_flights ASSIGNING FIELD-SYMBOL(<ls_flight>).
      DATA(ls_connection) = VALUE #( it_connections[ carrier_id    = <ls_flight>-CarrierId
                                                     connection_id = <ls_flight>-ConnectionId ] OPTIONAL ).

      DATA(ls_currency)   = VALUE #( it_currencies[ AirlineId = <ls_flight>-CarrierId ] OPTIONAL ).

      APPEND VALUE #(
        %tky               = <ls_flight>-%tky
        CurrencyCode       = ls_currency-CurrencyCode
        AirportFromId      = ls_connection-airport_from_id
        AirportToId        = ls_connection-airport_to_id
        DepartureLatitude  = ls_connection-departure_latitude
        DepartureLongitude = ls_connection-departure_longitude
        ArrivalLatitude    = ls_connection-arrival_latitude
        ArrivalLongitude   = ls_connection-arrival_longitude
      ) TO rt_updates.

    ENDLOOP.
  ENDMETHOD.

  METHOD fetch_flight_weather.
    TRY.
        DATA(ls_departure_weather) = io_weather_svc->get_weather(
                                      iv_latitude = is_flight-DepartureLatitude
                                      iv_longitude = is_flight-DepartureLongitude
                                      iv_date = is_flight-FlightDate ).

        DATA(ls_arrival_weather) = io_weather_svc->get_weather(
                                         iv_latitude = is_flight-ArrivalLatitude
                                         iv_longitude = is_flight-ArrivalLongitude
                                         iv_date = is_flight-FlightDate ).

        rs_weather = VALUE #( departure_status = ls_departure_weather-Status
                              departure_temperature = ls_departure_weather-Temperature
                              arrival_status = ls_arrival_weather-Status
                              arrival_temperature = ls_arrival_weather-Temperature  ).
      CATCH cx_static_check.
        rs_weather = VALUE #( departure_status = 'N/A'
                             arrival_status = 'N/A' ).
    ENDTRY.
  ENDMETHOD.

  METHOD fetch_connections.
    IF it_flights IS INITIAL. RETURN. ENDIF.

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
    IF it_flights IS INITIAL. RETURN. ENDIF.

    SELECT
    FROM /dmo/i_carrier
    FIELDS AirlineId,
           CurrencyCode
    FOR ALL ENTRIES IN @it_flights
    WHERE AirlineId = @it_flights-CarrierId
    INTO CORRESPONDING FIELDS OF TABLE @rt_currencies.
  ENDMETHOD.


ENDCLASS.
