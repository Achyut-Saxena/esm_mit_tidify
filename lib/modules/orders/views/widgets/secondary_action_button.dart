import 'package:eSamudaay/modules/cart/models/cart_model.dart';
import 'package:eSamudaay/modules/orders/views/widgets/cancel_order_prompt.dart';
import 'package:eSamudaay/presentations/custom_confirmation_dialog.dart';
import 'package:eSamudaay/themes/custom_theme.dart';
import 'package:eSamudaay/utilities/image_path_constants.dart';
import 'package:eSamudaay/utilities/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CancelOrderButton extends StatefulWidget {
  final Function(String) onCancel;
  // when cancel button animation is completed, an empty widget is returned in place of cancel button.
  // but at the same time 'order_details' button needs to be centered in parent widget.
  // we use this callback to reset the state in order card.
  final VoidCallback onAnimationComplete;
  final PlaceOrderResponse orderResponse;
  const CancelOrderButton({
    @required this.onCancel,
    this.onAnimationComplete,
    @required this.orderResponse,
    Key key,
  }) : super(key: key);

  @override
  _CancelOrderButtonState createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends State<CancelOrderButton>
    with SingleTickerProviderStateMixin {
  bool showCancelButton;
  AnimationController _animationController;
  Animation<double> animation;

  @override
  void initState() {
    showCancelButton = widget.orderResponse.secondsLeftToCancel > 0;

    if (showCancelButton) {
      final int timeDiffrence =
          widget.orderResponse.cancellationAllowedForSeconds -
              widget.orderResponse.secondsLeftToCancel;

      _animationController = new AnimationController(
        duration: Duration(
          seconds: widget.orderResponse.secondsLeftToCancel,
        ),
        vsync: this,
      );

      animation = Tween<double>(
        // animation should start from nth point if n seconds have already passed after placing the order.
        begin:
            (timeDiffrence / widget.orderResponse.cancellationAllowedForSeconds)
                .toDouble(),
        end: 1.0,
      ).animate(_animationController)
        ..addListener(() {
          if (_animationController.isCompleted) {
            _animationController.dispose();
            showCancelButton = false;
            if (widget.onAnimationComplete != null) {
              widget.onAnimationComplete();
            }
          }
          setState(() {
            // the state that has changed here is the animation object’s value
          });
        });

      _animationController.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!showCancelButton) {
      return SizedBox.shrink();
    }

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => CancelOrderPrompt(widget.onCancel),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                value: animation.value,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  CustomTheme.of(context).colors.warningColor,
                ),
                backgroundColor:
                    CustomTheme.of(context).colors.placeHolderColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tr("screen_order.Cancel"),
              style: CustomTheme.of(context).textStyles.sectionHeading2,
            ),
          ],
        ),
      ),
    );
  }
}

class ReorderButton extends StatelessWidget {
  final VoidCallback onReorder;

  const ReorderButton(this.onReorder, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
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
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: CustomTheme.of(context).colors.textColor,
            ),
            const SizedBox(width: 8),
            Text(
              tr("screen_order.reorder"),
              style: CustomTheme.of(context).textStyles.sectionHeading2,
            ),
          ],
        ),
      ),
    );
  }
}

class PayButton extends StatelessWidget {
  final VoidCallback onPay;
  final PlaceOrderResponse orderResponse;

  const PayButton({
    @required this.onPay,
    @required this.orderResponse,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: orderResponse.paymentInfo.isPaymentDone ||
              orderResponse.paymentInfo.isPaymentInitiated
          ? null
          : onPay,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          orderResponse.paymentInfo.isPaymentDone ||
                  orderResponse.paymentInfo.isPaymentInitiated
              ? Icon(
                  Icons.check_circle_outline,
                  size: 30,
                  color: CustomTheme.of(context).colors.positiveColor,
                )
              : Image.asset(
                  ImagePathConstants.paymentGreenIcon,
                  width: 35,
                  fit: BoxFit.contain,
                ),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              child: Text.rich(
                TextSpan(
                  text: (orderResponse.paymentInfo.isPayLaterSelected
                          ? tr(
                              orderResponse.deliveryType ==
                                      DeliveryType.DeliveryToHome
                                  ? "payment_statuses.pay_on_delivery"
                                  : "payment_statuses.pay_on_pickup",
                            )
                          : tr(
                              "payment_statuses.${orderResponse.paymentInfo.status.toLowerCase()}")) +
                      "\n",
                  style: CustomTheme.of(context).textStyles.body2Faded,
                  children: [
                    TextSpan(
                      text: tr(
                        orderResponse.paymentInfo.isPaymentDone ||
                                orderResponse.paymentInfo.isPaymentInitiated
                            ? "payment_statuses.paid_amout"
                            : "payment_statuses.pay_amount",
                        args: [
                          orderResponse.orderTotalPriceInRupees.withRupeePrefix
                        ],
                      ),
                      style: CustomTheme.of(context)
                          .textStyles
                          .sectionHeading2
                          .copyWith(
                            color: orderResponse.paymentInfo.isPaymentDone ||
                                    orderResponse.paymentInfo.isPaymentInitiated
                                ? CustomTheme.of(context).colors.textColor
                                : CustomTheme.of(context).colors.positiveColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailsButton extends StatelessWidget {
  final VoidCallback goToOrderDetails;
  final bool isCenterAligned;
  const OrderDetailsButton(
    this.goToOrderDetails, {
    this.isCenterAligned = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goToOrderDetails,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: isCenterAligned
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                tr("screen_order.order_details"),
                style: CustomTheme.of(context)
                    .textStyles
                    .sectionHeading2Primary
                    .copyWith(fontWeight: FontWeight.normal),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CustomTheme.of(context).colors.primaryColor,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_outlined,
                  size: 16,
                  color: CustomTheme.of(context).colors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// In case of list items , when merchant updates the order,
// customer should have an option to cancel order in case they don't like merchant updates.
class RejectOrderButton extends StatelessWidget {
  final Function(String) onReject;
  const RejectOrderButton(this.onReject, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => CancelOrderPrompt(onReject),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.clear,
              color: CustomTheme.of(context).colors.secondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              tr("screen_order.Cancel"),
              style: CustomTheme.of(context).textStyles.sectionHeading2,
            ),
          ],
        ),
      ),
    );
  }
}
