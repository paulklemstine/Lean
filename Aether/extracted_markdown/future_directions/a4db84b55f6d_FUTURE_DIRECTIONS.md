# Future Directions — Unique Games, MAX-CUT, and SDP Gaps

## Synthesis

This cycle built a constructive, decidable Lean 4 nucleus for the combinatorial
core of the Unique Games Conjecture (UGC). The file `Catalog/Bridges/UniqueGamesMaxCut.lean`
introduces `Constraint` (a permutation-defined binary constraint), `Game` (a list of
such constraints), `numSat`, and a fully decidable `value` (the maximum number of
simultaneously satisfiable constraints over all labelings of a finite vertex set). On
top of these we proved, in full generality, the perfect-completeness characterization
`value_eq_length_iff` (a game is fully satisfiable iff its value equals the number of
constraints) and the *defining* uniqueness property `Constraint.unique_label` (two
satisfying assignments agreeing on `u` must agree on `v`, because the constraint is a
bijection). We then embedded MAX-CUT as the 2-label flip game (`maxcut_sat_iff_ne`)
and produced a machine-checked integrality-gap witness: the triangle `K₃` has MAX-CUT
unique-game value `2` out of `3` (`triangle_value`, `triangle_gap`), is *not* perfectly
satisfiable (`triangle_not_satisfiable`), yet every single edge is satisfiable in
isolation (`triangle_each_edge_satisfiable`). This is the smallest odd-cycle obstruction
underlying the well-known MAX-CUT SDP integrality gap.

## Results Summary

- `value_le_length`, `numSat_le_length` — basic value bounds.
- `numSat_eq_length_iff` — a labeling satisfies all constraints iff it satisfies `length` of them.
- `value_eq_length_iff` — **perfect completeness** characterization (general `V`, `L`).
- `Constraint.unique_label` — the **uniqueness** structural property of unique games.
- `maxcut_sat_iff_ne` — MAX-CUT = 2-label `swap false true` game.
- `triangle_value` / `triangle_gap` / `triangle_not_satisfiable` / `triangle_each_edge_satisfiable`
  — a concrete, decidable completeness-vs-soundness (integrality-gap) witness.

These connect to existing catalog material on graphs and spectra
(`Bridges/Connectivity.lean`, spectral/expander files), since unique games over a graph
are exactly an edge-labeled constraint system whose soundness is governed by spectral
expansion.

---

## Direction 1 — A constructive odd-cycle soundness law

**Conjecture.** For every odd `n = 2m+1`, the MAX-CUT unique game on the `n`-cycle has
value exactly `n - 1` (i.e. completeness `(n-1)/n`, soundness gap `1/n`), and the `n`-cycle
is never perfectly satisfiable, whereas every even cycle *is* perfectly satisfiable
(value `= length`).

The key insight is that bipartiteness — equivalently the absence of odd closed walks —
is exactly the obstruction to perfect satisfiability of a 2-label flip game, so the
parity of the cycle length is the *sole* determinant of the value, and this can be made
into a decidable family indexed by `n`.

Why now? We already have the `n = 3` instance proved by `decide` and the general
`value_eq_length_iff` characterization; extending from a single decided instance to an
`n`-indexed theorem only needs an inductive cut-counting argument, which is squarely in
reach of the current framework.

## Direction 2 — Random-assignment lower bound (the trivial UG approximation)

**Conjecture.** For any unique game `G` over a label alphabet `L` with `|L| = k`, there
exists a labeling satisfying at least `⌈length / k⌉` constraints; hence `value G ≥ length / k`.
For MAX-CUT (`k = 2`) this specializes to: every graph has a cut containing at least half
of its edges.

The key insight is that averaging `numSat` over all `k^|V|` labelings equals `length / k`
exactly (each permutation constraint is satisfied by a `1/k` fraction of label pairs), so
the maximum is at least the average — a constructive pigeonhole that needs no probability
measure.

Why now? `numSat`, `value`, and the `Finset.sup`/`Finset.le_sup` machinery used in
`value_eq_length_iff` already give the "max ≥ average" half; the missing piece is the
exact average computation, a finite double-count over `Finset.univ`.

## Direction 3 — Decidable value as a verified algorithm with complexity content

**Conjecture.** `value` is computable in time `O(k^|V| · length)` by exhaustive search,
and this brute-force `value` agrees with a memoized/branch-and-bound refinement on all
instances; moreover deciding `value G ≥ t` is the NP-hardness kernel one would reduce
from in a UGC-style hardness proof.

The key insight is that our `value` is *already* an executable function (it `#eval`s),
so it is simultaneously the mathematical definition and a reference algorithm — the gap
between "definition" and "algorithm" disappears, letting us prove algorithmic
optimizations correct by `rfl`/`decide` against the spec.

Why now? `value` is defined as a concrete `Finset.sup` and the triangle results are
closed by `decide`, demonstrating executability; a faster certified variant can be
validated against this golden reference on all small instances.

## Direction 4 — Spectral soundness bridge to the catalog

**Conjecture.** For a `d`-regular graph with normalized second eigenvalue `λ`, the MAX-CUT
unique game has value at most `length · (1/2 + λ/2)`; consequently expander graphs
(small `λ`) have MAX-CUT value bounded away from perfection, giving an *infinite family*
of integrality-gap witnesses generalizing the triangle.

The key insight is that the soundness of a unique game is controlled by the spectral gap
of its constraint graph, so the catalog's expander/spectral results
(e.g. Cayley-graph connectivity and Dirichlet-energy lemmas in `Bridges/Connectivity.lean`)
plug directly into UG soundness bounds.

Why now? The catalog already contains spectral and expander infrastructure; bridging it to
`value` requires only relating `numSat` of the flip game to the quadratic form `xᵀ L x`
of the graph Laplacian, a single identity.

## Direction 5 — Label-extended games and the `k → ∞` hardness scaling

**Conjecture.** There is an explicit family of unique games `G_k` over `Fin k` with a
completeness-soundness pair `(1 - ε(k), δ(k))` where `ε(k), δ(k) → 0` as `k → ∞`,
realized by tensor/parallel composition of the triangle gadget; the value of a product
game factors as the product of values, certifying the gap amplification.

The key insight is that parallel repetition multiplies soundness while preserving
near-perfect completeness, so a single hard gadget (the triangle) can be lifted, by an
explicit constructive product on `Game`, into the `1-ε` vs `ε` regime named in the UGC
itself.

Why now? The `Constraint`/`Game` types are closed under an easily-definable product
(`Game V₁ L₁ → Game V₂ L₂ → Game (V₁ × V₂) (L₁ × L₂)`), and `value_eq_length_iff` already
gives the satisfiability side; only the value-factorization lemma remains to be proved.
