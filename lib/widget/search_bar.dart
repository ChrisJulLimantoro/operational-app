import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:operational_app/theme/colors.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  const SearchBarWidget({super.key, required this.controller});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        spacing: 0,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Icon(CupertinoIcons.search, color: AppColors.pinkPrimary),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.pinkPrimary.withValues(alpha: 0.8),
                ),
                fillColor: AppColors.pinkPrimary,
              ),
              controller: _controller,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                debugPrint(_controller.value.text);
              },
              cursorColor: AppColors.pinkPrimary,
              style: TextStyle(color: AppColors.pinkPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: AppColors.pinkPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
