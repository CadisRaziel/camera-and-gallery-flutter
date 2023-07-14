import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  final Function(File, int fileSize)? onImageCaptured;

  const CameraPage({Key? key, this.onImageCaptured}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  Size? size;
  List<XFile>? imagens;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  _loadCameras() async {
    try {
      cameras = await availableCameras();
      _startCamera();
    } on CameraException catch (e) {
      debugPrint(e.description);
    }
  }

  _startCamera() {
    if (cameras.isEmpty) {
      debugPrint('Câmera não foi encontrada');
    } else {
      _previewCamera(cameras.first);
    }
  }

  _previewCamera(CameraDescription camera) async {
    final CameraController cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint(e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context)
        .size; //vai dar um tamanho a tela de mostrar a camera ou imagem, sem isso da erro
    return Scaffold(
      body: Container(
        color: Colors.grey[900],
        child: Center(
          child: _arquivoWidget(),
        ),
      ),
      floatingActionButton: (imagens != null && imagens!.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context),
              label: const Text('Tirar foto'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //constroe o widget que vai mostrar a a camera ou a imagem tirada
  _arquivoWidget() {
    return SizedBox(
      width: size!.width - 50,
      height: size!.height - (size!.height / 4),
      child: imagens == null || imagens!.isEmpty
          ? _cameraPreviewWidget()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagens!.length,
              itemBuilder: (context, index) {
                return Image.file(
                  File(imagens![index].path),
                  fit: BoxFit.contain,
                );
              },
            ),
    );
  }

  _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          CameraPreview(controller!),
          _botaoCapturaWidget(),
        ],
      );
    }
  }

  _botaoCapturaWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          icon: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 30,
          ),
          onPressed: tirarFoto,
        ),
      ),
    );
  }

  //uma foto só
  // tirarFoto() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController != null && cameraController.value.isInitialized) {
  //     try {
  //       XFile file = await cameraController.takePicture();
  //       if (mounted) {
  //         setState(() => imagens ??= []);
  //         setState(() => imagens!.add(file));
  //         if (widget.onImageCaptured != null) {
  //           widget.onImageCaptured!(File(file.path));
  //         }
  //       }
  //     } on CameraException catch (e) {
  //       debugPrint(e.description);
  //     }
  //   }
  // }

  //multiplas imagens
  tirarFoto() async {
    final CameraController? cameraController = controller;

    if (cameraController != null && cameraController.value.isInitialized) {
      try {
        XFile file = await cameraController.takePicture();
        if (mounted) {
          File imageFile = File(file.path);
          int fileSize = await imageFile.length();
          // fileSize = (fileSize / 1024).round(); // Conversão para KB
          fileSize ~/= 1024; // Divisão inteira para obter o tamanho em KB
          log(fileSize.toString());
          setState(() {
            imagens ??= [];
            imagens!.add(file);
          });

          if (widget.onImageCaptured != null) {
            widget.onImageCaptured!(imageFile, fileSize);
          }
        }
      } on CameraException catch (e) {
        debugPrint(e.description);
      }
    }
  }
}
