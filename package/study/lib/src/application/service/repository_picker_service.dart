import 'package:domain_error/domain_error.dart';
import 'package:study/src/domain/_barrel.dart';

abstract interface class RepositoryPickerService {
  const RepositoryPickerService();

  FutureResult<RepositorySelectionV1> pickRepository();
}
