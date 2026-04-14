class WorkerProfileState {
  final bool isLoading;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? bio;
  final String? profession;
  final List<String> languages;
  final List<String> certifications;
  final String bankAccount;
  final String bankName;
  final String privacySetting;
  final bool isDarkMode;

  WorkerProfileState({
    required this.isLoading,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.address,
    this.bio,
    this.profession,
    required this.languages,
    required this.certifications,
    required this.bankAccount,
    required this.bankName,
    required this.privacySetting,
    required this.isDarkMode,
  });

  factory WorkerProfileState.initial() => WorkerProfileState(
    isLoading: true,
    firstName: null,
    lastName: null,
    email: null,
    phone: null,
    avatarUrl: null,
    address: null,
    bio: null,
    profession: null,
    languages: const [],
    certifications: const [],
    bankAccount: '',
    bankName: '',
    privacySetting: 'public',
    isDarkMode: false,
  );

  WorkerProfileState copyWith({
    bool? isLoading,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
    String? bio,
    String? profession,
    List<String>? languages,
    List<String>? certifications,
    String? bankAccount,
    String? bankName,
    String? privacySetting,
    bool? isDarkMode,
  }) {
    return WorkerProfileState(
      isLoading: isLoading ?? this.isLoading,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      privacySetting: privacySetting ?? this.privacySetting,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
