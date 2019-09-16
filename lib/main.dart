import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
        primaryColor: const Color(0xFFe91e63),
        accentColor: const Color(0xFFe91e63),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: RssListPage(),
    );
  }
}

// Yahoo RSS の一覧リスト
class RssListPage extends StatelessWidget {

  final List<String> names = [
    '主要ニュース',
    '国際情勢',
    '国内の出来事',
    'IT関係',
    '科学',
  ];

  final List<String> links = [
    'https://news.yahoo.co.jp/pickup/rss.xml',
    'https://news.yahoo.co.jp/pickup/world/rss.xml',
    'https://news.yahoo.co.jp/pickup/domestic/rss.xml',
    'https://news.yahoo.co.jp/pickup/computer/rss.xml',
    'https://news.yahoo.co.jp/pickup/science/rss.xml',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo! Checker'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: items(context),
        ),
      ),
    );
  }

  // Listに表示するListTitleのリストを作る
  List<Widget> items(BuildContext context) {
    List<Widget> items = [];
    for(var i = 0; i < names.length; i++) {
      items.add(
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          title: Text(names[i],
            style: TextStyle(fontSize: 24.0),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyRssPage(
                  title: names[i],
                  url: links[i],
                ),
              ),
            );
          },
        ),
      );
    }
    return items;
  }
}

// RSSの一覧表示
class MyRssPage extends StatefulWidget {
  final String title;
  final String url;

  MyRssPage({@required this.title, @required this.url});

  @override
  _MyRssPageState createState() => new _MyRssPageState(title: title, url: url);
}

class _MyRssPageState extends State<MyRssPage> {
  final String title;
  final String url;
  List<Widget> _items = <Widget>[];

  _MyRssPageState({
    @required this.title,
    @required this.url
  }) { getItems(); }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: _items,
        ),
      ),
    );
  }

  // YahooサイトからRSSを取得し、ListTitleのListを作成する
  void getItems() async {
    List<Widget> list = <Widget>[];
    Response res = await get(url);
    RssFeed feed = RssFeed.parse(res.body);
    for (RssItem item in feed.items) {
      list.add(
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
          subtitle: Text(
            item.pubDate
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsPage(
                  item: item,
                  title: title,
                  url: url,
                ),
              ),
            );
          },
        ),
      );
    }

    // _itemsの更新
    setState(() {
      _items = list;
    });
  }
}

// 選択した項目の内容表示
class ItemDetailsPage extends StatefulWidget {
  final String title;
  final String url;
  final RssItem item;

  ItemDetailsPage({
    @required this.title,
    @required this.url,
    @required this.item,
  });

  @override
  _ItemDetails createState() => new _ItemDetails(item: item);
}

class _ItemDetails extends State<ItemDetailsPage> {
  RssItem item;
  Widget _widget = Text('wait...',);

  _ItemDetails({@required this.item});

  @override
  void initState() {
    super.initState();
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: _widget,
    );
  }

  // RssItemの情報からコンテンツを取得し、Cardを作成する
  void getItem() async {
    Response response = await get(item.link);
    dom.Document document = dom.Document.html(response.body);

    // サンプル改修部分、クラスが書籍内容と異なっていた。。
    dom.Element hbody = document.querySelector('.tpcNews_summary');
    dom.Element htitle = document.querySelector('.tpcNews_title');
    dom.Element newslink = document.querySelector('.tpcNews_detailLink a');
    print(newslink.attributes['href']);

    setState(() {
      _widget = SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  htitle.text,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  hbody.text,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text(
                    '続きを読む...',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  onPressed: () {
                    launch(newslink.attributes['href']);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
