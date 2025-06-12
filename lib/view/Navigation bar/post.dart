import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Models/SelectedCategoryModel.dart';
import 'package:image/image.dart' as img;
import 'package:venta_cuba/view/Navigation%20bar/navigation_bar.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/privacy_policy/privacy_policy_screen.dart';
import '../../Controllers/auth_controller.dart';
import '../../Controllers/location_controller.dart';
import '../../Utils/funcations.dart';
import '../../cities_list/cites_list.dart';
import '../../util/my_button.dart';
import '../Chat/custom_text.dart';
import 'package:venta_cuba/Models/CategoriesModel.dart' as cta;
import 'package:venta_cuba/Models/SubCategoriesModel.dart' as sub;
import 'package:venta_cuba/Models/SubSubCategoriesModel.dart' as subSub;

import '../terms_of_use/terms_of_use_screen.dart';

// Add this class at the top of the file
class UploadingImage {
  String path;
  double progress;
  String status; // e.g., "Picking", "Normalizing", "Uploaded", "Failed"
  bool isUploading;
  bool isUploaded;
  String? errorMessage;

  UploadingImage({
    required this.path,
    this.progress = 0.0,
    this.status = 'Picking',
    this.isUploading = true,
    this.isUploaded = false,
    this.errorMessage,
  });
}

class Post extends StatefulWidget {
  final bool isUpdate;

  Post({super.key, required this.isUpdate});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> with SingleTickerProviderStateMixin {
  final homeCont = Get.find<HomeController>();
  final authCont = Get.put(AuthController());
  final locationCont = Get.find<LocationController>();
  TextAlign _textAlignment = TextAlign.left;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  final FocusNode _focusNode = FocusNode();
  bool isChecked = true;
  String? imageLink;
  File? imageFile;
  String currentText = '';
  double height = 0;
  List<CustomCitiesList>? searchCity = [];

  @override
  void dispose() {
    // TODO: implement dispose
    Timer(Duration(seconds: 1), () {
      homeCont.selectedCategory = null;
      homeCont.selectedSubCategory = null;
      homeCont.selectedSubSubCategory = null;
    });
    homeCont.postImages.clear();
    homeCont.titleCont.clear();
    homeCont.priceCont?.clear();
    homeCont.selectedCurrency = 'USD';
    homeCont.tags.clear();
    homeCont.postImages.clear();
    homeCont.descriptionCont.clear();
    homeCont.addressCont.clear();
    homeCont.youTubeController.clear();
    homeCont.phoneController.clear();
    homeCont.conditionController.clear();
    homeCont.fulfillmentController.clear();
    homeCont.paymentController.clear();
    homeCont.isType = 0;
    _focusNode.dispose();
    _controller.dispose();
    textEditingController.dispose();

    super.dispose();
  }

  void _setAlignment(TextAlign alignment, Color color) {
    setState(() {
      _textAlignment = alignment;
    });
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderlined = !_isUnderlined;
    });
  }

  String? valueChoose;
  String? valueChooseJob;

  //
  List listItem = [
    'Yes',
    'No',
  ];
  List jobListItem = [
    'Full_Time',
    'Part_Time',
    'Contract',
    'Temporary',
    'Please Contact',
  ];

  getData() async {
    await homeCont.listingGetDraft();
  }

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    homeCont.isType = 0;
    citiesList.forEach((element) {
      if (element.cityName == authCont.user?.city) {
        homeCont.lat = element.latitude;
        homeCont.lng = element.longitude;
        homeCont.addressCont.text =
            "${authCont.user?.province}, ${authCont.user?.city}";
        city = element;
      }
    });
    provinceName.forEach((element) {
      if (element.provinceName == authCont.user?.province) {
        province = element;
      }
    });

    _scrollController = ScrollController();
    if (authCont.user?.province != null && authCont.user?.city != null)

      // TODO: implement initState
      _controller = AnimationController(
        duration: Duration(milliseconds: 700),
        vsync: this,
      );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(0.0, 0.07),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    if (widget.isUpdate) {
      // homeCont.listingModel?.gallery?.forEach((element) {
      //   homeCont.postImages.add(element);
      // });
      city = null;
      province = null;

      print(homeCont.listingModel?.address);
      List<String> names =
          homeCont.listingModel?.address?.split(',') ?? ["", ""];
      provinceName.forEach((element) {
        if (element.provinceName == names[0]) {
          province = element;
        }
      });
      citiesList.forEach((element) {
        if (element.cityName == names[1].trim()) {
          homeCont.lat = element.latitude;
          homeCont.lng = element.longitude;
          homeCont.addressCont.text =
              "${authCont.user?.province}, ${authCont.user?.city}";
          city = element;
        }
      });

      if (homeCont.listingModel?.category != null) {
        homeCont.selectedCategory = cta.Data(
          id: homeCont.listingModel?.category?.id,
          name: homeCont.listingModel?.category?.name,
          icon: homeCont.listingModel?.category?.icon,
        );
      }
      if (homeCont.listingModel?.subCategory != null) {
        homeCont.selectedSubCategory = sub.Data(
          id: homeCont.listingModel?.subCategory?.id,
          category: sub.Category(
            id: homeCont.listingModel?.category?.id,
            name: homeCont.listingModel?.category?.name,
            icon: homeCont.listingModel?.category?.icon,
          ),
          name: homeCont.listingModel?.subCategory?.name,
          categoryId: homeCont.listingModel?.category?.id.toString(),
        );
      }
      if (homeCont.listingModel?.subSubCategory != null) {
        homeCont.selectedSubSubCategory = subSub.Data(
          id: homeCont.listingModel?.subSubCategory?.id,
          name: homeCont.listingModel?.subSubCategory?.name,
          categoryId: homeCont.listingModel?.category?.id.toString(),
          subCategoryId: homeCont.listingModel?.subCategory?.id.toString(),
          category: subSub.Category(
            id: homeCont.listingModel?.category?.id,
            name: homeCont.listingModel?.category?.name,
            icon: homeCont.listingModel?.category?.icon,
          ),
          subCategory: subSub.SubCategory(
            id: homeCont.listingModel?.subCategory?.id,
            name: homeCont.listingModel?.subCategory?.name,
            categoryId: homeCont.listingModel?.category?.id.toString(),
          ),
        );
      }

      homeCont.furnished = homeCont
              .listingModel?.additionalFeatures?.listingDetails?.furnished ??
          "";
      homeCont.jobType =
          homeCont.listingModel?.additionalFeatures?.listingDetails?.jobType ??
              "";
      homeCont.modelController.text =
          homeCont.listingModel?.additionalFeatures?.listingDetails?.model ??
              "";
      homeCont.makeController.text =
          homeCont.listingModel?.additionalFeatures?.listingDetails?.make ?? "";
      homeCont.titleCont.text = homeCont.listingModel?.title ?? "";
      homeCont.priceCont?.text = homeCont.listingModel?.price.toString() ?? "0";
      homeCont.selectedCurrency = homeCont.listingModel?.currency ?? "USD";
      homeCont.descriptionCont.text = homeCont.listingModel?.description ?? "";
      locationCont.locationEditingController.value.text =
          homeCont.listingModel?.address ?? "";
      homeCont.listingModel?.tag?.forEach((element) {
        homeCont.tags.add(element);
      });
      homeCont.youTubeController.text =
          homeCont.listingModel?.additionalFeatures?.videoLink ?? "";
      homeCont.phoneController.text = homeCont
              .listingModel?.additionalFeatures?.optionalDetails?.phoneNumber ??
          "";
      homeCont.websiteController.text =
          homeCont.listingModel?.additionalFeatures?.optionalDetails?.website ??
              "";
      homeCont.conditionController.text = homeCont
              .listingModel?.additionalFeatures?.optionalDetails?.condition ??
          "";
      homeCont.fulfillmentController.text = homeCont
              .listingModel?.additionalFeatures?.optionalDetails?.fulfillment ??
          "";
      homeCont.paymentController.text =
          homeCont.listingModel?.additionalFeatures?.optionalDetails?.payment ??
              "";
      homeCont.lat = homeCont.listingModel?.latitude;
      homeCont.lng = homeCont.listingModel?.longitude;
      homeCont.addressCont.text = homeCont.listingModel?.address ??
          "${authCont.user?.province},${authCont.user?.city}";
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Your function to be executed after the UI is built
        getData();
      });
    }
    super.initState();
  }

  final TextEditingController textEditingController = TextEditingController();
  late ScrollController _scrollController;
  void imagePickerOption(String imageType) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick Image From'.tr,
                    style: TextStyle(
                        fontSize: 22..h,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black),
                  ),
                  SizedBox(
                    height: 40..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImage(ImageSource.camera, imageType);
                          Get.back();
                        });
                      },
                      child: MyButton(text: 'Camera'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        pickImage(ImageSource.gallery, imageType);
                        Get.back();
                      },
                      child: MyButton(text: 'Gallery'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60..h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColors.k0xFFA9ABAC,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Cancel'.tr,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///===================================================================================================Pick image
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source, String imageFirst) async {
    try {
      homeCont.isLoadingImages.value = true;
      List<XFile> images = [];

      if (source == ImageSource.camera) {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null && pickedFile.path.isNotEmpty) {
          images = [pickedFile];
        }
      } else {
        images = await _picker.pickMultiImage();
      }

      if (images.isEmpty) return;

      final tempDir = await getTemporaryDirectory();

      await Future.wait(images.map((element) async {
        try {
          final fileName =
              'normalized_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final normalizedPath = '${tempDir.path}/$fileName';

          // Create uploading progress tracker
          final uploadingImage = UploadingImage(
            path: element.path,
          );

          setState(() {
            homeCont.uploadingImages.add(uploadingImage);
          });
          print('homeCont.uploadingImages:${homeCont.uploadingImages.length}');

          // Update progress to 10% (starting)
          setState(() {
            uploadingImage.progress = 0.1;
          });

          // Read original file
          final originalFile = File(element.path);
          final img.Image? image =
              img.decodeImage(await originalFile.readAsBytes());
          if (image == null) {
            setState(() {
              homeCont.uploadingImages.remove(uploadingImage);
            });
            return;
          }

          // Update progress to 30% (read complete)
          setState(() {
            uploadingImage.progress = 0.3;
          });

          // Normalize and compress image
          final normalizedFile = File(normalizedPath);
          await normalizedFile.writeAsBytes(img.encodeJpg(image, quality: 50));

          // Update progress to 70% (normalization complete)
          setState(() {
            uploadingImage.progress = 0.7;
            uploadingImage.path =
                normalizedPath; // Update path to normalized image
          });

          if (await normalizedFile.exists()) {
            homeCont.postImages.add(normalizedPath);

            // Complete progress
            setState(() {
              uploadingImage.progress = 1.0;
              uploadingImage.isUploading = false;
              uploadingImage.isUploaded = true;
            });
          }

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          print('Error processing image: $e');
        }
      }));

      homeCont.update();
    } catch (e) {
      print('Error in pickImage: $e');
    } finally {
      homeCont.isLoadingImages.value = false;
    }
  }

  CustomCitiesList? city;
  CustomProvinceNameList? province;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<HomeController>(
          builder: (cont) {
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 90..w,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    widget.isUpdate
                                        ? Get.back()
                                        : Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Navigation_Bar(),
                                            ));
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50..h),
                      Row(
                        children: [
                          Container(
                            height: 60..h,
                            width: 60..w,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CachedNetworkImage(
                              height: 35..h,
                              width: 35..w,
                              imageUrl: authCont.isBusinessAccount
                                  ? "${authCont.user?.businessLogo}"
                                  : "${authCont.user?.profileImage}",
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 60..h,
                                width: 60..w,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    shape: BoxShape.circle),
                              ),
                              placeholder: (context, url) => SizedBox(
                                  height: 60..h,
                                  width: 60..w,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ))),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          SizedBox(
                            width: 10..h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectionArea(
                                child: Text(
                                  !authCont.isBusinessAccount
                                      ? "${authCont.user?.firstName} ${authCont.user?.lastName}"
                                      : "${authCont.user?.businessName}",
                                  style: TextStyle(
                                    fontSize: 14..sp,
                                    color: AppColors.k0xFF0254B8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10..h,
                              ),
                              SizedBox(
                                width: 230.w,
                                child: SelectionArea(
                                  child: Text(
                                    '${"Posting in".tr} ${cont.selectedCategory?.name}'
                                        .tr,
                                    style: TextStyle(
                                        fontSize: 16..sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 50..h),
                      if (cont.postImages.length == 0 &&
                          homeCont.uploadingImages != 0)
                        GestureDetector(
                          onTap: () async {
                            if (homeCont.postImages.length >= 20) {
                              errorAlertToast(
                                  "You can select only 20 images".tr);
                            } else {
                              imagePickerOption('image');

                              if (authCont.user?.province != null &&
                                  authCont.user?.city != null)
                                homeCont.addressCont.text =
                                    "${authCont.user?.province}, ${authCont.user?.city}";
                              homeCont.getLatLong("${authCont.user?.city}",
                                  "${authCont.user?.province}");

                              setState(() {});
                              // pickImage(ImageSource.gallery, "");
                            }
                          },
                          child: Container(
                            height: 165..h,
                            width: MediaQuery.of(context).size.width,
                            child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: AppColors.k0xFFC4C4C4,
                                // Border color
                                strokeWidth: 1,
                                // Border width
                                radius: Radius.circular(10),
                                child: Container(
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/images/upload.png'),
                                        Text(
                                          'Upload Your Image Here'.tr,
                                          style: TextStyle(
                                              fontSize: 13..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.black),
                                        ),
                                        Text(
                                          'Maximum 50mb Size'.tr,
                                          style: TextStyle(
                                              fontSize: 10..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        )
                      else
                        SizedBox(),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        height: homeCont.uploadingImages.isEmpty ? 0 : 120.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            final image = homeCont.uploadingImages[index];
                            return Row(
                              children: [
                                Stack(
                                  children: [
                                    DottedBorder(
                                      borderType: BorderType.RRect,
                                      color: AppColors.k0xFFC4C4C4,
                                      strokeWidth: 1,
                                      radius: Radius.circular(10),
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            File(image.path),
                                            width: 140.w,
                                            height: 120.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Upload progress overlay
                                    if (image.isUploading)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: image.progress,
                                                    strokeWidth: 3,
                                                    backgroundColor:
                                                        Colors.white30,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            AppColors
                                                                .k0xFF0254B8),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '${(image.progress * 100).toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Remove button
                                    Positioned(
                                      top: 3.h,
                                      right: 15.w,
                                      child: InkWell(
                                        onTap: () {
                                          cont.postImages.removeAt(index);
                                          cont.update();
                                          setState(() {
                                            homeCont.uploadingImages
                                                .removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black38,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Cover indicator
                                    Positioned(
                                      top: 3.h,
                                      left: 5.w,
                                      child: Visibility(
                                        visible: index == 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.black38,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2.0.w,
                                                vertical: 1.h),
                                            child: Text(
                                              "cover".tr,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(width: 10),
                                if (homeCont.uploadingImages.length ==
                                    index + 1)
                                  InkWell(
                                    onTap: () {
                                      if (homeCont.uploadingImages.length >=
                                          20) {
                                        errorAlertToast(
                                            "You can select only 20 images".tr);
                                      } else {
                                        imagePickerOption("image");
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: AppColors.k0xFFC4C4C4,
                                          strokeWidth: 1,
                                          radius: Radius.circular(10),
                                          child: Obx(
                                            () => Container(
                                              width: 140.w,
                                              height: 120.h,
                                              child: homeCont
                                                      .isLoadingImages.isTrue
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          size: 30,
                                                        ),
                                                        CustomText(
                                                          text: "Add Photo".tr,
                                                          fontSize: 20,
                                                        )
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(width: 0.w);
                          },
                          itemCount: homeCont.uploadingImages.length,
                        ),
                      ),
                      SelectionArea(
                        child: Text(
                          'Photos: '.tr +
                              homeCont.uploadingImages.length.toString() +
                              '/20 Select your cover photo first, include picture with different angles and details'
                                  .tr,
                          style: TextStyle(
                              fontSize: 14..sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.k0xFFA9ABAC),
                        ),
                      ),
                      SizedBox(height: 15..h),
                      Container(
                        height: 58..h,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                        child: TextField(
                          controller: cont.titleCont,
                          decoration: InputDecoration(
                            hintText: "Title".tr,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                            CapitalizeFirstLetterFormatter(),
                            LengthLimitingTextInputFormatter(60),
                          ],
                          cursorColor: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 15..h),
                      InkWell(
                        onTap: cont.loadingSubCategory == true ||
                                cont.loadingCategory == true
                            ? () {}
                            : () async {
                                cont.isNavigate = false;
                                print(cont.selectedSubSubCategory?.name);
                                print("cont.selectedSubSubCategory");
                                if (cont.selectedSubSubCategory != null) {
                                  cont.isType = 2;
                                  cont.update();
                                  await cont.getSubCategories();
                                  await cont.getSubSubCategories();
                                  cont.loadingCategory = false.obs;
                                  cont.update();
                                  showBottomSheetDropDown(context);
                                } else if (cont.selectedSubCategory != null) {
                                  cont.isType = 1;
                                  cont.update();
                                  await cont.getSubCategories();
                                  cont.loadingCategory = false.obs;
                                  cont.update();
                                  showBottomSheetDropDown(context);
                                } else {
                                  cont.isType = 0;
                                  cont.loadingCategory = false.obs;
                                  cont.update();
                                  cont.getCategories();
                                  showBottomSheetDropDown(context);
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          height: 58..h,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color:
                                      AppColors.k0xFFA9ABAC.withOpacity(.33))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectionArea(
                                  child: cont.selectedCategory == null
                                      ? Text('please select category'.tr)
                                      : Text(cont.selectedSubSubCategory != null
                                          ? "${cont.selectedSubSubCategory?.name}"
                                          : cont.selectedSubCategory != null
                                              ? "${cont.selectedSubCategory?.name}"
                                              : "${homeCont.selectedCategory?.name}")),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15..h),
                      Container(
                        height: 58..h,
                        padding: EdgeInsets.all(10..r),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                        child: Row(
                          children: [
                            SizedBox(width: 7..w),
                            Expanded(
                              child: TextField(
                                maxLength: 9,
                                controller: cont.priceCont,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Price (Optional)".tr,
                                  hintStyle: TextStyle(fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 10),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                cursorColor: AppColors.black,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Text("Currency".tr),
                                  items: ['USD', 'MLC', 'CUP']
                                      .map((currency) =>
                                          DropdownMenuItem<String>(
                                            value: currency,
                                            child: Text(currency),
                                          ))
                                      .toList(),
                                  value: cont.selectedCurrency != null &&
                                          ['USD', 'MLC', 'CUP']
                                              .contains(cont.selectedCurrency)
                                      ? cont.selectedCurrency
                                      : 'USD', // Fallback to 'USD' if invalid or null
                                  onChanged: (value) {
                                    cont.selectedCurrency = value;
                                    cont.update(); // Trigger UI rebuild
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 40,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15..h),
                      Container(
                        // height: 160..h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 35..h,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: AppColors.k0xFFC4C4C4.withOpacity(.2)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_bold,
                                      size: 15,
                                      color: _isBold
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: _toggleBold,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_italic,
                                      size: 15,
                                      color: _isItalic
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: _toggleItalic,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_underline,
                                      size: 15,
                                      color: _isUnderlined
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: _toggleUnderline,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_align_left,
                                      size: 15,
                                      color: _textAlignment == TextAlign.left
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: () => _setAlignment(
                                        TextAlign.left, Colors.black),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_align_center,
                                      size: 15,
                                      color: _textAlignment == TextAlign.center
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: () => _setAlignment(
                                        TextAlign.center, Colors.black),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.format_align_right,
                                      size: 15,
                                      color: _textAlignment == TextAlign.right
                                          ? AppColors.black
                                          : AppColors.k0xFFA9ABAC,
                                    ),
                                    onPressed: () => _setAlignment(
                                        TextAlign.right, Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              maxLength: 60000,
                              controller: cont.descriptionCont,
                              textAlign: _textAlignment,
                              style: TextStyle(
                                fontWeight: _isBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontStyle: _isItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                decoration: _isUnderlined
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                              maxLines: 5,
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter,
                                CapitalizeFirstLetterFormatter(),
                              ],
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10)),
                              cursorColor: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40..h),
                      Visibility(
                        visible: cont.selectedCategory?.name ==
                                    "Cars & Bikes" ||
                                cont.selectedCategory?.name == "Real Estate" ||
                                cont.selectedCategory?.name == "Services"
                            ? true
                            : false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Listing Details',
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black),
                            ),
                            InkWell(
                                onTap: () {
                                  cont.showBelowFields[5] == 2
                                      ? cont.showBelowFields[5] = 0
                                      : cont.showBelowFields[5] = 2;
                                  cont.update();
                                },
                                child: cont.showBelowFields[5] == 2
                                    ? Icon(Icons.arrow_drop_up)
                                    : Icon(Icons.arrow_drop_down))
                          ],
                        ),
                      ),
                      Divider(),
                      Visibility(
                          visible: cont.showBelowFields[5] == 2 ? true : false,
                          child: cont.selectedCategory?.name == "Cars & Bikes"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    Container(
                                      height: 58..h,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: AppColors.k0xFFA9ABAC
                                                  .withOpacity(.33))),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Make (Optional)",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                        ),
                                        cursorColor: AppColors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5..h,
                                    ),
                                    Container(
                                      height: 58..h,
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: AppColors.k0xFFA9ABAC
                                                  .withOpacity(.33))),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Model (Optional)",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                        ),
                                        cursorColor: AppColors.black,
                                      ),
                                    ),
                                  ],
                                )
                              : cont.selectedCategory?.name == "Real Estate"
                                  ? Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 18),
                                          height: 58..h,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: AppColors.k0xFFA9ABAC
                                                      .withOpacity(.33))),
                                          child: DropdownButton(
                                              onTap: () {
                                                print(
                                                    ">>>>>>>>>>>>>>>>>>>>>>>>>>>>ggggg");
                                              },
                                              hint: Text('Furnished'),
                                              underline: SizedBox(),
                                              isExpanded: true,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              value: valueChoose,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  valueChoose =
                                                      newValue as String?;
                                                });
                                              },
                                              items: listItem.map((valueItem) {
                                                return DropdownMenuItem(
                                                  value: valueItem,
                                                  child: Text(valueItem),
                                                );
                                              }).toList()),
                                        )
                                      ],
                                    )
                                  : cont.selectedCategory?.name == "Services"
                                      ? Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 18),
                                              height: 58..h,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: AppColors
                                                          .k0xFFA9ABAC
                                                          .withOpacity(.33))),
                                              child: DropdownButton(
                                                  hint: Text('Job Type'),
                                                  underline: SizedBox(),
                                                  isExpanded: true,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  value: valueChooseJob,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      valueChooseJob =
                                                          newValue as String?;
                                                    });
                                                  },
                                                  items: jobListItem
                                                      .map((valueItem) {
                                                    return DropdownMenuItem(
                                                      value: valueItem,
                                                      child: Text(valueItem),
                                                    );
                                                  }).toList()),
                                            )
                                          ],
                                        )
                                      : SizedBox()),
                      SizedBox(height: 5.h),
                      InkWell(
                        onTap: () {
                          cont.showBelowFields[0] == 1
                              ? cont.showBelowFields[0] = 0
                              : cont.showBelowFields[0] = 1;
                          // cont.update();
                          setState(() {
                            // cont.showBelowFields[0] == 1 ? true : false;
                            if (cont.showBelowFields[0] == 1) {
                              _controller.forward();
                            } else if (cont.showBelowFields[0] == 0) {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tags'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black),
                            ),
                            cont.showBelowFields[0] == 1
                                ? Icon(Icons.arrow_drop_up)
                                : Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                      SlideTransition(
                        position: _offsetAnimation,
                        child: Visibility(
                          visible: cont.showBelowFields[0] == 1 ? true : false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15..h,
                              ),
                              SelectionArea(
                                child: Text(
                                  'Increase your ad exposure. Enter up to 5 keywords buyers could search to find your ad'
                                      .tr,
                                  style: TextStyle(
                                      fontSize: 14..sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.k0xFFA9ABAC),
                                ),
                              ),
                              SizedBox(
                                height: 15..h,
                              ),
                              TextField(
                                cursorColor: AppColors.black,
                                controller: cont.tagsController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33)),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33)),
                                  ),
                                  hintText:
                                      // cont.tags.isNotEmpty ? '' :
                                      "Enter tags...".tr,
                                  prefixIconConstraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width),
                                ),
                                onSubmitted: (value) {
                                  if (cont.tags.length < 5) {
                                    cont.tags.add(value);
                                  } else {
                                    errorAlertToast(
                                        "maximum tags allowed are 5.".tr);
                                  }

                                  cont.tagsController.clear();
                                  cont.update();
                                },
                              ),
                              SizedBox(height: 8..h),
                              cont.tags.isNotEmpty
                                  ? Wrap(
                                      spacing: 5..w,
                                      runSpacing: 5..h,
                                      children: cont.tags.map((String tag) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            color: Color.fromARGB(
                                                255, 74, 137, 92),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                child: SelectionArea(
                                                  child: Text(
                                                    '#$tag',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                onTap: () {
                                                  print("$tag selected");
                                                },
                                              ),
                                              const SizedBox(width: 4.0),
                                              InkWell(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 14.0,
                                                  color: Color.fromARGB(
                                                      255, 233, 233, 233),
                                                ),
                                                onTap: () {
                                                  cont.tags.remove(tag);
                                                  cont.update();
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: cont.showBelowFields[0] == 1 ? 15.h : 5.h),
                      Divider(),
                      InkWell(
                        onTap: () async {
                          SharedPreferences share =
                              await SharedPreferences.getInstance();
                          setState(() {
                            cont.showBelowFields[1] == 2
                                ? cont.showBelowFields[1] = 0
                                : cont.showBelowFields[1] = 2;

                            if (cont.showBelowFields[1] == 2) {
                              _controller.forward();
                            } else if (cont.showBelowFields[1] == 0) {
                              _controller.reverse();
                            }
                          });
                          if (authCont.user?.province != null &&
                              authCont.user?.city != null)
                            homeCont.addressCont.text =
                                "${authCont.user?.province}, ${authCont.user?.city}";
                          homeCont.lat1 = share.getString("lat")!;
                          homeCont.lng1 = share.getString("lng")!;
                          print("homeCont.lat1111111111111");
                          print(homeCont.lng1);
                          // cont.update();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SelectionArea(
                              child: Text(
                                'Set pick up location'.tr,
                                style: TextStyle(
                                    fontSize: 18..sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black),
                              ),
                            ),
                            cont.showBelowFields[1] == 2
                                ? Icon(Icons.arrow_drop_up)
                                : Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                      SlideTransition(
                        position: _offsetAnimation,
                        child: Visibility(
                          visible: cont.showBelowFields[1] == 2 ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10..h),
                              Column(
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    height: 58..h,
                                    // padding: EdgeInsets.only(left: 10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: AppColors.k0xFFA9ABAC
                                                .withOpacity(.33))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<
                                          CustomProvinceNameList>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Select province'.tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        iconStyleData:
                                            IconStyleData(iconSize: 0),
                                        items: provinceName
                                            .map((item) => DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    "${item.provinceName}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        value: province,
                                        onChanged: (value) {
                                          setState(() {
                                            if (city != null) {
                                              city = null;
                                              province = value;
                                            } else {
                                              province = value;
                                            }
                                            // province?.provinceName = "${selectedValue!.provinceName}";
                                            print(
                                                ".............${province?.provinceName}");
                                          });
                                        },

                                        buttonStyleData: const ButtonStyleData(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 40,
                                        ),
                                        dropdownStyleData:
                                            const DropdownStyleData(
                                                maxHeight: 600,
                                                useRootNavigator: true),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                        ),
                                        dropdownSearchData: DropdownSearchData(
                                          searchController:
                                              textEditingController,
                                          searchInnerWidgetHeight: 50,
                                          searchInnerWidget: Container(
                                            height: 50,
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: TextFormField(
                                              // expands: true,
                                              // maxLines: null,
                                              controller: textEditingController,
                                              decoration: InputDecoration(
                                                // isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                hintText:
                                                    'Search your province',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value
                                                .toString()
                                                .contains(searchValue);
                                          },
                                        ),
                                        //This to clear the search value when you close the menu
                                        onMenuStateChange: (isOpen) {
                                          if (!isOpen) {
                                            textEditingController.clear();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: double.maxFinite,
                                    height: 58..h,
                                    // padding: EdgeInsets.only(left: 10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: AppColors.k0xFFA9ABAC
                                                .withOpacity(.33))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<CustomCitiesList>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Select city'.tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        iconStyleData:
                                            IconStyleData(iconSize: 0),
                                        value: city,
                                        items: citiesList
                                            .where((element) =>
                                                element.provinceName.contains(
                                                    province?.provinceName ??
                                                        ""))
                                            .map((item) => DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    "${item.cityName}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),

                                        onChanged: (value) {
                                          setState(() {
                                            city = value;
                                            cont.lat = city!.latitude;
                                            cont.lng = city!.longitude;
                                            cont.addressCont.text =
                                                "${province!.provinceName}, ${city!.cityName}";
                                          });
                                        },

                                        buttonStyleData: const ButtonStyleData(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: 40,
                                        ),
                                        dropdownStyleData:
                                            const DropdownStyleData(
                                                maxHeight: 600,
                                                useRootNavigator: true),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                        ),
                                        dropdownSearchData: DropdownSearchData(
                                          searchController:
                                              textEditingController,
                                          searchInnerWidgetHeight: 50,
                                          searchInnerWidget: Container(
                                            height: 50,
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: TextFormField(
                                              controller: textEditingController,
                                              decoration: InputDecoration(
                                                // isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                hintText: 'Search your city',
                                                hintStyle: const TextStyle(
                                                    fontSize: 16),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return item.value
                                                .toString()
                                                .contains(searchValue);
                                          },
                                        ),
                                        //This to clear the search value when you close the menu
                                        onMenuStateChange: (isOpen) {
                                          if (!isOpen) {
                                            textEditingController.clear();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   height: 55..h,
                                  //   width: MediaQuery.of(context).size.width,
                                  //   padding: EdgeInsets.symmetric(horizontal: 20),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(5.0),
                                  //     border: Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33)),
                                  //   ),
                                  //   child: DropdownButtonHideUnderline(
                                  //     child: DropdownButton(
                                  //       elevation: 0,
                                  //       value: dropdownvalue1,
                                  //       icon: SizedBox(),
                                  //       hint: Text('Select city'),
                                  //       items: (dropdownvalue == null)
                                  //           ? []
                                  //           : citiesList
                                  //               .where((element) => element.provinceName
                                  //                   .contains(dropdownvalue?.provinceName ?? ""))
                                  //               .map<DropdownMenuItem<CustomCitiesList>>((e) {
                                  //               return DropdownMenuItem<CustomCitiesList>(
                                  //                 value: e,
                                  //                 child: Text(e.cityName),
                                  //               );
                                  //             }).toList(),
                                  //       onChanged: (newValue) {
                                  //         setState(() {
                                  //           dropdownvalue1 = newValue as CustomCitiesList?;
                                  //           city = dropdownvalue1!.countryName;
                                  //         });
                                  //       },
                                  //       onTap: () {
                                  //         if (dropdownvalue == null) {
                                  //           Get.snackbar("", "message");
                                  //         }
                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              // Container(
                              //   height: searchCity?.length == 4
                              //       ? 200
                              //       : searchCity?.length == 3
                              //           ? 150
                              //           : searchCity?.length == 2
                              //               ? 100
                              //               : searchCity?.length == 1
                              //                   ? 40
                              //                   : height,
                              //   margin: const EdgeInsets.only(left: 10, right: 10.0, bottom: 0),
                              //   color: Colors.white.withOpacity(0.9),
                              //   child: SingleChildScrollView(
                              //     child: Column(
                              //       children: List.generate(
                              //         searchCity?.length ?? 0,
                              //         (index) => ListTile(
                              //           title: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             children: [
                              //               Text(
                              //                 searchCity?.length == 0
                              //                     ? ""
                              //                     : "${searchCity![index].provinceName}",
                              //                 style: TextStyle(
                              //                   fontSize: 16.sp,
                              //                   fontWeight: FontWeight.w600,
                              //                 ),
                              //               ),
                              //               index == searchCity!.length - 1 ? SizedBox() : Divider(),
                              //             ],
                              //           ),
                              //           onTap: () async {
                              //             cont.addressCont.clear();
                              //             province = "${searchCity![index].provinceName}";
                              //             FocusScope.of(context).unfocus();
                              //             cont.addressController.text = cont.addressCont.text;
                              //             setState(() {});
                              //             searchCity?.length = 0;
                              //             height = 0;
                              //             print(cont.addressCont.text);
                              //             print(cont.addressController.text);
                              //           },
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: searchCity?.length == 0 ? 5.h : 19.h),
                      Divider(),
                      InkWell(
                        onTap: () {
                          cont.showBelowFields[2] == 2
                              ? cont.showBelowFields[2] = 0
                              : cont.showBelowFields[2] = 2;
                          // cont.update();
                          setState(() {
                            // cont.showBelowFields[0] == 1 ? true : false;
                            if (cont.showBelowFields[2] == 2) {
                              _controller.forward();
                            } else if (cont.showBelowFields[2] == 0) {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SelectionArea(
                              child: Text(
                                'Optional details'.tr,
                                style: TextStyle(
                                    fontSize: 18..sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black),
                              ),
                            ),
                            cont.showBelowFields[2] == 2
                                ? Icon(Icons.arrow_drop_up)
                                : Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                      SlideTransition(
                        position: _offsetAnimation,
                        child: Visibility(
                          visible: cont.showBelowFields[2] == 2 ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.websiteController,
                                  decoration: InputDecoration(
                                    hintText: "Website (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: 5..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.phoneController,
                                  decoration: InputDecoration(
                                    hintText: "Phone number (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: 5..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.conditionController,
                                  decoration: InputDecoration(
                                    hintText: "Condition (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: 5..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.fulfillmentController,
                                  decoration: InputDecoration(
                                    hintText: "Fulfillment (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                              SizedBox(
                                height: 5..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.paymentController,
                                  decoration: InputDecoration(
                                    hintText: "Payment (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Divider(),
                      InkWell(
                        onTap: () {
                          cont.showBelowFields[3] == 2
                              ? cont.showBelowFields[3] = 0
                              : cont.showBelowFields[3] = 2;
                          // cont.update();
                          setState(() {
                            // cont.showBelowFields[0] == 1 ? true : false;
                            if (cont.showBelowFields[3] == 2) {
                              _controller.forward();
                            } else if (cont.showBelowFields[3] == 0) {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add a YouTube video'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black),
                            ),
                            cont.showBelowFields[3] == 2
                                ? Icon(Icons.arrow_drop_up)
                                : Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                      SlideTransition(
                        position: _offsetAnimation,
                        child: Visibility(
                          visible: cont.showBelowFields[3] == 2 ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10..h,
                              ),
                              Container(
                                height: 58..h,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.k0xFFA9ABAC
                                            .withOpacity(.33))),
                                child: TextField(
                                  controller: cont.youTubeController,
                                  decoration: InputDecoration(
                                    hintText: "Video link (Optional)".tr,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  cursorColor: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40..h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                cont.listingSaveDraft(context);
                              },
                              child: Container(
                                height: 50..h,
                                // width:
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color(0xFF0254B8),
                                    )),
                                child: Center(
                                  child: Text(
                                    'Save Draft'.tr,
                                    style: TextStyle(
                                        fontSize: 18..sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.black),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          widget.isUpdate
                              ? Flexible(
                                  child: InkWell(
                                    onTap: () {
                                      homeCont.lat = city?.latitude;
                                      homeCont.lng = city?.longitude;
                                      homeCont.addressCont.text =
                                          "${city?.provinceName}, ${city?.cityName}";
                                      cont.furnished = valueChoose ?? "";
                                      cont.jobType = valueChooseJob ?? "";
                                      // cont.addressCont.text =
                                      //     locationCont.locationEditingController.value.text;
                                      if (cont.titleCont.text.isEmpty) {
                                        errorAlertToast(
                                            "Please Enter Title".tr);
                                      } else if (cont
                                          .descriptionCont.text.isEmpty) {
                                        errorAlertToast(
                                            "Please Enter Description".tr);
                                      } else {
                                        cont.editListing(context);
                                      }
                                    },
                                    child: MyButton(
                                      text: 'Update'.tr,
                                    ),
                                  ),
                                )
                              : Flexible(
                                  child: InkWell(
                                    onTap: () {
                                      homeCont.lat = city?.latitude;
                                      homeCont.lng = city?.longitude;
                                      homeCont.addressCont.text =
                                          "${city?.provinceName}, ${city?.cityName}";
                                      cont.furnished = valueChoose ?? "";
                                      cont.jobType = valueChooseJob ?? "";
                                      if (cont.titleCont.text.isEmpty) {
                                        errorAlertToast(
                                            "Please Enter Title".tr);
                                      } else if (cont
                                          .descriptionCont.text.isEmpty) {
                                        errorAlertToast(
                                            "Please Enter Description".tr);
                                      } else if (cont.selectedCategory?.id ==
                                          null) {
                                        errorAlertToast("Category is required");
                                      } else {
                                        cont.addListing(context);
                                      }
                                    },
                                    child: MyButton(text: 'Publish'.tr),
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: 10..h),
                      Center(
                        child: SizedBox(
                          width: 300..w,
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text:
                                      'By posting your listing you agree to our '
                                          .tr,
                                ),
                                TextSpan(
                                  text: 'Terms of Use'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Get.to(TermsOfUse()),
                                ),
                                TextSpan(text: ' and '.tr),
                                TextSpan(
                                  text: 'Privacy Policy'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Get.to(PrivacyPolicy()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  showBottomSheetDropDown(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        // isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Container(
              // expand: false,
              height: Get.height * 0.8,
              // maxChildSize: 0.85,
              // minChildSize: 0.32,
              child: GetBuilder<HomeController>(
                builder: (cont) {
                  return Stack(
                    alignment: AlignmentDirectional.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -15,
                        child: Container(
                          height: 8,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10.h,
                                  bottom: 5.h,
                                  left: 10.w,
                                  right: 20.w),
                              child: InkWell(
                                onTap: () {
                                  Get.log("type ${cont.isType}");
                                  if (cont.isType == 0) {
                                    cont.selectedCategory = null;
                                    cont.selectedSubCategory = null;
                                    cont.selectedSubSubCategory = null;
                                    cont.update();
                                    Navigator.pop(context);
                                  } else {
                                    cont.isType = cont.isType - 1;
                                    cont.update();
                                  }
                                },
                                child: Icon(Icons.close),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20.w, right: 20.w, top: 10..h),
                                child: cont.loadingCategory.value
                                    ? Center(
                                        child: SizedBox(
                                          height: 30.h,
                                          width: 30.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        // controller: scrollController,
                                        itemCount: cont.isType == 0
                                            ? cont.categoriesModel?.data
                                                    ?.length ??
                                                0
                                            : cont.isType == 1
                                                ? cont.subCategoriesModel?.data
                                                        ?.length ??
                                                    0
                                                : cont.subSubCategoriesModel
                                                        ?.data?.length ??
                                                    0,
                                        itemBuilder: (context, index) {
                                          bool isShowSubCat = true;
                                          bool isShowCat = true;
                                          //cont.isSelect = index;
                                          //cont.update();
                                          if (cont.isType == 0) {
                                            isShowCat = cont.categoriesModel
                                                    ?.data?[index].status ??
                                                true;
                                          }
                                          if (cont.isType == 1) {
                                            isShowSubCat = cont
                                                    .subCategoriesModel
                                                    ?.data?[index]
                                                    .status ??
                                                true;
                                          }
                                          return InkWell(
                                            onTap: () {
                                              if (cont.isType == 0) {
                                                cont.selectedSubCategory = null;
                                                cont.selectedSubSubCategory =
                                                    null;
                                                cont.selectedCategory = cont
                                                    .categoriesModel
                                                    ?.data?[index];
                                                cont.selectedCategoryModel =
                                                    SelectedCategoryModel(
                                                        id: cont.categoriesModel
                                                            ?.data?[index].id,
                                                        name: cont
                                                            .categoriesModel
                                                            ?.data?[index]
                                                            .name,
                                                        icon: cont
                                                            .categoriesModel
                                                            ?.data?[index]
                                                            .icon,
                                                        type: 0);
                                                cont.isNavigate = false;
                                                cont.isSearchScreen = false;
                                                cont.update();
                                                cont.getSubCategories();
                                              } else if (cont.isType == 1) {
                                                cont.selectedSubSubCategory =
                                                    null;
                                                cont.selectedSubCategory = cont
                                                    .subCategoriesModel
                                                    ?.data?[index];
                                                cont.selectedCategoryModel =
                                                    SelectedCategoryModel(
                                                        id: cont
                                                            .subCategoriesModel
                                                            ?.data?[index]
                                                            .id,
                                                        name: cont
                                                            .subCategoriesModel
                                                            ?.data?[index]
                                                            .name,
                                                        icon: "",
                                                        type: 1);
                                                cont.isNavigate = false;
                                                cont.isSearchScreen = false;
                                                cont.getSubSubCategories();
                                                // cont.isSelect1 = index;
                                              } else {
                                                cont.selectedSubSubCategory =
                                                    cont.subSubCategoriesModel
                                                        ?.data?[index];
                                                cont.selectedCategoryModel =
                                                    SelectedCategoryModel(
                                                        id: cont
                                                            .subSubCategoriesModel
                                                            ?.data?[index]
                                                            .id,
                                                        name: cont
                                                            .subSubCategoriesModel
                                                            ?.data?[index]
                                                            .name,
                                                        icon: "",
                                                        type: 2);
                                                //   cont.isSelect2 = index;
                                                cont.update();
                                                Navigator.pop(context);
                                                print(cont
                                                    .selectedSubSubCategory);
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  cont.isType == 0
                                                      ? "${cont.categoriesModel?.data?[index].name}"
                                                      : cont.isType == 1
                                                          ? "${cont.subCategoriesModel?.data?[index].name}"
                                                          : "${cont.subSubCategoriesModel?.data?[index].name}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                Spacer(),
                                                cont.isType == 0
                                                    ? isShowCat
                                                        ? Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: 14..r)
                                                        : Container(
                                                            height: 15,
                                                            width: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(),
                                                            ),
                                                            child: cont.selectedCategory
                                                                        ?.id ==
                                                                    cont
                                                                        .categoriesModel
                                                                        ?.data?[
                                                                            index]
                                                                        .id
                                                                ? Container(
                                                                    height: 7,
                                                                    width: 7,
                                                                    margin: EdgeInsets
                                                                        .all(2),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .blue,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  )
                                                                : SizedBox(),
                                                          )
                                                    : cont.isType == 1
                                                        ? isShowSubCat
                                                            ? Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                size: 14..r)
                                                            : Container(
                                                                height: 15,
                                                                width: 15,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(),
                                                                ),
                                                                //   child: cont.isSelect1 == index
                                                                child: cont.selectedSubCategory
                                                                            ?.id ==
                                                                        cont
                                                                            .subCategoriesModel
                                                                            ?.data?[index]
                                                                            .id
                                                                    ? Container(
                                                                        height:
                                                                            7,
                                                                        width:
                                                                            7,
                                                                        margin:
                                                                            EdgeInsets.all(2),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.blue,
                                                                            shape: BoxShape.circle),
                                                                      )
                                                                    : SizedBox(),
                                                              )
                                                        : Container(
                                                            height: 15,
                                                            width: 15,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(),
                                                            ),
                                                            // child: cont.isSelect2 == index
                                                            child: cont.selectedSubSubCategory
                                                                        ?.id ==
                                                                    cont
                                                                        .subSubCategoriesModel
                                                                        ?.data?[
                                                                            index]
                                                                        .id
                                                                ? Container(
                                                                    height: 7,
                                                                    width: 7,
                                                                    margin: EdgeInsets
                                                                        .all(2),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .blue,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  )
                                                                : SizedBox(),
                                                          ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(
                                            height: 10.h,
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ));
        });
  }
}

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      return TextEditingValue(
        text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}

class PriceFormatter {
  String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return formatter.format(number);
  }

  String getCurrency(String? currency) {
    if (currency == null) {
      return 'USD';
    }
    String cur = '${currency == 'null' || currency.isEmpty ? 'USD' : currency}';

    return cur;
  }
}
