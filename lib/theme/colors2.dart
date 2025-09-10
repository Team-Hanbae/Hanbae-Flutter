import 'package:flutter/material.dart';

class Primitives {
  static const Color common100 = Color(0xFFFFFFFF);
  static const Color common0   = Color(0xFF000000);

  static const Color neutral1  = Color(0xFFF7F7F7);
  static const Color neutral2  = Color(0xFFE5E5E5);
  static const Color neutral3  = Color(0xFFCCCCCC);
  static const Color neutral4  = Color(0xFFB2B2B2);
  static const Color neutral5  = Color(0xFF9C9C9C);
  static const Color neutral6  = Color(0xFF8A8A8A);
  static const Color neutral7  = Color(0xFF757575);
  static const Color neutral8  = Color(0xFF616161);
  static const Color neutral9  = Color(0xFF4A4A4A);
  static const Color neutral10 = Color(0xFF383838);
  static const Color neutral11 = Color(0xFF2E2E2E);
  static const Color neutral12 = Color(0xFF242424);
  static const Color neutral13 = Color(0xFF121212);

  static const Color orange1  = Color(0xFFFFFBF7);
  static const Color orange2  = Color(0xFFFFF3E5);
  static const Color orange3  = Color(0xFFFFE5CA);
  static const Color orange4  = Color(0xFFFFD1A0);
  static const Color orange5  = Color(0xFFFFBD75);
  static const Color orange6  = Color(0xFFFF9C31);
  static const Color orange7  = Color(0xFFFF8500);
  static const Color orange8  = Color(0xFFE07400);
  static const Color orange9  = Color(0xFFA55F12);
  static const Color orange10 = Color(0xFF8A4800);
  static const Color orange11 = Color(0xFF663500);
  static const Color orange12 = Color(0xFF472500);
  static const Color orange13 = Color(0xFF331A00);

  static const Color redOrange1  = Color(0xFFFFFAF7);
  static const Color redOrange2  = Color(0xFFFFEFE5);
  static const Color redOrange3  = Color(0xFFFFDDCA);
  static const Color redOrange4  = Color(0xFFFFC3A0);
  static const Color redOrange5  = Color(0xFFFFA875);
  static const Color redOrange6  = Color(0xFFFF823B);
  static const Color redOrange7  = Color(0xFFFF5C00);
  static const Color redOrange8  = Color(0xFFD44E00);
  static const Color redOrange9  = Color(0xFF9C4411);
  static const Color redOrange10 = Color(0xFF853100);
  static const Color redOrange11 = Color(0xFF6B2700);
  static const Color redOrange12 = Color(0xFF521E00);
  static const Color redOrange13 = Color(0xFF331300);  
}

class AppColors {
  // Brand
  static const Color brandNormal  = Primitives.orange6;
  static const Color brandStrong  = Primitives.orange7;
  static const Color brandHeavy   = Primitives.orange8;

  // Theme
  static const Color themeNormal  = Primitives.orange6;
  static const Color themeStrong  = Primitives.orange7;
  static const Color themeHeavy   = Primitives.orange8;

  // Label
  static const Color labelDefault    = Primitives.neutral1;
  static const Color labelPrimary    = Primitives.common100;
  static const Color labelSecondary  = Primitives.neutral3;
  static const Color labelTertiary   = Primitives.neutral6;
  static final Color labelAssistive  = Primitives.neutral5.withValues(alpha: 133); // 52% 투명도
  static final Color labelDisable    = Primitives.neutral4.withValues(alpha: 71); // 28% 투명도
  static const Color labelInverse    = Primitives.common0;

  // Button
  static const Color buttonDefault   = Primitives.neutral8;
  static const Color buttonElevated  = Primitives.neutral7;
  static const Color buttonSubtle    = Primitives.neutral9;
  static const Color buttonMute      = Primitives.neutral10;
  static const Color buttonInverse   = Primitives.common100;

  // Backgound
  static const Color backgroundDefault   = Primitives.neutral13;
  static const Color backgroundMute      = Primitives.neutral12;
  static const Color backgroundSubtle    = Primitives.neutral11;
  static const Color backgroundElevated  = Primitives.neutral10;
  static const Color backgroundDark      = Primitives.common0;

  // Metronome
  static const Color bakBarTop                = Primitives.redOrange6;
  static const Color bakBarBottom             = Primitives.orange6;
  static const LinearGradient bakBarGradient  = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      bakBarTop,
      bakBarBottom
    ],
  );
  static const Color bakBarInactive           = Primitives.neutral9;
  static const Color bakBarLine               = Primitives.common0;
  static const Color bakBarBorder             = Primitives.neutral8;
  static const Color frame                    = Primitives.neutral12;
  static const Color bakBarNumberDefault      = Primitives.common100;
  static const Color bakBarNumberAlternative  = Primitives.neutral12;
  static const Color bakBarNumberInactive     = Primitives.neutral9;
  static const Color ornament                 = Primitives.common100;
  static const Color sobakSegmentDaebak       = Primitives.orange6;
  static const Color sobakSegmentSobak        = Primitives.orange4;
  static const Color blink                    = Primitives.orange6;

  //Dimmer
  static final Color dimmerDefault = Primitives.common0.withValues(alpha: 110); // 43% 투명도
  static final Color dimmerStrong  = Primitives.common0.withValues(alpha: 188); // 74% 투명도
  static final Color dimmerHeavy   = Primitives.common0.withValues(alpha: 224); // 88% 투명도

  //Color Palette
  static const Color neutral1  = Primitives.neutral1;
  static const Color neutral2  = Primitives.neutral2;
  static const Color neutral3  = Primitives.neutral3;
  static const Color neutral4  = Primitives.neutral4;
  static const Color neutral5  = Primitives.neutral5;
  static const Color neutral6  = Primitives.neutral6;
  static const Color neutral7  = Primitives.neutral7;
  static const Color neutral8  = Primitives.neutral8;
  static const Color neutral9  = Primitives.neutral9;
  static const Color neutral10 = Primitives.neutral10;
  static const Color neutral11 = Primitives.neutral11;
  static const Color neutral12 = Primitives.neutral12;
  static const Color neutral13 = Primitives.neutral13;

  static const Color orange1  = Primitives.orange1;
  static const Color orange2  = Primitives.orange2;
  static const Color orange3  = Primitives.orange3;
  static const Color orange4  = Primitives.orange4;
  static const Color orange5  = Primitives.orange5;
  static const Color orange6  = Primitives.orange6;
  static const Color orange7  = Primitives.orange7;
  static const Color orange8  = Primitives.orange8;
  static const Color orange9  = Primitives.orange9;
  static const Color orange10 = Primitives.orange10;
  static const Color orange11 = Primitives.orange11;
  static const Color orange12 = Primitives.orange12;
  static const Color orange13 = Primitives.orange13;

  static const Color redOrange1  = Primitives.redOrange1;
  static const Color redOrange2  = Primitives.redOrange2;
  static const Color redOrange3  = Primitives.redOrange3;
  static const Color redOrange4  = Primitives.redOrange4;
  static const Color redOrange5  = Primitives.redOrange5;
  static const Color redOrange6  = Primitives.redOrange6;
  static const Color redOrange7  = Primitives.redOrange7;
  static const Color redOrange8  = Primitives.redOrange8;
  static const Color redOrange9  = Primitives.redOrange9;
  static const Color redOrange10 = Primitives.redOrange10;
  static const Color redOrange11 = Primitives.redOrange11;
  static const Color redOrange12 = Primitives.redOrange12;
  static const Color redOrange13 = Primitives.redOrange13;  
}