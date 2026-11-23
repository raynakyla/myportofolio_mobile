// Matches the required editable fields in C:/myportofolio/main/models.py (Project).
enum ProjectCategory {
  web('web', 'Web Development'),
  product('product', 'Product & UX'),
  creative('creative', 'Creative Work');

  const ProjectCategory(this.value, this.label);

  final String value;
  final String label;
}

// A validated local preview, without network requests or persistence.
class ProjectDraft {
  const ProjectDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.role,
    required this.skills,
  });

  final String title;
  final String description;
  final ProjectCategory category;
  final String role;
  final String skills;
}
