# Summary of changes for run 57eb46ad-b070-4aa1-bb2a-ed615e9e6eb7
Delivered a self-contained Lean 4 development on Beal's conjecture plus a future-directions narrative, building on the project's `Pythagorean` catalog library.

**New Lean file:** `Catalog/Pythagorean/BealConjecture.lean` (compiles cleanly, 0 `sorry`, only standard axioms `propext, Classical.choice, Quot.sound`, plus `Lean.ofReduceBool, Lean.trustCompiler` for the one `native_decide` enumeration). It contains 10 fully-proved results, each with a `-- !-- ... -- !--` proof sketch, and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

Theorems proved:
- `beal_le_AB`, `beal_sub_AB` — the ℕ-subtraction engine (`A^x ≤ C^z`, `C^z − A^x = B^y`).
- `beal_prime_dvd_third_AB / AC / BC` — prime transfer: a prime dividing two terms divides the third. Sharpened to *minimal* hypotheses — each needs only the two exponents of the terms the prime divides, freeing the target exponent (`AB` frees `z`, `AC` frees `y`, `BC` frees `x`).
- `beal_pairwise_coprime` — on any solution, `gcd(A,B,C)=1` forces pairwise coprimality.
- `beal_full_iff_coprime` — the full conjecture `BealFull` is logically equivalent to its pairwise-coprime restriction `BealCoprime` (both stated as `Prop` definitions, so the open problem is recorded without any `sorry`).
- `beal_verified_box` — exhaustive `native_decide` check: no counterexample for `A,B,C ≤ 50`, exponents `{3,4,5}`.
- `beal_box_nonvacuous` — the box contains a genuine non-coprime solution `3³ + 6³ = 3⁵`.
- `beal_equal_bases` — equal bases `A = B > 1` force `gcd > 1` (needs only `x,y ≥ 1`).
- `beal_cubes` — the cube case `x=y=z=3` has no positive solution, via Mathlib's `fermatLastTheoremThree`.

**`FUTURE_DIRECTIONS.md`** — synthesis, results summary, and 5 falsifiable research directions (not-coprime descent, modular obstruction sieve, the `(3,n)` Fermat-type slice, a radical/`abc` "defect" invariant, and pairwise-coprime infinite descent), each with a "The key insight is..." statement and a "Why now?" justification, all referencing the proven theorems by name.

All results were verified via `lake build` of the `Pythagorean.BealConjecture` module and an axiom audit.