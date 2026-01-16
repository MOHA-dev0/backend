import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/config_provider.dart';
import '../../core/services/subject_service.dart';
import 'package:unihub_app/src/core/constants/env_config.dart';
import '../widgets/subject_card.dart';
import '../widgets/wallet_card.dart';
import '../subject/subject_detail_screen.dart';
import '../wallet/wallet_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../settings/legal_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final SubjectService _subjectService = SubjectService();
  List<dynamic> _subjects = [];
  bool _isLoadingSubjects = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjects = await _subjectService.getSubjects();
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoadingSubjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSubjects = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final config = context.watch<ConfigProvider>().config;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          final configProvider = context.read<ConfigProvider>();
          final userProvider = context.read<UserProvider>();
          await Future.wait<void>([
            configProvider.loadConfig(),
            userProvider.refreshUser(),
          ]);
          _fetchSubjects();
        },
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // App Bar & Greeting
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رصيدك الحالي',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                user?.name ?? 'طالب',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          // Removed Avatar from Cart screen as it's less relevant here, or keep? Keeping for now but maybe minimize.
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Wallet Card
                      WalletCard(
                        balance: user?.balance ?? 0.0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'المواد المتاحة', // Available Subjects
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Subjects Grid
              _isLoadingSubjects
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : _subjects.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'لا توجد مواد متاحة حالياً',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final subject = _subjects[index];
                          String? imageUrl;
                          if (subject['image_url'] != null) {
                            if (subject['image_url'].toString().startsWith(
                              'http',
                            )) {
                              imageUrl = subject['image_url'];
                            } else {
                              imageUrl =
                                  '${EnvConfig.apiBaseUrl.replaceAll('/api', '')}/storage/${subject['image_url']}';
                            }
                          }

                          return SubjectCard(
                                title: subject['name'] ?? 'Subject',
                                code: subject['code'] ?? '',
                                imageUrl: imageUrl,
                                accessType: index.isEven ? 'gold' : 'none',
                                progress: 0.0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubjectDetailScreen(
                                        subjectId: subject['id'],
                                        title: subject['name'] ?? 'Detail',
                                      ),
                                    ),
                                  );
                                },
                              )
                              .animate(delay: (50 * index).ms)
                              .fadeIn()
                              .slideY(begin: 0.2);
                        }, childCount: _subjects.length),
                      ),
                    ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
