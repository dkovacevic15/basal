library basal;

import 'dart:async';

import 'package:rxdart/rxdart.dart' show CombineLatestStream, BehaviorSubject;
import 'package:flutter/widgets.dart';

@immutable
abstract class Model {}

class ModelManager<T extends Model> {

  final BehaviorSubject<T> _controller =
    new BehaviorSubject().asBroadcastStream();

  T get model => _controller.value;
  set model(T model) => _controller.add(model);
  Stream<T> get stream => _controller.stream;

  ModelManager(T initalState) {
    _controller.add(initalState);
  }

  String toString() => 'Manager of ${model.runtimeType} ($model)';
}

class Provider extends StatelessWidget {

  final Widget child;
  final List<ModelManager> managers;

  Provider({
    Key key,
    @required this.child,
    @required this.managers
    }) : super(key: key);

  static Provider of(BuildContext context) =>
      context.ancestorWidgetOfExactType(Provider);

  @override
  Widget build(BuildContext context) =>
    child;
}

typedef Widget BuilderFunction(
  BuildContext context,
  List<Model> data,
  [List<ModelManager> managers]
);

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
    List<ModelManager> availableManagers = Provider.of(context).managers;
    List<ModelManager> managers = new List<ModelManager>();

    for (Type model in models) {
      // TODO: catch StateError and throw something more informative
      ModelManager requiredManager = availableManagers.firstWhere(
          (ModelManager manager) => manager.model.runtimeType == model);

      managers.add(requiredManager);
    }

    Stream<List<Model>> stream;
    if (managers.length == 1) {
      stream = managers[0].stream.map((data) => [data]);
    } else {
      final modelStreams = managers.map(
        (ModelManager manager) => manager.stream);

      stream = new CombineLatestStream(modelStreams, _toList);
    }

    return StreamBuilder(
        stream: stream,
        builder: (c, s) => builder(c, s.data, managers)
      );
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

void main() {
  final test = new Consumer(models: [], builder: (context, models, [manager]) => null);
}
