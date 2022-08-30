//Packages
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//Widgets
import '../widgets/rounded_image_network.dart';
// import '../widgets/message_bubbles.dart';

//Models
// import '../models/chat_message.dart';
// import '../models/chat_user.dart';

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  const CustomListViewTile({
    Key? key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      // space between tiles
      // leading: RoundedImageNetworkWithStatusIndicator(
      //   key: UniqueKey(),
      //   size: height / 2,
      //   imagePath: imagePath,
      //   isActive: isActive,
      // ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  const CustomListViewTileWithActivity({
    Key? key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity, // Boolean value to show if it is someone typing or to see the last message
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        // key: UniqueKey(),
        size: height / 2,
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Boolean value to show if it is someone typing or to see the last message
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  // Animation gives us three circles that kind expand and contract
                  // such as typing indicator
                  color: Colors.white54,
                  size: height * 0.20,
                ),
              ],
            )
          : Text(
              subtitle,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
    );
  }
}
