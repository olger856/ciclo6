class ConfigApi {
  static const String appName = "Colegio";
  // static const String apiURL = "172.22.4.12:9090";
<<<<<<< HEAD
  static const String apiURL = "192.168.56.1:9090";
=======
  static const String apiURL = "172.17.96.1:9090";
>>>>>>> f5feb8454d7ea105f349231508f3d4dfad2996d8
  static const String loginAPI = "/auth/login";
  static const String registerAPI = "/auth/create";
  static const String listUserAPI = "/auth/list";

  static String buildUrl(String endpoint) {
    return 'http://$apiURL$endpoint';
  }

}

