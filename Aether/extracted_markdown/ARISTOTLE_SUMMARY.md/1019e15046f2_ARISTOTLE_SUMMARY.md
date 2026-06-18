# Summary of changes for run 45093c65-0220-4781-9585-b4230674ff85
## Beal's Conjecture — Provable Special Cases & Computational Evidence (Lean 4)

I delivered new Lean theorems on Beal's Conjecture (`A^x + B^y = C^z`, `x,y,z > 2` ⟹ `gcd(A,B,C) > 1`), built on and repairing the existing catalog Beal cluster.

### New files
- `Catalog/Speculative/Beal/Defs.lean` — supplies the previously **missing** shared definitions `BealConjecture` and `PrimitiveResidueSolution`. The existing files `MachineLearning/Beal/PrimitiveReduction.lean` and `MachineLearning/Beal/Monotonicity.lean` imported `Speculative.Beal.Defs`, which did not exist, so they failed to build; this repair makes the whole Beal cluster compile.
- `Catalog/MachineLearning/Beal/SpecialCases.lean` — the main deliverable, with Lab Notebook blocks and `-- !--` proof sketches.

### Theorems (proved, sorry-free, allowed axioms only)
- `beal_equal_bases` — Beal holds non-vacuously when the two summand bases coincide (`A = B`); realized by `2^3 + 2^3 = 2^4`. The substance is eliminating `A = 1` via a size bound.
- `beal_of_flt` — generic bridge: any exponent `n` with `FermatLastTheoremFor n` yields the diagonal Beal case `A^n + B^n = C^n` (vacuously, since no solution exists).
- `beal_diagonal_three`, `beal_diagonal_four` — Beal for `(3,3,3)` and `(4,4,4)` from Mathlib's `fermatLastTheoremThree`/`fermatLastTheoremFour`.
- `beal_diagonal_six`, `beal_diagonal_eight` — Beal for `(6,6,6)`/`(8,8,8)` via `FermatLastTheoremFor.mono`.
- `beal_verified_box` — kernel-checked finite search: every solution with bases in `[1,20]` and exponents in `[3,5]` has `gcd > 1` (non-vacuous).
- `bealConjecture_diagonal` — the diagonal fragment phrased against the catalog `BealConjecture` predicate.

### Conjecture (explicitly marked, `sorry` allowed)
- `beal_mixed_345` — the smallest genuinely open mixed-exponent triple `(3,4,5)`, marking the boundary of the present techniques.

### Notes
- `FUTURE_DIRECTIONS.md` (root) contains the required Synthesis, Results Summary, and 5 falsifiable research directions, each with a "key insight" and "why now". A central finding: the catalog's unit-based `PrimitiveResidueSolution` obstruction cannot bridge to coprime integer solutions (a coprime solution need not reduce to units mod `N`), which explains the open mixed-exponent core and motivates Direction 4.
- Structural picture: solutions split into non-primitive (catalog primitive reduction), primitive-diagonal (FLT, handled here), and primitive-mixed (open core).

All proved results were verified with `lean_build` and `#print axioms` (only `propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` for the computational theorem).