import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../common/helper.dart';
import '../../../models/booking_model.dart';
import '../../../repositories/payment_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/global_service.dart';
import '../../bookings/controllers/bookings_controller.dart';
import '../../global_widgets/tab_bar_widget.dart';

class PayMongoController extends GetxController {
  late WebViewController webView;
  late PaymentRepository _paymentRepository;
  final url = Uri().obs;
  final progress = 0.0.obs;
  final booking = new Booking().obs;

  PayMongoController() {
    _paymentRepository = new PaymentRepository();
  }

  @override
  void onInit() {
    booking.value = Get.arguments['booking'] as Booking;
    getUrl();
    initWebView();
    super.onInit();
  }

  void initWebView() {
    webView = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(url.value)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String _url) {
            url.value = Uri.parse(_url);
            showConfirmationIfSuccess();
          },
          onPageFinished: (String url) {
            progress.value = 1;
          },
        ),
      );
  }

  void getUrl() {
    url.value = _paymentRepository.getPayMongoUrl(booking.value);
  }

  void showConfirmationIfSuccess() {
    final _doneUrl = "${Helper.toUrl(Get.find<GlobalService>().baseUrl)}payments/paymongo";
    if (url.value.toString() == _doneUrl) {
      Get.find<BookingsController>().currentStatus.value = (Get.find<BookingsController>().getStatusByOrder(50).id);
      if (Get.isRegistered<TabBarController>(tag: 'bookings')) {
        Get.find<TabBarController>(tag: 'bookings').selectedId.value = (Get.find<BookingsController>().getStatusByOrder(50).id);
      }
      Get.toNamed(Routes.CONFIRMATION, arguments: {
        'title': "Payment Successful".tr,
        'long_message': "Your Payment is Successful".tr,
      });
    }
  }
}
