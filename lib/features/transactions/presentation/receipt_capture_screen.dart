import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';

class ReceiptScanResult {
  final double amount;
  final String merchant;
  final TransactionCategoryType category;
  final String? imagePath;

  const ReceiptScanResult({
    required this.amount,
    required this.merchant,
    required this.category,
    this.imagePath,
  });
}

class ReceiptCaptureScreen extends StatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isAutoMode = true;
  bool _isAnalyzing = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      // If camera unavailable (e.g. emulator, permissions, or desktop without webcam),
      // we gracefully fall back to the simulated viewfinder view.
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    if (_cameraController != null && _isCameraInitialized) {
      try {
        await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      } catch (e) {
        debugPrint('Flash toggle error: $e');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _processReceipt(imagePath: image.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access gallery: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _capturePhoto() async {
    String? path;
    if (_cameraController != null && _isCameraInitialized) {
      try {
        final XFile file = await _cameraController!.takePicture();
        path = file.path;
      } catch (e) {
        debugPrint('Error taking picture: $e');
      }
    }

    _processReceipt(imagePath: path);
  }

  void _processReceipt({String? imagePath}) async {
    setState(() => _isAnalyzing = true);

    // Simulate AI extraction delay for OCR processing
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Extracted receipt metadata matching Pizza Hut Sri Lanka receipt mockup
    final result = ReceiptScanResult(
      amount: 3150.00,
      merchant: 'Pizza Hut Sri Lanka (Colombo)',
      category: TransactionCategoryType.dining,
      imagePath: imagePath,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'Scan Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Auto Badge Toggle
                  GestureDetector(
                    onTap: () => setState(() => _isAutoMode = !_isAutoMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _isAutoMode
                            ? const Color(0xFF192A13)
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isAutoMode
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: _isAutoMode ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Auto',
                            style: TextStyle(
                              color: _isAutoMode ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Viewfinder Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF12151D),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.darkBorder, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera Preview or Fallback Receipt Mockup
                      if (_isCameraInitialized && _cameraController != null)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize?.height ?? 1,
                              height: _cameraController!.value.previewSize?.width ?? 1,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        )
                      else
                        _buildReceiptMockupView(),

                      // Four Vibrant Green Corner Guides
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: CustomPaint(
                            painter: _ReceiptCornersPainter(),
                          ),
                        ),
                      ),

                      // Status Pill: "● Hold steady • Scanning..."
                      Positioned(
                        bottom: 22,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isAnalyzing
                                    ? 'Analyzing...'
                                    : 'Hold steady • Scanning...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction Heading & Subtitle
            const Text(
              'Align all 4 corners of receipt inside box',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Amount, merchant & date will be extracted automatically',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 28),

            // Bottom Shutter & Controls Row (Gallery, Capture, Flash)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1E29),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkBorder, width: 1.2),
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Concentric Shutter Capture Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 78,
                          height: 78,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF0C0F14),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Capture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Flash Toggle Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1E29),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isFlashOn
                                  ? AppColors.primary
                                  : AppColors.darkBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: _isFlashOn ? AppColors.primary : Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isFlashOn ? 'Flash ON' : 'Flash OFF',
                        style: TextStyle(
                          color: _isFlashOn ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Simulated live receipt preview when device webcam is not accessible
  Widget _buildReceiptMockupView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0E1118),
      alignment: Alignment.center,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'PIZZA HUT SRI LANKA',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'COLOMBO 03 • TEL: 011 272 9729',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _buildReceiptRow('1x Large Pan Pizza', '2,450.00'),
            const SizedBox(height: 4),
            _buildReceiptRow('1x Garlic Bread Sticks', '450.00'),
            const SizedBox(height: 4),
            _buildReceiptRow('1x Pepsi 400ml', '250.00'),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'TOTAL LKR',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '3,150.00',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Barcode graphic
            Container(
              height: 24,
              width: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              child: CustomPaint(painter: _BarcodePainter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 4 bright lime-green framing corner brackets
class _ReceiptCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0;
    const radius = 10.0;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for barcode lines on receipt
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeCap = StrokeCap.square;

    const barCount = 38;
    final step = size.width / barCount;

    for (var i = 0; i < barCount; i++) {
      if (i % 7 == 3 || i % 11 == 5) continue; // gaps
      final isThick = (i % 4 == 0) || (i % 5 == 0);
      paint.strokeWidth = isThick ? 3.0 : 1.5;
      final x = i * step;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
