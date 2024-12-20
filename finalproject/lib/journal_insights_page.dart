// Importing Flutter Material package for building the app UI
import 'package:flutter/material.dart';
// Importing fl_chart package for charting and visualization features like pie and line charts
import 'package:fl_chart/fl_chart.dart';
// Importing the JournalEntry model class for handling journal entry data
import 'journal_entry_model.dart';

// The JournalInsightsPage is a StatelessWidget that displays insights and charts based on journal entries
class JournalInsightsPage extends StatelessWidget {
  final List<JournalEntry> entries;

  // Constructor to initialize the JournalInsightsPage with journal entries
  const JournalInsightsPage({Key? key, required this.entries}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate mood frequency from the journal entries
    Map<String, int> moodFrequency = _calculateMoodFrequency(entries);
    var totalEntries = entries.isNotEmpty ? entries.length : 1; // Ensure non-zero totalEntries

    // Calculate mood percentages based on the frequency of each mood
    Map<String, double> moodPercentages = _calculateMoodPercentages(moodFrequency, totalEntries);

    // Sort moods by their frequency in descending order
    var sortedMoods = moodFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepare data for charts
    List<BarChartGroupData> barChartData = _prepareBarChartData(sortedMoods);
    List<FlSpot> lineChartData = _prepareLineChartData(sortedMoods);

    // Get the peak mood (the mood with the highest frequency)
    String peakMood = sortedMoods.isNotEmpty ? sortedMoods.first.key : 'No data';
    int peakMoodCount = sortedMoods.isNotEmpty ? sortedMoods.first.value : 0;
    // Generate a personalized message based on the peak mood
    String personalizedMessage = _getPersonalizedMessage(peakMood);

    // Check if the app is in dark mode to apply appropriate colors
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AppBar with a custom title style
      appBar: AppBar(
        title: const Text(
          'Mood Trends',
          style: TextStyle(
            fontFamily: 'Teko',
            fontSize: 38,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for the mood trends section
              Text(
                'Mood Trends Over Time',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 1),
              Divider(color: isDarkMode ? Colors.white30 : Colors.black26), // Divider

              // Line chart showing mood frequency over time
              AspectRatio(
                aspectRatio: 1.9,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineChartData, // Data for the line chart
                        isCurved: true,
                        color: Colors.blue,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [Colors.blue.withOpacity(0.4), Colors.blue.withOpacity(0.1)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < sortedMoods.length) {
                              // Custom rotation for mood labels on the x-axis
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    sortedMoods[index].key,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true, border: Border.all(color: isDarkMode ? Colors.white : Colors.black12)),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mood Insights Section title
              Text(
                'Mood Insights (%)',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: isDarkMode ? Colors.white30 : Colors.black26), // Divider

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pie chart for mood percentage distribution
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: moodPercentages.entries.map((mood) {
                            return PieChartSectionData(
                              color: _getMoodColor(mood.key),
                              value: mood.value,
                              title: '${mood.value.toStringAsFixed(1)}%',
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Mood legend showing the mood distribution with labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: moodPercentages.entries.map((mood) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 8.0),
                                decoration: BoxDecoration(
                                  color: _getMoodColor(mood.key),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Text(
                                '${mood.key}: ${mood.value.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0.1),

              // Peak mood section with the most frequent mood displayed
              Text(
                'Peak Mood:',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '$peakMood',
                style: TextStyle(
                  fontSize: 19,
                  fontFamily: 'Lora',
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 5),

              // Personalized message based on the peak mood
              Text(
                personalizedMessage,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Frequency Distribution with a divider
              Text(
                'Mood Frequency Distribution:',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Divider(color: isDarkMode ? Colors.white30 : Colors.black26), // Divider

              // Bar chart displaying mood frequency distribution
              AspectRatio(
                aspectRatio: 1.7,
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            // Custom rotation for mood labels on the x-axis
                            if (index < sortedMoods.length) {
                              return Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  sortedMoods[index].key,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                    barGroups: barChartData, // Data for the bar chart
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate mood frequency from journal entries
  Map<String, int> _calculateMoodFrequency(List<JournalEntry> entries) {
    Map<String, int> moodFrequency = {};

    for (var entry in entries) {
      if (entry.mood != null) {
        moodFrequency[entry.mood!] = (moodFrequency[entry.mood!] ?? 0) + 1;
      }
    }

    return moodFrequency;
  }

  // Calculate the percentage of each mood based on the total number of entries
  Map<String, double> _calculateMoodPercentages(Map<String, int> moodFrequency, int totalEntries) {
    Map<String, double> moodPercentages = {};

    moodFrequency.forEach((mood, count) {
      moodPercentages[mood] = (count / totalEntries) * 100;
    });

    return moodPercentages;
  }

  // Prepare the data for the bar chart based on mood frequencies
  List<BarChartGroupData> _prepareBarChartData(List<MapEntry<String, int>> sortedMoods) {
    List<BarChartGroupData> data = [];
    for (int i = 0; i < sortedMoods.length; i++) {
      final mood = sortedMoods[i].key;
      final count = sortedMoods[i].value;

      data.add(BarChartGroupData(
        x: i, // Position on the x-axis (mood index)
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: _getMoodColor(mood),
            borderRadius: BorderRadius.circular(6), // Smooth rounded corners
          )
        ],
      ));
    }
    return data;
  }

  // Prepare the data for the line chart
  List<FlSpot> _prepareLineChartData(List<MapEntry<String, int>> sortedMoods) {
    List<FlSpot> data = [];
    for (int i = 0; i < sortedMoods.length; i++) {
      final count = sortedMoods[i].value;
      data.add(FlSpot(i.toDouble(), count.toDouble())); // Mood frequency as y-value
    }
    return data;
  }

  // Get mood color based on the mood
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy 😊':
        return const Color(0xFFBB9C01); // Soft yellow
      case 'sad 🌧️':
        return const Color(0xFF2F91BB); // Soft blue
      case 'motivated 🎯':
        return const Color(0xFF4DC04D); // Pale green
      case 'excited 🎉':
        return const Color(0xFFFF8B5B); // Light coral
      case 'relaxed 🧘':
        return const Color(0xFFBA55D3); // Orchid
      case 'grateful 🙏':
        return const Color(0xFF21B2A3); // Turquoise
      case 'stressed 😓':
        return const Color(0xFFFF3564); // Hot pink
      default:
        return const Color(0xFFC0C0C0); // Light gray
    }
  }



  // Personalized message based on the peak mood
  String _getPersonalizedMessage(String peakMood) {
    switch (peakMood.toLowerCase()) {
      case 'happy 😊':
        return 'Keep spreading that joy! Your positivity is contagious!';
      case 'motivated 🎯':
        return 'You’ve had a positive and upbeat mood recently. Keep that energy flowing!';
      case 'excited 🎉':
        return 'Your excitement is fueling your progress! Keep it up!';
      case 'sad 🌧️':
        return 'It seems you’ve been feeling a bit down lately. Remember, better days are ahead!';
      case 'relaxed 🧘':
        return 'Enjoy the peace and calm you’ve found. Take this time to recharge!';
      case 'grateful 🙏':
        return 'Gratitude is a powerful force. Keep appreciating the little things!';
      default:
        return 'You’ve had a mix of moods recently. Keep going strong!';
    }
  }
}