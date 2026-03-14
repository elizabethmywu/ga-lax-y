import 'package:flutter/material.dart';

class PlantShelf extends StatelessWidget {
  const PlantShelf({
    super.key,
  });

  // Helper widget to avoid code duplication and improve readability.
  Widget _buildPlantCard(BuildContext context) {
    final theme = Theme.of(context);
    // A list of different icons to represent the plants.
    final shelfIcons = [Icons.grass, Icons.spa, Icons.local_florist];

    return Card(
      // Using Card provides a nice elevation and shape from the theme.
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 100,
        width: double.infinity,
        color: theme.colorScheme.secondaryContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: shelfIcons.map((iconData) {
            return Icon(iconData,
                size: 40, color: theme.colorScheme.onSecondaryContainer);
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Using Expanded + ListView makes the list scrollable if it overflows.
          Expanded(
            child: ListView.builder(
              // This builds a list of 5 plant cards for demonstration.
              itemCount: 5,
              itemBuilder: (context, index) => _buildPlantCard(context),
            ),
          ),
        ],
      ),
    );
  }
}
