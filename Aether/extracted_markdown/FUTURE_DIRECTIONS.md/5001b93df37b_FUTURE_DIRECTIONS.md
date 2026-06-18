# Future Directions: Formal Polyhedral Information Theory

## Overview

This document outlines 5 concrete breakthrough research directions opened by the formally verified bridge between finite rate-distortion theory, tropical geometry, and categorical voice-leading. Each direction includes a precise theorem statement, proposed Lean type signature, proof strategy, and cross-domain connections.

---

## Direction 1: Blahut-Arimoto Convergence Theorem in Lean

### Precise Theorem Statement
For a finite source alphabet α with distribution μ, finite reproduction alphabet β, and distortion measure d : α → β → ℝ, the Blahut-Arimoto alternating minimization algorithm converges to the rate-distortion optimum. Specifically, the iterates (Rₖ, Dₖ) converge to a point on the R(D) curve, and the convergence rate is at least geometric in the KL divergence.

### Proposed Lean Type Signature
```lean
theorem blahutArimoto_converges
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (μ : FinPMF α) (d : α → β → ℝ) (s : ℝ) (hs : 0 < s)
    (q₀ : FinPMF β) :
    ∃ K : StochKernel α β,
      Filter.Tendsto (blahutArimotoIterate μ d s q₀)
        Filter.atTop (nhds K) ∧
      isRateDistortionOptimal μ d s K
```

### Proof Strategy
1. Define the Blahut-Arimoto iteration as alternating minimization of the Lagrangian I(X;Y) + s·E[d(X,Y)].
2. Show each step decreases the Lagrangian (using log-sum inequality / Gibbs variational principle).
3. Prove compactness of the probability simplex in finite dimensions.
4. Apply monotone convergence in a compact space to extract a limit.
5. Show the limit satisfies the KKT conditions of the rate-distortion optimization.

### Cross-Domain Connection
**Machine learning ↔ Information theory:** Blahut-Arimoto is structurally identical to the EM algorithm and variational inference. A formal convergence proof would provide a template for certified training algorithms in representation learning.

---

## Direction 2: Convexity of R(D) via Channel Mixing

### Precise Theorem Statement
For finite types α, β with source distribution μ and distortion d, the continuous rate-distortion function (defined over all stochastic kernels, not just a finite set) is convex on the feasible distortion interval. This requires proving that mutual information I(X;Y) is convex in the channel p(y|x) for fixed p(x).

### Proposed Lean Type Signature
```lean
theorem mutualInfo_convex_in_channel
    {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinPMF α)
    (K₁ K₂ : StochKernel α β) (t : ℝ) (ht₀ : 0 ≤ t) (ht₁ : t ≤ 1) :
    mutualInfo μ (mixKernel t K₁ K₂) ≤
      t * mutualInfo μ K₁ + (1 - t) * mutualInfo μ K₂

theorem continuous_rateDistortion_convexOn
    {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinPMF α) (d : α → β → ℝ) :
    ConvexOn ℝ (continuousFeasibleSet μ d) (continuousRD μ d)
```

### Proof Strategy
1. Define kernel mixing: (mixKernel t K₁ K₂).cond a b = t * K₁.cond a b + (1-t) * K₂.cond a b.
2. Prove log-sum inequality: for nonneg a₁, a₂, b₁, b₂, a₁·log(a₁/b₁) + a₂·log(a₂/b₂) ≥ (a₁+a₂)·log((a₁+a₂)/(b₁+b₂)).
3. Apply pointwise to the KL divergence terms in mutual information.
4. Deduce convexity of mutual information in the channel.
5. Derive convexity of R(D) by the standard argument: mixing channels preserves feasibility with mixed distortion.

### Cross-Domain Connection
**Convex optimization ↔ Tropical geometry:** Convexity of R(D) is the prerequisite for the tropical envelope being tight (strong duality). This connects to the epigraph characterization of convex functions as intersections of half-spaces.

---

## Direction 3: Categorical Adjunction Between Distortion Systems and Lawvere Spaces

### Precise Theorem Statement
Define a category **Dist** of finite distortion systems (source distribution + distortion matrix) with rate-preserving morphisms, and a category **Law** of Lawvere metric spaces with nonexpansive maps. Prove there exists a functorial assignment Dist → Law sending each distortion system to its induced Lawvere metric space (where distance = minimum distortion), and that this functor has a right adjoint.

### Proposed Lean Type Signature
```lean
def DistortionCat : Type _ := sorry

instance : Category DistortionCat := sorry

def LawvereCat : Type _ := sorry

instance : Category LawvereCat := sorry

def distToLawvere : DistortionCat ⥤ LawvereCat := sorry

theorem distToLawvere_has_right_adjoint :
    ∃ G : LawvereCat ⥤ DistortionCat, distToLawvere ⊣ G := sorry
```

### Proof Strategy
1. Define DistortionCat objects as bundled (Fintype α, FinPMF α, distortion matrix).
2. Morphisms are "simulation maps" preserving expected distortion.
3. Define LawvereCat using the existing LawvereMetric class, bundled with nonexpansive maps.
4. The functor sends (α, μ, d) to (α, d_min) where d_min(x,y) = min_ŷ d(x,ŷ).
5. The right adjoint sends a Lawvere space (X, d) to the trivial distortion system where distortion = distance.
6. Verify the adjunction via the hom-set characterization.

### Cross-Domain Connection
**Category theory ↔ Optimal transport:** The adjunction would formalize the correspondence between distortion-optimal maps and nonexpansive maps, connecting rate-distortion theory to Kantorovich duality in optimal transport.

---

## Direction 4: Optimal Transport Formulation of Voice-Leading

### Precise Theorem Statement
Prove that the minimum voice-leading distance between two voicings equals the optimal transport cost for the discrete measures concentrated on the pitch values, with ground cost |p - q|. This establishes voice-leading as a special case of the Wasserstein-1 (earth mover's) distance.

### Proposed Lean Type Signature
```lean
theorem minVLDist_eq_wasserstein1
    {n : ℕ} (V W : Voicing n) :
    minVLDist V W = wasserstein1 (uniformFinMeasure V) (uniformFinMeasure W) abs_dist

theorem minVLDist_eq_assignment_problem
    {n : ℕ} (V W : Voicing n) :
    minVLDist V W = optimalAssignment (fun i j => |V i - W j|)
```

### Proof Strategy
1. Model each voicing as a discrete measure on ℤ with n equal-weight atoms.
2. By Birkhoff's theorem, optimal transport for equal-weight measures reduces to minimum-cost bipartite matching.
3. Show that bipartite matchings correspond exactly to permutations of Fin n.
4. Conclude that minVLDist = optimal transport cost.
5. For the assignment problem formulation, use the equivalence between permutation enumeration and the Hungarian algorithm.

### Cross-Domain Connection
**Optimal transport ↔ Music theory ↔ Machine learning:** This would make voice-leading a testbed for Wasserstein distance computations, connecting to Wasserstein GANs and distributional robustness in ML.

---

## Direction 5: Semantic Compression for Finite Symbolic Dynamical Systems

### Precise Theorem Statement
Extend the finite rate-distortion framework to sequences. Define a "temporal voice-leading rate-distortion" for Markov chains on finite chord spaces, where distortion measures the time-averaged voice-leading cost to a compressed Markov chain on a prototype space.

### Proposed Lean Type Signature
```lean
structure MarkovChain (α : Type*) [Fintype α] where
  init : FinPMF α
  trans : α → FinPMF α

def temporalRD
    {α β : Type*} [Fintype α] [Fintype β]
    (M : MarkovChain α) (d : α → β → ℝ) (D : ℝ) : ℝ := sorry

theorem temporalRD_le_iid_bound
    {α β : Type*} [Fintype α] [Fintype β]
    (M : MarkovChain α) (d : α → β → ℝ) (D : ℝ) :
    temporalRD M d D ≤ iidRD (M.stationaryDist) d D := sorry
```

### Proof Strategy
1. Define temporal distortion as the Cesàro limit of expected per-step voice-leading costs.
2. Show that the temporal R(D) is bounded above by the i.i.d. R(D) for the stationary distribution (correlation reduces compression burden).
3. For Markov chains, use the conditional mutual information formula I(Xₙ; Ŷₙ | Xₙ₋₁) to reduce to a per-step optimization.
4. Prove existence of optimal temporal codes using Markov chain ergodic theory.

### Cross-Domain Connection
**Dynamical systems ↔ Music analysis ↔ Language modeling:** This extends the theory from static chord sets to dynamic progressions, enabling formal analysis of harmonic rhythm, phrase structure, and style-specific compression rates. The same framework applies to natural language compression (sentences as sequences of semantic states).

---

## Team Directive

Create a team to conduct research on these directions. Each team member should:

1. **Formalize prerequisites**: Check Mathlib coverage for required lemmas (log-sum inequality, Birkhoff theorem, Markov chain stationarity) and build missing infrastructure.
2. **State conjectures computationally**: Use `#eval` and Python prototypes to validate theorem statements before formalization.
3. **Decompose into ≤10 helper lemmas**: Each direction should be broken into independently provable pieces.
4. **Cross-validate**: Each theorem should be tested against at least 3 concrete numerical examples.
5. **Document for reuse**: All definitions should have docstrings explaining their mathematical significance and relationship to the existing catalog.

The goal is not isolated theorems but a **growing formal library** that future researchers can import, extend, and compute with.
