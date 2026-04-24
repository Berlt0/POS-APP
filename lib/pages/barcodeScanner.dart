import 'dart:async';
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

  bool _isProcessing = false;
  String? _lastCode;
  DateTime? _lastScanTime;
  List<String> scannedItems = [];
  final Map<String, int> sessionScanned = {};
  

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _shouldProcess(String code) {
    final now = DateTime.now();

    if (_lastCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(seconds: 1)) {
      return false;
    }

    _lastCode = code;
    _lastScanTime = now;
    return true;
  }

   void _save() {
    Navigator.pop(context, sessionScanned);
  }

  void _cancel() {
    Navigator.pop(context, null); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [ MobileScanner(
          controller: controller,
          onDetect: (BarcodeCapture capture) async {

              if (_isProcessing) return;
              if (capture.barcodes.isEmpty) return;

              final String? code = capture.barcodes.first.rawValue;
              if (code == null || code.isEmpty) return;
              if (!_shouldProcess(code)) return;

              _isProcessing = true;

              widget.onDetect(code); // adds to cart immediately

              setState(() {
                sessionScanned[code] = (sessionScanned[code] ?? 0) + 1;
              });

              await Future.delayed(const Duration(milliseconds: 500));
              _isProcessing = false;
          },
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child:
                SizedBox(
                  height: 50, 
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancel, 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text("Cancel")),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save, 
                          child: Text("Save"),
                        ),
                      ),
                    ],
                  ),
                )
          )
            ],
          )

          );
  }
}