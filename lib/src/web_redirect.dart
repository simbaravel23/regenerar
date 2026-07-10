// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class SiteWebView extends StatefulWidget {
  const SiteWebView({super.key, required this.url});

  final String url;

  @override
  State<SiteWebView> createState() => _SiteWebViewState();
}

class _SiteWebViewState extends State<SiteWebView> {
  late final String _viewType;
  late final html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = 'site-frame-${widget.url.hashCode}';
    _iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

Widget buildSiteView(String url) {
  return SiteWebView(url: url);
}
