# flutter_rss

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Memo

### StatefulWidgetとStatelessWidgetの違い

Statefulの場合、Stateを利用する際、childrenには変数などをしておき、必要に応じて変数の値をsetStateで書き換える。
Statelessの場合、後からWidgetの変更ができないため、表示する内容はchildrenに直接指定する。

### 書籍改修箇所

dom.Elementの取得のための、DOMのクラスが実際のWebページと異なっていたので修正。

```
dom.Element hbody = document.querySelector('.tpcNews_summary');
dom.Element htitle = document.querySelector('.tpcNews_title');
dom.Element newslink = document.querySelector('.tpcNews_detailLink a');
```
