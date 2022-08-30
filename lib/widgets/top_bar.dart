import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  String barTitle;
  Widget? primaryAction;
  Widget? secondaryAction;
  double? fontSize;

  // late double _deviceHeight;
  // late double _deviceWidth;

  TopBar(
    this.barTitle, {
    Key? key,
    this.primaryAction,
    this.secondaryAction,
    this.fontSize = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return SizedBox(
      // height: _deviceHeight * 0.10,
      // width: _deviceWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (secondaryAction != null) secondaryAction!,
          _titleBar(),
          if (primaryAction != null) primaryAction!,
        ],
      ),
    );
  }

  Widget _titleBar() {
    return Text(
      barTitle,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
