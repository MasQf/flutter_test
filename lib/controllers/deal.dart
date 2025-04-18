import 'package:get/get.dart';

class DealController extends GetxController {
  var location = ''.obs;
  var date = Rxn<DateTime>();
  get formatDate {
    return '${date.value?.year}/${date.value?.month.toString().padLeft(2, '0')}/${date.value?.day.toString().padLeft(2, '0')} ${date.value?.hour.toString().padLeft(2, '0')}:${date.value?.minute.toString().padLeft(2, '0')}';
  }
}
