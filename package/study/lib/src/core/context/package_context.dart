import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/config/_barrel.dart';
import 'package:study/src/dependency/contract/_barrel.dart';

final packageContext = package_context.PackageContext<Config, Dependencies>();

Config get studyConfig => packageContext.config;
