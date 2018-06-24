# Basal - a state manager for Flutter

Basal is Flutter library that aims to provide a scalable and performant way of managing state.

## A case against Redux

Because of Flutter's superficial similarity to React, there is an inherent instict to reach for Redux for handling complex application state. However, I would argue that Redux's success is in that its API is idiomatic to the language of implementation - Javascript is best applied as a functional language, and Redux embraces that in every aspect of its design. Dart, on the other hand, is an entirely different beast. It is heavily object-oriented, and trying to apply Redux's concepts is, in my view, misguided.

Despite not being a good fit for Flutter, Redux, when used with React, exhibits a couple of general qualities every state management library should strive for:

- **State composability**

  When using `combineReducers`, Redux makes it easy to add or remove slices of state. Adding new functionality to your app means writing another module, and then adding a single line of code to the store constructor. This goes a long way towards maintaining readability as the app scales.

- **UI as a function of state**

  When `react-redux` is applied properly, every React component becomes a function of state. It declares the specific parts of the app state it requires, and then declares the UI for the relevant data. This declarative apporach is great for large-scale apps since it makes interacting with a large system trivial. Another big advantage is performance - in the example or `react-redux`, the `connect` HOC is able to do shallow comparisons on state changes, and prevent unnecessary rerenders.

## A case for Basal

Basal, at its core, uses a similar pattern to `ScopedModel` and `FlutterRedux` - it expects you to wrap your entire app with a `Provider` widget, and then wrap state-dependent widgets with a `Consumer`. What's different is:

- **App state is composable**

  The Provider constructor accepts a `List<ModelManager>` (more on those later) instead of a single object. That means rather than writing a single 1000-line class, you can write 20 or so 50-line classes.

- **It uses Streams under the hood, without you needing to know about them.**

  Dart streams and Flutter StreamBuilders are awesome, and should be used whenever possible.

- **A Consumer only subscribes to the parts of the state relevant to it.**

  A Consumer declares which models it depends on, and only subscribes to the streams for those models. Changes to other models will have zero effect on the widget.

## Example code

```dart
class Person extends Model {
    final String name;

    Person(this.name);
}

class Task extends Model {
    final String title;
    final bool complete;
}

void main() => runApp(
    new Provider(
        managers: [
            new ModelManager<Person>(),
            new ModelManager<Task>()
        ]
    )
)
```

```dart
class SetNameButton extends StatelessWidget {
    final String newName;

    SetNameButton({Key key, this.newName}) : super(key: key);

    @override
    Widget build(BuildContext context) =>
        Consumer(
            models: [User],
            builder: (context, models, [managers]) {
                final User currentUser = models[0];
                final UserManager userManager = managers[0];

                return new RaisedButton(
                    child: new Text(newName),
                    onPressed: () => userManager.model = new User(newName);
                )
            }
        )
}
```

```dart
class NameAndJobDisplay extends StatelessWidget {

    @override
    Widget build(BuildContext context) =>
        Consumer(
            models: [User, Task],
            builder: (context, models) {
                final User user = models[0];
                final Task task = models[1];

                return new Text('$user ($task)');
            }
        )
}
```

## Usage

- `Provider`

  Takes a `List<ModelManager>`, and a child `Widget` which should be the root of your app.

- `Consumer`

  Takes a `List` of `Model` classes, and a builder function. The builder function will receive the `BuildContext`, the latest instances of the listed Models, and their relevant Managers.

- `ModelManager<Model>`

  Wraps the `Model` instance in a `BehaviorSubject`. The setter for the `Model` instance automatically fires off the `BehaviorSubject`. In a larger app, you should extend this class and implement methods that correspond to more complex actions such as HTTP requests.

- `Model`

  Stub class. It makes typing in the library easier, and it's marked as immutable.

That's really it.

## Future changes

First off, **there are no tests**. I'm pretty new to Flutter, and currently juggling a job and university, so I haven't had the time to learn Dart unit testing. Will get on it ASAP.

I'm not married to the idea of `ModelManager`s, but I also don't think `EventSink`s are the best choice either. They do promote looser coupling, but I just don't see the value of hiding a method behind a Stream.
