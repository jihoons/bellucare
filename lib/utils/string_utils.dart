class StringUtils {
  static String lpad(String value, int length, {String padding = "0"}) {
    if (value.length < length) {
      return "${List.generate(length - value.length, (index) => padding,).join()}$value";
    } else {
      return value;
    }
  }

  static String formatDateTime(DateTime value) {
    return "${value.year}-${lpad("${value.month}", 2)}-${lpad("${value.day}", 2)} ${lpad("${value.hour}", 2)}:${lpad("${value.minute}", 2)}:${lpad("${value.second}", 2)}.${lpad("${value.millisecond}", 3)}";
  }
}