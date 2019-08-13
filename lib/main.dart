import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'message.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Messaging Service'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _emailController = new TextEditingController();
  final _pwdController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final logo = Image.asset('images/logo.png');

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Phone',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      initialValue: 'some password',
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var successSnackBar = new SnackBar(
              content: Text('Login Success'),
              duration: Duration(milliseconds: 300));
          var failureSnackBar = new SnackBar(
              content: Text('Login Failed'),
              duration: Duration(milliseconds: 300));
          Firestore.instance
              .collection("user_details")
              .where("phone", isEqualTo: _emailController.text)
              .snapshots()
              .listen((data) {
            if (data.documents.length > 0) {
              _scaffoldKey.currentState.showSnackBar(successSnackBar);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PService(data.documents[0])));
            } else {
              _scaffoldKey.currentState.showSnackBar(failureSnackBar);
            }
          });
        },
        padding: EdgeInsets.all(12),
        color: Colors.green.shade900,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final signupButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Sup()),
          );
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            //      SizedBox(height: 8.0),
            //password,
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                loginButton,
                SizedBox(
                  width: 8.0,
                ),
                signupButton
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PService extends StatelessWidget {
  DocumentSnapshot loginDetails;
  PService(DocumentSnapshot doc) {
    loginDetails = doc;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PushService(loginDetails),
    );
  }
}

class PushService extends StatefulWidget {
  DocumentSnapshot logDetails;
  PushService(DocumentSnapshot doc) {
    logDetails = doc;
  }
  @override
  _PushServiceState createState() => _PushServiceState(logDetails);
}

class _PushServiceState extends State<PushService>
    with SingleTickerProviderStateMixin {
  DocumentSnapshot lDetails;
  _PushServiceState(DocumentSnapshot doc) {
    lDetails = doc;
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];
  final GlobalKey<ScaffoldState> _psKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch $message");
        final notification = message['data'];
        setState(() {
          messages.add(
            Message(title: notification['title'], body: notification['body']),
          );
        });
      },
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage $message");
        final notification = message['notification'];
        setState(() {
          messages.add(
            Message(title: notification['title'], body: notification['body']),
          );
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume $message");
        final notification = message['data'];
        setState(() {
          messages.add(
            Message(title: notification['title'], body: notification['body']),
          );
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _psKey,
      appBar: AppBar(
        title: Text("Rainbow Traders"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListView(
            children: <Widget>[
              Card(
                child: ListTile(
                  title: Text(
                    "NSE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  trailing: FlatButton(
                    onPressed: () {
                      if (lDetails.data['nse']) {
                        _firebaseMessaging
                            .unsubscribeFromTopic("nse")
                            .then((data) {
                          print("un subscribed to nse");
                          Firestore.instance
                              .collection("user_details")
                              .document(lDetails.documentID)
                              .updateData({"nse": false}).then((data) {
                            SnackBar s = new SnackBar(
                              content: Text("Un Subscribed to NSE"),
                              duration: Duration(milliseconds: 1000),
                            );
                            _psKey.currentState.showSnackBar(s);
                          });
                        });
                      } else {
                        _firebaseMessaging.subscribeToTopic("nse").then((data) {
                          print("subscribed to nse");
                          Firestore.instance
                              .collection("user_details")
                              .document(lDetails.documentID)
                              .updateData({"nse": true}).then((data) {
                            SnackBar s = new SnackBar(
                              content: Text("Subscribed to NSE"),
                              duration: Duration(milliseconds: 1000),
                            );
                            _psKey.currentState.showSnackBar(s);
                          });
                        });
                      }
                    },
                    child: (lDetails.data['nse'])
                        ? Text("UnSubscribe")
                        : Text("Subscribe"),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text(
                    "BSE",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  trailing: FlatButton(
                      onPressed: () {
                        if (lDetails.data['bse']) {
                          _firebaseMessaging
                              .unsubscribeFromTopic("bse")
                              .then((data) {
                            print("un subscribed to bse");
                            Firestore.instance
                                .collection("user_details")
                                .document(lDetails.documentID)
                                .updateData({"bse": false}).then((data) {
                              SnackBar s = new SnackBar(
                                content: Text("Un Subscribed to BSE"),
                                duration: Duration(milliseconds: 1000),
                              );
                              _psKey.currentState.showSnackBar(s);
                            });
                          });
                        } else {
                          _firebaseMessaging
                              .subscribeToTopic("bse")
                              .then((data) {
                            print("subscribed to bse");
                            Firestore.instance
                                .collection("user_details")
                                .document(lDetails.documentID)
                                .updateData({"bse": true}).then((data) {
                              SnackBar s = new SnackBar(
                                content: Text("Subscribed to BSE"),
                                duration: Duration(milliseconds: 1000),
                              );
                              _psKey.currentState.showSnackBar(s);
                            });
                          });
                        }
                      },
                      child: (lDetails.data['bse'])
                          ? Text("Un Subscribe")
                          : Text("Subscribe")),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text(
                    "Commodity",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  trailing: FlatButton(
                      onPressed: () {
                        if (lDetails.data['commodity']) {
                          _firebaseMessaging
                              .unsubscribeFromTopic("commodity")
                              .then((data) {
                            print("un subscribed to commodity");
                            Firestore.instance
                                .collection("user_details")
                                .document(lDetails.documentID)
                                .updateData({"commodity": false}).then((data) {
                              SnackBar s = new SnackBar(
                                content: Text("un Subscribed to Commodity"),
                                duration: Duration(milliseconds: 1000),
                              );
                              _psKey.currentState.showSnackBar(s);
                            });
                          });
                        } else {
                          _firebaseMessaging
                              .subscribeToTopic("commodity")
                              .then((data) {
                            print("subscribed to commodity");
                            Firestore.instance
                                .collection("user_details")
                                .document(lDetails.documentID)
                                .updateData({"commodity": true}).then((data) {
                              SnackBar s = new SnackBar(
                                content: Text("Subscribed to Commodity"),
                                duration: Duration(milliseconds: 1000),
                              );
                              _psKey.currentState.showSnackBar(s);
                            });
                          });
                        }
                      },
                      child: (lDetails.data['commodity'])
                          ? Text("Un Subscribe")
                          : Text("Subscribe")),
                ),
              ),
            ],
            shrinkWrap: true,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "Notifications ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.grey,
          ),
          Expanded(
            child: ListView(
              children: messages.map(buildMessage).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessage(Message msg) {
    return ListTile(
      title: Text(msg.title),
      subtitle: Text(msg.body),
    );
  }
}

class Sup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Signup(),
    );
  }
}

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _nameController = new TextEditingController();
  final _phoneController = new TextEditingController();
  static GlobalKey<ScaffoldState> _regKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final logo = Image.asset('images/logo.png');

    final name = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _nameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Enter Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final phone = TextFormField(
      keyboardType: TextInputType.phone,
      controller: _phoneController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Enter Phone Number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          var obj = {
            "uname": _nameController.text,
            "phone": _phoneController.text,
            "nse": false,
            "bse": false,
            "commodity": false
          };
          SnackBar s = new SnackBar(
            content: Text("Data Inserted Succesfully !!!"),
            duration: Duration(milliseconds: 500),
          );
          Firestore.instance.collection('user_details').add(obj).then((doc) {
            print('Data inserted into user_table successfully');
            _regKey.currentState.showSnackBar(s);
            _nameController.text = "";
            _phoneController.text = "";
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          });
        },
        padding: EdgeInsets.all(12),
        color: Colors.green.shade900,
        child: Text('Sign Up', style: TextStyle(color: Colors.white)),
      ),
    );

    final signupButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Sign In', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      key: _regKey,
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            name,
            SizedBox(height: 8.0),
            phone,
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                loginButton,
                SizedBox(
                  width: 8.0,
                ),
                signupButton
              ],
            ),
          ],
        ),
      ),
    );
  }
}
