import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/services/dashboard_service.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/title_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int _donatorsCount = 0;
  int _recipientsCount = 0;
  int _newRequestsCount = 0;
  int _approvedDonationsCount = 0;
  int _rejectedDonationsCount = 0;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final donators = await DashboardService.getDonatorsCount();
      final recipients = await DashboardService.getRecipientsCount();
      final newRequests = await DashboardService.getNewRequestsCount();
      final approvedDonations =
          await DashboardService.getApprovedDonationsCount();
      final rejectedDonations =
          await DashboardService.getRejectedDonationsCount();

      // Only update state once with all values
      setState(() {
        _donatorsCount = donators;
        _recipientsCount = recipients;
        _newRequestsCount = newRequests;
        _approvedDonationsCount = approvedDonations;
        _rejectedDonationsCount = rejectedDonations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Consider adding error handling UI here
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingWidget()
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kRedColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildAnalyticsSection(),
            ],
          ),
        );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _buildStatCard('Donators', _donatorsCount, Colors.blue[400]!),
          _buildStatCard('Recipients', _recipientsCount, Colors.purple[400]!),
          _buildStatCard('New Requests', _newRequestsCount, Colors.amber[700]!),
          _buildStatCard(
            'Approved Donations',
            _approvedDonationsCount,
            Colors.green[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      children: [
        const Text(
          'Donation Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildDonationsPieChart()),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _buildDonationRateCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildDonationsPieChart() {
    final totalDonations = _approvedDonationsCount + _rejectedDonationsCount;

    // Handle edge case when there are no donations
    if (totalDonations == 0) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No donation data to display',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: _generatePieChartSections(totalDonations),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const ChartIndicator(
                          color: Colors.green,
                          text: 'Approved',
                          isSquare: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_approvedDonationsCount donations',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ChartIndicator(
                          color: Colors.redAccent,
                          text: 'Rejected',
                          isSquare: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_rejectedDonationsCount donations',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationRateCard() {
    final totalDonations = _approvedDonationsCount + _rejectedDonationsCount;
    final approvalRate =
        totalDonations > 0
            ? (_approvedDonationsCount / totalDonations * 100).toStringAsFixed(
              1,
            )
            : '0.0';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Success Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMetricItem(
              'Approval Rate',
              '$approvalRate%',
              Icons.thumb_up_outlined,
              Colors.green,
            ),
            const Divider(height: 28),
            _buildMetricItem(
              'Average Processing Time',
              '2.4 days',
              Icons.timelapse,
              Colors.blue,
            ),
            const Divider(height: 28),
            _buildMetricItem(
              'Donation Fulfillment',
              '94%',
              Icons.verified_outlined,
              Colors.purple,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieChartSections(int totalDonations) {
    return List.generate(2, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      switch (i) {
        case 0:
          final approvedPercentage = (_approvedDonationsCount /
                  totalDonations *
                  100)
              .toStringAsFixed(1);
          return PieChartSectionData(
            color: Colors.green,
            value: _approvedDonationsCount.toDouble(),
            title: '$approvedPercentage%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          );
        case 1:
          final rejectedPercentage = (_rejectedDonationsCount /
                  totalDonations *
                  100)
              .toStringAsFixed(1);
          return PieChartSectionData(
            color: Colors.redAccent,
            value: _rejectedDonationsCount.toDouble(),
            title: '$rejectedPercentage%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class ChartIndicator extends StatelessWidget {
  const ChartIndicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(4) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
