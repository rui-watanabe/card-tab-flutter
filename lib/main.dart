import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PointBloc(),
          ),
          BlocProvider(
            create: (context) => TabBloc(),
          ),
        ],
        child: MyHomePage(),
      ),
    );
  }
}

// 作成したコンポーネントの呼び出し
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //　AppBarの表示
        appBar: AppBar(
          title: Text('Credit Card Points'),
        ),
        body: Column(
          children: [
            // カードエリア
            Expanded(
              flex: 3,
              // blockBuilderでポイントと
              child: BlocBuilder<PointBloc, PointState>(
                builder: (context, pointState) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GestureDetector(
                      onTap: () {
                        context.read<PointBloc>().add(PointCardTappedEvent());
                      },
                      child: FlipCard(
                        front: _buildPointsCard(pointState, isBack: false),
                        back: _buildPointsCard(pointState, isBack: true),
                      ),
                    ),
                  );
                },
              ),
            ),
            // タブバーエリア
            Expanded(
              flex: 7,
              child: TabBarWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(PointState pointState, {required bool isBack}) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(isBack ? pi : 0),
                child: Text(
                  pointState.isExpired ? 'Expired Points' : 'Available Points',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )),
            SizedBox(height: 8.0),
            // 文字が反転しないようにTransformを使用
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(isBack ? pi : 0),
              child: Text(
                isBack
                    ? '${pointState.expiredPoints} Expired Points'
                    : '${pointState.points} Points',
                style: TextStyle(
                    fontSize: 24.0,
                    color: pointState.isExpired ? Colors.red : null),
              ),
            ),
            if (isBack)
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(isBack ? pi : 0),
                child: Text(
                  'Additional Information on the Back',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class TabBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, int>(
      builder: (context, tabIndex) {
        return Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'tab1',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'tab2',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CampaignsList(),
                  ApplicationsList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CampaignsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(title: Text('Campaign 1')),
        ListTile(title: Text('Campaign 2')),
      ],
    );
  }
}

class ApplicationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(title: Text('Application 1')),
        ListTile(title: Text('Application 2')),
      ],
    );
  }
}

class PointBloc extends Bloc<PointEvent, PointState> {
  PointBloc()
      : super(PointState(points: 100, expiredPoints: 20, isExpired: false));

  @override
  Stream<PointState> mapEventToState(PointEvent event) async* {
    if (event is PointCardTappedEvent) {
      final random = Random();
      final newPoints = random.nextInt(101);

      yield state.copyWith(
        isExpired: !state.isExpired,
        points: newPoints,
      );
    }
  }
}

class PointState {
  final int points;
  final int expiredPoints;
  final bool isExpired;

  PointState(
      {required this.points,
      required this.expiredPoints,
      required this.isExpired});

  PointState copyWith({int? points, int? expiredPoints, bool? isExpired}) {
    return PointState(
      points: points ?? this.points,
      expiredPoints: expiredPoints ?? this.expiredPoints,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}

class PointEvent {}

class PointCardTappedEvent extends PointEvent {}

class TabBloc extends Bloc<int, int> {
  TabBloc() : super(0);

  @override
  Stream<int> mapEventToState(int event) async* {
    yield event;
  }
}

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  FlipCard({required this.front, required this.back});

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isCompleted) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            // Y軸を中心に回転
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 遠近感を与えるために追加
              ..rotateY(pi * _controller.value),
            alignment: Alignment.center,
            child: _controller.value < 0.5 ? widget.front : widget.back,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
