CLASS lhc_FlightWithGeo DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    INTERFACES:
      zif_14_weather_constants.

    ALIASES:
        c_weather_text FOR zif_14_weather_constants~c_weather_text.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR FlightWithGeo RESULT result.

    METHODS setFlightMasterData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setFlightMasterData.

    METHODS setWeatherData FOR DETERMINE ON MODIFY
       keys FOR FlightWithGeo~setWeatherData.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR FlightWithGeo RESULT result.

ENDCLASS.

CLASS lhc_FlightWithGeo IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setFlightMasterData.
    READ ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY FlightWithGeo
    FIELDS ( CarrierId ConnectionId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_flights).

    IF lt_flights IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_flight_service) = NEW zcl_14_flight_service( ) .
    DATA(lt_updates) = lo_flight_service->get_master_data_updates(
                                            CORRESPONDING #( lt_flights ) ).

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

    DATA(lo_flight_service) = NEW zcl_14_flight_service(  ).
    DATA(lt_updates) = lo_flight_service->get_weather_updates( lt_flights ).

    MODIFY ENTITIES OF z14_i_flightwithgeo IN LOCAL MODE
    ENTITY flightWithGeo
    UPDATE FIELDS ( DepartureWeatherStatus DepartureTemperature
                    ArrivalWeatherStatus ArrivalTemperature )
    WITH lt_updates.

  ENDMETHOD.

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

*  IF WEATHER IS BAD, USER CAN CHOOSE ANOTHER FLIGHT DATE
    result = VALUE #( FOR ls_weather IN lt_weather
                      ( %tky = ls_weather-%tky

*                      Always depends on carrier
                        %field-CurrencyCode = if_abap_behv=>fc-f-read_only

                        %field-FlightDate = COND #(
                            WHEN ls_weather-ArrivalWeatherStatus = c_weather_text-thunderstorm
                             OR ls_weather-ArrivalWeatherStatus = c_weather_text-rain
                              THEN if_abap_behv=>fc-f-unrestricted
                              ELSE if_abap_behv=>fc-f-read_only )
                      ) ).
  ENDMETHOD.

ENDCLASS.
