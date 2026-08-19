@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view - flights with geo data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z14_C_FLIGHTWITHGEO
  provider contract transactional_query
  as projection on Z14_I_FlightWithGeo
{
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'Z14_I_CarrierVH', element: 'AirlineID' }
      }]
  key CarrierId,
      @Consumption.valueHelpDefinition: [{
          entity: { name: 'Z14_I_ConnectionVH', element: 'ConnectionId' },
          additionalBinding: [{
            localElement: 'CarrierId', element: 'CarrierId', usage: #FILTER_AND_RESULT
          },
          { localElement: 'AirportFromId', element: 'AirportFromId', usage: #RESULT },
          { localElement: 'AirportToId', element: 'AirportToId', usage: #RESULT }
          ]
      }]

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
      
      DepartureWeatherStatus,
      DepartureTemperature,
      
      ArrivalWeatherStatus,
      ArrivalTemperature,

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
