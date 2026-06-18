# Future Directions: The Library of Babel, Cycle II

## Synthesis

The previous cycle established the **sphere-packing (Hamming) upper bound**
(`Catalog/Tropical/SpherePackingBound.lean`): disjoint radius-`t` balls about a
min-distance-`(2t+1)` code cannot overpack the space, so `|C|·V(t) ≤ qⁿ`.  This
cycle closed the other half of the classical coding-theory duality by proving the
**Gilbert–Varshamov lower bound** (`Catalog/Tropical/GilbertVarshamov.lean`).

The unifying realization is that *packing* and *covering* are dual extremal
readings of one and the same volume functional `V(r) = |B(r)|`:

* **Packing** (disjointness): `∑_c |B_c(t)| ≤ |space|`, hence `|C|·V(t) ≤ qⁿ`.
* **Covering** (exhaustion): `|space| ≤ ∑_c |B_c(r)|`, hence `qⁿ ≤ |C|·V(r)`.

A *maximal* min-distance-`d` code is the bridge: it is automatically
`(d-1)`-covering (`maxDist_code_covers`), turning a distance hypothesis into a
covering hypothesis and thereby yielding `qⁿ ≤ |C|·V(d-1)` (`gilbert_varshamov`).
Both files share the exact ball cardinality `V(t) = ∑_{i≤t} C(n,i)(q-1)ⁱ`
(`hammingBall_card_formula`) and the equicardinality of all balls
(`hammingBall_card_translation`).

## Results Summary

In `Catalog/Tropical/GilbertVarshamov.lean` (sorry-free, only standard axioms):

1. `covering_lower_bound` — any `r`-covering code obeys `qⁿ ≤ |C|·V(r)`; this is
   simultaneously the **covering-number / metric-entropy** lower bound: the
   `r`-covering number of Hamming space is `≥ qⁿ/V(r)`.
2. `exists_max_minDist_code` — a maximum-cardinality code of minimum distance
   `≥ d` exists (extremal/greedy selection).
3. `maxDist_code_covers` — maximality forces `(d-1)`-covering (proved uniformly
   in `d`, with **no** `d ≥ 1` hypothesis, a genuine generalization).
4. `gilbert_varshamov` — `qⁿ ≤ |C|·V(d-1)` for a min-distance-`d` code.
5. `gilbert_varshamov_formula` — the closed form
   `qⁿ ≤ |C|·∑_{i<d} C(n,i)(q-1)ⁱ`.

Together with `sphere_packing_bound` and `sphere_packing_bound_formula`, the
optimal code size `A_q(n,d)` is now bracketed in Lean by two explicit volume
estimates.

## Research Directions

### 1. The Packing–Covering Sandwich as a Single Theorem

State and prove a *combined* bracketing theorem: for every `n, d, q` the optimal
size `A_q(n,d) := max{|C| : minDist C ≥ d}` satisfies
`qⁿ / V(d-1) ≤ A_q(n,d) ≤ qⁿ / V(⌊(d-1)/2⌋)`, derived mechanically from
`gilbert_varshamov` and `sphere_packing_bound`.  This requires formalizing
`A_q(n,d)` itself (the max over the same finite family used in
`exists_max_minDist_code`) and the monotonicity `V(s) ≤ V(t)` for `s ≤ t`.

The key insight is that `A_q(n,d)` is *already* the cardinality of the extremal
code we constructed, so both bounds are statements about one object rather than
two unrelated estimates; the sandwich becomes a corollary of the two volume
inequalities sharing a witness.

Why now? `exists_max_minDist_code` gives the maximizer and both volume bounds are
sorry-free; only the definition of `A_q(n,d)` and ball-volume monotonicity remain,
both elementary `Finset` arguments.

### 2. Singleton Bound and the Linear-Programming Gap

Prove the **Singleton bound** `A_q(n,d) ≤ qⁿ⁻ᵈ⁺¹` via the projection that
deletes `d-1` coordinates: distinct codewords stay distinct because they differ
in `≥ d` positions, so at least one survives.  Then formally compare it against
the sphere-packing bound to identify, for fixed small `d`, which bound is tighter.

The key insight is that the Singleton bound is a *purely combinatorial injection*
argument (an `Finset.card_le_card_of_injOn` on the coordinate-restriction map),
independent of ball volumes, and so provides a third, orthogonal estimate that
sometimes beats both packing and covering — the seed of linear-programming bounds.

Why now? The Hamming-distance/`hammingDist` infrastructure and the finite
function space `ι → G` are already in place; the projection is just precomposition
with a coordinate inclusion, for which Mathlib has ready `Finset` injectivity API.

### 3. Plotkin Bound by Distance Double-Counting

Formalize the **Plotkin bound**: if `2d > n` (here `q = 2`), then
`|C| ≤ 2⌊d/(2d-n)⌋`, via the double count of `S := ∑_{x,y∈C} hammingDist x y`
both as `≥ |C|(|C|-1)d` (pairwise minimum distance) and as
`∑_{coords} 2 a_j(|C|-a_j) ≤ n·|C|²/2` (per-coordinate weight split).

The key insight is that the *total pairwise Hamming distance* is a coordinate-
separable quantity, so swapping the order of the double sum converts a global
distance constraint into a sum of one-dimensional variance bounds — the same
"sum over pairs = sum over coordinates" Fubini move that drives many extremal
combinatorics proofs.

Why now? `hammingDist` is a `Finset.card` of a coordinate set, so it already
commutes with `∑` over coordinates; the proof needs only `Finset.sum_comm` and the
AM–GM-style bound `a(m-a) ≤ m²/4`, both available, with no algebraic field machinery.

### 4. Asymptotic Rate Functions and the GV Threshold

Define the **rate** `R(C) = log_q|C| / n` and **relative distance** `δ = d/n`,
and prove the asymptotic GV statement `R ≥ 1 - H_q(δ)` in the limit, where
`H_q` is the q-ary entropy already formalized in `QarySourceCoding.lean`.  This
connects the finite `gilbert_varshamov_formula` to the entropy bound by showing
`(1/n) log_q V(δn) → H_q(δ)`.

The key insight is that the *combinatorial* ball volume and the *information-
theoretic* entropy are the same quantity asymptotically — `V(δn) = qⁿ⁽ᴴ_q⁽δ⁾⁺o⁽¹⁾⁾` —
so the GV bound and Shannon's entropy bound are two scales of one phenomenon,
directly linking this file to the existing q-ary source-coding catalog entry.

Why now? Both `gilbert_varshamov_formula` (giving `V`) and the catalog's
`H_q` entropy live in the same `Tropical` namespace; the missing piece is the
single Stirling-type estimate `log_q C(n, δn) ~ n H_q(δ)`, a self-contained
real-analysis lemma.

### 5. Perfect Codes: When Packing Meets Covering

Prove that a code is **perfect** (the radius-`t` packing balls *tile* the space,
`|C|·V(t) = qⁿ`) **iff** it is simultaneously a `t`-packing and a `t`-covering,
i.e. iff the sphere-packing inequality and the covering inequality both hold with
equality.  Then verify the Hamming-code parameter identity `2ⁿ = 2ⁿ⁻ʳ·V(n,1)` for
`n = 2ʳ - 1` as a concrete instance of equality.

The key insight is that perfection is *exactly* the coincidence point of the two
dual bounds proved in this and the previous cycle: equality in packing forces
disjoint balls, equality in covering forces exhaustive balls, and together they
force an exact partition — a tiling of Hamming space.

Why now? We have both inequalities (`sphere_packing_bound`, `covering_lower_bound`)
with the *same* volume `V`, so the iff is the statement that the two slack terms
vanish together; the Hamming-code identity `2ʳ·(1 + (2ʳ-1)) = 2^{2ʳ-1}`... wait,
`V(n,1) = 1 + n(q-1) = 1 + (2ʳ-1) = 2ʳ` for `q = 2`, `n = 2ʳ-1`, so
`2ⁿ⁻ʳ·V(n,1) = 2^{n-r}·2^r = 2ⁿ` is a one-line `Nat` computation our framework
can already check by `decide`/`omega` for fixed `r`.
