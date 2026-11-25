// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Project',
  json,
  ($checkedConvert) {
    final val = Project(
      id: $checkedConvert('id', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String),
      category: $checkedConvert(
        'category',
        (v) => $enumDecode(_$ProjectCategoryEnumMap, v),
      ),
      role: $checkedConvert('role', (v) => v as String),
      skills: $checkedConvert('skills', (v) => v as String),
      thumbnail: $checkedConvert('thumbnail', (v) => v as String? ?? ''),
      projectUrl: $checkedConvert('project_url', (v) => v as String? ?? ''),
      isFeatured: $checkedConvert('is_featured', (v) => v as bool? ?? false),
      starCount: $checkedConvert(
        'star_count',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      isStarred: $checkedConvert('is_starred', (v) => v as bool? ?? false),
      starredByNames: $checkedConvert(
        'starred_by_names',
        (v) => v as String? ?? '',
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'projectUrl': 'project_url',
    'isFeatured': 'is_featured',
    'starCount': 'star_count',
    'isStarred': 'is_starred',
    'starredByNames': 'starred_by_names',
  },
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'category': _$ProjectCategoryEnumMap[instance.category]!,
  'role': instance.role,
  'skills': instance.skills,
  'thumbnail': instance.thumbnail,
  'project_url': instance.projectUrl,
  'is_featured': instance.isFeatured,
};

const _$ProjectCategoryEnumMap = {
  ProjectCategory.web: 'web',
  ProjectCategory.product: 'product',
  ProjectCategory.creative: 'creative',
};
