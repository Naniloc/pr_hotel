class Validators {
  static String? required(String? value, [String fieldName = 'Поле']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName обязательно для заполнения';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, [
    String fieldName = 'Поле',
  ]) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '$fieldName должно содержать минимум $min символов';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int max, [
    String fieldName = 'Поле',
  ]) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '$fieldName должно содержать максимум $max символов';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Введите корректный email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Номер телефона должен содержать 10-15 цифр';
    }
    return null;
  }

  static String? positiveInt(String? value, [String fieldName = 'Значение']) {
    if (value == null || value.isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return '$fieldName должно быть положительным числом';
    }
    return null;
  }

  static String? range(
    String? value,
    int min,
    int max, [
    String fieldName = 'Значение',
  ]) {
    if (value == null || value.isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName должно быть числом';
    }
    if (number < min || number > max) {
      return '$fieldName должно быть от $min до $max';
    }
    return null;
  }

  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static String? passportNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (digits.length != 10 || int.tryParse(digits) == null) {
      return 'Номер паспорта должен содержать 10 цифр (серия и номер)';
    }
    return null;
  }

  static String? notFutureDate(DateTime? value) {
    if (value == null) return null;

    final today = DateTime.now();
    final compareDate = DateTime(today.year, today.month, today.day);
    final valueDate = DateTime(value.year, value.month, value.day);

    if (valueDate.isAfter(compareDate)) {
      return 'Дата не может быть в будущем';
    }
    return null;
  }

  static String? notPastDate(DateTime? value) {
    if (value == null) return null;

    final today = DateTime.now();
    final compareDate = DateTime(today.year, today.month, today.day);
    final valueDate = DateTime(value.year, value.month, value.day);

    if (valueDate.isBefore(compareDate)) {
      return 'Дата не может быть в прошлом';
    }
    return null;
  }
}
