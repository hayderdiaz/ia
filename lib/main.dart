import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ia/providers/dio.dart';
import 'package:ia/utils/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 8, 4, 187)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'IA Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //declaro las variables a utilizar
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic> data = {};
  List<dynamic> predictions = [];
  File? imagen;
  bool colorBotton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(193, 12, 25, 206),
        foregroundColor: Colors.white,
        leadingWidth: 110,
        title: Text(
          widget.title,
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
        shadowColor: Colors.white,
        flexibleSpace: ClipPath(
          clipper: _CustomClipper(),
          child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(193, 12, 25, 206)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Config.spaceSmall,
            //cargo el Widget
            bodyButton(context),
          ],
        ),
      ),
    );
  }

  Widget bodyButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconoimg(),
        consultarButton(),
        const SizedBox(
          height: 20,
        ),
        data.isEmpty
            ? const Center(child: Text('No hay resultados aún'))
            : result(),
      ],
    );
  }

  //Activar camara y tomar foto.
  Widget iconoimg() {
    return SizedBox(
      height: 55.0,
      child: IconButton(
          onPressed: () async {
            var archivo = await _picker.pickImage(
                source: ImageSource.camera, imageQuality: 25);
            //await _picker.pickImage(source: ImageSource.gallery);

            if (archivo != null) {
              setState(() {
                imagen = File(archivo.path);
                colorBotton = false;
              });
            }
          },
          //si la variable ColoBotton es false, cambio de color.
          icon: colorBotton == false
              ? const Icon(
                  CupertinoIcons.camera_fill,
                  color: Color.fromARGB(255, 0, 201, 7),
                  size: 30.0,
                )
              : const Icon(
                  CupertinoIcons.camera_fill,
                  color: Colors.black,
                  size: 30.0,
                )),
    );
  }

  //Cosumo el API utilizando DIO y FormData
  Widget consultarButton() {
    return SizedBox(
      width: 200.0,
      height: 46.0,
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
            elevation: 1.0,
            disabledBackgroundColor: const Color.fromARGB(255, 248, 248, 248),
            disabledForegroundColor: Colors.grey,
            backgroundColor: const Color.fromARGB(255, 54, 105, 244),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            side: const BorderSide(
              color: Colors.white70,
            ),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: imagen == null
            ? null
            : () async {
                //if (imagen != null) {
                final String filename = imagen!.path.split('/').last;

                final FormData formData = FormData.fromMap({
                  'file': await MultipartFile.fromFile(imagen!.path,
                      filename: filename)
                });

                var response1 = await DioProvider().postUploadImage1(formData);
                //}

                setState(() {
                  data = json.decode(response1);
                  predictions = data['predictions'];
                  if (kDebugMode) {
                    print(data);
                    print('imagen enviada $imagen');
                    print(data.length);
                  }
                });
              },
        child: const Text('Consultar'),
      ),
    );
  }

  //Muestro los resultados
  Widget result() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: predictions.length,
        itemBuilder: (context, index) {
          final prediction = predictions[index];
          return Card(
            margin: const EdgeInsets.all(10),
            color: const Color.fromARGB(213, 255, 255, 255),
            elevation: 20.0,
            shadowColor: Colors.grey,
            child: ListTile(
              title: Text(
                prediction['class_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color.fromARGB(255, 13, 138, 50),
                ),
              ),
              subtitle: Text(
                'Class ID: ${prediction['class_id']}\nProbability: ${(prediction['probability'] * 100).toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Color.fromARGB(255, 83, 110, 91),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var path = Path();

    path.lineTo(0, height - 28);
    path.quadraticBezierTo(width / 2, height, width, height - 25);
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
