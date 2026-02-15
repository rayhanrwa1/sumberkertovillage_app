import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';

/// Widget avatar author yang bisa fetch foto dari database
/// Digunakan di NewsView dan NewsviewView untuk konsistensi
/// 🔧 FIXED: Added strict size constraints to prevent overflow
class AuthorAvatar extends StatefulWidget {
  final String userId;
  final String fallbackName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;

  const AuthorAvatar({
    Key? key,
    required this.userId,
    required this.fallbackName,
    this.size = 36,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
  }) : super(key: key);

  @override
  State<AuthorAvatar> createState() => _AuthorAvatarState();
}

class _AuthorAvatarState extends State<AuthorAvatar> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhoto();
  }

  Future<void> _fetchPhoto() async {
    try {
      final snapshot = await _database
          .child('profile/${widget.userId}/photo_profile')
          .get();

      if (mounted && snapshot.exists) {
        setState(() {
          _photoUrl = snapshot.value as String?;
          _isLoading = false;
        });
        print('Photo profile loaded: $_photoUrl');
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching photo for ${widget.userId}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? const Color(0xFF2C3E50).withOpacity(0.1);
    final txtColor = widget.textColor ?? const Color(0xFF2C3E50);

    // 🔧 CRITICAL FIX: Wrap everything in SizedBox with exact dimensions
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _photoUrl != null ? Colors.transparent : bgColor,
          shape: BoxShape.circle,
          border: widget.showBorder
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: ClipOval(
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: txtColor.withOpacity(0.3),
                    ),
                  ),
                )
              : _photoUrl != null && _photoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: _photoUrl!,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: txtColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      widget.fallbackName.isNotEmpty
                          ? widget.fallbackName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: widget.size * 0.4,
                        fontWeight: FontWeight.w600,
                        color: txtColor,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    widget.fallbackName.isNotEmpty
                        ? widget.fallbackName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      fontSize: widget.size * 0.4,
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
