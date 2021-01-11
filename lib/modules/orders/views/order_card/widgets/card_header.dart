part of '../orders_card.dart';

class _CardHeader extends StatelessWidget {
  final PlaceOrderResponse orderResponse;
  const _CardHeader(this.orderResponse, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${tr('screen_order.order_no')} #${orderResponse.orderShortNumber}",
                style: CustomTheme.of(context).textStyles.sectionHeading2,
              ),
              const SizedBox(height: 8),
              Text(
                "${orderResponse.createdTime}\t\t\t\t${orderResponse.createdDate}",
                style: CustomTheme.of(context).textStyles.body1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              orderResponse.businessName,
              style: CustomTheme.of(context).textStyles.body1,
            ),
            const SizedBox(height: 8),
            Text(
              orderResponse.totalCountString,
              style: CustomTheme.of(context).textStyles.body1,
            ),
          ],
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => showModalBottomSheet(
            context: context,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            builder: (context) => ContactOptionsWidget(
              name: orderResponse.businessName,
              phoneNumber: orderResponse.businessContactNumber,
            ),
          ),
          child: Icon(
            Icons.call_outlined,
            color: CustomTheme.of(context).colors.primaryColor,
          ),
        ),
      ],
    );
  }
}
