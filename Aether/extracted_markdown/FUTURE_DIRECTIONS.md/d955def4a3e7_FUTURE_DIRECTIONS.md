# Future Directions — Boltzmann Bridge IX: Representation & Edge-Realization

## Synthesis

`Applications/BoltzmannBridge/InterleavingRepresentation.lean` (Bridge IX) takes
the metric theory of persistence stability past the isometry formula proved in
Bridge VIII (`InterleavingIsometry`) and closes the two frontiers its Lab Notebook
had flagged.

Bridge VIII proved that the extended interleaving distance is *exactly* the
extended sup-distance of the weight functions,
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ − G.weight σ|`. That is an
isometric *embedding* into `(Finset α → ℝ)`. Bridge IX upgrades it on two fronts,
in the spirit of duality and representation:

1. **Representation as a bijection.** `filtrationEquivWeight` exhibits `Filtration α`
   as the *full* subtype of weight functions that are grounded at `∅` (`w ∅ ≤ 0`)
   and monotone under inclusion. The image of the persistence map is pinned down
   exactly — it is the cone of admissible weights — and `eInterleavingDist` is
   transported across the bijection (`eInterleavingDist_eq_repr_supEDist`). The
   abstract filtration geometry and the concrete weight-function geometry are one
   and the same object viewed through a duality.

2. **Edge-realization for Vietoris–Rips.** For a genuine distance matrix
   (`IsDistMatrix`: nonnegative, zero diagonal, symmetric), the simplex-indexed
   supremum collapses onto an *edge*-indexed one:
   `eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
   = ⨆ (x y), ENNReal.ofReal |d₁ x y − d₂ x y|` (`vr_eInterleavingDist_eq_edgeSup`).
   The VR persistence distance is *literally* the `ℓ∞` distance of the distance
   matrices. As a concrete dividend, the catalog's `≤ 1/10` certificate for the two
   `3`-point clouds is sharpened to an exact equality `= 1/10`
   (`cloud_eInterleavingDist_eq`).

## Results Summary

| Result | Statement | Axioms |
| --- | --- | --- |
| `filtrationEquivWeight` | `Filtration α ≃` grounded-monotone weights | `propext, Classical.choice, Quot.sound` |
| `eInterleavingDist_eq_repr_supEDist` | distance transported across the bijection | standard |
| `diamWeightOf_pair` | `diam d {x,y} = d x y` for a distance matrix | standard |
| `weightSupEDist_diam_le_edgeSup` | simplex-sup `≤` edge-sup (no hypotheses) | standard |
| `edgeSup_le_weightSupEDist_diam` | edge-sup `≤` simplex-sup (distance matrices) | standard |
| `vr_eInterleavingDist_eq_edgeSup` | **edge-realization of the isometry** | standard |
| `cloud_eInterleavingDist_eq` | concrete cloud distance is *exactly* `1/10` | standard |

All proofs are `sorry`-free and depend only on `propext`, `Classical.choice`, and
`Quot.sound`.

## Research Directions

### Direction 1 — Higher-clique realization: from edges to `k`-faces.

Bridge IX realizes the persistence sup at a single *edge* (a two-vertex simplex).
Conjecture: for a weight built as the maximum of a `k`-ary symmetric kernel
`κ : (Fin k → α) → ℝ` over the injections of a simplex (the genuine *higher*
Vietoris–Rips/Čech weight, not just the pairwise diameter), the interleaving
distance collapses onto the sup over single `k`-cliques,
`eInterleavingDist (κ₁-filtration) (κ₂-filtration) = ⨆ (clique of size k),
ENNReal.ofReal |κ₁ − κ₂|`. **The key insight is** that `diamWeightOf_pair`'s only
content is that the maximizing structure is *itself a simplex of the filtration*, so
the argument should lift verbatim once "edge `{x,y}`" is replaced by "the `k`-vertex
support of the maximizing kernel value." **Why now?** Bridge IX has isolated the two
halves (a Lipschitz upper bound `diamWeightOf_dist_le` and a realization lower bound
`diamWeightOf_pair`) into independent lemmas; generalizing each to a `k`-ary kernel
is a self-contained refactor rather than new theory, and it would connect the metric
theory directly to higher-dimensional persistent homology, where the catalog
currently only has `euler_char_full_simplex`.

### Direction 2 — The image is metrically *complete*: a representation of the completion.

`filtrationEquivWeight` identifies filtrations with the cone of grounded-monotone
weights, but says nothing about limits. Conjecture: under the sup-edist, the cone of
grounded-monotone bounded weight functions is a *complete* extended metric space, and
hence `Filtration α` (restricted to bounded weights) is its own completion — no
Cauchy sequence of filtrations escapes the cone. **The key insight is** that
monotonicity (`w σ ≤ w τ` for `σ ⊆ τ`) and grounding (`w ∅ ≤ 0`) are both *closed*
conditions under uniform (sup) limits, so the image is a closed subset of the
complete space `(Finset α →ᵇ ℝ)`. **Why now?** Mathlib already carries
`BoundedContinuousFunction`/`lp`-completeness machinery and `IsClosed.completeSpace`;
the representation bijection of Bridge IX is exactly the bridge needed to import that
machinery into persistence theory, turning a soft "pseudometric/quotient" story into
a hard completeness theorem.

### Direction 3 — Lipschitz functoriality of relabelings (a representation of symmetry).

Any map `f : α → β` pulls back a weight on `Finset β` to one on `Finset α` via
`σ ↦ w (σ.image f)`, giving a functor `Filtration β → Filtration α`. Conjecture: this
pullback is `1`-Lipschitz for `eInterleavingDist`, and an *isometry* exactly when `f`
is injective. **The key insight is** that through `filtrationEquivWeight` the pullback
becomes precomposition `w ↦ w ∘ (Finset.image f)`, and precomposition is always a
sup-norm contraction, with equality iff the index map `Finset.image f` is surjective
onto the relevant supports — i.e. iff `f` is injective. **Why now?** The
representation theorem has just turned filtrations into honest functions, so
functoriality questions become elementary statements about function precomposition;
this would give the persistence functor a clean naturality/symmetry law (the action
of relabeling the data), connecting to the catalog's gauge/invariance themes.

### Direction 4 — Sharpness of the cloud certificate is generic, not special.

`cloud_eInterleavingDist_eq` shows the two `3`-point clouds sit at distance *exactly*
`1/10`. Conjecture: for *any* two distance matrices that differ by a constant `c > 0`
on every off-diagonal entry (a uniform dilation), the interleaving distance is
*exactly* `c`, never strictly less. **The key insight is** that the edge-realization
forces the distance to equal the *largest* off-diagonal gap, so a uniform gap makes
the bound tight automatically — the catalog's "`≤`" stability estimates are generically
attained, not merely upper bounds. **Why now?** With `vr_eInterleavingDist_eq_edgeSup`
in hand, sharpness reduces to evaluating a finite `⨆` of equal terms; proving the
general dilation case (and exhibiting it as a clean corollary) would convert a single
worked example into a reusable *tightness* principle for the whole VR stability suite.

### Direction 5 — A spectral/dual reading: persistence distance as an operator norm.

The edge-sup `⨆ (x y) |d₁ x y − d₂ x y|` is the `(∞,∞)` entrywise norm of the
matrix difference `d₁ − d₂`. Conjecture: this entrywise sup is comparable (up to the
explicit factor `√n` on an `n`-point space) to the *operator* `2`-norm
`‖d₁ − d₂‖₂`, giving two-sided spectral bounds
`‖d₁ − d₂‖∞ ≤ eInterleavingDist ≤ ... ≤ √n · ‖d₁ − d₂‖∞` and hence a *spectral*
control of the persistence distance. **The key insight is** that Bridge IX has
re-expressed a topological/combinatorial distance as a bare matrix norm, at which
point classical norm-equivalence (`Matrix`/`EuclideanSpace` operator-norm lemmas in
Mathlib) applies directly. **Why now?** This is the decisive duality move of the
engine — translating a hard problem in the "shape" space into an easy one in the dual
"operator" space — and it would let spectral perturbation theory (eigenvalue
stability) feed quantitative bounds back into persistent homology.
