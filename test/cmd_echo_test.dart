@TestOn("vm")

import 'dart:io';
import 'package:dev_test/test.dart';
import 'package:process_run/dartbin.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'dart:async';

String get echoScriptPath => join('bin', 'echo.dart');

void main() {
  group('cmd_echo', () {
    Future _runCheck(
      void Function(ProcessResult result) check,
      String executable,
      List<String> arguments, {
      String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment: true,
      bool runInShell: false,
      SystemEncoding stdoutEncoding: systemEncoding,
      SystemEncoding stderrEncoding: systemEncoding,
      StreamSink<List<int>> stdout,
    }) async {
      ProcessResult result = await Process.run(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding,
      );
      check(result);
      result = await run(executable, arguments,
          workingDirectory: workingDirectory,
          environment: environment,
          includeParentEnvironment: includeParentEnvironment,
          runInShell: runInShell,
          stdoutEncoding: stdoutEncoding,
          stderrEncoding: stderrEncoding,
          stdout: stdout);
      check(result);
    }

    test('stdout', () async {
      checkOut(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, "out");
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await _runCheck(
          checkOut, dartExecutable, [echoScriptPath, '--stdout', 'out']);
      await _runCheck(checkEmpty, dartExecutable, [echoScriptPath]);
    });

    test('stdout_bin', () async {
      check123(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, [1, 2, 3]);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, []);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await _runCheck(
          check123, dartExecutable, [echoScriptPath, '--stdout-hex', '010203'],
          stdoutEncoding: null);
      await _runCheck(checkEmpty, dartExecutable, [echoScriptPath],
          stdoutEncoding: null);
    });

    test('stderr', () async {
      checkErr(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, "err");
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      checkEmpty(ProcessResult result) {
        expect(result.stderr, '');
        expect(result.stdout, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await _runCheck(
          checkErr, dartExecutable, [echoScriptPath, '--stderr', 'err'],
          stdout: stdout);
      await _runCheck(checkEmpty, dartExecutable, [echoScriptPath]);
    });

    test('stderr_bin', () async {
      check123(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, [1, 2, 3]);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      checkEmpty(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, []);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await _runCheck(
          check123, dartExecutable, [echoScriptPath, '--stderr-hex', '010203'],
          stderrEncoding: null);
      await _runCheck(checkEmpty, dartExecutable, [echoScriptPath],
          stderrEncoding: null);
    });

    test('exitCode', () async {
      check123(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 123);
      }

      check0(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, '');
        expect(result.pid, isNotNull);
        expect(result.exitCode, 0);
      }

      await _runCheck(
          check123, dartExecutable, [echoScriptPath, '--exit-code', '123']);
      await _runCheck(check0, dartExecutable, [echoScriptPath]);
    });

    test('crash', () async {
      check(ProcessResult result) {
        expect(result.stdout, '');
        expect(result.stderr, isNotEmpty);
        expect(result.pid, isNotNull);
        expect(result.exitCode, 255);
      }

      await _runCheck(
          check, dartExecutable, [echoScriptPath, '--exit-code', 'crash']);
    });
  });
}
