import 'package:args/command_runner.dart';

class AddCommand extends Command<void> {
  @override
  String get name => 'add';

  @override
  String get description => 'Add a component to the project';

  @override
  Future<void> run() async {
    print('not yet implemented');
  }
}
