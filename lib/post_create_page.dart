import 'package:ekopal/services/firebase_service.dart';
import 'package:ekopal/services/post_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PostCreationPage extends StatefulWidget {
  @override
  _PostCreationPageState createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _postTitleController = TextEditingController(); // New controller for post title
  final PostService _postService = PostService();

  //random id yaratma
  void _createPost() async {
    final String id = Random().nextInt(100000).toString();
    final String postContent = _postContentController.text;
    final String postTitle = _postTitleController.text;

    if (postContent.isNotEmpty) {
      final post = Post(id: id, PostContent: postContent, postTitle: postTitle);

      await _postService.addPost(post).then((value) {
        print("Postunuz başarıyla paylaşıldı");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Postunuz başarıyla paylaşıldı')));
      }).catchError((error) {
        print("Paylaşma sırasında bir hata oluştu: $error");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paylaşma sırasında bir hata oluştu')));
      });

      _postContentController.clear();
    } else {
      print("Bu alan boş kalamaz.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bu alan boş kalamaz.')));
    }
  }

  @override
  void dispose() {
    _postContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gönderi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _postTitleController, // Use the new controller here
              decoration: InputDecoration(
                labelText: 'Gönderi Başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _postContentController,
              decoration: InputDecoration(
                labelText: 'Gönderi İçeriği',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Gönderi Oluşturun'),
            ),
          ],
        ),
      ),
    );
  }

}
