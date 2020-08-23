part of imena;

class Debug {
  static void log(val, [as = "default", before = ""]){
    if (before != "") {
      print("\n$before");
    }
    switch (as) {
      case "map":
        print(new JsonEncoder.withIndent("  ").convert(val));
        break;
      default:
        print(val);
    }
  }
}
