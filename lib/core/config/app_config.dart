class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.tenantId,
  });

  final String apiBaseUrl;
  final String tenantId;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      ),
      tenantId: String.fromEnvironment(
        'TENANT_ID',
        defaultValue: 'T1',
      ),
    );
  }
}
