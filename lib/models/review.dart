import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String foodId;
  final String foodName;
  final String sellerId;
  final String customerId;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final String? sellerReply;
  final DateTime? sellerReplyAt;

  const Review({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.sellerId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.sellerReply,
    this.sellerReplyAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> m) {
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    final reply = (m['sellerReply'] ?? '') as String;
    return Review(
      id: id,
      foodId: m['foodId'] ?? '',
      foodName: m['foodName'] ?? '',
      sellerId: m['sellerId'] ?? '',
      customerId: m['customerId'] ?? '',
      customerName: m['customerName'] ?? 'Customer',
      rating: (m['rating'] ?? 0).toDouble(),
      comment: m['comment'] ?? '',
      createdAt: ts(m['createdAt']),
      sellerReply: reply.isEmpty ? null : reply,
      sellerReplyAt: ts(m['sellerReplyAt']),
    );
  }
}