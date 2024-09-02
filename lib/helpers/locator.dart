import 'package:get_it/get_it.dart';
import 'package:skill_boost/providers/auth_provider.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
   locator.registerLazySingleton(() => AuthProvider());
}
