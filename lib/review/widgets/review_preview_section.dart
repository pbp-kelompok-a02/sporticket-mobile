import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../widgets/review_entry_card.dart';
import '../screens/review_list_page.dart';
import '../screens/add_review_page.dart';
import '../screens/review_detail_page.dart'; // Import Detail Page
import '../screens/edit_review_page.dart'; // Import Edit Page
import 'package:sporticket_mobile/screens/profile_page.dart';

class ReviewPreviewSection extends StatefulWidget {
  final String matchId;

  const ReviewPreviewSection({super.key, required this.matchId});

  @override
  State<ReviewPreviewSection> createState() => _ReviewPreviewSectionState();
}

class _ReviewPreviewSectionState extends State<ReviewPreviewSection> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchReviewData();
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _fetchReviewData();
    });
  }

  Future<Map<String, dynamic>> _fetchReviewData() async {
    final request = context.read<CookieRequest>();
    // URL API
    final response = await request.get(
      'http://127.0.0.1:8000/review/${widget.matchId}/api/',
    );

    final reviewEntry = ReviewEntry.fromJson(response);

    return {
      'reviews': reviewEntry.reviews,
      'user_has_ticket': response['user_has_ticket'] ?? false,
      'total_count': reviewEntry.reviews.length,
    };
  }

  Future<void> _deleteReview(int reviewId) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      'http://127.0.0.1:8000/review/${widget.matchId}/api/delete/$reviewId/',
      {},
    );

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Error loading reviews: ${snapshot.error}");
        }

        final data = snapshot.data!;
        final List<Review> allReviews = data['reviews'];
        final bool userHasTicket = data['user_has_ticket'];
        final int totalCount = data['total_count'];

        final previewReviews = allReviews.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ---
              const Text(
                "Reviews",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$totalCount Reviews",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // --- LIST PREVIEW (TOP 3) ---
              if (previewReviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No reviews yet. Be the first!",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...previewReviews.map(
                  (review) => ReviewCard(
                    matchId: widget.matchId.toString(),
                    review: review,

                    isCurrentUser: review.isCurrentUser,

                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewDetailPage(
                            matchId: widget.matchId.toString(),
                            review: review,
                            isCurrentUser: review.isCurrentUser,
                          ),
                        ),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },

                    onEdit: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReviewPage(
                            matchId: widget.matchId,
                            existingReview: review,
                          ),
                        ),
                      );
                      if (result != null) _refreshData();
                    },

                    onProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(userId: review.userId),
                        ),
                      );
                    },

                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Review'),
                          content: const Text('Are you sure?'),
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
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // --- BUTTON: SHOW MORE REVIEWS ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewListPage(
                          matchId: widget.matchId.toString(),
                        ), // Convert int to String
                      ),
                    ).then(
                      (_) => _refreshData(),
                    ); // Refresh preview saat kembali
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF537FB9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Show More Reviews",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --- BUTTON: + ADD REVIEW ---
              if (userHasTicket)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReviewPage(
                            matchId: widget.matchId.toString(),
                          ), // Convert
                        ),
                      );
                      if (result == true) _refreshData();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
