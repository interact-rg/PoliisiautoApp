import 'package:flutter/material.dart';

class LocaleProvider extends StatefulWidget {
  final Widget child;

  const LocaleProvider({super.key, required this.child});

  @override
  _LocaleProviderState createState() => _LocaleProviderState();

  static _LocaleProviderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_LocaleProviderState>();
  }

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', ''),
    Locale('fi', '')
  ];
}

class _LocaleProviderState extends State<LocaleProvider> {
  Locale? _locale;

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
  }

  Locale? get locale => _locale;

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return widget.child;
    }

    return Localizations.override(
      context: context,
      locale: _locale!,
      child: widget.child,
    );
  }
}
