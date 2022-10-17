// Extension which filters list on notes and onlu returns note associated with given user id.

// Extending any stream which has a value of a list of "T"
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
