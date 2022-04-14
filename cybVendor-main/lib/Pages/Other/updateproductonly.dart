import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/productmodel/storeprodcut.dart';

class UpdateProductPage extends StatefulWidget {
  @override
  UpdateProductPageState createState() => UpdateProductPageState();
}

class UpdateProductPageState extends State<UpdateProductPage> {
StoreProductData productData;
  var https = Client();
  bool isLoading = false;
  List<String> tags = [];

  TextEditingController pNamec = TextEditingController();
  // TextEditingController pDescC = TextEditingController();
  TextEditingController pTagsC = TextEditingController();
  TextEditingController eanC = TextEditingController();

  List<File> imageList = [];

  File _image;
  final picker = ImagePicker();
  var prodId;

  var productImage;
  UpdateProductPageState(){
    imageList.add(File(''));
  }

  bool entered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    https.close();
    super.dispose();
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
    Map<String,dynamic> argd = ModalRoute.of(context).settings.arguments;
    if(!entered){
      setState(() {
        entered = true;
        productData = argd['pData'];
        prodId = productData.productId;
        pNamec.text = productData.productName;
        if(productData.tags!=null && productData.tags.length>0){
          for(Tags tg in productData.tags){
            tags.add(tg.tag.toString().replaceAll('[', '').replaceAll(']', ''));
          }
        }
        productImage = productData.productImage;
      });
    }

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
              SizedBox(
                height: 8,
              ),
              buildHeading(context, locale.pimage1),
              Container(
                height: 130,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Image.network(productImage,fit: BoxFit.cover,),
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
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
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              buildHeading(context, locale.itemInfo),
              EntryField(
                label: locale.productTitle,
                labelFontSize: 16,
                labelFontWeight: FontWeight.w400,
                controller: pNamec,
              ),
              Divider(
                thickness: 8,
                color: Colors.grey[100],
                height: 30,
              ),
              // buildHeading(context, locale.description),
              // EntryField(
              //   maxLines: 4,
              //   label: locale.briefYourProduct,
              //   labelFontSize: 16,
              //   labelFontWeight: FontWeight.w400,
              //   controller: pDescC,
              // ),
              // Divider(
              //   thickness: 8,
              //   color: Colors.grey[100],
              //   height: 30,
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //         child: EntryField(
              //           label: locale.ean1,
              //           hint: locale.ean2,
              //           labelFontSize: 16,
              //           labelFontWeight: FontWeight.w400,
              //           controller: eanC,
              //         )),
              //     IconButton(
              //       icon: Icon(Icons.qr_code_scanner),
              //       onPressed: () {
              //         // setState(() {
              //         //   tags.add(pTagsC.text.toUpperCase());
              //         //   pTagsC.clear();
              //         // });
              //       },
              //     ),
              //   ],
              // ),
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
                      setState(() {
                        isLoading = true;
                      });
                      if(_image!=null){
                        String fid = _image.path.split('/').last;
                        if(fid!=null && fid.length>0){
                          updateProductWithImage(fid,context);
                        }else{
                          updateProduct(context);
                        }
                      }else{
                        updateProduct(context);
                      }
                    }
                  }, label: locale.updateItem)),
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


  void updateProductWithImage(String fid, BuildContext context) async{
    var requestMulti = http.MultipartRequest('POST', storeProductsUpdateUri);
    requestMulti.fields["product_id"] = '${prodId}';
    requestMulti.fields["product_name"] = '${pNamec.text}';
    requestMulti.fields["tags"] = '${tags.toString()}';
    http.MultipartFile.fromPath('product_image', _image.path, filename: fid)
        .then((pic) {
      requestMulti.files.add(pic);
      requestMulti.send().then((values) {
        values.stream.toBytes().then((value) {
          var responseString = String.fromCharCodes(value);
          var jsonData = jsonDecode(responseString);
          print('${jsonData.toString()}');
          if('${jsonData['status']}'=='1'){
            Navigator.of(context).pop(true);
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

  void updateProduct(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    https.post(storeProductsUpdateUri,body: {
      'product_id':'${prodId}',
      'product_name':'${pNamec.text}',
      'tags':'${tags.toString()}',
      'product_image':'',
    }).then((value){
      print(value.body);
      var jsonData = jsonDecode(value.body);
      if('${jsonData['status']}'=='1'){
        Navigator.of(context).pop(true);
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
