import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/config/config.dart';
import 'package:study/src/dependency/dependencies.dart';

final packageContext = package_context.PackageContext<Config, Dependencies>();

Config get studyConfig => packageContext.config;

Dependencies get studyDependencies => packageContext.dependencies;
