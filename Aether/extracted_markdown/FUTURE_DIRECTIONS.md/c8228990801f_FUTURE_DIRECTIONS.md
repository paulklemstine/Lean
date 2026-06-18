# Future Directions — Tropical Moduli Spaces and the Tropical Torelli Map

## Synthesis

The file `TropicalModuliDimension.lean` formalises the **numerical backbone** of the
tropical moduli space of curves `M_g^trop`.  A combinatorial type — a connected
stable weighted graph with edge lengths forgotten — is encoded as a `StableType`
carrying its invariants `(vert0, vertPos, edges, weight, genus)` together with three
linear structural relations: the *genus formula* `g + v = e + 1 + W`, the *stability*
inequality `3v ≤ 2W + 2e` (stability summed against the handshake lemma), and
*connectedness* `v ≤ e + 1`.  From this encoding the classical dimension theory of
Brannetti–Melo–Viviani / Caporaso falls out as linear arithmetic, and the
top-dimensional cones are realised by *honest* 3-regular `SimpleGraph`s through
Mathlib's `sum_degrees_eq_twice_card_edges`.

The governing discovery is that, once the handshake lemma is applied, the entire
dimension theory of `M_g^trop` is **linear over the integers**: every headline result
is `omega` after the geometry is recorded additively (so no truncated `ℕ`-subtraction
ever appears).

## Results Summary

* `StableType.vertex_bound` — `v ≤ 2g − 2`.
* `StableType.edge_bound` — `e ≤ 3g − 3` (the dimension of `M_g^trop`).
* `StableType.jacobianDim_eq` / `jacobianDim_nonneg` — the tropical Jacobian has
  dimension `b₁ = g − W ≥ 0`; the tropical Torelli map factors through it.
* `StableType.weight_le_genus`, `StableType.tree_genus_zero` — the genus-`0` picture
  (`b₁ = 0` ⇔ weight-`0` tree) as a degenerate stratum.
* `stableTypes_finite` — for fixed `g`, only finitely many types: the fan is finite.
* `trivalent_dimension` — every finite 3-regular simple graph satisfies
  `|V| = 2b₁ − 2`, `|E| = 3b₁ − 3`; with `topType g` / `topType_edge_bound_sharp`
  showing the edge bound is sharp for every `g ≥ 2`.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Bold, Falsifiable Research Directions

### 1. A genuine `Fintype` of isomorphism classes of genus-`g` stable graphs
`stableTypes_finite` bounds only the invariant vector `(vert0, vertPos, edges, weight)`.
Upgrade this to a `Fintype` instance on isomorphism classes of realising weighted
`SimpleGraph`s of genus `g`, quotienting by `SimpleGraph.Iso`.  **The key insight is**
that `vertex_bound` and `edge_bound` confine every type to graphs on the fixed finite
vertex set `Fin (2g − 2)` with at most `3g − 3` edges, so the classes inject into the
finite power set of edges — finiteness is purely combinatorial, no analysis needed.
*Why now?* The arithmetic skeleton is proved and axiom-clean, so only the bookkeeping
of attaching a realising graph remains, and Mathlib's `SimpleGraph`/`Fintype` API
supports it directly.

### 2. The tropical Jacobian as a positive-semidefinite quadratic form
Replace the scalar `jacobianDim` by the edge-length quadratic form
`Q_G(γ) = Σ_e ℓ(e)·γ(e)²` on the cycle lattice `ℤ^{b₁}`.  Conjecture: `Q_G` is always
PSD, and positive definite exactly when all `ℓ(e) > 0`, so the Torelli image lands in
the PSD cone `A_g^trop`.  **The key insight is** that `Q_G` is a `Finset.sum` of
non-negative terms, so PSD-ness is a `positivity`-style argument rather than spectral
theory, with `jacobianDim_eq` already pinning the rank to `b₁`.  *Why now?* The exact
rank target `b₁ = g − W` is in hand, so pairing it with an explicit sum-of-squares
closes the "factors through the Jacobian" half of the Torelli statement.

### 3. Edge contraction and the pure `(3g − 3)`-dimensional face poset
Define edge contraction `StableType → StableType` (length `→ 0`): it drops `edges` by
one and either merges two vertices or shifts a `vert0` into `vertPos`.  Conjecture:
contraction preserves genus exactly and makes `M_g^trop` a *pure* `(3g − 3)`-dimensional
generalized cone complex, with `topType g` at the top.  **The key insight is** that
contraction preserves the additive genus identity `g + v = e + 1 + W` term-by-term, so
genus-preservation is a structural `omega` fact definable directly on `StableType`.
*Why now?* The genus invariant is already a field equation `omega` tracks, so the
contraction map and its invariance can be defined and verified mechanically — the first
formal handle on the boundary stratification.

### 4. Finiteness of Torelli fibers via the cographic matroid
The Caporaso–Viviani theorem says the tropical Torelli map has finite fibers governed
by the *cographic matroid* of the graph.  Formalizable form: two `StableType`s with the
same Jacobian form share a cographic matroid, and only finitely many graphs share a
matroid.  **The key insight is** that the matroid depends only on the finite edge set,
so "same matroid ⇒ finite fiber" is `stableTypes_finite` intersected with a decidable
matroid-equality predicate — a finite-to-finite refinement, not a new compactness
argument.  *Why now?* `stableTypes_finite` supplies the ambient finiteness and Mathlib's
`Matroid` library makes the cographic matroid expressible, turning fiber-finiteness into
a concrete filtering of an existing finite set.

### 5. `M_g^trop` as a contractible metric realisation of the Berkovich skeleton
Equip each cone `σ_G = ℝ_{≥0}^{E(G)}` with the tropical `ℓ^∞` metric, glue along
contractions (Direction 3), and prove the resulting metric space is contractible and of
pure dimension `3g − 3` — the metric shadow of "`M_g^trop` is the Berkovich skeleton of
`M_g`".  **The key insight is** that contractibility comes from the tropical *scaling
homotopy* `ℓ ↦ t·ℓ` toward the cone apex, i.e. max-plus homogeneity, which composes the
dimension formula `edge_bound` with a one-parameter rescaling.  *Why now?* The dimension
formula and the rescaling are both elementary and in reach of Mathlib's topology library,
turning a deep algebraic-geometry statement into a metric-geometry gluing problem.
