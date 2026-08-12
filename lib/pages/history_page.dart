// import 'package:flutter/material.dart';
// import 'package:randomlottonumber/style.dart';
// import 'package:randomlottonumber/num_history_lists.dart';

// class AboutWinningNumPage extends StatelessWidget {
//   const AboutWinningNumPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: mainColor,
//           iconTheme: IconThemeData(
//             color: whiteColor
//           ),
//           title: Text(
//             '당첨번호',
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: whiteColor,
//             ),
//           ),
//           bottom: TabBar(
//             tabs: <Widget> [
//               Tab(
//                 child: Text(
//                   '역대 당첨번호',
//                   style: TextStyle(
//                     color: whiteColor,
//                   ),
//                 ),
//               ),
//               Tab(
//                 child: Text(
//                   '당첨번호 출현 순위',
//                   style: TextStyle(
//                     color: whiteColor,
//                   ),
//                 ),
//               ),
//             ],
//             indicatorColor: whiteColor,
//           ),
//         ),
//         body: const TabBarView(
//           children: <Widget> [
//             WinningNumScreen(),
//             DuplicateNumsScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ------------------------------------- 역대 당첨번호 -------------------------------------
// class WinningNumScreen extends StatefulWidget {
//   const WinningNumScreen({super.key});

//   @override
//   State<WinningNumScreen> createState() => _WinningNumScreenState();
// }

// class _WinningNumScreenState extends State<WinningNumScreen> {
//   var historyListsLength = historyNumberLists.length;
//   var reverseHistory = historyNumberLists.reversed.toList();
//   var reverseBonus = bonusNumbers.reversed.toList();

//   int listCount = 20;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(
//             maxWidth: 500,
//           ),
//           child: ListView.builder(
//             itemCount: historyListsLength,
//             itemBuilder: (context, index) {
//               return Container(
//                 height: 56,
//                 // margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       width: 1,
//                       color: greyColor,
//                     )
//                   )
//                 ),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Container(
//                         padding: const EdgeInsets.only(right: 8),
//                         width: 64,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               width: 2,
//                               color: greyColor,
//                             )
//                           )
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '${historyListsLength - index}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: blackColor,
//                               ),
//                             ),
//                             Text(
//                               '회',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: blackColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][0]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][0] < 11 ? num0Color : reverseHistory[index][0] < 21 ? num10Color : reverseHistory[index][0] < 31 ? num20Color  : reverseHistory[index][0] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][1]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][1] < 11 ? num0Color : reverseHistory[index][1] < 21 ? num10Color : reverseHistory[index][1] < 31 ? num20Color  : reverseHistory[index][1] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][2]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][2] < 11 ? num0Color : reverseHistory[index][2] < 21 ? num10Color : reverseHistory[index][2] < 31 ? num20Color  : reverseHistory[index][2] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][3]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][3] < 11 ? num0Color : reverseHistory[index][3] < 21 ? num10Color : reverseHistory[index][3] < 31 ? num20Color  : reverseHistory[index][3] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][4]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][4] < 11 ? num0Color : reverseHistory[index][4] < 21 ? num10Color : reverseHistory[index][4] < 31 ? num20Color  : reverseHistory[index][4] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseHistory[index][5]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseHistory[index][5] < 11 ? num0Color : reverseHistory[index][5] < 21 ? num10Color : reverseHistory[index][5] < 31 ? num20Color  : reverseHistory[index][5] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '+',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: blackColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${reverseBonus[index]}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: reverseBonus[index] < 11 ? num0Color : reverseBonus[index] < 21 ? num10Color : reverseBonus[index] < 31 ? num20Color  : reverseBonus[index] < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ------------------------------------- 당첨번호 순위 -------------------------------------
// class DuplicateNumsScreen extends StatelessWidget {
//   const DuplicateNumsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Map<int, int> countMap = {};

//     for (int value in allHistoryNumbers) {
//       countMap[value] = (countMap[value] ?? 0) + 1;
//     }

//     List<MapEntry<int, int>> sortedEntries = countMap.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
      
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(
//             maxWidth: 500,
//           ),
//           child: ListView.builder(
//             itemCount: 45,
//             itemBuilder: (context, index){
//               return Container(
//                 height: 56,
//                 // margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       width: 1,
//                       color: greyColor,
//                     )
//                   )
//                 ),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Container(
//                         padding: const EdgeInsets.only(right: 8),
//                         width: 48,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               width: 2,
//                               color: greyColor,
//                             )
//                           )
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '${index + 1}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: blackColor,
//                               ),
//                             ),
//                             Text(
//                               '위',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: blackColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${sortedEntries[index].key}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             // color: blackColor,
//                             color: sortedEntries[index].key < 11 ? num0Color : sortedEntries[index].key < 21 ? num10Color : sortedEntries[index].key < 31 ? num20Color  : sortedEntries[index].key < 41 ? num30Color : num40Color,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Center(
//                         child: Text(
//                           '${sortedEntries[index].value} 회',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: blackColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// void test() {
//   Map<int, int> countMap = {};
//   for (int value in allHistoryNumbers) {
//     countMap[value] = (countMap[value] ?? 0) + 1;
//   }
//   List<MapEntry<int, int>> sortedEntries = countMap.entries.toList()
//     ..sort((a, b) => b.value.compareTo(a.value));
//   int count = 0;
//   for (MapEntry<int, int> entry in sortedEntries) {
//     if (count < 10) {
//       print('${entry.key}: ${entry.value}번');
//       count++;
//     } else {
//       break;
//     }
//   }
// }