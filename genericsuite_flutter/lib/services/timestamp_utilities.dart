import 'utilities.dart';

const tsUtDebug = false;

const gmtTail = '.000Z'; // '.000-0000'
const dateTimeTail = 'T00:00:00$gmtTail';

String timestampToDate({
  required dynamic timestamp,
  bool fullDateTime = false,
  String separator = '',
  bool militaryTime = true,
}) {
  if (tsUtDebug) {
    logDebug(
      'timestampToDate: $timestamp, fullDateTime: $fullDateTime, separator: $separator, militaryTime: $militaryTime',
    );
  }

  double timestampUnixEpoch = double.parse(timestamp.toString()) * 1000;

  DateTime date = DateTime.fromMillisecondsSinceEpoch(
    timestampUnixEpoch.toInt(),
  );
  if (tsUtDebug) {
    logDebug(
      'timestampToDate | timestampUnixEpoch: $timestampUnixEpoch, date: $date',
    );
  }

  int hours = date.hour;
  int minutes = date.minute;
  String ampm = hours >= 12 ? 'PM' : 'AM';
  String formattedTime =
      '${(hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)).toString()}'
      ':'
      '${(minutes < 10 ? '0' : '')}'
      '${minutes.toString()}'
      ' $ampm';

  if (fullDateTime) {
    if (separator.isNotEmpty) {
      if (!militaryTime) {
        return date.toIso8601String().split("T")[0] + separator + formattedTime;
      }
      return date.toIso8601String().split("T").join(separator).substring(0, 19);
    }
    if (!militaryTime) {
      return '${date.toIso8601String().split("T")[0]}T$formattedTime';
    }
    return date.toIso8601String();
  }
  return date.toIso8601String().split("T")[0];
}

String addMissingTz(String stringDate) {
  return stringDate + (stringDate.indexOf('.') > 0 ? '' : gmtTail);
}

int dateToTimestap(String stringDate) {
  return ((DateTime.parse(addMissingTz(stringDate)).millisecondsSinceEpoch) ~/
          1000)
      .toInt();
}

int nowToTimestap() {
  return ((DateTime.now().millisecondsSinceEpoch) ~/ 1000).toInt();
}

String fixDateWithTz(String dateTimeString) {
  switch (dateTimeString.length) {
    case 10:
      dateTimeString += dateTimeTail;
      break;
    case 16:
      dateTimeString += ':00$gmtTail';
      break;
    default:
      dateTimeString = addMissingTz(dateTimeString);
  }
  return dateTimeString;
}

String processTimestampToDate(
  dynamic timestampMixed,
  bool fullDatetime,
  String separator,
) {
  if (tsUtDebug) {
    logDebug(
      'processTimestampToDate | timestampMixed: $timestampMixed, fullDatetime: $fullDatetime, separator: $separator',
    );
  }
  if (timestampMixed is int || timestampMixed is double) {
    if (timestampMixed == 0) {
      timestampMixed = nowToTimestap();
    }
    timestampMixed = timestampMixed.toString();
  } else if (timestampMixed is String) {
    timestampMixed = fixDateWithTz(timestampMixed);
    timestampMixed = dateToTimestap(timestampMixed);
  }
  return timestampToDate(
    timestamp: timestampMixed,
    fullDateTime: fullDatetime,
    separator: separator,
  );
}

int processDateToTimestamp(String dateTime) {
  if (tsUtDebug) {
    logDebug('processDateToTimestamp - BEFORE: $dateTime');
  }
  dateTime = fixDateWithTz(dateTime);
  if (tsUtDebug) {
    logDebug(
      'processDateToTimestamp - AFTER: $dateTime | Resultado: ${dateToTimestap(dateTime)}',
    );
  }
  return dateToTimestap(dateTime);
}

String addZeroTimeToDate(String dateValue) {
  DateTime date = DateTime.parse(dateValue);
  date = DateTime(date.year, date.month, date.day);
  return date.toIso8601String().substring(0, 19).replaceAll('T', ' ');
}

dynamic convertTimestampToInt(dynamic timestamp) {
  if (timestamp == null) {
    return 0;
  }
  if (timestamp is double) {
    return timestamp.toInt();
  }
  if (timestamp is String) {
    return int.tryParse(timestamp) ?? 0;
  }
  return timestamp;
}
