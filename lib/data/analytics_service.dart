import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AnalyticsService {
  AnalyticsService([this._mixpanel]);

  Mixpanel? _mixpanel;

  void setMixpanel(Mixpanel mixpanel) {
    _mixpanel = mixpanel;
  }

  void appEntry() {
    _mixpanel?.track('app_entry');
  }

  void sequenceEntryClick() {
    _mixpanel?.track('sequence_entry_click');
  }

  void sequenceSave(List<Jangdan> jangdans) {
    _mixpanel?.track(
      'sequence_save',
      properties: {
        for (final jangdan in jangdans) jangdan.jangdanType.label: true,
      },
    );
  }

  void metronomePlay({
    required double duration,
    required String soundType,
    required String jangdanType,
    required String jangdanName,
  }) {
    _mixpanel?.track(
      'metronome_play',
      properties: {
        'duration': duration,
        'sound_type': soundType,
        'jangdan_type': jangdanType,
        'jangdan_name': jangdanName,
      },
    );
  }
}

final analytics = AnalyticsService();
