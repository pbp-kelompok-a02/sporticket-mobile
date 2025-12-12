import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sporticket_mobile/review/models/review.dart';
import 'add_review_page.dart';
import 'edit_review_page.dart';

class ReviewListPage extends StatefulWidget {
  final int matchId;

  const ReviewListPage({super.key, required this.matchId});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  bool _isMyReviewFilter = false;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = fetchReviews(context.read<CookieRequest>());
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = fetchReviews(context.read<CookieRequest>());
    });
  }

  Future<List<Review>> fetchReviews(CookieRequest request) async {
    // TODO: Replace with your actual API URL
    final response = await request.get('http://localhost:8000/review/${widget.matchId}/api/');
    var data = ReviewEntry.fromJson(response);
    return data.reviews;
  }

  Future<void> _deleteReview(int reviewId) async {
    final request = context.read<CookieRequest>();
    // TODO: Replace with your actual API URL
    final response = await request.post(
      'http://localhost:8000/review/${widget.matchId}/api/delete/$reviewId/',
      {},
    );

    if (response['status'] == 'success') {
      _refreshReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Review deleted successfully'),
          backgroundColor: Colors.green,
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? 'Failed to delete review'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Back', style: TextStyle(color: Colors.blue, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)], // Light blue gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Event Reviews',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data!.length} Review${snapshot.data!.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              _buildFilterButtons(),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Review>>(
                  future: _reviewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No reviews yet.", style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final allReviews = snapshot.data!;
                    final filteredReviews = _isMyReviewFilter
                        ? allReviews.where((r) => r.isCurrentUser).toList()
                        : allReviews;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredReviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(filteredReviews[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // TODO: Add your BottomNavigationBar here
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterButton('All Reviews', !_isMyReviewFilter, () {
          setState(() => _isMyReviewFilter = false);
        }),
        const SizedBox(width: 20),
        _buildFilterButton('My Review', _isMyReviewFilter, () {
          setState(() => _isMyReviewFilter = true);
        }),
      ],
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF5C84B1) : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for Profile Image
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 24,
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                  // TODO: Use NetworkImage if URL is available in model
                  // backgroundImage: NetworkImage(review.userProfileImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review.user,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(review.createdAt),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text('${review.rating}/5', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.komentar, style: const TextStyle(fontSize: 15, height: 1.3)),
            if (review.isCurrentUser) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to EditReviewPage
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => EditReviewPage(review: review)));
                    },
                    child: const Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Review'),
                          content: const Text('Are you sure you want to delete this review?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteReview(review.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}