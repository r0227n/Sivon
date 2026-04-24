---
name: Carry (or TBD)
description: "A minimal task management app focused on 'today' and seamless rescheduling"
platform: macOS (SwiftUI)

colors:
  primary: "#2563EB"
  background: "#F8FAFC"
  surface: "#FFFFFF"
  text-primary: "#111827"
  text-secondary: "#6B7280"
  danger: "#EF4444"
  success: "#22C55E"

typography:
  title:
    font: system
    size: 20
    weight: semibold
  body:
    font: system
    size: 14
    weight: regular
  caption:
    font: system
    size: 12
    weight: regular

spacing:
  xs: 4
  sm: 8
  md: 12
  lg: 16
  xl: 24

radius:
  sm: 6
  md: 8
  lg: 12

shadow:
  level-0: none
  level-1: subtle
---

# 1. Visual Theme

This product emphasizes **clarity, calmness, and temporal flow**.

- Minimal visual noise
- Focus on "today"
- Smooth transition between time states (today → future)
- Avoid decorative UI

---

# 2. Color Usage

## Primary
Used for:
- Active states
- Selected items
- Key actions

## Background / Surface
- Background: overall app canvas
- Surface: cards, lists

## Text
- Primary: main content
- Secondary: metadata (date, labels)

## Status Colors
- Danger: overdue tasks (must be visually strong)
- Success: completed tasks (subtle, not dominant)

---

# 3. Typography Rules

- Use system font for consistency with macOS
- Titles should feel stable, not loud
- Avoid large font size jumps
- Maintain vertical rhythm

---

# 4. Layout Principles

## Structure
3-column layout:
1. Sidebar
2. Task List
3. Detail Panel

## Rules
- Keep consistent spacing between elements
- Align left edges strictly
- Avoid nested containers unless necessary

---

# 5. Component Guidelines

## Task Row (Core Component)

Structure:
- Checkbox (left)
- Title
- Due date
- Optional metadata

States:
- Default
- Selected
- Completed
- Overdue

Rules:
- Overdue must be immediately recognizable
- Completed should be visually de-emphasized
- Row height must remain consistent

---

## Sidebar Item

Structure:
- Icon + Label

States:
- Default
- Active

Rules:
- Active state uses primary color background
- Keep icon weight consistent

---

## Button

Types:
- Primary
- Secondary
- Ghost

Rules:
- Primary only for main actions
- Avoid overusing buttons (prefer inline actions)

---

## Input (Task Creation)

Rules:
- Must be frictionless
- Enter = create task
- No modal required

---

## Date Control

Quick actions:
- Today
- Tomorrow
- Next week

Rules:
- Must be accessible within 1 click
- Avoid complex calendar UI in MVP

---

# 6. State Representation

## Overdue
- Use danger color
- Show date in red
- Encourage rescheduling

## Completed
- Reduce opacity
- Keep readable

## Selected
- Highlight background subtly

---

# 7. Interaction Principles

- Minimize clicks
- Prefer inline editing
- Keyboard-first interaction (macOS)

---

# 8. Motion

- Subtle transitions only
- No heavy animation
- State change should feel instant

---

# 9. Do's and Don'ts

## Do
- Keep UI minimal
- Emphasize task flow over structure
- Make rescheduling effortless

## Don't
- Add unnecessary hierarchy
- Overuse colors
- Introduce modal-heavy UX

---

# 10. Accessibility

- Ensure sufficient contrast
- Maintain readable font sizes
- Avoid color-only meaning

---

# 11. Future Extensions

- Tags
- Categories
- Recurring tasks
- Notifications
- iOS adaptation

---

# 12. Agent Instructions

When generating UI:
- Always prioritize "Today View"
- Keep Task Row consistent
- Use defined tokens only
- Avoid introducing new styles without updating DESIGN.md