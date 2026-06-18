# Summary of changes for run 9f1629bb-1c33-40ec-a12b-e109961461cd
Completed a new research cycle on the cryptographic hardness lattice (OWF → PRG → PRF → ENC), delivering one new Lean file and a research-directions document.

## New Lean file: Catalog/Cryptography/GGMSecurity.lean
Formalizes the deterministic combinatorial skeleton of the Goldreich–Goldwasser–Micali (GGM) PRG→PRF construction. A length-doubling PRG is abstracted as a `LengthDoublingExpander` structure (both child maps injective, ranges disjoint — the information-theoretic shadow of pseudorandom independence). Four theorems, all proved with **0 sorry** and depending only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`:

1. `ggm_injOn_length` — GGM evaluation is injective on equal-length input paths (the deterministic core of GGM-PRF security).
2. `ggm_image_card` — the family realizes all `2^n` outputs on n-bit inputs: the image has cardinality exactly `2^n` (no entropy loss). This upgrades the catalog's `ggm_image_bounded` (≤ |α|) to an attained count.
3. `prf_domain_lower_bound` — consequently `2^n ≤ |α|`, the matching exponential-codomain lower bound.
4. `ggm_bijOn_length` — the keyed family is a perfect bijection onto its range.

The module also includes the required Lab Notebook block (Hypothesis/Result/Insight/Failure analysis), per-theorem `-- !-- ... -- !--` proof sketches, and a "Catalog synthesis" docstring explicitly citing and building on existing results: `GGMTree`/`ggm_image_bounded`/`LossyFunction` from `Cryptography.HardnessHierarchy` and `exact_inversions_le_image`/`rank_injective` from `Cryptography.OneWayHierarchy`. The unifying theme is that both edges of the hierarchy are governed by one cardinality invariant: inversion is capped above by |Im f|, expansion forced below by 2^n.

(Note: the GGM evaluator is reproduced locally as `ggmTree` so the file is self-contained on Mathlib while still strengthening the catalog's `GGMTree` bound.)

## FUTURE_DIRECTIONS.md
A narrative document with a Synthesis section, a results-summary table, and five falsifiable research directions (expander composition climbing the hierarchy multiplicatively; necessity/tightness of the disjoint-range hypothesis; a quantitative inversion×expansion duality bridge; linear hybrid-distance vs. exponential entropy in GGM depth; and an ℕ-graded extension of the `CryptoLevel` order-isomorphism). Each direction includes a "The key insight is..." sentence and a "Why now?" justification grounded in specific catalog lemmas.

Verification: `Cryptography.GGMSecurity` builds successfully with no warnings, no sorries, and only standard axioms.