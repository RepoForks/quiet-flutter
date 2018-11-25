import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///登录状态
///在上层嵌套 LoginStateWidget 以监听用户登录状态
class LoginState extends InheritedWidget {
  ///根据BuildContext获取 [LoginState]
  static LoginState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(LoginState);
  }

  ///刷新登录状态，检查是否登录状态已改变
  static void refresh(BuildContext context) {
    _LoginState _state =
        context.ancestorStateOfType(const TypeMatcher<_LoginState>());
    _state.checkIsLogin();
  }

  LoginState(this.user, this.child) : super(child: child);

  ///null -> not login
  ///not null -> login
  final Map<String, Object> user;

  final Widget child;

  @override
  bool updateShouldNotify(LoginState oldWidget) {
    return user != oldWidget.user;
  }

  bool get isLogin {
    return user != null;
  }
}

class LoginStateWidget extends StatefulWidget {
  LoginStateWidget(this.child);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginStateWidget> {
  Map<String, Object> user;

  void checkIsLogin() {
    SharedPreferences.getInstance().then((preference) {
      var jsonStr = preference.getString("login_user");

      Map<String, Object> user;
      if (jsonStr == null || jsonStr.isEmpty) {
        user = null;
      }
      try {
        user = json.decode(jsonStr);
      } catch (e) {}
      if (user != this.user) {
        setState(() {
          this.user = user;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    return LoginState(user, widget.child);
  }
}