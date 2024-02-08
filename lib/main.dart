import 'dart:io';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:personal_expenses/widgets/chart.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';




void main() {
  /*WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, 
  ]);*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        accentColor: Colors.amber,
        primarySwatch: Colors.purple
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1', 
    //   amount: 4500, 
    //   title: 'New Shoes', 
    //   date: DateTime.now()
    // ),

    // Transaction(
    //   id: 't2', 
    //   amount: 1500, 
    //   title: 'Weekly Groceries', 
    //   date: DateTime.now()
    // ),
  ];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      id: DateTime.now().toString(), 
      amount: txAmount, 
      title: txTitle, 
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx, 
      builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewTransaction(_addNewTransaction),
        behavior: HitTestBehavior.opaque,
      );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List <Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery, 
    AppBar appBar,
    Widget  txListWidget,
  ) {
    return [Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Show Chart', 
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Switch.adaptive(
                  activeColor: Theme.of(context).accentColor,
                  value: _showChart, 
                  onChanged: (val) {
                    setState(() {
                      _showChart = val;
                    });
                  }
                ),
              ],
            ),
            _showChart 
                ? Container(
                    height: (mediaQuery.size.height - 
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.7,
                    child: Chart(_recentTransactions)
                  ) 
                : txListWidget];
  }
  
  List<Widget> _buildPotraitContent(
    MediaQueryData mediaQuery, 
    AppBar appBar,
    Widget  txListWidget,
  ) {
    return [Container(
                    height: (mediaQuery.size.height - 
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.3,
                    child: Chart(_recentTransactions)
              ),  txListWidget];
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = Platform.isIOS 
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses'
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              GestureDetector(
                child: Icon(CupertinoIcons.add),
                onTap: () => _startAddNewTransaction(context),
              ),
            ],
          ),
        ) 
        : AppBar(
        title: Text(
          'Personal Expenses'
        ),
        actions: [
          IconButton(
            onPressed: () => _startAddNewTransaction(context),
            icon: Icon(Icons.add),
          )
        ],
      );

    final txListWidget = Container(
                  height: (mediaQuery.size.height - 
                          appBar.preferredSize.height -
                          mediaQuery.padding.top) *
                      0.7,
                    child: 
                        TransactionList(_userTransactions, _deleteTransaction)
                );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
          child: Column(
            children: [
            if (isLandscape) 
              ..._buildLandscapeContent(
                mediaQuery, 
                appBar,
                txListWidget,
            ),

            if(!isLandscape) 
              ..._buildPotraitContent(
                mediaQuery, 
                appBar,
                txListWidget,
              ),
            ],
          ),
        ),
    );
    
    return Platform.isIOS 
      ? CupertinoPageScaffold(child: pageBody, navigationBar: appBar,) 
      : Scaffold(
        appBar: appBar,
        body: pageBody,
      floatingActionButtonLocation: 
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS 
          ? Container() 
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
