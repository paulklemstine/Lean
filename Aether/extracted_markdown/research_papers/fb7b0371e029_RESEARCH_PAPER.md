# A Tropical Threshold Characterization of Complete Vietoris–Rips 1-Skeleta

**Artifact:** `Catalog/Bridges/RipsTropicalCompletion.lean`
**Status:** type-checks end-to-end, 0 `sorry`s, axioms `{propext, Classical.choice, Quot.sound}`.

## 1. Problem statement

The Vietoris–Rips filtration of a finite (pseudo)metric space `α` is the monotone
family of graphs `ε ↦ ripsGraph α ε`, where two distinct points are joined iff
their distance is at most the scale `ε`. A basic structural question in this
filtration is:

> *At which scale does the 1-skeleton first become the complete graph, and how can
> completeness be detected algorithmically?*

The Rips ↔ tropical valuation program reads each potential edge `{x, y}` as a
*tropical object* whose **birth time** is the valuation `dist x y`, and reads the
filtration as a sublevel-set construction on those birth times. Under the max-plus
(tropical) semiring, where `⊕ = max`, the scale at which *all* edges have been born
is the tropical sum of the birth times. This paper formalizes the exact equivalence
between the topological condition "the 1-skeleton is complete" and this single
tropical quantity, and derives the algorithmic consequences.

## 2. Definitions used

Built directly on the verified Rips dictionary in
`Catalog/Applications/PoincareData/MetricFiltration.lean`:

- `ripsGraph α ε : SimpleGraph α` — adjacency `x ≠ y ∧ dist x y ≤ ε`.
- `ripsGraph_mono : ε₁ ≤ ε₂ → ripsGraph α ε₁ ≤ ripsGraph α ε₂` — filtration
  monotonicity.

New, local definitions (genuinely missing upstream):

- `tropBirthSum α := (univ : Finset (α × α)).sup' _ (fun p => dist p.1 p.2)` — the
  **max-plus (tropical) sum of edge birth times**, i.e. the largest pairwise
  distance, computed as the finite tropical fold `⊕ = max`. The diagonal pairs
  contribute `dist x x = 0`.
- `simplexCount α ε := (ripsGraph α ε).edgeFinset.card` — the number of
  1-simplices (edges) present at scale `ε`.

## 3. Main theorem and corollaries

**Main theorem (`rips_complete_iff_tropBirthSum_le`).**
For a finite pseudometric space with at least two points and any scale `ε`,
```
ripsGraph α ε = ⊤  ↔  tropBirthSum α ≤ ε.
```
The abstract topological completeness condition is transported to a single
max-plus inequality.

**Corollaries.**

- `rips_complete_mono` — *monotonicity in the filtration parameter*: completeness
  at scale `ε₁` persists at every `ε₂ ≥ ε₁`.
- `rips_complete_at_tropBirthSum` — the 1-skeleton is already complete *at* the
  threshold `tropBirthSum α`.
- `tropBirthSum_le_of_complete` and `rips_complete_threshold_eq` — `tropBirthSum α`
  is the **unique minimal completion scale**; precisely
  `sInf {ε | ripsGraph α ε = ⊤} = tropBirthSum α`.
- `rips_eventually_const` — *eventual stabilization on finite data*: for
  `tropBirthSum α ≤ ε₁ ≤ ε₂`, the graphs at `ε₁` and `ε₂` coincide.
- `rips_complete_iff_simplexCount_eq` — *decision criterion*: completeness holds
  iff `simplexCount α ε` equals the complete-graph edge count
  `(⊤ : SimpleGraph α).edgeFinset.card`, reducing the test to a finite
  natural-number equality.
- `decidableRipsComplete` — packages the threshold characterization as a
  `Decidable` instance for `ripsGraph α ε = ⊤`.

## 4. Proof sketch

Everything factors through two elementary reformulations:

1. `tropBirthSum_le_iff`: by `Finset.sup'_le_iff`, `tropBirthSum α ≤ ε` is
   equivalent to `∀ x y, dist x y ≤ ε`.
2. `ripsGraph_eq_top_iff`: by graph extensionality and `SimpleGraph.top_adj`,
   `ripsGraph α ε = ⊤` is equivalent to `∀ x y, x ≠ y → dist x y ≤ ε`.

The main theorem is the equivalence of these two quantified statements. The
backward direction is immediate. The forward direction needs only `0 ≤ ε`, which
follows from `Nontrivial α`: pick distinct `a, b`, then `0 ≤ dist a b ≤ ε`, so the
diagonal pairs (`dist x x = 0`) also satisfy `≤ ε`.

The minimal-threshold corollary rewrites the completion set to `Set.Ici
(tropBirthSum α)` and applies `csInf_Ici`. The edge-count criterion uses
`ripsGraph α ε ≤ ⊤`, monotonicity of `edgeFinset`, and
`Finset.eq_of_subset_of_card_le` together with injectivity of `edgeFinset`.

## 5. Why this is an algorithmic pipeline / decision procedure

The main theorem converts an a-priori infinite/topological predicate
(`ripsGraph α ε = ⊤`, a statement quantified over all pairs of points and all
adjacency data) into a **single comparison of two real numbers**,
`tropBirthSum α ≤ ε`. On finite data, `tropBirthSum α` is one tropical fold over
the `n²` pairwise distances. This gives a concrete pipeline:

1. compute the max-plus birth sum `τ = tropBirthSum α` once (`O(n²)` distance
   evaluations and `max`s);
2. for any query scale `ε`, decide completeness by the test `τ ≤ ε`
   (`decidableRipsComplete`);
3. `rips_complete_threshold_eq` certifies that `τ` is *the* minimal completion
   scale, and `rips_eventually_const` certifies that the filtration is constant
   above `τ`, so no further scales need be examined.

The complementary `rips_complete_iff_simplexCount_eq` gives a purely combinatorial
decision route: complete iff the edge count attains its maximum, a decidable
`ℕ`-equality that needs no real-number comparison.

## 6. Next concrete formalization steps

- Express the complete-graph edge bound concretely as
  `(⊤ : SimpleGraph α).edgeFinset.card = (Fintype.card α).choose 2`, turning
  `rips_complete_iff_simplexCount_eq` into the explicit criterion
  `simplexCount α ε = n.choose 2`.
- Lift `tropBirthSum` to a genuine `Tropical ℝᵒᵈ`-valued functional and prove it is
  a semiring homomorphism on the relevant fold, making the "tropical sum" reading
  literal rather than nominal.
- Extend the threshold characterization from the 1-skeleton (`⊤` graph) to higher
  simplices of the flag/clique complex, characterizing the scale at which the Rips
  complex becomes the full simplex via the same max-plus birth sum.
- Connect `tropBirthSum α` to the diameter of `α` and to the interleaving-distance
  stability already formalized in the Boltzmann-bridge arc.
