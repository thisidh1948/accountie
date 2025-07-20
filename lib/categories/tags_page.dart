import 'package:accountie/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: true);
    List<String> tags = dataService.tags;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Tags'),
        ),
        body: dataService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tags.isEmpty
                ? const Center(child: Text('No tags available'))
                : ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(tags[index]),
                        onTap: () {
                          //Add new tag functionality
                          showDialog(
                            context: context,
                            builder: (context) => AddTagDialog(),
                          );
                        },
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddTagDialog(),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Tag',
        ));
  }
}

class AddTagDialog extends StatelessWidget {
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _tagController,
        decoration: const InputDecoration(hintText: 'Enter tag name'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String newTag = _tagController.text.trim();
            if (newTag.isNotEmpty) {
              Provider.of<DataService>(context, listen: false).addTag(newTag);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
