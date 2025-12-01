import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/presentation/home/home_screen.dart';
import 'package:hanbae/presentation/splash/splash.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/data/sound_manager.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/data/jangdan_repository.dart';
import 'package:flutter/services.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late Mixpanel mixpanel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WidgetsBinding.instance.deferFirstFrame();

  final fontLoader = FontLoader('Pretendard');
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Black.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Bold.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-ExtraBold.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-ExtraLight.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Light.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Medium.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Regular.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-SemiBold.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Pretendard-Thin.ttf'));
  await fontLoader.load();

  final gosanjaFontLoader = FontLoader('Gosanja');
  gosanjaFontLoader.addFont(rootBundle.load('assets/fonts/GosanjaOTF.otf'));
  await gosanjaFontLoader.load();

  // WidgetsBinding.instance.allowFirstFrame();

  try {
    await dotenv.load(fileName: ".env");

    final String mixpanelToken =
        kDebugMode
            ? dotenv.env['MIXPANEL_DEV_TOKEN']!
            : dotenv.env['MIXPANEL_PROD_TOKEN']!;

    mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: false);
  } catch (e) {
    print(e.toString());
  }

  await Hive.initFlutter();

  Hive.registerAdapter(JangdanAdapter());
  Hive.registerAdapter(AccentAdapter());
  Hive.registerAdapter(JangdanTypeAdapter());
  await Hive.openBox<Jangdan>('customJangdanBox');

  await SoundManager.preloadAllSounds();

  final jangdanRepository = JangdanRepository();
  final storage = Storage();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MetronomeBloc()),
        BlocProvider(
          create: (_) => JangdanBloc(jangdanRepository, storage)..add(LoadJangdan()),
        ),
      ],
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
          backgroundColor: AppColors.backgroundMute,
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
      home: SplashPage(),
    );
  }
}
