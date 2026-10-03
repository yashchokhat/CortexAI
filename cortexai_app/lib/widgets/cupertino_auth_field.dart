import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoAuthField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? placeholder;

  const CupertinoAuthField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.placeholder,
  });

  @override
  State<CupertinoAuthField> createState() => _CupertinoAuthFieldState();
}

class _CupertinoAuthFieldState extends State<CupertinoAuthField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused ? const Color(0xFF141414) : const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _isFocused
              ? const Color(0xFFFFFFFF) // Crisp pure white on focus
              : const Color(0x2EFFFFFF), // Hairline white border when idle
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: _isFocused
                  ? Colors.white
                  : const Color(0xCCFFFFFF), // 80% white - crisp & readable
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: widget.keyboardType,
                  placeholder: widget.placeholder,
                  placeholderStyle: const TextStyle(
                    color: Color(0x59FFFFFF), // 35% white
                    fontSize: 15.0,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: Colors.white,
                  padding: EdgeInsets.zero,
                  decoration: null,
                ),
              ),
              if (widget.isPassword)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 24,
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: _isFocused ? Colors.white : const Color(0x99FFFFFF),
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
