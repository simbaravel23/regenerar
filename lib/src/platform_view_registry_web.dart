// Web implementation that forwards to `dart:ui` platformViewRegistry.
import 'dart:ui' as ui;

// The name `platformViewRegistry` is only available on web builds.
// ignore: undefined_prefixed_name
void registerViewFactory(String viewId, dynamic Function(int) factory) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewId, factory);
}
