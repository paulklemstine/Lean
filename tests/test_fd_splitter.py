# tests/test_fd_splitter.py
"""Tests for the section-aware future-direction splitter."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'Aether'))

from fd_splitter import infer_domains_v2, classify_header, split_sections, clean_title


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
        # Sentence-starter fragments are rejected; technical lowercase noun
        # phrases ("p-adic dynamics", "horizontal cut") are legitimately titles.
        assert clean_title("we proved the theorem") is None
        assert clean_title("this approach is nice") is None
        assert clean_title("horizontal cut") is not None
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



class TestSplitDirectionsFromText:
    """One test per format class in the spec."""

    def _mgr(self):
        import tempfile
        from pathlib import Path
        from research_memory import FutureDirectionsManager
        tmpdir = tempfile.mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        mgr._save = lambda: None  # skip disk writes
        return mgr

    def test_structured(self):
        """### Direction N: sections with **Field** entries."""
        from fd_splitter import split_directions_from_text
        text = """### Direction 1: Uniformize the obstruction
**Conjecture**: The obstruction class lives in H^2.
**Test**: Compute for small groups.
**Impact**: Resolves the suspension tower problem.

### Direction 2: Extend the tropical lifting
**Conjecture**: Every tropical variety lifts to a higher-dimensional ambient space.
**Test**: Check dimension 3 and verify the lifting preserves the tropical structure.
**Impact**: Provides a new classification tool for tropical geometry problems.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added >= 2, f"Expected >=2, got {added}"

    def test_numbered_bold(self):
        """1. **Title** format."""
        from fd_splitter import split_directions_from_text
        text = """1. **Prove a generalization of Goldbach** for sparse sequences.
The current result only applies to dense sequences. Extending to sparse
sequences would resolve a long-standing open problem in analytic number
theory and connect to recent work on additive combinatorics.

2. **Classify all rank-3 matroids** over finite fields.
The classification of rank-2 matroids is complete but rank-3 remains open.
Recent computational evidence suggests a finite classification is possible.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added >= 2

    def test_bullets(self):
        """* and - bullet items."""
        from fd_splitter import split_directions_from_text
        text = """Future directions:

* Prove the uniform bound for all Lp norms by extending the current
interpolation argument to the non-commutative setting. This would unify
several scattered results in harmonic analysis and provide sharp constants
for the operator inequality.

- Construct explicit examples of the failure of the tropical lifting
conjecture in dimension 4. The dimension-3 case was settled by Zhang but
the higher-dimensional picture remains unclear and computationally
challenging.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added >= 2

    def test_plain_numbered(self):
        """Plain numbered list: 1. Title. 2. Title. (no bold)."""
        from fd_splitter import split_directions_from_text
        text = """1. Prove a generalization of Goldbach for sparse sequences.
The current result only applies to dense sequences. Extending to sparse
sequences would resolve a long-standing open problem in analytic number
theory and connect to recent work on additive combinatorics.

2. Classify all rank-3 matroids over finite fields.
The classification of rank-2 matroids is complete but rank-3 remains open.
Recent computational evidence suggests a finite classification is possible.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added >= 2

    def test_recap_stripped(self):
        """Recap sections are dropped; directions are kept."""
        from fd_splitter import split_directions_from_text
        text = """## Summary of Results
We proved the main theorem and established all lemmas.

## Future Directions
* Extend the proof to the non-abelian case. This would generalize
the main result to a much broader class of groups and resolve the
open problem posed by Thompson in 2019.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added >= 1, "Should extract direction from Future Directions section"

    def test_zero_add_recap_only(self):
        """Pure-recap blob yields 0 directions — defensible."""
        from fd_splitter import split_directions_from_text
        text = """## Summary
We proved the main theorem about Goldbach.

## Established Results
All lemmas hold and the conjecture is settled.
"""
        mgr = self._mgr()
        added, _ = split_directions_from_text(mgr, text, "test", "fd")
        assert added == 0, f"Pure recap should add 0, got {added}"


class TestWriteSideSplit:
    """Section 2: merged-one injection now splits before storing."""

    def test_split_before_store(self):
        """A multi-direction blob should produce multiple pool entries."""
        from fd_splitter import split_directions_from_text
        from research_memory import FutureDirectionsManager
        import tempfile
        from pathlib import Path

        blob = """## Synthesis
This cycle explored tropical geometry and quantum computing.

## Future Directions
* Prove the tropical lifting conjecture for all toric varieties. The
dimension-3 case was settled but the general case requires new techniques
from tropical intersection theory and stacky fans.

* Extend the quantum error-correcting code framework to handle
non-stabilizer noise models. Current codes assume depolarizing noise
but realistic hardware exhibits biased noise.
"""
        tmpdir = tempfile.mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        mgr._save = lambda: None
        added, _ = split_directions_from_text(mgr, blob, "test_cycle", "fd")
        assert added >= 2, f"Expected >=2 from merged blob, got {added}"
        assert all(d.source_exp_id == "test_cycle" for d in mgr._directions)


# ── 2026-08-21 splitter overhaul: regression tests for the audited bugs ──

import json
import tempfile
from pathlib import Path


class _FakeMgr:
    """Minimal manager stand-in exercising the real gates."""

    def __init__(self):
        from research_memory import FutureDirectionsManager
        self._mgr = FutureDirectionsManager(Path(tempfile.mkdtemp()))
        self.added = []

    def _next_id(self):
        return f"fd_t{len(self.added):04d}"

    def _is_quality_direction(self, fd):
        return self._mgr._is_quality_direction(fd)

    def _compute_quality_score(self, fd):
        return 0.6

    def _extract_bold_field(self, body, name):
        import re as _re
        m = _re.search(rf'\*\*{name}\*\*:?\s*(.+)', body)
        return m.group(1).strip() if m else None

    def add_direction(self, fd):
        from research_memory import FutureDirectionsManager
        ok = self._mgr.add_direction(fd)
        if ok:
            self.added.append(fd)
        return ok

    @property
    def directions(self):
        return self._mgr._directions


def _split(text):
    from fd_splitter import split_directions_from_text
    mgr = _FakeMgr()
    count, _ = split_directions_from_text(mgr, text, source_exp_id="test")
    return count, [d.title for d in mgr.added], mgr


class TestBulletRegexFix:
    def test_bold_runins_no_phantom_bullets(self):
        """A document with bold run-ins but NO real bullets must not be
        hijacked by the bullets stage (was: '**Conjecture.** text' matched)."""
        text = (
            "# Future Directions\n\n"
            "## 1. Spectral gap for Pell spines\n\n"
            "**Conjecture.** The silver-ratio potential has a spectral gap.\n\n"
            "**Why now?** The machinery exists.\n\n"
            "## 2. p-adic Berggren dynamics\n\n"
            "**Conjecture.** The moves contract p-adically.\n"
        )
        count, titles, _ = _split(text)
        assert count >= 2
        for t in titles:
            assert not t.startswith("**"), t
            assert "Conjecture." not in t[:20] or "spectral" in t.lower(), t


class TestCleanedTitlesStored:
    def test_headers_path_strips_numbering(self):
        text = (
            "## 1. Certified finite-prefix null tests for pi\n\n"
            "We will formalize a null test. The approach: prove the theorem "
            "by constructing the finite prefix and extending it to all reals. "
            "This is an open direction worth pursuing next.\n"
        )
        count, titles, _ = _split(text)
        assert count == 1
        assert not titles[0].startswith("1."), titles

    def test_clean_title_v2_rejections(self):
        from fd_splitter import clean_title
        # narration fragments
        assert clean_title("The file `Catalog/X.lean` now consists of ten files") is None
        assert clean_title("The following are concrete conjectures") is None
        assert clean_title("This work formalizes the notion") is None
        # past-tense recaps
        assert clean_title("The prime theorem is established for all n") is None
        assert clean_title("Qualitative synchronized stabilization has been proved") is None
        # multi-sentence
        assert clean_title("First idea here. Second sentence follows") is None
        # over-long
        assert clean_title("x" * 130) is None
        # good noun phrases still pass
        assert clean_title("Silver-Ratio Spectral Gap for Pell Spines") is not None
        assert clean_title("p-adic Dynamics of the Berggren Moves") is not None


class TestRecapHandling:
    def test_synthesis_section_stripped(self):
        from fd_splitter import classify_header
        assert classify_header("Synthesis") == "recap"
        assert classify_header("Conclusions") == "recap"

    def test_mixed_recap_header_keeps_items(self):
        """A header containing a recap stem must NOT nuke real directions
        inside the section (was: 'RESULT' in header deleted 4954 chars)."""
        text = (
            "# Results and Future Directions\n\n"
            "1. **Pell spine rigidity** Extend the extremal rigidity to "
            "higher spines. Prove the conjecture for all n and formalize "
            "the growth bound in Lean.\n\n"
            "2. **Totient arm classification** Classify the star arms by "
            "Euler's totient. Show the count matches phi and generalize it.\n"
        )
        count, titles, _ = _split(text)
        assert count >= 2, f"mixed-header items were nuked: {titles}"


class TestJSONFirstBranch:
    def test_json_block_parsed(self):
        directions = [
            {"title": "Silver-Ratio Spectral Gap",
             "domain": "NumberTheory",
             "description": "Prove the spectral gap for the silver potential along Pell spines.",
             "conjecture": "The potential has a uniform gap.",
             "test": "Formalize the bound in Lean.",
             "if_true": "Growth exponent is exact.",
             "if_false": "The spine is not extremal.",
             "proof_strategy": "Window lemma + monotonicity.",
             "catalog_references": ["Catalog.Pythagorean.BerggrenTrees"]},
            {"title": "p-adic Contraction of Berggren Moves",
             "domain": "NumberTheory",
             "description": "Show the hyperbolic move contracts p-adically on the null cone.",
             "conjecture": "Contraction holds for all odd p.",
             "test": "Compute orbits mod p^k.",
             "if_true": "p-adic fractal boundary.",
             "if_false": "Orbits are dense.",
             "proof_strategy": "Spectral classification mod p.",
             "catalog_references": []},
        ]
        text = (
            "## Synthesis\n\nThis cycle went well.\n\n"
            "## Future Directions\n\nProse directions here that would "
            "otherwise feed the low paths and could produce junk titles.\n\n"
            "```json\n" + json.dumps(directions) + "\n```\n"
        )
        count, titles, mgr = _split(text)
        assert count == 2, titles
        assert titles[0] == "Silver-Ratio Spectral Gap"
        d0 = mgr.added[0]
        assert d0.proof_strategy == "Window lemma + monotonicity."
        assert d0.catalog_references == ["Catalog.Pythagorean.BerggrenTrees"]
        assert d0.priority_score >= 0.55  # high-fidelity floor

    def test_no_json_falls_back_to_cascade(self):
        text = (
            "# Future Directions\n\n"
            "1. **Plain numbered path** Prove the theorem by extending the "
            "core result and formalizing the general case in Lean.\n"
        )
        count, titles, _ = _split(text)
        assert count == 1


class TestNumberedBoldDescriptionTruncation:
    def test_last_item_does_not_swallow_document(self):
        text = (
            "## Future Directions\n\n"
            "1. **First direction** Prove the first conjecture by extending "
            "the core lemma and formalizing it.\n\n"
            "2. **Second direction** Show the general case holds and "
            "formalize the bound.\n\n"
            "## Synthesis\n\nThis cycle deepened the theory considerably "
            "and we proved many theorems.\n"
        )
        count, titles, mgr = _split(text)
        assert count >= 2
        last = mgr.added[-1]
        assert "Synthesis" not in last.description
        assert "deepened the theory" not in last.description


class TestAddDirectionReturnsBool:
    def test_true_on_insert_false_on_dedup(self):
        from research_memory import FutureDirectionsManager, FutureDirection
        mgr = FutureDirectionsManager(Path(tempfile.mkdtemp()))
        fd = FutureDirection(id="fd_a1", title="Unique Direction Alpha",
                             description="Prove the theorem about alpha.",
                             source_exp_id="t", source_path="t")
        assert mgr.add_direction(fd) is True
        fd2 = FutureDirection(id="fd_a2", title="Unique Direction Alpha",
                              description="Prove the theorem about alpha again.",
                              source_exp_id="t", source_path="t")
        assert mgr.add_direction(fd2) is False

    def test_title_overlap_dedup(self):
        from research_memory import FutureDirectionsManager, FutureDirection
        mgr = FutureDirectionsManager(Path(tempfile.mkdtemp()))
        fd = FutureDirection(id="fd_b1", title="Derived from the analysis of cycles",
                             description="Prove the alpha bound.",
                             source_exp_id="t", source_path="t")
        assert mgr.add_direction(fd) is True
        fd2 = FutureDirection(id="fd_b2", title="Derived from the analysis of cycles 2",
                              description="Prove the beta bound.",
                              source_exp_id="t", source_path="t")
        assert mgr.add_direction(fd2) is False, "near-identical titles must dedup"


class TestQualityGateSignals:
    def test_terse_conjecture_passes(self):
        from research_memory import FutureDirectionsManager, FutureDirection
        mgr = FutureDirectionsManager(Path(tempfile.mkdtemp()))
        fd = FutureDirection(id="fd_c1", title="Zeta Function Pole Count",
                             description="Conjecture: the pole count is exactly two.",
                             source_exp_id="t", source_path="t", domains=["NumberTheory"])
        assert mgr._is_quality_direction(fd) is True

    def test_padded_no_signal_fails(self):
        from research_memory import FutureDirectionsManager, FutureDirection
        mgr = FutureDirectionsManager(Path(tempfile.mkdtemp()))
        fd = FutureDirection(id="fd_c2", title="Cycle Recap Notes",
                             description=("This cycle deepened the theory. " * 10),
                             source_exp_id="t", source_path="t", domains=["Algebra"])
        assert mgr._is_quality_direction(fd) is False


class TestIsValidParentTitle:
    def test_long_github_issue_titles_pass(self):
        from fd_splitter import is_valid_parent_title
        assert is_valid_parent_title(
            "FACT round-85 #1 — SPIKE-ORIGIN-RESOLVED (exp 589 FINAL): H1 true at z=+8.02 across 3 datasets, zero baseline overlap; mechanism is leading-exponent crossover at gamma=1.38"
        ) is True
        assert is_valid_parent_title(
            "FACT round-87 #2 — U065-FRESH-SEED-GATE (exp 592 FINAL): GATE-1 PASS at 80% power on 6 new seeds; R^2=0.91 effectivity replicated, no degradation"
        ) is True
        assert is_valid_parent_title(
            "NET-94 THE-ROLE-SPLIT-CONFIRMED: K8/V4 cache is quality-free (+0.14%) at ~6 avg bits — the serving default; key-side cliff is a two-stage fall (free @8b, +868% @5b, +38,000% @4b) while values stay free to raw 4-bit"
        ) is True

    def test_standard_math_titles_pass(self):
        from fd_splitter import is_valid_parent_title
        assert is_valid_parent_title("Composition of PCP locality with commitment hiding") is True
        assert is_valid_parent_title("p-adic Dynamics of the Berggren Moves") is True
        assert is_valid_parent_title("Score variance controls drift") is True

    def test_junk_fragments_rejected(self):
        from fd_splitter import is_valid_parent_title
        assert is_valid_parent_title("is a finitely supported a : ℕ → ℤ with") is False
        assert is_valid_parent_title("which was proved in section 3") is False
        assert is_valid_parent_title("the file Catalog/Foo.lean consists of ten theorems") is False
        assert is_valid_parent_title("Future Directions") is False
        assert is_valid_parent_title("Next Steps") is False
        assert is_valid_parent_title("Status:") is False
        assert is_valid_parent_title("1.") is False
        assert is_valid_parent_title("***") is False
        assert is_valid_parent_title("(123)") is False
        assert is_valid_parent_title("with equality when x = 0") is False
        assert is_valid_parent_title("") is False
        assert is_valid_parent_title(None) is False
