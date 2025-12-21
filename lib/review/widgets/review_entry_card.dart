import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  final String matchId;
  final Review review;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onProfileTap;
  final VoidCallback? onTap;
  final bool enableTruncation;

  const ReviewCard({
    Key? key,
    required this.matchId,
    required this.review,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
    this.onProfileTap,
    this.onTap,
    this.enableTruncation = true,
  }) : super(key: key);

  Widget _buildStarRating(int rating) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_rounded,
            color: index < rating ? const Color(0xFFFBBF24) : const Color(0xFFE5E7EB),
            size: 20,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${review.rating}/5',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCommentSection() {
    const int truncateLength = 150;
    if (enableTruncation && review.komentar.length > truncateLength) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${review.komentar.substring(0, truncateLength)}...",
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Read More",
            style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ],
      );
    } else {
      return Text(
        review.komentar,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF374151),
          height: 1.5,
        ),
      );
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: const Color(0xFFE0E7FF),
      alignment: Alignment.center,
      child: Text(
        review.user.isNotEmpty ? review.user[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Color(0xFF4338CA),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- AVATAR ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22), 
                        onTap: onProfileTap, 
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: ClipOval(
                            child: review.profilePhoto.isNotEmpty
                                ? Image.network(
                                    review.profilePhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildPlaceholderAvatar(),
                                  )
                                : _buildPlaceholderAvatar(),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 14),

                    // --- USER INFO ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- NAMA USER ---
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: onProfileTap,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  review.user,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStarRating(review.rating),
                        ],
                      ),
                    ),

                    // Date
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- COMMENT SECTION ---
                _buildCommentSection(),

                // --- ACTION BUTTONS (Edit/Delete) ---
                if (isCurrentUser) ...[
                  const SizedBox(height: 20),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: const Color(0xFFFEF2F2),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}