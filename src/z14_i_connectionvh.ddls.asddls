@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Connections'
@Metadata.ignorePropagatedAnnotations: true

define view entity Z14_I_ConnectionVH
 as select from /dmo/connection
{
    key carrier_id as CarrierId,
    key connection_id as ConnectionId,
    airport_from_id as AirportFromId,
    airport_to_id as AirportToId
}
