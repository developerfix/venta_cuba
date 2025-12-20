import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/cities_list/cites_list.dart';

class LocationDialog extends StatefulWidget {
  final List<CustomProvinceNameList>? initialProvinces;
  final List<CustomCitiesList>? initialCities;
  final bool? isAllProvinces;
  final bool? isAllCities;

  const LocationDialog({
    Key? key,
    this.initialProvinces,
    this.initialCities,
    this.isAllProvinces,
    this.isAllCities,
  }) : super(key: key);

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  List<CustomProvinceNameList> selectedProvinces = [];
  List<CustomCitiesList> selectedCities = [];
  bool isAllProvincesSelected = false;
  bool isAllCitiesSelected = false;

  @override
  void initState() {
    super.initState();
    selectedProvinces = widget.initialProvinces ?? [];
    selectedCities = widget.initialCities ?? [];
    isAllProvincesSelected = widget.isAllProvinces ?? false;
    isAllCitiesSelected = widget.isAllCities ?? false;
  }

  List<CustomCitiesList> getAvailableCities() {
    if (selectedProvinces.isEmpty || isAllProvincesSelected) {
      return [];
    }
    return citiesList.where((city) {
      return selectedProvinces.any((province) =>
        province.provinceName == city.provinceName
      );
    }).toList();
  }

  String getProvinceDisplayText() {
    if (isAllProvincesSelected) {
      return 'All provinces'.tr;
    } else if (selectedProvinces.isEmpty) {
      return 'Select province'.tr;
    } else if (selectedProvinces.length == 1) {
      return selectedProvinces[0].provinceName;
    } else {
      return '${selectedProvinces.length} ${"provinces".tr}';
    }
  }

  String getMunicipalityDisplayText() {
    if (selectedProvinces.isEmpty || isAllProvincesSelected) {
      return 'Choose a province first'.tr;
    } else if (isAllCitiesSelected) {
      return 'All municipalities'.tr;
    } else if (selectedCities.isEmpty) {
      return 'Select municipality'.tr;
    } else if (selectedCities.length == 1) {
      return selectedCities[0].cityName;
    } else {
      return '${selectedCities.length} ${"municipalities".tr}';
    }
  }

  Future<void> _openProvinceSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _ProvinceSelector(
          selectedProvinces: selectedProvinces,
          isAllProvincesSelected: isAllProvincesSelected,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedProvinces = result['provinces'] as List<CustomProvinceNameList>;
        isAllProvincesSelected = result['isAllProvinces'] as bool;

        // When provinces change, default to "All municipalities"
        selectedCities.clear();
        if (isAllProvincesSelected) {
          // If "All provinces" selected, disable municipalities
          isAllCitiesSelected = false;
        } else if (selectedProvinces.isNotEmpty) {
          // If specific provinces selected, default to "All municipalities"
          isAllCitiesSelected = true;
        } else {
          // If no provinces selected, clear municipalities
          isAllCitiesSelected = false;
        }
      });
    }
  }

  Future<void> _openMunicipalitySelector() async {
    if (selectedProvinces.isEmpty || isAllProvincesSelected) return;

    final availableCities = getAvailableCities();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _MunicipalitySelector(
          availableCities: availableCities,
          selectedCities: selectedCities,
          isAllCitiesSelected: isAllCitiesSelected,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCities = result['cities'] as List<CustomCitiesList>;
        isAllCitiesSelected = result['isAllCities'] as bool;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFF0254B8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Location'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provincia Label
                  Text(
                    'Provincia'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Province Selector
                  InkWell(
                    onTap: _openProvinceSelector,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getProvinceDisplayText(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: (isAllProvincesSelected || selectedProvinces.isNotEmpty)
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  : Colors.grey,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF0254B8),
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Municipio Label
                  Text(
                    'Municipio'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Municipality Selector
                  InkWell(
                    onTap: (selectedProvinces.isEmpty || isAllProvincesSelected)
                        ? null
                        : _openMunicipalitySelector,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: (selectedProvinces.isEmpty || isAllProvincesSelected)
                            ? Colors.grey.shade200
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: (selectedProvinces.isEmpty || isAllProvincesSelected)
                              ? Colors.grey.shade400
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey.shade300),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getMunicipalityDisplayText(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: (selectedProvinces.isEmpty || isAllProvincesSelected)
                                  ? Colors.grey.shade600
                                  : ((isAllCitiesSelected || selectedCities.isNotEmpty)
                                      ? (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      : Colors.grey),
                            ),
                          ),
                          Icon(
                            (selectedProvinces.isEmpty || isAllProvincesSelected)
                                ? Icons.lock_outline
                                : Icons.arrow_drop_down,
                            color: (selectedProvinces.isEmpty || isAllProvincesSelected)
                                ? Colors.grey.shade600
                                : Color(0xFF0254B8),
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer Buttons
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF2C2C2C)
                    : Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        side: BorderSide(
                          color: Color(0xFF0254B8),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0254B8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isAllProvincesSelected ||
                              selectedProvinces.isNotEmpty)
                          ? () {
                              // DEBUG: Print all available province names from dropdown
                              print("🔴🔴🔴 VENTA CUBA DEBUG START 🔴🔴🔴");
                              print("═══════════════════════════════════════════════════");
                              print("📋 DROPDOWN PROVINCE LIST (${provinceName.length} provinces):");
                              for (int i = 0; i < provinceName.length; i++) {
                                print("   ${i + 1}. '${provinceName[i].provinceName}'");
                              }
                              print("═══════════════════════════════════════════════════");
                              print("✅ USER SELECTED:");
                              if (isAllProvincesSelected) {
                                print("   All Provinces");
                              } else {
                                for (int i = 0; i < selectedProvinces.length; i++) {
                                  print("   ${i + 1}. '${selectedProvinces[i].provinceName}'");
                                }
                              }
                              print("═══════════════════════════════════════════════════");
                              print("🔴🔴🔴 VENTA CUBA DEBUG END 🔴🔴🔴");

                              Navigator.of(context).pop({
                                'provinces': selectedProvinces,
                                'cities': selectedCities,
                                'isAllProvinces': isAllProvincesSelected,
                                'isAllCities': isAllCitiesSelected,
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0254B8),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Apply'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Province Selector Screen
class _ProvinceSelector extends StatefulWidget {
  final List<CustomProvinceNameList> selectedProvinces;
  final bool isAllProvincesSelected;

  const _ProvinceSelector({
    required this.selectedProvinces,
    required this.isAllProvincesSelected,
  });

  @override
  State<_ProvinceSelector> createState() => _ProvinceSelectorState();
}

class _ProvinceSelectorState extends State<_ProvinceSelector> {
  late List<CustomProvinceNameList> tempSelectedProvinces;
  late bool tempIsAllProvincesSelected;

  @override
  void initState() {
    super.initState();
    tempSelectedProvinces = List.from(widget.selectedProvinces);
    tempIsAllProvincesSelected = widget.isAllProvincesSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0254B8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Provincia'.tr,
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'provinces': tempSelectedProvinces,
                'isAllProvinces': tempIsAllProvincesSelected,
              });
            },
            child: Text(
              'Done'.tr,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // All provinces option
          InkWell(
            onTap: () {
              setState(() {
                tempIsAllProvincesSelected = !tempIsAllProvincesSelected;
                if (tempIsAllProvincesSelected) {
                  tempSelectedProvinces.clear();
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: tempIsAllProvincesSelected
                    ? Color(0xFF0254B8).withValues(alpha: 0.1)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All provinces'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: tempIsAllProvincesSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (tempIsAllProvincesSelected)
                    Icon(Icons.check, color: Color(0xFF0254B8), size: 24.sp),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1),
          // Individual provinces
          ...provinceName.map((province) {
            final isSelected = tempSelectedProvinces.contains(province);
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      tempIsAllProvincesSelected = false;
                      if (isSelected) {
                        tempSelectedProvinces.remove(province);
                      } else {
                        tempSelectedProvinces.add(province);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF0254B8).withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            province.provinceName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: Color(0xFF0254B8), size: 24.sp),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Municipality Selector Screen
class _MunicipalitySelector extends StatefulWidget {
  final List<CustomCitiesList> availableCities;
  final List<CustomCitiesList> selectedCities;
  final bool isAllCitiesSelected;

  const _MunicipalitySelector({
    required this.availableCities,
    required this.selectedCities,
    required this.isAllCitiesSelected,
  });

  @override
  State<_MunicipalitySelector> createState() => _MunicipalitySelectorState();
}

class _MunicipalitySelectorState extends State<_MunicipalitySelector> {
  late List<CustomCitiesList> tempSelectedCities;
  late bool tempIsAllCitiesSelected;

  @override
  void initState() {
    super.initState();
    tempSelectedCities = List.from(widget.selectedCities);
    tempIsAllCitiesSelected = widget.isAllCitiesSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0254B8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Municipio'.tr,
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'cities': tempSelectedCities,
                'isAllCities': tempIsAllCitiesSelected,
              });
            },
            child: Text(
              'Done'.tr,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // All municipalities option
          InkWell(
            onTap: () {
              setState(() {
                tempIsAllCitiesSelected = !tempIsAllCitiesSelected;
                if (tempIsAllCitiesSelected) {
                  tempSelectedCities.clear();
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: tempIsAllCitiesSelected
                    ? Color(0xFF0254B8).withValues(alpha: 0.1)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All municipalities'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: tempIsAllCitiesSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (tempIsAllCitiesSelected)
                    Icon(Icons.check, color: Color(0xFF0254B8), size: 24.sp),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1),
          // Individual cities
          ...widget.availableCities.map((city) {
            final isSelected = tempSelectedCities.contains(city);
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      tempIsAllCitiesSelected = false;
                      if (isSelected) {
                        tempSelectedCities.remove(city);
                      } else {
                        tempSelectedCities.add(city);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF0254B8).withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            city.cityName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: Color(0xFF0254B8), size: 24.sp),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
