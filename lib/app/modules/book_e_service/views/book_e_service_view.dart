import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../common/ui.dart';
import '../../../models/booking_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/book_e_service_controller.dart';

class BookEServiceView extends GetView<BookEServiceController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book the Service".tr,
          style: context.textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      bottomNavigationBar: buildBlockButtonWidget(controller.booking.value),
      body: ListView(
        children: [
          Obx(() {
            return TextFieldWidget(
              onChanged: (input) => controller.booking.value.coupon.code = input,
              hintText: "COUPON01".tr,
              labelText: "Coupon Code".tr,
              errorText: controller.getValidationMessage() ?? '',
              iconData: Icons.confirmation_number_outlined,
              style: Get.textTheme.bodyMedium!.merge(TextStyle(
                  color: controller.getValidationMessage() != null ? Colors.redAccent : Colors.green)),
              suffixIcon: MaterialButton(
                onPressed: () {
                  controller.validateCoupon();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                color: Get.theme.focusColor.withOpacity(0.1),
                child: Text("Apply".tr, style: Get.textTheme.bodyLarge),
                elevation: 0,
              ).marginSymmetric(vertical: 4),
            );
          }),
          TextFieldWidget(
            onChanged: (input) => controller.booking.value.hint = input,
            hintText: "Is there anything else you would like us to know?".tr,
            labelText: "Notes".tr,
            iconData: Icons.description_outlined,
          ),
          SizedBox(height: 20),
          Obx(() {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: Ui.getBoxDecoration(color: controller.getColor(controller.scheduled.value)),
              child: Theme(
                data: ThemeData(
                  toggleableActiveColor: Get.theme.primaryColor,
                ),
                child: RadioListTile(
                  value: true,
                  groupValue: controller.scheduled.value,
                  activeColor: Colors.white, // Set to white color
                  onChanged: (value) {
                    controller.toggleScheduled(value);
                  },
                  title: Text("Select Date & Time".tr,
                          style: controller.getTextTheme(controller.scheduled.value)).paddingSymmetric(vertical: 20),
                ),
              ),
            );
          }),
          Obx(() {
            return AnimatedOpacity(
              opacity: controller.scheduled.value ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: controller.scheduled.value ? 20 : 0),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: controller.scheduled.value ? 20 : 0),
                decoration: Ui.getBoxDecoration(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("When would you like us to call you?".tr, style: Get.textTheme.bodyLarge),
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          elevation: 0,
                          onPressed: () {
                            // Add your logic for showing date picker only if the selected date is valid
                              controller.showMyDatePicker(context);
                            
                          },
                          shape: StadiumBorder(),
                          color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                          child: Text("Select a Date".tr, style: Get.textTheme.titleMedium),
                        ),
                      ],
                    ),
                    Divider(thickness: 1.3, height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Text("At what time are you free for a call?".tr, style: Get.textTheme.bodyLarge),
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          onPressed: () {
                            // Add your logic for showing time picker only if the selected time is valid
                              controller.showMyTimePicker(context);
                            
                          },
                          shape: StadiumBorder(),
                          color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                          child: Text("Select a time".tr, style: Get.textTheme.titleMedium),
                          elevation: 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
  if (controller.scheduled.value && controller.booking.value.bookingAt != null) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, controller.scheduled.value ? 0 : -110, 0),
      child: Obx(() {
        return Column(
          children: [
            Text("Requested Service on".tr).paddingSymmetric(vertical: 20),
            Text('${DateFormat.yMMMMEEEEd(Get.locale.toString()).format(controller.booking.value.bookingAt!)}',
                style: Get.textTheme.headlineSmall),
            Text('${DateFormat('HH:mm', Get.locale.toString()).format(controller.booking.value.bookingAt!)}',
                style: Get.textTheme.displaySmall),
            SizedBox(height: 20)
          ],
        );
      }),
    );
  } else {
    return Container(); // Return an empty container if not selected or date and time not chosen
  }
}),

        ],
      ),
    );
  }

  Widget buildBlockButtonWidget(Booking _booking) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5)),
        ],
      ),
      child: Obx(() {
        return BlockButtonWidget(
          text: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Continue".tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.titleLarge?.merge(
                    TextStyle(color: Get.theme.primaryColor),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Get.theme.primaryColor, size: 20)
            ],
          ),
          color: Get.theme.colorScheme.secondary,
           onPressed: (!(Get.find<SettingsService>().address.value.isUnknown()))
              ? () {
                  // Check if "Schedule an Order" is selected before navigating
                  if (controller.scheduled.value) {
                    // Perform date and time validation
                    if (controller.isDateAndTimeValid() && controller.isTimeWithinRange(controller.selectedTime!)) {
                      Get.toNamed(Routes.BOOKING_SUMMARY);
                    } else {
                      Get.snackbar('Error', 'Please select a date and time.');
                    }
                  } else {
                    // Show an error message or handle the case where the option is not selected
                    Get.snackbar('Error', 'Please select date and time before proceeding.');
                  }
                }
              : null,
        ).paddingOnly(right: 20, left: 20);
      }),
    );
  }
}
