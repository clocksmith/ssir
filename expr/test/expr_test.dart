@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:expr/expr.dart';
import 'package:vector_math/vector_math.dart' as vm;

final overwriteGoldens = false;

Future<void> matchGolden(ByteBuffer item, String filename) async {
  assert(filename != null);
  final file = File(filename);
  if (overwriteGoldens) {
    print(Directory.current);
    await file.writeAsBytes(item.asUint8List(), flush: true);
  }
  expect(item.asUint8List(), equals(await file.readAsBytes()));
}

void main() {
  test('simple shader', () async {
    final shader = Shader(
      color: Vec4(0, 0.25, 0.75, 1.0),
    );
    await matchGolden(shader.toSPIRV(), 'simple.golden');
  });

  test('vec4 ops', () async {
    final a = Vec4(1.0, 0.25, 0.75, 1.0);
    final b = Vec4(1, 1, 1, 1);

    final color = (b.scale(Scalar(2)) + (a * -b) / a) % Vec4(1.5, 1.5, 1.5, 1.5);

    final shader = Shader(
      color: color
    );
    await matchGolden(shader.toSPIRV(), 'vec4op.golden');

    final result = color.evaluate();
    expect(result, equals(vm.Vector4.all(1)));
    expect(color.dot(b).evaluate(), equals(4));
  });
}
