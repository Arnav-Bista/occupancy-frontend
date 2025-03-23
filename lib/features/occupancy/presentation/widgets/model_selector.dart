import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:occupancy_frontend/features/occupancy/domain/entities/models.dart';

class ModelSelector extends ConsumerStatefulWidget {
  const ModelSelector({super.key});

  @override
  ConsumerState<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends ConsumerState<ModelSelector> {
  late Models currentModel;

  void changeModelSelection(Models? model) {
    if (model == null) return;
    setState(() {
      currentModel = model;
      ref.read(modelsProvider.notifier).state = model;
    });
  }

  void _showModelInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Model Selection Guide'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("KNN", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Weighted K-Nearest Neighbors Regression", style: TextStyle(fontSize: 12)),
                  Divider(),
                  Text("This model works really well if the last 2 weeks had no holidays. Weeks like ILW have a minor impact on the current predictions."),
                  SizedBox(height: 30),
                  Text("GB", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Gradient Boosting Regression", style: TextStyle(fontSize: 12)),
                  Divider(),
                  Text("Model trained on almost 2 years of data. Not as fine grained as KNN when the conditions are right, but you can count on it to give you a good estimate. This is unaffected by holidays."),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    currentModel = ref.read(modelsProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Model:",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        CustomDropdown(
          value: currentModel,
          onChanged: changeModelSelection,
          items: const [
            CustomDropdownItem(
              value: Models.both,
              child: PredictionModelEntry(name: "Both"),
            ),
            CustomDropdownItem(
              value: Models.knn,
              child: PredictionModelEntry(name: "KNN", color: Colors.blue),
            ),
            CustomDropdownItem(
              value: Models.gb,
              child: PredictionModelEntry(name: "GB", color: Colors.purple),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, size: 18),
          onPressed: _showModelInfoDialog,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      ],
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final Models value;
  final ValueChanged<Models?> onChanged;
  final List<CustomDropdownItem> items;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Models>(
          value: value,
          onChanged: onChanged,
          items: items,
          icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
          isDense: true,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class CustomDropdownItem extends DropdownMenuItem<Models> {
  const CustomDropdownItem({
    Key? key,
    required Models value,
    required Widget child,
  }) : super(key: key, value: value, child: child);
}

class PredictionModelEntry extends StatelessWidget {
  const PredictionModelEntry({
    super.key,
    required this.name,
    this.color,
  });

  final String name;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (color != null) ...[
          const SizedBox(width: 4),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}
