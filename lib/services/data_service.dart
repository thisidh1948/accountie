// lib/services/data_service.dart
import 'package:accountie/models/account_model.dart';
import 'package:accountie/models/category_model.dart';
import 'package:accountie/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accountie/models/record_model.dart';

class DataService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TRecord> _records = [];
  List<Category> _categories = [];
  List<Account> _accounts = [];
  List<LoanModel> _loans = [];
  List<String> _tags = [];
  Map<String, dynamic> _settings = {};

  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get settings => _settings;
  List<String> get tags => _tags;
  List<LoanModel> get loans => _loans;

  DataService() {
    fetchCategories();
    getLoans();
    getRecords();
  }

  get records => _records;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    await fetchCategories();
    getLoans();
    getRecords();
    notifyListeners();
  }

  Future<void> getRecords() async {
    _isLoading = true;
    try {
      final snapshot = await _firestore.collection('records').get();
      _records = snapshot.docs
          .map((doc) => TRecord.fromMap(doc.data(), doc.id))
          .toList();
      print('Fetched records successfully.');
    } catch (e) {
      print('Error fetching records: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(TRecord record, bool isUpdate) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isUpdate) {
        await _firestore
            .collection('records')
            .doc(record.recordId)
            .update(record.toMap());
        _records[_records.indexWhere((r) => r.recordId == record.recordId)] =
            record;
      } else {
        await _firestore.collection('records').add(record.toMap());
        _records.add(record);
      }
      print('Record ${isUpdate ? 'updated' : 'added'} successfully.');
    } catch (e) {
      print('Error ${isUpdate ? 'updating' : 'adding'} record: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      //Load Accounts
      final accountsSnapshot =
          await FirebaseFirestore.instance.collection('accounts').get();
      _accounts = accountsSnapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();

      //Load Categories
      final categoriesSnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      List<Category> fetchedCategories = [];

      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryData = categoryDoc.data();
        final categoryId = categoryDoc.id;

        final subcategoriesSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('subcategories')
            .get();

        List<SubCategory> fetchedSubcategories = [];
        for (var subcategoryDoc in subcategoriesSnapshot.docs) {
          final subcategoryData = subcategoryDoc.data();
          final subcategoryId = subcategoryDoc.id;

          final itemsSnapshot = await FirebaseFirestore.instance
              .collection('categories')
              .doc(categoryId)
              .collection('subcategories')
              .doc(subcategoryId)
              .collection('items')
              .get();

          List<Item> items = itemsSnapshot.docs
              .map((itemDoc) => Item.fromMap(itemDoc.data()))
              .toList();

          SubCategory subcategory = SubCategory.fromMap(subcategoryData);
          subcategory.items = items;
          fetchedSubcategories.add(subcategory);
        }
        Category category = Category.fromMap(categoryData);
        category.subcategories = fetchedSubcategories;
        fetchedCategories.add(category);
      }
      _categories = fetchedCategories;
      print('Fetched categories, subcategories, and items successfully.');
      _settings = await getSettings();
      String tagsString = _settings['tags'] ?? '';
      _tags = tagsString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching categories, subcategories, and items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleCategory(Category category, String categoryName,
      bool isUpdate, bool isDelete) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isDelete) {
        await _firestore.collection('categories').doc(categoryName).delete();
        _categories.removeWhere((c) => c.name == categoryName);
      } else {
        await _firestore
            .collection('categories')
            .doc(category.name)
            .set(category.toFirestore());
        if (isUpdate) {
          _categories[_categories.indexWhere((c) => c.name == categoryName)] =
              category;
        } else {
          _categories.add(category);
        }
      }
    } catch (e) {
      print('Error adding category: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSubCategory(SubCategory subCategory, String category,
      String subcategoryName, bool isUpdate, bool isDelete) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isDelete) {
        await _firestore
            .collection('categories')
            .doc(category)
            .collection('subcategories')
            .doc(subcategoryName)
            .delete();
        _categories
            .firstWhere((c) => c.name == category)
            .subcategories
            .removeWhere((sc) => sc.name == subcategoryName);
      } else {
        _firestore
            .collection('categories')
            .doc(category)
            .collection('subcategories')
            .doc(subcategoryName)
            .set(subCategory.toMap());
        if (isUpdate) {
          _categories[_categories.indexWhere((c) => c.name == category)]
                      .subcategories[
                  _categories[_categories.indexWhere((c) => c.name == category)]
                      .subcategories
                      .indexWhere((sc) => sc.name == subcategoryName)] =
              subCategory;
        } else {
          _categories[_categories.indexWhere((c) => c.name == category)]
              .subcategories
              .add(subCategory);
        }
      }
    } catch (e) {
      print('Error adding subcategory: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleItem(Item item, String category, String subcategory,
      String? itemName, bool isUpdate, bool isDelete) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isDelete) {
        await _firestore
            .collection('categories')
            .doc(category)
            .collection('subcategories')
            .doc(subcategory)
            .collection('items')
            .doc(itemName)
            .delete();
        _categories
            .firstWhere((c) => c.name == category)
            .subcategories
            .firstWhere((sc) => sc.name == subcategory)
            .items
            ?.removeWhere((i) => i.name == itemName);
      } else {
        await _firestore
            .collection('categories')
            .doc(category)
            .collection('subcategories')
            .doc(subcategory)
            .collection('items')
            .doc(itemName)
            .set(item.toMap());

        if (isUpdate) {
          _categories
              .firstWhere((x) => x.name == category)
              .subcategories
              .firstWhere((x) => x.name == subcategory)
              .items
              ?.add(item);
        } else {
          _categories
              .firstWhere((x) => x.name == category)
              .subcategories
              .firstWhere((x) => x.name == subcategory)
              .items
              ?.firstWhere((x) => x.name == itemName)
              .replaceWith(item);
        }
      }
    } catch (e) {
      print('Error adding item: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAccount(Account? account, String accountNumber,
      bool isUpdate, bool isDelete) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isDelete) {
        await _firestore.collection('accounts').doc(accountNumber).delete();
        _accounts.removeWhere((a) => a.accountNumber == accountNumber);
      } else {
        await _firestore
            .collection('accounts')
            .doc(accountNumber)
            .set(account!.toFirestore());
        if (isUpdate) {
          _accounts[_accounts
              .indexWhere((a) => a.accountholder == accountNumber)] = account;
        } else {
          _accounts.add(account);
          print('added');
        }
      }
    } catch (e) {
      print('Error adding account: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSettings(String key, dynamic value) async {
    try {
      await _firestore.collection('settings').doc(key).set({'value': value});
      print('Settings updated: $key = $value');
    } catch (e) {
      print('Error updating settings: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final doc = await _firestore.collection('settings').get();
      return doc.docs.fold<Map<String, dynamic>>({}, (acc, element) {
        acc[element.id] = element.data()['value'];
        return acc;
      });
    } catch (e) {
      print('Error fetching settings: $e');
      return new Map<String, dynamic>();
    }
  }

  Future<void> addTag(String tag) async {
    if (tag.isEmpty) return;
    _tags.add(tag);
    _settings['tags'] = _tags.join(',');
    await addSettings('tags', _settings['tags']);
    notifyListeners();
  }

  Future<void> removeTag(String tag) async {
    _tags.remove(tag);
    _settings['tags'] = _tags.join(',');
    await addSettings('tags', _settings['tags']);
    notifyListeners();
  }

  Future<void> getLoans() async {
    _isLoading = true;
    notifyListeners();
    try {
      //Want to fetch all loans and their installments as well from Firestore
      final snapshot = await _firestore.collection('loans').get();
      _loans = snapshot.docs
          .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
          .toList();
      print("Fetched loans successfully.-----");
      for (var loan in _loans) {
        if (loan.installments.isEmpty) {
          final installmentsSnapshot = await _firestore
              .collection('loans')
              .doc(loan.loanId)
              .collection('installments')
              .get();
          loan.installments = installmentsSnapshot.docs
              .map((doc) => Installment.fromMap(doc.data()))
              .toList();
        }
      }
      _loans.sort((a, b) => a.startDate.compareTo(b.startDate));
      print('Fetched loans successfully.');
    } catch (e) {
      print('Error fetching loans: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleLoan(LoanModel loan, bool isUpdate, {bool isDelete = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      print(loan.startDate.toString());

      if(isDelete){
        await _firestore.collection('loans').doc(loan.loanId).delete();
        _loans.removeWhere((l) => l.loanId == loan.loanId);
      }
      else if(isUpdate) {
        await _firestore
            .collection('loans')
            .doc(loan.loanId)
            .update(loan.toMap());
      } else {
        await _firestore.collection('loans').add(loan.toMap());
      }
      print('Loan ${isUpdate ? 'updated' : 'added'} successfully.');
      if (isUpdate) {
        _loans[_loans.indexWhere((l) => l.loanId == loan.loanId)] = loan;
      } else {
        _loans.add(loan);
      }
    } catch (e) {
      print('Error ${isUpdate ? 'updating' : 'adding'} loan: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
