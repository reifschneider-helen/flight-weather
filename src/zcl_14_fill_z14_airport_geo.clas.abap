CLASS zcl_14_fill_z14_airport_geo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_14_fill_z14_airport_geo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA:
        lt_geo_data TYPE TABLE OF z14_airports_geo.

    lt_geo_data = VALUE #(
      ( airport_id = 'FRA' latitude = '50.0379'   longitude = '8.5622' )
      ( airport_id = 'MUC' latitude = '48.3537'   longitude = '11.7860' )
      ( airport_id = 'BER' latitude = '52.3667'   longitude = '13.5033' )
      ( airport_id = 'JFK' latitude = '40.6413'   longitude = '-73.7781' )
      ( airport_id = 'SFO' latitude = '37.6213'   longitude = '-122.3790' )
      ( airport_id = 'LHR' latitude = '51.4700'   longitude = '-0.4543' )
      ( airport_id = 'CDG' latitude = '49.0097'   longitude = '2.5479' )
      ( airport_id = 'NRT' latitude = '35.7720'   longitude = '140.3929' )
      ( airport_id = 'SYD' latitude = '-33.9399'  longitude = '151.1753' )
      ( airport_id = 'SIN' latitude = '1.3644'    longitude = '103.9915' )
     ).

    MODIFY z14_airports_geo
    FROM TABLE @lt_geo_data.

    IF sy-subrc <> 0.
      out->write( 'Error while modifying z14_airports_geo' ).
    ELSE.
      out->write( 'Table z14_airports_geo was filled successfully' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
