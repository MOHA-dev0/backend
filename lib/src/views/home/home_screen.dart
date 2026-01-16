import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unihub_app/src/core/services/subject_service.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/custom_cache_manager.dart';
import '../../core/providers/user_provider.dart';
import '../chat/chat_screen.dart';
import '../links/important_links_screen.dart';
import '../calculator/grade_calculator_screen.dart';
import '../subject/year_content_screen.dart';
import '../../core/helpers/url_helper.dart';
import '../subject/academic_years_screen.dart';
import '../../core/utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSliderIndex = 0;
  List<dynamic> _sliderAds = [];
  bool _isLoading = true;
  final SubjectService _subjectService = SubjectService();

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  int? _lastUniversityId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<UserProvider>().user;
    if (user != null && user.universityId != _lastUniversityId) {
      _lastUniversityId = user.universityId;
      _fetchAds();
    }
  }

  Future<void> _fetchAds() async {
    // Only refetch if not initially loading or if triggered by change
    // _isLoading is true on init
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh Ads
            await _fetchAds();
            // Refresh User Data (University settings, years, etc.)
            if (mounted) {
              await context.read<UserProvider>().refreshUser();
            }
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if content is short
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // ... (rest of the children unchanged, but we are just wrapping the ScrollView)
                // Wait, I need to match the indentation and structure.
                // The replace block should cover the specific lines.
                // Simpler: Just wrap the SingleChildScrollView or its child?
                // RefreshIndicator works best on Scrollable.

                // Custom Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Chat Icon (Left)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: AppColors.primary, // Cyan/Blue
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const Spacer(),

                      // Welcome Text + User Name (Center/Right)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'مرحباً بك',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Verified Icon (if verified)
                              if (context
                                      .watch<UserProvider>()
                                      .user
                                      ?.isVerified ??
                                  false)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.blue, // Verified Color
                                    size: 20,
                                  ),
                                ),
                              Text(
                                context.watch<UserProvider>().user?.name ??
                                    'طالب',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Logo (Right)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

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
                        AppColors.primary,
                      ), // Cyan
                      // Conditionally Show Grade Calculator
                      if (context
                              .watch<UserProvider>()
                              .user
                              ?.universityHasCalculator ??
                          true)
                        _buildServiceCard(
                          'حاسبة\nعلاماتي',
                          Icons.calculate_outlined,
                          AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GradeCalculatorScreen(),
                              ),
                            );
                          },
                        ), // Blue

                      _buildServiceCard(
                        'الكتب\nالجامعي',
                        Icons.menu_book_outlined,
                        AppColors.primary,
                      ), // Cyan
                      _buildServiceCard(
                        'روابط\nمهمة',
                        Icons.link,
                        Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ImportantLinksScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // University Title
                Center(
                  child: Text(
                    context.watch<UserProvider>().user?.universityName ?? '',
                    textAlign: TextAlign.center,
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
                  child: Builder(
                    builder: (context) {
                      final int count =
                          context
                              .watch<UserProvider>()
                              .user
                              ?.universityYearsCount ??
                          4;
                      final List<String> yearNames = [
                        'السنة الأولى',
                        'السنة الثانية',
                        'السنة الثالثة',
                        'السنة الرابعة',
                        'السنة الخامسة',
                        'السنة السادسة',
                        'السنة السابعة',
                      ];

                      final displayCount = (count > 7) ? 7 : count;
                      final items = List.generate(
                        displayCount,
                        (index) => yearNames[index],
                      );

                      // If 4 or fewer, keep the 2-column Grid
                      if (displayCount <= 4) {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: items
                              .map((title) => _buildYearCard(title))
                              .toList(),
                        );
                      }

                      // If 5 or more, use the "Pie" / Cluster Layout (Wrap Centered)
                      // Calculate width to fit 3 items roughly
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Available width minus spacing?
                          // If we want 3 items, item width approx (width - 2*spacing) / 3
                          final double spacing = 12.0;
                          final double itemWidth =
                              (constraints.maxWidth - (2 * spacing)) / 3 -
                              1; // -1 for safety

                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: spacing,
                            runSpacing: spacing,
                            children: items.map((title) {
                              return SizedBox(
                                width: itemWidth,
                                height:
                                    itemWidth * 0.8, // Aspect ratio approx 1.25
                                child: _buildYearCard(title, isSmall: true),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
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
            // If relative path, prepend base url + /media
            // If relative path, prepend base url + /media
            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
              // API Base is .../api. We want .../media/filename
              // EnvConfig.apiBaseUrl gives http://10.0.2.2:8000/api (on android)
              // So we strip /api and add /media/
              imageUrl =
                  '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/cors-storage/$imageUrl';
            }

            // Fix 127.0.0.1 -> 10.0.2.2 if needed (for full URLs returned by backend)
            imageUrl = UrlHelper.fixUrl(imageUrl);

            return GestureDetector(
              onTap: () async {
                final link = ad['link'];
                if (link != null && link.toString().isNotEmpty) {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
              },
              child: Builder(
                builder: (BuildContext context) {
                  // debugPrint('DEBUG: Loading Ad Image: $imageUrl');
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
                            CachedNetworkImage(
                              cacheManager: CustomCacheManager.instance,
                              imageUrl: imageUrl,
                              fit: BoxFit.fill, // Fill the container
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) {
                                debugPrint(
                                  'DEBUG: Image Load Error: $error for URL: $url',
                                );
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
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
              ),
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
                    ? AppColors
                          .secondary // Goldish active
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }

  Widget _buildYearCard(String title, {bool isSmall = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AcademicYearsScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary, // Accurate Gold/Olive color
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
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: isSmall ? 13 : 18, // Smaller font for grid of 3
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
