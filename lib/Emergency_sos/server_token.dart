import 'package:googleapis_auth/auth_io.dart';

// ignore: camel_case_types
class get_server_key {
  // ignore: non_constant_identifier_names
  Future<String> server_token() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "propertypall",
          "private_key_id": "35cb5fca8828e0dc75b31ddf642cc6d94f2ebc07",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCihZe4afKS09zy\nCrh381BG0WawqP4QJMjR2bCoq2qKOhCWP5YUrlCsGkuvzPtaQ7e4vwGZdNlejaQs\nQl4ijXJU4XdOeZro0mOxDcuS5PAu9Ukg1uaX1X3zQ1nqg/n50P3uXK42IoOmd52M\npZ3y2I6px2DneXJYqbCpaOfMmOJrsvwCyO16iCdWt5hbxdEAFDp7e87VR0nJTA9J\nxugIQ7ogukBZib20iH5MyWUxjykH45pjlNFExYL6RmNTayEMhBtILhfGuFRiCtL8\nm8vajsp3rPiskCzLxA6g8lQo7iCrU9EOva/SpqTa+WOvQlCL0H2FlGSzu4M7Vu9a\nj2Y21EhXAgMBAAECggEALZE1W+BgwegjD74PwJn4zRJTL38CVPZrU+MsU+5T3dOv\n6OCFLOE+/zIUPINFiiZocaUkRqlrdMZT3JDzIc702nWo5NjVpSewCelrRZFpAlGF\nom5+kt2qBbXBlS5RvUhqmhVkRwtgTCFHjDK3WWp8fX/IXL5BYDibrrQaIdRPz5Aa\nCp7FqQ6iO5O8JU3Ud9uPEvgCmbEwW2IiRVXKlpfAWlGz5O2k3qveQoy85Ada31Ap\nlf5+Bn+52oa2jGTU6a/fNlHw28KMGxqA96tguZ73KBPOIrZK5SSB2h7cjTrFxzWS\nijDoqTljEJUcBlh6evvI+UoZcxyIdsqrvpxYrPJZIQKBgQDGmJOV6DJCjOhEF6pW\n1ww6/v1yx29cIgH/QQ45emycgbCSeX0XDaurIOq/t2c87Atq2p+Jqq0oXeYVJfFJ\n3WHQ9OhJ7xA48ejf0BmIVqpAcjLcRImUKeYHZ1l5ntandA9trVuE6FRt1uN/YJbY\nzXHxwyExkC9eK4ITTywrqB//JwKBgQDRf6b7NHxT9mgVSwEGBxezRWQ3HFJcoKov\nIzur3B6Lsl/mtXc/UGBmPtE1t9fibkBphIbTpXBw3uEpQaTmZ4+6NdUQZkzsnhXw\nhj1oC3ul/wbrHytlYmpddIT2oACOJ+jC2He8hDobyxZe+NPxSy0S9+Rb331wQxlp\nS/0ou/8rUQKBgGrL5BnqSxTkx4bOnyih7o7PTyZpP2ZxV1eX+XlJb5zeVUD/mhhK\nnrWhNvwwOZFWcnFc7gxPP10E2dUnmVEafx6qhTw1Fik5Vfz94K0jxdxwTQ+Mv9tw\niKYUmtY/Z7mXPTDC2ANqGPUUaTS3kYc3O/5B69jGa+KdTQ7rNZqoh8RjAoGBALiV\nf3uP+AdGcNhp+GHmN+SVPEIuawb/7FKR+Y5n6GXvaP3uXz3ixLzxlgV9kPIJcClI\nQj8SYiqgxcRC+VakYoePzMWhTR+h/fSpYktc6roMJH1fPi4a81qaQljGCxc1ZKjg\nb0cjPculOXW+SYctVG6FCahFFtGl3SrgcBLG6YGxAoGAIY5NfT4E3PBq0gM7ODQr\njsG57t7dnLgugnIA/2k0r9Q51N/VXwytuwp+hKEkgihdqWQ66rPxfJqaQd6F2hsv\nrxFhappdHk8J+nndn0SgRIlhZaY5GDKjyTNY/xlgjYy+xs/PzzFnyEmOESGlaPv6\nyNQvcf8yg6VXWHWdJp37G0c=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-zg1es@propertypall.iam.gserviceaccount.com",
          "client_id": "109988975729385230394",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zg1es%40propertypall.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessserverkey = client.credentials.accessToken.data;
    return accessserverkey;
  }
}
