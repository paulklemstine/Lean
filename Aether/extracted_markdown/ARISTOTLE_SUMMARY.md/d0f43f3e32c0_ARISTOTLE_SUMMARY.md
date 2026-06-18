# Summary of changes for run bd515407-6711-41cc-9316-a0903962b71d
Delivered a self-contained, sorry-free Lean 4 development on **Fermat near-misses**, plus a research-direction document.

## Deliverables

**1. Lean file — `Catalog/Pythagorean/FermatNearMisses.lean`** (10 theorems, 0 `sorry`, builds cleanly; all main results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`). Placed in the `Pythagorean` library — the catalog's buildable home for sums-of-powers theory, next to `TaxicabNumbers.lean` — since `Applications` is not a build target in the project's lakefile. It was verified with `lake build Pythagorean.FermatNearMisses`.

Core objects: `defect n a b c = aⁿ+bⁿ−cⁿ`, the genuine-near-miss predicate `IsNearMiss`, and the `relativeDefect = |defect|/cⁿ`.

Theorems proved:
- `defect_zero_iff` — defect = 0 is exactly the Fermat equation.
- `defect_scale` — the absolute defect carries the weight-n character: `defect n (ta)(tb)(tc) = tⁿ·defect n a b c`.
- `trivial_defect_one` — the diagonal family `(a,1,a)` has defect exactly 1 for *every* exponent.
- `trivial_near_miss_arbitrarily_large` — defect-1 near-misses exist with arbitrarily large entries, for every n.
- `relative_defect_scale_invariant` — the relative defect is the scale invariant of the action `(a,b,c)↦(ta,tb,tc)`.
- `trivial_relative_superexp_decay` — the relative defect of `(a,1,a)` decays super-exponentially, `≤ (1/2)ⁿ` for a ≥ 2.
- `famous_cube_near_miss` — `6³+8³ = 9³−1` is a genuine nontrivial defect-1 near-miss.
- `cube_near_miss_family` — an infinite family of nontrivial cube near-misses (all entries > 1).
- `no_exact_cube_solution` — no positive triple has defect 0 at n=3 (via Mathlib's `fermatLastTheoremThree`).
- `cube_defect_one_is_optimal` — combines the two previous: gap ±1 is attained but gap 0 is impossible for cubes.

The file also includes computational `#eval`/`decide` verification (`defectN`), per-theorem proof-sketch comment blocks in `-- !-- ... -- !--` form, and a Lab Notebook block (Hypothesis / Result / Insight / Failure analysis).

**Catalog synthesis:** extends the exact sum-of-cubes theory of `Pythagorean/TaxicabNumbers.lean` to the approximate regime, and bridges to `MachineLearning/ABCTriple.lean` by exhibiting near-misses as additive perturbations `aⁿ+bⁿ=cⁿ+d` — the abc-controlled regime. The central finding is a clean dichotomy: the *absolute* defect transforms by `t↦tⁿ` (so bounded absolute defects are sporadic, non-scalable accidents), while the *relative* defect is scale-invariant (so any bounded-relative-defect seed yields an infinite family), and along the diagonal family relative quality collapses super-exponentially in the exponent.

**2. `FUTURE_DIRECTIONS.md`** — a narrative synthesis, a results table, and 5 falsifiable conjectures (Super-Miss conjecture; optimal gaps for higher exponents conditional on FLT; three-term Catalan rigidity; effective-abc ⇒ near-miss density bounds; relative defect as a projective height), each with a "The key insight is…" sentence and a "Why now?" justification.