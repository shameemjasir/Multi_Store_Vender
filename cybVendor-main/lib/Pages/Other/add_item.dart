import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/categorylist.dart';

class AddItemPage extends StatefulWidget {
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {

  var https = Client();
  bool isLoading = false;
  List<CategoryListData> categoryList = [];
  CategoryListData catData;
  List<String> tags = [];
  dynamic _scanBarcode;
  TextEditingController pNamec = TextEditingController();
  TextEditingController pDescC = TextEditingController();
  TextEditingController pPriceC = TextEditingController();
  TextEditingController pMrpC = TextEditingController();
  TextEditingController pQtyC = TextEditingController();
  TextEditingController pUnitC = TextEditingController();
  TextEditingController pTagsC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  List<File> imageList = [];

  File _image;
  final picker = ImagePicker();

  String catString = 'Select Item Category';

  AddItemPageState(){
    imageList.add(File(''));
    catData = CategoryListData('', 'Select Item Category', '', '', '', '', '', '', '');
    categoryList.add(catData);
  }

  void scanProductCode(BuildContext context) async {
    var locale = AppLocalizations.of(context);
    await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", locale.cancel, true, ScanMode.DEFAULT)
        .then((value) {
      setState(() {
        _scanBarcode = value;
        eanC.text = _scanBarcode;
      });
      print('scancode - ${_scanBarcode}');
    }).catchError((e) {});
  }

  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
  }

  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });
    https.get(catListUri).then((value) {
      if (value.statusCode == 200) {
        CategoryListMain categoryListMain = CategoryListMain.fromJson(
            jsonDecode(value.body));
        if ('${categoryListMain.status}' == '1') {
          setState(() {
            categoryList.clear();
            categoryList = List.from(categoryListMain.data);
            catData = categoryList[0];
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        imageList.add(_image);
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
          imageList.add(_image);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.addItem, style: TextStyle(color: Theme
            .of(context)
            .backgroundColor,),),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                height: 130,
                color: Colors.grey[100],
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          if(index ==0){
                            _showPicker(context);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          width: 100,
                          decoration: BoxDecoration(
                              color: Colors.grey[200]
                                  .withOpacity(index == 0 ? 1 : 0.9),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      Colors.grey[100]
                                          .withOpacity(index == 0 ? 1 : 0.9),
                                      index != 0
                                          ? BlendMode.dst
                                          : BlendMode.clear),
                                  image: index==0?AssetImage(
                                      'assets/ProductImages/lady finger.png'):FileImage(imageList[1]),
                                  fit: BoxFit.fill)),
                          child: index == 0
                              ? Icon(
                            Icons.camera_alt,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            size: 30,
                          )
                              : SizedBox.shrink(),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 8,
              ),
              buildHeading(context, locale.itemInfo),
              EntryField(
                label: locale.productTitle,
                labelFontSize: 16,
                labelFontWeight: FontWeight.w400,
                controller: pNamec,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                      child: Text(
                        locale.itemCategory,
                        style: TextStyle(fontSize: 13, color: kHintColor),
                      ),
                    ),
                    DropdownButton<CategoryListData>(
                      isExpanded: true,
                      value: catData,
                      underline: Container(
                        height: 1.0,
                        color: kMainTextColor,
                      ),
                      items: categoryList.map((values) {
                        return DropdownMenuItem<CategoryListData>(
                          value: values,
                          child: Text(values.title),
                        );
                      }).toList(),
                      onChanged: (area) {
                        setState(() {
                          catData = area;
                        });
                        // getSubCategoryList(area.category_id);
                      },
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              buildHeading(context, locale.description),
              EntryField(
                maxLines: 4,
                label: locale.briefYourProduct,
                labelFontSize: 16,
                labelFontWeight: FontWeight.w400,
                controller: pDescC,
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              buildHeading(context, locale.pricingStock),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                      child: EntryField(
                        label: locale.sellProductPrice,
                        hint: locale.sellProductPrice,
                        labelFontSize: 16,
                        labelFontWeight: FontWeight.w400,
                        controller: pPriceC,
                      )),
                  Expanded(
                      child: EntryField(
                        label: locale.sellProductMrp,
                        hint: locale.sellProductMrp,
                        labelFontSize: 16,
                        labelFontWeight: FontWeight.w400,
                        controller: pMrpC,
                      )),
                ],
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              buildHeading(context, locale.qntyunit),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                      child: EntryField(
                        label: locale.qnty1,
                        hint: locale.qnty2,
                        labelFontSize: 16,
                        labelFontWeight: FontWeight.w400,
                        controller: pQtyC,
                      )),
                  Expanded(
                      child: EntryField(
                        label: locale.unit1,
                        hint: locale.unit2,
                        labelFontSize: 16,
                        labelFontWeight: FontWeight.w400,
                        controller: pUnitC,
                      )),
                ],
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                      child: EntryField(
                        label: locale.ean1,
                        hint: locale.ean2,
                        labelFontSize: 16,
                        labelFontWeight: FontWeight.w400,
                        controller: eanC,
                      )),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      scanProductCode(context);
                    },
                  ),
                ],
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              buildHeading(context, locale.productTag1),
              SizedBox(
                height: 8,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: EntryField(
                            label: locale.productTag2,
                            hint: locale.productTag2,
                            labelFontSize: 16,
                            labelFontWeight: FontWeight.w400,
                            controller: pTagsC,
                          )),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if(pTagsC.text!=null && pTagsC.text.length>0){
                            int idd = tags.indexOf(pTagsC.text.toUpperCase());
                            if(idd<0){
                              setState(() {
                                tags.add(pTagsC.text.toUpperCase());
                                pTagsC.clear();
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text('${tags[index]}',textAlign: TextAlign.start,)),
                              IconButton(
                                icon: Icon(Icons.delete_forever),
                                onPressed: () {
                                  setState(() {
                                    tags.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      })
                ],
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: isLoading?SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ):CustomButton(
                  onTap: (){
                    if(pNamec.text!=null && pNamec.text.length>0){
                      if(pDescC.text!=null && pDescC.text.length>0){
                        if(pPriceC.text!=null && pPriceC.text.length>0){
                          if(pMrpC.text!=null && pMrpC.text.length>0){
                            if(pQtyC.text!=null && pQtyC.text.length>0){
                              if(pUnitC.text!=null && pUnitC.text.length>0){
                                if(catData.title!=null && '${catData.title}'!=catString){
                                  setState(() {
                                    isLoading = true;
                                  });
                                  if(_image!=null){
                                    String fid = _image.path.split('/').last;
                                    if(fid!=null && fid.length>0){
                                      addProductWithImage(fid);
                                    }else{
                                      addProduct();
                                    }
                                  }else{
                                    addProduct();
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }, label: locale.addItem)),
        ],
      ),
    );
  }

  Padding buildHeading(BuildContext context, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
      child: Text(heading,
          style: Theme
              .of(context)
              .textTheme
              .subtitle2
              .copyWith(fontWeight: FontWeight.w500)),
    );
  }


  void addProductWithImage(String fid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var requestMulti = http.MultipartRequest('POST', storeProductsAddUri);
    requestMulti.fields["store_id"] = '${prefs.getInt('store_id')}';
    requestMulti.fields["cat_id"] = '${catData.cat_id}';
    requestMulti.fields["product_name"] = '${pNamec.text}';
    requestMulti.fields["quantity"] = '${pQtyC.text}';
    requestMulti.fields["unit"] = '${pUnitC.text}';
    requestMulti.fields["price"] = '${pPriceC.text}';
    requestMulti.fields["mrp"] = '${pMrpC.text}';
    requestMulti.fields["description"] = '${pDescC.text}';
    requestMulti.fields["ean"] = '${eanC.text}';
    requestMulti.fields["tags"] = '${tags.toString()}';
    http.MultipartFile.fromPath('product_image', _image.path, filename: fid)
        .then((pic) {
      requestMulti.files.add(pic);
      requestMulti.send().then((values) {
        values.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('${jsonData.toString()}');
          // RegistrationModel signInData = RegistrationModel.fromJson(jsonData);
          if('${jsonData['status']}'=='1'){
            setState(() {
              imageList.removeAt(1);
              pNamec.clear();
              tags.clear();
              pDescC.clear();
              pMrpC.clear();
              pPriceC.clear();
              pQtyC.clear();
              pUnitC.clear();
              eanC.clear();
            });
          }
          Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
          setState(() {
            isLoading = false;
          });
        }).catchError((e) {
          print(e);
          setState(() {
            isLoading = false;
          });
        });
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        print(e);
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }

  void addProduct() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    https.post(storeProductsAddUri,body: {
      'store_id':'${prefs.getInt('store_id')}',
      'cat_id':'${catData.cat_id}',
      'product_name':'${pNamec.text}',
      'quantity':'${pQtyC.text}',
      'unit':'${pUnitC.text}',
      'price':'${pPriceC.text}',
      'mrp':'${pMrpC.text}',
      'description':'${pDescC.text}',
      'ean':'${eanC.text}',
      'tags':'${tags.toString()}',
      'product_image':'',
    }).then((value){
      var jsonData = jsonDecode(value.body);
      if('${jsonData['status']}'=='1'){
        setState(() {
          imageList.removeAt(1);
          pNamec.clear();
          tags.clear();
          pDescC.clear();
          pMrpC.clear();
          pPriceC.clear();
          pQtyC.clear();
          pUnitC.clear();
          eanC.clear();
        });
      }
      Toast.show(jsonData['message'], context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      setState(() {
        isLoading = false;
      });
    });
  }
}
