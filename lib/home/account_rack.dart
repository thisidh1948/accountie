import 'package:accountie/models/account_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/util/calculator.dart';
import 'package:accountie/util/number_formatter.dart';
import 'package:accountie/widgets/svg_icon_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountCardsCarousel extends StatelessWidget {
  const AccountCardsCarousel({
    super.key,
    this.onTap,
    this.cardWidth = 180,
    this.height = 100,
  });

  final void Function(dynamic account)? onTap;
  final double cardWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final records = context.watch<DataService>().records;
    final accounts = context.watch<DataService>().accounts;

    if (accounts.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No accounts yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final account = accounts[i];
          final balance = calculateAccountBalance(records, account.accountNumber as String);
          return SizedBox(
            width: cardWidth,
            child: _AccountCard(
              account: account,
              balance: balance,
            ),
          );
        },
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.balance});
  final Account account;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(account.color) ?? Colors.grey;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SvgIconWidget(iconFileName: account.icon ?? account.name, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(account.name,
                style: Theme.of(context).textTheme.titleMedium),
          ]),
          Text('Acc #: ${account.accountNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(NumberFormatter.formatIndianNumber(balance),
              style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  static Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      return Color(int.parse(colorStr));
    } catch (_) {
      return null;
    }
  }
}
