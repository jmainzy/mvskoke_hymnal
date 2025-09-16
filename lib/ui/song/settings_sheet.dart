import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class SettingsSheet extends StatefulWidget {
  final Function(double fontSize)? onChangeFontSize;

  const SettingsSheet({
    required this.onChangeFontSize,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SettingsSheetState();
}

class SettingsSheetState extends State<SettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.marginLarge),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 4,
          ),
          child: Column(
            children: [
              TextSizeWidget(onChangeFontSize: widget.onChangeFontSize),
              const SizedBox(height: Dimens.marginShort),
            ],
          ),
        ),
      ),
    );
  }
}

class TransposeWidget extends StatefulWidget {
  final int transposeIncrement;
  final Function(Direction direction)? onChangeTranspose;

  const TransposeWidget({
    required this.transposeIncrement,
    required this.onChangeTranspose,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => TransposeWidgetState();
}

class TransposeWidgetState extends State<TransposeWidget> {
  int transposeIncrement = 0;

  @override
  void initState() {
    super.initState();
    transposeIncrement = widget.transposeIncrement;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Transpose', style: Theme.of(context).textTheme.bodyMedium),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onChangeTranspose == null
                    ? null
                    : () {
                        widget.onChangeTranspose?.call(Direction.down);
                        setState(() {
                          transposeIncrement--;
                        });
                      },
                icon: const Icon(Icons.arrow_downward_rounded),
                color: Theme.of(context).colorScheme.primary,
              ),
              Text('$transposeIncrement'),
              IconButton(
                onPressed: widget.onChangeTranspose == null
                    ? null
                    : () {
                        widget.onChangeTranspose?.call(Direction.up);
                        setState(() {
                          transposeIncrement++;
                        });
                      },
                icon: const Icon(Icons.arrow_upward_rounded),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ToggleChordsWidget extends StatefulWidget {
  final Function(bool showChords)? onToggle;

  const ToggleChordsWidget({required this.onToggle, super.key});

  @override
  State<StatefulWidget> createState() => ToggleChordsWidgetState();
}

class ToggleChordsWidgetState extends State<ToggleChordsWidget> {
  bool showChords = false;
  StoreService prefs = sl<MusStoreService>();

  @override
  void initState() {
    super.initState();
    showChords = prefs.get('show_chords') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Show chords', style: Theme.of(context).textTheme.bodyMedium),
        Padding(
          padding: const EdgeInsets.only(right: Dimens.marginLarge),
          child: Switch(
            value: showChords,
            onChanged: (value) {
              widget.onToggle?.call(value);
              prefs.put('show_chords', value);
              setState(() {
                showChords = value;
              });
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class TextSizeWidget extends StatefulWidget {
  final Function(double fontSize)? onChangeFontSize;

  const TextSizeWidget({required this.onChangeFontSize, super.key});

  @override
  State<StatefulWidget> createState() => TextSizeWidgetState();
}

class TextSizeWidgetState extends State<TextSizeWidget> {
  double fontSize = 0;
  StoreService prefs = sl<MusStoreService>();

  @override
  void initState() {
    super.initState();
    fontSize = prefs.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyLarge!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('A', style: textStyle.copyWith(fontSize: 16)),
        Expanded(
          child: Slider(
            value: fontSize,
            onChanged: (value) {
              prefs.setFontSize(value);
              setState(() {
                fontSize = value;
              });
              widget.onChangeFontSize?.call(value);
            },
            min: 14,
            max: 32,
            divisions: 10,
          ),
        ),
        Text('A', style: textStyle.copyWith(fontSize: 42)),
      ],
    );
  }
}
