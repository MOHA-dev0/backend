import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unihub_app/src/core/services/subject_service.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentSliderIndex = 0;
  List<dynamic> _sliderAds = [];
  bool _isLoading = true;
  final SubjectService _subjectService = SubjectService();

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final ads = await _subjectService.getSliderAds();
      if (mounted) {
        setState(() {
          _sliderAds = ads;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEEF0), // Light Pink top
            Color(0xFFEBFDFD), // Light Cyan bottom match
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Ads Slider
                if (_isLoading)
                  const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_sliderAds.isEmpty)
                  // Placeholder if no ads
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(child: Text('No Ads Available')),
                  )
                else
                  _buildSlider(),

                const SizedBox(height: 24),

                // Services Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildServiceCard(
                        'طلب\nمطبوعاتي',
                        Icons.print_outlined,
                        const Color(0xFF00BCD4),
                      ), // Cyan
                      _buildServiceCard(
                        'حاسبة\nعلاماتي',
                        Icons.calculate_outlined,
                        const Color(0xFF2196F3),
                      ), // Blue
                      _buildServiceCard(
                        'الكتب\nالجامعي',
                        Icons.menu_book_outlined,
                        const Color(0xFF00BCD4),
                      ), // Cyan
                      _buildServiceCard('روابط\nمهمة', Icons.link, Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // University Title
                Center(
                  child: Text(
                    'الجامعة الافتراضية السورية',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900, // Extra Bold
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Academic Years Grid
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      _buildYearCard('السنة الأولى'),
                      _buildYearCard('السنة الثانية'),
                      _buildYearCard('السنة الثالثة'),
                      _buildYearCard('السنة الرابعة'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentSliderIndex = index;
              });
            },
          ),
          items: _sliderAds.map((ad) {
            String imageUrl = ad['image_url'] ?? '';
            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
              imageUrl =
                  '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/$imageUrl';
            }

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),

                        // Title Bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ad['title'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _sliderAds.asMap().entries.map((entry) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentSliderIndex == entry.key
                    ? const Color(0xFFCDC346) // Goldish active
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      width: 80,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearCard(String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDC346), // Accurate Gold/Olive color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
