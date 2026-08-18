@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view - flights with geo data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z14_C_FLIGHTWITHGEO
  provider contract transactional_query
  as projection on Z14_I_FlightWithGeo
{
  key CarrierId,
  key ConnectionId,
  key FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      PlaneTypeId,
      SeatsMax,
      SeatsOccupied,
      
      AirportFromId,
      AirportToId,

      DepartureLatitude,
      DepartureLongitude,
      ArrivalLatitude,
      ArrivalLongitude,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
