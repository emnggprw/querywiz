import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Enum representing the various states a message can be in
enum MessageStatus {
  /// Message is being sent
  sending,

  /// Message has been sent to the server
  sent,

  /// Message has been delivered to the recipient
  delivered,

  /// Message has been read by the recipient
  read,

  /// Error occurred during sending
  error,

  /// Message is being generated (for AI responses)
  generating,

  /// AI has responded to the message
  responded,

  /// Message is being edited
  editing,

  /// Message has been deleted
  deleted
}

/// Extension to provide helpful methods for MessageStatus
extension MessageStatusExtension on MessageStatus {
  /// Returns true if the message is in a terminal state
  bool get isTerminal =>
      this == MessageStatus.delivered ||
          this == MessageStatus.read ||
          this == MessageStatus.error ||
          this == MessageStatus.responded ||
          this == MessageStatus.deleted;

  /// Returns the icon associated with this status
  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.error:
        return Icons.error_outline;
      case MessageStatus.generating:
        return Icons.more_horiz;
      case MessageStatus.responded:
        return Icons.check_circle_outline;
      case MessageStatus.editing:
        return Icons.edit;
      case MessageStatus.deleted:
        return Icons.delete_outline;
    }
  }

  /// Returns the color for this status
  Color get color {
    switch (this) {
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.error:
        return Colors.red;
      case MessageStatus.deleted:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

/// Types of attachments that can be added to a message
enum AttachmentType {
  image,
  video,
  file,
  audio,
  location,
  contact,
  custom
}

/// Represents an attachment in a message
class MessageAttachment {
  final String id;
  final AttachmentType type;
  final String url;
  final String? thumbnailUrl;
  final String? name;
  final int? size; // in bytes
  final Map<String, dynamic>? metadata;

  MessageAttachment({
    String? id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.name,
    this.size,
    this.metadata,
  }) : id = id ?? const Uuid().v4();

  /// Create an attachment from JSON
  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      type: AttachmentType.values.firstWhere(
            (e) => e.toString() == 'AttachmentType.${json['type']}',
        orElse: () => AttachmentType.file,
      ),
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      name: json['name'],
      size: json['size'],
      metadata: json['metadata'],
    );
  }

  /// Convert attachment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'url': url,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (name != null) 'name': name,
      if (size != null) 'size': size,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Reactions that can be added to messages
class MessageReaction {
  final String emoji;
  final String userId;
  final DateTime timestamp;

  MessageReaction({
    required this.emoji,
    required this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a reaction from JSON
  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Convert reaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Primary Message class representing a chat message
class Message {
  final String id;
  final String text;
  final String? senderId;
  final String? receiverId;
  final DateTime timestamp;
  final DateTime? editedTimestamp;
  final MessageStatus status;
  final List<MessageAttachment> attachments;
  final List<MessageReaction> reactions;
  final bool isUser;
  final String? formattedContent; // Rich text support (JSON Delta)
  final String? replyToId; // ID of message being replied to
  final Map<String, dynamic>? metadata; // Custom metadata

  /// Constructor with required and optional fields
  Message({
    String? id,
    required this.text,
    this.senderId,
    this.receiverId,
    DateTime? timestamp,
    this.editedTimestamp,
    required this.isUser,
    MessageStatus? status,
    List<MessageAttachment>? attachments,
    List<MessageReaction>? reactions,
    this.formattedContent,
    this.replyToId,
    this.metadata,
  }) :
        id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        status = status ?? (isUser ? MessageStatus.sending : MessageStatus.delivered),
        attachments = attachments ?? [],
        reactions = reactions ?? [];

  /// Create a message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      timestamp: DateTime.parse(json['timestamp']),
      editedTimestamp: json['editedTimestamp'] != null
          ? DateTime.parse(json['editedTimestamp'])
          : null,
      isUser: json['isUser'],
      status: MessageStatus.values.firstWhere(
            (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      attachments: (json['attachments'] as List?)
          ?.map((a) => MessageAttachment.fromJson(a))
          .toList() ?? [],
      reactions: (json['reactions'] as List?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      formattedContent: json['formattedContent'],
      replyToId: json['replyToId'],
      metadata: json['metadata'],
    );
  }

  /// Convert message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      if (senderId != null) 'senderId': senderId,
      if (receiverId != null) 'receiverId': receiverId,
      'timestamp': timestamp.toIso8601String(),
      if (editedTimestamp != null) 'editedTimestamp': editedTimestamp?.toIso8601String(),
      'isUser': isUser,
      'status': status.toString().split('.').last,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
      if (reactions.isNotEmpty)
        'reactions': reactions.map((r) => r.toJson()).toList(),
      if (formattedContent != null) 'formattedContent': formattedContent,
      if (replyToId != null) 'replyToId': replyToId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create a copy of this message with modified fields
  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    DateTime? editedTimestamp,
    bool? isUser,
    MessageStatus? status,
    List<MessageAttachment>? attachments,
    List<MessageReaction>? reactions,
    String? formattedContent,
    String? replyToId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      isUser: isUser ?? this.isUser,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      reactions: reactions ?? this.reactions,
      formattedContent: formattedContent ?? this.formattedContent,
      replyToId: replyToId ?? this.replyToId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Add an attachment to this message
  Message addAttachment(MessageAttachment attachment) {
    final newAttachments = List<MessageAttachment>.from(attachments)..add(attachment);
    return copyWith(attachments: newAttachments);
  }

  /// Add a reaction to this message
  Message addReaction(MessageReaction reaction) {
    final newReactions = List<MessageReaction>.from(reactions)..add(reaction);
    return copyWith(reactions: newReactions);
  }

  /// Remove a reaction from this message
  Message removeReaction(String userId, String emoji) {
    final newReactions = reactions.where(
            (r) => !(r.userId == userId && r.emoji == emoji)
    ).toList();
    return copyWith(reactions: newReactions);
  }

  /// Mark the message as edited
  Message markAsEdited(String newText, {String? newFormattedContent}) {
    return copyWith(
      text: newText,
      formattedContent: newFormattedContent ?? formattedContent,
      editedTimestamp: DateTime.now(),
    );
  }

  /// Update the message status
  Message updateStatus(MessageStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// Check if the message is edited
  bool get isEdited => editedTimestamp != null;

  /// Check if the message is a reply
  bool get isReply => replyToId != null;

  /// Check if the message has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Check if the message has reactions
  bool get hasReactions => reactions.isNotEmpty;

  /// Check if the message has formatted content
  bool get hasFormattedContent => formattedContent != null;

  /// Parse the formatted content as rich text (if available)
  dynamic get parsedFormattedContent {
    if (formattedContent == null) return null;
    try {
      return jsonDecode(formattedContent!);
    } catch (e) {
      return null;
    }
  }

  /// Create a text-only message
  factory Message.text({
    required String text,
    required bool isUser,
    String? senderId,
    String? receiverId,
  }) {
    return Message(
      text: text,
      isUser: isUser,
      senderId: senderId,
      receiverId: receiverId,
    );
  }

  /// Create a reply message
  factory Message.reply({
    required String text,
    required bool isUser,
    required String replyToId,
    String? senderId,
    String? receiverId,
    String? formattedContent,
  }) {
    return Message(
      text: text,
      isUser: isUser,
      senderId: senderId,
      receiverId: receiverId,
      replyToId: replyToId,
      formattedContent: formattedContent,
    );
  }

  /// Create a system message
  factory Message.system({
    required String text,
    String? formattedContent,
  }) {
    return Message(
      text: text,
      isUser: false,
      senderId: 'system',
      formattedContent: formattedContent,
      metadata: {'isSystemMessage': true},
    );
  }
}