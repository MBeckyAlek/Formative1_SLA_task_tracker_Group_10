class TeamMember {
  final String id;
  final String name;
  final String role;
  final String email;

  const TeamMember ({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'email': email,
  };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    id: json['id'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    email: json['email'] as String,
  );

  TeamMember copyWith({
    String? name,
    String? role,
    String? email,
  }) =>
      TeamMember (
        id: id,
        name: name?? this.name,
        role: role?? this.role,
        email: email?? this.email,
      );
}