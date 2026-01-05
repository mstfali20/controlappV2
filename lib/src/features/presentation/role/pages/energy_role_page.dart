import 'dart:developer';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/scale_button.dart';
import 'package:controlapp/src/features/energy/presentation/pages/electricity_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/overview_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/carbon_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/gas_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/ges_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/steam_screen.dart';
import 'package:controlapp/src/features/energy/presentation/pages/water_screen.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:controlapp/src/features/auth/domain/usecases/get_session_usecase.dart';

import 'package:controlapp/data/tree_node.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class EnerjiWidget extends StatefulWidget {
  const EnerjiWidget({super.key});

  @override
  State<EnerjiWidget> createState() => _EnerjiWidgetState();
}

class _EnerjiWidgetState extends State<EnerjiWidget> {
  List<TreeNode> nodes = [];
  TreeNode? nodesName;
  TreeNode? organizizasyom;

  // Veriler
  String? totalTuketimId;
  String? buharTuketimId;
  String? suTuketimId;
  String? dogalgazTuketimId;
  String? dogalgazDeviceId;
  String? uretimId;
  String? gesId;
  String? gesfarkId;
  String? energyId;

  // UI Durum Değişkenleri
  int selectedCategoryIndex = 0;
  int selectedPeriodIndex = 0;
  int periodIndex = 3; // Varsayılan period (örneğin günlük veri)
  String termIndex = '0'; // Varsayılan periyot term

  List<String> categories = [];
  bool isLoading = true; // Yüklenme durumu

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      log("Veriler yükleniyor...");
      await _loadData();
      log("Veriler yüklendi!");

      // Kategorileri oluştur
      _generateCategories();

      // Yüklenme durumunu tamamla
      setState(() {
        isLoading = false;
      });
    } catch (e, stacktrace) {
      log("Hata oluştu: $e\n$stacktrace");
      setState(() {
        isLoading = false; // Hata olsa bile yüklenme durumu tamamlanır
      });
    }
  }

  Future<void> _loadData() async {
    try {
      // Tree verilerini yükle
      nodes = await _loadAndParseTree();

      final firmName = (userDataConst["firm_name"]?.toString() ?? '').trim();
      // "TanTekstil" düğümünü bul
      nodesName = nodes.firstWhere(
        (node) => node.caption.trim() == firmName,
        orElse: () => TreeNode.empty(),
      );

      if (nodesName == TreeNode.empty()) {
        throw Exception("Düğümü bulunamadı.");
      }

      // "Enerji İzleme Sistemi" düğümünü bul
      organizizasyom = nodesName!.children.firstWhere(
        (childNode) => childNode.caption.trim() == enerjiIzlem,
        orElse: () => TreeNode.empty(),
      );

      if (organizizasyom == TreeNode.empty()) {
        throw Exception("Enerji İzleme Sistemi düğümü bulunamadı.");
      }

      // Organizasyon düğümünü işle
      _parseOrganization(organizizasyom!);
    } catch (e) {
      log("Tree verisi yüklenirken hata oluştu: $e");
      rethrow; // Hata üst katmana iletilir
    }
  }

  Future<List<TreeNode>> _loadAndParseTree() async {
    try {
      var source = treeJson;
      if (source.trim().isEmpty) {
        final getSession = getIt<GetSessionUseCase>();
        final session = await getSession();
        var cached = session?.treeJson ?? '';
        if (cached.isEmpty) {
          final username = session?.username ?? users;
          final password = session?.password ?? pass;
          if (username.isNotEmpty && password.isNotEmpty) {
            await OrganizationService().fetchOrganizations(username, password);
            cached = treeJson;
          }
        }
        if (cached.isNotEmpty) {
          treeJson = cached;
          source = cached;
        }
      }
      return TreeNode.parseTreeNodes(source);
    } catch (e) {
      log("Tree parse hatası: $e");
      throw Exception("Tree verisi parse edilemedi.");
    }
  }

  void _parseOrganization(TreeNode organizationNode) {
    for (var child in organizationNode.children) {
      final normalizedCaption = child.caption.trim();
      final normalizedClass = child.classType.trim();
      if (normalizedClass == 'obm_organization') {
        _parseOrganization(child); // Alt organizasyonları gez
      }

      if (normalizedClass == 'obm_device') {
        switch (normalizedCaption) {
          case 'Fabrika Toplam Tüketim':
            totalTuketimId = child.id;
            break;
          // case 'BUHAR SAYACI':
          //   buharTuketimId = child.id;
          //   break;
          case 'GES Toplam':
            uretimId = child.id;
            break;
          // case 'Su':
          //   suTuketimId = child.id;
          //   break;

          case 'GES Üretim Tüketim Farkı':
            gesfarkId = child.id;
            break;
        }
      } else if (normalizedClass == 'obm_organization' &&
          normalizedCaption == 'Doğalgaz') {
        dogalgazTuketimId = child.id;
        dogalgazDeviceId ??= _findFirstDevice(child);
      } else if (normalizedClass == 'obm_organization' &&
          normalizedCaption == 'GES') {
        gesId = child.id;
      } else if (normalizedClass == 'obm_organization' &&
          normalizedCaption == 'Su') {
        suTuketimId = child.id;
      } else if (normalizedClass == 'obm_organization' &&
          normalizedCaption == 'Buhar') {
        buharTuketimId = child.id;
      } else if (normalizedClass == 'obm_organization' &&
          normalizedCaption == 'Elektrik Ana Tüketim') {
        energyId = child.id;
      }
    }
  }

  void _generateCategories() {
    categories.clear();
    if (totalTuketimId != null) {
      categories.add(AppLocalizations.of(context)!.ozet);
    }
    if (energyId != null) {
      categories.add(AppLocalizations.of(context)!.elektrik);
    }

    if (uretimId != null) {
      categories.add(AppLocalizations.of(context)!.ges);
    }
    if (gesfarkId != null) {
      categories.add(AppLocalizations.of(context)!.karbon);
    }
    if (suTuketimId != null) {
      categories.add(AppLocalizations.of(context)!.su);
    }
    if (buharTuketimId != null) {
      categories.add(AppLocalizations.of(context)!.buhar);
    }
    if (dogalgazTuketimId != null) {
      categories.add(AppLocalizations.of(context)!.dogalGaz);
    }
  }

  Widget _buildSelectedWidget() {
    if (categories.isEmpty) {
      return const Center(child: Text('Kategori Bulunamadı.'));
    }

    switch (selectedCategoryIndex) {
      case 0:
        return OverviewScreen(
          key: UniqueKey(),
          totalTuketimId: totalTuketimId,
          buharTuketimId: buharTuketimId,
          suTuketimId: suTuketimId,
          dogalgazTuketimId: dogalgazTuketimId,
          uretimTuketimId: uretimId,
          gesfark: gesfarkId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 1:
        return EnergyScren(
          key: UniqueKey(),
          energyId: energyId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 2:
        return GesScren(
          key: UniqueKey(),
          totalTuketimId: totalTuketimId,
          uretimTuketimId: uretimId,
          gesfark: gesfarkId,
          gesid: gesId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 3:
        return KarbonScren(
          key: UniqueKey(),
          totalTuketimId: totalTuketimId,
          uretimTuketimId: uretimId,
          dogalgazDeviceId: dogalgazDeviceId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 4:
        return SuScren(
          key: UniqueKey(),
          suid: suTuketimId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 5:
        return BuharScren(
          key: UniqueKey(),
          buharid: buharTuketimId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );
      case 6:
        return DogalgazScren(
          key: UniqueKey(),
          dogalgazid: dogalgazTuketimId,
          periodIndex: periodIndex.toString(),
          termIndex: termIndex,
        );

      default:
        return const Text('Kategori Seçimi Yapılmadı');
    }
  }

  String? _findFirstDevice(TreeNode node) {
    for (final child in node.children) {
      if (child.classType.trim() == 'obm_device' && child.id.isNotEmpty) {
        return child.id;
      }
      final nested = _findFirstDevice(child);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> periods = [
      AppLocalizations.of(context)!.buAy,
      AppLocalizations.of(context)!.gecenAy,
    ];
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: contolblue));
    }

    return Column(
      children: [
        // Kategori Seçimleri
        FadeInAnimation(
          delay: 1.1,
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ListView.separated(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = selectedCategoryIndex == index;
                return ScaleButton(
                  onTap: () => setState(() => selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? contolblue : Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkColor,
                          fontSize: 18.h,
                        ),
                        child: Text(categories[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Periyot Seçimleri
        FadeInAnimation(
          delay: 1.1,
          child: SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ListView.separated(
              itemCount: periods.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = selectedPeriodIndex == index;
                return ScaleButton(
                  onTap: () {
                    setState(() {
                      selectedPeriodIndex = index;
                      termIndex = index == 0
                          ? '0'
                          : '1'; // Seçime göre termIndex değişiyor
                      log('selectedPeriodIndex: $selectedPeriodIndex, termIndex: $termIndex');
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? contolblue : Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkColor,
                          fontSize: 18.h,
                        ),
                        child: Text(periods[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 20.h),
        // İçerik
        FadeInAnimation(
          delay: 1.1,
          child: Container(
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: _buildSelectedWidget(),
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 100.h),
      ],
    );
  }
}
