CLASS ltcl_flight_service DEFINITION FINAL FOR TESTING
DURATION SHORT
RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA:
        mo_cut TYPE REF TO zcl_14_flight_service.
    METHODS:
      setup,
      get_master_data_for_LH400 FOR TESTING,

      assert_master_data IMPORTING iv_carrier    TYPE /dmo/carrier_id
                                   iv_connection TYPE /dmo/connection_id
                                   iv_date       TYPE /dmo/flight_date
                                   iv_exp_curr   TYPE /dmo/currency_code
                                   iv_exp_from   TYPE /dmo/airport_from_id.
ENDCLASS.

CLASS ltcl_flight_service IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #(  ).
  ENDMETHOD.

  METHOD assert_master_data.
    DATA(lt_updates) = mo_cut->get_master_data_updates( VALUE #( ( CarrierId = iv_carrier
                                                                   ConnectionId = iv_connection
                                                                   FlightDate = iv_date ) ) ).

    ASSIGN lt_updates[ 1 ] TO FIELD-SYMBOL(<ls_update>).
    cl_abap_unit_assert=>assert_equals( act = <ls_update>-CurrencyCode
                                        exp = iv_exp_curr ).

    cl_abap_unit_assert=>assert_equals( act = <ls_update>-AirportFromId
                                        exp = iv_exp_from ).

  ENDMETHOD.

  METHOD get_master_data_for_lh400.
    assert_master_data( iv_carrier = 'LH' iv_connection = 400 iv_date = '20260827'
                        iv_exp_curr = 'EUR' iv_exp_from = 'FRA' ).
  ENDMETHOD.

ENDCLASS.
