import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/store.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveStoreScreen extends StatefulWidget {
  const ActiveStoreScreen({super.key});

  @override
  State<ActiveStoreScreen> createState() => _ActiveStoreScreenState();
}

class _ActiveStoreScreenState extends State<ActiveStoreScreen> {
  bool isLoading = false;
  List<Store> stores = [];
  String activeStore = "";

  Future<void> _fetchStores() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    List<Store> newStores = await StoreAPI.fetchActiveStore(context);
    Set<String> existingIds = stores.map((store) => store.id).toSet();

    List<Store> uniqueStores =
        newStores
            .where((company) => !existingIds.contains(company.id))
            .toList();

    if (uniqueStores.isNotEmpty) {
      stores.addAll(uniqueStores);
    }
    setState(() => isLoading = false);
  }

  Future<void> _changeActiveStore(Store store) async {
    await context.read<AuthCubit>().changeActiveStore(store);
  }

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    activeStore = context.read<AuthCubit>().state.storeId;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text(
              'Change Active Store',
              style: AppTextStyles.headingWhite,
            ),
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  ...stores.map(
                    (store) => Card(
                      elevation: 1,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              "${store.code} | ${store.name}",
                              style: AppTextStyles.headingBlue,
                            ),
                            Divider(),
                            TextCardDetail(
                              label: 'Usaha',
                              value:
                                  '${store.company?.code} | ${store.company?.name}',
                              type: "text",
                            ),
                            TextCardDetail(
                              label: 'Alamat',
                              value: store.address,
                              type: "text",
                              isLong: true,
                            ),
                            Divider(),

                            store.id == activeStore
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: double.infinity,
                                    color: AppColors.success,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Active",
                                      style: AppTextStyles.headingWhite,
                                    ),
                                  ),
                                )
                                : InkWell(
                                  onTap: () async {
                                    // Change active store_id
                                    await _changeActiveStore(store);
                                    GoRouter.of(context).go('/home');
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      color: AppColors.error,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Change to This",
                                        style: AppTextStyles.headingWhite,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
