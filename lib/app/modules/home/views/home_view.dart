import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/core/const/asset_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';
import 'package:sumberkerto_smart_village/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColorsConst.neutral50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: TColorsConst.blue500,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(TAssetsConst.bgMaps, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TColorsConst.blue600.withOpacity(0.7),
                          TColorsConst.blue500.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: TColorsConst.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  PhosphorIcons.buildings(
                                    PhosphorIconsStyle.bold,
                                  ),
                                  color: TColorsConst.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dashboard Desa',
                                      style: TGoogleTextStyleConst.inter14Medium
                                          .copyWith(
                                            color: TColorsConst.white
                                                .withOpacity(0.9),
                                          ),
                                    ),
                                    Text(
                                      'Sumberkerto Smart Village',
                                      style: TGoogleTextStyleConst
                                          .inter18SemiBold
                                          .copyWith(color: TColorsConst.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: TColorsConst.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: TColorsConst.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: TColorsConst.white.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      PhosphorIcons.users(
                                        PhosphorIconsStyle.bold,
                                      ),
                                      color: TColorsConst.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Penduduk',
                                          style: TGoogleTextStyleConst
                                              .inter12Regular
                                              .copyWith(
                                                color: TColorsConst.white
                                                    .withOpacity(0.85),
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${controller.totalPenduduk.value}',
                                          style: TGoogleTextStyleConst
                                              .inter24SemiBold
                                              .copyWith(
                                                color: TColorsConst.white,
                                                height: 1.2,
                                              ),
                                        ),
                                        Text(
                                          'Warga Terdaftar',
                                          style: TGoogleTextStyleConst
                                              .inter10Regular
                                              .copyWith(
                                                color: TColorsConst.white
                                                    .withOpacity(0.75),
                                              ),
                                        ),
                                      ],
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    'Layanan Desa',
                    style: TGoogleTextStyleConst.inter16SemiBold.copyWith(
                      color: TColorsConst.neutral800,
                    ),
                  ),
                ),
                _buildServiceList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    final services = [
      {
        'title': 'Pemetaan Wilayah',
        'subtitle': 'Peta sawah, lahan, dan wilayah desa',
        'image': TAssetsConst.iconPemetaan,
        'bgColor': const Color.fromARGB(255, 255, 255, 255),
      },
      {
        'title': 'Data Penduduk',
        'subtitle': 'NIK, KK, RT/RW, status warga',
        'image': TAssetsConst.iconPenduduk,
        'bgColor': const Color.fromARGB(255, 255, 255, 255),
      },
      {
        'title': 'Data Pertanian',
        'subtitle': 'Luas sawah, panen padi, pupuk',
        'image': TAssetsConst.iconPertanian,
        'bgColor': const Color.fromARGB(255, 255, 255, 255),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(
          title: service['title'] as String,
          subtitle: service['subtitle'] as String,
          imagePath: service['image'] as String,
          bgColor: service['bgColor'] as Color,
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColorsConst.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColorsConst.neutral300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (title == 'Pemetaan Wilayah') {
              Get.toNamed(Routes.PEMETAAN);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TGoogleTextStyleConst.inter14SemiBold.copyWith(
                          color: TColorsConst.neutral800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TGoogleTextStyleConst.inter12Regular.copyWith(
                          color: TColorsConst.neutral500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  color: TColorsConst.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
