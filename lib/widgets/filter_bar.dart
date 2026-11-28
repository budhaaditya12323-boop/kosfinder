import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final String searchQuery;
  final String selectedGender;
  final int? maxPrice;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onGenderSelected;
  final ValueChanged<int?> onPriceChanged;
  final VoidCallback onClearSearch;

  const FilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedGender,
    this.maxPrice,
    required this.onSearchChanged,
    required this.onGenderSelected,
    required this.onPriceChanged,
    required this.onClearSearch,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  static const List<String> genderOptions = [
    'Semua',
    'Putra',
    'Putri',
    'Campur',
  ];

  // State lokal untuk menggerakkan slider dengan mulus
  late double _currentSliderValue;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Jika maxPrice null (tanpa batas), set slider ke 0
    _currentSliderValue = widget.maxPrice?.toDouble() ?? 0.0;
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sinkronisasi jika nilai dari luar (Provider) berubah
    if (widget.maxPrice != oldWidget.maxPrice) {
      _currentSliderValue = widget.maxPrice?.toDouble() ?? 0.0;
    }
    if (widget.searchQuery != oldWidget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── SEARCH INPUT ───
          TextField(
            key: const Key('search_bar_field'),
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama atau area kos...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      key: const Key('clear_search_button'),
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        widget.onClearSearch();
                      },
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

          // ─── GENDER FILTER CHIPS ───
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genderOptions.map((gender) {
                final isSelected =
                    widget.selectedGender.toLowerCase() == gender.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    key: Key('filter_chip_${gender.toLowerCase()}'),
                    label: Text(gender),
                    selected: isSelected,
                    onSelected: (_) => widget.onGenderSelected(gender),
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
          
          const SizedBox(height: 8),

          // ─── FILTER HARGA MAKSIMAL (SLIDER) ───
          Row(
            children: [
              const Text(
                'Harga Maks: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                _currentSliderValue == 0
                    ? 'Tanpa Batas'
                    : 'Rp ${_currentSliderValue.toInt()}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _currentSliderValue,
            min: 0,
            max: 3000000,
            divisions: 30, // Jarak per 100.000
            activeColor: Colors.green.shade700,
            inactiveColor: Colors.green.shade100,
            label: _currentSliderValue == 0
                ? 'Tanpa Batas'
                : 'Rp ${_currentSliderValue.toInt()}',
            onChanged: (value) {
              setState(() {
                _currentSliderValue = value;
              });
              // Kirim nilai ke Provider (jika 0, kirim null agar "Tanpa Batas")
              if (value == 0) {
                widget.onPriceChanged(null);
              } else {
                widget.onPriceChanged(value.toInt());
              }
            },
          ),
        ],
      ),
    );
  }
}