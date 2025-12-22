import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';

class ServiceComplaintController extends GetxController {
  // Service Types from API
  final RxList<String> serviceTypes = <String>[].obs;
  final RxMap<String, String> serviceTypeNames = RxMap({});
  final isLoadingServiceTypes = false.obs;

  // Branches
  final List<String> branches = [
    'Central',
    'Sub-cities',
    'Mesob',
  ];

  // Sub-branches based on main branch
  final RxMap<String, RxList<String>> subBranches = RxMap({
    'Central': RxList(['Addisu Gebeya', 'Megenagna', 'Lafto']),
    'Sub-cities': RxList([]), // Will be populated from API
    'Mesob': RxList(['Mesob Central', 'Mesob 2', 'Mesob 3']),
  });

  // IDs for sub-cities (name -> id)
  final RxMap<String, String> subCityIds = RxMap({});

  // Woredas based on sub-branch
  final RxMap<String, RxList<String>> woredas = RxMap({
    'Addisu Gebeya': RxList(['Woreda 1', 'Woreda 2', 'Woreda 3']),
    'Megenagna': RxList(['Woreda 1', 'Woreda 2']),
    'Lafto': RxList(['Woreda 1', 'Woreda 2', 'Woreda 3', 'Woreda 4']),
    // Sub-cities woredas will be populated from API
    'Mesob Central': RxList(['Woreda 1', 'Woreda 2', 'Woreda 3']),
    'Mesob 2': RxList(['Woreda 1', 'Woreda 2']),
    'Mesob 3': RxList(['Woreda 1']),
  });

  // Selected values
  final selectedServiceType = ''.obs;
  final selectedBranch = ''.obs; // Start with empty to hide sub-branches initially
  final selectedSubBranch = ''.obs;
  final selectedWoreda = ''.obs;

  // Text controller for description
  final TextEditingController descriptionController = TextEditingController();

  // Attachment
  final selectedFileName = ''.obs;
  File? selectedFile;
  final attachmentId = ''.obs;

  // Error messages
  final serviceTypeError = ''.obs;
  final branchError = ''.obs;
  final subBranchError = ''.obs;
  final woredaError = ''.obs;
  final descriptionError = ''.obs;

  Future<void> fetchServiceTypes() async {
    try {
      isLoadingServiceTypes.value = true;
      final response = await ApiService.to.get('https://crrsa-api.risertechservices.com/api/v1/portal-bff/reference-data/service-types');

      print('Service Types API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> serviceTypesJson = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          serviceTypesJson = data['data'] ?? [];
        } else if (data is List) {
          serviceTypesJson = data;
        }

        if (serviceTypesJson is! List) {
          serviceTypesJson = [];
        }

        // Extract service type codes and names
        List<String> codes = [];
        Map<String, String> names = {};
        for (var item in serviceTypesJson) {
          if (item is Map<String, dynamic>) {
            String? code = (item['code'] as String?) ?? (item['id'] as String?);
            String? name;
            if (item.containsKey('localizedContent') &&
                item['localizedContent'] is Map<String, dynamic> &&
                item['localizedContent']['en'] is Map<String, dynamic> &&
                item['localizedContent']['en']['name'] != null) {
              name = item['localizedContent']['en']['name'] as String;
            } else if (item.containsKey('name')) {
              name = item['name'] as String;
            }

            if (code != null && code.isNotEmpty && name != null && name.isNotEmpty) {
              codes.add(code);
              names[code] = name;
            }
          }
        }

        serviceTypes.value = codes;
        serviceTypeNames.value = names;
      } else {
        // On non-200 status, set empty
        serviceTypes.value = [];
      }
    } catch (e) {
      print('Service Types API Error: $e');
      // On exception, set empty
      serviceTypes.value = [];
    } finally {
      isLoadingServiceTypes.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize sub-branch based on selected branch
    updateSubBranchOptions();
    fetchServiceTypes();
  }

  Future<void> fetchSubCities() async {
    try {
      final response = await ApiService.to.get('https://crrsa-api.risertechservices.com/api/v1/portal-bff/reference-data/administrative-structures?level=SUBCITY&parentId=91cf3266-a2d9-46ba-ae8d-008050512d9e');

      print('Sub-cities API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> subCitiesJson = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          subCitiesJson = data['data'] ?? [];
        } else if (data is List) {
          subCitiesJson = data;
        }

        if (subCitiesJson is! List) {
          subCitiesJson = [];
        }

        // Extract names and ids
        List<String> names = [];
        Map<String, String> ids = {};
        for (var item in subCitiesJson) {
          if (item is Map<String, dynamic>) {
            String? name;
            String? id = item['id'] as String?;
            if (item.containsKey('localizedContent') &&
                item['localizedContent'] is Map<String, dynamic> &&
                item['localizedContent']['en'] is Map<String, dynamic> &&
                item['localizedContent']['en']['name'] != null) {
              name = item['localizedContent']['en']['name'] as String;
            } else if (item.containsKey('name')) {
              name = item['name'] as String;
            }

            if (name != null && name.isNotEmpty && id != null) {
              names.add(name);
              ids[name] = id;
            }
          } else if (item is String) {
            names.add(item);
          }
        }

        subBranches['Sub-cities']!.value = names;
        subCityIds.value = ids;
      } else {
        subBranches['Sub-cities']!.value = [];
      }
    } catch (e) {
      print('Sub-cities API Error: $e');
      subBranches['Sub-cities']!.value = [];
    }
  }

  void updateSubBranchOptions() {
    if (selectedBranch.value == 'Sub-cities') {
      // Fetch sub-cities from API
      fetchSubCities().then((_) {
        final subBranchList = subBranches[selectedBranch.value]?.value ?? [];
        if (subBranchList.isNotEmpty) {
          // If current selection is valid, keep it, else set to first
          if (!subBranchList.contains(selectedSubBranch.value)) {
            selectedSubBranch.value = subBranchList[0];
          }
          updateWoredaOptions();
        } else {
          selectedSubBranch.value = '';
          selectedWoreda.value = '';
        }
      });
    } else {
      final subBranchList = subBranches[selectedBranch.value]?.value ?? [];
      if (subBranchList.isNotEmpty) {
        // If current selection is not valid, clear it
        if (!subBranchList.contains(selectedSubBranch.value)) {
          selectedSubBranch.value = '';
          selectedWoreda.value = '';
        }
      } else {
        selectedSubBranch.value = '';
        selectedWoreda.value = '';
      }
    }
  }

  Future<void> fetchWoredas(String parentId) async {
    try {
      final response = await ApiService.to.get('https://crrsa-api.risertechservices.com/api/v1/portal-bff/reference-data/administrative-structures?level=WOREDA&parentId=$parentId');

      print('Woredas API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> woredasJson = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          woredasJson = data['data'] ?? [];
        } else if (data is List) {
          woredasJson = data;
        }

        if (woredasJson is! List) {
          woredasJson = [];
        }

        // Extract names
        List<String> names = [];
        for (var item in woredasJson) {
          if (item is Map<String, dynamic>) {
            String? name;
            if (item.containsKey('localizedContent') &&
                item['localizedContent'] is Map<String, dynamic> &&
                item['localizedContent']['en'] is Map<String, dynamic> &&
                item['localizedContent']['en']['name'] != null) {
              name = item['localizedContent']['en']['name'] as String;
            } else if (item.containsKey('name')) {
              name = item['name'] as String;
            }

            if (name != null && name.isNotEmpty) {
              names.add(name);
            }
          } else if (item is String) {
            names.add(item);
          }
        }

        // Update woredas for the selected sub-branch
        if (woredas.containsKey(selectedSubBranch.value)) {
          woredas[selectedSubBranch.value]!.value = names;
        } else {
          woredas[selectedSubBranch.value] = RxList(names);
        }
      } else {
        // On error, set empty
        if (woredas.containsKey(selectedSubBranch.value)) {
          woredas[selectedSubBranch.value]!.value = [];
        } else {
          woredas[selectedSubBranch.value] = RxList([]);
        }
      }
    } catch (e) {
      print('Woredas API Error: $e');
      // On error, set empty
      if (woredas.containsKey(selectedSubBranch.value)) {
        woredas[selectedSubBranch.value]!.value = [];
      } else {
        woredas[selectedSubBranch.value] = RxList([]);
      }
    }
  }

  void updateWoredaOptions() {
    if (selectedBranch.value == 'Sub-cities' && subCityIds.containsKey(selectedSubBranch.value)) {
      // Fetch woredas from API using the sub-city ID
      String parentId = subCityIds[selectedSubBranch.value]!;
      fetchWoredas(parentId).then((_) {
        final woredaList = woredas[selectedSubBranch.value]?.value ?? [];
        if (woredaList.isNotEmpty) {
          // If current selection is not valid, clear it
          if (!woredaList.contains(selectedWoreda.value)) {
            selectedWoreda.value = '';
          }
        } else {
          selectedWoreda.value = '';
        }
      });
    } else {
      final woredaList = woredas[selectedSubBranch.value]?.value ?? [];
      if (woredaList.isNotEmpty) {
        // If current selection is valid, keep it, else set to first
        if (!woredaList.contains(selectedWoreda.value)) {
          selectedWoreda.value = woredaList[0];
        }
      } else {
        selectedWoreda.value = '';
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  void pickAttachment() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedFile = File(pickedFile.path);
        selectedFileName.value = pickedFile.name;

        // Check file size (10MB limit)
        final fileSize = await selectedFile!.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB in bytes
          Get.snackbar(
            'Error',
            'File size must be less than 10MB',
            snackPosition: SnackPosition.BOTTOM,
          );
          selectedFile = null;
          selectedFileName.value = '';
        } else {
          // Upload the file automatically
          await uploadFile();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    try {
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(selectedFile!.path, filename: selectedFileName.value),
      });

      // Create a new Dio instance without interceptors to avoid FormData reuse issues
      final uploadDio = dio.Dio(dio.BaseOptions(
        baseUrl: 'https://crrsa-api.risertechservices.com/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Note: This endpoint appears to be public, so no authorization header added

      final response = await uploadDio.post('api/v1/storage/files/public', data: formData);

      print('Upload Response Body: ${response.data}');

      // Assuming response.data is a Map with 'id'
      if (response.data is Map<String, dynamic> && response.data.containsKey('id')) {
        attachmentId.value = response.data['id'].toString();
      }
    } catch (e) {
      print('Upload Error: $e');
    }
  }

  Future<void> submitComplaint() async {
    print('Submit Complaint called');
    // Clear previous errors
    serviceTypeError.value = '';
    branchError.value = '';
    subBranchError.value = '';
    woredaError.value = '';
    descriptionError.value = '';

    // Validation
    bool hasErrors = false;

    if (selectedServiceType.value.isEmpty) {
      serviceTypeError.value = 'Please select a service type';
      hasErrors = true;
    }

    if (selectedBranch.value.isEmpty) {
      branchError.value = 'Please select a branch';
      hasErrors = true;
    }

    if (selectedSubBranch.value.isEmpty) {
      subBranchError.value = 'Please select a sub-branch';
      hasErrors = true;
    }

    if (selectedBranch.value == 'Sub-cities' && selectedWoreda.value.isEmpty) {
      woredaError.value = 'Please select a woreda';
      hasErrors = true;
    }

    if (descriptionController.text.trim().isEmpty) {
      descriptionError.value = 'Please enter a description';
      hasErrors = true;
    }

    if (hasErrors) {
      return;
    }

    // Submit complaint to backend
    try {
      final data = {
        'type': 'SERVICE',
        'serviceType': selectedServiceType.value,
        'description': descriptionController.text,
        'structureId': selectedBranch.value == 'Sub-cities' ? (subCityIds[selectedSubBranch.value] ?? '') : '',
        'attachments': attachmentId.value.isNotEmpty ? [
          {
            'attachmentId': attachmentId.value,
            'description': 'Supporting document'
          }
        ] : [],
      };

      print('Posting to: https://crrsa-api.risertechservices.com/api/v1/complaint-service/complaints');
      print('Posting complaint data: $data');

      final response = await ApiService.to.post('api/v1/complaint-service/complaints', data: data);

      print('Complaint Submit Response: ${response.data}');

      Get.snackbar(
        'Success',
        'Complaint submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Submit Error: $e');
      Get.snackbar(
        'Error',
        'Failed to submit complaint',
        snackPosition: SnackPosition.BOTTOM,
      );
      return; // Don't reset on error
    }

    // Reset form
    selectedServiceType.value = '';
    selectedBranch.value = '';
    selectedSubBranch.value = '';
    selectedWoreda.value = '';
    descriptionController.clear();
    selectedFileName.value = '';
    selectedFile = null;
    attachmentId.value = '';

    // Clear errors
    serviceTypeError.value = '';
    branchError.value = '';
    subBranchError.value = '';
    woredaError.value = '';
    descriptionError.value = '';

    // Navigate back or to success page
    Get.back();
  }
}