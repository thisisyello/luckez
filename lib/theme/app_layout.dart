import 'dart:math' as math;

import 'package:flutter/material.dart';

const double pageContentMaxWidth = 520;
const double shellBottomBarHeight = 68;
const double shellBottomBarMinimumGap = 8;
const double shellFloatingActionGap = 16;

double shellBottomBarExtent(BuildContext context) {
  return shellBottomBarHeight +
      math.max(MediaQuery.paddingOf(context).bottom, shellBottomBarMinimumGap);
}

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
