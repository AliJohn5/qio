import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qio/api/users.dart';
import 'package:qio/models/users/users.dart';
import 'package:qio/screens/profile_other_screen.dart';

class PublisherWidget extends StatefulWidget {
  const PublisherWidget({super.key, required this.user});
  final String user;

  @override
  State<PublisherWidget> createState() => _PublisherWidgetState();
}

class _PublisherWidgetState extends State<PublisherWidget> {
  User user = User(
    email: "email",
    userType: UserType.company,
    followersEmails: [],
    followingEmails: [],
  );

  bool isLoading = true;
  bool isFollwingUser = false;

  void _getUserData() async {
    setState(() => isLoading = true);

    final resProfile = await DioClient.instance.get(
      "api/users/profile/${widget.user}/",
    );

    User user1 = User(
      email: "email",
      userType: UserType.company,
      followersEmails: [],
      followingEmails: [],
    );

    if (resProfile.statusCode == 200) {
      user1.firstName = resProfile.data['first_name'] ?? '';
      user1.email = resProfile.data['email'] ?? '';
      user1.lastName = resProfile.data['last_name'] ?? '';
      user1.phoneNumber = resProfile.data['phone_number'] ?? '';
      user1.userType =
          resProfile.data['user_type'] == 'public'
              ? UserType.company
              : UserType.private;
      setState(() {
        user = user1;
        isLoading = false;
      });
      final res = await DioClient.instance.get(
        "api/users/image/${widget.user}/",
      );

      if (res.statusCode == 200) {
        String imageURL = res.data[0]['image'] ?? "";
        if (imageURL.startsWith('/')) imageURL = imageURL.substring(1);
        user1.imageUrl = domain + imageURL;

        setState(() {
          user = user1;
          isLoading = false;
        });
      }
      final resCountFollwers = await DioClient.instance.get(
        "api/users/profile/followers/get/${widget.user}/",
      );

      if (resCountFollwers.statusCode == 200) {
        for (var u in resCountFollwers.data) {
          user1.followersEmails.add(u['email']);
          //print(u['email']);
        }
        setState(() {
          user = user1;
          isLoading = false;
        });
      }

      final resFollowing = await DioClient.instance.get(
        "api/users/profile/following/get/",
      );
      bool isFollwingUserTemp = false;

      if (resFollowing.statusCode == 200) {
        for (var u in resFollowing.data) {
          if (u['email'] == widget.user) {
            isFollwingUserTemp = true;
            break;
          }
        }
        setState(() {
          isFollwingUser = isFollwingUserTemp;
          isLoading = false;
        });
      }
    }

    setState(() {
      user = user1;
      isLoading = false;
    });
  }

  void _followUser() async {
    bool isFollwingUserTemp = isFollwingUser;
    if (isFollwingUser) {
      final res = await DioClient.instance.post(
        "api/users/profile/${widget.user}/unfollow/",
      );
      if (res.statusCode == 200) isFollwingUserTemp = false;
    } else {
      final res = await DioClient.instance.post(
        "api/users/profile/${widget.user}/follow/",
      );
      if (res.statusCode == 200) isFollwingUserTemp = true;
    }

    setState(() {
      isFollwingUser = isFollwingUserTemp;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    return  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'الناشر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: (){
                  Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => ProfileOtherScreen(userEmail: widget.user,),
                ),
              );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: ClipOval(
                      child:
                          user.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: user.imageUrl,
                                placeholder:
                                    (context, url) => CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) => Text(
                                      user.email.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              )
                              : Text(
                                user.email.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نوع الحساب: ${user.userType.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _followUser,
                    child:
                        isFollwingUser ? Text("إلغاء المتابعة") : Text('متابعة'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
