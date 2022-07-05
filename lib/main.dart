import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.light().copyWith(primary: Colors.pink),
      ),
      home: const RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);
  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = <WordPair>{};
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

// 业务, 列表整体
  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: /*1 cell回调*/ (context, i) {
        if (i.isOdd) return const Divider(); /*2 分割线*/

        final index = i ~/
            2; /*3 向下取整 语法 i ~/ 2 表示 i 除以 2，但返回值是整型（向下取整），比如 i 为：1, 2, 3, 4, 5 时，结果为 0, 1, 1, 2, 2，这个可以计算出 ListView 中减去分隔线后的实际单词对数量。*/
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs()
              .take(10)); /*4 如果是建议列表中最后一个单词对，接着再生成 10 个单词对，然后添加到建议列表。*/
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

// 单行
  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
        /** 提示: 在 Flutter 的响应式风格的框架中，调用 setState() 会为 State 对象触发 build() 方法，从而导致对 UI 的更新 */
      }, // onTap
    );
  }

// 导航菜单按钮, 跳转导航. 路由.
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          /* 接下来，添加 MaterialPageRoute 及其 builder。 现在，添加生成 ListTile 行的代码，ListTile 的 divideTiles() 方法在每个 ListTile 之间添加 1 像素的分割线。 该 divided 变量持有最终的列表项，并通过 toList()方法非常方便的转换成列表显示。*/
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
          /** builder 返回一个 Scaffold，其中包含名为"Saved Suggestions"的新路由的应用栏。新路由的body 由包含 ListTiles 行的 ListView 组成；每行之间通过一个分隔线分隔。 */
        },
      ),
    );
  }
}
