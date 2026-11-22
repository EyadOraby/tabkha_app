import 'package:material_ui/material_ui.dart';

/// Builds a screen from a deferred library once it has loaded.
///
/// On the web, deferred libraries are split into their own files, so the
/// restaurant, courier and platform consoles stay out of the first download
/// that every customer pays for. On mobile, loading completes at once.
class DeferredView extends StatefulWidget {
  const DeferredView({super.key, required this.load, required this.builder});

  final Future<void> Function() load;
  final Widget Function() builder;

  @override
  State<DeferredView> createState() => _DeferredViewState();
}

class _DeferredViewState extends State<DeferredView> {
  late Future<void> _loading = widget.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
          return widget.builder();
        }
        return Scaffold(
          body: Center(
            child: snapshot.hasError
                ? TextButton.icon(
                    onPressed: () => setState(() => _loading = widget.load()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
