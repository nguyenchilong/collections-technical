
class Repository<T> {
	final List<T> _dataStore = [];

	void add(T item) {
		_dataStore.add(item);
	}

	List<T> getAll() {
		return _dataStore;
	}

	T? getByIndex(int index) {
		if (index < 0 || index >= _dataStore.length) {
			return null; // Return null if the index is out of bounds
		}
		return _dataStore[index];
	}
}

void main() {
	// Using Repository for Strings
	final stringRepo = Repository<String>();
	stringRepo.add("Hello");
	stringRepo.add("World");
	print(stringRepo.getAll()); // Output: [Hello, World]

	// Using Repository for Integers
	final intRepo = Repository<int>();
	intRepo.add(1);
	intRepo.add(2);
	print(intRepo.getAll()); // Output: [1, 2]

	// Accessing an item by index
	print(intRepo.getByIndex(0)); // Output: 1
	print(intRepo.getByIndex(2)); // Output: null (out of bound)
}
