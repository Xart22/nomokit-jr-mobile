import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/nomokitjr/bindings/nomopro_binding.dart';
import '../modules/nomokitjr/views/nomopro_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/project/bindings/project_binding.dart';
import '../modules/project/views/project_view.dart';
import '../modules/stetting/bindings/stetting_binding.dart';
import '../modules/stetting/views/stetting_view.dart';
import '../modules/upload_project/bindings/upload_project_binding.dart';
import '../modules/upload_project/views/upload_project_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.STETTING,
      page: () => const StettingView(),
      binding: StettingBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NOMOPRO,
      page: () => const NomoproView(),
      binding: NomoproBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT,
      page: () => const ProjectView(),
      binding: ProjectBinding(),
    ),
    GetPage(
      name: _Paths.UPLOAD_PROJECT,
      page: () => const UploadProjectView(),
      binding: UploadProjectBinding(),
    ),
  ];
}
