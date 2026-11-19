// Matches C:/myportofolio/main/models.py (Experience).
enum ExperienceCategory {
  career('career', 'Career'),
  organizations('organizations', 'Organizations'),
  community('community', 'Community'),
  competition('competition', 'Competition'),
  personalProject('personal-project', 'Personal Project'),
  certification('certification', 'Certification');

  const ExperienceCategory(this.value, this.label);

  final String value;
  final String label;
}

// A validated, local snapshot. No network or persistence at this stage.
class ExperienceDraft {
  const ExperienceDraft({
    required this.title,
    required this.description,
    required this.category,
    this.thumbnail,
    this.startedAt,
    this.endedAt,
  });

  final String title;
  final String description;
  final ExperienceCategory category;
  final String? thumbnail;
  final DateTime? startedAt;
  final DateTime? endedAt;

  bool get isOngoing => endedAt == null;
}
