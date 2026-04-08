import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task1/auth_service.dart';

class ProfilDuzenle extends StatefulWidget {
  const ProfilDuzenle({Key? key}) : super(key: key);

  @override
  State<ProfilDuzenle> createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  // Servis ve Araçlar
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Renkler
  final Color gradientStart = const Color(0xFFC2185B);
  final Color gradientEnd = const Color(0xFF880E4F);

  // Form Kontrolcüleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Durum Değişkenleri
  File? _selectedImage;
  String? _currentBase64Image;
  bool _isPasswordVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // --- 1. MEVCUT VERİLERİ ÇEKME ---
  Future<void> _loadCurrentData() async {
    final data = await _authService.getProfile();

    if (mounted) {
      setState(() {
        if (data != null) {
          _nameController.text = data['fullName'] ?? "";
          _emailController.text = data['email'] ?? "";
          _phoneController.text = data['phone'] ?? "";
          _currentBase64Image = data['profileImage'];
        }
        _isLoading = false;
      });
    }
  }

  // --- 2. FOTOĞRAF SEÇME (Kamera veya Galeri) ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Fotoğraf seçimi hatası: $e");
    }
  }

  // --- 3. BOTTOM SHEET İLE FOTOĞRAF KAYNAĞI SEÇTİRME ---
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Profil Fotoğrafı Ekle",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gradientStart.withOpacity(0.1),
                    child: Icon(Icons.camera_alt, color: gradientStart),
                  ),
                  title: const Text("Fotoğraf Çek"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera); // Kamerayı aç
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gradientStart.withOpacity(0.1),
                    child: Icon(Icons.photo_library, color: gradientStart),
                  ),
                  title: const Text("Galeriden Seç"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery); // Galeriyi aç
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 4. VERİLERİ KAYDETME ---
  Future<void> _saveData() async {
    if (_isLoading) return;

    setState(() { _isLoading = true; });

    String? base64ImageToSend;
    if (_selectedImage != null) {
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      base64ImageToSend = base64Encode(imageBytes);
    }

    bool success = await _authService.updateProfile(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      base64Image: base64ImageToSend,
    );

    if (mounted) {
      setState(() { _isLoading = false; });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil başarıyla güncellendi!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Güncelleme sırasında bir hata oluştu.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _nameController.text.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Profili Düzenle", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Gradient Header
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [gradientStart, gradientEnd],
            ),
          ),
        ),
        // Modern Custom Geri Dönüş Butonu
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Cam (Frosted) efekti
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- PROFİL FOTOĞRAFI ALANI ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.grey[300],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _getImageWidget(),
                    ),
                  ),
                  // Kamera İkonu (Tıklanınca menü açar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceBottomSheet, // Galeri/Kamera seçimi
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gradientStart,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: gradientStart.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- FORM ALANLARI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: "Ad Soyad",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _emailController,
                    label: "E-Posta",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _phoneController,
                    label: "Telefon Numarası",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _passwordController,
                    label: "Yeni Şifre (Opsiyonel)",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- KAYDET BUTONU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientStart.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _saveData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Değişiklikleri Kaydet",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI: Hangi Resim Gösterilecek? ---
  Widget _getImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (_currentBase64Image != null && _currentBase64Image!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_currentBase64Image!),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
        );
      } catch (e) {
        return _defaultAvatar();
      }
    } else {
      return _defaultAvatar();
    }
  }

  Widget _defaultAvatar() {
    return Icon(
      Icons.person,
      size: 80,
      color: Colors.grey[500],
    );
  }

  // --- YARDIMCI: TextField Tasarımı ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [gradientStart, gradientEnd],
              ).createShader(bounds);
            },
            child: Icon(icon, color: Colors.white),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}