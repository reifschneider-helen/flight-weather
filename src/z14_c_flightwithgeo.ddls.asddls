@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view - flights with geo data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z14_C_FLIGHTWITHGEO
  provider contract transactional_query
  as projection on Z14_I_FlightWithGeo
{
  key UUID,
  
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'Z14_I_CarrierVH', element: 'AirlineID' }
      }]
      CarrierId,
      
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'Z14_I_ConnectionVH', element: 'ConnectionId' },
          additionalBinding: [
          { localElement: 'CarrierId', element: 'CarrierId', usage: #FILTER_AND_RESULT }
          ]
      }]
      ConnectionId,

      FlightDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,

      //    CONNECTION FIELDS
      AirportFromId,
      AirportToId,

      //    GEO DATA
      DepartureLatitude,
      DepartureLongitude,
      ArrivalLatitude,
      ArrivalLongitude,

      //    WEATHER
      DepartureWeatherStatus,
      DepartureTemperature,
      ArrivalWeatherStatus,
      ArrivalTemperature,

      //    Travel advice depending on weather
      TravelAdvisory,

      //    ADMIN FIELDS
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
