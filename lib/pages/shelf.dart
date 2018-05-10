import 'package:flutter/material.dart';
import 'reader/reader.dart';
import '../services/system.dart';
import '../models/book.dart';
import '../widgets/book_item.dart';

class Shelf extends StatefulWidget {
  Shelf({@override this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ShelfState createState() => new _ShelfState();
}

class _ShelfState extends State<Shelf> {
  SystemService service = new SystemService();

  bool inSelect = false;

  bool showReadProcess = false;

  List<Book> selectedBooks = <Book>[];

  List<Book> books = <Book>[];

  /// open drawer
  void handleOpenDrawer() {
    widget.scaffoldKey.currentState.openDrawer();
  }

  /// open search page
  void handleSearch() {
    Navigator.pushNamed(context, 'search');
  }

  void handleRefresh(dynamic event) {
    print('handleRefresh1');
    if (null != event && event is List && event.isNotEmpty) {
      if ('refreshShelf' == event[0]) {
        print('handleRefresh2');
        var data = service.bookService.getBooks()?.values?.toList();
        if (null != data) {
          setState(() {
            books = data;
          });
        }
      }
    }
  }

  void update(Book book) {
    if (indexOf(book) >= 0) {
      selectedBooks.removeWhere((Book b) => b == book);
    } else {
      selectedBooks.add(book);
    }
  }

  int indexOf(Book book) {
    if (selectedBooks.length == 0) return -1;
    return selectedBooks.indexWhere((Book v) => v == book);
  }

  void handleOnTap(Book book) {
    print('on tap $book');
    if (inSelect) {
      /// update selectedBooks
      update(book);
    } else {
      /// jump to reader
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
        return new Reader(book: book);
      }));
    }
  }

  void handleLongPress(Book book) {
    print('long press $book');
    setState(() {
      if (inSelect) {
        if (null != book) {
          selectedBooks.add(book);
        }
      } else {
        inSelect = true;
        update(book);
      }
    });
  }

  void handleDelete() {
    print('handle delete');
    if (selectedBooks.length > 0) {
      /// delete selected books
      final ThemeData theme = Theme.of(context);
      final TextStyle dialogTextStyle = theme.textTheme.subhead
          .copyWith(color: theme.textTheme.caption.color);
      showDialog<bool>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                  content: new Text('要删除这${selectedBooks.length}个资源？',
                      style: dialogTextStyle),
                  actions: <Widget>[
                    new FlatButton(
                        child: const Text('是'),
                        onPressed: () {
                          Navigator.pop(context, true);
                        })
                  ])).then<bool>((value) {
        if (true == value) {
          service.bookService.removeBooks(selectedBooks);

          selectedBooks.clear();
          inSelect = false;
          handleRefresh(['refreshShelf']);
        }
      });
    }
  }

  void handleSelectAll() {
    print('handle select all');
    setState(() {
      selectedBooks.clear();
    });
  }

  void handleCancel() {
    print('handle cancel');
    setState(() {
      selectedBooks.clear();
      inSelect = false;
    });
  }

  Widget buildBottomBar() {
    return new Container(
        height: 48.0,
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleCancel,
                  child: new Text('取消')),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleSelectAll,
                  child: new Text('全选')),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleDelete,
                  child: new Text('删除')),
            ]));
  }

  @override
  void initState() {
    super.initState();
    service.listen(handleRefresh);
    handleRefresh(['refreshShelf']);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(
              Icons.menu,
              color: Theme.of(context).accentIconTheme.color,
            ),
            onPressed: handleOpenDrawer),
        title: new Text('Light'),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.search), onPressed: handleSearch),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Offstage(
            offstage: null != books && books.isNotEmpty,
            child: new Center(
              child: new Text('Empty'),
            ),
          ),
          new Offstage(
            offstage: null == books || books.isEmpty,
            child: new Column(
              children: <Widget>[
                new Expanded(
                  child: new GridView.extent(
                    physics: new BouncingScrollPhysics(),
                    maxCrossAxisExtent: 130.0,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 24.0,
                    padding: const EdgeInsets.all(24.0),
                    childAspectRatio: 0.56,
                    children: books
                        .map((Book book) => new BookItem(
                              book: book,
                              inSelect: inSelect,
                              showReadProcess: showReadProcess,
                              onTap: handleOnTap,
                              onLongPress: handleLongPress,
                            ))
                        .toList(),
                  ),
                ),
                new Divider(height: 1.0),
                new Offstage(
                  offstage: !inSelect,
                  child: buildBottomBar(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
