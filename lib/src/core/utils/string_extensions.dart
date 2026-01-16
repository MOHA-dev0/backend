extension StringExtensions on String {
  String toEnglishDigits() {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const english = '0123456789';

    String result = this;
    for (int i = 0; i < arabic.length; i++) {
        result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }
}
