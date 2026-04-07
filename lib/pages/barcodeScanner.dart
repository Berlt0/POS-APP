import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  final Function(String) onDetect;
  
  const BarcodeScannerPage({super.key, required this.onDetect});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {


  final MobileScannerController controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,                   
      formats: [
        BarcodeFormat.code128,
        BarcodeFormat.ean13,     
        BarcodeFormat.upcA,     
        BarcodeFormat.code39,
        BarcodeFormat.ean8,
      ],
      returnImage: false,
      torchEnabled: false,
      autoZoom: true,
      facing: CameraFacing.back,
    );

    bool _isDetected = false;

    @override
    void dispose() {
      controller.dispose();       
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on), // static icon
            onPressed: () {
              controller.toggleTorch(); // toggle torch
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) {

          if (_isDetected) return;
          if (capture.barcodes.isEmpty) return;

          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;

            if (code == null || code.isEmpty) return;

          _isDetected = true;                

          widget.onDetect(code);
          Navigator.pop(context);
          }
        },
      ),
    );
  }
}