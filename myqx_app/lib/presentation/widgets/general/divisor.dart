import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/app_constants.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class Divisor extends StatelessWidget {
  const Divisor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.verticalMargins),
      child: const Divider(
        color: CorporativeColors.mainColor,
        thickness: 1.5,
      ),
    );
  }
}