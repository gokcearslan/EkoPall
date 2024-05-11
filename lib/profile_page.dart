import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekopal/colors.dart';
import 'package:ekopal/usersvotes_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ekopal/login_page.dart';
import 'package:ekopal/services/image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'change_password_page.dart';
import 'mySharingsPage.dart';

// YORUM(YANIT) VE OY VERME ÖZELLİKLERİ EKLENİNCE
// PAYLAŞIM GİBİ ÇEKİLECEK -g
//email conform buradan kaldırılacak


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ImageService _imageService = ImageService();
  String name = '';
  String? _base64Image;
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  User? _currentUser;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchProfileImage(); // Fetch the profile image URL
    fetchUser();
    _tabController = TabController(length: 3, vsync: this);
  }
  Future<void> _fetchProfileImage() async {
    String userId = _currentUser?.uid ?? '';
    String? url = await _imageService.getImageUrlFromFirestore(userId);
    setState(() {
      _imageUrl = url;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchUser() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String,
          dynamic>;
      setState(() {
        name = userData['name'] as String;
      });
    } else {
      print('Böyle bir kullanıcı bulunmamaktadır!');
    }
  }
/*
  Future<void> fetchImage() async {
    String? base64Image = await _imageService.getImageFromFirestore(
        _currentUser!.uid);
    setState(() {
      _base64Image = base64Image ?? '';
    });
  }


 */
  void _showEditImageActionSheet(BuildContext context) {
    final action = CupertinoActionSheet(
      title: Text("Picture", style: TextStyle(fontSize: 15.0, color: Color(0xFF001489))),
      message: Text("Select a picture", style: TextStyle(fontSize: 15.0, color: Color(0xFF001489).withOpacity(0.7))),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Camera", style: TextStyle(color: Color(0xFF001489))),
          onPressed: () {
            Navigator.pop(context);
            _imageService.pickAndUploadImage(ImageSource.camera).then((_) {
              _fetchProfileImage(); // Refresh the image URL after uploading
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text("Gallery", style: TextStyle(color: Color(0xFF001489))),
          onPressed: () {
            Navigator.pop(context);
            _imageService.pickAndUploadImage(ImageSource.gallery).then((_) {
              _fetchProfileImage(); // Refresh the image URL after uploading
            });
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Close", style: TextStyle(color: Colors.red)),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => action,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil',
            style: TextStyle(fontSize: 26)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: <Widget>[

          //Edit profil özelliği eklenecek
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Navigate to the edit profile page or open edit mode
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
      Stack(
        children: [
          Container(
            width: width * 0.3,
            height: width * 0.3,
            decoration: BoxDecoration(
              color: Colors.black12,
              shape: BoxShape.circle,
              border: Border.all(color: somon, width: 1),
              image: _imageUrl != null
                  ? DecorationImage(
                image: NetworkImage(_imageUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
          ),
          Positioned(
            right: width * 0.01,
            bottom: height * 0.05,
            child: Container(
              width: width * 0.15,
              height: height * 0.07,
              decoration: BoxDecoration(
                color: Color(0xfff2f9fe),
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF001489), width: 1),
              ),
              child: IconButton(
                onPressed: ()  {
                  _showEditImageActionSheet(context);
                },

                icon: Icon(
                  Icons.edit,
                  color: Color(0xFF001489),
                  size: width * 0.05,
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      Align(
        alignment: Alignment.center,
        child: Text(name, style: TextStyle(
            color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold)),
      ),
      SizedBox(height: 10),
      _currentUser?.emailVerified == true
          ? Text(
        'Email confirmed',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      )
          : Text(
        'Email could not be confirmed',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: _currentUser != null && !_currentUser!.emailVerified
            ? () async {
          setState(() {
            _isSendingVerification = true;
          });
          await _currentUser!.sendEmailVerification();
          setState(() {
            _isSendingVerification = false;
          });
        }
            : null,
        child: _isSendingVerification
            ? CircularProgressIndicator()
            : Text(
          'Confirm Email',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_currentUser != null && _currentUser!.emailVerified) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(),
                  ),
                );
              }
            },
            child: Text(
              'Change Password',
              style: TextStyle(color: Colors.white),
            ),
            style: _currentUser != null && _currentUser!.emailVerified
                ? ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            )
                : ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              backgroundColor: Colors.purple.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isSigningOut = true;
              });
              await FirebaseAuth.instance.signOut();
              setState(() {
                _isSigningOut = false;
              });
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Logout',
                    style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.exit_to_app, color: Colors.white),
              ],
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 20),
      TabBar(
        controller: _tabController,
        indicatorColor: buttonColor,
        labelColor: textColor,
        labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        tabs: [
          Tab(text: 'Paylaşımlarım'),
          Tab(text: 'Yanıtlarım'),
          Tab(text: 'Oylarım'),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            MySharingsPage(showAppBar: false),
            Text('Content for comments'),
            UserVotesPage(),

          ],
        ),
      ),
    ]
      ),
    );
  }


}