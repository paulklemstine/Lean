# Summary of changes for run f144d2cc-f064-497c-a687-9195664fa5ae
Created a new, fully proved Lean 4 development on BB84 quantum key distribution security, plus the required research notes.

## New file: `Catalog/Cryptography/QuantumSecurity/BB84Security.lean`
A self-contained `import Mathlib` file (namespace `BB84`) built on Mathlib's `Real.binEntropy` toolkit and conceptually bridged to the catalog's `Cryptography/LeftoverHash.lean`. It builds cleanly with **zero `sorry`** and the main results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Definitions: `H2` (base-2 binary entropy), `secureKeyRate Q = 1 - 2·H₂(Q)` (Shor–Preskill rate), and `eveAdvantage` (leftover-hash distinguishing advantage).

Theorems with complete proofs:
- `secureKeyRate_eq_zero_iff` — reduces the security boundary to `binEntropy Q = log 2 / 2`.
- `bb84_secureKeyRate_root_existsUnique` — existence and uniqueness of the QBER threshold `Q⋆ ∈ (0, 1/2)` (continuity + strict monotonicity + IVT).
- `bb84_threshold_bracket` — a certified rational sandwich `Q⋆ ∈ (1/16, 1/8) = (6.25%, 12.5%)`, containing the textbook ≈11%, using no floating-point `log` bound: the bracket lemmas (`binEntropy_inv8_gt`, `binEntropy_inv16_lt`) reduce, via the closed forms `binEntropy_inv8_eq`/`binEntropy_inv16_eq`, to the integer inequalities `7^7 < 2^20` and `2^56 < 15^15` decided by `norm_num`.
- `secureKeyRate_quarter_neg` — the intercept–resend attack (`Q = 1/4`) is always detectable (`R(1/4) < 0`).
- `privacy_amplification_decay` — the eavesdropper's advantage decays to 0 with the entropy gap.
- `mub_overlap_half` — the Pythagorean mutually-unbiased-basis overlap `cos²(π/4) = 1/2`.
Plus supporting closed-form/inequality lemmas (`binEntropy_quarter_eq`, `binEntropy_quarter_gt`, `eveAdvantage_eq_exp`).

The file includes the requested `-- !-- comment -- !--` proof sketches per theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

## New file: `Catalog/Cryptography/QuantumSecurity/FUTURE_DIRECTIONS.md`
A freeform narrative with a synthesis, a results-summary table, and 5 falsifiable research directions (rational-log squeeze to pin ≈11%; six-state protocol threshold ≈12.62%; explicit finite-key length; convexity/tangent-line robustness certificate; a Pythagorean information–disturbance QBER bound). Each direction contains a "The key insight is…" sentence and a "Why now?" justification, and cites the proven theorem names it extends.

Both files live in the project under `Catalog/Cryptography/QuantumSecurity/`, which is covered by the existing `Cryptography` build target.