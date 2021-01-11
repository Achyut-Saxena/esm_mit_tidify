part of 'order_summary_card.dart';

class _OrderSummaryAvailableItemsList extends StatelessWidget {
  final List<OrderItems> availableItemsList;
  final bool isOrderConfirmed;

  const _OrderSummaryAvailableItemsList({
    @required this.availableItemsList,
    @required this.isOrderConfirmed,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOrderConfirmed
              ? tr("screen_order.available_items")
              : tr("cart.catalogue_items"),
          style: isOrderConfirmed
              ? CustomTheme.of(context).textStyles.cardTitlePrimary
              : CustomTheme.of(context).textStyles.body1,
        ),
        const SizedBox(height: 20),
        _GenericItemsList(
          productsList: availableItemsList,
          showPrice: true,
          isFaded: false,
        ),
        Divider(
          color: CustomTheme.of(context).colors.dividerColor,
          thickness: 1,
          height: 5,
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}

class _GenericItemsList extends StatelessWidget {
  final List<OrderItems> productsList;
  final bool showPrice;
  final bool isFaded;
  const _GenericItemsList({
    @required this.productsList,
    @required this.showPrice,
    @required this.isFaded,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productsList.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final OrderItems _currentProduct = productsList[index];
        if (_currentProduct.quantity == 0) return SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentProduct.productName,
                      style:
                          CustomTheme.of(context).textStyles.cardTitle.copyWith(
                                color: isFaded
                                    ? CustomTheme.of(context)
                                        .colors
                                        .disabledAreaColor
                                    : CustomTheme.of(context).colors.textColor,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentProduct.variationOption?.size ?? "",
                      style: CustomTheme.of(context).textStyles.body2.copyWith(
                            color: isFaded
                                ? CustomTheme.of(context)
                                    .colors
                                    .disabledAreaColor
                                : CustomTheme.of(context).colors.textColor,
                          ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: !showPrice
                    ? CustomPaint(
                        foregroundPainter: DashedLinePainter(
                          color:
                              CustomTheme.of(context).colors.disabledAreaColor,
                        ),
                        child: Container(
                          width: 10,
                          height: 2,
                        ),
                      )
                    : Text(
                        _currentProduct.totalPriceOfItem.withRupeePrefix,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderSummaryNoAvailableItemsList extends StatelessWidget {
  final List<OrderItems> unavailableItemsList;

  _OrderSummaryNoAvailableItemsList({
    @required this.unavailableItemsList,
    Key key,
  }) : super(key: key);

  final GlobalKey notAvailableIconKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: CustomTheme.of(context).colors.dividerColor,
          thickness: 1,
          height: 20,
        ),
        Row(
          children: [
            Text(
              tr("screen_order.not_available"),
              style: CustomTheme.of(context).textStyles.cardTitle,
            ),
            const SizedBox(width: 14),
            InkWell(
              key: notAvailableIconKey,
              onTap: () {
                CustomPositionedDialog.show(
                  key: notAvailableIconKey,
                  content: NotAvailableInfoCard(),
                  context: context,
                  margin: Size(0, 0),
                );
              },
              child: Icon(
                Icons.error,
                size: 22,
                color: CustomTheme.of(context).colors.placeHolderColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _GenericItemsList(
            productsList: unavailableItemsList,
            showPrice: false,
            isFaded: true,
          ),
        ),
      ],
    );
  }
}

class NotAvailableInfoCard extends StatelessWidget {
  const NotAvailableInfoCard({Key key}) : super(key: key);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error,
              size: 22,
              color: CustomTheme.of(context).colors.placeHolderColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                tr("screen_order.not_available_message"),
                style: CustomTheme.of(context).textStyles.body2Faded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChargesList extends StatelessWidget {
  final PlaceOrderResponse orderDetails;
  ChargesList(this.orderDetails, {Key key}) : super(key: key);

  final GlobalKey deliveryChargeKey = new GlobalKey();
  final GlobalKey merchantChargeKey = new GlobalKey();

  double get deliveryCharge =>
      orderDetails.otherChargesDetail?.deliveryCharge?.amount ?? 0;

  double get merchantCharge => orderDetails.otherCharges / 100;

  double get itemTotal => orderDetails.itemTotal / 100;

  double get grandTotal => orderDetails.orderTotal / 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChargesListTile(
          chargeName: tr("cart.item_total"),
          price: itemTotal,
        ),
        const SizedBox(height: 2),
        Container(
          key: deliveryChargeKey,
          margin: const EdgeInsets.symmetric(vertical: 14),
          child: ChargesListTile(
            chargeName: tr("cart.delivery_partner_fee"),
            price: deliveryCharge,
            style: CustomTheme.of(context)
                .textStyles
                .body1FadedWithDottedUnderline,
            onTap: () => CustomPositionedDialog.show(
              key: deliveryChargeKey,
              content: DeliveryChargeInfoCard(),
              context: context,
              margin: Size(0, 45),
            ),
          ),
        ),
        Container(
          key: merchantChargeKey,
          child: ChargesListTile(
            chargeName: tr("cart.merchant_charges"),
            price: merchantCharge,
            style: CustomTheme.of(context)
                .textStyles
                .body1FadedWithDottedUnderline,
            onTap: () => CustomPositionedDialog.show(
              key: merchantChargeKey,
              context: context,
              content: MerchantChargesInfoCard(
                packingCharge:
                    orderDetails.otherChargesDetail.packingCharge?.amount ?? 0,
                serviceCharge:
                    orderDetails.otherChargesDetail.serviceCharge?.amount ?? 0,
                extraCharge:
                    orderDetails.otherChargesDetail.extraCharge?.amount ?? 0,
              ),
              margin: Size(0, 80),
            ),
          ),
        ),
        Divider(
          color: CustomTheme.of(context).colors.dividerColor,
          thickness: 1,
          height: 40,
        ),
        ChargesListTile(
          chargeName: tr("cart.grand_total"),
          price: grandTotal,
          style: CustomTheme.of(context).textStyles.sectionHeading2,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CustomerNoteImagesView extends StatelessWidget {
  final List<String> customerNoteImages;
  const CustomerNoteImagesView(this.customerNoteImages, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        CustomPaint(
          foregroundPainter: DashedLinePainter(
            color: CustomTheme.of(context).colors.disabledAreaColor,
          ),
          child: Container(
            width: double.infinity,
            height: 2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr("cart.list_items"),
          style: CustomTheme.of(context).textStyles.body1,
        ),
        const SizedBox(height: 20),
        CustomerNoteImageView(
          customerNoteImages: customerNoteImages,
          onRemove: null,
          showRemoveButton: false,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final bool showCancelButton;
  final Function(String) onCancel;
  final VoidCallback onReorder;
  const SecondaryActionButton({
    @required this.showCancelButton,
    @required this.onCancel,
    @required this.onReorder,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: CustomTheme.of(context).colors.dividerColor,
          thickness: 1,
          height: 20,
        ),
        showCancelButton
            ? ActionButton(
                text: tr("screen_order.cancel_order"),
                icon: Icons.clear,
                showBorder: false,
                textColor: CustomTheme.of(context).colors.secondaryColor,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CancelOrderPrompt(onCancel),
                  );
                },
              )
            : ActionButton(
                text: tr("screen_order.reorder"),
                icon: Icons.refresh,
                showBorder: false,
                textColor: CustomTheme.of(context).colors.textColor,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomConfirmationDialog(
                      title: tr("screen_order.repeat_order"),
                      // message:
                      //     "The order will be added to your cart. You can modify it or proceed with the same order.",
                      positiveAction: () {
                        Navigator.pop(context);
                        onReorder();
                      },
                      positiveButtonText: tr("common.continue"),
                      negativeButtonText: tr("common.cancel"),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
