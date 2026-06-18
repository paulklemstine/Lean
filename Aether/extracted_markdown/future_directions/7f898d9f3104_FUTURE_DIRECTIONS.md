# Future Directions: Categorical Rate-Distortion Theory

## Direction 1: Blahut-Arimoto Convergence Theorem in Lean 4

### Precise Theorem Statement
For finite alphabets α, β with source μ and distortion d, the Blahut-Arimoto iterates Q_n(y|x) converge to the rate-distortion optimal channel Q*(y|x), and the mutual information I(X;Y_n) converges monotonically to R(D).

### Proposed Lean Type Signature
```lean
theorem blahut_arimoto_convergence
    {α β : Type*} [Fintype α] [Fintype β]
    (μ : FinPMF α) (d : α → β → ℝ) (beta : ℝ) (hbeta : 0 < beta)
    (Q₀ : Channel α β) :
    ∃ Q_star : Channel α β,
      Filter.Tendsto (fun n => blahutArimotoIter μ d beta Q₀ n)
        Filter.atTop (nhds Q_star) ∧
      IsRateDistortionMinimizer μ d (expectedDistortion μ Q_star d) Q_star
```

### Proof Strategy
1. Show each Blahut-Arimoto iteration decreases the Lagrangian L(Q) = I(X;Y) + β·E[d(X,Y)].
2. Show the iterates remain in the compact set of channels (product of simplices).
3. Apply the monotone convergence theorem in finite dimensions.
4. Characterize the fixed point as the KKT point of the Lagrangian.

### Cross-Domain Connection
Convergence analysis connects to proximal algorithms in optimization and expectation-maximization in machine learning. A formal convergence proof would be the first verified iterative information-theoretic algorithm.

---

## Direction 2: Convexity of R(D) via Channel Mixing

### Precise Theorem Statement
The rate-distortion function R(D) is convex on the feasible distortion interval [D_min, D_max].

### Proposed Lean Type Signature
```lean
theorem finite_rateDistortion_convexOn
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (μ : FinPMF α) (d : α → β → ℝ) :
    ConvexOn ℝ {D | IsFeasible μ d D} (rateDistortion μ d)
```

### Proof Strategy
1. Use the proved theorem `expectedDistortion_mix`: expected distortion is affine in channel mixing.
2. Show mutual information is convex in the channel (via log-sum inequality).
3. For D₁, D₂ feasible with channels K₁, K₂: the mixed channel K_t = (1-t)K₁ + tK₂ achieves distortion (1-t)D₁ + tD₂ and mutual info ≤ (1-t)I₁ + tI₂.
4. Take infimum over feasible channels to get convexity of R(D).

### Cross-Domain Connection
Convexity is the foundation for duality theory and connects to convex optimization, supporting hyperplanes, and the tropical envelope structure.

---

## Direction 3: Categorical Adjunction Between Distortion Systems and Lawvere Spaces

### Precise Theorem Statement
Define a category **Dist** of finite distortion systems (finite types with distortion matrices and probability distributions) and a category **Law** of Lawvere metric spaces. There exists an adjunction F ⊣ G where F maps distortion systems to their rate-distortion metric spaces and G maps Lawvere spaces to canonical distortion systems.

### Proposed Lean Type Signature
```lean
def DistortionCat : Type _ := sorry -- Category of finite distortion systems
def LawvereCat : Type _ := sorry   -- Category of Lawvere metric spaces

def RD_functor : DistortionCat ⥤ LawvereCat := sorry
def canonical_functor : LawvereCat ⥤ DistortionCat := sorry

theorem distortion_lawvere_adjunction :
    RD_functor ⊣ canonical_functor := sorry
```

### Proof Strategy
1. Define morphisms in **Dist** as distortion-nonincreasing maps (stochastic maps preserving feasibility).
2. Define morphisms in **Law** as nonexpansive maps.
3. Show R(D) defines a functor: distortion-nonincreasing maps pull back to nonexpansive maps on R(D) curves.
4. Construct the right adjoint by sending a Lawvere space to its "universal distortion system."
5. Prove the unit and counit satisfy the triangle identities.

### Cross-Domain Connection
This adjunction would unify the observer-rate-distortion duality (existing catalog theorem `prime_capacity_le_rate_distortion`) with the categorical framework, showing that capacity and rate-distortion are adjoint notions.

---

## Direction 4: Tropical Legendre Duality for Finite Rate-Distortion

### Precise Theorem Statement
For finite alphabets, the rate-distortion function R(D) and the dual function Φ(λ) = inf_K {I(X;Y) + λ·E[d]} are tropical Legendre duals:
R(D) = sup_{λ≥0} (Φ(λ) - λD)  and  Φ(λ) = sup_{D≥0} (R(D) + λD)

Moreover, the breakpoints of R(D) correspond to the active dual multipliers, and the number of linear pieces is bounded by the number of extreme points of the feasible polytope.

### Proposed Lean Type Signature
```lean
theorem tropical_legendre_duality
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (μ : FinPMF α) (d : α → β → ℝ) (D : ℝ) (hf : IsFeasible μ d D) :
    rateDistortion μ d D =
      sSup (Set.range (fun lam : {l : ℝ // 0 ≤ l} =>
        dualFunction μ d lam.val - lam.val * D))
```

### Proof Strategy
1. The forward inequality (R(D) ≥ sup Φ(λ) - λD) is already proved (rateDistortion_affine_lower_bound).
2. The reverse inequality uses strong duality for finite-dimensional convex optimization.
3. Show the Slater condition holds (strict feasibility) for the distortion constraint.
4. Apply the minimax theorem / strong duality.
5. Characterize the finite support via the extreme point structure.

### Cross-Domain Connection
This connects directly to the catalog theorem `tropical_rate_distortion_duality_finset` and would provide a computational characterization of R(D) as a tropical polynomial, enabling exact arithmetic computation.

---

## Direction 5: Optimal Transport Formulation of Voice-Leading Compression

### Precise Theorem Statement
Voice-leading distance between probability distributions over chords equals the Wasserstein-1 distance with voice-leading cost as ground metric. The rate-distortion function R(D) for voice-leading can be reformulated as a regularized optimal transport problem.

### Proposed Lean Type Signature
```lean
theorem voiceLeading_wasserstein
    {n : ℕ} (μ ν : FinPMF (Voicing n)) :
    wasserstein1 vlDistReal μ ν =
      sInf {c | ∃ γ : Coupling μ ν, ∑ᵢ ∑ⱼ γ(i,j) * vlDistReal (μ.support i) (ν.support j) ≤ c}

theorem voiceLeading_RD_as_regularized_OT
    {n : ℕ} (μ : FinPMF (Voicing n)) (d : Voicing n → Voicing n → ℝ) (D : ℝ) :
    rateDistortion μ d D =
      sInf {H(γ) - H(μ) | γ coupling, Wasserstein_cost γ ≤ D}
```

### Proof Strategy
1. Define Wasserstein-1 distance for finite distributions using linear programming duality.
2. Show voice-leading distance satisfies the ground metric requirements.
3. Express the rate-distortion optimization as entropy-regularized transport.
4. Use Sinkhorn's theorem for computational aspects.

### Cross-Domain Connection
This bridges to computational optimal transport, enabling the use of Sinkhorn algorithms for R(D) computation and connecting to the Monge-Kantorovich theory. It also links to the machine learning literature on Wasserstein distances for generative models.

---

## Team Directive

Create a team to conduct research along these five directions. Each direction should:
1. **Formulate hypotheses** as precise Lean theorem statements.
2. **Build infrastructure** (definitions, helper lemmas) incrementally.
3. **Validate computationally** using Python implementations before formalizing.
4. **Cross-pollinate** — results in one direction often unlock proofs in another.

Priority ordering:
1. Direction 2 (Convexity) — builds directly on existing infrastructure
2. Direction 4 (Tropical Legendre) — extends the affine lower bound
3. Direction 1 (Blahut-Arimoto) — algorithmically important
4. Direction 3 (Adjunction) — theoretically deepest
5. Direction 5 (Optimal Transport) — broadest applications

Each iteration should produce:
- New formally verified theorems
- Updated computational experiments
- Revised proof strategies for remaining directions
