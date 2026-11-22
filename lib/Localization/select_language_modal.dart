// import 'package:material_ui/material_ui.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:spark_admin/CommonModels/user_preferences.dart';
// import 'package:spark_admin/CommonWidgets/common_modal_container.dart';
// import 'package:spark_admin/Constants/app_sizes.dart';
// import 'package:spark_admin/Services/preferences_service.dart';
// import 'package:spark_admin/Utils/extensions.dart';

// class SelectLanguageModal extends ConsumerWidget {
//   const SelectLanguageModal({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return CommonModalContainer(
//       height: 200,
//       child: ListView.builder(
//         addAutomaticKeepAlives: false,
//         itemCount: LanguageCodeEnum.values.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () async {
//               ref.read(preferencesStateProvider.notifier).updatePreferences(
//                     languageCodeEnum: LanguageCodeEnum.values[index],
//                   );
//               context.pop();
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               decoration: const BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(width: 0.2),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   gapW8,
//                   Expanded(
//                     child: Text(
//                       LanguageCodeEnum.values[index].toString(),
//                       style: context.textStyles.titleSmall
//                           ?.copyWith(fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                   if (LanguageCodeEnum.values[index] ==
//                       ref.read(preferencesStateProvider).language)
//                     Icon(
//                       Icons.check,
//                       color: context.colors.secondary,
//                       size: 24,
//                     ),
//                   gapW16,
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
