#!/usr/bin/env python3
"""
phase-2-validate.py — Validate codebase-health-audit Phase 2 CSV integrity.

Runs 6 checks against the audit's Phase 2 findings CSV. Exits 0 on PASS;
non-zero with a row-by-row report on any FAIL. This script is invoked as a
non-bypassable gate before Phase 3 generation per
protocols/codebase-health-audit.md.

Checks:
  1. Row column-count: every row has the expected number of columns.
  2. Decision-value canonical: every decision is one of {fix-now, fix-later,
     defer, debunk, scope-extend}.
  3. fix-now has fix_session_id: every row with decision=fix-now has a
     non-empty fix_session_id column.
  4. FIX-NN-kebab-name format: every fix_session_id matches FIX-NN-<kebab>.
  5. Row integrity (1): finding_id is non-empty and unique across rows.
  6. Row integrity (2): mechanism_signature column is non-empty for any
     row with decision=fix-now or fix-later (per the fingerprint-before-
     behavior-change pattern).

This script does NOT validate safety tags. The 4-tag safety taxonomy was
empirically rejected per synthesis-2026-04-26 Phase A pushback round 2;
see protocols/codebase-health-audit.md §2.9 "Anti-pattern (do not reinvent)"
for the rationale and the canonical list of rejected tokens.

Origin: synthesis-2026-04-26.
"""

import csv
import re
import sys
from pathlib import Path

EXPECTED_COLUMNS = [
    "finding_id",
    "file_path",
    "issue_summary",
    "mechanism_signature",
    "decision",
    "fix_session_id",
    "rationale",
]
ALLOWED_DECISIONS = {"fix-now", "fix-later", "defer", "debunk", "scope-extend"}
FIX_SESSION_ID_PATTERN = re.compile(r"^FIX-\d+-[a-z0-9]+(?:-[a-z0-9]+)*$")


def validate(csv_path: Path) -> list[str]:
    """Run all 6 checks. Return list of error messages (empty if PASS)."""
    errors = []
    seen_ids = set()
    with csv_path.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        actual_columns = reader.fieldnames or []
        if actual_columns != EXPECTED_COLUMNS:
            errors.append(
                f"Column-count check: header is {actual_columns!r}, "
                f"expected {EXPECTED_COLUMNS!r}"
            )
            return errors  # cannot proceed with row-level checks on bad header
        for row_num, row in enumerate(reader, start=2):
            # Check 1: row column-count (DictReader handles this implicitly,
            # but verify no row has missing cells)
            if any(row.get(col) is None for col in EXPECTED_COLUMNS):
                errors.append(f"Row {row_num}: missing column cells")
                continue
            # Check 5: finding_id non-empty + unique
            finding_id = (row.get("finding_id") or "").strip()
            if not finding_id:
                errors.append(f"Row {row_num}: finding_id is empty")
            elif finding_id in seen_ids:
                errors.append(f"Row {row_num}: finding_id {finding_id!r} duplicated")
            else:
                seen_ids.add(finding_id)
            # Check 2: decision is canonical
            decision = (row.get("decision") or "").strip()
            if decision not in ALLOWED_DECISIONS:
                errors.append(
                    f"Row {row_num} ({finding_id}): decision {decision!r} "
                    f"is not one of {sorted(ALLOWED_DECISIONS)}"
                )
            # Check 3: fix-now has fix_session_id
            fix_session_id = (row.get("fix_session_id") or "").strip()
            if decision == "fix-now" and not fix_session_id:
                errors.append(
                    f"Row {row_num} ({finding_id}): decision is fix-now "
                    f"but fix_session_id is empty"
                )
            # Check 4: FIX-NN-kebab format (only for non-empty fix_session_id)
            if fix_session_id and not FIX_SESSION_ID_PATTERN.match(fix_session_id):
                errors.append(
                    f"Row {row_num} ({finding_id}): fix_session_id "
                    f"{fix_session_id!r} does not match FIX-NN-<kebab> format"
                )
            # Check 6: mechanism_signature for fix-now/fix-later
            mechanism = (row.get("mechanism_signature") or "").strip()
            if decision in ("fix-now", "fix-later") and not mechanism:
                errors.append(
                    f"Row {row_num} ({finding_id}): decision is {decision} "
                    f"but mechanism_signature is empty (per "
                    f"fingerprint-before-behavior-change pattern)"
                )
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <phase-2-findings.csv>", file=sys.stderr)
        return 2
    csv_path = Path(sys.argv[1])
    if not csv_path.exists():
        print(f"ERROR: CSV file not found: {csv_path}", file=sys.stderr)
        return 2
    errors = validate(csv_path)
    if errors:
        print(f"FAIL: {len(errors)} validation error(s) in {csv_path}:")
        for err in errors:
            print(f"  - {err}")
        return 1
    print(f"PASS: {csv_path} validates clean ({len(EXPECTED_COLUMNS)} columns, all 6 checks).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
