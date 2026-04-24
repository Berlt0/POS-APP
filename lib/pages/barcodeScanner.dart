import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_app/utils/responsive.dart';

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

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        elevation: 3,
        toolbarHeight: isLandscape ? (isDesktop ? 50 : isTablet ? 40 : 35) : (isDesktop ? 70 : isTablet ? 60 : 50),
        title: Text("Scan Barcode",
         style: GoogleFonts.kameron(
              fontSize:  isLandscape ? (isDesktop ? 20 :isTablet ? 18 : 16) : (isDesktop ? 24 :isTablet ? 22 : 20),
              fontWeight: FontWeight.bold,)),
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
                  height: 100, 
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancel, 
                          style: ElevatedButton.styleFrom(
                            minimumSize: isLandscape 
                              ? (isDesktop ? Size(double.infinity, 48) : isTablet ? Size(double.infinity, 45) : Size(double.infinity, 40)) 
                              : (isDesktop ?  Size(double.infinity, 53) : isTablet ? Size(double.infinity, 50) : Size(double.infinity, 40)),
                            backgroundColor: Colors.red
                            ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.kameron(
                              fontSize: Responsive.font(context,mobile: 16, tablet: 18, desktop: 20),
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                            )
                            )),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: isLandscape 
                              ? (isDesktop ? Size(double.infinity, 48) : isTablet ? Size(double.infinity, 45) : Size(double.infinity, 40)) 
                              : (isDesktop ?  Size(double.infinity, 53) : isTablet ? Size(double.infinity, 50) : Size(double.infinity, 40)),
                          ),
                          onPressed: _save, 
                          child: Text("Save",
                          style: GoogleFonts.kameron(
                            fontSize: Responsive.font(context,mobile: 16, tablet: 18, desktop: 20),
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                          ),),
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