import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedGender;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onGenderSelected;
  final VoidCallback onClearSearch;

  const FilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedGender,
    required this.onSearchChanged,
    required this.onGenderSelected,
    required this.onClearSearch,
  });

  static const List<String> genderOptions = [
    'Semua',
    'Putra',
    'Putri',
    'Campur',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            key: const Key('search_bar_field'),
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: searchQuery.length),
              ),
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama atau area kos...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      key: const Key('clear_search_button'),
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: onClearSearch,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade700, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Gender Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genderOptions.map((gender) {
                final isSelected =
                    selectedGender.toLowerCase() == gender.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    key: Key('filter_chip_${gender.toLowerCase()}'),
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (_) => onGenderSelected(gender),
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green.shade800,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.green.shade900
                          : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
