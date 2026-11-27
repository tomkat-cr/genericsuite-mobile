# GS-346 Enhance Mobile UI Listing Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Status:** Implemented. All tasks are done (`[x]`).
> Commits: `genericsuite-mobile` `d7d6763` (on `develop`, rebased onto the UTC date fix `dc9d303`), `genericsuite-basecamp` `efcb39a`.

**Goal:** Make the CRUD editor listing screen configurable from the frontend JSON (columns per line), format the listing values, and give even and odd rows different colors set by theme params.

**Architecture:** The pure listing logic goes in a new file `lib/services/crud_editor_listing.dart` (public top-level functions, unit-tested). `crud_editor.dart` calls these functions from `_loadEditorConfig`, `_buildListingLine` and `_buildListItem`. The new theme tokens go in `theme_config_defaults.dart`. Apps override them in `AppCallablesSuper.getThemeParams()`, and a missing key falls back to `defaultThemeParams`.

**Tech Stack:** Flutter / Dart (SDK `>=3.10.7`), `intl` (`DateFormat`), `flutter_test`, MkDocs Material (GS Basecamp docs).

**Spec:** Jira GS-346 "Enhance Mobile UI Listing screen", plus the user decisions below.

## Global Constraints

- JSON format: `colsForListingLine1` / `colsForListingLine2` are **int counts** of `"listing": true` fields, in `fieldElements` order. Top-level keys in `assets/config_dbdef/frontend/<entity>.json`.
- Priority: `CrudEditor(props: {...})` > frontend JSON > class default (`1` / `0`).
- Line layout: values on one line are joined text with a separator (theme key `listingColumnSeparator`, default `' · '`).
- Value formatting: `select` labels, `date` → `yyyy-MM-dd`, `datetime` / `datetime-local` → `yyyy-MM-dd HH:mm`, `boolean` / `checkbox` → `Yes` / `No`, empty or null values are skipped.
- Row colors match the GS FE (`genericsuite-fe/src/lib/services/generic.editor.rfc.service.jsx:575`): even rows (index 0, 2, ...) `Color(0xFFE5E7EB)` (Tailwind gray-200), odd rows `Colors.transparent`.
- Epoch dates are read as UTC, the same as `timestampToDate()` in `lib/services/timestamp_utilities.dart`.
- `flutter analyze` must report no new issues except the existing `material.dart` `deprecated_member_use` infos. `dart format --set-exit-if-changed .` must pass.
- Docs: Markdown with minimal HTML, `pymdown-extensions` syntax (`genericsuite-basecamp/docs/codeStyle.md`). English and Spanish pages.
- Communications use ASD-STE100 Simplified Technical English.

## Review Focus

1. Invalid JSON values (`"2"`, `-1`, `"abc"`, `null`): a numeric string is accepted, a negative value becomes 0, other values use the default. Tested in Task 2 (`toNonNegativeInt`, `resolveListingCols`).
2. Counts larger than the number of listing fields: the total is clamped, and the title is never empty. Tested in Task 2 (`clampListingCols`).
3. Null or empty values: the listing never shows the text `null`. Tested in Task 3 (`null and empty values give an empty string`).
4. Epoch dates near midnight UTC on a device in another time zone: the listing and the form show the same date. Tested in Task 3 (`date and datetime formats`, compared with `timestampToDate`). Run in two time zones.
5. An app that returns only some keys from `getThemeParams()`: the missing keys use the defaults. Tested in Task 4 (`overrides from theme params, other keys use defaults`).

---

## File Structure

| File | Responsibility |
|------|----------------|
| Create: `genericsuite_flutter/lib/services/crud_editor_listing.dart` | Pure listing logic: int parse/clamp, value format, line join, row colors |
| Modify: `genericsuite_flutter/lib/services/theme_config_defaults.dart` | 6 new listing tokens in `defaultThemeParams` |
| Modify: `genericsuite_flutter/lib/services/crud_editor.dart` | Use the listing functions in `_loadEditorConfig`, `_buildListingLine`, `_buildListItem` |
| Create: `genericsuite_flutter/test/crud_editor_listing_test.dart` | Unit tests for `crud_editor_listing.dart` |
| Modify: `genericsuite_flutter/test/theme_params_test.dart` | Check the new default keys |
| Modify: `genericsuite_flutter/CHANGELOG.md` | GS-346 entries under `[Unreleased]` |
| Modify: `genericsuite-basecamp/mkdocs_root/{en,es}/Mobile-Development/index.md` | "Listing screen" subsection and Theming table rows |

---

### Task 1: Listing theme tokens

**Files:**
- Modify: `genericsuite_flutter/lib/services/theme_config_defaults.dart`
- Test: `genericsuite_flutter/test/theme_params_test.dart`

**Interfaces:**
- Produces: `defaultThemeParams` keys `listingRowEvenBackgroundColor` (`Color`), `listingRowOddBackgroundColor` (`Color`), `listingRowEvenTextColor` (`Color`), `listingRowOddTextColor` (`Color`), `listingRowSubtitleColor` (`Color`), `listingColumnSeparator` (`String`).

- [x] **Step 1: Write the failing test** `defaultThemeParams carries the listing screen tokens [GS-346]`

```dart
expect(defaultThemeParams['listingRowEvenBackgroundColor'], const Color(0xFFE5E7EB));
expect(defaultThemeParams['listingRowOddBackgroundColor'], Colors.transparent);
expect(defaultThemeParams['listingRowEvenTextColor'], textColor);
expect(defaultThemeParams['listingRowOddTextColor'], textColor);
expect(defaultThemeParams['listingRowSubtitleColor'], secondaryTextColor);
expect(defaultThemeParams['listingColumnSeparator'], ' · ');
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme_params_test.dart`
Expected: FAIL (keys are null)

- [x] **Step 3: Add the 6 `const` tokens and add them to `defaultThemeParams`** (values from Global Constraints).

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/theme_params_test.dart`
Expected: PASS

- [x] **Step 5: Commit** (combined into the GS-346 commit)

---

### Task 2: Columns per line from JSON

**Files:**
- Create: `genericsuite_flutter/lib/services/crud_editor_listing.dart`
- Modify: `genericsuite_flutter/lib/services/crud_editor.dart` (`_loadEditorConfig`, after `listingFieldElements` is set)
- Test: `genericsuite_flutter/test/crud_editor_listing_test.dart`

**Interfaces:**
- Produces:
  - `int toNonNegativeInt(dynamic value, int fallback)`
  - `int resolveListingCols({required String key, required Map<String, dynamic>? props, required Map<String, dynamic>? editorConfig, required int defaultValue})`
  - `({int line1, int line2}) clampListingCols(int line1, int line2, int listingFieldsCount)`

- [x] **Step 1: Write the failing tests**

- `toNonNegativeInt`: `accepts int, num and numeric String` (`2`, `2.0`, `"2"` → `2`); `invalid values use the fallback; negative gives 0` (`"abc"`, `null` → fallback; `-1` → `0`).
- `resolveListingCols`: `uses the default when no JSON and no props`; `reads the JSON value`; `props override the JSON`; `invalid JSON value uses the default`.
- `clampListingCols`: `line1 + line2 does not pass the listing fields count` (`(3, 3, 4)` → `(3, 1)`); `title fallback: line1 0 becomes 1` (`(0, 1, 4)` → `(1, 1)`); `no listing fields keeps non-negative values`.

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/crud_editor_listing_test.dart`
Expected: FAIL (functions not defined)

- [x] **Step 3: Implement the three functions** in `crud_editor_listing.dart`. In `_loadEditorConfig`, call `resolveListingCols` for both keys, then `clampListingCols(..., listingFieldElements.length)`. Remove the old `props` block for these keys and its `TODO` comments.

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/crud_editor_listing_test.dart`
Expected: PASS

- [x] **Step 5: Commit** (combined into the GS-346 commit)

---

### Task 3: Listing value formatting

**Files:**
- Modify: `genericsuite_flutter/lib/services/crud_editor_listing.dart`
- Modify: `genericsuite_flutter/lib/services/crud_editor.dart` (`_buildListingLine`; new private `_getListingSelectOptions(Map<String, dynamic> field)`)
- Test: `genericsuite_flutter/test/crud_editor_listing_test.dart`

**Interfaces:**
- Consumes: `listingColumnSeparator` (Task 1).
- Produces:
  - `String formatListingValue(Map<String, dynamic> field, Map<String, dynamic> item, {dynamic selectOptions})`. It returns `''` for null or empty values.
  - `String joinListingValues(Iterable<String> values, String separator)`

- [x] **Step 1: Write the failing tests**

- `select shows the label, or the raw value without a label` (not `--value--`).
- `select_table uses description, then options, then raw` (`${name}_description` → options map → raw).
- `date and datetime formats`: `'2026-03-04T10:20:30'` → `'2026-03-04'`; `datetime-local` `'2026-03-04 10:20:30'` → `'2026-03-04 10:20'`; epoch ms of `DateTime.utc(2026, 3, 4, 10, 20)` → `'2026-03-04 10:20'`; epoch seconds of `DateTime.utc(2026, 3, 4, 0, 30)` → `'2026-03-04'` and equal to `timestampToDate(timestamp: seconds)`; `'not a date'` → `'not a date'`.
- `boolean shows Yes / No` (`true`, `false`, checkbox `'true'`).
- `null and empty values give an empty string`.
- `other types show the raw value`.
- `joins non-empty values with the separator`.

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/crud_editor_listing_test.dart`
Expected: FAIL

- [x] **Step 3: Implement `formatListingValue` and `joinListingValues`.** Epoch numbers: milliseconds when `>= 100000000000`, else seconds. Use `DateTime.fromMillisecondsSinceEpoch(..., isUtc: true)`. Select options come from `constants[field['select_elements']]` (`select`) or `editorConfig['selectFieldsOptionsPromises'][...]['promiseResult']` (`select_component`, `select_table`). Change `_buildListingLine` to format each column and join with the separator. Remove `_getColumnName` and `_selectTableFallbackDescription` (no other callers).

- [x] **Step 4: Run tests to verify they pass, in two time zones**

Run: `TZ=America/Caracas flutter test` and `TZ=Asia/Tokyo flutter test test/crud_editor_listing_test.dart`
Expected: PASS

- [x] **Step 5: Commit** (combined into the GS-346 commit)

---

### Task 4: Even/odd row colors

**Files:**
- Modify: `genericsuite_flutter/lib/services/crud_editor_listing.dart`
- Modify: `genericsuite_flutter/lib/services/crud_editor.dart` (`_buildListItem`; new private `_getListingThemeParams()`)
- Test: `genericsuite_flutter/test/crud_editor_listing_test.dart`

**Interfaces:**
- Consumes: Task 1 keys.
- Produces:
  - `dynamic getListingThemeParam(Map<String, dynamic>? themeParams, String key)`. It returns `themeParams?[key] ?? defaultThemeParams[key]`.
  - `Color listingRowBackgroundColor(int index, Map<String, dynamic>? themeParams)`
  - `Color listingRowTextColor(int index, Map<String, dynamic>? themeParams)`

- [x] **Step 1: Write the failing tests**

- `defaults: even gray, odd transparent` (index 0 → `Color(0xFFE5E7EB)`, index 1 → `Colors.transparent`).
- `overrides from theme params, other keys use defaults`.

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/crud_editor_listing_test.dart`
Expected: FAIL

- [x] **Step 3: Implement the three functions.** `_getListingThemeParams()` reads `appCallablesLocator.get<AppCallablesSuper>().getThemeParams()` and returns `defaultThemeParams` if the locator throws. In `_buildListItem`, set `ListTile.tileColor` and `ListTile.textColor` from `index`, and set the subtitle `TextStyle.color` from `listingRowSubtitleColor`. Keep `onTap` as it is.

- [x] **Step 4: Run all checks**

Run: `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`
Expected: only the existing `deprecated_member_use` infos; 0 format changes; all tests pass (94).

- [x] **Step 5: Commit**

```bash
git add genericsuite_flutter/lib/services/crud_editor.dart genericsuite_flutter/lib/services/crud_editor_listing.dart genericsuite_flutter/lib/services/theme_config_defaults.dart genericsuite_flutter/test/crud_editor_listing_test.dart genericsuite_flutter/test/theme_params_test.dart genericsuite_flutter/CHANGELOG.md
git commit -m "Add: colsForListingLine1 / colsForListingLine2 in the frontend JSON ... [GS-346]"
```

---

### Task 5: Documentation

**Files:**
- Modify: `genericsuite_flutter/CHANGELOG.md` (`[Unreleased]`: 2 "Added", 1 "Changed")
- Modify: `genericsuite-basecamp/mkdocs_root/en/Mobile-Development/index.md`
- Modify: `genericsuite-basecamp/mkdocs_root/es/Mobile-Development/index.md`

**Interfaces:**
- Consumes: key names and defaults from Tasks 1–4.

- [x] **Step 1: Add `#### Listing screen` under `### JSON-driven CRUD`** (es: `#### Pantalla de listado`). Include the key table, the JSON example (`users`, 2 + 2 columns → `John · Smith` / `john@mail.com · Yes`), the rules, the formatting table, a `getThemeParams()` override example and a `CrudEditor` props example.

- [x] **Step 2: Add the 6 keys to the `## Theming` table**, with a link to `#listing-screen`.

- [ ] **Step 3: Build the docs**

Run (from `genericsuite-basecamp`): `mkdocs build --strict`
Expected: no warnings. **Not done:** `mkdocs-material` is not installed in the local environment.

- [x] **Step 4: Commit**

```bash
git add mkdocs_root/en/Mobile-Development/index.md mkdocs_root/es/Mobile-Development/index.md
git commit -m "Add: Mobile \"Listing screen\" docs ... [GS-346]"
```

---

## Open Items

- No widget test covers `_buildListItem` / `_loadEditorConfig`. Only the pure functions are tested.
- The docs formatting table does not list `datetime-local` and `checkbox` (the code supports them).
- `mkdocs build --strict` must be run in an environment that has the docs dependencies.
