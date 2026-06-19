import 'dart:io';
import 'package:args/command_runner.dart';
import 'commands/init_command.dart';
import 'commands/list_command.dart';
import 'commands/add_command.dart';
import 'commands/status_command.dart';
import 'commands/update_command.dart';
import 'commands/diff_command.dart';

class CliRunner {
  Future<void> run(List<String> args) async {
    final runner = CommandRunner<void>(
      'flutter_kinetic_ui',
      'Flutter Kinetic UI — copy-paste component library',
    )
      ..addCommand(InitCommand())
      ..addCommand(ListCommand())
      ..addCommand(AddCommand())
      ..addCommand(StatusCommand())
      ..addCommand(UpdateCommand())
      ..addCommand(DiffCommand());

    try {
      await runner.run(args);
    } on UsageException catch (e) {
      stderr.writeln(e.message);
      stderr.writeln(e.usage);
      exit(64);
    } on ArgumentError catch (e) {
      stderr.writeln('Error: ${e.message}');
      exit(1);
    } on StateError catch (e) {
      stderr.writeln('Error: ${e.message}');
      exit(1);
    } on Exception catch (e) {
      stderr.writeln('Error: $e');
      exit(1);
    }
  }
}
