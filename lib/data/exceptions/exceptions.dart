import 'package:loop_task/utils/exceptions/exception_level.dart';
import 'package:loop_task/utils/exceptions/exceptions.dart';

class LocalStorageException extends AppException {
  @override
  final ExceptionLevel level = ExceptionLevel.info;

  LocalStorageException(super.message, [super.stackTrace]);
}

class LocalStorageNotFoundException extends LocalStorageException {
  LocalStorageNotFoundException(super.message, [super.stackTrace]);
}

class TaskException extends AppException {
  @override
  final ExceptionLevel level = ExceptionLevel.error;

  TaskException(super.message, [super.stackTrace]);
}

class TaskNotFoundException extends TaskException {
  TaskNotFoundException(super.message, [super.stackTrace]);
}

class TaskValidationException extends TaskException {
  TaskValidationException(super.message, [super.stackTrace]);
}

class DatabaseException extends AppException {
  @override
  final ExceptionLevel level = ExceptionLevel.error;

  DatabaseException(super.message, [super.stackTrace]);
}

class StorageException extends AppException {
  @override
  final ExceptionLevel level = ExceptionLevel.error;

  StorageException(super.message, [super.stackTrace]);
}
