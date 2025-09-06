import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_constants.dart';

class SearchField extends StatefulWidget {
    final String hintText;
    final TextEditingController controller;
    final VoidCallback? onSearchPressed;
    final List<String> suggestions;
    final Function(String)? onSuggestionSelected;
    final Function(String)? onChanged;
    final bool showSuggestionsBelow;

    const SearchField({
        super.key,
        required this.hintText,
        required this.controller,
        this.onSearchPressed,
        this.suggestions = const [],
        this.onSuggestionSelected,
        this.onChanged,
        this.showSuggestionsBelow = false,
    });

    @override
    State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {

    bool _isReadOnly = false;

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 필요한 만큼만 공간 사용
            children: [
                Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
                // textEditingValue의 텍스트 사용 (실시간 업데이트)
                final text = textEditingValue.text;
                if (text.isEmpty) {
                    return const Iterable<String>.empty();
                }
                return widget.suggestions.where((suggestion) => suggestion.contains(text));
            },
            onSelected: (String selected) {
                // 외부 controller에 선택된 값 설정
                widget.controller.text = selected;
                setState(() {
                    _isReadOnly = true;
                });
                widget.onSuggestionSelected?.call(selected);
            },
            optionsViewBuilder: (context, onSelected, options) {
                return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: 200,
                                minWidth: 0,
                                maxWidth: double.infinity, // 검색 필드와 동일한 너비
                            ),
                            child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                        onTap: () => onSelected(option),
                                        child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                border: index < options.length - 1
                                                    ? Border(
                                                        bottom: BorderSide(
                                                            color: Color(0xFFF3F4F6),
                                                            width: 1,
                                                        ),
                                                    )
                                                    : null,
                                            ),
                                            child: Text(
                                                option,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF374151),
                                                ),
                                            ),
                                        ),
                                    );
                                },
                            ),
                        ),
                    ),
                );
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // 외부 controller와 내부 controller 동기화
                if (widget.controller.text != controller.text) {
                    controller.text = widget.controller.text;
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: widget.controller.text.length),
                    );
                }
                
                return Container(
                    width: double.infinity,
                    height: AppConstants.searchFieldHeight,
                    decoration: BoxDecoration(
                        color: AppColors.grey50, // Grayscale/Gray-50
                        borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                        controller: controller, // Autocomplete의 내부 controller 사용
                        focusNode: focusNode,
                        readOnly: _isReadOnly,
                        onChanged: (value) {
                            // 외부 controller도 동기화
                            widget.controller.text = value;
                            widget.onChanged?.call(controller.text);
                        },
                        style: AppTextStyles.inputText, // 입력 텍스트 스타일
                        decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: AppTextStyles.inputHint, // 힌트 텍스트 스타일
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onTap: () {
                            if (_isReadOnly) {
                                setState(() {
                                    _isReadOnly = false;
                                });
                                focusNode.requestFocus();
                            }
                        }
                    ),
                );
            },
                ),
                
                // 검색 필드 아래 suggestions 목록
                if (widget.showSuggestionsBelow && widget.suggestions.isNotEmpty)
                    Container(
                        margin: EdgeInsets.only(top: 8),
                        constraints: BoxConstraints(
                            maxHeight: 150, // 최대 높이 제한을 더 작게
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE5E7EB)),
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                ),
                            ],
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.suggestions.take(5).length,
                            itemBuilder: (context, index) {
                                final suggestion = widget.suggestions[index];
                                return InkWell(
                                    onTap: () {
                                        widget.controller.text = suggestion;
                                        widget.onSuggestionSelected?.call(suggestion);
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                            border: index < widget.suggestions.take(5).length - 1
                                                ? Border(
                                                    bottom: BorderSide(
                                                        color: Color(0xFFF3F4F6),
                                                        width: 1,
                                                    ),
                                                )
                                                : null,
                                        ),
                                        child: Text(
                                            suggestion,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF374151),
                                            ),
                                        ),
                                    ),
                                );
                            },
                        ),
                    ),
            ],
        );
    }
}