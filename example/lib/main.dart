import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_crdt/pocketbase_crdt.dart';
import 'package:pocketbase_crdt/connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

late final CrdtPocketBase instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final e = createDatabaseExecutor(
    'example5.db',
    logStatements: true,
    isWeb: kIsWeb,
  );
  final prefs = await SharedPreferences.getInstance();
  const authKey = 'auth';
  final store = AsyncAuthStore(
    initial: prefs.getString(authKey),
    save: (value) async => await prefs.setString(authKey, value),
    clear: () async => await prefs.remove(authKey),
  );
  instance = CrdtPocketBase(
    httpClientFactory:
        kIsWeb ? () => FetchClient(mode: RequestMode.cors) : null,
    'http://127.0.0.1:8090',
    e,
    authStore: store,
  );
  await instance.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRDT',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SignalsMixin {
  late final auth$ =
      this.bindSignal(instance.authStore.onChange.toStreamSignal());
  late final loggedIn$ = this.createComputed(() {
    auth$.value;
    return instance.authStore.isValid;
  });
  late final authModel$ = this.createComputed(() {
    auth$.value;
    return instance.authStore.model;
  });

  @override
  Widget build(BuildContext context) {
    final model = authModel$.value;
    if (model is RecordModel) {
      return TodosScreen(userId: model.id);
    }
    return const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SignalsMixin {
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: username,
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: password,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await instance
                  .collection('users')
                  .authWithPassword(username.text, password.text)
                  .then((user) {
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //     builder: (context) => TodosScreen(userId: user.id),
                //   ),
                // );
              }).catchError((e) {
                debugPrint('error logging in: $e');
              });
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class TodosScreen extends StatefulWidget {
  const TodosScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> with SignalsMixin {
  late final col = instance.crdtCollection(
    collectionId: collectionId,
    collectionName: collectionName,
  );
  late final loading$ = this.createSignal(false);
  // late final items$ = this.createSignal<List<RecordModel>>([]);
  late final items$ = this.bindSignal(
    col.getAll().watch().toStreamSignal(),
  );

  final collectionId = '2gufa3r1rbqvc36';
  final collectionName = 'todos';

  Future<void> Function()? _unsubscribe;

  late final remoteFilters = "user = '${widget.userId}'";
  late final localFilters =
      "json_extract(data, '\$.user') = '${widget.userId}'";

  @override
  void initState() {
    super.initState();

    col
        .sync(
          remoteFilters: remoteFilters,
          localFilters: localFilters,
        )
        .ignore();
    col
        .syncRealtime(
      remoteFilters: remoteFilters,
      localFilters: localFilters,
    )
        .then((unsubscribe) {
      _unsubscribe = unsubscribe;
    });
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                loading$.value = true;
                await col.sync(
                  remoteFilters: remoteFilters,
                  localFilters: localFilters,
                );
              } catch (e) {
                debugPrint('error syncing: $e');
              } finally {
                loading$.value = false;
              }
              // try {
              //   // Newest record locally
              //   final newest = await localCrdt //
              //       .getLastModifiedRecordModel();
              //   // Remote to local
              //   var changes = await localCrdt.getChangeset(
              //     onlyNodeId: localCrdt.nodeId,
              //     // exceptNodeId: crdt.nodeId,
              //     // extraFilters: {"user = '${widget.userId}'"},
              //   );
              //   debugPrint('new changes: $changes');
              //   await client.merge(changes);
              //   debugPrint('merged new changes');

              //   changes = await client.getChangeset(
              //     onlyNodeId: crdt.nodeId,
              //   );
              //   debugPrint('pending changes: $changes');
              //   await crdt.merge(changes);
              // } catch (e) {
              //   debugPrint('error syncing: $e');
              // } finally {
              //   loading$.value = false;
              // }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              instance.authStore.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (loading$.value) const LinearProgressIndicator(),
          Expanded(
            child: () {
              return items$.value.map(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error) => Center(
                  child: Text('Error: $error'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items'),
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final name = item.getStringValue('name');
                      return ListTile(
                        title: Text(name.isNotEmpty ? name : 'Untitled'),
                        // subtitle: Text(jsonEncode(item.toJson())),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await col.set(
                              item.toJson(),
                              isDeleted: true,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final now = DateTime.now();
          await col.set({
            'name': 'New Task ${now.toIso8601String()}',
            'user': widget.userId,
          });
        },
      ),
    );
  }
}
