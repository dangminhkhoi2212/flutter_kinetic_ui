import 'package:args/command_runner.dart';

class StatusCommand extends Command<void> {
  @override
  String get name => 'status';

  @override
  String get description => 'Show project status';

  @override
  Future<void> run() async {
    print('not yet implemented');
  }
}
