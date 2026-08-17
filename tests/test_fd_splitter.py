# tests/test_fd_splitter.py
"""Tests for the section-aware future-direction splitter."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'Aether'))

from fd_splitter import infer_domains_v2, classify_header, split_sections, extract_items, clean_title


class TestInferDomainsV2:
    """Fix A: domain-inference failure returns [] — no Bridges fallback."""

    def test_known_domain(self):
        result = infer_domains_v2("Prove a conjecture about Goldbach's weak form")
        assert "NumberTheory" in result or "Pythagorean" in result

    def test_no_match_returns_empty(self):
        """The root-cause bug: old code returned ['Bridges'] here."""
        result = infer_domains_v2("The quick brown fox jumps over the lazy dog")
        assert result == [], f"Expected empty list on no-match, got {result}"

    def test_two_domains_capped(self):
        result = infer_domains_v2(
            "tropical geometry meets quantum field theory and representation theory"
        )
        assert len(result) <= 2

    def test_empty_text(self):
        result = infer_domains_v2("")
        assert result == []


class TestClassifyHeader:
    def test_generic_direction_header(self):
        assert classify_header("Future Directions") == "directions"
        assert classify_header("Next Steps") == "directions"
        assert classify_header("What remains") == "directions"

    def test_hard_recap(self):
        assert classify_header("Summary of Results") == "recap"
        assert classify_header("Verdict") == "recap"
        assert classify_header("Established Results") == "recap"

    def test_direction_stem_only(self):
        assert classify_header("Natural next steps") == "directions"

    def test_recap_stem_only(self):
        assert classify_header("What was proved") == "recap"

    def test_ambiguous_proven_heavy(self):
        # "Open problems after what was established" → directions
        # ("open problems" is GENERIC_DIR_HEADERS, checked before ambiguity)
        assert classify_header("Open problems after what was established") == "directions"

    def test_ambiguous_lean_directions(self):
        # "What remains to prove" → directions (remain is dir stem, no proven-heavy)
        assert classify_header("What remains to prove") == "directions"


class TestCleanTitle:
    def test_none_input(self):
        assert clean_title(None) is None
    def test_empty(self):
        assert clean_title("") is None
    def test_generic_header_rejected(self):
        assert clean_title("Future Directions") is None
        assert clean_title("Next Steps") is None
    def test_recap_leadin_rejected(self):
        assert clean_title("Derived from the above results") is None
        assert clean_title("What was proved this cycle") is None
    def test_metadata_prefix_rejected(self):
        assert clean_title("Status. The algorithm converges") is None
        assert clean_title("Remark. The bound is tight") is None
    def test_bare_number_rejected(self):
        assert clean_title("42.") is None
    def test_short_lowercase_rejected(self):
        assert clean_title("horizontal cut") is None
    def test_valid_direction_kept(self):
        title = clean_title("Prove a generalization of the Riemann hypothesis")
        assert title is not None
    def test_leading_number_stripped(self):
        title = clean_title("1. Prove a conjecture about primes")
        assert title is not None
        assert title.startswith("Prove")
    def test_bold_markers_stripped(self):
        title = clean_title("**Uniformize the obstruction** to all n")
        assert title is not None
        assert "**" not in title
    def test_latex_rejected(self):
        assert clean_title("$\\sum_{n} a_n$ diverges") is None
    def test_sentence_tail_rejected(self):
        assert clean_title("that the bound holds for all n") is None
        assert clean_title("when A denotes the adjoint") is None
