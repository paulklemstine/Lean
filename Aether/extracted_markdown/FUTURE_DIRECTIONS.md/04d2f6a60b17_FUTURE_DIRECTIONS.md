# Future Directions: Tropical Holographic Reconstruction

## Overview

This document outlines concrete research directions opened by our formalization of boundary-to-bulk rigidity for weighted closure systems in the min-plus (tropical) semiring. Each direction includes specific theorem targets, proof strategies, and cross-domain connections.

---

## Direction 1: Multi-Step Tropical Propagation Rigidity

### Current State
Our rigidity theorem operates at the level of single-step boundary data (generator signatures and weights). The propagation cost infrastructure supports multi-step reasoning, but the rigidity result does not yet exploit multi-step boundary response.

### Target Theorem
```
theorem multi_step_rigidity
    (B : Finset X) (S₁ S₂ : WeightedClosureSystem X G)
    (hnf₁ : S₁.IsNormalForm B) (hnf₂ : S₂.IsNormalForm B)
    (hprop : ∀ (s : Finset X) (t : Finset X), t ⊆ B →
      propagationCost S₁ s t = propagationCost S₂ s t) :
    Nonempty (BulkGaugeEquiv B S₁ S₂)
```

### Proof Strategy
- Show that single-step boundary data can be recovered from multi-step propagation costs by examining costs of length-1 generator sequences.
- Alternatively, define a "multi-step boundary kernel" `K_n(s, T)` = min cost to reach `T` from `s` in at most `n` steps, and show `K_1` already determines the system in normal form.
- For non-normal-form systems, show that `K_∞` (iterated closure cost) determines the reduced quotient.

### Cross-Domain Connection
This connects to **metric space boundary rigidity** in differential geometry (Pestov–Uhlmann theory): knowing geodesic distances from boundary to boundary determines the interior metric. Here, tropical propagation cost replaces geodesic distance.

---

## Direction 2: Tropical Sheafification of Boundary Observables

### Vision
Replace the global boundary data set with a **sheaf** on the poset of boundary subsets. Each restriction `B' ⊆ B` induces a localization of boundary data, and the sheaf condition encodes how local boundary observations glue to global data.

### Target Theorem
```
theorem boundary_sheaf_gluing
    (B : Finset X) (S : WeightedClosureSystem X G)
    (cover : Finset (Finset X)) (hcov : ⋃₀ cover = B)
    (local_data : ∀ U ∈ cover, BoundaryData U S)
    (compat : ∀ U V ∈ cover, restrict (U ∩ V) (local_data U) = restrict (U ∩ V) (local_data V)) :
    ∃! d : BoundaryData B S, ∀ U ∈ cover, restrict U d = local_data U
```

### Proof Strategy
- Define restriction maps on boundary data (filtering generators by their interaction with sub-boundaries).
- Show the presheaf axioms hold for the assignment `U ↦ boundaryDataSet U S`.
- Prove the gluing axiom under a separation condition (generators interact with at most one cover element, or the cover is fine enough).

### Impact
This would establish **tropical holography as a sheaf-theoretic framework**, opening connections to derived categories, cohomological obstructions to reconstruction, and persistent homology of boundary response.

---

## Direction 3: Stochastic / Finite-Temperature Deformation

### Vision
Replace the min-plus (zero-temperature) semiring with a **log-sum-exp** (finite-temperature) deformation:
```
cost_β(S, gs) = -(1/β) · log(∑_g exp(-β · w(g)))
```
As β → ∞, this recovers the tropical (min-plus) cost. At finite β, it gives a smooth, differentiable version of propagation cost.

### Target Theorems
```
theorem finite_temp_convergence
    (β : ℝ) (hβ : 0 < β) :
    Filter.Tendsto (fun β => cost_β S gs β) Filter.atTop (nhds (propagationCost S gs))

theorem finite_temp_rigidity
    (B : Finset X) (S₁ S₂ : WeightedClosureSystem X G)
    (hK : ∀ β > 0, boundaryKernel_β B S₁ β = boundaryKernel_β B S₂ β) :
    Nonempty (BulkGaugeEquiv B S₁ S₂)
```

### Proof Strategy
- Define `cost_β` using Mathlib's `Real.exp` and `Real.log`.
- The convergence theorem follows from standard log-sum-exp asymptotics.
- Finite-temperature rigidity is stronger than zero-temperature rigidity (more data), so it should follow from the tropical case plus continuity.

### Cross-Domain Connection
This bridges to **statistical physics partition functions** (the deformed cost IS a partition function), **variational inference** in machine learning, and **Maslov dequantization** (the passage from quantum to tropical).

---

## Direction 4: Categorical Equivalence of Reduced Systems and Admissible Kernels

### Vision
Establish a **category equivalence** (not just bijection) between:
- The category of reduced normal-form weighted closure systems (with gauge-equivalence classes as morphisms)
- The category of admissible boundary kernels (with boundary-compatible maps as morphisms)

### Target Theorem
```
theorem boundary_functor_conservative
    {G₁ G₂ : Type*} [Fintype G₁] [Fintype G₂]
    (B : Finset X)
    (S₁ : WeightedClosureSystem X G₁)
    (S₂ : WeightedClosureSystem X G₂)
    (hred₁ : S₁.Reduced B) (hred₂ : S₂.Reduced B)
    (f : BoundaryDataIso B S₁ S₂) :
    Nonempty (BulkGaugeEquiv B S₁ S₂)
```

### Proof Strategy
- Define a category `WCS_B` of reduced normal-form systems over boundary `B`, with morphisms being gauge equivalences.
- Define a category `BK_B` of admissible boundary data sets, with morphisms being inclusion-preserving maps.
- The boundary functor `F : WCS_B → BK_B` sends `S ↦ boundaryDataSet B S`.
- Our rigidity theorem shows `F` is conservative (reflects isomorphisms).
- Our reconstruction theorem shows `F` is essentially surjective.
- Together: `F` is an equivalence of categories.

### Impact
This is the correct categorical formulation of holographic duality for discrete systems. It would be the first formally verified statement of a bulk-boundary correspondence as a categorical equivalence.

---

## Direction 5: Weighted Hypergraph Rewriting Dynamics

### Vision
Generalize from closure systems (where generators have no preconditions) to **hypergraph rewriting** (where generators require antecedent patterns). This models:
- Chemical reaction networks (reactants → products with rate)
- Logic programming (premises → conclusion with cost)
- Cellular automata with weighted rules

### Target Structure
```
structure WeightedRewriteSystem (X : Type*) (G : Type*) where
  antecedent : G → Finset X    -- required inputs
  consequent : G → Finset X    -- produced outputs
  weight : G → ℝ≥0∞            -- tropical cost
  step : Finset X → G → Option (Finset X) :=
    fun s g => if antecedent g ⊆ s then some (s ∪ consequent g) else none
```

### Target Theorem
```
theorem rewrite_boundary_rigidity
    (B : Finset X)
    (S₁ : WeightedRewriteSystem X G₁)
    (S₂ : WeightedRewriteSystem X G₂)
    (hnf₁ : S₁.IsNormalForm B) (hnf₂ : S₂.IsNormalForm B)
    (hdata : rewriteBoundaryData B S₁ = rewriteBoundaryData B S₂) :
    Nonempty (RewriteGaugeEquiv B S₁ S₂)
```

### Proof Strategy
- The boundary data now includes antecedent information projected onto `B`.
- Normal form requires injectivity of the full `(antecedent ∩ B, consequent ∩ B, weight)` triple.
- The rigidity proof follows the same pattern as the closure case, but with a richer signature type.

### Cross-Domain Connection
This connects to **Petri nets**, **term rewriting**, **chemical reaction network theory**, and **graph transformation systems**. The boundary rigidity theorem would say: observable input-output behavior determines the hidden reaction mechanism.

---

## Priority Ordering

1. **Direction 4** (categorical equivalence) — most immediate, builds directly on current results
2. **Direction 1** (multi-step rigidity) — natural strengthening, uses existing propagation cost
3. **Direction 5** (hypergraph rewriting) — broadest applicability, moderate difficulty
4. **Direction 3** (finite temperature) — deepest mathematical content, connects to physics
5. **Direction 2** (sheafification) — most abstract, highest long-term value

## Technical Prerequisites

- Directions 1–2 require only the current Mathlib infrastructure.
- Direction 3 requires Mathlib's `Real.exp`, `Real.log`, and `Filter.Tendsto`.
- Direction 4 requires Mathlib's category theory library (`CategoryTheory.Category`, `CategoryTheory.Functor`).
- Direction 5 requires extending the `WeightedClosureSystem` structure, minimal new Mathlib dependencies.

## Estimated Effort

| Direction | Definitions | Lemmas | Main Theorems | Estimated Time |
|-----------|-------------|--------|---------------|----------------|
| 1 | 2–3 | 5–8 | 1 | 1–2 weeks |
| 2 | 5–8 | 10–15 | 2–3 | 3–4 weeks |
| 3 | 3–5 | 8–12 | 2 | 2–3 weeks |
| 4 | 8–12 | 15–20 | 3–5 | 4–6 weeks |
| 5 | 5–8 | 10–15 | 1–2 | 2–3 weeks |
