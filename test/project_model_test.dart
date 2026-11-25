import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/project_data.dart';

void main() {
  const writableFields = {
    'title': 'Portfolio kampus',
    'description': 'Karya dan pengalaman',
    'category': 'web',
    'role': 'Developer',
    'skills': 'Django, Flutter',
    'thumbnail': 'https://example.com/preview.png',
    'project_url': 'https://example.com/project/',
    'is_featured': true,
  };
  const serverFields = {
    'id': 'aaad6faa-09d7-456b-a0ce-117788d2c44b',
    'star_count': 3,
    'is_starred': true,
    'starred_by_names': 'reader, editor, owner',
  };
  const response = {...writableFields, ...serverFields};
  const requiredFields = {
    'title': 'Portfolio kampus',
    'description': 'Karya dan pengalaman',
    'category': 'web',
    'role': 'Developer',
    'skills': 'Django, Flutter',
  };

  test('reads every field from the flat Django Project response', () {
    final project = Project.fromJson(response);

    expect(project.id, serverFields['id']);
    expect(project.title, writableFields['title']);
    expect(project.description, writableFields['description']);
    expect(project.category, ProjectCategory.web);
    expect(project.role, writableFields['role']);
    expect(project.skills, writableFields['skills']);
    expect(project.thumbnail, writableFields['thumbnail']);
    expect(project.projectUrl, writableFields['project_url']);
    expect(project.isFeatured, isTrue);
    expect(project.starCount, 3);
    expect(project.isStarred, isTrue);
    expect(project.starredByNames, serverFields['starred_by_names']);
  });

  test('encoding a fetched Project sends exactly the writable POST fields', () {
    final project = Project.fromJson(response);
    final body = jsonDecode(jsonEncode(project)) as Map<String, dynamic>;

    expect(body, writableFields);
    for (final field in serverFields.keys) {
      expect(
        body.containsKey(field),
        isFalse,
        reason: '$field is server-owned',
      );
    }
  });

  test(
    'new Project needs no server fields and uses valid blank URL inputs',
    () {
      const project = Project(
        title: 'Portfolio kampus',
        description: 'Karya dan pengalaman',
        category: ProjectCategory.web,
        role: 'Developer',
        skills: 'Django, Flutter',
      );

      expect(project.id, isNull);
      expect(project.toJson(), {
        ...requiredFields,
        'thumbnail': '',
        'project_url': '',
        'is_featured': false,
      });
    },
  );

  for (final category in ProjectCategory.values) {
    test('category ${category.value} reads and writes its backend value', () {
      final project = Project.fromJson({
        ...response,
        'category': category.value,
      });

      expect(project.category, category);
      expect(project.toJson()['category'], category.value);
    });
  }

  for (final explicitNulls in [false, true]) {
    test(
      'optional fields default safely with explicit nulls=$explicitNulls',
      () {
        final project = Project.fromJson({
          ...requiredFields,
          if (explicitNulls) ...{
            'id': null,
            'thumbnail': null,
            'project_url': null,
            'is_featured': null,
            'star_count': null,
            'is_starred': null,
            'starred_by_names': null,
          },
        });

        expect(project.id, isNull);
        expect(project.thumbnail, isEmpty);
        expect(project.projectUrl, isEmpty);
        expect(project.isFeatured, isFalse);
        expect(project.starCount, 0);
        expect(project.isStarred, isFalse);
        expect(project.starredByNames, isEmpty);
        expect(project.toJson(), {
          ...requiredFields,
          'thumbnail': '',
          'project_url': '',
          'is_featured': false,
        });
      },
    );
  }

  test('rejects categories outside the Project serializer contract', () {
    expect(
      () => Project.fromJson({...response, 'category': 'career'}),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });

  test(
    'does not silently replace invalid required fields with blank values',
    () {
      for (final field in requiredFields.keys) {
        final missing = Map<String, dynamic>.from(response)..remove(field);
        expect(
          () => Project.fromJson(missing),
          throwsA(isA<CheckedFromJsonException>()),
          reason: '$field is required',
        );
        expect(
          () => Project.fromJson({...response, field: null}),
          throwsA(isA<CheckedFromJsonException>()),
          reason: '$field cannot be null',
        );
      }
    },
  );
}
