import 'package:eshop_multivendor/repository/systemRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eshop_multivendor/Model/appSettingsModel.dart';

abstract class AppSettingsState {}

class AppSettingsInitial extends AppSettingsState {}

class AppSettingsProgress extends AppSettingsState {}

class AppSettingsSuccess extends AppSettingsState {
  final AppSettingsModel appSettingsModel;
  AppSettingsSuccess({
    required this.appSettingsModel,
  });
}

class AppSettingsFailure extends AppSettingsState {
  final String message;
  AppSettingsFailure({required this.message});
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(AppSettingsInitial());

  fetchAndStoreAppSettings() async {
    emit(AppSettingsProgress());
    try {
      final response = await SystemRepository.fetchSystemSetting(parameter: {});
      if (!response['error']) {
        emit(AppSettingsSuccess(
            appSettingsModel: AppSettingsModel.fromMap(response)));
      } else {
        emit(AppSettingsFailure(message: response['message']));
      }
    } catch (e) {
      emit(AppSettingsFailure(message: e.toString()));
    }
  }

  bool isGoogleLoginOn() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess)
          .appSettingsModel
          .isGoogleLoginAllowed;
    }
    return false;
  }

  String? getiosLink() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.iosLink;
    }
    return '';
  }

  String? getandroidLink() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.androidLink;
    }
    return '';
  }

  String? getAppStoreId() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.appStoreId;
    }
    return '';
  }

  String? getUserCountryCode() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.userCountryCode;
    }
    return null; // Return null instead of an empty string
  }

  String? getDefaultCountryCode() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.defaultCountryCode;
    }
    return null; // Return null instead of an empty string
  }

  bool isAppleLoginAllowed() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.isAppleLoginAllowed;
    }
    return false;
  }

  bool isSMSGatewayActive() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess).appSettingsModel.isSMSGatewayActive;
    }
    return false;
  }

  bool isCityWiseDeliverability() {
    if (state is AppSettingsSuccess) {
      return (state as AppSettingsSuccess)
          .appSettingsModel
          .isCityWiseDeliveribility;
    }
    return false;
  }
}
