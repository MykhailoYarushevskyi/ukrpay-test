import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';

/// This class contains UI for entering and verifying user's access code
class CodeInput extends StatefulWidget {
  @override
  _CodeInputState createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  // static const String MAIN_TAG = '## CodeInput'; // for log() prints
  late final TextEditingController? _textController;
  String _code = '';
  final String _appBarTitle = 'Enter the code access';
  final int _maxInputNumber = 4;
  final bool _isIOS = Platform.isIOS;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _textController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isIOS
        ? CupertinoPageScaffold(
            navigationBar: _buildCupertinoCupertinoNavigationBar(),
            child: _pageBody(),
          )
        : Scaffold(
            appBar: _buildAndroidAppBar(),
            body: _pageBody(),
          );
  }

  Widget _pageBody() {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ..._buildListNumericalWidgets(),
                    ],
                  ),
                ),
              ),
              if (!_isLoading) _buildButton('Confirm code'),
              SizedBox(height: 20),
              if (!_isLoading)
                Container(
                  height: 0.0,
                  width: 0.0,
                  child: _buildTextField(),
                ),
            ],
          ),
          if (_isLoading)
            Center(
                child: _isIOS
                    ? CupertinoActivityIndicator(
                        radius: 40.0,
                      )
                    : CircularProgressIndicator(
                        semanticsLabel: 'Circular Progress Indicator',
                      )),
        ],
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildCupertinoCupertinoNavigationBar() {
    return CupertinoNavigationBar(
      middle: Text(_appBarTitle),
    );
  }

  PreferredSizeWidget _buildAndroidAppBar() {
    return AppBar(
      title: Text(_appBarTitle),
      centerTitle: true,
    );
  }

  Widget _buildButton(String text) {
    return _isIOS
        ? CupertinoButton.filled(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
            onPressed: _sendCodeToVerify,
          )
        : ElevatedButton(
            onPressed: _sendCodeToVerify,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
  }

  Widget _buildTextField() {
    return _isIOS
        ? CupertinoTextField(
            controller: _textController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.unspecified,
            autofocus: true,
            onChanged: (enteredCode) => setState(() {
              _code = enteredCode;
            }),
          )
        : TextField(
            textInputAction: TextInputAction.unspecified,
            controller: _textController,
            keyboardType: TextInputType.number,
            keyboardAppearance: Brightness.light,
            autofocus: true,
            onChanged: (enteredCode) => setState(() {
              _code = enteredCode;
            }),
          );
  }

  List<Widget> _buildListNumericalWidgets() {
    int maxNumberOfWidgets = _maxInputNumber;
    int currentCodeLength = _code.length;
    List<Widget> widgets = [];
    for (int i = 0; i <= maxNumberOfWidgets - 1; i++) {
      if (_code.isNotEmpty && i <= currentCodeLength - 1) {
        String value = _code.substring(i, i + 1);
        widgets.add(_buildNumericalWidget(i, value));
      } else {
        widgets.add(_buildNumericalWidget(i, ''));
      }
    }
    return widgets;
  }

  Widget _buildNumericalWidget(int index, String value) {
    return Container(
      key: ValueKey(index),
      height: 50.0,
      width: 50.0,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 40.0),
      ),
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
    );
  }

  Future<void> _sendCodeToVerify() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await context.read<Auth>().sendCodeToVerify(_code);
      _showCodeConfirmedMessage();
    } catch (error) {
      await _showErrorDialog(error.toString());
    }
    resetCodeProcessing();
  }

  void resetCodeProcessing() {
    setState(() {
      _code = '';
      _textController?.clear();
      _isLoading = false;
    });
  }

  Future<void> _showErrorDialog(String message) async {
    if (_isIOS) {
      _showCupertinoDialog(
        'The Entered code is incorrect!',
        titleColor: Theme.of(context).errorColor,
        content: message,
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'The Entered code is incorrect!',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  void _showCodeConfirmedMessage() {
    if (_isIOS) {
      _showCupertinoDialog('The code access confirmed');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          action: SnackBarAction(
            textColor: Colors.red,
            label: 'Ok',
            onPressed: () {},
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          padding: EdgeInsets.all(8.0),
          backgroundColor: Theme.of(context).primaryColor,
          content: const Text(
            'The code access confirmed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showCupertinoDialog(
    String title, {
    String content = '',
    String actionText = 'Ok',
    Color titleColor = Colors.black,
  }) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text(actionText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
