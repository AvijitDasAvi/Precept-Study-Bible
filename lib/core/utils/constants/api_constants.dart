class ApiConstants {
  ApiConstants._();

  static String baseUrl = 'http://165.227.58.164:5000';
  // auth endpoints
  static String signUp = '$baseUrl/auth/signup';
  static String login = '$baseUrl/auth/login';
  static String sendOTP = '$baseUrl/auth/send-code';
  static String verifyOTP = '$baseUrl/auth/verify-code';
  static String resetPassword = '$baseUrl/auth/reset-password';
  static String forgotPassword = '$baseUrl/auth/forgot-password';
  static String verifyForgotPasswordOTP = '$baseUrl/auth/verify-forgot-code';
  static String setNewPassword = '$baseUrl/auth/set-new-password';
  // user endpoints
  static String userInfo = '$baseUrl/users/me';
  static String updateUser = '$baseUrl/users/updateMe';
  // book endpoints
  static String kjv = '$baseUrl/kjv';
  static String kjva = '$baseUrl/kjva';
  static String kjvcp = '$baseUrl/kjvcp';
  // topics endpoints
  static String postTopic = '$baseUrl/topics';
  static String getTopics = '$baseUrl/topics';
  static String getSingleTopic = '$baseUrl/topics/{topicId}';
  static String deleteTopic = '$baseUrl/topics/{topicId}';
  static String updateTopic = '$baseUrl/topics/{topicId}';
  static String addPreceptToTopic = '$baseUrl/topics/{topicId}/addPrecept';
  static String removePreceptFromTopic =
      '$baseUrl/topics/removePrecept/{preceptId}';
  // notes endpoints
  static String postNote = '$baseUrl/notes';
  static String patchNote = '$baseUrl/notes/{noteId}';
  static String deleteNote = '$baseUrl/notes/{noteId}';
  // recommended books
  static String recommendedBooks = '$baseUrl/recommended-books';
  // precept of the day
  static String preceptOfTheDay = '$baseUrl/random-content';
  static String spanishBook = '$baseUrl/spanish/{bookName}';
  static String spanishBookByChapter =
      '$baseUrl/spanish/{bookName}/chapter/{chapter}';
}
