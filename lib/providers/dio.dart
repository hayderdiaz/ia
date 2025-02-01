import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioProvider {
  final String _uriPrd = 'http://52.71.55.169:8720/';
  final String _uriQa = 'http://54.161.52.202:8720/';

  //Post upload imagen
  Future<dynamic> postUploadImage1(FormData formData) async {
    try {
      // ignore: unused_local_variable
      Response uploadImage =
          await Dio().post('${_uriQa}predict/', data: formData);
      if (uploadImage.statusCode == 200) {
        return json.encode(uploadImage.data);
      } else {
        if (kDebugMode) {
          print('Error en la respuesta: ${uploadImage.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al enviar la imagen: $e");
      }
    }
  }
}
