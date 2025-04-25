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

  // Sample data for time series - in a real app, fetch this from your service
  final List<Map<String, dynamic>> _monthlySummary = [
    {'month': 'Jan', 'approved': 5, 'rejected': 2},
    {'month': 'Feb', 'approved': 7, 'rejected': 3},
    {'month': 'Mar', 'approved': 10, 'rejected': 4},
    {'month': 'Apr', 'approved': 8, 'rejected': 2},
    {'month': 'May', 'approved': 12, 'rejected': 3},
    {'month': 'Jun', 'approved': 15, 'rejected': 5},
  ];

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
        const SizedBox(height: 16),
        _buildMonthlyTrendsChart(),
        const SizedBox(height: 16),
        _buildRecentActivity(),
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

  Widget _buildMonthlyTrendsChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Donation Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 2.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barGroups: _generateBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value >= _monthlySummary.length || value < 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _monthlySummary[value.toInt()]['month'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300], strokeWidth: 1);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ChartIndicator(
                  color: Colors.green,
                  text: 'Approved',
                  isSquare: true,
                ),
                SizedBox(width: 24),
                ChartIndicator(
                  color: Colors.redAccent,
                  text: 'Rejected',
                  isSquare: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Sample recent activities - in a real app, fetch this from your service
    final List<Map<String, dynamic>> recentActivities = [
      {
        'title': 'New donation request',
        'donor': 'John Doe',
        'recipient': 'Local Hospital',
        'type': 'Blood Donation',
        'status': 'Pending',
        'time': '15 min ago',
      },
      {
        'title': 'Donation approved',
        'donor': 'Sarah Connor',
        'recipient': 'Maria Rodriguez',
        'type': 'Plasma Donation',
        'status': 'Approved',
        'time': '1 hour ago',
      },
      {
        'title': 'Donation completed',
        'donor': 'Mike Lewis',
        'recipient': 'Community Clinic',
        'type': 'Blood Donation',
        'status': 'Completed',
        'time': '2 hours ago',
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to activity page/screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _getActivityIcon(activity['status']),
                  title: Text(activity['title']),
                  subtitle: Text(
                    '${activity['donor']} → ${activity['recipient']} | ${activity['type']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _getStatusBadge(activity['status']),
                      const SizedBox(height: 4),
                      Text(
                        activity['time'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActivityIcon(String status) {
    switch (status) {
      case 'Pending':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.hourglass_top, color: Colors.amber[700], size: 20),
        );
      case 'Approved':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
        );
      case 'Completed':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.verified, color: Colors.blue[700], size: 20),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.circle, color: Colors.grey[700], size: 20),
        );
    }
  }

  Widget _getStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = Colors.amber;
        break;
      case 'Approved':
        color = Colors.green;
        break;
      case 'Completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(_monthlySummary.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _monthlySummary[index]['approved'].toDouble(),
            color: Colors.green,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: _monthlySummary[index]['rejected'].toDouble(),
            color: Colors.redAccent,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
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
