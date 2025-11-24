import '../../utils/typedefs.dart';

/// Base repository interface with common CRUD operations
abstract class BaseRepository<T> {
  /// Creates a new item
  ResultFuture<T> create(T item);
  
  /// Retrieves an item by its ID
  ResultFuture<T> getById(String id);
  
  /// Retrieves all items
  ResultFuture<List<T>> getAll();
  
  /// Updates an existing item
  ResultFuture<void> update(T item);
  
  /// Deletes an item by its ID
  ResultFuture<void> delete(String id);
  
  /// Checks if an item exists
  ResultFuture<bool> exists(String id);
}
