import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/review.dart'; 

class EditReviewPage extends StatefulWidget {
  final String matchId;
  final Review existingReview; // Pass the review object to fill the form

  const EditReviewPage({
    super.key, 
    required this.matchId, 
    required this.existingReview
  });

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing data
    _rating = widget.existingReview.rating;
    _commentController = TextEditingController(text: widget.existingReview.komentar);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> submitEdit(CookieRequest request) async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rating cannot be zero!")),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment cannot be empty!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // URL
    final String url = 'http://127.0.0.1:8000/review/${widget.matchId}/api/edit/${widget.existingReview.id}/';

    try {
      final response = await request.postJson(
        url,
        jsonEncode({
          "rating": _rating.toString(),
          "komentar": _commentController.text,
        }),
      );

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Review updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'rating': _rating,
            'komentar': _commentController.text,
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to update review"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Review"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update your experience",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Changed your mind? Update your rating below.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Star Rating Section
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
            ),
            const Center(
              child: Text(
                "Tap stars to rate",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Comment Section
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Update your review here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => submitEdit(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}