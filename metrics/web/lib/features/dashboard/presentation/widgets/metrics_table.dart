import 'package:flutter/material.dart';
import 'package:metrics/features/common/presentation/strings/common_strings.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics_data.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:metrics/features/dashboard/presentation/strings/dashboard_strings.dart';
import 'package:metrics/features/dashboard/presentation/widgets/loading_placeholder.dart';
import 'package:metrics/features/dashboard/presentation/widgets/metrics_table_header.dart';
import 'package:metrics/features/dashboard/presentation/widgets/project_metrics_tile.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/// A widget that displays the [MetricsTableHeader] with the list of [ProjectMetricsTile].
class MetricsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const MetricsTableHeader(),
        Expanded(
          child: WhenRebuilder<ProjectMetricsStore>(
            models: [Injector.getAsReactive<ProjectMetricsStore>()],
            onError: _buildLoadingErrorPlaceholder,
            onWaiting: () => const LoadingPlaceholder(),
            onIdle: () => const LoadingPlaceholder(),
            onData: (store) {
              return StreamBuilder<List<ProjectMetricsData>>(
                stream: store.projectsMetrics,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LoadingPlaceholder();

                  final projects = snapshot.data;

                  if (projects.isEmpty) {
                    return const _DashboardTablePlaceholder(
                      text: DashboardStrings.noConfiguredProjects,
                    );
                  }

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return ProjectMetricsTile(projectMetrics: project);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the loading error placeholder.
  Widget _buildLoadingErrorPlaceholder(error) {
    return _DashboardTablePlaceholder(
      text: CommonStrings.getLoadingErrorMessage("$error"),
    );
  }
}

/// Widget that displays the placeholder [text] in the center of the screen.
class _DashboardTablePlaceholder extends StatelessWidget {
  final String text;

  /// Creates the dashboard placeholder widget with the given [text].
  const _DashboardTablePlaceholder({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.grey,
        ),
      ),
    );
  }
}