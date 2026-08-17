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


class TestSplitSections:
    def test_no_headers(self):
        text = "Just some plain text with no headers at all."
        result = split_sections(text)
        assert len(result) == 1
        assert result[0] == ("", "", text)

    def test_with_headers(self):
        text = "# Intro\nSome intro text.\n## Details\nMore details here.\n"
        result = split_sections(text)
        assert len(result) == 2
        assert result[0][0] == 1
        assert result[0][1] == "Intro"
        assert "Some intro text." in result[0][2]
        assert result[1][0] == 2
        assert result[1][1] == "Details"
        assert "More details here." in result[1][2]

    def test_leading_text_before_first_header(self):
        text = " preamble text\n# First Section\nBody here.\n"
        result = split_sections(text)
        assert len(result) == 2
        assert result[0] == ("", "", " preamble text\n")
        assert result[1][0] == 1
        assert result[1][1] == "First Section"


class TestExtractItems:
    def test_numbered_bold(self):
        body = (
            "1. **Prove Goldbach**\n"
            "A detailed investigation of the Goldbach conjecture for all even numbers "
            "greater than four, using analytic methods and sieve theory.\n\n"
            "2. **Twin Prime**\n"
            "Extend the bounded gaps result for twin primes to arbitrary admissible "
            "patterns using the Maynard-Tao sieve framework.\n"
        )
        items = extract_items(body)
        assert len(items) == 2
        assert items[0][0] == "Prove Goldbach"
        assert items[1][0] == "Twin Prime"

    def test_bullets(self):
        body = "- Extend the collatz conjecture to all even numbers with a rigorous bound\nthat is longer than eighty characters to pass the minimum length check\n\n- Study tropical methods for number theory applications\n"
        items = extract_items(body)
        assert len(items) >= 1
        assert any("collatz" in t.lower() for t, _ in items)

    def test_subheaders(self):
        body = "## Prove something new\n\nWe will prove a new theorem about the Riemann zeta function\nthat extends existing results and opens new directions for future work\nin analytic number theory.\n"
        items = extract_items(body)
        assert len(items) == 1
        assert "Prove something new" in items[0][0]

    def test_empty_body(self):
        items = extract_items("")
        assert items == []
