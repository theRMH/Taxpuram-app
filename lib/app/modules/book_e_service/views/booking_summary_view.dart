import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../common/ui.dart';
import '../../../models/booking_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../global_widgets/block_button_widget.dart';
import '../controllers/book_e_service_controller.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../widgets/payment_details_widget.dart';

class BookingSummaryView extends GetView<BookEServiceController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Booking Summary".tr,
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
        bottomNavigationBar: buildBottomWidget(controller.booking.value),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Booking At".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${DateFormat.yMMMMEEEEd(Get.locale.toString()).format(controller.booking.value.bookingAt!)}', style: Get.textTheme.bodyMedium),
                          Text('${DateFormat('HH:mm', Get.locale.toString()).format(controller.booking.value.bookingAt!)}', style: Get.textTheme.bodyMedium),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("A Hint for the Provider".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                        child: Obx(() {
                          return Text(controller.booking.value.hint, style: Get.textTheme.bodyMedium);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildBottomWidget(Booking _booking) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaymentDetailsWidget(booking: _booking),
          Obx(() {
            return BlockButtonWidget(
              text: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Confirm & Book Now".tr,
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
              onPressed: Get.find<LaravelApiClient>().isLoading(task: "addBooking")
                  ? null
                  : () {
                      // Call the method to initiate Razorpay payment
                      initiateRazorpayPayment();
                    },
            ).paddingSymmetric(vertical: 10, horizontal: 20);
          }),
        ],
      ),
    );
  }


 // New method to initiate Razorpay payment
  void initiateRazorpayPayment() {
    final Razorpay _razorpay = Get.find<Razorpay>();
    final User user = Get.find<AuthService>().user.value;


       // Get user's contact number and email from ProfileController
  String userContact = user.phoneNumber ?? ""; // Replace "" with your default value or handle accordingly
  String userEmail = user.email ?? ""; // Replace "" with your default value or handle accordingly



    // Create a payment options object
    var options = {
      'key': 'rzp_live_3pleQJyWFEyG5G',
      'amount': controller.booking.value.getTotal() * 100, // amount in the smallest currency unit (e.g., paise in INR)
      'name': 'Taxpuram App',
      'description': 'Payment for Booking',
      'prefill': {
        'contact': userContact,
        'email': userEmail,
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      // Open the Razorpay checkout form
      _razorpay.open(options);
    } catch (e) {
      print('Error initiating Razorpay payment: $e');
    }

    // Set up listeners for payment success and failure
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  // Callback for payment success
  void handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Successful: ${response.paymentId}');
    // Proceed with the booking confirmation
    controller.createBooking();
  }

  // Callback for payment failure
  void handlePaymentError(PaymentFailureResponse response) {
    print('Payment Failed: ${response.code} - ${response.message}');
    // Handle the case where the payment failed
    // You may want to show an error message to the user
  }

  // Callback for external wallet usage
  void handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet Used: ${response.walletName}');
  }
}