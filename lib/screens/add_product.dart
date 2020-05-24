import 'dart:io';

import 'package:adminecommerce/db/products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adminecommerce/db/brand.dart';
import 'package:adminecommerce/db/category.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService _productService = ProductService();
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  List<String> selectedSizes = <String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;

  @override
  void initState() {
    _getCategories();
    getCategoriesDropdown();
    _getBrands();
    getBrandsDropdown();
  }
  List<DropdownMenuItem<String>> getCategoriesDropdown(){
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i<categories.length; i++){
    setState(() {
      items.insert(0, DropdownMenuItem(child: Text(categories[i].data['category']),
        value: categories[i]['category'],));
    });
    }
  return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropdown(){
    List<DropdownMenuItem<String>> items = new List();
    for (int i= 0; i<brands.length; i++){
      setState(() {
        items.insert(0, DropdownMenuItem(child: Text(brands[i].data['brand']),
        value: brands[i]['brand'],));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: white,
        title: Text("add product", style: TextStyle(color: black), ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading ? Center(child: CircularProgressIndicator()) : Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.0),
                        onPressed: (){
                          _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 1);
                        },
                        child: _displayChild1(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.0),
                        onPressed: (){
                          _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 2);
                        },
                        child: _displayChild2(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlineButton(
                        borderSide: BorderSide(color: grey.withOpacity(0.5), width: 2.0),
                        onPressed: (){
                          _selectImage(ImagePicker.pickImage(source: ImageSource.gallery), 3);
                        },
                        child: _displayChild3()
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('enter s product name with 10 characters maximum', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 12),),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: 'Product name'
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter a product name';
                    }else if (value.length > 10) {
                      return 'Product name cant have more than 10 letters';
                    }
                    return value;
                  },
                ),
              ),

            // ================ select category ============o
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Category:', style: TextStyle(color: Colors.red),),
                  ),
                  DropdownButton(items: categoriesDropDown,
                  onChanged: changeSelectedcategory,
                  value:_currentCategory,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Brand:', style: TextStyle(color: Colors.red),),
                  ),
                  DropdownButton(items: brandsDropDown,
                    onChanged: changeSelectedbrand,
                    value:_currentBrand,
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new TextFormField(
                  controller: productQuantityController,
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                      hintText: 'Quantity'
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter a product quantity';
                    }
                    return value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new TextFormField(
                  initialValue: '0.00',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                      hintText: 'Quantity'
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'You must enter a product quantity';
                    }
                    return value;
                  },
                ),
              ),

             Text('Available sizes'),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: selectedSizes.contains('S'),
                      onChanged: (value) => changeSelectedSize('S'),),
                    new Text('S'),

                    Checkbox(
                      value: selectedSizes.contains('M'),
                      onChanged: (value) => changeSelectedSize('M'),),
                    new Text('M'),
                    Checkbox(
                      value: selectedSizes.contains('L'),
                      onChanged: (value) => changeSelectedSize('L'),),
                    new Text('L'),
                    Checkbox(
                      value: selectedSizes.contains('XL'),
                      onChanged: (value) => changeSelectedSize('XL'),),
                    new Text('XL'),
                    Checkbox(
                      value: selectedSizes.contains('XLL'),
                      onChanged: (value) => changeSelectedSize('XLL'),),
                    new Text('XXL'),
                  ],
                ),
              ),

             SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Row(
                   children: <Widget>[
                     Checkbox(
                       value: selectedSizes.contains('28'),
                       onChanged: (value) => changeSelectedSize('28'),),
                     new Text('28'),

                     Checkbox(
                       value: selectedSizes.contains('30'),
                       onChanged: (value) => changeSelectedSize('30'),),
                     new Text('30'),
                     Checkbox(
                       value: selectedSizes.contains('32'),
                       onChanged: (value) => changeSelectedSize('32'),),
                     new Text('32'),
                     Checkbox(
                       value: selectedSizes.contains('34'),
                       onChanged: (value) => changeSelectedSize('34'),),
                     new Text('34'),
                     Checkbox(
                       value: selectedSizes.contains('36'),
                       onChanged: (value) => changeSelectedSize('36'),),
                     new Text('36'),
                     Checkbox(
                       value: selectedSizes.contains('38'),
                       onChanged: (value) => changeSelectedSize('38'),),
                     new Text('38'),
                     Checkbox(
                       value: selectedSizes.contains('40'),
                       onChanged: (value) => changeSelectedSize('40'),),
                     new Text('40'),
                     Checkbox(
                       value: selectedSizes.contains('42'),
                       onChanged: (value) => changeSelectedSize('42'),),
                     new Text('42'),
                     Checkbox(
                       value: selectedSizes.contains('44'),
                       onChanged: (value) => changeSelectedSize('44'),),
                     new Text('44'),
                   ],
                 ),
               ),
             ),

             FlatButton(
               color: Colors.red,
               textColor: white,
               child: Text('Add product') ,
               onPressed: (){
                 validateAndUpload();
               },
             )
            ],
          ),
        ),
      ),
    );
  }

   _getCategories() async{
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
        categories = data;
        categoriesDropDown = getCategoriesDropdown();
        _currentCategory = categories[0].data['category'];
    });
   }

  changeSelectedcategory(String selectedCategory) {
    setState(() => _currentCategory = selectedCategory);

  }

  void _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    print(data.length);
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropdown();
      _currentBrand = brands[0].data['brand'];
    });
  }

  changeSelectedbrand(String selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

   void changeSelectedSize(String size) {
    if(selectedSizes.contains(size)){
      setState(() {
        selectedSizes.remove(size);
      });
    }else {
      setState(() {
        selectedSizes.add(size);
      });
    }
  }

  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    switch(imageNumber){
      case 1: setState(() => _image1 = tempImg);
      break;
      case 2: setState(() => _image2 = tempImg);
      break;
      case 3: setState(() => _image2 = tempImg);
      break;
    }

  }

  Widget _displayChild1() {
    if(_image1 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return Image.file(_image1, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild2() {
    if(_image2 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return Image.file(_image2, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  Widget _displayChild3() {
    if(_image3 == null){
      return Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 50.0, 14.0, 50.0),
        child: new Icon(Icons.add, color: grey,),
      );
    }else{
      return  Image.file(_image3, fit: BoxFit.fill, width: double.infinity,);
    }
  }

  void validateAndUpload() async{
    if(_formKey.currentState.validate()){
      setState(() => isLoading = true
      );
      if(_image1 != null && _image2!= null && _image3 != null){
        if(selectedSizes.isNotEmpty){
          String imageUrl1;
          String imageUrl2;
          String imageUrl3;
          final FirebaseStorage storage = FirebaseStorage.instance;
          //uploading first image
          final String picture1 = "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task1 =  storage.ref().child(picture1).putFile(_image1);
          //uploading second image
          final String picture2 = "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task2 = storage.ref().child(picture2).putFile(_image2);
          //uploading third image
          final String picture3 = "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task3 = storage.ref().child(picture3).putFile(_image3);
          StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snapshot)=> snapshot);
          StorageTaskSnapshot snapshot2 = await task2.onComplete.then((snapshot)=> snapshot);
          task3.onComplete.then((snapshot3) async{
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();
            List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];
            _productService.uploadProduct(
              productName: productNameController.text,
              price: double.parse(priceController.text),
              sizes: selectedSizes,
              images: imageList,
              quantity: int.parse(productQuantityController.text)
            );
            _formKey.currentState.reset();
            setState(() => isLoading = false
            );
            Fluttertoast.showToast(msg: 'product added');
          });
        }else {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: 'select at least one size');
        }
      }else {
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: 'all images must be provided');
      }
    }
  }
}
