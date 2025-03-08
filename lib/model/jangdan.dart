import 'package:equatable/equatable.dart';
import 'accent.dart';

// struct JangdanEntity {
//     var name: String
//     var createdAt: Date?
//     var bakCount: Int
//     var daebak: Int
//     var bpm: Int
//     var daebakList: [[Daebak]]
//     var jangdanType: Jangdan  // 부모 장단 타입
//     var instrument: Instrument  // 악기 타입
    
//     struct Daebak {
//         var bakAccentList: [Accent]
//     }
// }

class Jangdan extends Equatable {
  final String name;
  final String jangdanType;
  final String createdAt;
  final int bpm;
  final List<List<List<Accent>>> accents;

  const Jangdan({
    required this.name, 
    required this.createdAt, 
    required this.bpm, 
    required this.jangdanType, 
    required this.accents
  });

  @override
  List<Object> get props => [name, bpm, jangdanType];
}
