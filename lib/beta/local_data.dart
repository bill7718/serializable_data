

import 'dart:io';

import 'package:serializable_data/serializable_data.dart';
import 'dart:async';
import 'dart:convert';



class LocalData  implements DataService {

  static const String fileName = 'cache.json';

  Map<String, dynamic> _cache = <String, dynamic>{};
  final File data;

  LocalData(this.data) {
    initialise();
  }

  Future<void> initialise() async  {
    var c = Completer<void>();
    var content = data.readAsStringSync();
    setCacheFromString(content);
    c.complete();
    return c.future;
  }



  Map<String, dynamic> get cache {
    return _cache;
  }


  @override
  Future<void> set(String ref, Map<String, dynamic> m) {
    var c = Completer<void>();
    _setByReference(ref, m, (_) {
      var json = const JsonEncoder().convert(_cache);

      data.writeAsStringSync(json);
      c.complete();
    });

    return c.future;
  }

  void _setByReference(String ref, dynamic m, Function callback) {
    _addToCache(ref, m);
    callback(null);
  }

  void _addToCache(String ref, Map<String, dynamic> data) {
    var copy = _cloneMap(data);
    var l = ref.split('/');
    var i = 0;
    Map m = _cache;
    while (i < l.length - 1) {
      Map? m1 = m[l[i]];
      if (m1 == null) {
        m[l[i]] = <String, dynamic>{};
        m = m[l[i]];
      } else {
        m = m1;
      }

      i++;
    }

    m[l.last] = copy;
  }



  // Map<String, dynamic> get cache => _cache;

  void setCacheFromString(String s) {
    var js = const JsonDecoder();
    _cache = js.convert(s);
  }

  @override
  Future<Map<String, dynamic>> delete(String ref) {
    var c = Completer<Map<String, dynamic>>();

    _deleteByReference(ref, (d) {
      if (d == null) {
        c.completeError('delete failed object not found for ref: ' + ref);
      } else {
        data.writeAsStringSync(const JsonEncoder().convert(_cache));
        c.complete(d);
      }
    });

    return c.future;
  }

  void _deleteByReference(String ref, Function callback) {
    var l = ref.split('/');
    var i = 0;
    Map m = _cache;
    while (i < l.length - 1) {
      Map? m1 = m[l[i]];
      if (m1 == null) {
        callback(null);
        return;
      } else {
        m = m1;
      }

      i++;
    }

    var d = m[l.last];
    m.remove(l.last);
    callback(d);
  }

  @override
  Future<Map<String, dynamic>> get(String ref) {
    var c = Completer<Map<String, dynamic>>();
    _readDataByReference(ref, (m) {
      c.complete(m);
    });

    return c.future;
  }

  void _readDataByReference(String ref, Function callback) {
    var l = ref.split('/');
    var i = 0;
    Map m = _cache;

    while (i < l.length - 1) {
      Map? m1 = m[l[i]];
      if (m1 == null) {
        callback(null);
        return;
      } else {
        m = m1;
      }

      i++;
    }

    callback(_cloneMap(m[l.last]));
  }

  @override
  Future<List<Map<String, dynamic>>> query(String ref, { String? field,  value } ) {
    var c = Completer<List<Map<String, dynamic>>>();
    Map<String, dynamic> d = _getByReference(ref) ?? <String, dynamic>{};

    var results = <Map<String, dynamic>>[];
    if (d.isEmpty) {
      c.complete(results);
      return c.future;
    }

    var i = d.values.iterator;
    while (i.moveNext()) {
      if (i.current is Map<String, dynamic>) {
        Map<String, dynamic> m = i.current;
        if (field != null) {
          if (m[field] == value) {
            results.add(_cloneMap(m) ?? <String, dynamic>{});
          }
        } else {
          // if field is null just return all the data
          results.add(_cloneMap(m) ?? <String, dynamic>{});
        }
      }
    }
    c.complete(results);
    return c.future;
  }

  dynamic _getByReference(String ref) {
    var l = ref.split('/');
    var i = 0;
    Map m = _cache;
    while (i < l.length - 1) {
      Map? m1 = m[l[i]];
      if (m1 == null) {
        return null;
      } else {
        m = m1;
      }

      i++;
    }

    return _cloneMap(m[l.last]);
  }


  Future<List<Map<String, dynamic>>> queryAll(String ref) {
    return query(ref);
  }

  Map<String, dynamic>? _cloneMap(Map<String, dynamic>? m) {
    if (m == null) {
      return null;
    }

    var copy = <String, dynamic>{};
    var i = m.keys.iterator;
    while (i.moveNext()) {
      copy[i.current] = m[i.current];
    }

    return copy;
  }


}
