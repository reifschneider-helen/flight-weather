CLASS ltcl_flight_service DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
        mo_cut TYPE REF TO zcl_14_flight_service.
    METHODS:
      setup,
      teardown,
      get_master_data_success FOR TESTING,
      get_master_data_empty   FOR TESTING,
      get_master_data_error   FOR TESTING,

      assert_master_data
        IMPORTING it_flights  TYPE zcl_14_flight_service=>tt_flights
                  iv_exp_curr TYPE /dmo/currency_code
                  iv_exp_from TYPE /dmo/airport_from_id,

      assert_master_data_error
        IMPORTING it_flights TYPE zcl_14_flight_service=>tt_flights
                  iv_msg     TYPE string.
ENDCLASS.

CLASS ltcl_flight_service IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #(  ).
  ENDMETHOD.

  METHOD teardown.
    CLEAR mo_cut.
  ENDMETHOD.

  METHOD get_master_data_success.
    DATA(lt_flights) = VALUE zcl_14_flight_service=>tt_flights(
                      ( CarrierId = 'LH' ConnectionId = 400 FlightDate = '20260827' ) ).
    assert_master_data( it_flights = lt_flights
                        iv_exp_curr = 'EUR' iv_exp_from = 'FRA' ).

    lt_flights = VALUE zcl_14_flight_service=>tt_flights(
                       ( CarrierId = 'LH' ConnectionId = 401 FlightDate = '20260828' ) ).
    assert_master_data( it_flights = lt_flights
                        iv_exp_curr = 'EUR' iv_exp_from = 'JFK' ).
  ENDMETHOD.

  METHOD get_master_data_empty.
   DATA(lt_flights) = VALUE zcl_14_flight_service=>tt_flights(  ).

   assert_master_data_error( it_flights = lt_flights
                             iv_msg = 'Empty flight input must yield initial updates' ).

    lt_flights = VALUE zcl_14_flight_service=>tt_flights(
                        ( CarrierId = '' ConnectionId = 400 FlightDate = '20260827' ) ).
    assert_master_data_error( it_flights = lt_flights
                             iv_msg = 'Empty CarrierId must yield initial updates' ).

  ENDMETHOD.

  METHOD get_master_data_error.
   DATA(lt_flights) = VALUE zcl_14_flight_service=>tt_flights(
                        ( CarrierId = 'XZ' ConnectionId = 400 FlightDate = '20260827' ) ).

   assert_master_data_error( it_flights = lt_flights
                             iv_msg = 'Invalid CarrierId must yield initial updates' ).

  ENDMETHOD.


  METHOD assert_master_data.
    DATA(lt_updates) = mo_cut->get_master_data_updates( it_flights ).

    cl_abap_unit_assert=>assert_not_initial( act = lt_updates ).

    ASSIGN lt_updates[ 1 ] TO FIELD-SYMBOL(<ls_update>).
    cl_abap_unit_assert=>assert_equals( act = <ls_update>-CurrencyCode
                                        exp = iv_exp_curr ).

    cl_abap_unit_assert=>assert_equals( act = <ls_update>-AirportFromId
                                        exp = iv_exp_from ).

  ENDMETHOD.

  METHOD assert_master_data_error.
    DATA(lt_updates) = mo_cut->get_master_data_updates( it_flights ).

    cl_abap_unit_assert=>assert_initial( act = lt_updates
                                         msg = iv_msg ).
  ENDMETHOD.


ENDCLASS.
