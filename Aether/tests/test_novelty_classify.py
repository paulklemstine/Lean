"""Tests for _classify_theorem_novelty after SQLite TheoremDatabase removal.

Every theorem counts as "new"; disproofs are detected by keyword. The dict
shape is preserved for downstream callers.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _extractor():
    from knowledge_extractor import KnowledgeExtractor
    ext = KnowledgeExtractor.__new__(KnowledgeExtractor)
    # No theorem_db attribute anymore (SQLite index removed).
    return ext


def test_no_db_attribute_present():
    ext = _extractor()
    assert not hasattr(ext, "theorem_db") or ext.__dict__.get("theorem_db") is None


def test_all_new_no_disproofs():
    ext = _extractor()
    lean = "theorem foo : True := trivial\ntheorem bar : 1 = 1 := rfl\n"
    c = ext._classify_theorem_novelty(lean, [])
    assert c["new"] == 2
    assert c["disproof"] == 0
    assert c["duplicate"] == 0 and c["strengthening"] == 0 and c["unknown"] == 0


def test_disproof_detected_by_keyword():
    ext = _extractor()
    lean = "theorem no_such_thing : not exists x, x = x := by sorry\ntheorem real_one : True := trivial\n"
    c = ext._classify_theorem_novelty(lean, [])
    assert c["disproof"] == 1
    assert c["new"] == 1


def test_counterexample_classified_as_disproof():
    ext = _extractor()
    lean = "theorem contra : False := by counterexample\n"
    c = ext._classify_theorem_novelty(lean, [])
    assert c["disproof"] == 1
    assert c["new"] == 0


def test_dict_shape_preserved():
    ext = _extractor()
    c = ext._classify_theorem_novelty("theorem t : True := trivial\n", [])
    assert set(c.keys()) == {"new", "strengthening", "duplicate", "disproof", "unknown"}