# Future Directions — Taxicab 1729 and Sums of Three Cubes

This cycle resolved the mission question: the conjecture that **1729 has no
representation as a sum of three nonzero integer cubes is FALSE**. We exhibited
two essentially distinct representations,

* `1729 = 13³ + (-7)³ + (-5)³`  (= 2197 − 343 − 125),
* `1729 = 208³ + 98³ + (-215)³`,

and explained *why* they had to exist: the only available local obstruction is the
mod-9 one (a sum of three cubes is never `≡ 4` or `≡ 5 (mod 9)`), and
`1729 ≡ 1 (mod 9)` evades it.  We also proved a mod-3 necessary condition on the
bases and ruled out the degenerate `3x³` representation.

The conjectures below are bold, falsifiable, and grow directly out of the
Stage-3 analysis and the Stage-4 adversarial review.

---

## Conjecture 1 — Every residue class that passes the mod-9 filter is hit by 1729's "siblings"
For each `r ∈ {0,1,2,3,5,6,7,8}` (i.e. `r ≢ ±4 mod 9`), the number `1729 + 9k` for
suitable small `k` admits a nonzero three-cube representation, and the density of
representable numbers in `[N, 2N]` among the non-obstructed classes tends to `1`.

**The key insight is...** the mod-9 obstruction is conjecturally the *only*
obstruction, so passing it should be not just necessary but (asymptotically)
sufficient — 1729's two solutions are the local face of a global density statement.

**Why now?** We have a fully formal, axiom-clean statement of the mod-9 filter
(`sum_three_cubes_not_4_5_mod9`); the next step is to formalize a counting/density
companion and test it computationally on the `1729 + 9k` window first.

---

## Conjecture 2 — Bounded-height multiplicity grows for taxicab-type targets
Let `r₃(n, H)` count nonzero integer triples (up to permutation/sign symmetry)
with `x³+y³+z³ = n` and `|x|,|y|,|z| ≤ H`.  Then for `n = 1729`,
`r₃(1729, H)` is unbounded in `H`, and more strongly grows like `c·log H`.

**The key insight is...** our brute-force search already found a *second* solution
only once the height bound passed ~215, suggesting solutions appear on a
logarithmic schedule rather than petering out.

**Why now?** With `taxicab_three_cubes_two_solutions` formalized as a base case,
a Lean-checked search harness can certify `r₃(1729, H) ≥ k` for increasing `k` and
empirically fit the growth law before attempting a proof.

---

## Conjecture 3 — The mod-3 base-sum invariant refines into a full congruence portrait
Every nonzero three-cube representation `x³+y³+z³ = 1729` satisfies
`x+y+z ≡ 1 (mod 3)` (proved) **and** `x+y+z ≡ 1 (mod 9)` is *false* in general,
with the exact distribution of `x+y+z mod 9` over all representations being
non-uniform and computable.

**The key insight is...** `a³ ≡ a (mod 3)` collapses cubes to bases mod 3 but
`a³ mod 9 ∈ {0,1,8}` does NOT collapse to `a`, so the mod-9 base-sum behaves
genuinely differently from mod-3 — a measurable refinement.

**Why now?** `taxicab_three_cubes_base_sum_mod3` pins the mod-3 layer exactly;
extending the same `ZMod` case-analysis technique to mod 9 is mechanical and will
either confirm or refute the non-uniformity claim quickly.

---

## Conjecture 4 — Taxicab numbers are "three-cube rich"
For every taxicab number `Ta(k)` (the smallest integer expressible as a sum of two
positive cubes in `k` ways), `Ta(k)` is also a sum of three nonzero cubes whenever
`Ta(k) ≢ ±4 (mod 9)`; and the first taxicab number `1729 = Ta(2)` is the smallest
positive integer that is simultaneously a 2-way two-cube sum and a nonzero
three-cube sum.

**The key insight is...** having *many* two-cube representations forces algebraic
flexibility (the cubic surface carries many rational points), which heuristically
also supplies three-cube representations — two-way richness predicts three-cube
richness.

**Why now?** We have certified both the two-way two-cube structure
(`taxicab_two_ways`, `taxicab_pairs_distinct`) and a three-cube witness for the
same number; the bridge between them is exactly the object this conjecture names.

---

## Conjecture 5 — Quantify how negative the forced negative base must be
We have already **proved** (`taxicab_no_positive_three_cubes`) that every nonzero
three-cube representation of `1729` uses at least one negative base.  The next
step: in every such representation the most-negative base `m = min(x,y,z)`
satisfies `m ≤ -5`, with equality realized only by `(13,-7,-5)`; and as the height
grows the required negativity grows without bound, `|m| → ∞` along the solution
sequence.

**The key insight is...** the proved all-positive impossibility forces a negative
base, and a cube must be *large* (in absolute value) to cancel the surplus once
the positive bases climb past 12 — so "needs a negative cube" sharpens into a
quantitative lower bound on `|m|`.

**Why now?** `taxicab_no_positive_three_cubes` already certifies the qualitative
statement via a finite box; extending the same bound-then-`interval_cases`
technique with the explicit minimum `-5` is mechanical, and the two known
solutions `(13,-7,-5)` and `(208,98,-215)` already exhibit the predicted growth in
`|m|` (5 → 215).
