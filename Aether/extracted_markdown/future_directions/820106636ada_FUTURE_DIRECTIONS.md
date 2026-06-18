# Future Directions: Causal Integration Algebra — Composition Layer

## What We Built in This Cycle

This cycle extends the catalog's `Shared.CausalIntegration.Core` (the lattice-theoretic
formalization of Integrated Information Theory as min-cuts of weighted digraphs) with a new
file, `Shared.CausalIntegration.Composition`, proving four new headline results (zero sorries,
only the standard `propext / Classical.choice / Quot.sound` axioms):

- **`phi_eq_zero_iff`** — the *exact* characterization `Φ(C) = 0 ↔ C.IsDisconnected`. This is
  the genuine converse of the catalog's one-directional `phi_zero_of_disconnected`, closing
  the boundary of the integrated regime. The proof hinges on the minimum over the lattice of
  nontrivial bipartitions being *attained* (`Finset.exists_mem_eq_inf'`).
- **`symmetrize_crossInfo`** — the undirected weight `w i j + w j i` has cut value
  `crossInfo S + crossInfo Sᶜ`, decomposing an undirected cut into the two opposite directed
  cuts via a summation swap.
- **`directSum` + `phi_directSum_eq_zero`** — the block-diagonal direct sum of two nonempty
  systems is always disconnected, so `Φ = 0`. This is the algebraic incarnation of IIT's
  exclusion postulate: causally independent subsystems carry no joint integration.
- Supporting lemmas `directSum_weight_cross_eq_zero`, `crossInfo_natural_cut_eq_zero`,
  `directSum_isDisconnected`, plus two worked `example` instances (a two-node direct sum, and
  the strict positivity `¬IsDisconnected → 0 < Φ` that drops out of `phi_eq_zero_iff`).

These build directly on catalog results `phi_nonneg`, `phi_le_crossInfo`,
`phi_zero_of_disconnected`, `nontrivialBipartitions_nonempty`, and the `crossInfo` / `phi`
API. They are also the graph-theoretic mirror of the tensor-network IIT in
`Computation.IIT.TensorNetworkSchmidt`, where the role of "disconnected ⟹ Φ = 0" is played by
"product state ⟹ Φ = 0".

---

## Direction 1: Weakly Coupled Direct Sums and a Quantitative Φ = O(ε)

We proved `phi_directSum_eq_zero` for the *strict* block-diagonal sum. The natural next step is
the weakly coupled sum `C₁ ⊕ε C₂`, where the cross-blocks carry weights bounded by `ε`. One
expects `Φ(C₁ ⊕ε C₂) ≤ ε · n₁ · n₂`, and — more sharply — that for small enough `ε` the natural
block bipartition *is* the minimizer, giving `Φ(C₁ ⊕ε C₂) = (cross-info of the block cut) = O(ε)`.
The key insight is that `phi_le_crossInfo` already pins Φ below the block cut, whose value is a
sum of at most `n₁ · n₂` terms each `≤ ε`; combined with `crossInfo_le_totalWeight` from Core this
gives the upper bound immediately, and the matching lower bound only requires showing every other
cut exceeds it once `ε` is below the spectral gap of the diagonal blocks. Why now? The `scale`,
`mono`, and the brand-new `directSum_weight_cross_eq_zero` lemmas already isolate exactly the
cross-block contribution, so the perturbation `ε · 𝟙_{cross}` is additive and `crossInfo_mono`
controls its effect cut-by-cut without any new machinery.

## Direction 2: Submodularity of `crossInfo` and a Lattice Structure on Φ

The map `S ↦ crossInfo S` should be *submodular*:
`crossInfo (S ∪ T) + crossInfo (S ∩ T) ≤ crossInfo S + crossInfo T`, at least for symmetrized
systems. The key insight is that `symmetrize_crossInfo` rewrites every cut as a sum over the
*edge boundary*, and the boundary operator `∂` satisfies the inclusion–exclusion inequality
edge-by-edge: an edge crossing `∂(S∪T)` or `∂(S∩T)` always crosses `∂S` or `∂T` at least as many
times. Establishing this would make Φ the minimum of a submodular function over the Boolean
lattice, immediately importing the entire theory of submodular minimization (Lovász extension,
polymatroid greedy bounds). Why now? `symmetrize_crossInfo` just gave us the boundary
decomposition that turns the global inequality into a finite per-edge case split that `decide` /
`Finset.sum_le_sum` can discharge.

## Direction 3: Restriction Functor and the Exclusion Postulate Inequality

Define `C.restrict S : CausalSystem |S|` by keeping only intra-`S` weights, and prove the
exclusion inequality `Φ(C) ≤ Σᵢ Φ(C.restrict Pᵢ) + (cross-terms)` for any partition
`P = {P₁,…,Pₖ}`. The key insight is that the global minimum cut either *aligns* with the
partition — in which case its value is exactly a sum of cross-terms — or it *splits* some part
`Pᵢ`, in which case the induced sub-cut bounds `Φ(C.restrict Pᵢ)` from above via `crossInfo_mono`.
This makes precise IIT's claim that Φ selects a unique causal "grain." Why now? The direct-sum
construction is the `k = 2`, zero-cross-term special case we just formalized, so `directSum` and
`crossInfo_natural_cut_eq_zero` are the literal base case of the induction on the number of parts.

## Direction 4: A Spectral (Cheeger-type) Lower Bound on Φ

Brute-force evaluation of `phi` enumerates `2ⁿ − 2` bipartitions. The Fiedler value λ₂ of the
graph Laplacian `L = D − W` of a symmetrized system gives a *polynomial-time* lower bound through
the Cheeger inequality `λ₂ / 2 ≤ h(G)`, where Φ is the unnormalized analogue of the Cheeger
constant `h(G)`. The key insight is that `symmetrize_crossInfo` already shows our cut value is the
quadratic form `xᵀ L x` evaluated at the indicator `x = 𝟙_S` (up to the standard `±1` rescaling),
so the Rayleigh quotient `min_{x ⟂ 𝟙} xᵀLx / xᵀx = λ₂` is a *relaxation* of `min_S crossInfo S`
and hence a certified lower bound. Why now? With `symmetrize` and `symmetrize_crossInfo` in hand,
the only missing ingredient is the Laplacian as a `Matrix (Fin n) (Fin n) ℝ` and Mathlib's
existing `Matrix.IsHermitian` spectral theorem to extract λ₂ — no new analysis is required.

## Direction 5: Φ as a Continuous, Monotone Functional on Weight Space

Viewing weights as a point in `(Fin n → Fin n → ℝ≥0)`, the catalog already gives monotonicity
(`phi_mono_of_weight_le`) and homogeneity (`phi_scale`). The natural completion is that Φ is
**1-Lipschitz** in the ℓ¹ norm on weight space: `|Φ(C) − Φ(C')| ≤ Σ_{i,j} |w_ij − w'_ij|`, making
Φ a genuine continuous concave-like functional. The key insight is that Φ is a *minimum of linear
functionals* (each `crossInfo S` is linear in the weights), and a pointwise minimum of
1-Lipschitz functions is 1-Lipschitz; `phi_le_crossInfo` plus `crossInfo_mono` already supply the
two-sided comparison needed. Why now? This packages the existing Core monotonicity/scaling lemmas
together with the new `phi_eq_zero_iff` (which identifies the kernel of Φ) into a single
statement that Φ is a seminorm-like integration measure — the precise object IIT needs for
stability of consciousness measures under noisy weight estimation.
