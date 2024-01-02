double moyenne(List<int> list) {
  int total = 0;
  for (var i = 0; i < list.length; i++) {
    total += list[i];
  }
  return total / list.length;
}
