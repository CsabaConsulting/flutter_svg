import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_svg/src/cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sanity', () async {
    final Cache cache = Cache();
    expect(cache.maximumSize, 100);
    expect(cache.count, 0);
    final Completer<ByteData> completer = Completer<ByteData>();
    final Future<ByteData> put = cache.putIfAbsent(1, () => completer.future);
    expect(put, completer.future);
    expect(cache.count, 0);
    completer.complete(ByteData(1));
    expect(cache.count, 0);
    await null;
    expect(cache.count, 1);
    cache.clear();
    expect(cache.count, 0);
    // Not bothering to check result since it's from the same completer.
    cache.putIfAbsent(1, () => completer.future);
    expect(cache.count, 0);
    await null;
    expect(cache.count, 1);
    expect(cache.evict(1), true);
    expect(cache.count, 0);
    expect(cache.evict(1), false);
  });

  test('LRU', () async {
    final Cache cache = Cache();
    cache.maximumSize = 2;
    final Completer<ByteData> completerA = Completer<ByteData>()
      ..complete(ByteData(1));
    final Completer<ByteData> completerB = Completer<ByteData>()
      ..complete(ByteData(2));
    final Completer<ByteData> completerC = Completer<ByteData>()
      ..complete(ByteData(3));

    expect(cache.count, 0);

    cache.putIfAbsent(1, () => completerA.future);
    await null;
    expect(cache.count, 1);

    cache.putIfAbsent(2, () => completerB.future);
    await null;
    expect(cache.count, 2);

    cache.putIfAbsent(3, () => completerC.future);
    await null;
    expect(cache.count, 2);

    expect(cache.evict(1), false);
    expect(cache.evict(2), true);
    expect(cache.evict(3), true);

    cache.putIfAbsent(1, () => completerA.future);
    await null;
    expect(cache.count, 1);

    cache.putIfAbsent(2, () => completerB.future);
    await null;
    expect(cache.count, 2);

    cache.putIfAbsent(1, () => completerA.future);
    await null;
    expect(cache.count, 2);

    cache.putIfAbsent(3, () => completerC.future);
    await null;
    expect(cache.count, 2);

    expect(cache.evict(1), true);
    expect(cache.evict(2), false);
    expect(cache.evict(3), true);
  });
}
