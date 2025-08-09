import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/record_model.dart';
import '../models/category_model.dart' as category_model;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User CRUD
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Transaction CRUD
  Future<void> addTransaction(TRecord tx) async {
    await _db.collection('records').doc(tx.recordId).set(tx.toMap());
  }

  Stream<List<TRecord>> getRecords(String userId) {
    return _db
        .collection('records')
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TRecord.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Category CRUD
  Future<void> addCategory(category_model.Category category) async {
    await _db.collection('categories').doc(category.name).set(category.toFirestore());
  }

  Stream<List<category_model.Category>> getCategories() {
    return _db.collection('categories').orderBy('index').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => category_model.Category.fromMap(doc.data())).toList());
  }

  Future<void> updateCategory(category_model.Category category) async {
    await _db.collection('categories').doc(category.name).set(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // SubCategory CRUD (as subcollection)
  Future<void> addSubCategory(String categoryId, category_model.SubCategory subCategory) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategory.name)
        .set(subCategory.toMap());
  }

  Stream<List<category_model.SubCategory>> getSubCategories(String categoryId) {
    return _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .orderBy('index')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => category_model.SubCategory.fromMap(doc.data())).toList());
  }

  Future<void> updateSubCategory(String categoryId, category_model.SubCategory subCategory) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategory.name)
        .set(subCategory.toMap());
  }

  Future<void> deleteSubCategory(String categoryId, String subCategoryId) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategoryId)
        .delete();
  }

  // Item CRUD (as subcollection)
  Future<void> addItem(String categoryId, String subCategoryId, category_model.Item item) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategoryId)
        .collection('items')
        .doc(item.name)
        .set(item.toMap());
  }

  Stream<List<category_model.Item>> getItems(String categoryId, String subCategoryId) {
    return _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategoryId)
        .collection('items')
        .orderBy('index')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => category_model.Item.fromMap(doc.data())).toList());
  }

  Future<void> updateItem(String categoryId, String subCategoryId, category_model.Item item) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategoryId)
        .collection('items')
        .doc(item.name)
        .set(item.toMap());
  }

  Future<void> deleteItem(String categoryId, String subCategoryId, String itemId) async {
    await _db
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subCategoryId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}
