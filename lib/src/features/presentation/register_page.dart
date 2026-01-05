import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/core/storage/user_controller.dart';
import 'package:controlapp/src/core/storage/database_methods.dart';
import 'package:controlapp/src/features/auth/presentation/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class RegisterScrean extends StatefulWidget {
  const RegisterScrean({super.key});

  @override
  State<RegisterScrean> createState() => _RegisterScreanState();
}

class _RegisterScreanState extends State<RegisterScrean> {
  TextEditingController firmaNameTextController = TextEditingController();
  TextEditingController roleTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController areaTextController = TextEditingController();

  TextEditingController emailTextController = TextEditingController();

  TextEditingController telTextController = TextEditingController();
  final bool _isCheckingUser = true;

  Color tcnoTextColor = black;
  double tcnoTextSize = 12.h;
  bool passwordIsObsecure = true;
  bool rememberMe = true;

  registration() async {
    if (roleTextController.text != "" &&
        emailTextController.text != "" &&
        firmaNameTextController.text != "" &&
        areaTextController.text != "") {
      try {
        // Kullanıcı başarıyla oluşturulduysa, veritabanına kullanıcı bilgilerini kaydet
        await DatabaseMethods().updateUser(fcmtokenstring, {
          "id": fcmtokenstring,
          "firma": firmaNameTextController.text,
          "name": nameTextController.text,
          "rol": roleTextController.text,
          "firmacalisma": areaTextController.text,
          "tel": telTextController.text,
          "email": emailTextController.text,
          "okundu": false,

          // Diğer bilgileri ekleyin
        });

        // Kullanıcı ID'sini güncelle

        // Kayıt işlemi başarılı oldu, kullanıcıyı giriş ekranına yönlendir
        showLoginLoadingScreen();
      } catch (e) {
        // Diğer hataları ele al
        print("Error during registration: $e");

        // Hata mesajını kullanıcıya göster
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Beklenmedik bir hata oluştu",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    } else {
      // Gerekli alanlar doldurulmadıysa kullanıcıya uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Lütfen gerekli tüm alanları doldurun",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  Future<void> saveCredentials(String username, String password, String serial,
      String serialTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', userDataConst["password"]);
    await prefs.setString('serial', serial);
    await prefs.setString('serialTitle', serialTitle);
  }

  // Future<void> saveserial(String username, String password, String serial,
  //     String serialTitle) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('username', username);
  //   await prefs.setString('password', userDataConst["password"]);
  //   await prefs.setString('serial', serial);
  //   await prefs.setString('serialTitle', serialTitle);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300], // Başlangıç ve bitiş renkleri
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 10),
              Row(
                children: [
                  SizedBox(width: 30.h),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(25.h),
                      minimumSize: const Size(0, 0),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Iconsax.arrow_left),
                  ),
                  SizedBox(width: 10.h),
                  Padding(
                    padding: EdgeInsets.all(2.0.h),
                    child: Image.asset(
                      'assets/ControlAppSiyah.png',
                      height: 100.h,
                    ),
                  ),
                ],
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
                      labelText: AppLocalizations.of(context)!.firmaAdi,
                      controller: firmaNameTextController,
                      keyboardType: TextInputType.text,
                      maxLength: 20,
                      isPassword: false,
                      icon: Icons.business, // Firma Adı için iş ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: ABC Ltd. Şti.', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                    buildTextField(
                      labelText: AppLocalizations.of(context)!.adSoyad,
                      controller: nameTextController,
                      keyboardType: TextInputType.text,
                      maxLength: 12,
                      isPassword: false,
                      icon: Icons.person, // Ad Soyad için kişi ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: Mevlüt Yarbay', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                    buildTextField(
                      labelText: AppLocalizations.of(context)!.rol,
                      controller: roleTextController, // Controller'ı düzelttim
                      keyboardType: TextInputType.text,
                      maxLength: 12,
                      isPassword: false,
                      icon: Icons.assignment_ind, // Rol için görev ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: Yönetici', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                    buildTextField(
                      labelText:
                          AppLocalizations.of(context)!.firmaCalismaAlani,
                      controller: areaTextController, // Controller'ı düzelttim
                      keyboardType: TextInputType.text,
                      maxLength: 12,
                      isPassword: false,
                      icon: Icons.work, // Çalışma alanı için iş ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: Yazılım', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                    buildTextField(
                      labelText: AppLocalizations.of(context)!.telefon,
                      controller: telTextController,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      isPassword: false,
                      icon: Icons.phone, // Telefon için telefon ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: +90 555 555 55 55', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                    buildTextField(
                      labelText: AppLocalizations.of(context)!.email,
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 30,
                      isPassword: false,
                      icon: Icons.email, // Email için email ikonu
                      hintText:
                          '${AppLocalizations.of(context)!.ornek}: bilgi@yarbayotomasyon.com.tr', // ${AppLocalizations.of(context)!.ornek}ek metin
                    ),
                  ],
                ),
              ),

              builDemoButton(),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //   child: SizedBox(
              //     height: 50,
              //     width: MediaQuery.of(context).size.width * 0.8,
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         foregroundColor: Colors.black,
              //         backgroundColor: Colors
              //             .white, // Butonun tıklandığında renginin değişimi
              //         side: BorderSide(
              //           color: Colors.black,
              //           width: 2.0, // Çerçeve rengi ve kalınlığı
              //         ),
              //         shape: RoundedRectangleBorder(
              //           borderRadius:
              //               BorderRadius.circular(8.0), // Köşeleri yuvarlatma
              //         ),
              //         padding: const EdgeInsets.all(8.0), // İç boşluk
              //       ),
              //       onPressed: () {
              //         registration();
              //         // Butona basıldığında yapılacak işlemler buraya yazılır
              //       },
              //       child: Text(
              //         'Demo İste',
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 20.h,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              SizedBox(height: 20.h),

              SizedBox(height: 20.h),

              // google + apple sign in buttons  https://www.linkedin.com/company/yarbay-otomasyon/about/
            ],
          ),
        ),
      ),
    );
  }

  Widget builDemoButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LoadingBtn(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.8,
        borderRadius: 8,
        animate: true,
        color: Colors.white,
        loader: Container(
          padding: const EdgeInsets.all(10),
          child: const Center(
            child: SpinKitDoubleBounce(
              color: Colors.black,
            ),
          ),
        ),
        onTap: ((startLoading, stopLoading, btnState) async {
          if (btnState == ButtonState.idle) {
            startLoading();
            await Future.delayed(const Duration(seconds: 1));
            stopLoading();
            registration();

            // call your network api
            // stopLoading();
          }
        }),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.demoIste,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void showLoginLoadingScreen() async {
    AlertDialog alert = AlertDialog(
      backgroundColor: white,
      shadowColor: transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.h),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.kayitAlindi,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.h,
              ),
            ),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );

    // loginWithGoogle fonksiyonunu çağır ve sonucu bekle
    final result = await yukleme();

    // Sonuca göre işlem yap
    if (result == "completed") {
      Navigator.pop(context); // Loading ekranını kapat
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.kayitIletildi,
          style: const TextStyle(fontSize: 20.0),
        ),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      // Hata durumunda
      Navigator.pop(context); // Loading ekranını kapat
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.beklenmedikHata,
          style: const TextStyle(fontSize: 20.0),
        ),
      ));
    }
  }

  Future<String?> yukleme() async {
    try {
      UserController.getUserData();

      await Future.delayed(const Duration(seconds: 2));
      return "completed";
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Widget buildTextField({
    required String labelText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required int maxLength,
    required bool isPassword,
    required IconData icon, // Yeni eklenen parametre
    required String
        hintText, // ${AppLocalizations.of(context)!.ornek}ek metin için yeni parametre
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
                    icon, // İkonu buradan alıyoruz
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
                      hintText:
                          hintText, // ${AppLocalizations.of(context)!.ornek}ek metni buraya ekliyoruz
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
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
}
