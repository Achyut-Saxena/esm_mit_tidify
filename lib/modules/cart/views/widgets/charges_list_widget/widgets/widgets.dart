part of "../charges_list_widget.dart";

class _ChargesListTile extends StatelessWidget {
  final String chargeName;
  final double price;
  final TextStyle style;
  final VoidCallback onTap;

  const _ChargesListTile({
    @required this.chargeName,
    @required this.price,
    this.style,
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Text(
              chargeName,
              style: style ?? CustomTheme.of(context).textStyles.body1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          price.withRupeePrefix,
          style: (style ?? CustomTheme.of(context).textStyles.body1).copyWith(
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _DeliveryChargeInfoCard extends StatelessWidget {
  const _DeliveryChargeInfoCard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: SizeConfig.screenWidth / 2,
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          tr("cart.delivery_charge_info"),
          style: CustomTheme.of(context).textStyles.body2Faded,
        ),
      ),
    );
  }
}

class _MerchantChargesInfoCard extends StatelessWidget {
  final double packingCharge;
  final double serviceCharge;
  const _MerchantChargesInfoCard({
    @required this.packingCharge,
    @required this.serviceCharge,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      key: key,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: SizeConfig.screenWidth / 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("cart.merchant_charges"),
              style: CustomTheme.of(context).textStyles.body2,
            ),
            Divider(
              color: CustomTheme.of(context).colors.dividerColor,
              thickness: 1,
              height: 4,
            ),
            const SizedBox(height: 4),
            _ChargesListTile(
              chargeName: tr("cart.packing_charges"),
              price: packingCharge,
              style: CustomTheme.of(context).textStyles.body2Faded,
            ),
            const SizedBox(height: 4),
            _ChargesListTile(
              chargeName: tr("cart.service_charges"),
              price: serviceCharge,
              style: CustomTheme.of(context).textStyles.body2Faded,
            ),
          ],
        ),
      ),
    );
  }
}