enum NotificationType {
  transaction,
  promotion,
  information,
  security,
}

enum NotificationStatus {
  success,
  failed,
  info,
  warning,
}

enum PromotionType {
  offer,
  gift,
}

enum InformationType {
  info,
  report,
}

class NotificationEntity {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final NotificationStatus? status;
  final PromotionType? promotionType;
  final InformationType? informationType;
  final DateTime timestamp;
  final bool isRead;
  final String? amount;
  final String? recipient;
  final String? actionButtonText;
  final String? secondaryActionText;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status,
    this.promotionType,
    this.informationType,
    required this.timestamp,
    this.isRead = false,
    this.amount,
    this.recipient,
    this.actionButtonText,
    this.secondaryActionText,
  });
}