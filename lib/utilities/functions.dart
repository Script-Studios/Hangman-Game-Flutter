String replaceCharAt(int index, String old, String newChar) {
  if (index == 0) {
    return newChar + old.substring(1);
  } else if (index == old.length - 1) {
    return old.substring(0, index) + newChar;
  } else {
    return old.substring(0, index) + newChar + old.substring(index + 1);
  }
}
