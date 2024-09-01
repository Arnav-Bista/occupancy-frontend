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

  @override
  Widget build(BuildContext context) {
    currentModel = ref.read(modelsProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Prediction Model"),
        const SizedBox(width: 10),
        DropdownButton(
          onChanged: changeModelSelection,
          value: currentModel,
          borderRadius: BorderRadius.circular(10),
          items: const [
            DropdownMenuItem(
              value: Models.both,
              child: PredictionModelEntry(name: "Both"),
            ),
            DropdownMenuItem(
              value: Models.knn,
              child: PredictionModelEntry(name: "KNN", color: Colors.blue),
            ),
            DropdownMenuItem(
              value: Models.lstm,
              child: PredictionModelEntry(name: "LSTM", color: Colors.purple),
            ),
          ],
        )
      ],
    );
  }
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(name),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
