import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/event/models/event.dart';

// Form for add and edit

class EventFormPage extends StatefulWidget {
  final Events? event; // Null = create, not null = edit

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _homeTeamController = TextEditingController();
  final _awayTeamController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController();
  final _posterController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  Category _selectedCategory = Category.FOOTBALL; // default value
  bool _isSubmitting = false;
  String _posterPreviewUrl = '';

  @override
  void initState() {
    super.initState();

    // preview poster urls
    _posterController.addListener(() {
      if (_posterController.text != _posterPreviewUrl) {
        setState(() {
          _posterPreviewUrl = _posterController.text;
        });
      }
    });

    // If editing, fill form with existing event data
    if (widget.event != null) {
      final event = widget.event!;
      _nameController.text = event.name;
      _homeTeamController.text = event.homeTeam;
      _awayTeamController.text = event.awayTeam;
      _descriptionController.text = event.description;
      _venueController.text = event.venue;
      _capacityController.text = event.capacity.toString();
      _posterController.text = event.poster ?? '';
      _selectedDateTime = event.date;
      _selectedCategory = event.category;
      _posterPreviewUrl = event.poster ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  // Select datetime
  Future<void> _selectDateTime(BuildContext context) async {

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;


    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    // Combine date and time
    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = combinedDateTime;
    });
  }


  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute';
  }


  String _getCategoryLabel(Category category) {
    switch (category) {
      case Category.BADMINTON:
        return 'Badminton';
      case Category.BASKETBALL:
        return 'Basketball';
      case Category.FOOTBALL:
        return 'Football';
      case Category.TENNIS:
        return 'Tennis';
      case Category.VOLLEYBALL:
        return 'Volleyball';
      default:
        return 'Football';
    }
  }

  // NOTE: integrate authentication for adding (CSRF problem because not logged in)
  // (should work)
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isSubmitting) return; // prevent double submission

      setState(() {
        _isSubmitting = true;
      });

      try {
        final request = Provider.of<CookieRequest>(context, listen: false);

        // Prepare event data
        final eventData = {
          "name": _nameController.text.trim(),
          "home_team": _homeTeamController.text.trim(),
          "away_team": _awayTeamController.text.trim(),
          "description": _descriptionController.text.trim(),
          "venue": _venueController.text.trim(),
          "date": _selectedDateTime.toIso8601String(),
          "capacity": int.parse(_capacityController.text),
          "category": _selectedCategory.toString().split('.').last.toLowerCase(),
          "poster": _posterController.text.trim().isNotEmpty ? _posterController.text.trim() : "",
        };

        // Determine URL based on create/edit
        // TODO: ganti link ke pws
        String url;
        if (widget.event == null) {
          // Create new event
          url = 'http://laudya-michelle-sporticket.pbp.cs.ui.ac.id/events/create-flutter/';
        } else {
          // Update existing event
          url = 'http://laudya-michelle-sporticket.pbp.cs.ui.ac.id/events/update-flutter/${widget.event!.matchId}/';
        }


        final response = await request.postJson(
          url,
          jsonEncode(eventData),
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          // toast (temp)
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.event == null
                    ? 'Event created successfully!'
                    : 'Event updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // return after success then refresh
            Navigator.pop(context, true);
          } else {
            // debug
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Something went wrong'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });

          // debug
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        print('Error submitting event: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button, name, and icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_back_ios),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Page title
                    Text(
                      widget.event == null ? 'Create Event' : 'Edit Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    // App icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo_sporticket.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Event name
                          TextFormField(
                            controller: _nameController,
                            enabled: !_isSubmitting,
                            decoration: InputDecoration(
                              labelText: 'Event Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter event name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Team names
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _homeTeamController,
                                  enabled: !_isSubmitting,
                                  decoration: InputDecoration(
                                    labelText: 'Home Team',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter home team';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'VS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _awayTeamController,
                                  enabled: !_isSubmitting,
                                  decoration: InputDecoration(
                                    labelText: 'Away Team',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter away team';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category dropdown - disabled when editing (match_id is based on category)
                          DropdownButtonFormField<Category>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Sport Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              // Show hint when disabled
                              suffixIcon: widget.event != null
                                  ? Tooltip(
                                message: 'Event category cannot be changed!',
                                child: Icon(Icons.lock, size: 20, color: Colors.grey[400]),
                              )
                                  : null,
                            ),
                            items: Category.values
                                .where((cat) => cat != Category.ALL)
                                .map((Category category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(_getCategoryLabel(category)),
                              );
                            }).toList(),
                            // Only allow changes when creating new event
                            onChanged: (widget.event == null && !_isSubmitting)
                                ? (Category? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            }
                                : null,
                            disabledHint: Text(_getCategoryLabel(_selectedCategory)),
                          ),
                          const SizedBox(height: 16),

                          // Date & Time Picker
                          InkWell(
                            onTap: _isSubmitting ? null : () => _selectDateTime(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date & Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(_selectedDateTime),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Change',
                                    style: TextStyle(
                                      color: _isSubmitting ? Colors.grey : primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Venue
                          TextFormField(
                            controller: _venueController,
                            enabled: !_isSubmitting,
                            decoration: InputDecoration(
                              labelText: 'Venue',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter venue';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Capacity
                          TextFormField(
                            controller: _capacityController,
                            enabled: !_isSubmitting,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Capacity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              suffixText: 'people',
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter capacity';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (int.parse(value) < 0) {
                                return 'Capacity must be a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Poster URL (optional)
                          TextFormField(
                            controller: _posterController,
                            enabled: !_isSubmitting,
                            decoration: InputDecoration(
                              labelText: 'Poster Image URL (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Preview poster if URL is provided
                          if (_posterPreviewUrl.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Poster Preview:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _posterPreviewUrl,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            enabled: !_isSubmitting,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Action button
                          Row(
                            children: [
                              // Cancel
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey.shade400),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Submit button
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: primaryColor,
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : Text(
                                    widget.event == null ? 'Create Event' : 'Update Event',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}