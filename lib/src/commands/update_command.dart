import 'package:args/command_runner.dart';

class UpdateCommand extends Command<void> {
  @override
  String get name => 'update';

  @override
  String get description => 'Update components';

  @override
  Future<void> run() async {
    print('not yet implemented');
  }
}
