import pytest
import re

def strip_lean_comments(content: str) -> str:
    """Helper representing the comment stripping logic in _result_looks_truncated."""
    code_only = re.sub(r'/-\s*[\s\S]*?-\/', '', content)
    code_only = re.sub(r'--.*$', '', code_only, flags=re.MULTILINE)
    return code_only

def is_truncated_check(content: str) -> bool:
    """Replicates the truncation decision logic."""
    if not content.strip():
        return False
    code_only = strip_lean_comments(content)
    if re.findall(r'\bsorry\b', code_only):
        return True
    if content.count("/-") > content.count("-/"):
        return True
    lines = [l for l in code_only.splitlines() if l.strip()]
    if lines:
        last = lines[-1].strip()
        if (re.match(r'^(theorem|lemma|def|structure|instance|abbrev)\b', last)
                and ':=' not in last and 'sorry' not in last
                and not last.endswith(('.', ':'))):
            return True
    return False

def test_sorry_in_line_comment():
    content = """
import Mathlib

-- Note: we originally tried sorry here, but proved it below.
theorem add_comm_test (a b : ℕ) : a + b = b + a := by
  omega
"""
    assert is_truncated_check(content) is False

def test_sorry_in_block_comment():
    content = """
/-
  Future work:
  Can we remove the sorry from the classical version?
-/
theorem mult_zero (n : ℕ) : n * 0 = 0 := by
  simp
"""
    assert is_truncated_check(content) is False

def test_active_sorry():
    content = """
theorem open_problem (n : ℕ) : n + 1 = 1 + n := by
  sorry
"""
    assert is_truncated_check(content) is True

def test_unclosed_block_comment():
    content = """
/-
  Incomplete docstring without closing tag
theorem foo : True := trivial
"""
    assert is_truncated_check(content) is True

def test_cutoff_declaration():
    content = """
theorem incomplete_header (x : ℕ) : x = x
"""
    assert is_truncated_check(content) is True
