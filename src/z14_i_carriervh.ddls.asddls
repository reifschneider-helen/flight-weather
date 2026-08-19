@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Airlines'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z14_I_CarrierVH
  as select from /DMO/I_Carrier
{
  key AirlineID,
      Name
      //    CurrencyCode,

      /* Associations */
      //    _Currency
}
