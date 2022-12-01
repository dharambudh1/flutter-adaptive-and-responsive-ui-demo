import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:math" as math;

import "package:after_layout/after_layout.dart";
import "package:csc_picker/csc_picker.dart";
import "package:dynamic_height_grid_view/dynamic_height_grid_view.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_dropzone/flutter_dropzone.dart";
import "package:flutter_web_navigation/model/upload_cdn_model.dart";
import "package:flutter_web_navigation/model/users_info_model.dart";
import "package:flutter_web_navigation/singleton/color_utils.dart";
import "package:flutter_web_navigation/singleton/dio_singleton.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:flutter_web_navigation/singleton/picker_utils.dart";
import "package:flutter_web_navigation/utils/full_screen_loader.dart";
import "package:flutter_web_navigation/utils/responsive_utils.dart";
import "package:flutter_web_navigation/utils/string_extension.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:permission_handler/permission_handler.dart";
import "package:responsive_framework/responsive_framework.dart";

enum Title { mr, ms, mrs, miss, dr }

enum Gender { male, female, other }

class UserCreateScreen extends StatefulWidget {
  const UserCreateScreen({
    required this.queryParams,
    required this.extra,
    super.key,
  });

  final Map<String, dynamic>? queryParams;
  final Object? extra;

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen>
    with AfterLayoutMixin<UserCreateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _timeZoneController = TextEditingController();
  final TextEditingController _registerDateController = TextEditingController();
  final TextEditingController _updatedDateController = TextEditingController();

  Title _defaultTitle = Title.values.first;
  Gender _defaultGender = Gender.values.first;

  List<File> _filePaths = <File>[];
  final int _maxLength = 1;
  String _generatedFileURL = "";

  XFile webPickedFile = XFile("");
  Uint8List webImage = Uint8List(8);
  UsersInfoModel _usersInfoModel = UsersInfoModel();

  String _preFilledImageURL = "";

  Future<UsersInfoModel>? _future;

  String id = "";

  DropzoneViewController? _dropzoneCtrl;
  bool highlighted1 = false;

  void prePopulateAllData() {
    preFillDataToTextEditingController();
    preFillDataToRadioButton();
    preFillImageToImageWidget();
    setState(() {});
    return;
  }

  void preFillDataToTextEditingController() {
    _idController.text = _usersInfoModel.id ?? "";
    _firstNameController.text = _usersInfoModel.firstName ?? "";
    _lastNameController.text = _usersInfoModel.lastName ?? "";
    _emailController.text = _usersInfoModel.email ?? "";
    _birthDateController.text = _usersInfoModel.dateOfBirth ?? "";
    _phoneController.text = _usersInfoModel.phone ?? "";
    _streetController.text = _usersInfoModel.location?.street ?? "";
    _countryController.text = _usersInfoModel.location?.country ?? "";
    _stateController.text = _usersInfoModel.location?.state ?? "";
    _cityController.text = _usersInfoModel.location?.city ?? "";
    _timeZoneController.text = _usersInfoModel.location?.timezone ??
        generateRandomTimeZone().toString();
    _registerDateController.text = _usersInfoModel.registerDate ?? "";
    _updatedDateController.text = _usersInfoModel.updatedDate ?? "";
    return;
  }

  void preFillDataToRadioButton() {
    _defaultTitle = Title.values.firstWhere(
      (Title e) => e.name == _usersInfoModel.title,
      orElse: () => Title.values.first,
    );
    _defaultGender = Gender.values.firstWhere(
      (Gender e) => e.name == _usersInfoModel.gender,
      orElse: () => Gender.values.first,
    );
    return;
  }

  void preFillImageToImageWidget() {
    _preFilledImageURL = _usersInfoModel.picture ?? "";
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void generateRandomTimeZoneForTimeZoneController() {
    _timeZoneController.text = generateRandomTimeZone().toString();
    return;
  }

  Future<void> checkRedirectOrInitCall() async {
    id = widget.queryParams?["id"] ?? "";
    id.isEmpty ? redirect() : await initCall();
    return Future<void>.value();
  }

  void redirect() {
    _future = Future<UsersInfoModel>.value(UsersInfoModel());
    if (NavigationSingleton().router.location != NavigationSingleton.create) {
      NavigationSingleton().router.pushNamed(NavigationSingleton.create);
    }
    return;
  }

  Future<UsersInfoModel> initCall() async {
    final UsersInfoModel response = await DioSingleton().viewUser(
      id: id,
    );
    _future = Future<UsersInfoModel>.value(response);
    _usersInfoModel = response;
    prePopulateAllData();
    setState(() {});
    return Future<UsersInfoModel>.value(response);
  }

  @override
  void dispose() {
    super.dispose();
  }

  int generateRandomTimeZone() {
    final List<int> tz = <int>[];
    for (int i = -12; i <= 14; i++) {
      tz.add(i);
    }
    return tz[math.Random().nextInt(tz.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _usersInfoModel.id == null ? "Create user" : "Update user",
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              100,
            ),
            onTap: () {
              if (NavigationSingleton().router.canPop()) {
                NavigationSingleton().router.pop();
              } else {
                NavigationSingleton()
                    .router
                    .pushNamed(NavigationSingleton.home);
              }
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<UsersInfoModel>(
          future: _future,
          builder:
              (BuildContext context, AsyncSnapshot<UsersInfoModel> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.active:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                  );
                } else {
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: isMobilePhone(context)
                            ? mobilePhoneView()
                            : ResponsiveWrapper.of(context).isTablet
                                ? tabletView()
                                : ResponsiveWrapper.of(context).isDesktop
                                    ? desktopView()
                                    : const SizedBox(),
                      ),
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Widget tabletView() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: profilePictureWidget()),
            const SizedBox(width: 20),
            Expanded(child: dobWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: titleWidget()),
            const SizedBox(width: 20),
            Expanded(child: genderWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: firstNameWidget()),
            const SizedBox(width: 20),
            Expanded(child: streetWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: lastNameWidget()),
            const SizedBox(width: 20),
            Expanded(child: cscPickerWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: emailWidget()),
            const SizedBox(width: 20),
            Expanded(child: timeZoneWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: phoneWidget()),
            const SizedBox(width: 20),
            Expanded(child: submitButton()),
          ],
        ),
      ],
    );
  }

  Widget desktopView() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: profilePictureWidget()),
            const SizedBox(width: 20),
            Expanded(child: dobWidget()),
            const SizedBox(width: 20),
            Expanded(child: streetWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: titleWidget()),
            const SizedBox(width: 20),
            Expanded(child: genderWidget()),
            const SizedBox(width: 20),
            Expanded(child: cscPickerWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: firstNameWidget()),
            const SizedBox(width: 20),
            Expanded(child: emailWidget()),
            const SizedBox(width: 20),
            Expanded(child: timeZoneWidget()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: lastNameWidget()),
            const SizedBox(width: 20),
            Expanded(child: phoneWidget()),
            const SizedBox(width: 20),
            Expanded(child: submitButton()),
          ],
        ),
      ],
    );
  }

  Widget mobilePhoneView() {
    return Column(
      children: <Widget>[
        profilePictureWidget(),
        titleWidget(),
        firstNameWidget(),
        lastNameWidget(),
        genderWidget(),
        emailWidget(),
        dobWidget(),
        phoneWidget(),
        streetWidget(),
        cscPickerWidget(),
        timeZoneWidget(),
        submitButton(),
      ],
    );
  }

  Widget profilePictureWidget() {
    return Column(
      children: <Widget>[
        const Align(
          child: Text(
            "Profile picture",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        if (_preFilledImageURL != "")
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(100),
              ),
              border: Border.all(
                color: ColorUtils().borderColor(),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    child: Image.network(
                      _preFilledImageURL,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      _preFilledImageURL = "";
                      setState(() {});
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.delete,
                        color: ColorUtils().iconColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _filePaths.isNotEmpty
              ? Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    border: Border.all(
                      color: ColorUtils().borderColor(),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                          child: kIsWeb
                              ? Image.memory(
                                  webImage,
                                  fit: BoxFit.fill,
                                )
                              : Image.file(
                                  _filePaths[0],
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            _filePaths = List<File>.from(_filePaths)
                              ..removeAt(
                                0,
                              );
                            highlighted1 = false;
                            setState(() {});
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.delete,
                              color: ColorUtils().iconColor(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : imagePicker(),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget titleWidget() {
    return Column(
      children: <Widget>[
        const Align(
          child: Text(
            "Title",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        DynamicHeightGridView(
          shrinkWrap: true,
          itemCount: Title.values.length,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Title.values.length,
          crossAxisSpacing: Title.values.length.toDouble(),
          mainAxisSpacing: Title.values.length.toDouble(),
          builder: (BuildContext ctx, int index) {
            return InkWell(
              onTap: () {
                _defaultTitle = Title.values[index];
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Radio<Title>(
                      activeColor: Colors.blue,
                      groupValue: _defaultTitle,
                      value: Title.values[index],
                      onChanged: (Title? index) {
                        _defaultTitle = index ?? Title.values.first;
                        setState(() {});
                      },
                    ),
                    Text(
                      Title.values[index].name.caps(),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget firstNameWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "First name",
            ),
          ),
          controller: _firstNameController,
          keyboardType: TextInputType.name,
          validator: (String? value) {
            if (value == null || value.isEmpty || value.length < 2) {
              return "Please enter your first name";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget lastNameWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "Last name",
            ),
          ),
          controller: _lastNameController,
          keyboardType: TextInputType.name,
          validator: (String? value) {
            if (value == null || value.isEmpty || value.length < 2) {
              return "Please enter your last name";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget genderWidget() {
    return Column(
      children: <Widget>[
        const Align(
          child: Text(
            "Gender",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        DynamicHeightGridView(
          shrinkWrap: true,
          itemCount: Gender.values.length,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Gender.values.length,
          crossAxisSpacing: Gender.values.length.toDouble(),
          mainAxisSpacing: Gender.values.length.toDouble(),
          builder: (BuildContext ctx, int index) {
            return InkWell(
              onTap: () {
                _defaultGender = Gender.values[index];
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Radio<Gender>(
                      activeColor: Colors.blue,
                      groupValue: _defaultGender,
                      value: Gender.values[index],
                      onChanged: (Gender? index) {
                        _defaultGender = index ?? Gender.values.first;
                        setState(() {});
                      },
                    ),
                    Text(
                      Gender.values[index].name.caps(),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget emailWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "Email",
            ),
          ),
          controller: _emailController,
          enabled: _emailController.value.text.isEmpty,
          keyboardType: TextInputType.emailAddress,
          validator: (String? value) {
            if (!(value?.isValidEmail() ?? false)) {
              return "Please enter your email";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget dobWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "Date of birth",
            ),
          ),
          readOnly: true,
          controller: _birthDateController,
          keyboardType: TextInputType.datetime,
          validator: (String? value) {
            if (value == null || value.isEmpty || value.length < 5) {
              return "Please enter your date of birth";
            } else {
              return null;
            }
          },
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(
                const Duration(
                  days: 7,
                ),
              ),
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(
                const Duration(
                  days: 7,
                ),
              ),
            );
            if (pickedDate != null) {
              final String formattedDate = DateFormat("dd-MM-yyyy").format(
                pickedDate,
              );
              _birthDateController.text = formattedDate;
              setState(() {});
            } else {}
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget phoneWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "Phone",
            ),
          ),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (String? value) {
            if (value == null || value.isEmpty || value.length < 5) {
              return "Please enter your phone";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget streetWidget() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
            label: Text(
              "Street",
            ),
          ),
          controller: _streetController,
          keyboardType: TextInputType.streetAddress,
          validator: (String? value) {
            if (value == null || value.isEmpty || value.length < 5) {
              return "Please enter your street";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget cscPickerWidget() {
    return Column(
      children: <Widget>[
        const Align(
          child: Text(
            "Country, state & city",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        CSCPicker(
          dropdownDecoration: const BoxDecoration(),
          disabledDropdownDecoration: const BoxDecoration(),
          countryDropdownLabel: "Select country",
          countrySearchPlaceholder: "Search country",
          currentCountry: _countryController.text.isNotEmpty
              ? _countryController.text
              : null,
          stateDropdownLabel: "Select state",
          stateSearchPlaceholder: "Search state",
          currentState:
              _stateController.text.isNotEmpty ? _stateController.text : null,
          cityDropdownLabel: "Select city",
          citySearchPlaceholder: "Search city",
          currentCity:
              _cityController.text.isNotEmpty ? _cityController.text : null,
          flagState: CountryFlag.DISABLE,
          onCountryChanged: (String value) {
            _countryController.text = value;
          },
          onStateChanged: (String? value) {
            _stateController.text = value ?? "";
          },
          onCityChanged: (String? value) {
            _cityController.text = value ?? "";
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget timeZoneWidget() {
    return Column(
      children: <Widget>[
        Align(
          child: Text(
            "Timezone (random): ${_timeZoneController.value.text}",
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Register date: ${_registerDateController.value.text}",
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Updated date: ${_updatedDateController.value.text}",
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget submitButton() {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: submit,
          child: const Text("Submit"),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future<void> submit() async {
    if (_preFilledImageURL.isNotEmpty && _filePaths.isEmpty) {
      if (_formKey.currentState?.validate() ?? false) {
        unawaited(LoaderUtils().startLoading());
        _generatedFileURL = _preFilledImageURL;
        await getHttpResponse();
        LoaderUtils().stopLoading();
      } else {
        log("Validation bearer");
      }
      return Future<void>.value();
    } else if (_preFilledImageURL.isEmpty && _filePaths.isNotEmpty) {
      log("message");
      if (_formKey.currentState?.validate() ?? false) {
        unawaited(LoaderUtils().startLoading());
        final UploadCDNModel response = await uploadImage(
          file: _filePaths[0],
          webPickedFile: webPickedFile,
        );
        if (response.fileUrl != null) {
          await getHttpResponse();
        } else {
          log("UploadCDNModel response fileUrl is null");
        }
        LoaderUtils().stopLoading();
      } else {
        log("Validation bearer");
      }
      return Future<void>.value();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Profile picture is required",
          ),
        ),
      );
      return Future<void>.value();
    }
  }

  Future<UsersInfoModel> getHttpResponse() async {
    final UsersInfoModel usersInfoProvidedModel = UsersInfoModel(
      id: _idController.text,
      title: _defaultTitle.name,
      firstName: _firstNameController.value.text,
      lastName: _lastNameController.value.text,
      picture: _generatedFileURL,
      gender: _defaultGender.name,
      email: _emailController.value.text,
      dateOfBirth: _birthDateController.value.text,
      phone: _phoneController.value.text,
      location: Location(
        street: _streetController.value.text,
        city: _cityController.value.text,
        state: _stateController.value.text,
        country: _countryController.value.text,
        timezone: _timeZoneController.value.text,
      ),
      registerDate: _registerDateController.text,
      updatedDate: _updatedDateController.text,
    );
    final UsersInfoModel response =
        (usersInfoProvidedModel.id == null || usersInfoProvidedModel.id == "")
            ? await DioSingleton().createNewUser(
                usersInfoProvidedModel: usersInfoProvidedModel,
              )
            : await DioSingleton().updateExistingUser(
                usersInfoProvidedModel: usersInfoProvidedModel,
              );
    if (response.id != null) {
      await _showMyDialogModel(response);
      NavigationSingleton().router.pop();
    } else {}
    return Future<UsersInfoModel>.value(response);
  }

  Future<void> _showMyDialogModel(UsersInfoModel response) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("API Acknowledgment"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Unique ID: ${response.id ?? ""}'),
                Text('Title: ${response.title ?? ""}'),
                Text('First name: ${response.firstName ?? ""}'),
                Text('Last name: ${response.lastName ?? ""}'),
                Text('Gender: ${response.gender ?? ""}'),
                Text('Email: ${response.email ?? ""}'),
                Text('DOB: ${response.dateOfBirth ?? ""}'),
                Text('Phone: ${response.phone ?? ""}'),
                Text('Picture: ${response.picture ?? ""}'),
                Text('Street: ${response.location?.street ?? ""}'),
                Text('City: ${response.location?.city ?? ""}'),
                Text('State: ${response.location?.state ?? ""}'),
                Text('Country: ${response.location?.country ?? ""}'),
                Text('Timezone: ${response.location?.timezone ?? ""}'),
                Text('Register date: ${response.registerDate ?? ""}'),
                Text('Updated date: ${response.updatedDate ?? ""}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> onPressed(Function(List<File>) showMyDialogCallBack) async {
    return Future<void>.value(
      showBarModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        builder: (BuildContext context) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: PickerType.values.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(PickerType.values[index].name),
                leading: Icon(
                  index == 0 ? Icons.camera_outlined : Icons.photo_outlined,
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  List<File> discardedFiles = <File>[];
                  _filePaths = await PickerUtils().checkPermissionAndPick(
                    maxFileSize: 5000000,
                    shouldFollowMaxSizeInCamera: false,
                    shouldFollowMaxSizeInAssets: false,
                    type: PickerType.values[index],
                    filePaths: _filePaths,
                    maxLength: _maxLength,
                    discardedFiles: (List<File> value) {
                      discardedFiles = value;
                    },
                    permDeniedList: (Map<Permission, PermissionStatus> map) {},
                  );
                  if (discardedFiles.isNotEmpty) {
                    showMyDialogCallBack(discardedFiles);
                  }
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showMyDialog(List<File> discardedFiles) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Discarded files",
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "Note: The files which are greater than 5 MB will be discard.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: discardedFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    discardedFiles[index].path,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  Future<UploadCDNModel> uploadImage({
    required File file,
    required XFile webPickedFile,
  }) async {
    final UploadCDNModel response = await DioSingleton().uploadImage(
      file: file,
      webPickedFile: webPickedFile,
    );
    _generatedFileURL = response.fileUrl ?? "";
    log("Generated File URL: $_generatedFileURL");
    return Future<UploadCDNModel>.value(response);
  }

  Widget imagePicker() {
    final ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
    return kIsWeb
        ? Stack(
            children: <Widget>[
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: highlighted1 ? Colors.green : Colors.transparent,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: DropzoneView(
                  operation: DragOperation.copy,
                  cursor: CursorType.grab,
                  onCreated: (DropzoneViewController controller) {
                    _dropzoneCtrl = controller;
                  },
                  onLoaded: () {
                    log("DropzoneView onLoaded");
                  },
                  onError: (String? ev) {
                    log("DropzoneView onError: $ev");
                  },
                  onHover: () {
                    log("DropzoneView onHover");
                    highlighted1 = true;
                    setState(() {});
                  },
                  onLeave: () {
                    log("DropzoneView onLeave");
                    highlighted1 = false;
                    setState(() {});
                  },
                  onDrop: (dynamic file) async {
                    log("DropzoneView onDrop: $file");
                    final String mime = await _dropzoneCtrl?.getFileMIME(
                          file,
                        ) ??
                        "";
                    if (mime.startsWith("image/")) {
                      final String path =
                          await _dropzoneCtrl?.createFileUrl(file) ?? "";
                      final String name =
                          await _dropzoneCtrl?.getFilename(file) ?? "";
                      final String mime =
                          await _dropzoneCtrl?.getFileMIME(file) ?? "";
                      final int size =
                          await _dropzoneCtrl?.getFileSize(file) ?? 0;
                      final DateTime lastModified =
                          await _dropzoneCtrl?.getFileLastModified(file) ??
                              DateTime.now();
                      final Uint8List bytes =
                          await _dropzoneCtrl?.getFileData(file) ??
                              Uint8List(8);

                      webPickedFile = XFile(
                        path,
                        name: name,
                        mimeType: mime,
                        lastModified: lastModified,
                        length: size,
                        bytes: bytes,
                      );

                      final File temp = File(webPickedFile.path);
                      webPickedFile = await PickerUtils().webImageCrop(temp);

                      if (webPickedFile != XFile("")) {
                        webImage = await webPickedFile.readAsBytes();
                        _filePaths = <File>[
                          File.fromRawPath(webImage),
                        ];
                        setState(() {});
                      }
                    } else {
                      const SnackBar snackBar = SnackBar(
                        content: Text(
                          "Only images are allow to drop here.",
                        ),
                      );
                      messengerState.showSnackBar(snackBar);
                    }
                  },
                  onDropMultiple: (List<dynamic>? files) {
                    log("DropzoneView onDropMultiple: $files");
                    if ((files?.length ?? 0) > 1) {
                      const SnackBar snackBar = SnackBar(
                        content: Text(
                          "Multiple file pick is not supported.",
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              ),
              inkWellPicker(),
            ],
          )
        : inkWellPicker();
  }

  Widget inkWellPicker() {
    return InkWell(
      onTap: () async {
        if (kIsWeb) {
          webPickedFile = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              ) ??
              XFile("");

          final File temp = File(webPickedFile.path);
          webPickedFile = await PickerUtils().webImageCrop(temp);

          if (webPickedFile != XFile("")) {
            webImage = await webPickedFile.readAsBytes();
            _filePaths = <File>[
              File.fromRawPath(webImage),
            ];
            setState(() {});
          } else {
            log("inkWellPicker() webPickedFile is empty");
          }
        } else {
          if (_filePaths.length < _maxLength) {
            await onPressed(_showMyDialog);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "You've reached the maximum assets upload limit",
                ),
              ),
            );
          }
        }
      },
      borderRadius: const BorderRadius.all(
        Radius.circular(100),
      ),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
          border: Border.all(
            color: ColorUtils().borderColor(),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
            child: Icon(
              Icons.add,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    if (widget.extra != null) {
      if (widget.extra is UsersInfoModel) {
        _usersInfoModel = (widget.extra ?? UsersInfoModel()) as UsersInfoModel;
        _future = Future<UsersInfoModel>.value(_usersInfoModel);
        if (_usersInfoModel.id != "" || _usersInfoModel.id?.isEmpty != true) {
          prePopulateAllData();
          setState(() {});
        } else {
          generateRandomTimeZoneForTimeZoneController();
          await checkRedirectOrInitCall();
        }
      } else {
        generateRandomTimeZoneForTimeZoneController();
        await checkRedirectOrInitCall();
      }
    } else {
      generateRandomTimeZoneForTimeZoneController();
      await checkRedirectOrInitCall();
    }
    setState(() {});
    return Future<void>.value();
  }
}
