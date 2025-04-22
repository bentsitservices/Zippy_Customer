import 'dart:async';
import 'package:country_pickers/country_pickers.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Auth/countryCodePickerScreen.dart';
import 'package:eshop_multivendor/Screen/PrivacyPolicy/Privacy_Policy.dart';
import 'package:eshop_multivendor/Screen/Auth/Verify_Otp.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/cubits/loadCountryCodeCubit.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Provider/authenticationProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/validation.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';

// ignore: must_be_immutable
class SendOtp extends StatefulWidget {
  String? title;
  String? mobileNo;
  String? from;

  SendOtp({Key? key, this.title, this.mobileNo, this.from}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  //final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, countrycode;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool acceptTnC = false;
  int? numberLength;
  final GlobalKey<FormState> verifyPhoneNumberFormKey = GlobalKey<FormState>();

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
      // ignore: empty_catches
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      final String countryCallingCode =
          context.read<CountryCodeCubit>().getSelectedCountryCode();

      countrycode = countryCallingCode;
      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getVerifyUser(mobileController.text,
                countryCode: countrycode!,
                isForgotPassword:
                    widget.title == getTranslated(context, 'FORGOT_PASS_TITLE'))
            .then(
          (
            value,
          ) async {
            bool? error = value['error'];
            String? msg = value['message'];
            await buttonController!.reverse();

            if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
              if (!error!) {
                setSnackbar(msg!, context);
                Future.delayed(const Duration(seconds: 1)).then(
                  (_) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: getTranslated(context, 'SEND_OTP_TITLE'),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setSnackbar(msg!, context);
              }
            }
            if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
              if (!error!) {
                setSnackbar(msg!, context);
                // settingsProvider.setPrefrence(MOBILE, mobileController.text);
                // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
                Future.delayed(const Duration(seconds: 1)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setSnackbar(getTranslated(context, msg!), context);
              }
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
          await buttonController!.reverse();
        },
      );
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (mobileController.text.toString().trim().isEmpty) {
      setSnackbar(getTranslated(context, 'MOB_REQUIRED'), context);
      return false;
    } else if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Widget verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: Text(
        getTranslated(context, 'SEND_VERIFY_CODE_LBL'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .fontColor
                  .withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 3,
      ),
    );
  }

  setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ) ??
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              ),
        ),
        child: TextFormField(
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: mobileController,
          readOnly: widget.mobileNo == null ? false : true,
          autofocus: widget.mobileNo == null ? true : false,
          enabled: true,
          decoration: InputDecoration(
            counterStyle:
                TextStyle(color: Theme.of(context).colorScheme.fontColor),
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            hintText: getTranslated(context, 'MOBILEHINT_LBL'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(circularBorderRadius7)),
            fillColor: Theme.of(context).colorScheme.white,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ((numberLength! < minimumMobileNumberDigit)
                      ? Theme.of(context).colorScheme.lightWhite
                      : (numberLength! > maximumMobileNumberDigit)
                          ? colors.red
                          : Theme.of(context).colorScheme.onSurface)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, bottom: 2),
              child: BlocBuilder<CountryCodeCubit, CountryCodeState>(
                builder:
                    (final BuildContext context, final CountryCodeState state) {
                  var code = '--';
                  var codeflag = "--";

                  print("countrycode status--->${state}");
                  if (state is CountryCodeFetchSuccess) {
                    code = state.selectedCountry!.callingCode;
                    codeflag = state.selectedCountry!.flag;
                  }

                  return InkWell(
                    onTap: () {
                      if (allowOnlySingleCountry) {
                        return;
                      }
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => CountryCodePickerScreen(),
                        ),
                      ).then((_) =>
                          context.read<CountryCodeCubit>().fillTemporaryList());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (BuildContext context) {
                            if (state is CountryCodeFetchSuccess) {
                              return Center(
                                  child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 25,
                                    child: Image.asset(
                                      codeflag,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontSize: 16,
                                      )),
                                ],
                              ));
                            }
                            if (state is CountryCodeFetchFail) {
                              return setSnackbar(state.error, context);
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          onChanged: (number) {
            setState(() {
              numberLength = number.length;
            });
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: Theme.of(context).colorScheme.fontColor,
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }

  /*setCodeWithMono() {
    // Get numeric country code from the API response
    final numericCountryCode =
        context.read<AppSettingsCubit>().getUserCountryCode() ??
            context.read<AppSettingsCubit>().getDefaultCountryCode();

    String? isoCountryCode;
    try {
      isoCountryCode =
          CountryPickerUtils.getCountryByPhoneCode(numericCountryCode!).isoCode;
    } catch (e) {
      isoCountryCode = context
          .read<AppSettingsCubit>()
          .getDefaultCountryCode(); // Default to India if the code is unsupported
      print(
          "Unsupported country code: $numericCountryCode. Falling back to default.");
    }

    print("Converted ISO Country Code: $isoCountryCode");

    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ) ??
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              ),
        ),
        child: IntlPhoneField(
          disableLengthCheck: true,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: mobileController,
          readOnly: widget.mobileNo == null ? false : true,
          autofocus: widget.mobileNo == null ? true : false,
          enabled: true,
          decoration: InputDecoration(
            counterStyle:
                TextStyle(color: Theme.of(context).colorScheme.fontColor),
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            hintText: getTranslated(context, 'MOBILEHINT_LBL'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(circularBorderRadius7)),
            fillColor: Theme.of(context).colorScheme.white,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          ),
          initialCountryCode: isoCountryCode, // Use the ISO code here
          onSaved: (phoneNumber) {
            setState(() {
              countrycode = phoneNumber!.countryCode.toString();
              mobile = phoneNumber.number;
            });
          },
          onCountryChanged: (country) {
            setState(() {
              countrycode = country.dialCode;
            });
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          showDropdownIcon: false,
          cursorColor: Theme.of(context).colorScheme.fontColor,
          keyboardType: TextInputType.number,
          flagsButtonMargin: const EdgeInsets.only(left: 20, right: 20),
          pickerDialogStyle: PickerDialogStyle(
            searchFieldCursorColor: Theme.of(context).colorScheme.fontColor,
            padding: const EdgeInsets.only(left: 10, right: 10),
            searchFieldInputDecoration: InputDecoration(
              hintText: 'Search country',
              hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .black
                      .withValues(alpha: 0.5)),
              fillColor: Theme.of(context).colorScheme.white,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            countryNameStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }*/

  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) {
      return false;
    }

    return int.tryParse(phoneNumber) != null;
  }

  Widget verifyBtn() {
    return Center(
      child: AppBtn(
        title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SEND_OTP')
            : getTranslated(context, 'CONTINUE'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          FocusScope.of(context).unfocus();
          if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE') ||
              acceptTnC) {
            validateAndSubmit();
          } else {
            setSnackbar(getTranslated(context, 'agreeTCFirst'), context);
          }
        },
      ),
    );
  }

  Widget termAndPolicyTxt() {
    if (widget.title != getTranslated(context, 'FORGOT_PASS_TITLE')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0.0, left: 25.0, right: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    activeColor: colors.primary,
                    value: acceptTnC,
                    onChanged: (newValue) {
                      setState(() => acceptTnC = newValue!);
                    }),
                Expanded(
                    child: RichText(
                  text: TextSpan(
                    text: getTranslated(context, 'CONTINUE_AGREE_LBL'),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                        text:
                            "\n${getTranslated(context, 'TERMS_SERVICE_LBL')}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.normal),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PrivacyPolicy(
                                          title: getTranslated(context, 'TERM'),
                                        )));
                          },
                      ),
                      TextSpan(
                        text: "  ${getTranslated(context, 'AND_LBL')}  ",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                          text: getTranslated(context, 'PRIVACY'),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => PrivacyPolicy(
                                            title: getTranslated(
                                                context, 'PRIVACY'),
                                          )));
                            }),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryCodeCubit>().loadAllCountryCode(context);
    });
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });
    if (widget.mobileNo != null) {
      setState(() {
        mobileController.text = widget.mobileNo!;
        mobile = widget.mobileNo!;
      });
    }
    numberLength = mobileController.text.length;
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            getTranslated(context, 'ALREADY_HAVE_AN_ACCOUNT'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          if (widget.from != 'changePassword')
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text(
                " ${getTranslated(context, 'SIGNIN_LBL')}",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      // backgroundColor: Theme.of(context).colorScheme.white,
      //bottomNavigationBar: termAndPolicyTxt(),
      body: isNetworkAvail
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 23,
                  left: 23,
                  right: 23,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // getLogo(),
                          backBotton(),
                          signUpTxt(),
                          verifyCodeTxt(),
                          setCodeWithMono(),
                          verifyBtn(),
                          SizedBox(
                            height: 20,
                          ),
                          if (widget.title ==
                              getTranslated(context, 'SEND_OTP_TITLE'))
                            setDontHaveAcc()
                        ],
                      ),
                      termAndPolicyTxt()
                    ],
                  ),
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: const AppLogo(),
    );
  }

  Widget backBotton() {
    return InkWell(
      child: Icon(
        Icons.arrow_back_ios,
        color: Theme.of(context).colorScheme.black,
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget signUpTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SIGN_UP_LBL')
            : getTranslated(context, 'FORGOT_PASSWORDTITILE'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              fontFamily: 'ubuntu',
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
