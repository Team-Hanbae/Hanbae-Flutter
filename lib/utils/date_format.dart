String formatDateShort(DateTime date) {
  final yy = (date.year % 100).toString().padLeft(2, '0'); // 2025 -> "25"
  final mm = date.month.toString().padLeft(2, '0');        // 11   -> "11"
  final dd = date.day.toString().padLeft(2, '0');          // 30   -> "30"

  return '$yy.$mm.$dd.';
}