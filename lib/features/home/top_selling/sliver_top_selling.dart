import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wow_shopping/models/product_item.dart';
import 'package:wow_shopping/widgets/common.dart';
import 'package:wow_shopping/widgets/content_heading.dart';
import 'package:wow_shopping/widgets/product_card.dart';

import '../../../backend/product_repo.dart';

class SliverTopSelling extends ConsumerStatefulWidget {
  const SliverTopSelling({super.key});

  @override
  ConsumerState<SliverTopSelling> createState() => _SliverTopSellingState();
}

class _SliverTopSellingState extends ConsumerState<SliverTopSelling> {
  late Future<List<ProductItem>> _futureTopSelling;

  @override
  void initState() {
    super.initState();
    _futureTopSelling = ref.read(productsRepoProvider).fetchTopSelling();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductItem>>(
        future: _futureTopSelling,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return const SliverFillRemaining(
              child: Center(
                child: Text('Error!'),
              ),
            );
          } else if (snapshot.data!.isEmpty) {
            return emptySliver;
          } else {
            return TopSellingContent(
              products: snapshot.data!,
            );
          }
        });
  }
}

class TopSellingContent extends StatelessWidget {
  const TopSellingContent({super.key, required this.products});
  final List<ProductItem> products;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: horizontalPadding8,
          sliver: SliverToBoxAdapter(
            child: ContentHeading(
              title: 'Top Selling Items',
              buttonLabel: 'Show All',
              onButtonPressed: () {
                // FIXME: show all top selling items
              },
            ),
          ),
        ),
        sliverMainAxisVerticalMargin8,
        for (int index = 0; index < products.length; index += 2) ...[
          Builder(
            builder: (BuildContext context) {
              final item1 = products[index + 0];
              if (index + 1 < products.length) {
                final item2 = products[index + 1];
                return SliverCrossAxisGroup(
                  slivers: [
                    sliverCrossAxisHorizontalMargin12,
                    SliverCrossAxisExpanded(
                      flex: 2,
                      sliver: SliverProductCard(
                        key: Key('top-selling-${item1.id}'),
                        item: item1,
                      ),
                    ),
                    sliverCrossAxisHorizontalMargin12,
                    SliverCrossAxisExpanded(
                      flex: 2,
                      sliver: SliverProductCard(
                        key: Key('top-selling-${item2.id}'),
                        item: item2,
                      ),
                    ),
                    sliverCrossAxisHorizontalMargin12,
                  ],
                );
              } else {
                return SliverCrossAxisGroup(
                  slivers: [
                    sliverCrossAxisHorizontalMargin12,
                    SliverCrossAxisExpanded(
                      flex: 1,
                      sliver: SliverProductCard(
                        key: Key('top-selling-${item1.id}'),
                        item: item1,
                      ),
                    ),
                    sliverCrossAxisHorizontalMargin12,
                    const SliverCrossAxisExpanded(
                      flex: 1,
                      sliver: emptySliver,
                    ),
                    sliverCrossAxisHorizontalMargin12,
                  ],
                );
              }
            },
          ),
          sliverMainAxisVerticalMargin12,
        ],
        sliverMainAxisVerticalMargin48,
        sliverMainAxisVerticalMargin48,
      ],
    );
  }
}
