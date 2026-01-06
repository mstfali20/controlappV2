import 'dart:developer';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/core/config/tree_sections.dart';
import 'package:controlapp/src/core/utils/tree_selection.dart';
import 'package:controlapp/src/features/presentation/navigation/pages/navigation_page.dart';
import 'package:controlapp/src/features/presentation/register_page.dart';
import 'package:controlapp/widget/square_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:controlapp/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../enerji_izleme/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import '../../../yardimci_tesisler/climate/domain/usecases/fetch_climate_snapshot_usecase.dart';
import '../view_model/auth_cubit.dart';
import '../view_model/auth_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        loginUseCase: getIt(),
        saveSessionUseCase: getIt(),
        logger: getIt(),
      ),
      child: const _LoginViewContent(),
    );
  }
}

class _LoginViewContent extends StatefulWidget {
  const _LoginViewContent();

  @override
  State<_LoginViewContent> createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<_LoginViewContent> {
  TextEditingController userNameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  Color tcnoTextColor = black;
  double tcnoTextSize = 12.h;
  bool passwordIsObsecure = true;
  bool rememberMe = true;
  Future<void> lancurl(String gelurl) async {
    try {
      final Uri uri = Uri.parse(
          gelurl); // URL'yi düzgün bir şekilde ayrıştırmak için parse() kullanılıyor.
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print("URL successfully launched");
      } else {
        throw "Failed to launch URL";
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error!),
              ),
            );
          context.read<AuthCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Başlangıç ve bitiş renkleri
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 10),

                Padding(
                  padding: EdgeInsets.all(10.0.h),
                  child: Image.asset(
                    'assets/ControlAppSiyah.png',
                    height: 150.h,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.hosgeldiniz,
                    style: TextStyle(
                      color: black,
                      fontSize: 20.h,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 40.h),
                  child: Column(
                    children: [
                      buildTextField(
                        labelText: AppLocalizations.of(context)!.kullaniciAdi,
                        controller: userNameTextController,
                        keyboardType: TextInputType.text,
                        maxLength: 20,
                        isPassword: false,
                      ),
                      buildTextField(
                        labelText: AppLocalizations.of(context)!.sifre,
                        controller: passwordTextController,
                        keyboardType: TextInputType.text,
                        maxLength: 12,
                        isPassword: true,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width / 9,
                      bottom: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          buildRememberMeCheckbox(),
                          SizedBox(width: 10.h),
                          Text(
                            AppLocalizations.of(context)!.bilgileriKaydet,
                            style: TextStyle(
                              fontSize: 14.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildLoginButton(),
                SizedBox(height: 10.h),
                buildDemoButton(),

                SizedBox(height: 20.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.sosyalMedya,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // google + apple sign in buttons  https://www.linkedin.com/company/yarbay-otomasyon/about/
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await lancurl(
                            "https://www.instagram.com/controlapp.tr");
                      },
                      child: const SquareBox(
                        imagePath: "assets/social_media/instagram.png",
                      ),
                    ),
                    SizedBox(
                      width: 25.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await lancurl(
                            "https://www.linkedin.com/company/control-appco/");
                      },
                      child: const SquareBox(
                        imagePath: "assets/social_media/linkedin.png",
                      ),
                    ),
                    SizedBox(
                      width: 25.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await lancurl("https://www.yarbayotomasyon.com");
                      },
                      child: const SquareBox(
                        imagePath: "assets/yarbayiconlogo.png",
                      ),
                    ),
                    SizedBox(
                      width: 25.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await lancurl("https://www.controlapp.com.tr/");
                      },
                      child: const SquareBox(
                        imagePath: "assets/iconlogo.png",
                      ),
                    )
                  ],
                ),
//https://www.controlapp.co/
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String labelText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required int maxLength,
    required bool isPassword,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(51, 0, 0, 0),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
              borderRadius: BorderRadius.circular(10.h),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.h),
                  child: Icon(
                    isPassword ? Icons.lock_outline : Icons.pin_outlined,
                    size: 30.h,
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: labelText,
                        hintStyle: TextStyle(color: Colors.grey[500])),
                    onChanged: (value) {
                      setState(() {
                        if (value.length != maxLength) {
                          tcnoTextSize = 15.h;
                          tcnoTextColor = Colors.red;
                        } else {
                          tcnoTextSize = 12.h;
                          tcnoTextColor = black;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRememberMeCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: rememberMe ? black : white,
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(51, 0, 0, 0),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      height: 35.h,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: CupertinoSwitch(
          thumbColor: blue,
          inactiveTrackColor: white,
          activeTrackColor: black,
          value: rememberMe,
          onChanged: (bool? value) {
            setState(() {
              rememberMe = value!;
            });
          },
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    bool isProcessing = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isProcessing
                ? null
                : () async {
                    setState(() => isProcessing = true);
                    // await registration();
                    await Future.delayed(const Duration(seconds: 1));
                    await loginFunc(
                      context,
                      userNameTextController.text,
                      passwordTextController.text,
                    );
                    setState(() => isProcessing = false);
                  },
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Giriş",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget buildDemoButton() {
    bool isProcessing = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isProcessing
                ? null
                : () async {
                    setState(() => isProcessing = true);
                    // await registration();
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScrean(),
                      ),
                    );
                    setState(() => isProcessing = false);
                  },
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
                    AppLocalizations.of(context)!.demoIste,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> loginFunc(
    BuildContext context,
    String username,
    String password,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.girisHata),
          ),
        );
      return;
    }

    final authCubit = context.read<AuthCubit>();

    final session = await authCubit.login(
      username: username,
      password: password,
      rememberMe: rememberMe,
      deviceToken: fcmtokenstring,
    );

    if (session == null) {
      return;
    }

    try {
      final organizationService = OrganizationService();
      final sessionPassword =
          session.password ?? userDataConst['password']?.toString() ?? '';

      await organizationService.fetchOrganizations(
        session.username,
        sessionPassword,
      );

      if (organizationList.isEmpty && sectionList.isEmpty) {
        loginErrorAlert();
        return;
      }

      final selectedOrganization = await _selectOrganizationForLogin(context);
      if (selectedOrganization == null) {
        loginErrorAlert();
        return;
      }

      serialTitle = selectedOrganization.caption;
      await guncelleFunc(
        context,
        session.username,
        sessionPassword,
        serialTitle,
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.girisHata} $error'),
          ),
        );
    }
  }

  Future<OrganizationData?> _selectOrganizationForLogin(
    BuildContext context,
  ) async {
    if (sectionList.isNotEmpty) {
      if (sectionList.length == 1) {
        return _selectOrganizationFromSection(context, sectionList.first);
      }

      final selectedSection = await _showSectionPicker(context, sectionList);
      if (selectedSection == null) {
        return null;
      }
      return _selectOrganizationFromSection(context, selectedSection);
    }

    if (organizationList.isEmpty) {
      return null;
    }
    if (organizationList.length == 1) {
      return organizationList.first;
    }

    return _showOrganizationPicker(
      context,
      organizationList,
      title: AppLocalizations.of(context)!.modulSec,
    );
  }

  Future<OrganizationData?> _selectOrganizationFromSection(
    BuildContext context,
    SectionData section,
  ) async {
    if (section.organizations.isEmpty) {
      return null;
    }
    if (section.organizations.length == 1) {
      return section.organizations.first;
    }

    return _showOrganizationPicker(
      context,
      section.organizations,
      title: section.caption,
    );
  }

  Future<SectionData?> _showSectionPicker(
    BuildContext context,
    List<SectionData> sections,
  ) {
    return showDialog<SectionData>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.modulSec,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width / 1.2,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(dialogContext, section);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Colors.blue,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            child: Center(
                              child: Text(
                                section.caption,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<OrganizationData?> _showOrganizationPicker(
    BuildContext context,
    List<OrganizationData> organizations, {
    required String title,
  }) {
    return showDialog<OrganizationData>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width / 1.2,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final organization = organizations[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(dialogContext, organization);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Colors.blue,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            child: Center(
                              child: Text(
                                organization.displayCaption,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void loginErrorAlert() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: white,
          shadowColor: transparent,
          surfaceTintColor: transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.h),
            ),
          ),
          content: SizedBox(
            height: 175.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 28.sp,
                  color: Colors.red,
                ),
                Text(
                  AppLocalizations.of(context)!.sunucuHata,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: black,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.h),
                      border: Border.all(
                        width: 1.h,
                        color: blue,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 22.h,
                        right: 22.h,
                        top: 12.h,
                        bottom: 12.h,
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.tekrarDene,
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _resolveSectionIdForCaption(String caption) {
    final normalized = caption.trim();
    for (final section in sectionList) {
      for (final organization in section.organizations) {
        if (organization.caption.trim() == normalized) {
          return section.id;
        }
      }
    }
    return null;
  }

  SectionData? _resolveSectionForCaption(String caption) {
    final normalized = caption.trim();
    for (final section in sectionList) {
      for (final organization in section.organizations) {
        if (organization.caption.trim() == normalized) {
          return section;
        }
      }
    }
    return null;
  }

  Future<List<TreeNode>> _loadAndParseTree() async {
    return TreeNode.parseTreeNodes(treeJson);
  }

  Future<void> guncelleFunc(
    BuildContext context,
    String username,
    String password,
    String selectedSerialTitle,
  ) async {
    final fetchUseCase = getIt<FetchEnergySnapshotUseCase>();

    try {
      // Tree verilerini yükle ve işle
      List<TreeNode> nodes = await _loadAndParseTree();

      final normalizedSelection = selectedSerialTitle.trim();
      TreeNode organizizasyom = nodes.firstWhere(
        (node) =>
            node.classType.trim() == 'obm_organization' &&
            node.caption.trim() == normalizedSelection,
        orElse: () =>
            TreeNode.empty(), // Burada da boş bir TreeNode döndürmelisiniz
      );

      // Burada organizizasyom altında istediğiniz verilere erişebilirsiniz
      if (organizizasyom != TreeNode.empty()) {
        final section = _resolveSectionForCaption(selectedSerialTitle);
        final sectionId = section?.id;
        final preferredCaptions = preferredDeviceCaptionsForSection(sectionId);
        final ilkVeri = findFirstDevice(
          organizizasyom,
          preferredCaptions: preferredCaptions,
        );

        if (ilkVeri == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.altVeriBulunamadi),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        final ilkVeriId = ilkVeri.id;
        plcTitle = ilkVeri.caption;
        serialTitle = selectedSerialTitle;
        selectedModule = section?.caption ?? selectedSerialTitle;
        userDataConst['selected_module'] = selectedModule;
        log("İlk Veri ID: $ilkVeriId");

        bool success = false;
        if (selectedSerialTitle == iklimlendirmeIzlem) {
          final climateUseCase = getIt<FetchClimateSnapshotUseCase>();
          final snapshot = await climateUseCase(
            FetchClimateSnapshotParams(
              username: username,
              password: password,
              deviceId: ilkVeriId,
            ),
          );

          if (snapshot.isSuccess) {
            final values = Map<String, String>.from(snapshot.values);
            if (values['ErrorNumber'] == null || values['ErrorNumber'] == '0') {
              anaAnlikVeriMap
                ..clear()
                ..addAll(values);
              serial = ilkVeriId;
              success = true;
            }
          }
        } else {
          final snapshot = await fetchUseCase(
            FetchEnergySnapshotParams(
              username: username,
              password: password,
              deviceId: ilkVeriId,
            ),
          );

          if (snapshot.isSuccess) {
            anaAnlikVeriMap
              ..clear()
              ..addAll(snapshot.values);
            serial = ilkVeriId;
            success = true;
          }
        }

        if (success) {
          if (organizizasyom.id.isNotEmpty) {
            organizationid = organizizasyom.id;
          }

          users = username;
          pass = password;
          userDataConst['serial'] = serial;
          userDataConst['serialTitle'] = serialTitle;
          userDataConst['plcTitle'] = plcTitle;
          userDataConst['selected_module'] = selectedModule;

          final authCubit = context.read<AuthCubit>();
          final currentSession = authCubit.state.session;
          if (currentSession != null) {
            final updatedSession = currentSession.copyWith(
              serial: ilkVeriId,
              serialTitle: serialTitle,
              plcTitle: ilkVeri.caption,
              selectedOrganizationId: organizizasyom.id.isNotEmpty
                  ? organizizasyom.id
                  : currentSession.selectedOrganizationId,
              treeJson:
                  treeJson.isNotEmpty ? treeJson : currentSession.treeJson,
              password: currentSession.password,
              extras: {
                ...currentSession.extras,
                'selected_module': selectedModule,
              },
            );
            await authCubit.cacheSession(updatedSession);
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavigatiorPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.beklenmedikHata,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Eğer organizizasyom bulunamadıysa hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.enerjiIzlemeBulunamadi),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Eğer bir hata oluşursa, kullanıcıya hata mesajı göster
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.beklenmedikHata),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
