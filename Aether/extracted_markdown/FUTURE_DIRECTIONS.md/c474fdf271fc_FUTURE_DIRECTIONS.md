# Future Directions: Abstract Baker–Norine Rank Theory

The new file `Catalog/Bridges/TropicalRiemannRochRank.lean` reframes graph
chip-firing rank theory as the theory of an arbitrary finite family of
*degree-preserving moves* `moves : ι → Divisor n`. Within this abstraction we
proved degree invariance of linear equivalence (`principalEquiv_degree`), the
easy half of Riemann–Roch (`rank_le_degree : r(D) ≤ deg D`), monotonicity of the
rank (`rank_antitone`), the rank `-1` characterization of negative-degree
divisors (`not_hasRank_zero_of_neg_degree`), the exact computation `r(0) = 0`
(`rank_zero_divisor`), and an instantiation back to genuine `SimpleGraph`
chip-firing (`graph_riemann_roch_inequality`). This decouples the *combinatorial
content* of Baker–Norine theory from any particular graph, and the directions
below build on that decoupling.

## 1. The Riemann–Roch inequality `deg D − g + 1 ≤ r(D)`

The companion bound to `rank_le_degree` is the genuinely hard half of
Riemann–Roch: for graph chip-firing on a connected graph of genus `g`, every
divisor satisfies `r(D) ≥ deg D − g`. **The key insight is** that the abstract
move-system framework reduces this to a single existence statement — for every
divisor of degree `≥ g` there is an effective representative — which is exactly
the statement that the maximal-degree *non*-special divisors are precisely those
of degree `g − 1`, and this can be attacked through `q`-reduced representatives.
**Why now?** With `principalEquiv_degree`, `rank_antitone` and the effective/degree
bookkeeping lemmas (`Effective.degree_nonneg`, `Effective.eq_zero_of_degree_zero`)
already in place, the only missing ingredient is a certified normal form for the
equivalence classes; the abstract `Principal`/`PrincipalEquiv` quotient is the
right object on which to build it.

## 2. `q`-reduced divisors and Dhar's burning algorithm as a decision procedure

Define, for a chosen sink vertex `q`, the predicate that a divisor is
`q`-reduced, and prove existence and uniqueness of a `q`-reduced representative in
every `PrincipalEquiv` class. **The key insight is** that Dhar's burning algorithm
is a *terminating, deterministic* reduction on the lattice of firing vectors, so
it can be formalized as structural recursion whose invariant is exactly the
`degree`-preservation lemma `principalEquiv_degree` already proven here. **Why
now?** The move-system formulation makes the firing lattice explicit as
`Principal (firingVector G)`, so a burning step is a concrete decrease in a
well-founded measure; combined with `firingVector_degree_zero` this gives a
machine-checkable rank oracle, turning `HasRankAtLeast` from a `∀`-quantified
predicate into a computation.

## 3. Rank is achieved: existence of a maximal valid rank

`rank_antitone` shows the set `{ r ≥ 0 | HasRankAtLeast moves D r }` is a downward
closed set of integers, and `rank_le_degree` shows it is bounded above by
`deg D`. **The key insight is** that a bounded, downward closed, inhabited set of
integers has a maximum, so one can *define* the Baker–Norine rank
`rank moves D : ℤ` (with the convention `-1` when even rank `0` fails, cf.
`not_hasRank_zero_of_neg_degree`) and prove it is well defined, recovering the
classical integer-valued rank function as a theorem rather than a definition.
**Why now?** All three order-theoretic inputs are already proven; the remaining
step is packaging them with `Int`'s well-ordering, after which every later result
(Riemann–Roch, Clifford's bound) can be stated about the honest function `rank`.

## 4. Clifford's inequality for special divisors

For a special effective divisor `D` (one with `D` and `K − D` both of nonnegative
rank), Clifford's theorem asserts `2·r(D) ≤ deg D`. **The key insight is** that the
abstract framework makes the "sub-additivity of rank" lemma
`r(D) + r(E) ≤ r(D + E)` a statement purely about concatenating the witnessing
effective divisors under `principalEquiv_add_right`, which we already proved is
the translation-invariance of `PrincipalEquiv`. **Why now?** `principalEquiv_add_right`
is exactly the gluing operation Clifford's proof needs, so the inequality becomes
an induction on `deg D` using `rank_antitone` as the inductive step, with no new
infrastructure required.

## 5. Specialization functoriality across move systems

Given two move systems `moves₁ : ι → Divisor n` and `moves₂ : κ → Divisor n` with
`range moves₁ ⊆ span (range moves₂)` (more moves available), one expects
`HasRankAtLeast moves₁ D r → HasRankAtLeast moves₂ D r`: enlarging the move set can
only increase rank. **The key insight is** that this is the abstract,
purely-lattice-theoretic skeleton of Baker's specialization lemma — coarsening or
refining the equivalence relation is a monotone operation on rank — and it follows
because any `moves₁`-principal divisor is also `moves₂`-principal. **Why now?** Our
`PrincipalEquiv`/`Principal` definitions expose the move set as data, so the
inclusion hypothesis is directly expressible and the proof is a transport along
`principalEquiv` witnesses; this gives a clean, reusable monotonicity-in-the-moves
theorem that the graph-to-curve specialization story can later be instantiated
against.
