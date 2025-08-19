# Routine Tracker (Generic Templates)

A Flutter starter that lets any user create routines for **any topic** (workouts, study, prayers, habits).

## Core Concepts
- **Master Time Slots**: user-defined times like "Morning before Fajr", "After Maghrib", or "Evening 7:30 PM". Each has a name, optional note, and an exact clock time.
- **Templates**: define a routine template with a topic name (e.g., "Pushups", "Dhikr Astaghfirullah", "Study Math"), a target count (e.g., 20/30/100), select a **Master Time Slot**, and number of days (e.g., 10/30/40).
- **Routine Instance**: when you create from a template, the app records a routine with `start_date`, `end_date`, and `total_days`.
- **Daily Progress**: each day you can increment counts toward the target; completion is tracked per date + template.

## How to Run
```bash
flutter pub get
flutter run
```
If you created an empty folder, run `flutter create .` once to generate platform folders.

## SQLite Tables
- `timeslots(id, name, note, clock)`
- `templates(id, topic, target_count, timeslot_id, total_days)`
- `routines(id, template_id, start_date, end_date, total_days)`
- `progress(id, date, template_id, completed_count, is_completed)`

## Next Steps
- Add notifications to remind at the slot's `clock` time.
- Export/import data (CSV/JSON).
- Tagging and analytics.
