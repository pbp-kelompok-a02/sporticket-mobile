import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review.dart';
import '../widgets/review_entry_card.dart';
import 'edit_review_page.dart'; 

class ReviewDetailPage extends StatefulWidget {
  final String matchId;
  final Review review;
  final bool isCurrentUser;

  const ReviewDetailPage({
    super.key,
    required this.matchId,
    required this.review,
    required this.isCurrentUser,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late Review _currentReview;
  bool _hasChanged = false; // Tracks if edits happened

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
    // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web
    final response = await request.post(
      'http://127.0.0.1:8000/review/${widget.matchId}/api/delete/${_currentReview.id}/',
      {},
    );

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Review deleted successfully'),
          backgroundColor: Colors.green,
        ));
        // Return 'true' so the list page knows to refresh
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['message'] ?? 'Failed to delete'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // --- EDIT LOGIC (Option B: Update in Place) ---
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

    // Check if we got updated data back (Map) from EditReviewPage
    if (result != null && result is Map) {
      setState(() {
        _currentReview.rating = result['rating'];
        _currentReview.komentar = result['komentar'];
        _hasChanged = true; // Mark that changes occurred
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

    // PopScope ensures that when user presses Back, we send '_hasChanged' status
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Review Detail"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Manually handle back button to pass state
            onPressed: () => Navigator.pop(context, _hasChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ReviewCard(
            matchId: widget.matchId,
            review: _currentReview,
            isCurrentUser: widget.isCurrentUser,
            enableTruncation: false, // Show full text in detail view
            onTap: null, // Disable tapping the card itself (prevent recursion)
            
            onEdit: _handleEdit,
            onDelete: () => _handleDelete(request),
            
            onProfileTap: () {
               // Add profile navigation if needed
            },
          ),
        ),
      ),
    );
  }
}