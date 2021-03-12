import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';

class CodeInput extends StatefulWidget {
  @override
  _CodeInputState createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  static const String MAIN_TAG = '## CodeInput';
  TextEditingController? _textController;
  String code = '';
  final int maxInputNumber = 4;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Input'),
        centerTitle: true,
      ),
      body: Stack(
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
                      ..._buildListNumWidgets(),
                    ],
                  ),
                ),
              ),
              if (!_isLoading)
                Container(
                  height: 0.0,
                  width: 0.0,
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.number,
                    keyboardAppearance: Brightness.light,
                    autofocus: true,
                    onChanged: (enteredCode) => setState(() {
                      code = enteredCode;
                    }),
                  ),
                ),
            ],
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  List<Widget> _buildListNumWidgets() {
    int maxNumberOfWidgets = maxInputNumber;
    int currentCodeLength = code.length;
    List<Widget> widgets = [];
    for (int i = 0; i <= maxNumberOfWidgets - 1; i++) {
      if (code.isNotEmpty && i <= currentCodeLength - 1) {
        String value = code.trim().substring(i, i + 1);
        widgets.add(_buildNumericalWidget(i, value));
      } else {
        widgets.add(_buildNumericalWidget(i, ''));
      }
    }
    setState(() {
      if (currentCodeLength == maxNumberOfWidgets) {
        _sendCodeToVerify();
      }
    });
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
    _isLoading = true;
    log('$MAIN_TAG._sendCodeToVerify _isLoading: $_isLoading; code: $code');

    try {
      await context.read<Auth>().sendCodeToVerify(code);
      _showCodeConfirmedMessage();
    } catch (error) {
      _showErrorDialog(error.toString());
    }
    setState(() {
      code = '';
      _textController?.clear();
      _isLoading = false;
    });
    log('$MAIN_TAG._sendCodeToVerify _isLoading: $_isLoading; code: $code');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'An Error Occured!',
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _showCodeConfirmedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
        duration: Duration(seconds: 5),
        padding: EdgeInsets.all(8.0),
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          'The code confirmed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
