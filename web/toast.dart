import 'dart:js' as js;

void toast(String message, [int duration = 2500]) {
  print(message);

  final options = js.JsObject(js.context['Object']);
  options['html'] = message;

  (js.context['M'] as js.JsObject).callMethod('toast', [options]);
}
