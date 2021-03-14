import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../providers/auth.dart';
/// This class contains UI for entering and verifying some user's code
class CodeInput extends StatefulWidget {
  @override
  _CodeInputState createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  static const String MAIN_TAG = '## CodeInput';
  TextEditingController? _textController;
  String _code = '';
  final int _maxInputNumber = 4;
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
                      ..._buildListNumericalWidgets(),
                    ],
                  ),
                ),
              ),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: _sendCodeToVerify,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      'Confirm code',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              SizedBox(height: 20),
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
                      _code = enteredCode;
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
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Entered code is incorrect!',
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
          textColor: Colors.red,
          label: 'Ok',
          onPressed: () {},
        ),
        duration: Duration(seconds: 3),
        padding: EdgeInsets.all(8.0),
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(
          'The code confirmed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
