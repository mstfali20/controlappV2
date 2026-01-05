import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/data/xmlModel.dart';
import 'package:controlapp/src/features/energy/presentation/pages/detail/xml_list.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnerjiMenuWidget extends StatelessWidget {
  final String organisation;
  final Future<List<XmlModel>> Function() loadAndParseXml;

  const EnerjiMenuWidget({
    super.key,
    required this.organisation,
    required this.loadAndParseXml,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.1,
          top: 5), // Ekran genişliğinin %5'i kadar mesafe
      child: Container(
        decoration: const BoxDecoration(
          color: contolblue, // Butonun arka planı siyah
          shape: BoxShape.circle, // Çerçeve yuvarlak olacak
        ),
        child: IconButton(
          icon: Icon(
            Icons.menu, // Üç çizgili menü ikonu
            color: Colors.white, // İkon rengi beyaz
            size: 30.sp, // İkon boyutu
          ),
          padding: EdgeInsets.zero, // Butonun ekstra padding'ini kaldırır
          splashColor: Colors
              .transparent, // Buton tıklandığında oluşan sıçrama efektini kaldırma
          highlightColor: Colors
              .transparent, // Butonun tıklanırken oluşan renk değişimini kaldırma
          onPressed: () {
            showDialog(
              barrierColor: Colors.transparent,
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.white70,
                  body: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder(
                          future: loadAndParseXml(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: contolblue),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Hata: ${snapshot.error}'),
                              );
                            } else {
                              List<XmlModel> nodes =
                                  snapshot.data as List<XmlModel>;

                              // "TanTekstil" düğümünü bulma
                              XmlModel nodesName = nodes.firstWhere(
                                (node) =>
                                    node.caption == userDataConst["firm_name"],
                                orElse: () => XmlModel
                                    .empty(), // Burada boş bir XmlModel döndürmelisiniz
                              );

                              // Eğer "TanTekstil" bulunduysa, altındaki "Enerji İzleme Sistemi" düğümünü bul
                              XmlModel organizizasyom =
                                  nodesName.children.firstWhere(
                                (childNode) =>
                                    childNode.caption == organisation,
                                orElse: () => XmlModel
                                    .empty(), // Burada da boş bir XmlModel döndürmelisiniz
                              );

                              // Eğer "Enerji İzleme Sistemi" düğümünü bulduysanız, onun altındaki düğümleri listeleyin
                              if (organizizasyom.children.isNotEmpty) {
                                log(organisation.toString());
                                return Flexible(
                                  child: XmlListScreen(
                                      nodes: organizizasyom.children),
                                );
                              } else {
                                return const Center(
                                  child: Text(
                                      '"Enerji İzleme Sistemi" düğümünün altındaki düğümler bulunamadı.'),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
