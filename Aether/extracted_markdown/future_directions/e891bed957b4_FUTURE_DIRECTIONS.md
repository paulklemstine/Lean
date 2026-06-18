# Future Directions — Tropical Per-Vertex Cycle Means

## Synthesis

This cycle attacked Direction 1 of the incoming program (Tropical Matrix Power
Stabilization / effective one-wayness) but took it in a sharper direction than the
original Bellman–Ford-style "stabilizes after `n` steps" conjecture. The decisive
observation came from re-reading the catalog's own counterexample in
`Catalog/Computation/Spectral.lean`: the **cross-vertex** subadditivity
`minDiag(M^(k+l)) ≤ minDiag(M^k) + minDiag(M^l)` is *false*, because the minimizing
vertex migrates between powers. Rather than treat this as an obstacle, we isolated the
exact structure that survives — the **per-vertex** diagonal cost sequence
`k ↦ (M^k) i i` — and proved it is genuinely subadditive. This is the right hypothesis
on which Fekete's lemma fires, giving an honest *limit* (not merely the growth
inequalities the catalog had): the per-vertex minimum cycle mean always exists.

Two structural choices made the proofs robust. First, we abandoned `WithTop ℤ`
(which buys a literal semiring `^` but makes the cast to `ℝ` needed for Fekete
painful) in favour of defining min-plus multiplication directly via `Finset.inf'`
over `ℤ` with `[NeZero n]` — exactly the `inf'` style the catalog uses for
`minEntry`/`minDiag`. Second, we never needed full min-plus associativity (Mathlib
lacks `Finset.inf'_add`); a single one-sided **triangle inequality** `tpow_triangle`,
proved by induction that selects the minimizing last edge via
`Finset.exists_mem_eq_inf'`, supplies every upper bound the development uses.

What failed / what we learned: the naive generalization to `minDiag` does not even
have a subadditive sequence to feed Fekete, so the un-normalized stabilization story
of the original Direction 1 cannot hold verbatim. The repair is *normalization* — we
conjecture (and leave as `sorry`) that the cross-vertex normalized sequence still
converges, i.e. the catalog counterexample is a statement about the un-normalized
sequence only. This reframes "stabilization" as "convergence of the cycle mean,"
which is the tropical eigenvalue, and is the object actually relevant to security
parameters for tropical one-way functions.

## Results Summary

- `tmul_le`: proved — choosing an intermediate vertex upper-bounds the min-plus product (the inf' is below every concatenation).
- `le_tmul`: proved — a uniform lower bound on concatenations lower-bounds the product.
- `minEntry_le`: proved — `minEntry M ≤ M i j`, the ℤ analogue of the catalog's `minEntry_le`.
- `tpow_minEntry_le`: proved — `(k+1)·minEntry M ≤ (M^k) i j`, the ℤ port of `minEntry_mul_le_tropPow`; gives the linear lower bound that makes Fekete's BddBelow hypothesis hold.
- `tpow_triangle`: proved — path-concatenation/triangle inequality through any fixed intermediate vertex; the workhorse upper bound.
- `tpow_diag_subadditive`: proved — per-vertex cycle-cost subadditivity `(M^(k+l+1)) i i ≤ (M^k) i i + (M^l) i i`; the structure surviving the catalog's cross-vertex counterexample.
- `tpow_diag_self_loop`: proved — `(M^k) i i ≤ (k+1)·M i i`, the self-loop upper bound.
- `cycleSeq_subadditive` / `cycleSeq_bddBelow`: proved — the two Fekete hypotheses for the shifted diagonal sequence.
- `cycleMean_converges`: proved — **main result**: `(M^k) i i / (k+1)` converges; the per-vertex minimum cycle mean (tropical eigenvalue at a vertex) exists.
- `minDiag_cycleMean_converges`: conjecture (`sorry`) — the normalized cross-vertex sequence converges despite un-normalized cross-vertex subadditivity failing.

## Research Directions

### Direction 1: Karp's theorem in min-plus (closed form for the limit)
**Hypothesis**: The limit `L_i` in `cycleMean_converges` equals
`min { w(C)/len(C) : C a directed cycle through i }`, the minimum mean weight of a
cycle through vertex `i`.
**Test**: Formalize finite walks/cycles as lists of vertices, define cycle weight and
length, and prove `≤` (a low-mean cycle yields a low-cost diagonal walk by repetition,
giving `L_i ≤ mean`) and `≥` (any length-`k` closed walk decomposes into cycles plus a
bounded remainder, so its mean is `≥ min cycle mean − o(1)`).
**Why now**: `tpow_diag_self_loop` already proves the `≤` direction for the trivial
1-cycle; `tpow_triangle` provides the concatenation needed to lift it to arbitrary
cycles, and `tpow_minEntry_le` controls the remainder term.
**If true**: Converts an existence theorem into a computable spectral invariant — a
concrete security parameter for tropical OWFs.
**If false**: Would reveal a gap between analytic (Fekete) and combinatorial (Karp)
cycle means in the integer min-plus setting, itself a surprising phenomenon.

### Direction 2: Cross-vertex repair (prove `minDiag_cycleMean_converges`)
**Hypothesis**: `minDiag(M^k)/(k+1)` converges to `min_i L_i`, even though the
un-normalized `minDiag` sequence is not subadditive (catalog counterexample).
**Test**: Bound `minDiag(M^k)` between `min_i (M^k) i i` over the finitely many vertices;
since each per-vertex sequence converges and there are finitely many vertices, the
pointwise minimum of finitely many convergent normalized sequences converges to the
minimum of the limits.
**Why now**: `cycleMean_converges` supplies convergence for each fixed `i`, and `Fin n`
is finite, so the min is over a finite index set.
**If true**: Recovers a *stabilization* statement at the level of the catalog's original
Direction 1, repaired by normalization.
**If false**: The interchange of `min` and `lim` would fail, pointing to non-uniform
convergence across vertices.

### Direction 3: Effective stabilization rate (the security parameter)
**Hypothesis**: `(M^k) i i / (k+1)` reaches its limit up to additive error `O(1/k)`
with the `O(1)` constant controlled by `n · (maxEntry − minEntry)`; in particular the
*integer* cycle-mean structure stabilizes after `O(n)` steps.
**Test**: Use the cycle decomposition from Direction 1 to bound the remainder of a
length-`k` walk by one sub-`n` path, giving `|(M^k) i i − k·L_i| ≤ C`.
**Why now**: `tpow_triangle` and `tpow_minEntry_le` already bound walk costs both ways;
the missing piece is a pigeonhole on vertices repeating within `n` steps.
**If true**: Gives the quantitative "critical exponent ≈ dimension" that the original
Bellman–Ford conjecture wanted, but in the correct normalized form.
**If false**: Stabilization is slower than linear, weakening tropical OWF parameters.

### Direction 4: From `ℤ` to `WithTop ℤ` (disconnected graphs)
**Hypothesis**: All four main theorems extend to `WithTop ℤ` entries (allowing `⊤` =
"no edge"), with `cycleMean_converges` holding for every vertex `i` whose self-cost is
eventually finite, and the limit being `+∞` exactly for vertices on no cycle.
**Test**: Re-prove `tmul_le`/`tpow_triangle` over `WithTop ℤ` (now `inf'` over a
possibly-`⊤` family) and split the Fekete argument on whether `(M^k) i i` is eventually
finite.
**Why now**: The `inf'` formulation localizes every `⊤` issue to two lemmas; the rest of
the pipeline is order-theoretic and transfers.
**If true**: Connects the result to genuine weighted digraphs (Bellman–Ford with absent
edges), the realistic setting for the catalog's `orbitHash` constructions.
**If false**: Identifies `⊤`-absorption as the precise obstruction to a uniform tropical
spectral theory.

### Direction 5: Per-vertex means as a hard-core predicate for tropical OWFs
**Hypothesis**: The vector `(L_1, …, L_n)` of per-vertex cycle means is invariant under
the tropical conjugacy `M ↦ D ⊙ M ⊙ D^{-1}` (diagonal similarity) and hence is a
well-defined function of the tropical OWF instance, usable as a Goldreich–Levin-style
hard-core predicate.
**Test**: Define tropical diagonal similarity, prove `cycleMean_converges` limits are
invariant under it (cycle weights are conjugation-invariant), then relate distinguishing
`L_i` to inverting matrix powering.
**Why now**: `cycleMean_converges` makes `L_i` a bona fide function of `M`; invariance is
the next algebraic property to nail down.
**If true**: Bridges this cycle's spectral result to Direction 4 of the incoming program
(tropical hybrid arguments / hard-core predicates), a genuine cross-domain link between
tropical spectral theory and cryptographic indistinguishability.
**If false**: Shows the cycle mean leaks similarity data, disqualifying it as a hard-core
predicate and constraining which tropical invariants can be.
