import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  Future<void> loadData() async {
    setLoading(true);
    try {
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
