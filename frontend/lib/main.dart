import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const ink = Color(0xFF101411);
const panel = Color(0xFF1A211C);
const lime = Color(0xFFB9F45A);
const muted = Color(0xFF9AA79D);
const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api');

void main() => runApp(const ChargeShareApp());

class Session {
  static String? token, email, fullName, role;
  static void clear() { token = email = fullName = role = null; }
}

class Api {
  static Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$apiBase$path').replace(queryParameters: query);
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (Session.token != null) 'Authorization': 'Bearer ${Session.token}',
  };
  static Future<dynamic> get(String path, [Map<String, String>? query]) async =>
      _read(await http.get(uri(path, query), headers: headers));
  static Future<dynamic> post(String path, [Map<String, dynamic>? body]) async =>
      _read(await http.post(uri(path), headers: headers, body: jsonEncode(body ?? {})));
  static Future<dynamic> put(String path, [Map<String, dynamic>? body]) async =>
      _read(await http.put(uri(path), headers: headers, body: jsonEncode(body ?? {})));
  static Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async =>
      _read(await http.patch(uri(path), headers: headers, body: jsonEncode(body ?? {})));
  static Future<void> delete(String path) async {
    final r = await http.delete(uri(path), headers: headers);
    if (r.statusCode < 200 || r.statusCode >= 300) _read(r);
  }
  static dynamic _read(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      var message = 'Request failed (${r.statusCode})';
      try {
        final b = jsonDecode(r.body);
        if (b is Map) message = (b['detail'] ?? b['message'] ?? b['error'] ?? b['title'] ?? message).toString();
      } catch (_) { if (r.body.isNotEmpty) message = r.body; }
      throw Exception(message);
    }
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }
}

class ChargeShareApp extends StatelessWidget {
  const ChargeShareApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ChargeShare', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(primary: lime, secondary: lime, surface: panel),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: muted),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    ),
    home: Session.token == null ? const LoginScreen() : const HomeScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController();
  String role = 'USER';
  bool registering = false, busy = false, obscure = true;
  @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }
  void message(String m, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: error ? Colors.red.shade800 : const Color(0xFF2D4325)));
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      if (registering) {
        await Api.post('/auth/register', {'fullName': name.text.trim(), 'email': email.text.trim(), 'password': password.text, 'role': role});
        if (!mounted) return;
        setState(() { registering = false; password.clear(); });
        message('Account created. Log in with your new account.');
      } else {
        final result = Map<String, dynamic>.from(await Api.post('/auth/login', {'email': email.text.trim(), 'password': password.text, 'role': role}));
        Session.token = result['token']?.toString();
        Session.email = result['email']?.toString();
        Session.fullName = result['fullName']?.toString();
        Session.role = result['role']?.toString();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) { if (mounted) message(e.toString().replaceFirst('Exception: ', ''), error: true); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(22), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(height: 78, width: 78, alignment: Alignment.center,
              decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.bolt, color: ink, size: 48)),
            const SizedBox(height: 22),
            const Text('ChargeShare', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 7),
            const Text('Community-powered EV charging across Goa.', style: TextStyle(color: muted)),
            const SizedBox(height: 28),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(24)),
              child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(registering ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: role, decoration: const InputDecoration(labelText: 'Continue as', prefixIcon: Icon(Icons.badge_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text('EV User')),
                    DropdownMenuItem(value: 'HOST', child: Text('Charging Host')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                  ], onChanged: busy ? null : (v) => setState(() => role = v ?? 'USER')),
                if (registering) ...[
                  const SizedBox(height: 12),
                  TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
                ],
                const SizedBox(height: 12),
                TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.alternate_email)),
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
                const SizedBox(height: 12),
                TextFormField(controller: password, obscureText: obscure,
                  decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off))),
                  validator: (v) => v == null || v.length < 6 ? 'Use at least 6 characters' : null),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: busy ? null : submit,
                  style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: ink, padding: const EdgeInsets.all(16)),
                  child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) :
                    Text(registering ? 'Create account' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w800))),
                TextButton(onPressed: busy ? null : () => setState(() => registering = !registering),
                  child: Text(registering ? 'Already registered? Sign in' : 'New here? Create a user or host account')),
              ]))),
          ])))));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  bool loading = true, hostAvailable = true;
  String query = '';
  List<Map<String, dynamic>> locations = [], bookings = [], payments = [], users = [];
  Map<String, dynamic> summary = {};
  final emailFilter = TextEditingController();
  final searchController = TextEditingController();
  String? typeFilter;
  bool solarOnly = false, availableOnly = true;
  bool get isAdmin => Session.role == 'ADMIN';
  bool get isHost => Session.role == 'HOST';
  bool get isUser => Session.role == 'USER';

  @override void initState() { super.initState(); refresh(); }
  @override void dispose() { emailFilter.dispose(); searchController.dispose(); super.dispose(); }
  void message(String m, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: error ? Colors.red.shade800 : const Color(0xFF2D4325)));
  }
  Future<void> refresh({bool showLoading = true}) async {
    if (showLoading) setState(() => loading = true);
    try {
      final q = <String, String>{};
      if (query.trim().isNotEmpty) q['q'] = query.trim();
      if (typeFilter != null) q['type'] = typeFilter!;
      if (solarOnly) q['solar'] = 'true';
      if (availableOnly && isUser) q['available'] = 'true';
      // Every role must load its own authorized transaction list. The API filters
      // records by role (user = own payments, host = own locations, admin = all).
      final results = await Future.wait([
        Api.get('/locations', q),
        Api.get('/bookings', isAdmin && emailFilter.text.trim().isNotEmpty ? {'email': emailFilter.text.trim()} : null),
        Api.get('/payments'),
      ]);
      final l = List<Map<String, dynamic>>.from(results[0]);
      final b = List<Map<String, dynamic>>.from(results[1]);
      final p = List<Map<String, dynamic>>.from(results[2]);
      if (!mounted) return;
      setState(() { locations = l; bookings = b; payments = p; });
      if (isAdmin) {
        final adminResults = await Future.wait([Api.get('/admin/users'), Api.get('/admin/summary')]);
        if (!mounted) return;
        setState(() {
          users = List<Map<String, dynamic>>.from(adminResults[0]);
          summary = Map<String, dynamic>.from(adminResults[1]);
        });
      } else if (isHost) {
        final a = await Api.get('/locations/host/availability');
        if (!mounted) return;
        setState(() => hostAvailable = a['available'] == true);
      }
    } catch (e) { if (mounted) message(e.toString().replaceFirst('Exception: ', ''), error: true); }
    finally { if (mounted && showLoading) setState(() => loading = false); }
  }
  Future<void> logout() async {
    try { await Api.post('/auth/logout'); } catch (_) {}
    Session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }
  Future<void> toggleLocationAvailability(Map<String, dynamic> location, bool value) async {
    try {
      await Api.put('/locations/${location['id']}/availability', {'available': value});
      message('${location['name']} is now ${value ? 'available' : 'unavailable'}');
      await refresh();
    } catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  Future<void> respond(Map<String, dynamic> b, String action) async {
    try { await Api.patch('/bookings/${b['id']}/$action'); message(action == 'accept' ? 'Booking accepted' : action == 'reject' ? 'Booking rejected' : 'Booking cancelled'); await refresh(); }
    catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  Future<void> pay(Map<String, dynamic> b) async {
    final method = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel, title: const Text('Pay in ChargeShare'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Booking #${b['id']} • ₹${b['totalPrice']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: lime)),
        const SizedBox(height: 12), const Text('Demo payment only. No real money will be charged.'),
        const SizedBox(height: 12), const Text('Select a demo payment method'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
        FilledButton(onPressed: () => Navigator.pop(ctx, 'UPI-DEMO'), child: const Text('Pay with demo UPI')),
        FilledButton.tonal(onPressed: () => Navigator.pop(ctx, 'CARD-DEMO'), child: const Text('Demo card')),
      ]));
    if (method == null) return;
    try { final result = await Api.post('/payments/booking/${b['id']}/demo', {'method': method}); message('Demo payment successful • ${result['transactionReference']}'); await refresh(); }
    catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  Future<void> cancelBooking(Map<String, dynamic> b) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel, title: const Text('Cancel this booking?'),
      content: const Text('The booking will be marked as cancelled.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep booking')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel booking'))]));
    if (yes == true) await respond(b, 'cancel');
  }
  Future<void> bookingForm(Map<String, dynamic> location, [Map<String, dynamic>? existing]) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?['customerName']?.toString() ?? Session.fullName ?? '');
    final email = TextEditingController(text: existing?['customerEmail']?.toString() ?? Session.email ?? '');
    final energy = TextEditingController(text: existing?['energyKwh']?.toString() ?? '10');
    final date = TextEditingController(text: existing?['startTime'] == null
      ? DateFormat("yyyy-MM-dd'T'HH:mm").format(DateTime.now().add(const Duration(hours: 2)))
      : existing!['startTime'].toString().substring(0, 16));
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel, title: Text(existing == null ? 'Book ${location['name']}' : 'Modify booking #${existing['id']}'),
      content: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('₹${location['pricePerKwh']} per kWh', style: const TextStyle(color: lime, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _field(name, 'Full name'), _field(email, 'Email address'),
        _field(energy, 'Energy required (kWh)', number: true),
        _field(date, 'Start time (YYYY-MM-DDTHH:MM)'),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
        FilledButton(onPressed: () async {
          if (!key.currentState!.validate()) return;
          try {
            final dt = DateTime.parse(date.text);
            final payload = {'locationId': location['id'], 'customerName': name.text.trim(), 'customerEmail': email.text.trim(),
              'energyKwh': double.parse(energy.text), 'startTime': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt)};
            if (existing == null) { await Api.post('/bookings', payload); }
            else { await Api.put('/bookings/${existing['id']}', payload); }
            if (ctx.mounted) Navigator.pop(ctx);
            message(existing == null ? 'Booking request sent to host' : 'Booking updated; host approval is required again');
            await refresh();
          } catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
        }, child: Text(existing == null ? 'Request booking' : 'Save changes')),
      ]));
    // Let the dialog route finish its closing animation before disposing field controllers.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose(); email.dispose(); energy.dispose(); date.dispose();
  }
  Future<void> locationForm([Map<String, dynamic>? existing]) async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController(text: existing?['name']?.toString() ?? '');
    final area = TextEditingController(text: existing?['area']?.toString() ?? '');
    final address = TextEditingController(text: existing?['address']?.toString() ?? '');
    final price = TextEditingController(text: existing?['pricePerKwh']?.toString() ?? '14');
    final chargers = TextEditingController(text: existing?['availableChargers']?.toString() ?? '1');
    final hostName = TextEditingController(text: existing?['hostName']?.toString() ?? 'Demo Host');
    final hostEmail = TextEditingController(text: existing?['hostEmail']?.toString() ?? 'host@chargeshare.demo');
    final desc = TextEditingController(text: existing?['description']?.toString() ?? '');
    String type = existing?['type']?.toString() ?? 'HOME';
    bool solar = existing?['solarSupported'] == true;
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      backgroundColor: panel, title: Text(existing == null ? 'Add charging location' : 'Edit location'),
      content: SizedBox(width: 450, child: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(name, 'Location name'), _field(area, 'Area / town'), _field(address, 'Full address'),
        _field(price, 'Price per kWh', number: true), _field(chargers, 'Available chargers', number: true),
        if (isAdmin) ...[_field(hostName, 'Host display name'), _field(hostEmail, 'Host account email')],
        _field(desc, 'Description', required: false),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Location type'),
          items: const ['HOME','CAFE','RESTAURANT','PUBLIC','HOTEL','OTHER'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setDialog(() => type = v ?? 'HOME')),
        SwitchListTile(title: const Text('Solar supported'), value: solar, activeColor: lime, onChanged: (v) => setDialog(() => solar = v)),
      ])))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (!key.currentState!.validate()) return;
          try {
            final body = {'name': name.text.trim(), 'area': area.text.trim(), 'address': address.text.trim(),
              'pricePerKwh': double.parse(price.text), 'availableChargers': int.parse(chargers.text),
              'hostName': hostName.text.trim(), 'hostEmail': hostEmail.text.trim(), 'description': desc.text.trim(),
              'type': type, 'solarSupported': solar, 'hostAvailable': existing?['hostAvailable'] ?? true};
            if (existing == null) await Api.post('/locations', body); else await Api.put('/locations/${existing['id']}', body);
            if (ctx.mounted) Navigator.pop(ctx);
            message(existing == null ? 'Location created' : 'Location updated'); await refresh();
          } catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
        }, child: const Text('Save location')),
      ])));
    // Avoid disposing controllers while the dialog's closing transition is still building widgets.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final c in [name, area, address, price, chargers, hostName, hostEmail, desc]) { c.dispose(); }
  }
  Widget _field(TextEditingController c, String label, {bool number = false, bool required = true}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(
      controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) return 'Required';
        if (number && v != null && v.isNotEmpty) {
          final n = double.tryParse(v);
          if (n == null || n <= 0) return 'Enter a number greater than zero';
        }
        return null;
      }));

  Future<void> deleteLocation(Map<String, dynamic> l) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: panel,
      title: const Text('Delete location?'), content: Text('Delete ${l['name']}?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (yes != true) return;
    try { await Api.delete('/locations/${l['id']}'); message('Location deleted'); await refresh(); }
    catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }
  Future<void> setUserEnabled(Map<String, dynamic> u, bool enabled) async {
    try { await Api.patch('/admin/users/${u['id']}/enabled', {'enabled': enabled}); message(enabled ? 'Account enabled' : 'Account suspended'); await refresh(); }
    catch (e) { message(e.toString().replaceFirst('Exception: ', ''), error: true); }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = isAdmin
      ? const [NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
        NavigationDestination(icon: Icon(Icons.ev_station_outlined), selectedIcon: Icon(Icons.ev_station), label: 'Locations'),
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Accounts'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Bookings')]
      : isHost
      ? const [NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.ev_station_outlined), selectedIcon: Icon(Icons.ev_station), label: 'My spots'),
        NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Earnings')]
      : const [NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'My bookings'),
        NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Payments')];
    if (tab >= destinations.length) tab = 0;
    return Scaffold(
      appBar: AppBar(backgroundColor: ink, title: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.bolt, color: ink)),
        const SizedBox(width: 10),
        const Text('Charge', style: TextStyle(fontWeight: FontWeight.w800)),
        const Text('Share', style: TextStyle(color: lime, fontWeight: FontWeight.w800)),
      ]), actions: [
        IconButton(tooltip: 'Refresh', onPressed: refresh, icon: const Icon(Icons.refresh)),
        PopupMenuButton<String>(tooltip: 'Account', onSelected: (v) { if (v == 'logout') logout(); },
          itemBuilder: (_) => [PopupMenuItem(value: 'logout', child: Text('Sign out (${Session.role})'))]),
      ]),
      body: loading ? const Center(child: CircularProgressIndicator(color: lime)) : IndexedStack(
        index: tab,
        children: isAdmin
          ? [_adminOverview(), _adminLocations(), _adminAccounts(), _bookingList(admin: true)]
          : isHost
          ? [_hostRequests(), _hostLocations(), _hostPayments()]
          : [_explore(), _bookingList(admin: false), _userPayments()],
      ),
      bottomNavigationBar: NavigationBar(backgroundColor: panel, indicatorColor: lime.withOpacity(.17),
        selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: destinations),
      floatingActionButton: isAdmin && tab == 1
        ? FloatingActionButton.extended(backgroundColor: lime, foregroundColor: ink, onPressed: () => locationForm(),
          icon: const Icon(Icons.add), label: const Text('Add location')) : null,
    );
  }

  Widget _page(List<Widget> children) => RefreshIndicator(color: lime, onRefresh: refresh,
    child: ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 28), children: children));
  Widget _heading(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -.5)),
    const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: muted)), const SizedBox(height: 18)]);
  Widget _stat(String value, String label) => Expanded(child: Container(padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: lime, fontSize: 24, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: muted, fontSize: 12)),
    ])));
  Widget _section(String title, String value) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const Spacer(), Text(value, style: const TextStyle(color: muted))]));
  Widget _empty(String text) => Padding(padding: const EdgeInsets.all(28),
    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: muted)));

  Widget _adminOverview() => _page([
    _heading('Admin overview', 'Complete control of the ChargeShare platform.'),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF293D27), Color(0xFF18231B)]), borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PLATFORM OPERATIONS', style: TextStyle(color: lime, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8), const Text('Keep community charging moving.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18), Row(children: [_stat('${summary['users'] ?? users.length}', 'Accounts'), const SizedBox(width: 10),
          _stat('${summary['locations'] ?? locations.length}', 'Locations')]),
        const SizedBox(height: 10), Row(children: [_stat('${summary['bookings'] ?? bookings.length}', 'Bookings'), const SizedBox(width: 10),
          _stat('₹${(summary['paidAmount'] ?? 0).toStringAsFixed(0)}', 'Demo payments')]),
      ]),
    ),
    const SizedBox(height: 22), _section('Recent bookings', '${bookings.length} total'),
    if (bookings.isEmpty) _empty('No bookings yet.'),
    ...bookings.take(5).map(_bookingCard),
    const SizedBox(height: 12), _section('Payments', '${payments.length} records'),
    ...payments.take(4).map(_paymentCard),
  ]);

  Widget _adminLocations() => _page([
    _heading('Locations', 'Admin controls for every charging point.'),
    TextField(controller: searchController, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search locations'),
      onChanged: (v) { query = v; refresh(showLoading: false); }),
    const SizedBox(height: 16), _section('All charging spots', '${locations.length} listed'),
    if (locations.isEmpty) _empty('No locations found.'),
    ...locations.map((l) => _locationCard(l, admin: true)),
  ]);

  Widget _explore() => _page([
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF293D27), Color(0xFF18231B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CHARGE LOCAL.\nDRIVE FURTHER.', style: TextStyle(fontSize: 28, height: 1.1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10), const Text('Find community charging spots and request a time that works for you.', style: TextStyle(color: muted)),
        const SizedBox(height: 18), Row(children: [_stat('${locations.length}', 'Charging spots'), const SizedBox(width: 10),
          _stat('${locations.where((l) => ((l['availableChargers'] as num?) ?? 0) > 0 && l['hostAvailable'] != false).length}', 'Available now')]),
      ]),
    ),
    const SizedBox(height: 20),
    TextField(controller: searchController, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by location, area or address'),
      onChanged: (v) { query = v; refresh(showLoading: false); }),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: [
      _chip('All types', typeFilter == null, () { setState(() => typeFilter = null); refresh(); }),
      ...['HOME','CAFE','RESTAURANT','PUBLIC','HOTEL'].map((t) => _chip(_pretty(t), typeFilter == t, () { setState(() => typeFilter = typeFilter == t ? null : t); refresh(); })),
      FilterChip(label: const Text('Solar'), selected: solarOnly, selectedColor: lime.withOpacity(.2), onSelected: (v) { setState(() => solarOnly = v); refresh(); }),
      FilterChip(label: const Text('Available'), selected: availableOnly, selectedColor: lime.withOpacity(.2), onSelected: (v) { setState(() => availableOnly = v); refresh(); }),
    ]),
    const SizedBox(height: 18), _section('Charging spots', '${locations.length} found'),
    if (locations.isEmpty) _empty('No charging spots match your filters.'),
    ...locations.map((l) => _locationCard(l)),
  ]);
  Widget _chip(String label, bool selected, VoidCallback onTap) =>
    FilterChip(label: Text(label), selected: selected, selectedColor: lime.withOpacity(.2), onSelected: (_) => onTap());

  Widget _locationCard(Map<String, dynamic> l, {bool admin = false, bool host = false}) => Container(
    margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.05))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: lime.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
          child: Icon(_typeIcon(l['type']?.toString()), color: lime, size: 25)),
        const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${l['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4), Text('${l['area']} • ${_pretty('${l['type']}')}', style: const TextStyle(color: muted, fontSize: 12)),
          Text('${l['address'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12)),
        ])),
        Text('₹${l['pricePerKwh']}', style: const TextStyle(color: lime, fontSize: 18, fontWeight: FontWeight.w900)),
      ]),
      if ((l['description'] ?? '').toString().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text('${l['description']}', style: const TextStyle(color: muted))),
      const SizedBox(height: 10),
      Wrap(spacing: 7, children: [
        _pill('${l['availableChargers']} chargers', ((l['availableChargers'] as num?) ?? 0) > 0),
        if (l['solarSupported'] == true) _pill('Solar supported', true),
        _pill(l['hostAvailable'] == false ? 'Host unavailable' : 'Host available', l['hostAvailable'] != false),
      ]),
      if (admin || host) ...[
        const SizedBox(height: 10),
        SwitchListTile(contentPadding: EdgeInsets.zero, dense: true, title: const Text('Location availability', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(l['hostAvailable'] == false ? 'Unavailable — users cannot book this location' : 'Available for booking', style: const TextStyle(color: muted, fontSize: 12)),
          value: l['hostAvailable'] != false, activeColor: lime, onChanged: (value) => toggleLocationAvailability(l, value)),
      ],
      if (admin) ...[const SizedBox(height: 4), Wrap(spacing: 8, children: [
        OutlinedButton.icon(onPressed: () => locationForm(l), icon: const Icon(Icons.edit_outlined), label: const Text('Edit')),
        OutlinedButton.icon(onPressed: () => deleteLocation(l), icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
      ])],
      if (isUser) ...[const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(
        onPressed: ((l['availableChargers'] as num?) ?? 0) > 0 && l['hostAvailable'] != false ? () => bookingForm(l) : null,
        style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: ink),
        child: const Text('Request a booking')))],
    ]),
  );

  Widget _hostRequests() => _page([
    _heading('Host requests', 'Accept or reject requests for your charging spots. Change availability separately on each spot in My Charging Spots.'),
    const SizedBox(height: 12), _section('Pending requests', '${bookings.where((b) => b['status'] == 'PENDING').length} pending'),
    if (bookings.isEmpty) _empty('No booking requests yet.'),
    ...bookings.map(_bookingCard),
  ]);
  Widget _hostLocations() => _page([
    _heading('My charging spots', 'Review your assigned charging locations.'),
    ...locations.where((l) => (l['hostEmail'] ?? '').toString().toLowerCase() == (Session.email ?? '').toLowerCase()).map((l) => _locationCard(l, host: true)),
    if (locations.where((l) => (l['hostEmail'] ?? '').toString().toLowerCase() == (Session.email ?? '').toLowerCase()).isEmpty)
      _empty('No locations are assigned to this host account yet. Ask the admin to assign a location using this account email.'),
  ]);
  Widget _hostPayments() => _page([
    _heading('Earnings', 'Payment records for your charging locations.'),
    _section('Payment records', '${payments.length} records'),
    if (payments.isEmpty) _empty('No payments yet.'),
    ...payments.map(_paymentCard),
  ]);
  Widget _bookingList({required bool admin}) => _page([
    _heading(admin ? 'All bookings' : 'My bookings', admin ? 'Monitor booking activity across the platform.' : 'Track requests, confirmations and payments.'),
    if (admin) TextField(controller: emailFilter, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Filter by customer email'),
      onSubmitted: (_) => refresh()),
    const SizedBox(height: 12),
    _section('Booking history', '${bookings.length} records'),
    if (bookings.isEmpty) _empty('No bookings found.'),
    ...bookings.map(_bookingCard),
  ]);
  Widget _bookingCard(Map<String, dynamic> b) {
    final location = b['location'] is Map ? Map<String, dynamic>.from(b['location']) : <String, dynamic>{};
    final status = '${b['status'] ?? 'PENDING'}';
    final isMine = '${b['customerEmail']}'.toLowerCase() == (Session.email ?? '').toLowerCase();
    final isOwnedHost = '${location['hostEmail']}'.toLowerCase() == (Session.email ?? '').toLowerCase();
    final canRespond = (isAdmin || (isHost && isOwnedHost)) && status == 'PENDING';
    final canUserEdit = isUser && isMine && (status == 'PENDING' || status == 'ACCEPTED' || status == 'CONFIRMED') && b['paymentStatus'] != 'PAID';
    final canPay = isUser && isMine && (status == 'ACCEPTED' || status == 'CONFIRMED') && b['paymentStatus'] != 'PAID';
    final canCancel = (isAdmin || isUser && isMine || isHost && isOwnedHost) && !['CANCELLED','REJECTED','COMPLETED'].contains(status);
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text('${location['name'] ?? 'Charging location'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
          _pill(status, status == 'ACCEPTED' || status == 'COMPLETED')]),
        const SizedBox(height: 7),
        Text('Booking #${b['id']} • ${b['customerName'] ?? ''}', style: const TextStyle(color: muted)),
        Text('${b['startTime'] ?? ''}'.replaceFirst('T', ' '), style: const TextStyle(color: muted)),
        const SizedBox(height: 4),
        Text('${b['energyKwh']} kWh • ₹${b['totalPrice']}', style: const TextStyle(color: lime, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4), Text('Payment: ${b['paymentStatus'] ?? 'UNPAID'}', style: const TextStyle(color: muted, fontSize: 12)),
        if (isAdmin) Text('Customer: ${b['customerEmail'] ?? ''} • Host: ${location['hostEmail'] ?? 'Unassigned'}', style: const TextStyle(color: muted, fontSize: 12)),
        if (canRespond || canUserEdit || canPay || canCancel) ...[
          const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 4, children: [
            if (canRespond) FilledButton(onPressed: () => respond(b, 'accept'), child: const Text('Accept')),
            if (canRespond) OutlinedButton(onPressed: () => respond(b, 'reject'), child: const Text('Reject')),
            if (canUserEdit) OutlinedButton.icon(onPressed: () => bookingForm(location, b), icon: const Icon(Icons.edit_outlined), label: const Text('Modify')),
            if (canPay) FilledButton(onPressed: () => pay(b), style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: ink), child: const Text('Pay now')),
            if (canCancel) TextButton.icon(onPressed: () => cancelBooking(b), icon: const Icon(Icons.cancel_outlined), label: const Text('Cancel')),
          ]),
        ],
      ]));
  }
  Widget _adminAccounts() => _page([
    _heading('Accounts', 'Review user and host accounts.'),
    _section('Registered accounts', '${users.length} accounts'),
    ...users.map((u) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(backgroundColor: lime.withOpacity(.15), child: Icon(u['role'] == 'HOST' ? Icons.house : u['role'] == 'ADMIN' ? Icons.shield : Icons.person, color: lime)),
        const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${u['fullName']}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${u['email']}', style: const TextStyle(color: muted, fontSize: 12)),
          Text('${u['role']} • ${u['enabled'] == true ? 'Enabled' : 'Suspended'}', style: const TextStyle(color: muted, fontSize: 12)),
        ])),
        if (u['role'] != 'ADMIN') IconButton(tooltip: u['enabled'] == true ? 'Suspend account' : 'Enable account',
          onPressed: () => setUserEnabled(u, u['enabled'] != true),
          icon: Icon(u['enabled'] == true ? Icons.block : Icons.check_circle_outline, color: u['enabled'] == true ? Colors.orange : lime)),
      ]))),
  ]);
  Widget _userPayments() => _page([
    _heading('Payments', 'Your ChargeShare demo payment history.'),
    _section('Transactions', '${payments.length} records'),
    if (payments.isEmpty) _empty('No payments yet. Accepted bookings will appear here after payment.'),
    ...payments.map(_paymentCard),
  ]);
  Widget _paymentCard(Map<String, dynamic> p) {
    final b = p['booking'] is Map ? Map<String, dynamic>.from(p['booking']) : <String, dynamic>{};
    final loc = b['location'] is Map ? Map<String, dynamic>.from(b['location']) : <String, dynamic>{};
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: lime.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.receipt_long, color: lime)),
        const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${loc['name'] ?? 'Charging session'}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${p['transactionReference'] ?? 'Transaction'} • ${p['method'] ?? ''}', style: const TextStyle(color: muted, fontSize: 11)),
          Text('${p['status'] ?? 'PAID'}', style: const TextStyle(color: lime, fontSize: 12)),
        ])),
        Text('₹${p['amount'] ?? b['totalPrice'] ?? 0}', style: const TextStyle(color: lime, fontWeight: FontWeight.w900)),
      ]));
  }
  Widget _pill(String text, bool active) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: active ? lime.withOpacity(.12) : Colors.white10, borderRadius: BorderRadius.circular(30)),
    child: Text(text, style: TextStyle(fontSize: 11, color: active ? lime : muted, fontWeight: FontWeight.w700)));
  IconData _typeIcon(String? t) => switch (t) {
    'HOME' => Icons.home_outlined, 'CAFE' => Icons.coffee_outlined, 'RESTAURANT' => Icons.restaurant_outlined,
    'MOTEL' || 'HOTEL' => Icons.hotel_outlined, 'PUBLIC' => Icons.ev_station, _ => Icons.bolt
  };
  String _pretty(String s) => s.toLowerCase().split('_').map((v) => v.isEmpty ? v : '${v[0].toUpperCase()}${v.substring(1)}').join(' ');
}
