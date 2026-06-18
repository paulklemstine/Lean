# Future Directions: Formal Polyhedral Information Theory

## Overview

This document outlines 5 concrete breakthrough research directions opened by the formalization of finite rate-distortion theory, categorical voice-leading geometry, and their bridge. Each direction includes a precise theorem statement, proposed Lean type signature, proof strategy, and cross-domain connection.

---

## Direction 1: Blahut-Arimoto Convergence Theorem in Lean

### Precise Theorem Statement

The Blahut-Arimoto alternating optimization algorithm converges to the rate-distortion function R(D) for finite alphabets. Specifically, for any finite source distribution μ over α with distortion d : α → β → ℝ, the sequence of mutual information values {I_n} produced by the Blahut-Arimoto iteration satisfies I_n → R(D) as n → ∞.

### Proposed Lean Type Signature

```lean
theorem blahut_arimoto_converges
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (μ : FinProb α) (d : α → β → ℝ) (D : ℝ)
    (hD : IsFeasible μ d D) (β_param : ℝ) (hβ : 0 < β_param) :
    ∃ K_seq : ℕ → Channel α β,
      (∀ n, expectedDistortion μ (K_seq n) d ≤ D + 1 / (n + 1)) ∧
      Filter.Tendsto (fun n => mutualInfo μ (K_seq n))
        Filter.atTop (nhds (rateDistortion μ d D))
```

### Proof Strategy

1. Define the Blahut-Arimoto iteration as a map on the simplex of output distributions.
2. Show each iteration decreases mutual information (or maintains feasibility).
3. Prove the iteration map is continuous on the compact channel simplex.
4. Use the Bolzano-Weierstrass theorem to extract a convergent subsequence.
5. Show the limit is a fixed point, hence a minimizer.

### Cross-Domain Connection

Connects to **optimization theory**: the Blahut-Arimoto algorithm is an alternating minimization / EM-type algorithm. A formal convergence proof would also apply to the EM algorithm for mixture models and to alternating projection algorithms in convex optimization.

---

## Direction 2: Categorical Adjunction Between Distortion Systems and Lawvere Spaces

### Precise Theorem Statement

Define a category **Dist** of finite distortion systems (objects: pairs (X, μ, d) of finite types with distributions and distortion measures; morphisms: distortion-reducing maps) and a category **Law** of Lawvere metric spaces (objects: finite types with distances; morphisms: nonexpansive maps). Prove the existence of an adjunction F ⊣ G : Dist ⇄ Law, where F extracts the induced metric from a distortion system and G equips a metric space with its canonical distortion structure.

### Proposed Lean Type Signature

```lean
def DistortionCat : Type _ := sorry  -- category of finite distortion systems
def LawvereCat : Type _ := sorry     -- category of Lawvere metric spaces

def extractMetric : DistortionCat ⥤ LawvereCat := sorry
def embedDistortion : LawvereCat ⥤ DistortionCat := sorry

theorem distortion_lawvere_adjunction :
    extractMetric ⊣ embedDistortion := sorry
```

### Proof Strategy

1. Define DistortionCat with objects as bundled (type, distribution, distortion matrix).
2. Define LawvereCat with objects as bundled (type, distance function satisfying triangle inequality).
3. The functor F maps (X, μ, d) to (X, d_min) where d_min(x,y) = inf_K E_K[d(x,·)] subject to K(x,·) = δ_y.
4. The functor G maps (X, dist) to (X, uniform, dist).
5. Prove the adjunction via the hom-set bijection: nonexpansive maps (FX, Y) ↔ distortion-reducing maps (X, GY).

### Cross-Domain Connection

Connects to **enriched category theory** and **optimal transport**: the adjunction makes precise the sense in which distortion systems and metric spaces are "dual" perspectives on the same geometric structure.

---

## Direction 3: Tropical Legendre Duality for Finite Rate-Distortion

### Precise Theorem Statement

For finite source and reproduction alphabets, the rate-distortion function R(D) admits a tropical (min-plus) Legendre dual representation:

R(D) = sup_{λ ≥ 0} (Φ(λ) - λD)

where Φ(λ) is the free energy function. Moreover, there exists a finite set of breakpoints {D_1, ..., D_k} such that R(D) is affine on each interval [D_i, D_{i+1}].

### Proposed Lean Type Signature

```lean
theorem finite_rateDistortion_tropical_envelope
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (μ : FinProb α) (d : α → β → ℝ) :
    ∃ A : Finset (ℝ × ℝ),
      ∀ D ∈ feasibleDistortionSet μ d,
        rateDistortion μ d D = A.sup' ⟨_, A_nonempty⟩
          (fun p => p.1 * D + p.2)
```

### Proof Strategy

1. Start from the Lagrange dual formulation: R(D) = sup_{λ≥0} inf_K (I(X;Y) + λ(E[d] - D)).
2. Show the inner minimization over K has a finite number of active vertices (extreme points of the channel simplex).
3. Each vertex contributes one affine functional in D.
4. R(D) as a sup of finitely many affine functions is piecewise-linear.
5. The tropical characterization follows from the equivalence of sup of affine functions and tropical polynomial evaluation.

### Cross-Domain Connection

Connects to **polyhedral geometry** and **linear programming duality**: the piecewise-linear structure of R(D) corresponds to the facet structure of the dual polytope, and the breakpoints correspond to pivots in the parametric simplex method.

---

## Direction 4: Optimal Transport Formulation of Voice-Leading

### Precise Theorem Statement

Voice-leading distance equals the Wasserstein-1 (earth mover's) distance between the empirical measures of the two voicings, where the ground metric is absolute pitch difference on ℤ:

d_VL(V, W) = W_1(μ_V, μ_W)

where μ_V = (1/n) Σ_i δ_{V(i)} is the empirical measure of voicing V.

### Proposed Lean Type Signature

```lean
theorem voiceLeading_eq_wasserstein
    {n : ℕ} (V W : Voicing n) :
    vlDist V W = wasserstein1
      (empiricalMeasure V) (empiricalMeasure W)
      (fun x y => |(x : ℝ) - (y : ℝ)|)
```

### Proof Strategy

1. Show that both sides are solutions to the same linear program (Kantorovich formulation).
2. For the voice-leading side: the minimum over permutations is the solution to the assignment problem.
3. For the Wasserstein side: the optimal transport plan between uniform measures on n atoms reduces to the assignment problem.
4. Use strong duality of linear programming to establish equality.

### Cross-Domain Connection

Connects to **optimal transport theory**: this identifies voice-leading as a discrete optimal transport problem, opening access to the rich toolbox of Kantorovich-Rubinstein duality, entropic regularization (Sinkhorn algorithm), and gradient flow interpretations.

---

## Direction 5: Semantic Compression for Finite Symbolic Dynamical Systems

### Precise Theorem Statement

For a finite symbolic dynamical system (Σ, σ, μ) with alphabet Σ, shift σ, and invariant measure μ, define the semantic distortion d(x, y) as the maximum observer disagreement over a finite window. Prove that the rate-distortion function R_sem(D) characterizes the optimal tradeoff between symbolic complexity (topological entropy) and semantic fidelity.

### Proposed Lean Type Signature

```lean
theorem symbolic_rateDistortion_entropy_bound
    {Σ : Type*} [Fintype Σ] [DecidableEq Σ]
    (μ : FinProb (Fin L → Σ))  -- distribution over length-L words
    (d : (Fin L → Σ) → (Fin L → Σ) → ℝ)  -- semantic distortion
    (D : ℝ) (hD : IsFeasible μ d D) :
    rateDistortion μ d D ≤ topologicalEntropy Σ L
```

### Proof Strategy

1. Define semantic distortion via a finite observer family (as in the catalog's ObserverFamily).
2. Bound the rate-distortion function by the topological entropy of the shift.
3. Use the variational principle: topological entropy = sup of measure-theoretic entropies.
4. Show that the rate-distortion function at D = 0 equals the Shannon entropy, which is bounded by topological entropy.

### Cross-Domain Connection

Connects to **symbolic dynamics** and **representation learning**: semantic compression of symbolic sequences is a formal model for learning representations of sequential data (text, DNA, music scores) that preserve meaning while reducing complexity.

---

## Implementation Priority

1. **Direction 3** (Tropical Legendre duality) — highest impact, directly extends the current formalization
2. **Direction 1** (Blahut-Arimoto) — most computationally useful, validates the theory
3. **Direction 4** (Optimal transport) — strongest cross-domain connection
4. **Direction 2** (Categorical adjunction) — deepest conceptual contribution
5. **Direction 5** (Symbolic dynamics) — most ambitious, requires most new infrastructure

## Team Directive

Create a team to pursue these directions in parallel:
- **Team A** (Directions 1, 3): Computational information theory — iterate on Blahut-Arimoto and tropical duality
- **Team B** (Directions 2, 4): Categorical and transport theory — build enriched category and optimal transport infrastructure
- **Team C** (Direction 5): Dynamical systems — connect to symbolic dynamics and ergodic theory

Each team should:
1. State precise conjectures and validate with computational experiments
2. Build Lean infrastructure incrementally, proving helper lemmas bottom-up
3. Share common definitions (FinProb, Channel, distortion) across teams
4. Meet weekly to identify cross-team synergies and share Mathlib discoveries
