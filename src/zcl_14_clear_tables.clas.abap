CLASS zcl_14_clear_tables DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_14_clear_tables IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DELETE
    FROM z14_flights_d.

    COMMIT WORK.

    DELETE
    FROM z14_flights.

    COMMIT WORK.

  ENDMETHOD.
ENDCLASS.
