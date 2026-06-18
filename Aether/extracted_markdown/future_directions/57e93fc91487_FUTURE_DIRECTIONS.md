# Future Directions: Markov Bases for Contingency Tables

## Synthesis

This cycle added `Algebra/MarkovBases/TwoWay.lean`, a from-scratch formalization of the
**two-way independence model** on general `m × n` integer contingency tables and a complete,
axiom-clean proof of the **Fundamental Theorem of Markov Bases** for it (Diaconis–Sturmfels):
the family of basic `2 × 2` swap moves `B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}`
connects every fiber while staying non-negative throughout.

It is the foundational companion to the existing `Algebra/MarkovBases/NoThreeWay.lean` (the
rank-one `2 × 2 × 2` no-three-way model) and realizes the `TwoWay` module that file's
docstrings already pointed to. The structural heart is a three-stage sign-pattern pigeonhole
(`exists_good_indices`: all-cells sum → row sum → column sum), a localized `ℓ¹`
distance-reduction estimate (`dist_decrease`), and a strong induction on the `ℓ¹` distance
(`connected_of_D_le`). We also proved the step relation is symmetric (`step_symm`,
`Connected.symm`), so connectivity is a genuine equivalence relation whose classes are the
fibers.

## Results summary

- `basicMove_preserves_margins` — basic moves lie in the kernel of the margin map.
- `exists_good_indices` — sign-aligned `2 × 2` frame from the three-stage pigeonhole.
- `dist_decrease` — a sign-aligned basic move strictly drops the `ℓ¹` distance to the target.
- `exists_step` — every non-equal fiber pair admits one legal, distance-decreasing move.
- `twoWay_fiber_connected` — **the Fundamental Theorem of Markov Bases** for the independence model.
- `step_symm`, `Connected.symm` — fibers are equivalence classes of the move relation.

All main results compile with no `sorry` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research directions

### 1. The diameter of the Markov graph is exactly half the `ℓ¹` distance

We proved every legal move decreases the `ℓ¹` distance `D u v = ∑ |u - v|` by *at least one*,
but the sign-aligned move actually pushes three of four touched cells toward the target. The
falsifiable claim is sharp: the graph distance between two fibers equals `D u v / 2`, and this
bound is attained. **The key insight is** that `D` decomposes as twice the total positive part
`∑ max(u - v, 0)` (because equal margins force `∑ (u - v) = 0`), and each basic move can be
chosen to retire exactly two units of positive part at once, giving a matching upper and lower
bound. **Why now?** The `dist_decrease` localization lemma already isolates the four-cell
contribution, so upgrading `< D u v` to `≤ D u v - 2` is a one-line strengthening, and the
matching lower bound is a 1-Lipschitz potential argument identical in spirit to
`NoThreeWay/Geodesic.lean`'s `walk_corner_bound`.

### 2. The basic moves are a *lattice* basis, not merely a connector

Connectivity (this cycle) is the combinatorial half of the Fundamental Theorem; the algebraic
half is that the basic moves **ℤ-span the entire kernel lattice** of the margin map — every
integer (possibly negative) table with zero margins is an integer combination of basic moves.
**The key insight is** that the kernel of the row/column margin map on `Fin m × Fin n` is a
free `ℤ`-module of rank `(m-1)(n-1)`, and the basic moves `B(0,i,0,j)` for `1 ≤ i, 1 ≤ j`
form an explicit basis by a triangular elimination on the last row and last column. **Why
now?** The pointwise cancellation machinery in `step_symm` (`basicMove i i' j j' + basicMove i' i j j' = 0`)
plus `basicMove_preserves_margins` already give the two ingredients — closure under negation
and membership in the kernel — so the remaining content is a finite-rank spanning/independence
computation that `Finset.sum` and `Matrix` rank lemmas can carry.

### 3. The no-three-way `2 × 2 × n` model needs (and only needs) the slice-pair moves

`NoThreeWay.lean` settled the rank-one `2 × 2 × 2` case and explicitly flagged `2 × 2 × n` as
open. The conjecture: a Markov basis is exactly the set of `2 × 2 × 2` alternating moves on
each *pair* of `k`-slices, i.e. `binom(n,2)` generators, and they connect every fiber.
**The key insight is** that fixing the two-way margins of a `2 × 2 × n` table reduces, slice by
slice, to a sequence of coupled `2 × 2 × 2` problems whose corner coordinates `u 0 0 k` form a
constrained integer vector — so connectivity becomes a transportation-style walk on those
corners, exactly the structure proven here for the two-way model. **Why now?** This cycle's
distance-reduction template (`exists_good_indices` → `dist_decrease` → `connected_of_D_le`) is
model-agnostic; porting it to the slice-corner coordinates is the most direct route to the
first genuinely *multi-generator* Fundamental Theorem in the catalog.

### 4. Markov degree bound: basic moves have degree `4`, and no smaller basis exists

A Markov basis element's *degree* is its `ℓ¹` size (here `4`: two `+1`s and two `-1`s). The
falsifiable claim is a minimality statement: for `m, n ≥ 2` the independence model has Markov
degree exactly `4`, and any connecting move set must contain a degree-`4` element (so the
basic moves are degree-optimal). **The key insight is** that a degree-`2` move would change a
single row or column sum, contradicting `basicMove_preserves_margins`'s necessity direction —
kernel elements are supported on `≥ 4` cells. **Why now?** We already have the "sufficiency"
direction (degree-`4` moves connect); the "necessity" direction is a short support-size
argument on kernel vectors, making this a clean, self-contained companion theorem.

### 5. Bridge to toric ideals and Gröbner bases (Diaconis–Sturmfels duality)

The deepest direction: connect the combinatorial Markov basis to the **toric ideal** of the
independence model, where basic moves correspond to the binomials `x_{ij} x_{i'j'} - x_{ij'} x_{i'j}`
generating the `2 × 2`-minor (Segre) ideal, and a Markov basis is a generating set of that
ideal. **The key insight is** the Diaconis–Sturmfels dictionary: "moves that connect all
fibers" ⟺ "binomials that generate the toric ideal", translating the discrete connectivity
proven here into a statement about polynomial ideal membership. **Why now?** The catalog
already contains Gröbner-basis infrastructure (`Algebra/GroebnerDerandomization.lean`) and
tropical/toric tooling; wiring `twoWay_fiber_connected` to a `MvPolynomial` toric ideal would
be the catalog's first explicit algebraic-statistics ↔ commutative-algebra bridge, exactly the
cross-domain synthesis these cycles reward.
