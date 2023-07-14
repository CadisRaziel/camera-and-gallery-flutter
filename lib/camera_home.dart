import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera_example/camera_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraHome extends StatefulWidget {
  const CameraHome({Key? key}) : super(key: key);

  @override
  State<CameraHome> createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> multipleImages = [];

  multipleImagePicker() async {
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage();

    for (var xfile in pickedImages) {
      File imageFile = File(xfile.path);
      int fileSize = await imageFile.length();
      fileSize ~/= 1024; // Divisão inteira para obter o tamanho em KB
      log(fileSize.toString());
      setState(() {
        multipleImages.add({
          'file': imageFile,
          'size': fileSize,
        });
      });
    }
  }

  //uma foto só
  // List<File> imagensCapturadas = [];
  // void atualizarImagemCapturada(File imagem) {
  //   setState(() {
  //     imagensCapturadas.add(imagem);
  //   });
  // }

  List<Map<String, dynamic>> imagensCapturadas = [];
  void atualizarImagemCapturada(File imagem, int tamanhoKB) {
    setState(() {
      imagensCapturadas.add({
        'imagem': imagem,
        'tamanhoKB': tamanhoKB,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width * 0.65,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(50),
                color:
                    const Color(0xffC4C4C4).withOpacity(0.15).withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    onTap: () => multipleImagePicker(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate_outlined),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "abrir a galeria",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  InkWell(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CameraPage(
                          onImageCaptured: atualizarImagemCapturada,
                        ),
                      ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Câmera",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: imagensCapturadas.map((e) {
                File imagem = e['imagem'];
                int tamanhoKB = e['tamanhoKB'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.file(
                          imagem,
                          width: 60,
                          height: 75,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("imagem.jpg"),
                            Text(
                              "${tamanhoKB.toStringAsFixed(2).substring(0, 2)}/KB",
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              imagensCapturadas.remove(e);
                            });
                          },
                          child: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            Column(
                children: multipleImages.map(
              (e) {
                File imageFile = e['file'];
                int fileSize = e['size'];
                // if (fileSize > 5 && fileSize <= 100) {
                //condicao para estabelecer um tamanho da imagem
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.file(
                          imageFile,
                          width: 60,
                          height: 75,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("imagem.jpg"),
                            Text(
                                "${fileSize.toStringAsFixed(2).substring(0, 2)}/KB"),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              multipleImages.remove(e);
                            });
                          },
                          child: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
                // } else {
                //   return Text("A imagem não pode ser maior que 15kb");
                // }
              },
            ).toList()),
          ],
        ),
      ),
    );
  }
}
