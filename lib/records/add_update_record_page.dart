import 'package:accountie/models/structure.dart';
import 'package:accountie/records/selection_dialog.dart';
import 'package:accountie/records/multi_select_tag_dialog.dart';
import 'package:accountie/models/account_model.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/models/record_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/widgets/credit_debit_toggle.dart';
import 'package:accountie/widgets/location_service.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddRecordDialogPage extends StatefulWidget {
  final Record? initialRecord;

  const AddRecordDialogPage({super.key, this.initialRecord});
  @override
  State<AddRecordDialogPage> createState() => _AddRecordDialogPage();
}

class _AddRecordDialogPage extends State<AddRecordDialogPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  var _amountController = TextEditingController();

  Record? currentRecord; // To hold the initial record if editing
  List<String> selectedTags = [];
  Account? _selectedAccount; // To store the full selected Account object
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  List<Item> _subCatItems = [];
  String? _selectedAccountName;

  bool _isAmountCalculatedFromItems = false;
  bool _isSaving = false;
  bool _type = false;
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      currentRecord = widget.initialRecord;
      _descriptionController.text = currentRecord?.description ?? '';
      _amountController.text = currentRecord?.amount.toString() ?? '';
      selectedTags = List<String>.from(currentRecord?.tags ?? []);
      _type = currentRecord?.type ?? false;
      _resolveInitialData();
    } else {
      currentRecord = Record(
        recordId: uuid.v4(),
        transactionDate: DateTime.now(),
        items: [],
        tags: [],
        account: '',
        type: false,
        category: '',
        subCategory: '',
        amount: 0.0,
      );
      selectedTags = [];
      _addItem(); // Initialize with one empty item
      // For new record, try to auto-pick location
      _pickLocationAutomatically();
    }

    _amountController.addListener(() {
      if (_isAmountCalculatedFromItems)
        return; // Skip if amount is calculated from items
      setState(() {
        currentRecord?.amount = double.tryParse(_amountController.text) ?? 0.0;
      });
    });
    _updateAmountDisplay(); // Initial calculation if items exist
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedAccount == null ||
          _selectedCategory == null ||
          _selectedSubCategory == null ||
          currentRecord?.type == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an Missing Field.')),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        currentRecord?.recordId = widget.initialRecord?.recordId ?? uuid.v4();
        currentRecord?.amount = double.tryParse(_amountController.text) ?? 0.0;
        currentRecord?.description =
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null;

        if (widget.initialRecord == null) {
          await FirebaseFirestore.instance
              .collection('records')
              .doc(currentRecord!.recordId)
              .set(currentRecord!.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record added successfully!')),
          );
        } else {
          await FirebaseFirestore.instance
              .collection('records')
              .doc(currentRecord!.recordId)
              .update(currentRecord!.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record updated successfully!')),
          );
        }

        Navigator.of(context).pop();
      } catch (e) {
        debugPrint('Error saving record: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _resolveInitialData() async {
    if (widget.initialRecord == null) return;

    // Get DataService instance
    final dataService = Provider.of<DataService>(context, listen: false);

    // Resolve Account from cached data
    if (currentRecord?.account != null) {
      final account = dataService.accounts.firstWhere(
        (acc) => acc.accountholder == currentRecord?.account,
        orElse: () => null as Account, // Handle not found case
      );
      if (account != null) {
        setState(() {
          _selectedAccount = account;
        });
      } else {
        debugPrint('Initial account not found in cache: $_selectedAccountName');
      }
    }

    // Resolve Category and SubCategory from cached data
    if (currentRecord?.category != null) {
      final category = dataService.categories.firstWhere(
        (cat) => cat.name == currentRecord?.category,
        orElse: () => null as Category, // Handle not found case
      );
      if (category != null) {
        setState(() {
          _selectedCategory = category;
          if (currentRecord?.subCategory != null) {
            _selectedSubCategory = category.subcategories.firstWhere(
              (sub) => sub.name == currentRecord?.subCategory,
              orElse: () => null as SubCategory, // Handle not found case
            );
          }
        });
      } else {
        debugPrint(
            'Initial category not found in cache: ${currentRecord?.category}');
      }
    }
  }

  void _updateAmountDisplay() {
    if (currentRecord?.items?.isNotEmpty ?? false) {
      double sum = currentRecord?.items
              ?.fold(0.0, (prev, item) => prev! + item.totalAmount) ??
          0.0;
      setState(() {
        _amountController.text = sum.toStringAsFixed(2);
        _isAmountCalculatedFromItems = true;
      });
    } else {
      setState(() {
        _isAmountCalculatedFromItems = false;
      });
    }
  }

  void _addItem() {
    setState(() {
      final newItem =
          RecordItem(name: '', quantity: 1, unitPrice: 0.0, totalAmount: 0.0);
      currentRecord!.items!.add(newItem);
      // Initialize a new controller for the newly added item
      final newIndex = currentRecord!.items!.length - 1;
    });
    // Scroll to the new item if neede
  }

  void _removeItem(String name) {
    setState(() {
      // Remove from the map
      currentRecord?.items?.removeWhere((item) => item.name == name);
      _updateAmountDisplay();
    });
  }

  Color? _parseColorString(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    if (colorString.startsWith('0x')) {
      try {
        return Color(int.parse(colorString));
      } catch (e) {
        debugPrint('Error parsing color from hex: $e');
        return null;
      }
    }
    return null; // For now, only hex is assumed.
  }

Future<void> _pickLocationAutomatically() async {
  Position? position = await LocationService.getCurrentLocation();

  if (position != null) {
    String cityName = '';
    String areaName = '';
    int pincode = 0;

    debugPrint('Attempting reverse geocoding for: ${position.latitude}, ${position.longitude}');

    try {
      debugPrint('Calling placemarkFromCoordinates...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      debugPrint('placemarkFromCoordinates returned.'); // <-- If you see this, the call itself succeeded.

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        debugPrint('Accessed placemarks.first. Now checking its properties...');

        // Add comprehensive debug prints for ALL properties of Placemark
        debugPrint('--- Placemark Data for Diagnosis ---');
        debugPrint('  name: ${place.name}');
        debugPrint('  street: ${place.street}');
        debugPrint('  isoCountryCode: ${place.isoCountryCode}');
        debugPrint('  country: ${place.country}');
        debugPrint('  postalCode: ${place.postalCode}');
        debugPrint('  administrativeArea: ${place.administrativeArea}');
        debugPrint('  subAdministrativeArea: ${place.subAdministrativeArea}');
        debugPrint('  locality: ${place.locality}');
        debugPrint('  subLocality: ${place.subLocality}');
        debugPrint('  thoroughfare: ${place.thoroughfare}');
        debugPrint('  subThoroughfare: ${place.subThoroughfare}');
        debugPrint('--- End Placemark Data ---');

        cityName = place.locality ?? place.subAdministrativeArea ?? '';
        areaName = place.subLocality ?? place.locality ?? '';

        String fetchedPostalCode = place.postalCode ?? '';
        if (fetchedPostalCode.isNotEmpty) {
          pincode = int.tryParse(fetchedPostalCode) ?? 0;
        }

        debugPrint('CityName assigned: $cityName');
        debugPrint('AreaName assigned: $areaName');
        debugPrint('Pincode assigned: $pincode');

      } else {
        debugPrint('Geocoding returned an empty list of placemarks for ${position.latitude}, ${position.longitude}.');
      }
    } on PlatformException catch (e) {
      debugPrint('PLATFORM EXCEPTION during reverse geocoding: Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
    } catch (e) {
      debugPrint('GENERIC CATCH during reverse geocoding: $e'); // <-- This is the one we're looking for
    }

    setState(() {
      currentRecord?.location = LocationModel(
        cityName: cityName,
        areaName: areaName,
        pincode: pincode,
      );
    });

  } else {
    debugPrint('Failed to get current location. Position was null.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not get your current location. Please check permissions.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // Watch the DataService to react to changes in cached data
    DataService dataService = Provider.of<DataService>(context);
    List<Account> accounts = dataService.accounts;
    List<Category> categories = dataService.categories;

    List<String> _tags =
        dataService.tags; // To store selected account's display name

    if (dataService.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialRecord == null ? 'Add New Record' : 'Edit Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Selection
              ListTile(
                title: Text(currentRecord?.account ?? 'Select Account'),
                subtitle: _selectedAccount != null
                    ? Text(
                        '${_selectedAccount!.name ?? ''} - ${_selectedAccount!.accountNumber ?? ''}')
                    : null,
                leading: _selectedAccount?.icon != null &&
                        _selectedAccount!.icon!.isNotEmpty
                    ? SvgIconWidget(
                        iconFileName: _selectedAccount!.icon!,
                        width: 24,
                        height: 24)
                    : const Icon(Icons.account_balance),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final Account? pickedAccount = await showDialog<Account>(
                    context: context,
                    builder: (context) => SelectionDialog<Account>(
                      title: 'Select Account',
                      items: accounts, // Get accounts from DataService
                      itemBuilder: (account) =>
                          account.icon != null && account.icon!.isNotEmpty
                              ? SvgIconWidget(
                                  iconFileName: account.icon!,
                                  width: 24,
                                  height: 24)
                              : Icon(Icons.account_balance,
                                  color: account.color != null &&
                                          account.color!.isNotEmpty
                                      ? Color(int.parse(account.color!))
                                      : Colors.grey),
                      itemToString: (account) =>
                          '${account.name ?? 'N/A'} - ${account.accountNumber ?? 'N/A'} (${account.accountholder})',
                    ),
                  );
                  if (pickedAccount != null) {
                    setState(() {
                      _selectedAccount = pickedAccount;
                      _selectedAccountName = pickedAccount.accountholder;
                    });
                  }
                },
              ),
              const Divider(),
              // Category Selection
              ListTile(
                title: Text(currentRecord?.category ?? 'Select Category'),
                leading: _selectedCategory?.icon?.isNotEmpty == true
                    ? SvgIconWidget(
                        iconFileName: _selectedCategory!.icon ?? '',
                        width: 24,
                        height: 24)
                    : const Icon(Icons.category),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final Category? pickedCategory = await showDialog<Category>(
                    context: context,
                    builder: (context) => SelectionDialog<Category>(
                      title: 'Select Category',
                      items: categories, // Get categories from DataService
                      itemBuilder: (category) =>
                          category.icon != null && category.icon!.isNotEmpty
                              ? SvgIconWidget(
                                  iconFileName: category.icon!,
                                  width: 24,
                                  height: 24)
                              : Icon(Icons.category, color: Colors.grey),
                      itemToString: (category) =>
                          category.name ?? 'Unnamed Category',
                    ),
                  );
                  if (pickedCategory != null) {
                    setState(() {
                      _selectedCategory = pickedCategory;
                      currentRecord?.category = pickedCategory.name;
                      currentRecord?.subCategory = ''; // Reset subcategory
                      _selectedSubCategory = null; // Reset subcategory
                    });
                  }
                },
              ),
              const Divider(),
              // SubCategory Selection
              ListTile(
                title: Text(currentRecord?.subCategory ?? 'Select Subcategory'),
                enabled: _selectedCategory !=
                    null, // Enable only if category is selected
                leading: _selectedSubCategory?.icon!.isNotEmpty == true
                    ? SvgIconWidget(
                        iconFileName: _selectedSubCategory!.icon ?? '',
                        width: 24,
                        height: 24)
                    : const Icon(Icons.subdirectory_arrow_right),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectedCategory == null
                    ? null
                    : () async {
                        final SubCategory? pickedSubCategory =
                            await selectionMethod(context);
                        if (pickedSubCategory != null) {
                          setState(() {
                            _selectedSubCategory = pickedSubCategory;
                            currentRecord?.subCategory = pickedSubCategory.name;
                            _type = pickedSubCategory.type;
                            _subCatItems = pickedSubCategory.items ?? [];
                          });
                        }
                      },
              ),
              const Divider(),
              Row(
                // <--- Start of the new Row
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Align items vertically in the center
                children: [
                  Expanded(
                    // <--- Wrap TextFormField in Expanded
                    flex: 3, // Give more space to the amount field
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: _isAmountCalculatedFromItems
                            ? 'Total Amount (Calculated)'
                            : 'Amount',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: _isAmountCalculatedFromItems,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between the two widgets
                  Expanded(
                    // <--- Wrap CreditDebitSwitch in Expanded
                    flex: 2, // Give less space to the switch, adjust as needed
                    child: CreditDebitSwitch(
                      initialValue: _type,
                      onChanged: (val) {
                        setState(() {
                          print('Selected Type: $val');
                          currentRecord?.type = val;
                          _type = val; // Update the type state
                        });
                      },
                    ),
                  ),
                ],
              ),
              //Amount Input
              const SizedBox(height: 8),
              // Transaction Date
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                    text: currentRecord?.transactionDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        DateTime.now().toLocal().toString().split(' ')[0]),
                decoration: const InputDecoration(
                  labelText: 'Transaction Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        currentRecord?.transactionDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null &&
                      pickedDate != currentRecord?.transactionDate) {
                    setState(() {
                      currentRecord?.transactionDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              // Tags Selection (Multi-select)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.label),
                  const SizedBox(width: 8),
                  Expanded(
                    child: selectedTags.isNotEmpty
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: selectedTags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: Colors.blue.shade100,
                                      deleteIcon:
                                          const Icon(Icons.close, size: 18),
                                      onDeleted: () {
                                        setState(() {
                                          selectedTags.remove(tag);
                                          currentRecord?.tags =
                                              List<String>.from(selectedTags);
                                        });
                                      },
                                    ))
                                .toList(),
                          )
                        : const Text('No tags selected'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () async {
                      final List<String>? pickedTags =
                          await showDialog<List<String>>(
                        context: context,
                        builder: (context) => MultiSelectTagDialog(
                          tags: _tags,
                          initialSelected: selectedTags,
                        ),
                      );
                      if (pickedTags != null) {
                        setState(() {
                          selectedTags = List<String>.from(pickedTags);
                          currentRecord?.tags = List<String>.from(selectedTags);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Items List
              const Text('Items:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentRecord?.items?.length ?? 0,
                itemBuilder: (context, index) {
                  return _buildItemRow(index);
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
              const SizedBox(height: 16),

              // Location Display and Pick Button
              Text('Location:', style: const TextStyle(fontSize: 16)),
              ElevatedButton.icon(
                onPressed: _pickLocationAutomatically,
                icon: const Icon(Icons.location_on),
                label: const Text('Auto Pick Location'),
              ),
              const SizedBox(height: 24),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : Text(widget.initialRecord == null
                          ? 'Save Record'
                          : 'Update Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<SubCategory?> selectionMethod(BuildContext context) async {
    return await showDialog<SubCategory>(
      context: context,
      builder: (context) => SelectionDialog<SubCategory>(
        title: 'Select Subcategory',
        // Get subcategories from the selected category
        items: _selectedCategory?.subcategories ?? [],
        itemBuilder: (subcategory) =>
            subcategory.icon != null && subcategory.icon!.isNotEmpty
                ? SvgIconWidget(
                    iconFileName: subcategory.icon!, width: 24, height: 24)
                : Icon(Icons.category, color: Colors.grey),
        itemToString: (subcategory) =>
            subcategory.name ?? 'Unnamed Subcategory',
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final item = currentRecord?.items?[index];
    if (_subCatItems == null || _subCatItems.isEmpty || item == null) {
      return const SizedBox.shrink(); // No subcategories available
    }
    Item structItem = _subCatItems.firstWhere(
      (i) => i.name == item.name,
      orElse: () => Item(name: item.name, icon: item.name),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [ 
                ElevatedButton(
                  onPressed: () async {
                    final Structure? picketItem = await showDialog<Structure>(
                      context: context,
                      builder: (context) => SelectionDialog<Structure>(
                        title: 'Select Item',
                        items: _subCatItems, // Get categories from DataService
                        itemBuilder: (category) =>
                            category.icon != null && category.icon!.isNotEmpty
                                ? SvgIconWidget(
                                    iconFileName: category.icon!,
                                    width: 24,
                                    height: 24)
                                : Icon(Icons.category, color: Colors.grey),
                        itemToString: (item) => item.name ?? 'Unnamed Category',
                      ),
                    );
                    if (picketItem != null) {
                      setState(() {
                        currentRecord!.items![index].name = picketItem.name;
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIconWidget(
                          iconFileName: structItem.icon ?? item.name ?? 'NA'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // <-- Remove all default padding
                    minimumSize: Size
                        .zero, // <-- Allow the button to be as small as its child
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),             
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  key: Key(item.name ?? 'item_name_$index'),
                  initialValue: structItem.name,
                  decoration:
                      itemFormFieldDecor(context, labelText: 'Item Name'),
                  onChanged: (value) {
                    setState(() {
                      currentRecord!.items![index] =
                          currentRecord!.items![index].copyWith(name: value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item.brand,
                  decoration: itemFormFieldDecor(context,
                      labelText: 'Brand (Optional)'),
                  onChanged: (value) {
                    setState(() {
                      currentRecord!.items![index] =
                          currentRecord!.items![index].copyWith(brand: value);
                    });
                  },
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue:
                      currentRecord!.items![index].quantity.toString(),
                  decoration: itemFormFieldDecor(context, labelText: 'Qty'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      final qty = int.tryParse(value) ?? 1;
                      final unitPrice = currentRecord!.items![index].unitPrice;
                      final tax = currentRecord!.items![index].tax ?? 0.0;
                      final totalAmount = qty * unitPrice * (1 + tax / 100);
                      currentRecord!.items![index] = currentRecord!
                          .items![index]
                          .copyWith(quantity: qty, totalAmount: totalAmount);
                      _updateAmountDisplay();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue:
                      currentRecord!.items![index].unitPrice.toString(),
                  decoration:
                      itemFormFieldDecor(context, labelText: 'Unit Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      final unitPrice = double.tryParse(value) ?? 0.0;
                      final qty = currentRecord!.items![index].quantity;
                      final tax = currentRecord!.items![index].tax ?? 0.0;
                      final totalAmount = qty * unitPrice * (1 + tax / 100);
                      currentRecord!.items![index] =
                          currentRecord!.items![index].copyWith(
                              unitPrice: unitPrice, totalAmount: totalAmount);
                      _updateAmountDisplay();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<double>(
                  value: item.tax,
                  decoration: itemFormFieldDecor(context, labelText: 'Tax %'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 0.5, child: Text('0.5%')),
                    DropdownMenuItem(value: 1.0, child: Text('1%')),
                    DropdownMenuItem(value: 5.0, child: Text('5%')),
                    DropdownMenuItem(value: 15.0, child: Text('15%')),
                    DropdownMenuItem(value: 18.0, child: Text('18%')),
                    DropdownMenuItem(value: 20.0, child: Text('20%')),
                    DropdownMenuItem(value: 25.0, child: Text('25%')),
                    DropdownMenuItem(value: 30.0, child: Text('30%')),
                  ],
                  onChanged: (double? newValue) {
                    setState(() {
                      final tax = newValue ?? 0.0;
                      final qty = currentRecord!.items![index].quantity;
                      final unitPrice = currentRecord!.items![index].unitPrice;
                      final totalAmount = qty * unitPrice * (1 + tax / 100);
                      currentRecord!.items![index] = currentRecord!
                          .items![index]
                          .copyWith(tax: newValue, totalAmount: totalAmount);
                      _updateAmountDisplay();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  '₹${currentRecord!.items![index].totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

InputDecoration itemFormFieldDecor(
  BuildContext context, // <-- BuildContext still passed as a required parameter
  {
  String labelText = 'Item',
  String? hintText,
  IconData? prefixIcon,
  // You can add more customizable parameters here if needed
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2.0,
      ),
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    filled: true,
    fillColor:
        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
  );
}
