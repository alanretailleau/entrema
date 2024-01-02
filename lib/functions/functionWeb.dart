import 'package:universal_html/html.dart';

void downloadImageWeb(url) {
  AnchorElement anchorElement = AnchorElement(href: url);
  anchorElement.download = "KOMI${DateTime.now()}";
  anchorElement.click();
}
