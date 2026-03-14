import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  // Define the scopes required: Read-only access to calendar events
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarEventsReadonlyScope],
  );

  GoogleSignInAccount? _currentUser;
  List<calendar.Event> _events = [];
  bool _isLoading = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() => _currentUser = account);
      if (_currentUser != null) {
        _fetchEvents();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      setState(() => _errorMsg = 'Sign in failed: $error');
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      // Get an authenticated HTTP client via the extension package
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return;

      final calendarApi = calendar.CalendarApi(httpClient);
      final events = await calendarApi.events.list(
        'primary',
        timeMin: DateTime.now().toUtc(),
        maxResults: 10,
        singleEvents: true,
        orderBy: 'startTime',
      );

      setState(() {
        _events = events.items ?? [];
      });
    } catch (e) {
      setState(() => _errorMsg = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Schedule', style: Theme.of(context).textTheme.headlineSmall),
              if (_currentUser != null)
                IconButton(icon: const Icon(Icons.logout), onPressed: _handleSignOut),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentUser == null) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month),
          label: const Text('Connect Google Calendar'),
          onPressed: _handleSignIn,
        ),
      );
    }
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMsg.isNotEmpty) return Text(_errorMsg, style: const TextStyle(color: Colors.red));
    if (_events.isEmpty) return const Center(child: Text('No upcoming events.'));

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final start = event.start?.dateTime ?? event.start?.date;
        final timeString = start != null ? '${start.hour}:${start.minute.toString().padLeft(2, '0')}' : 'All Day';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('${start?.day ?? "?"}')),
            title: Text(event.summary ?? '(No Title)', maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(timeString),
          ),
        );
      },
    );
  }
}