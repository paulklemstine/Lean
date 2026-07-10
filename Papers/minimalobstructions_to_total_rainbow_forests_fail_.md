# Computational Evidence — Certificates of minimal rainbow-forest obstructions

## Setup

For two matroids on a common ground set `E` with rank functions `r₁, r₂`, Edmonds'
Matroid Intersection Theorem gives

    max |common independent set| = min_{A ⊆ E} ( r₁(A) + r₂(E∖A) ).

For total rainbow forests, `r₁` is the cycle-matroid rank (forests) and `r₂` the
partition-matroid rank of the colouring (rainbow sets). The Rainbow Forest Inequality at
level `t` is the family of inequalities `obj(A) := r₁(A) + r₂(E∖A) ≥ t`. A *minimal /
tight* obstruction is a configuration with `min_A obj(A) = t − 1`.

The mission conjecture claims the failing subset `A` is **unique**.

## Small-case exploration

We treat `obj` abstractly as a submodular set function and enumerate its minimizers on
tiny ground sets.

- **|E| = 1 (`E = {e}`).** `obj` takes two values `obj(∅)`, `obj({e})`. Any submodular
  function is minimized either at a single subset or at both; if the minimum is attained
  twice the two minimizers are `∅ ⊆ {e}`, comparable.

- **|E| = 2 (`E = {a, b}`).** Enumerate the concave-of-cardinality objective
  `g(A) = −(|A| − 1)²`, giving values

  | A        | ∅  | {a} | {b} | {a,b} |
  |----------|----|-----|-----|-------|
  | g(A)     | −1 | 0   | 0   | −1    |

  The minimum `−1` is attained at **two** subsets, `∅` and `{a,b}`. They are comparable
  (`∅ ⊆ {a,b}`) and their intersection/union are again minimizers — the minimizers form a
  2-element chain. This already **refutes uniqueness** while confirming the lattice
  structure.

- **Non-lattice attempt.** The convex variant `(|A| − 1)²` is minimized at the two
  incomparable singletons `{a}, {b}`, but this function is **not** submodular
  (`obj(∅)+obj(E) = 2 > 0 = obj({a})+obj({b})`). So incomparable multiple minimizers force
  a violation of submodularity: the sublattice property is exactly what submodularity buys.

## What the evidence says

1. Multiple failing subsets do occur, so the literal uniqueness conjecture is **false**.
2. Whenever the objective is genuinely submodular (as matroid-intersection objectives
   always are), the failing subsets are closed under `∪` and `∩`: they form a sublattice.
3. Hence a **unique smallest** and a **unique largest** failing subset always exist,
   sandwiching all the others. Uniqueness of a single failing subset is the degenerate case
   where these two extremes coincide.

These observations drove the formal development in `Obstruction.lean`, where the sublattice
property, the extremal certificates, and an explicit two-certificate counterexample are all
established.

## OEIS / counterexample notes

No integer sequence is intrinsic to the qualitative statement, so no OEIS lookup applies.
The counterexample hunt (above) succeeded on the smallest non-trivial ground set, so no
larger search was needed.
