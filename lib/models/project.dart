import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disamakan dengan `ProjectSerializer` di Django.
///
/// Field yang dihitung server (id, slug, label kategori/status, jumlah star)
/// memakai `includeToJson: false`, jadi tidak ikut terkirim saat POST.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.summary,
    required this.role,
    required this.technologies,
    this.category = 'game',
    this.status = 'released',
    this.projectUrl = '',
    this.thumbnailUrl = '',
    this.featured = false,
    this.id,
    this.slug,
    this.categoryDisplay,
    this.statusDisplay,
    this.starCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  @JsonKey(includeToJson: false)
  final String? slug;
  final String title;
  final String summary;
  final String category;
  @JsonKey(includeToJson: false)
  final String? categoryDisplay;
  final String status;
  @JsonKey(includeToJson: false)
  final String? statusDisplay;
  final String role;
  final String technologies;
  @JsonKey(defaultValue: '')
  final String projectUrl;
  @JsonKey(defaultValue: '')
  final String thumbnailUrl;
  @JsonKey(defaultValue: false)
  final bool featured;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

/// Pilihan kategori dan status, sama dengan choices di model Project Django.
const Map<String, String> projectCategories = {
  'game': 'Game Development',
  'security': 'Cybersecurity & CTF',
  'data': 'Data & AI',
};

const Map<String, String> projectStatuses = {
  'released': 'Released',
  'in-development': 'In Development',
  'prototype': 'Prototype',
};
