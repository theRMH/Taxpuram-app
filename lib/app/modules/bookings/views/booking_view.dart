import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../common/map.dart';
import '../../../../common/ui.dart';
import '../../../models/booking_model.dart';
import '../../../providers/laravel_provider.dart';
import '../controllers/booking_controller.dart';
import '../controllers/bookings_controller.dart';
import '../widgets/booking_actions_widget.dart';
import '../widgets/booking_row_widget.dart';
import '../widgets/booking_til_widget.dart';
import '../widgets/booking_title_bar_widget.dart';

class BookingView extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BookingActionsWidget(),
      body: RefreshIndicator(
          onRefresh: () async {
            Get.find<LaravelApiClient>().forceRefresh();
            controller.refreshBooking(showMessage: true);
            Get.find<LaravelApiClient>().unForceRefresh();
          },
          child: CustomScrollView(
            primary: true,
            shrinkWrap: false,
            slivers: <Widget>[
              SliverAppBar(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  expandedHeight: 370,
  elevation: 0,
  floating: true,
  iconTheme: IconThemeData(color: Get.theme.primaryColor),
  centerTitle: true,
  automaticallyImplyLeading: false,
  leading: IconButton(
    icon: Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
    onPressed: () async {
      Get.find<BookingsController>().refreshBookings();
      Get.back();
    },
  ),
  bottom: buildBookingTitleBarWidget(controller.booking),
  flexibleSpace: Obx(() {
    if (!controller.booking.value.address.hasData)
      return SizedBox();
    else
      return FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          child: Image.network(
            controller.booking.value.eService.firstImageThumb,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Icon(Icons.error_outline);
            },
          ),
        ),
      );
  }).marginOnly(bottom: 68),
),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      if (!controller.booking.value.status.hasData)
                        return SizedBox();
                      else
                        return BookingTilWidget(
                          title: Text("Booking Details".tr, style: Get.textTheme.titleSmall),
                          actions: [Text("#" + controller.booking.value.id, style: Get.textTheme.titleSmall)],
                          content: Column(
                            children: [
                              BookingRowWidget(
                                  descriptionFlex: 1,
                                  valueFlex: 2,
                                  description: "Status".tr,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(right: 12, left: 12, top: 6, bottom: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: Get.theme.focusColor.withOpacity(0.1),
                                        ),
                                        child: Text(
                                          controller.booking.value.status.status,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          softWrap: true,
                                          style: TextStyle(color: Get.theme.hintColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  hasDivider: true),
                              
                              if (controller.booking.value.payment?.paymentMethod != null)
                                BookingRowWidget(
                                    description: "Payment Method".tr,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(right: 12, left: 12, top: 6, bottom: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            color: Get.theme.focusColor.withOpacity(0.1),
                                          ),
                                          child: Text(
                                            controller.booking.value.payment?.paymentMethod.name ?? "Not Paid".tr,
                                            style: TextStyle(color: Get.theme.hintColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    hasDivider: true),
                              BookingRowWidget(
                                description: "Hint".tr,
                                child: Ui.removeHtml(controller.booking.value.hint, alignment: Alignment.centerRight, textAlign: TextAlign.end),
                              ),
                            ],
                          ),
                        );
                    }),
                    BookingTilWidget(
                      title: Text("Booking Date & Time".tr, style: Get.textTheme.subtitle2),
                      
                      content: Obx(() {
                        return Column(
                          children: [
                            if (controller.booking.value.bookingAt != null)
                              BookingRowWidget(
                                  description: "Booking At".tr,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        DateFormat('d, MMMM y  HH:mm', Get.locale.toString()).format(controller.booking.value.bookingAt!),
                                        style: Get.textTheme.caption,
                                        textAlign: TextAlign.end,
                                      )),
                                  hasDivider: controller.booking.value.startAt != null || controller.booking.value.endsAt != null),
                            if (controller.booking.value.startAt != null)
                              BookingRowWidget(
                                  description: "Started At".tr,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        DateFormat('d, MMMM y  HH:mm', Get.locale.toString()).format(controller.booking.value.startAt!),
                                        style: Get.textTheme.caption,
                                        textAlign: TextAlign.end,
                                      )),
                                  hasDivider: false),
                            if (controller.booking.value.endsAt != null)
                              BookingRowWidget(
                                description: "Ended At".tr,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      DateFormat('d, MMMM y  HH:mm', Get.locale.toString()).format(controller.booking.value.endsAt!),
                                      style: Get.textTheme.caption,
                                      textAlign: TextAlign.end,
                                    )),
                              ),
                          ],
                        );
                      }),
                    ),
                    Obx(() {
                      if (!controller.booking.value.eService.hasData)
                        return SizedBox();
                      else
                        return BookingTilWidget(
                          title: Text("Pricing".tr, style: Get.textTheme.titleSmall),
                          content: Column(
                            children: [
                              BookingRowWidget(
                                  descriptionFlex: 2,
                                  valueFlex: 1,
                                  description: controller.booking.value.eService.name,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Ui.getPrice(controller.booking.value.eService.getPrice, style: Get.textTheme.titleSmall),
                                  ),
                                  hasDivider: true),
                              Column(
                                children: List.generate(controller.booking.value.options.length, (index) {
                                  var _option = controller.booking.value.options.elementAt(index);
                                  return BookingRowWidget(
                                      descriptionFlex: 2,
                                      valueFlex: 1,
                                      description: _option.name,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Ui.getPrice(_option.price, style: Get.textTheme.bodyLarge),
                                      ),
                                      hasDivider: (controller.booking.value.options.length - 1) == index);
                                }),
                              ),
                              if (controller.booking.value.eService.priceUnit == 'fixed')
                                BookingRowWidget(
                                    description: "Quantity".tr,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "x" + controller.booking.value.quantity.toString() + " " + (controller.booking.value.eService.quantityUnit.tr),
                                        style: Get.textTheme.bodyMedium,
                                      ),
                                    ),
                                    hasDivider: true),
                              Column(
                                children: List.generate(controller.booking.value.taxes.length, (index) {
                                  var _tax = controller.booking.value.taxes.elementAt(index);
                                  return BookingRowWidget(
                                      description: _tax.name,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _tax.type == 'percent'
                                            ? Text(_tax.value.toString() + '%', style: Get.textTheme.bodyLarge)
                                            : Ui.getPrice(
                                                _tax.value,
                                                style: Get.textTheme.bodyLarge,
                                              ),
                                      ),
                                      hasDivider: (controller.booking.value.taxes.length - 1) == index);
                                }),
                              ),
                              
                              if ((controller.booking.value.coupon.discount) > 0)
                                BookingRowWidget(
                                    description: "Coupon".tr,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Wrap(
                                        children: [
                                          Text(' - ', style: Get.textTheme.bodyLarge),
                                          Ui.getPrice(controller.booking.value.coupon.discount,
                                              style: Get.textTheme.bodyLarge, unit: controller.booking.value.coupon.discountType == 'percent' ? "%" : null),
                                        ],
                                      ),
                                    ),
                                    hasDivider: true),
                              Obx(() {
                                return BookingRowWidget(
                                  description: "Total Amount".tr,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Ui.getPrice(controller.booking.value.getTotal(), style: Get.textTheme.titleLarge),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                    })
                  ],
                ),
              ),
            ],
          )),
    );
  }

  BookingTitleBarWidget buildBookingTitleBarWidget(Rx<Booking> _booking) {
    return BookingTitleBarWidget(
      title: Obx(() {
        return Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _booking.value.eService.name,
                    style: Get.textTheme.headlineSmall!.merge(TextStyle(height: 1.1)),
                    overflow: TextOverflow.fade,
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Get.theme.focusColor),
                      SizedBox(width: 8),
                      Text(
                        _booking.value.user.name,
                        style: Get.textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                 
                ],
              ),
            ),
            if (_booking.value.bookingAt == null)
              Container(
                width: 80,
                child: SizedBox.shrink(),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              ),
            if (_booking.value.bookingAt != null)
              Container(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('HH:mm', Get.locale.toString()).format(_booking.value.bookingAt!),
                        maxLines: 1,
                        style: Get.textTheme.bodyMedium!.merge(
                          TextStyle(color: Get.theme.colorScheme.secondary, height: 1.4),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade),
                    Text(DateFormat('dd', Get.locale.toString()).format(_booking.value.bookingAt!),
                        maxLines: 1,
                        style: Get.textTheme.displaySmall!.merge(
                          TextStyle(color: Get.theme.colorScheme.secondary, height: 1),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade),
                    Text(DateFormat('MMM', Get.locale.toString()).format(_booking.value.bookingAt!),
                        maxLines: 1,
                        style: Get.textTheme.bodyMedium!.merge(
                          TextStyle(color: Get.theme.colorScheme.secondary, height: 1),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              ),
          ],
        );
      }),
    );
  }

  
}
