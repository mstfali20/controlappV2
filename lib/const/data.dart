import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:controlapp/data/userModel.dart';

String users = "";
String pass = "";
Map<String, String> anaAnlikVeriMap = {};

String enerjiIzlem = 'Enerji İzleme Sistemi';
String iklimlendirmeIzlem = 'Klima Santrali İzleme Sistemi';
String boyahaneIzlem = 'Boyahane İzleme Sistemi';

String yanserial = '';

List<UserData> loginData = [];
Map<String, dynamic> userDataConst = {};
// List<PlcData> plcList = [];
List<OrganizationData> organizationList = [];
List<OrganizationData> altorganizationList = [];
int deviceCount = 0;
String treeJson = "";
String serial = '';
String serialTitle = '';
String plcTitle = '';
String organizationid = '';
String selectedModule = enerjiIzlem;

String catogari = '';
String satisUrl = 'https://www.controlapp.com.tr/';
String fcmtokenstring = "";

// final Uri satisUrl = Uri.parse('https://www.controlapp.com.tr/');
final Uri yarbayUrl = Uri.parse('https://www.yarbayotomasyon.com.tr/');
final Uri controlUrl = Uri.parse('https://www.controlapp.com.tr');
// final Uri googlePlayUrl = Uri.parse(
//     'https://play.google.com/store/apps/details?id=com.yarbay.controlapp');
// final Uri apstoreUrl =
//     Uri.parse('https://apps.apple.com/tr/app/controlapp/id6511192984?l=tr');
String apstoreUrl =
    'https://apps.apple.com/tr/app/controlapp/id6511192984?l=tr';
String googlePlayUrl =
    'https://play.google.com/store/apps/details?id=com.yarbay.controlapp';
