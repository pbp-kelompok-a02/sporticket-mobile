import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../widgets/review_entry_card.dart';
import 'add_review_page.dart';
import 'review_detail_page.dart';
import 'edit_review_page.dart';
import 'package:sporticket_mobile/screens/profile_page.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';

class ReviewListPage extends StatefulWidget {
  final String matchId;

  const ReviewListPage({super.key, required this.matchId});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  bool _showMyReviewsOnly = false;
  bool _sortOldest = false; // false = newest first, true = oldest first
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchReviewData();
  }

  // Refresh function to reload data after adding/editing/deleting
  void _refreshData() {
    setState(() {
      _dataFuture = _fetchReviewData();
    });
  }

  Future<Map<String, dynamic>> _fetchReviewData() async {
    final request = context.read<CookieRequest>();
    // Adjust URL to your specific endpoint
    final response = await request.get(
      'http://127.0.0.1:8000/review/${widget.matchId}/api/',
    );
    final reviewEntry = ReviewEntry.fromJson(response);

    return {
      'reviews': reviewEntry.reviews,
      'user_has_ticket': response['user_has_ticket'] ?? false,
      'event_name': response['event_name'] ?? 'Event',
    };
  }

  Future<void> _deleteReview(int reviewId) async {
    final request = context.read<CookieRequest>();
    final response = await request.post(
      'http://127.0.0.1:8000/review/${widget.matchId}/api/delete/$reviewId/',
      {},
    );

    if (response['status'] == 'success') {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
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
    return Scaffold(
      appBar: const SporticketAppBar(title: 'Reviews'),
      // Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              // Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error State
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // Data Loaded
              final data = snapshot.data!;
              final List<Review> allReviews = data['reviews'];
              final bool userHasTicket = data['user_has_ticket'];
              final String eventName = data['event_name'];

              // Filter logic
              final displayedReviews = _showMyReviewsOnly
                  ? allReviews.where((r) => r.isCurrentUser).toList()
                  : allReviews;

              // Sorting: newest or oldest based on _sortOldest
              final sortedReviews = List<Review>.from(displayedReviews)
                ..sort(
                  (a, b) => _sortOldest
                      ? a.createdAt.compareTo(b.createdAt)
                      : b.createdAt.compareTo(a.createdAt),
                );

              return Column(
                children: [
                  // --- CUSTOM APP BAR ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.indigo,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Sort toggle: newest <-> oldest
                        IconButton(
                          icon: Icon(
                            _sortOldest
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: _sortOldest ? Colors.indigo : Colors.grey,
                          ),
                          tooltip: _sortOldest
                              ? 'Sort: Oldest first'
                              : 'Sort: Newest first',
                          onPressed: () =>
                              setState(() => _sortOldest = !_sortOldest),
                        ),
                      ],
                    ),
                  ),

                  // --- TITLE SECTION ---
                  Text(
                    "$eventName Reviews",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${allReviews.length} Review${allReviews.length == 1 ? '' : 's'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // --- "ADD REVIEW" BUTTON ---
                  if (userHasTicket) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddReviewPage(matchId: widget.matchId),
                              ),
                            );
                            if (result == true) _refreshData();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add Your Review"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF537FB9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // --- FILTER BUTTONS ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton(
                            "All Reviews",
                            !_showMyReviewsOnly,
                            () => setState(() => _showMyReviewsOnly = false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFilterButton(
                            "My Reviews",
                            _showMyReviewsOnly,
                            () => setState(() => _showMyReviewsOnly = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- REVIEW LIST ---
                  Expanded(
                    child: displayedReviews.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: displayedReviews.length,
                            itemBuilder: (context, index) {
                              final review = displayedReviews[index];
                              return ReviewCard(
                                matchId: widget.matchId,
                                review: review,
                                isCurrentUser: review.isCurrentUser,
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
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewDetailPage(
                                        matchId: widget.matchId,
                                        review: review,
                                        isCurrentUser: review.isCurrentUser,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    _refreshData();
                                  }
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Review'),
                                      content: const Text('Are you sure?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                                onProfileTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(userId: review.userId),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }

  Widget _buildFilterButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF537FB9) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF537FB9).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_bank_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No reviews yet",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
