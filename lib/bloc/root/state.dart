part of 'root.dart';

class State {
  final Page page;

  const State({this.page = Page.startup});

  State copyWith({final Page Function()? page}) => State(
        page: page == null ? this.page : page.call(),
      );
}

enum Page { startup, login, home }
