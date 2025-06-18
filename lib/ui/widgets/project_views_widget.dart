import 'package:flutter/material.dart';

/// Widget que reacciona al stream de BlocNavigator y muestra la vista correspondiente.
import '../../blocs/bloc_loading.dart';
import '../../blocs/bloc_navigator.dart';
import '../../views/enum_views.dart';
import '../../views/splash_view.dart';
import 'loading_widget.dart';

class ProjectViewsWidget extends StatelessWidget {
  const ProjectViewsWidget({
    required this.blocNavigator,
    required this.blocLoading,
    super.key,
  });
  final BlocNavigator blocNavigator;
  final BlocLoading blocLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder<EnumViews>(
          stream: blocNavigator.viewStream,
          initialData: blocNavigator.currentView,
          builder: (BuildContext context, AsyncSnapshot<EnumViews> snapshot) {
            final EnumViews view = blocNavigator.currentView;
            switch (view) {
              case EnumViews.splash:
                return const SplashView();
            }
          },
        ),
        StreamBuilder<String>(
          stream: blocLoading.msgStream,
          initialData: blocLoading.msg,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            final String msg = snapshot.data ?? '';
            if (msg.isEmpty) {
              return const SizedBox.shrink();
            }
            return LoadingWidget(loadingMsg: msg);
          },
        ),
      ],
    );
  }
}
