// lib/widgets/bid_button.dart
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BidButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final double minBid;

  const BidButton({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.minBid,
  });

  @override
  _BidButtonState createState() => _BidButtonState();
}

class _BidButtonState extends State<BidButton> {
  bool _isValid = true;

  void _validateInput(String value) {
    double? amount = double.tryParse(value);
    if (amount == null || amount < widget.minBid) {
      setState(() {
        _isValid = false;
      });
    } else {
      setState(() {
        _isValid = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _validateInput(widget.controller.text);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {
      _validateInput(widget.controller.text);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Bid Input Field with Validation
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Your Bid',
            prefixIcon: const Icon(Icons.attach_money),
            prefixText: '\$',
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : AppColors.error,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? Colors.transparent : AppColors.error,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? AppColors.primary : AppColors.error,
                width: 2,
              ),
            ),
            hintText:
                'Enter your bid (min \$${widget.minBid.toStringAsFixed(2)})',
            errorText: _isValid
                ? null
                : 'Bid must be at least \$${widget.minBid.toStringAsFixed(2)}',
          ),
          onChanged: (value) {
            _validateInput(value);
          },
        ),
        const SizedBox(height: 20),
        // Submit Bid Button with Enhanced UI
        GestureDetector(
          onTap: _isValid ? widget.onSubmit : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: screenHeight * 0.07, // 7% of screen height
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _isValid
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isValid
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.6),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                'Submit Bid',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: screenWidth * 0.045, // 4.5% of screen width
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
