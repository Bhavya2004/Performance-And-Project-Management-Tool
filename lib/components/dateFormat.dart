import 'package:intl/intl.dart';

String getFormattedDateTime({dynamic dateToFormat}) {
  if (dateToFormat != null) {
    return DateFormat('yyyy-MM-dd').format(dateToFormat).toString();
  } else {
    return DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  }
}

String getFormattedYear({dynamic year}) {
  if (year != null) {
    return DateFormat('yyyy').format(year).toString();
  } else {
    return DateFormat('yyyy').format(DateTime.now()).toString();
  }
}
