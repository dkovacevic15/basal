library basal;

import 'dart:async';

import 'package:rxdart/rxdart.dart' show CombineLatestStream, BehaviorSubject;
import 'package:flutter/widgets.dart';

/// Base class for all models. Doesn't have any functionality for now,
/// except for enforcing mutability. Makes typing in other classes easier.
@immutable
abstract class Model {}

/// The model manager. Wraps an instance of the provided [Model] with a
/// [BehaviorSubject],
class Manager<T extends Model> {
  final BehaviorSubject<T> _controller;

  T get model => _controller.value;
  set model(T model) => _controller.add(model);
  Stream<T> get stream => _controller.stream;

  Manager(T initalState) :
    _controller = new BehaviorSubject<T>(seedValue: initalState);

  String toString() => 'Manager of ${model.runtimeType} ($model)';
}

class Provider extends StatelessWidget {
  final Function child;
  final List<Manager> managers;

  Provider({Key key, @required this.child, @required this.managers})
      : super(key: key);

  static Provider of(BuildContext context) =>
      context.ancestorWidgetOfExactType(Provider);

  @override
  Widget build(BuildContext context) => child();
}

typedef Widget BuilderFunction(BuildContext context, List<Model> data,
    [List<Manager> managers]);

class Consumer extends StatelessWidget {
  final List<Type> models;
  final BuilderFunction builder;

  Consumer({
    Key key,
    @required this.models,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Manager> availableManagers = Provider.of(context).managers;
    List<Manager> managers = new List<Manager>();

    for (Type model in models) {
      // TODO: catch StateError and throw something more informative
      Manager requiredManager = availableManagers
          .firstWhere((Manager manager) => manager.model.runtimeType == model);

      managers.add(requiredManager);
    }

    Stream<List<Model>> stream;
    if (managers.length == 1) {
      stream = managers[0].stream.map((data) => [data]);
    } else {
      final modelStreams = managers.map((Manager manager) => manager.stream);

      stream = new CombineLatestStream(modelStreams, _toList);
    }

    return StreamBuilder(
        stream: stream, builder: (c, s) => builder(c, s.data, managers));
  }
}

List<Model> _toList(a, b, [c, d, e, f, g, h, i]) {
  List<Model> combined = new List<Model>();
  if (a != null) combined.add(a);
  if (b != null) combined.add(b);
  if (c != null) combined.add(c);
  if (d != null) combined.add(d);
  if (e != null) combined.add(e);
  if (f != null) combined.add(f);
  if (g != null) combined.add(g);
  if (h != null) combined.add(h);
  if (i != null) combined.add(i);
  return combined;
}
