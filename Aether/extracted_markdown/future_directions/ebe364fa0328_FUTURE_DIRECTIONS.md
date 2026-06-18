# Future Directions: Matroid Minors & Robertson–Seymour

This research cycle built the abstract order-theoretic skeleton of the Robertson–Seymour /
Rota programme for matroids in `Geometry/MatroidMinors/`:

- `Basic.lean` — minor-closed predicates, excluded minors, dual–minor correspondence,
  antichains, and `WQO ⇒ finite antichains`.
- `ExcludedMinor.lean` — the descent lemma and the **excluded-minor characterization**
  (`P M ↔ no excluded minor is a minor of M`), well-foundedness of `<m` over finite ground
  types, dual symmetry of excluded minors, and the self-dual duality-closure result.
- `ForbiddenFamily.lean` — forbidden families are minor-closed, minor-closure is stable
  under arbitrary conjunction, the equality `P = Forbids (excludedMinors P)`, and
  **uniqueness of the forbidden antichain**.
- `RobertsonSeymour.lean` — the capstone: `WQO ⇒ finite forbidden-minor characterization`.

## Resolved this cycle (formerly conjectures, now theorems)
- **Uniqueness of the forbidden antichain** — `forbids_antichain_unique`: the antichain that
  defines a minor-closed property is unique (and equals its excluded minors), with *no*
  well-foundedness hypothesis required.
- **Duality halves the search** — `isExcludedMinor_dual_of_selfDual`: for a self-dual
  minor-closed property the excluded minors are closed under matroid duality.

The skeleton remains content-free about *which* classes are well-quasi-ordered; supplying
that analytic input is where the genuine mathematics lies. The conjectures below are
concrete, falsifiable next targets.

## Conjecture 1 (Excluded minors are connected)
Every excluded minor of a minor-closed class closed under direct sums (2-sums) is
**connected** in the matroid-connectivity sense. Formal target: define `Matroid.Connected`
compatibly with Mathlib, then prove `IsExcludedMinor P M → M` connected whenever `P` is
closed under direct sums. This is the matroid analogue of "excluded minors of graph classes
are 3-connected".

## Conjecture 2 (Finite-field WQO bound, Geelen–Gerards–Whittle)
For each finite field `GF(q)`, the class of `GF(q)`-representable matroids is WQO under the
minor relation. Falsifiable milestone: formalize `GF(q)`-representability as a predicate,
show it is minor-closed, and (long-term) feed a proof of its WQO into `robertsonSeymour` to
obtain Rota's conjecture (finitely many excluded minors) as a corollary with **zero extra
plumbing**.

## Conjecture 3 (Decidable minor-testing certificate)
Over a finite ground type, membership in a minor-closed class is decidable by checking the
finite forbidden family. Target: upgrade `robertsonSeymour_finite` to a `Decidable (P M)`
instance given decidability of `· ≤m ·` and a `Fintype` enumeration of candidate minors,
turning the existence statement into an executable membership test.

## Conjecture 4 (Lattice of minor-closed properties)
The minor-closed properties of `Matroid α` form a complete lattice under implication, with
meet = conjunction (`isMinorClosed_iInf`) and join = "smallest minor-closed property above".
Conjecture: this lattice is anti-isomorphic to the poset of forbidden antichains ordered by
"each member has a minor in the other" — making `forbids_antichain_unique` the object map of
a Galois connection. Testable first step: prove minor-closed properties are closed under
arbitrary disjunction's minor-closure and that `Forbids` is monotone-reversing.

## Conjecture 5 (Growth rate / density excluded minors)
Define the rank-`n` size function `h_P(n)` of a minor-closed class `P`. Conjecture (matroid
growth-rate dichotomy, after Geelen–Kabell–Kung–Whittle): for `GF(q)`-representable `P`,
`h_P(n)` is eventually polynomial or eventually `(q^n - 1)/(q-1)`. Formal milestone: define
`h_P`, prove monotonicity under minors, and establish the linear lower bound for any class
containing all free matroids.
