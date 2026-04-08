import 'dart:async'; // Timer için eklendi
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task1/auth_service.dart';
import 'package:task1/ayarlar_sayfasi.dart';
import 'package:task1/bildirimler_sayfasi.dart';
import 'package:task1/favoriler_sayfasi.dart';
import 'package:task1/hakkimizda_sayfasi.dart';
import 'package:task1/iletisim_sayfasi.dart';
import 'package:task1/login_page.dart';
import 'package:task1/profil_sayfasi.dart';
import 'package:task1/sepet_Sayfasi.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AnaSayfa(),
  ));
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final Color gradientStart = const Color(0xFF560027);
  final Color gradientEnd = const Color(0xFFC2185B);

  // --- SLIDER (CAROUSEL) KONTROLCÜLERİ ---
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  // En Çok Satanlar Slider Verileri
  final List<Map<String, String>> _carouselItems = [
    {
      "image": "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "title": "En Çok Satanlar",
      "subtitle": "Koleksiyonu Keşfet"
    },
    {
      "image": "https://images.unsplash.com/photo-1524592094714-0f0654e20314?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "title": "Klasik Saatler",
      "subtitle": "Zamana Şıklık Katın"
    },
    {
      "image": "https://images.unsplash.com/photo-1591561954557-26941169b49e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "title": "Yeni Gelenler",
      "subtitle": "Sınırlı Stok Fırsatı"
    },
    {
      "image": "https://cdn.britannica.com/77/170477-050-1C747EE3/Laptop-computer.jpg",
      "title": "Teknoloji Fırsatları",
      "subtitle": "İşinize Güç Katın"
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  // Her 3 saniyede bir otomatik kaydırma fonksiyonu
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _carouselItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Sona gelince başa dön
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Bellek sızıntısını önlemek için timer'ı iptal et
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: AuthService().getProfile(),
                    builder: (context, snapshot) {
                      String name = "Misafir";
                      String email = "misafir@ornek.com";
                      String? base64Image;

                      if (snapshot.hasData && snapshot.data != null) {
                        name = snapshot.data!['fullName'] ?? "Kullanıcı";
                        email = snapshot.data!['email'] ?? "";
                        base64Image = snapshot.data!['profileImage'];
                      }

                      ImageProvider? imageProvider;
                      if (base64Image != null && base64Image.isNotEmpty) {
                        try {
                          imageProvider = MemoryImage(base64Decode(base64Image));
                        } catch (e) {
                          imageProvider = null;
                        }
                      }

                      return DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [gradientStart, gradientEnd],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: imageProvider,
                                  child: (imageProvider == null)
                                      ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                                      : null,
                                ),
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  ListTile(
                    leading: _buildIconsColor(Icons.store, "Tüm Kategoriler"),
                    title: const Text('Tüm Kategoriler'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SepetSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.shopping_cart, "Sepet"),
                    title: const Text('Sepet'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SepetSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.favorite, "Favoriler"),
                    title: const Text('Favoriler'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavorilerSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.notifications, "Bildirimler"),
                    title: const Text('Bildirimler'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BildirimlerSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.person, "Profil"),
                    title: const Text('Profil'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.info, "Hakkımızda"),
                    title: const Text('Hakkımızda'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HakkimizdaSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading: _buildIconsColor(Icons.help, "Yardım ve Destek"),
                    title: const Text('Yardım ve Destek'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const IletisimSayfasi()),
                      );
                    },
                  ),
                  ListTile(
                    leading:_buildIconsColor(Icons.settings, "Ayarlar"),
                    title: const Text('Ayarlar'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AyarlarSayfasi()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading:_buildIconsColor(Icons.exit_to_app,"Çıkış Yap"),
              title: const Text("Çıkış Yap"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [gradientStart, gradientEnd],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      Image.asset(
                        'assets/beyaz_yazisiz_logo_arkaplansiz.png',
                        width: 80,
                        height: 80,
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SepetSayfasi()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // HOŞ GELDİN YAZISI (BACKEND)
                FutureBuilder<Map<String, dynamic>?>(
                  future: AuthService().getProfile(),
                  builder: (context, snapshot) {
                    String isim = "Misafir";

                    if (snapshot.hasData && snapshot.data != null) {
                      String fullName = snapshot.data!['fullName'] ?? "Kullanıcı";
                      isim = fullName;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            text: 'Hoş Geldin, ',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                            children: [
                              TextSpan(
                                text: isim,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ARAMA ÇUBUĞU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ürün ara...",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white60),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- OTOMATİK KAYAN SLIDER (CAROUSEL) ALANI ---
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 150,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _carouselItems.length,
                          itemBuilder: (context, index) {
                            return _buildCarouselItem(_carouselItems[index]);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dinamik Nokta Göstergeleri (Dots Indicator)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _carouselItems.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha:0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // KATEGORİLER VE ÜRÜNLER KISMI
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCategoryItem(Icons.shopping_bag, "Giyim"),
                            _buildCategoryItem(Icons.menu_book, "Kırtasiye"),
                            _buildCategoryItem(Icons.computer, "Elektronik"),
                            _buildCategoryItem(Icons.diamond, "Aksesuar"),
                          ],
                        ),
                        const SizedBox(height: 20),

                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGET: SLIDER ELEMANI ---
  Widget _buildCarouselItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5), // Resimler arasına hafif boşluk
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(item["image"]!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha:0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["title"]!,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              item["subtitle"]!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconsColor(IconData icon, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [gradientStart, gradientEnd],
            ).createShader(bounds);
          },
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFFCE4EC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: gradientEnd),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border, color: gradientEnd, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String title;
  final String price;
  final String imageUrl;

  Product({required this.title, required this.price, required this.imageUrl});
}

// Örnek Veri
List<Product> products = [
  Product(
    title: "MonsterXXL PC",
    price: "₺ 1,231",
    imageUrl: "https://cdn.britannica.com/77/170477-050-1C747EE3/Laptop-computer.jpg",
  ),
  Product(
    title: "Aurora Çanta",
    price: "₺ 2,450",
    imageUrl: "https://images.unsplash.com/photo-1591561954557-26941169b49e?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60",
  ),
  Product(
    title: "Klasik Saat",
    price: "₺ 1,400",
    imageUrl: "https://images.unsplash.com/photo-1524592094714-0f0654e20314?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60",
  ),
  Product(
    title: "Deri Çanta",
    price: "₺ 3,100",
    imageUrl: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60",
  ),
];