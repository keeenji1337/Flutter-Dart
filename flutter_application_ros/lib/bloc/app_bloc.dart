import 'package:flutter_bloc/flutter_bloc.dart';                           // flutter_bloc: базовые классы Bloc, on, emit
import 'app_event.dart';                                                   // Импорт событий (AppEvent)
import 'app_state.dart';                                                   // Импорт состояний (AppState)

class AppBloc extends Bloc<AppEvent, AppState> {                           // AppBloc: принимает AppEvent, выдаёт AppState
  AppBloc() : super(AppState.initial()) {                                  // Конструктор: super с начальным состоянием
    on<AddToCartEvent>((event, emit) {                                     // Обработчик события AddToCartEvent
      final updatedCart = List<String>.from(state.cartItems);              //    Копируем текущий список в новый
      updatedCart.add(event.item);                                         //    Добавляем товар из события
      emit(state.copyWith(cartItems: updatedCart));                        //    emit: отправляем новое состояние в UI
    });

    on<RemoveFromCartEvent>((event, emit) {                                // Обработчик события RemoveFromCartEvent
      final updatedCart = List<String>.from(state.cartItems);              //    Копируем текущий список в новый
      updatedCart.remove(event.item);                                      //    Удаляем первое вхождение товара
      emit(state.copyWith(cartItems: updatedCart));                        //    emit: отправляем новое состояние в UI
    });
  }
}