import 'dart:math' as math;

import 'package:flutter/material.dart';

const double pageContentMaxWidth = 520;

class PageContentWidth extends StatelessWidget {
  const PageContentWidth({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, pageContentMaxWidth);

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: child,
          ),
        );
      },
    );
  }
}
