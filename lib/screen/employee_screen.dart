import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:operational_app/api/employee.dart';
import 'package:operational_app/model/employee.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/search_bar.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _scroll = ScrollController();
  final search = TextEditingController();
  List<Employee> employees = List.empty(growable: true);
  int page = 1;
  bool isLoading = false;
  bool isRefresh = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
  }

  Future<void> _fetchEmployees() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      List<Employee> newEmployees = await EmployeeAPI.fetchEmployees(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      debugPrint('Fetched ${newEmployees.length} employees');
      if (newEmployees.isEmpty) {
        setState(() => hasMore = false);
      } else {
        page++;
        Set<String> existingIds =
            employees.map((employee) => employee.id).toSet();

        List<Employee> uniqueEmployees =
            newEmployees
                .where((employee) => !existingIds.contains(employee.id))
                .toList();

        await Future.delayed(
          Duration(milliseconds: 400),
        ); // 🚀 Ensure UI updates

        if (uniqueEmployees.isNotEmpty) {
          employees.addAll(uniqueEmployees);
        }
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _refreshEmployees() async {
    if (isLoading) return;
    isRefresh = true;
    setState(() {
      isLoading = true;
      employees.clear();
      page = 1;
      hasMore = true;
    });

    _scroll.removeListener(_onScroll);

    try {
      List<Employee> latestEmployees = await EmployeeAPI.fetchEmployees(
        context,
        page: page,
        limit: 10,
        search: search.text,
      );

      if (latestEmployees.isNotEmpty) {
        page++;
        employees.addAll(latestEmployees);
      } else {
        hasMore = false;
      }

      await Future.delayed(Duration(milliseconds: 500)); // 🚀 Ensure UI updates
      _scroll.jumpTo(1);
    } catch (e) {
      debugPrint("Error fetching newest employees: $e");
    }

    _scroll.addListener(_onScroll);
    setState(() => isLoading = false);
    isRefresh = false;
  }

  Timer? _debounce;

  void _onScroll() {
    if (isLoading || isRefresh || (_debounce?.isActive ?? false)) {
      return;
    }
    _debounce = Timer(Duration(milliseconds: 300), () {
      if (isLoading) return; // Avoid duplicate API calls

      double offset = _scroll.position.pixels;
      double maxScroll = _scroll.position.maxScrollExtent;

      if (offset >= maxScroll - 100 && hasMore) {
        _fetchEmployees();
      }

      if (offset <= -40) {
        _refreshEmployees();
      }
    });
  }

  void _onSearchChanged() {
    _scroll.jumpTo(0);
    if (isLoading) return;

    _refreshEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: CupertinoScrollBehavior(),
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true, // Ensures the app bar remains visible when scrolling
            floating: false, // No snap effect
            elevation: 0,
            title: Text('Pegawai', style: AppTextStyles.headingWhite),
            leading: IconButton(
              icon: Icon(CupertinoIcons.arrow_left, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  SearchBarWidget(
                    controller: search,
                    onChanged: _onSearchChanged,
                  ),
                  // Employees
                  ...employees.map(
                    (employee) => Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                employee.name,
                                style: AppTextStyles.headingBlue,
                              ),
                              Divider(),
                              TextCardDetail(
                                label: 'Email',
                                value: employee.email,
                                type: "text",
                              ),
                              TextCardDetail(
                                label: 'Dibuat pada',
                                value: employee.createdAt,
                                type: "date",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // No Data Indicator
          if (employees.isEmpty && !isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 70,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Tidak ada pegawai ditemukan",
                        style: AppTextStyles.headingBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Loading Indicator
          if (isLoading)
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 52),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
