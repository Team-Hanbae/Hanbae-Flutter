import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/presentation/home/home_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/data/sound_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundManager.preloadAllSounds();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => MetronomeBloc())],
      child: Hanbae(),
    ),
  );
}

class Hanbae extends StatelessWidget {
  const Hanbae({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // ThemeData.dark()를 유지하면서
        scaffoldBackgroundColor:
            AppColors.backgroundDefault, // scaffold 배경색을 오버라이드
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundNavigationbar,
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Pretendard'),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: HomeScreen(),
    );
  }
}
