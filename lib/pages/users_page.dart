//Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

//Providers
// import '../providers/authentication_provider.dart';
// import '../providers/users_page_provider.dart';

//Widgets
// import '../widgets/top_bar.dart';
// import '../widgets/custom_input_fields.dart';
// import '../widgets/custom_list_view_tiles.dart';
// import '../widgets/rounded_button.dart';

//Models
// import '../models/chat_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return const Scaffold(
      backgroundColor: Colors.green,
    );
  }
}
