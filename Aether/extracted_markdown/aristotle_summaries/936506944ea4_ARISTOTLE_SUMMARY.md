# Summary of changes for run 491cd63f-a3b2-47f4-ba42-9e93d6810020
Completed one research cycle on "The Unreasonable Effectiveness of 163" (Tropical catalog).

## Deliverables
- **`Catalog/Tropical/HeegnerOneSixtyThree.lean`** — a self-contained Lean 4 file (imports only Mathlib, compiles cleanly; verified axioms are limited to `propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler`).
- **`FUTURE_DIRECTIONS.md`** — with `## Synthesis`, `## Results Summary`, and 5 falsifiable research directions, each with Hypothesis / Test / "The key insight is…" / "Why now?" / If true / If false.

## Mathematical content
Rather than chase the out-of-reach analytic fact `e^(π√163) ≈ integer` or a full Stark–Heegner proof, I formalized its *elementary shadow* — the Rabinowitz phenomenon connecting Heegner numbers to Euler's prime-generating polynomials via `p ↦ 4p-1`.

Theorems proved (zero `sorry` on all main results):
- `euler41_prime_run`, `euler17_prime_run`, `euler11_prime_run`: the prime runs `x²+x+41`, `x²+x+17`, `x²+x+11` (the elementary fingerprints of the Heegner numbers 163, 67, 43).
- `poly_square_at_boundary` and `poly_not_prime_at_boundary`: a *general* boundary theorem — every generator `x²+x+c` equals the perfect square `c²` at `x=c-1`, hence is composite, capping every run at length `c-1`. This explains structurally why 41 (largest Euler lucky prime) gives the longest run ↔ 163 (largest Heegner number).
- `euler41_breaks_at_40`: Euler's run first fails at `x=40` with value `41²=1681`.
- `heegner_lucky_correspondence`: the bijection `p ↦ 4p-1` from Euler lucky primes onto the odd Heegner numbers; plus `oneSixtyThree_eq` (`4·41-1=163`).
- `heegner_max`, `heegner_card`, `starkHeegner_largest`: 163 is the maximum of the nine Heegner numbers.

Two deep results are recorded as honest, precisely-stated conjectures with `sorry` to seed the next cycle: `rabinowitz_biconditional` (full prime-run ⇔ class-number-one equivalence) and `ramanujan_near_integer` (the metric `10^{-6}` statement).

Lab Notebook blocks (Hypothesis / Result / Insight / Failure analysis) and per-theorem proof sketches are embedded in the file as `-- !--` comments.

Note: the file only imports Mathlib, so it was verified by compiling it directly; the catalog-wide build was not run because an unrelated pre-existing file referenced by the `Algebra` target is missing from the snapshot.