import 'package:async_redux/async_redux.dart';
import 'package:eSamudaay/redux/states/app_state.dart';

Store<AppState> store = Store<AppState>(
  initialState: AppState.initial(),
//  actionObservers: [Log<AppState>.printer()],
//  modelObserver: DefaultModelObserver(),
);
