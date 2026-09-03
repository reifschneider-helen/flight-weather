CLASS lhc_FlightWithGeo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    INTERFACES:
      zif_14_weather_constants.

    ALIASES:
        c_weather_text FOR zif_14_weather_constants~c_weather_text.

  PRIVATE SECTION.
    " --- 1. Authorization Methods ---
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    " --- 2. Dynamic Feature Control ---
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR FlightWithGeo RESULT result.

    " --- 3. Determinations (Business Logic On Change) ---
    METHODS setFlightMasterData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setFlightMasterData.

    METHODS setWeatherData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setWeatherData.

ENDCLASS.

CLASS lhc_FlightWithGeo IMPLEMENTATION.
  " ====================================================================
  " 1. AUTHORIZATION METHODS
  " ====================================================================
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  " ====================================================================
  " 2. FEATURE CONTROL METHODS
  " ====================================================================
  METHOD get_instance_features.
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( DepartureWeatherStatus
             DepartureTemperature
             ArrivalWeatherStatus
             ArrivalTemperature
             FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_weather).

    "IF WEATHER IS BAD, USER CAN CHOOSE ANOTHER FLIGHT DATE
    result = VALUE #( FOR ls_weather IN lt_weather
                      ( %tky = ls_weather-%tky

                        "CurrencyCode always depends on carrier
                        %field-CurrencyCode = if_abap_behv=>fc-f-read_only

                        %field-FlightDate = COND #(
                            WHEN ls_weather-ArrivalWeatherStatus = c_weather_text-thunderstorm
                             OR ls_weather-ArrivalWeatherStatus = c_weather_text-rain
                              THEN if_abap_behv=>fc-f-unrestricted
                              ELSE if_abap_behv=>fc-f-read_only )
                      ) ).
  ENDMETHOD.

  " ====================================================================
  " 3. DETERMINATION METHODS
  " ====================================================================
  METHOD setFlightMasterData.
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( CarrierId ConnectionId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_flights).

    DELETE lt_flights
    WHERE CarrierId IS INITIAL OR ConnectionId IS INITIAL OR FlightDate IS INITIAL.

    IF lt_flights IS INITIAL. RETURN. ENDIF.

    TRY.
        DATA(lt_updates) = NEW zcl_14_flight_service( )->get_master_data_updates(
                                                CORRESPONDING #( lt_flights ) ).
      CATCH zcx_14_flight_weather_errors INTO DATA(lx_error).
        reported-FlightWithGeo = VALUE #( FOR ls_key IN keys (
                             %tky = ls_key-%tky
                             %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = CONV #( lx_error->get_text( ) )
                                 )
                              ) ).
        RETURN.
    ENDTRY.

    IF lt_updates IS INITIAL. RETURN. ENDIF.

    MODIFY ENTITIES OF Z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    UPDATE FIELDS ( CurrencyCode
                    AirportFromId
                    AirportToId
                    DepartureLatitude
                    DepartureLongitude
                    ArrivalLatitude
                    ArrivalLongitude )
    WITH lt_updates.

  ENDMETHOD.

  METHOD setWeatherData.
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( CarrierId ConnectionId
            DepartureLatitude DepartureLongitude
            ArrivalLatitude ArrivalLongitude FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_flights).

    IF lt_flights IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(lt_updates) = NEW zcl_14_flight_service( )->get_weather_updates( lt_flights ).

      CATCH zcx_14_flight_weather_errors INTO DATA(lx_error).
        reported-FlightWithGeo = VALUE #( FOR ls_key IN keys (
                             %tky = ls_key-%tky
                             %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = CONV #( lx_error->get_text( ) )
                                 )
                              ) ).
        RETURN.
    ENDTRY.

    MODIFY ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY flightWithGeo
    UPDATE FIELDS ( DepartureWeatherStatus DepartureTemperature
                    ArrivalWeatherStatus ArrivalTemperature )
    WITH lt_updates.

  ENDMETHOD.

ENDCLASS.
