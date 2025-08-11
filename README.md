# HabitFlow - Personal Habit Tracker

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

HabitFlow is a simple and intuitive habit tracking app that helps users build consistent daily routines. Users can create custom habits, track daily progress, view streak counts, and visualize their progress over time with clean, motivating interfaces.

### App Evaluation

- **Category:** Productivity / Health & Wellness
- **Mobile:** Mobile-first experience with daily notifications, easy one-tap logging, and offline functionality
- **Story:** Empowers users to build positive habits through simple tracking and visual motivation
- **Market:** Students, professionals, and anyone looking to improve their daily routines (target: 18-35 years old)
- **Habit:** Daily use - users check in each day to log habits and see progress
- **Scope:** V1 focuses on core habit tracking. V2+ could add social features, advanced analytics, habit suggestions

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can create a new habit with name and target frequency
- [x] User can view list of all active habits
- [x] User can mark a habit as completed for today
- [x] User can see current streak count for each habit
- [x] User can edit habit details (name, target frequency)
- [x] User can delete habits they no longer want to track
- [x] App persists data between sessions
- [x] User can see today's progress overview

**Optional Nice-to-have Stories**

- [ ] User can view calendar showing habit completion history
- [ ] User can see weekly/monthly progress statistics
- [ ] User can set daily reminder notifications
- [ ] User can choose custom colors/icons for habits
- [ ] User can view motivational quotes or achievements
- [ ] User can backup/restore data
- [ ] User can share progress with friends

### 2. Screen Archetypes

- **Habit List Screen**
  - User can view all active habits
  - User can see today's completion status
  - User can quickly mark habits complete
  - User can see current streak counts

- **Add/Edit Habit Screen**
  - User can create new habit
  - User can edit existing habit details
  - User can set target frequency (daily, weekly, etc.)

- **Habit Detail Screen**
  - User can view detailed progress for specific habit
  - User can see historical data and streaks
  - User can edit or delete the habit

- **Progress Overview Screen** (Optional)
  - User can see overall progress summary
  - User can view weekly/monthly statistics

### 3. Navigation

**Tab Navigation** (Primary)

- Habits List (Home)
- Progress Overview

**Flow Navigation** (Screen to Screen)

- Habits List → Add Habit Screen
- Habits List → Habit Detail Screen
- Habit Detail Screen → Edit Habit Screen

## Wireframes

[Add your wireframe images here - can be hand-drawn photos or digital mockups]

### Low-Fidelity Wireframes
*Hand-drawn or basic digital wireframes showing the main screens*

### Digital Wireframes & Mockups
*Higher fidelity mockups showing colors, typography, and detailed layouts*

## Schema

### Models

**Habit**
| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| name | String | Habit name (e.g., "Drink 8 glasses of water") |
| targetFrequency | Int | Target completions per week (1-7) |
| createdDate | Date | When habit was created |
| currentStreak | Int | Current streak count |
| completedToday | Bool | Whether habit was completed today |

**HabitEntry**
| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| habitId | String | Reference to parent habit |
| date | Date | Date of completion |
| isCompleted | Bool | Whether habit was completed on this date |

### Networking

- No external API required for V1
- All data stored locally using UserDefaults
- Future versions could add cloud sync with Firebase

## Sprint Planning

### Sprint 1 (Week 9): Foundation & Core List
- [x] Set up project structure and repository
- [x] Create Habit data model
- [x] Implement basic habit list view
- [x] Add ability to create new habits
- [x] Implement local data persistence
- [x] Convert Task app structure to Habit tracking

### Sprint 2 (Week 10): Completion Tracking & Polish
- [ ] Add habit completion functionality with streak tracking
- [ ] Implement "mark completed today" feature
- [ ] Create habit detail view with progress history
- [ ] Add edit/delete functionality
- [ ] Polish UI and add habit-specific animations
- [ ] Test and fix bugs

### Post-Course (Optional Future Sprints):
- [ ] Add calendar view for completion history
- [ ] Implement progress statistics and charts
- [ ] Add push notifications for habit reminders
- [ ] Create onboarding flow and app tutorial

## Progress Updates

### Week 9 Progress:
- [x] Project setup complete
- [x] Repository created and configured
- [x] Basic project structure copied from Task app
- [x] Capstone documentation completed (brainstorm.md, README.md)
- [ ] Data model conversion in progress (Task → Habit)
- [ ] UI updates for habit tracking in progress

### Week 10 Progress:
*To be updated...*

## Video Walkthrough

Here's a walkthrough of implemented user stories:

*[Add your video/GIF here for Week 9 submission]*

## Notes

### Challenges Encountered:
- Converting Task app structure to work for habit tracking use case
- Designing streak calculation logic for daily habit completion
- Adapting calendar integration for habit progress visualization

### Technical Decisions:
- Reusing proven Task app architecture to save development time
- Maintaining UserDefaults for data persistence (simple and reliable)
- Focusing on daily habit completion rather than complex scheduling

## License

    Copyright [2025] [Kemely Alfonso Martinez]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
