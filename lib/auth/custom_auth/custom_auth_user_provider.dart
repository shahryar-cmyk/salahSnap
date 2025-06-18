import 'package:rxdart/rxdart.dart';

import 'custom_auth_manager.dart';

class SalahSnapVersionSecondAuthUser {
  SalahSnapVersionSecondAuthUser({required this.loggedIn, this.uid});

  bool loggedIn;
  String? uid;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<SalahSnapVersionSecondAuthUser>
    salahSnapVersionSecondAuthUserSubject =
    BehaviorSubject.seeded(SalahSnapVersionSecondAuthUser(loggedIn: false));
Stream<SalahSnapVersionSecondAuthUser> salahSnapVersionSecondAuthUserStream() =>
    salahSnapVersionSecondAuthUserSubject
        .asBroadcastStream()
        .map((user) => currentUser = user);
