import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/appinfomodel.dart';
import 'package:vendor/beanmodel/citybean/citybean.dart';
import 'package:vendor/beanmodel/mapsection/latlng.dart';
import 'package:vendor/beanmodel/registrationmodel/registrationmodel.dart';
import 'package:vendor/Theme/colors.dart';

class SignUp extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  // SignUp(this.onVerificationDone);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool showDialogBox = false;
  bool enteredFirst = false;
  int numberLimit = 10;
  dynamic mobileNumber;
  dynamic emailId;
  dynamic fb_id;
  TextEditingController sellerNameC = TextEditingController();
  TextEditingController storeNameC = TextEditingController();
  TextEditingController emailAddressC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController adminShareC = TextEditingController();
  TextEditingController deliveryRangeC = TextEditingController();
  TextEditingController addressC = TextEditingController();
  String selectCity = 'Select city';
  List<CityDataBean> cityList = [];
  CityDataBean cityData;
  AppInfoModel appinfo;
  FirebaseMessaging messaging;
  dynamic token;
  File _image;
  final picker = ImagePicker();
  int count = 0;

  dynamic lat;
  dynamic lng;

  @override
  void initState() {
    super.initState();
    hitAsyncInit();
    hitCityData();
  }

  void hitAsyncInit() async{
    try{
      await Firebase.initializeApp();
      messaging = FirebaseMessaging.instance;
      messaging.getToken().then((value) {
        token = value;
      });
    }catch(e){}
  }

  void hitCityData() {
    setState(() {
      showDialogBox = true;
    });
    var http = Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            selectCity = cityList[0].city_name;
            cityData = cityList[0];
          });
        } else {
          setState(() {
            selectCity = 'Select your city';
            cityData = null;
          });
        }
      } else {
        setState(() {
          selectCity = 'Select your city';
          cityData = null;
        });
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      setState(() {
        selectCity = 'Select your city';
        cityData = null;
        showDialogBox = false;
      });
      print(e);
    });
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _imgFromGallery() async {
    picker.getImage(source: ImageSource.gallery).then((pickedFile) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }).catchError((e) => print(e));
  }

  void _showPicker(context) {
    var locale = AppLocalizations.of(context);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(locale.photolib),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(locale.camera),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if(!enteredFirst){
      final Map<String, Object> rcvdData =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        enteredFirst = true;
        appinfo = rcvdData['appinfo'];
        numberLimit = int.parse('${appinfo.phoneNumberLength}');
      });
    }
    return Scaffold(
      appBar: AppBar(

        title: Text(locale.register,style: TextStyle(color:Theme.of(context). backgroundColor,),),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 90,
                        decoration: BoxDecoration(
                            border: Border.all(color: kMainColor),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image(
                              image: (_image != null)
                                  ? FileImage(_image)
                                  : AssetImage('assets/icon.png'),
                              height: 80,
                              width: 80,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              locale.uploadpictext,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  EntryField(
                    label: locale.sellerName,
                    hint: locale.sellerName1,
                    controller: sellerNameC,
                  ),
                  EntryField(
                    label: locale.storename1,
                    hint: locale.storename2,
                    controller: storeNameC,
                  ),
                  EntryField(
                    label: locale.storenumber1,
                    hint: locale.storenumber2,
                    controller: phoneNumberC,
                    keyboardType: TextInputType.phone,
                  ),
                  EntryField(
                    label: locale.emailAddress,
                    hint: locale.enterEmailAddress,
                    controller: emailAddressC,
                  ),
                  EntryField(
                    label: locale.adminshare1,
                    hint: locale.adminshare2,
                    controller: adminShareC,
                  ),
                  EntryField(
                    label: locale.password1,
                    hint: locale.password2,
                    controller: passwordC,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 1),
                    child: Text(
                      locale.selectycity1,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          color: kMainTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 21.7),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<CityDataBean>(
                      hint: Text(
                        selectCity,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                      isExpanded: true,
                      iconEnabledColor: kMainTextColor,
                      iconDisabledColor: kMainTextColor,
                      iconSize: 30,
                      items: cityList.map((value) {
                        return DropdownMenuItem<CityDataBean>(
                          value: value,
                          child: Text(value.city_name,
                              overflow: TextOverflow.clip),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectCity = value.city_name;
                          cityData = value;
                          // showDialogBox = true;
                        });
                        // hitSocityList(value.city_name, locale);
                        print(value);
                      },
                    ),
                  ),
                  EntryField(
                    label: locale.deliveryrange1,
                    hint: locale.deliveryrange2,
                    controller: deliveryRangeC,
                  ),
                  EntryField(
                    label: locale.storeaddress1,
                    hint: locale.storeaddress2,
                    controller: addressC,
                    readOnly: true,
                    onTap: (){
                      Navigator.pushNamed(context, PageRoutes.locSearch).then((value){
                        if(value!=null){
                          BackLatLng back = value;
                          setState(() {
                            addressC.text = back.address;
                            lat = double.parse('${back.lat}');
                            lng = double.parse('${back.lng}');
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          showDialogBox?Container(
            height: 50,
            child: Center(
                widthFactor: 50,
                heightFactor: 40,
                child: CircularProgressIndicator(strokeWidth: 3)
            ),
          ):CustomButton(onTap: () {
            if (!showDialogBox) {
              setState(() {
                showDialogBox = true;
              });
              // int numLength = (mobileNumber!=null && mobileNumber.toString().length>0)?numberLimit:10;
              if (sellerNameC.text != null) {
                if (emailAddressC.text != null &&
                    emailValidator(emailAddressC.text)) {
                  if (passwordC.text != null && passwordC.text.length > 6) {
                    if (phoneNumberC.text != null &&
                        phoneNumberC.text.length == numberLimit) {
                      if (storeNameC.text != null) {
                        if (adminShareC.text != null) {
                          if (deliveryRangeC.text != null) {
                            if (addressC.text != null) {
                              hitSignUpUrl(
                                  sellerNameC.text,
                                  storeNameC.text,
                                  phoneNumberC.text,
                                  emailAddressC.text,
                                  passwordC.text,
                                  cityData.city_name,
                                  adminShareC.text,
                                  deliveryRangeC.text,
                                  addressC.text,
                                  context);
                            } else {
                              setState(() {
                                showDialogBox = false;
                              });
                              Toast.show(
                                  '${locale.incorectUserName}${numberLimit}',
                                  context,
                                  gravity: Toast.CENTER,
                                  duration: Toast.LENGTH_SHORT);
                            }
                          } else {
                            setState(() {
                              showDialogBox = false;
                            });
                            Toast.show(
                                '${locale.incorectUserName}${numberLimit}',
                                context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_SHORT);
                          }
                        } else {
                          setState(() {
                            showDialogBox = false;
                          });
                          Toast.show(
                              '${locale.incorectUserName}${numberLimit}',
                              context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                        }
                      } else {
                        setState(() {
                          showDialogBox = false;
                        });
                        Toast.show(
                            '${locale.incorectUserName}${numberLimit}',
                            context,
                            gravity: Toast.CENTER,
                            duration: Toast.LENGTH_SHORT);
                      }
                    } else {
                      setState(() {
                        showDialogBox = false;
                      });
                      Toast.show(
                          '${locale.incorectMobileNumber}${numberLimit}',
                          context,
                          gravity: Toast.CENTER,
                          duration: Toast.LENGTH_SHORT);
                    }
                  } else {
                    setState(() {
                      showDialogBox = false;
                    });
                    Toast.show(locale.incorectPassword, context,
                        gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  }
                } else {
                  setState(() {
                    showDialogBox = false;
                  });
                  Toast.show(locale.incorectEmail, context,
                      gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                }
              } else {
                setState(() {
                  showDialogBox = false;
                });
                Toast.show(locale.incorectUserName, context,
                    gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
              }
            }else{
              Toast.show('Already in progress.', context,
                  gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
            }
          })
        ],
      ),
    );
  }

  bool emailValidator(email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void hitSignUpUrl(
      dynamic sellerName,
      dynamic storename,
      dynamic storephone,
      dynamic storeemail,
      dynamic password,
      dynamic cityid,
      dynamic adminshare,
      dynamic deliveryrange,
      dynamic address,
      BuildContext context) {
    var requestMulti = http.MultipartRequest('POST', registrationStoreUri);
    requestMulti.fields["store_name"] = '${storename}';
    requestMulti.fields["emp_name"] = '${sellerName}';
    requestMulti.fields["store_phone"] = '${storephone}';
    requestMulti.fields["city"] = '${cityid}';
    requestMulti.fields["email"] = '${storeemail}';
    requestMulti.fields["del_range"] = '${deliveryrange}';
    requestMulti.fields["password"] = '${password}';
    requestMulti.fields["address"] = '${address}';
    requestMulti.fields["lat"] = '${lat}';
    requestMulti.fields["lng"] = '${lng}';
    requestMulti.fields["share"] = '${adminshare}';
    if (_image != null) {
      String fid = _image.path.split('/').last;
      if(fid!=null && fid.length>0){
        http.MultipartFile.fromPath('store_doc', _image.path, filename: fid)
            .then((pic) {
          requestMulti.files.add(pic);
          requestMulti.send().then((values) {
            values.stream.toBytes().then((value) {
              var responseString = String.fromCharCodes(value);
              var jsonData = jsonDecode(responseString);
              print('${jsonData.toString()}');
              RegistrationModel signInData = RegistrationModel.fromJson(jsonData);
              if('${signInData.status}'=='1'){
                Navigator.of(context).pop();
              }
              Toast.show(signInData.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
              setState(() {
                showDialogBox = false;
              });
            }).catchError((e) {
              print(e);
              setState(() {
                showDialogBox = false;
              });
            });
          }).catchError((e) {
            setState(() {
              showDialogBox = false;
            });
            print(e);
          });
        }).catchError((e) {
          setState(() {
            showDialogBox = false;
          });
          print(e);
        });
      }
      else{
        print('not null');
        requestMulti.fields["store_doc"] = '';
        requestMulti.send().then((value1){
          value1.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            var jsonData = jsonDecode(responseString);
            print('${jsonData.toString()}');
            RegistrationModel signInData = RegistrationModel.fromJson(jsonData);
            if('${signInData.status}'=='1'){
              Navigator.of(context).pop();
            }
            Toast.show(signInData.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_LONG);
            setState(() {
              showDialogBox = false;
            });
          }).catchError((e) {
            print(e);
            setState(() {
              showDialogBox = false;
            });
          });
        }).catchError((e){
          setState(() {
            showDialogBox = false;
          });
        });
      }
    }
    else{
      print('not null');
      requestMulti.fields["store_doc"] = '';
      requestMulti.send().then((value1){
        value1.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('${jsonData.toString()}');
          RegistrationModel signInData = RegistrationModel.fromJson(jsonData);
          if('${signInData.status}'=='1'){
            Navigator.of(context).pop();
          }
          Toast.show(signInData.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          setState(() {
            showDialogBox = false;
          });
        }).catchError((e) {
          print(e);
          setState(() {
            showDialogBox = false;
          });
        });
      }).catchError((e){
        setState(() {
          showDialogBox = false;
        });
      });
    }
  }
}
