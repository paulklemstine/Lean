# Summary of changes for run 5f2b81b7-929e-4fd8-a7e8-4d3c6ecda601
Produced a self-contained Lean research file plus research notes on Beal's Conjecture.

## New Lean file: `Catalog/Pythagorean/BealConjecture.lean`
(placed in the buildable `Pythagorean` library — Beal generalizes the Pythagorean/Fermat equation, and the file cross-references that corpus). It builds cleanly under the catalog project; all main results are `sorry`-free and use only allowed axioms (`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` for the computational theorem).

### Theorem declarations (Step 1 protocol)
1. `beal_prime_dvd_third_AB` — a prime dividing A and B divides C — **proved** (needs x,y≥1).
2. `beal_prime_dvd_third_AC` — a prime dividing A and C divides B — **proved**; refactoring showed it needs only x,z≥1 (y free).
3. `beal_prime_dvd_third_BC` — symmetric transfer — **proved**; needs only y,z≥1 (x free).
4. `beal_pairwise_coprime` — gcd(A,B,C)=1 on a solution forces pairwise coprimality — **proved** (the standard reduction).
5. `beal_full_iff_coprime` — Beal's conjecture is logically equivalent to its pairwise-coprime restriction — **proved**.
6. `beal_verified_box` — computational verification: no counterexample for A,B,C≤100, exponents {3,4,5}; the box contains genuine non-coprime solutions (e.g. 3³+6³=3⁵) — **proved**.
7. `beal_equal_bases` — A=B>1 forces gcd>1 with no exponent restriction — **proved** (cheapest non-vacuous slice).
8. `beal_cubes` — the x=y=z=3 case, via Mathlib's `fermatLastTheoremThree` — **proved**.
9. `beal_conjecture` (`BealFull`) — the full open problem — stated as a **conjecture** (`sorry`).
10. `beal_exponent_three_bounded` — one exponent 3, others ≤5 (Darmon–Granville range) — stated as a **conjecture** (`sorry`).

The only two `sorry`s in the file are exactly these two explicitly-declared open conjectures.

### Notes (Step 6 deliverables)
- Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a brief `-- !--` proof sketch.
- `FUTURE_DIRECTIONS.md` (repo root) contains the required `## Synthesis`, `## Results Summary`, and five falsifiable `## Research Directions`, each with a "The key insight is..." sentence and a "Why now?" justification, building on the cycle's reduction theorem.

### Critique / generalization (Steps 3 & 7)
The minimal-hypothesis analysis of the prime-transfer lemmas pins the exact boundary (each fails if its retained exponent positivity is dropped, e.g. AC fails at x=0 via 3⁰+2¹=3¹). The best theorem, `beal_full_iff_coprime`, is generalized in Direction 1 (replace A=B by "A,B not coprime") and Direction 5 (infinite-descent skeleton on the now-canonical pairwise-coprime target).

Two harmless linter notes remain (unused `hC`, `hz` on the `beal_exponent_three_bounded` conjecture) — these are faithful hypotheses of the conjecture statement and appear unused only because its body is `sorry`.