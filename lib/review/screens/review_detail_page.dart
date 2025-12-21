import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review.dart';
import '../widgets/review_entry_card.dart';
import 'edit_review_page.dart';
import 'package:sporticket_mobile/screens/profile_page.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';

class ReviewDetailPage extends StatefulWidget {
  final String matchId;
  final Review review;
  final bool isCurrentUser;
  final int? userId;

  const ReviewDetailPage({
    super.key,
    required this.matchId,
    required this.review,
    required this.isCurrentUser,
    this.userId,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late Review _currentReview;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _currentReview = widget.review;
  }

  // --- DELETE LOGIC ---
  Future<void> _handleDelete(CookieRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // FIX: URL adjusted to match standard API pattern
    final response = await request.post(
      'https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/review/${widget.matchId}/api/delete/${_currentReview.id}/',
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
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- EDIT LOGIC ---
  Future<void> _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewPage(
          matchId: widget.matchId,
          existingReview: _currentReview,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _currentReview.rating = result['rating'];
        _currentReview.komentar = result['komentar'];
        _hasChanged = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review updated!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        appBar: const SporticketAppBar(title: "Review Detail"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ReviewCard(
            matchId: widget.matchId,
            review: _currentReview,
            isCurrentUser: widget.isCurrentUser,
            enableTruncation: false,
            onTap: null,

            onEdit: _handleEdit,
            onDelete: () => _handleDelete(request),

            onProfileTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(userId: _currentReview.userId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
