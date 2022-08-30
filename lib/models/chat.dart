import '../models/chat_user.dart';
import '../models/chat_message.dart';

class Chat {
  final String uid;
  final String currentUserUid;
  final bool activity;
  final bool group;
  final List<ChatUser> members;
  List<ChatMessage> messages;

  late final List<ChatUser>
      recipients; // all users but it's not going to include the user who is currently logged in

  Chat({
    required this.uid,
    required this.currentUserUid,
    required this.members,
    required this.messages,
    required this.activity,
    required this.group,
  }) {
    recipients = members.where((i) => i.uid != currentUserUid).toList();
  }

  List<ChatUser> recepients() {
    return recipients;
  }

  String title() {
    return !group
        ? recipients.first.name
        : recipients.map((user) => user.name).join(", ");
  }

  String imageURL() {
    return !group
        ? recipients.first.imageURL
        : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
  }
}