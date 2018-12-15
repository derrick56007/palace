import 'dart:js';

toast(String message, [int duration = 2500]) {
  print(message);
  context['Materialize'].callMethod('toast', [message, duration]);
}