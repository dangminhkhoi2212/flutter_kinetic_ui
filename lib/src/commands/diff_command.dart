import 'package:args/command_runner.dart';

class DiffCommand extends Command<void> {
  @override
  String get name => 'diff';

  @override
  String get description => 'Show differences';

  @override
  Future<void> run() async {
    print('not yet implemented');
  }
}
