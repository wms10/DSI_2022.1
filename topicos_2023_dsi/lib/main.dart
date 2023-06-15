import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

enum ViewType { grid, list }

// função principal
void main() => runApp(MyApp());

// classe que guarda as configurações do app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  //static const routeName = '/';

  // cria o estado da pagina RandomWords (pagina home)
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 16);

  ViewType _viewType = ViewType.list;
  int _colum = 1;

  // construção da página inicial (RandomWords)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
              icon: const Icon(Icons.list, color: Colors.lightBlue),
              onPressed: _pushSaved),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 244, 177, 54),
          child:
              Icon(_viewType == ViewType.grid ? Icons.grid_view : Icons.list),
          onPressed: () {
            if (_viewType == ViewType.grid) {
              _viewType = ViewType.list;
              _colum = 1;
            } else {
              _viewType = ViewType.grid;
              _colum = 2;
            }
            setState(() {});
          }),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return GridView.builder(
        itemCount: _viewType == ViewType.grid ? 20 : 40,
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _colum,
          childAspectRatio: _viewType == ViewType.grid ? 1 : 10,
        ),
        itemBuilder: (context, i) {
          if (i.isOdd && _viewType == ViewType.list) {
            return const Divider();
          }

          final index = i ~/ 1;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          final alreadySaved =
              _saved.contains(_suggestions[index]); //análogo a um state

          return ListTile(
            title: Text(
              _suggestions[index].asPascalCase,
              style: _biggerFont,
            ),
            trailing: Wrap(
              // spacing: -10, não funciona
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                    color: alreadySaved
                        ? const Color.fromARGB(255, 255, 115, 0)
                        : null,
                    semanticLabel: alreadySaved
                        ? 'Desfavoritar'
                        : 'Salvo', //análogo ao alt
                  ),
                  onPressed: () {
                    setState(() {
                      //lógica da troca de estado
                      if (alreadySaved) {
                        _saved.remove(_suggestions[index]);
                      } else {
                        _saved.add(_suggestions[index]);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.delete,
                    semanticLabel: 'Deletado',
                  ),
                  onPressed: () {
                    setState(() {
                      if (alreadySaved) {
                        _saved.remove(_suggestions[0]);
                      }
                      _suggestions.remove(_suggestions[0]); //remove do array
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              _editWordPair(context, _suggestions[index],
                  _suggestions.indexOf(_suggestions[index]));
            },
          );
        });
  }

  // tela de edição do par de palavras
  void _editWordPair(BuildContext context, WordPair pair, int index) {
    String? firstWord;
    String? secondWord;
    final formKey = GlobalKey<FormState>();

    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(title: const Text('Edição de palavra')),
          body: Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.center,
            child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: firstWord,
                      decoration: const InputDecoration(
                        hintText: 'Primeira palavra',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                      onSaved: (value) => firstWord = value,
                    ),
                    TextFormField(
                      initialValue: secondWord,
                      decoration: const InputDecoration(
                        hintText: 'Segunda palavra',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                      onSaved: (value) => secondWord = value,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            setState(() {
                              var pairUpdated =
                                  WordPair(firstWord!, secondWord!);
                              _suggestions.insert(index, pairUpdated);
                              Navigator.of(context).pop();
                            });
                          }
                        },
                        child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text('Salvar'))),
                  ],
                )),
          ));
    }));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
