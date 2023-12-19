import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/address_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/coupon_model.dart';
import '../../../models/e_service_model.dart';
import '../../../models/option_model.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/setting_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/settings_service.dart';
import '../../bookings/controllers/bookings_controller.dart';
import '../../global_widgets/tab_bar_widget.dart';

class BookEServiceController extends GetxController {
  final scheduled = false.obs;
  final booking = Booking().obs;
  final addresses = <Address>[].obs;
  late BookingRepository _bookingRepository;
  late SettingRepository _settingRepository;

  Address get currentAddress => Get.find<SettingsService>().address.value;

  BookEServiceController() {
    _bookingRepository = BookingRepository();
    _settingRepository = SettingRepository();
  }

DateTime? get selectedDate => booking.value.bookingAt;
  TimeOfDay? get selectedTime => _selectedTime;
  TimeOfDay? _selectedTime;
bool isTimeWithinRange(TimeOfDay selectedTime) {
    TimeOfDay openingTime = TimeOfDay(hour: 10, minute: 0); // Replace with your opening time
    TimeOfDay closingTime = TimeOfDay(hour: 18, minute: 0); // Replace with your closing time

    int selectedTimeInSeconds = selectedTime.hour * 60 + selectedTime.minute;
    int openingTimeInSeconds = openingTime.hour * 60 + openingTime.minute;
    int closingTimeInSeconds = closingTime.hour * 60 + closingTime.minute;

    return selectedTimeInSeconds >= openingTimeInSeconds && selectedTimeInSeconds <= closingTimeInSeconds;
  }
 bool isDateAndTimeValid() {
    DateTime currentDate = DateTime.now();
    DateTime selectedDate = this.selectedDate ?? currentDate;

    // Validate date and time
    if (selectedDate.isBefore(currentDate.add(Duration(days: 0))) ||
        selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday ||
        (selectedTime == null) || // No time selected
        !isTimeWithinRange(selectedTime!)) {
      return false;
    }

    return true;
  }




  @override
  void onInit() async {
    super.onInit();
    final _eService = (Get.arguments['eService'] as EService);
    final _options = (Get.arguments['options'] as List<Option>);
    final _quantity = (Get.arguments['quantity'] as int);
    this.booking.value = Booking(
      bookingAt: DateTime.now(),
      address: currentAddress,
      eService: _eService,
      eProvider: _eService.eProvider,
      taxes: _eService.eProvider.taxes,
      options: _options,
      duration: 1,
      quantity: _quantity,
      user: Get.find<AuthService>().user.value,
      coupon: new Coupon(),
    );
    await getAddresses();
  }

  @override
  void update([ids, bool condition = true]) {
    print("fsdfsdf");
  }

  void toggleScheduled(value) {
    scheduled.value = value;
  }

  TextStyle? getTextTheme(bool selected) {
    if (selected) {
      return Get.textTheme.bodyMedium!.merge(TextStyle(color: Get.theme.primaryColor));
    }
    return Get.textTheme.bodyMedium;
  }

  Color? getColor(bool selected) {
    if (selected) {
      return Get.theme.colorScheme.secondary;
    }
    return null;
  }

  void createBooking() async {
    try {
      this.booking.value.address = currentAddress;
      await _bookingRepository.add(booking.value);
      Get.find<BookingsController>().currentStatus.value = Get.find<BookingsController>().getStatusByOrder(1).id;
      if (Get.isRegistered<TabBarController>(tag: 'bookings')) {
        Get.find<TabBarController>(tag: 'bookings').selectedId.value = Get.find<BookingsController>().getStatusByOrder(1).id;
      }
      Get.toNamed(Routes.CONFIRMATION);
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getAddresses() async {
    try {
      if (Get.find<AuthService>().isAuth) {
        addresses.assignAll(await _settingRepository.getAddresses());
        if (!currentAddress.isUnknown()) {
          addresses.remove(currentAddress);
          addresses.insert(0, currentAddress);
        }
        if (Get.isRegistered<TabBarController>(tag: 'addresses')) {
          Get.find<TabBarController>(tag: 'addresses').selectedId.value = addresses.elementAt(0).id;
        }
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  void validateCoupon() async {
    try {
      Coupon _coupon = await _bookingRepository.coupon(booking.value);
      booking.update((val) {
        val!.coupon = _coupon;
      });
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  String? getValidationMessage() {
    if (!booking.value.coupon.hasData) {
      return null;
    } else {
      if (booking.value.coupon.id == '') {
        return "Invalid Coupon Code".tr;
      } else {
        return null;
      }
    }
  }

  Future<Null> showMyDatePicker(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: booking.value.bookingAt?.add(Duration(days: 1)) ?? DateTime.now().add(Duration(days: 1)),
    firstDate: DateTime.now().add(Duration(days: 1)),
    lastDate: DateTime(2101),
    locale: Get.locale,
    builder: (BuildContext context, Widget? child) {
      return child!.paddingAll(10);
    },
  );

  if (picked != null) {
    if (picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday) {
      // Show an error message for Saturday and Sunday
      Get.defaultDialog(
        title: "Error",
        titleStyle: TextStyle(color: Colors.red),
        middleText: "Please select a weekday (Monday to Friday).",
        backgroundColor: Get.theme.primaryColor,
        radius: 10.0,
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text("OK", style: TextStyle(color: Colors.red)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
            ),
          ),
        ],
      );
    } else {
      // Update the booking date
      booking.update((val) {
        val!.bookingAt = DateTime(picked.year, picked.month, picked.day, val.bookingAt?.hour ?? 0, val.bookingAt?.minute ?? 0);
      });
    }
  }
}


  void showMyTimePicker(BuildContext context) async {
  TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();

  TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (pickedTime != null && isTimeWithinRange(pickedTime)) {
    _selectedTime = pickedTime; // Update selectedTime
    booking.update((val) {
      val!.bookingAt = DateTime(
        booking.value.bookingAt!.year,
        booking.value.bookingAt!.month,
        booking.value.bookingAt!.day,
      ).add(Duration(minutes: pickedTime.minute + pickedTime.hour * 60));
    });
  } else {
    // Show an error message in the popup itself with app default color
    Get.defaultDialog(
  title: "Error",
  titleStyle: TextStyle(color: Colors.red), // Set "Error" text color to red
  middleText: "Please select a time between 10 A.M to 6 P.M",
  backgroundColor: Get.theme.primaryColor,
  radius: 10.0,
  actions: [
    ElevatedButton(
      onPressed: () => Get.back(),
      child: Text("OK", style: TextStyle(color: Colors.red)), // Set "OK" text color
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
      ),
    ),
  ],
);

  }
}


}
