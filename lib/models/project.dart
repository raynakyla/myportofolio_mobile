import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/project_data.dart';

part 'project.g.dart';

/// The flat Django Project response and its writable POST fields.
@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.role,
    required this.skills,
    this.thumbnail = '',
    this.projectUrl = '',
    this.isFeatured = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;
  final ProjectCategory category;
  final String role;
  final String skills;

  // Django accepts blank URLs for POST, rather than null.
  @JsonKey(defaultValue: '')
  final String thumbnail;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  @JsonKey(defaultValue: false)
  final bool isFeatured;

  @JsonKey(defaultValue: 0, includeToJson: false)
  final int starCount;

  @JsonKey(defaultValue: false, includeToJson: false)
  final bool isStarred;

  @JsonKey(defaultValue: '', includeToJson: false)
  final String starredByNames;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Only serializer input fields are encoded, even for a fetched Project.
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
