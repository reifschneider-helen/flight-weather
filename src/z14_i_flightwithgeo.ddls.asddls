@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view - flights with geo data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z14_I_FlightWithGeo
  as select from z14_flights     as Flights
    inner join   /dmo/connection as _Connection
        on  Flights.carrier_id    = _Connection.carrier_id
        and Flights.connection_id = _Connection.connection_id

  association [0..1] to z14_airports_geo as _DepartureGeo
    on _Connection.airport_from_id = _DepartureGeo.airport_id

  association [0..1] to z14_airports_geo as _ArrivalGeo
    on _Connection.airport_to_id = _ArrivalGeo.airport_id
{
  key Flights.carrier_id            as CarrierId,
  key Flights.connection_id         as ConnectionId,
  key Flights.flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Flights.price                 as Price,
      Flights.currency_code         as CurrencyCode,
      Flights.plane_type_id         as PlaneTypeId,
      Flights.seats_max             as SeatsMax,
      Flights.seats_occupied        as SeatsOccupied,

      _Connection.airport_from_id   as AirportFromId,
      _Connection.airport_to_id     as AirportToId,

      _DepartureGeo.latitude        as DepartureLatitude,
      _DepartureGeo.longitude       as DepartureLongitude,

      _ArrivalGeo.latitude          as ArrivalLatitude,
      _ArrivalGeo.longitude         as ArrivalLongitude,
      
      cast( '' as abap.char(40) )   as DepartureWeatherStatus,
      cast( 0.0 as abap.dec(4,2) )  as DepartureTemperature,
      
      cast( '' as abap.char(40) )   as ArrivalWeatherStatus,
      cast( 0.0 as abap.dec(4,2) )  as ArrivalTemperature,

      Flights.local_created_by      as LocalCreatedBy,
      Flights.local_created_at      as LocalCreatedAt,
      Flights.local_last_changed_by as LocalLastChangedBy,
      Flights.local_last_changed_at as LocalLastChangedAt,
      Flights.last_changed_at       as LastChangedAt,


      _DepartureGeo,
      _ArrivalGeo
}
