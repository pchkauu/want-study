import 'package:package_context/package_context.dart' as package_context;

final class Config extends package_context.PackageConfig {
  final Duration autosaveDelay;

  const Config({this.autosaveDelay = const Duration(milliseconds: 750)});
}
