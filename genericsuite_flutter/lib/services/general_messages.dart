import 'utilities.dart';

const gmDebug = false;

Map<String, dynamic> apiErrorMessages = {
  "serverIsDown": "The server is not available. Please try again later.",
  "serverError": "The server has returned an error. Please try again later.",
  "internalError": "An internal error has occurred.",
  "unknownError": "An unknown error has occurred.",
};

String getApiErrorMessage(String key) {
  if (gmDebug) {
    logDebug(
      'GeneralMessages | getApiErrorMessage | key: $key'
      ' | apiErrorMessages: $apiErrorMessages',
    );
  }
  return apiErrorMessages[key] ?? apiErrorMessages['unknownError'];
}
