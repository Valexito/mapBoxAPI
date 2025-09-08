import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controla si mostramos Login o SignUp en el AuthFlowPage
final showRegisterProvider = StateProvider<bool>((_) => false);
