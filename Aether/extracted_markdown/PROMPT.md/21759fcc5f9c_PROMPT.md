

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

# Idempotent Hamilton-Jacobi Theory: Max-Plus Action Principles, Maslov Dequantization Convergence, and Symplectic Darboux Normal Forms

## I. FOUNDATIONAL DEFINITIONS

### Structure 1: `MaxPlusPhaseSpace`
The idempotent phase space — a 2n-dimensional space over the max-plus semiring where classical mechanics is "tropicalized." This replaces the additive group structure of ℝ²ⁿ with the multiplicative structure of (ℝ ∪ {-∞}, max, +).

```lean
/-- The max-plus phase space: idempotent counterpart to classical symplectic ℝ²ⁿ.
    Bridge: connects differential geometry to tropical algebra.
    Applications: tropical_optimal_control, certified_robustness_bounds -/
structure MaxPlusPhaseSpace (n : ℕ) where
  /-- Position coordinates in max-plus semiring (-∞ represents zero element) -/
  q_plus : Fin n → ℝ
  /-- Momentum coordinates in max-plus semiring -/
  p_plus : Fin n → ℝ
  /-- All coordinates are above the tropical zero (-∞) -/
  above_tropical_zero : ∀ i, -∞ < q_plus i ∧ -∞ < p_plus i
```

### Structure 2: `IdempotentSymplecticForm`
The tropical analogue of a symplectic 2-form: a closed, non-degenerate max-plus bilinear form.

```lean
/-- An idempotent symplectic form on max-plus phase space.
    Satisfies ω₊(v, w) = max(vᵢ, wᵢ) in canonical coordinates.
    Bridge: connects symplectic geometry to idempotent semiring theory.
    Application: hamiltonian_flow_invariance -/
structure IdempotentSymplecticForm (n : ℕ) where
  /-- The max-plus 2-form as a function on pairs of tangent vectors -/
  omega_plus : (Fin n → ℝ) → (Fin n → ℝ) → ℝ
  /-- Non-degeneracy in max-plus sense: ∀v≠0₊, ∃w, ω₊(v,w) > -∞ -/
  nondegenerate : ∀ v w, (∀ i, v i = -∞) ∨ (∃ i, v i > -∞ ∧ omega_plus v w > -∞)
  /-- Closedness in max-plus sense (cocycle condition) -/
  closed : ∀ u v w, omega_plus u (v ⊕ w) = max (omega_plus u v) (omega_plus u w)
  /-- Skew-symmetry in tropical sense: ω₊(v,w) = ω₊(w,v) (symmetric, not antisymmetric!) -/
  tropical_skew : ∀ v w, omega_plus v w = omega_plus w v
  /-- In canonical Darboux form locally: ω₊ = ⊕ᵢ max(dpᵢ₊, dqᵢ₊) -/
  locally_darboux : ∀ x, ∃ (p q : Fin n → ℝ), ∀ v w, 
    omega_plus v w = Finset.max' (Finset.univ.image (fun i => max (v (i : Fin n) - p i) (w (i : Fin n) - q i))) 
      (by simp [Finset.univ_nonempty])
```

### Structure 3: `MaslovDequantization`
The one-parameter family connecting classical Hamilton-Jacobi to max-plus Hamilton-Jacobi via the Maslov parameter β.

```lean
/-- Maslov dequantization: a one-parameter family connecting classical to tropical mechanics.
    As β → ∞, the deformed product x ⊗ᵦ y = (1/β) log(exp(βx) · exp(βy)) converges to max(x,y).
    Bridge: connects real analysis to tropical geometry via deformation theory.
    Application: post_quantum_security (lattice dequantization bounds) -/
structure MaslovDequantization where
  /-- Deformation parameter: β = ∞ gives the tropical limit -/
  beta : ℝ
  beta_pos : 0 < beta
  /-- The deformed addition: x ⊕ᵦ y = (1/β) log(exp(βx) + exp(βy)) -/
  tropical_plus : ℝ → ℝ → ℝ := fun x y => (1/beta) * Real.log (Real.exp (beta * x) + Real.exp (beta * y))
  /-- The deformed multiplication: x ⊗ᵦ y = x + y (unchanged) -/
  tropical_times : ℝ → ℝ → ℝ := fun x y => x + y
```

### Structure 4: `MaxPlusActionFunctional`
The tropical action functional whose stationary points are max-plus Hamilton-Jacobi characteristics.

```lean
/-- The max-plus action functional S₊[γ] = maxₜ H₊(γ(t), γ̇(t)).
    Bridge: connects calculus of variations to idempotent optimization.
    Application: tropical_optimal_control, certified_robustness_bounds -/
structure MaxPlusActionFunctional (n : ℕ) where
  /-- The max-plus Hamiltonian H₊: T*M₊ → ℝ₊ -/
  hamiltonian_plus : MaxPlusPhaseSpace n → ℝ
  /-- Time horizon -/
  T : ℝ
  T_pos : 0 < T
  /-- The action: supremum over time of H₊ evaluated on the curve -/
  action : (ℝ → MaxPlusPhaseSpace n) → ℝ := fun γ =>
    Finset.sup' (Finset.Icc 0 ⌊T⌋₊) (Finset.Icc_nonempty 0 ⌊T⌋₊) 
      (fun t => hamiltonian_plus (γ t))
```

### Structure 5: `ViscositySolution`
A viscosity solution of the classical Hamilton-Jacobi equation, equipped with its Maslov dequantization data.

```lean
/-- A viscosity solution of the classical HJ equation, together with its
    tropical limit under Maslov dequantization.
    Bridge: connects PDE theory to tropical algebra.
    Application: hamiltonian_flow_invariance, certified_robustness_bounds -/
structure ViscositySolution (n : ℕ) where
  /-- The classical solution S: ℝⁿ × ℝ → ℝ -/
  S : ℝ → (Fin n → ℝ) → ℝ
  /-- The Hamiltonian -/
  H : (Fin n → ℝ) → ℝ → ℝ
  /-- S is a viscosity subsolution of ∂ₜS + H(∇S, x) = 0 -/
  is_subsolution : ∀ t x φ, 
    (∀ s y, s = t ∧ y = x → φ s y ≤ S s y) → 
    ∂ₜφ t x + H (∇φ t x) (x : Fin n → ℝ) ≤ 0
  /-- S is a viscosity supersolution -/
  is_supersolution : ∀ t x φ,
    (∀ s y, s = t ∧ y = x → φ s y ≥ S s y) →
    ∂ₜφ t x + H (∇φ t x) (x : Fin n → ℝ) ≥ 0
  /-- Maslov dequantization data -/
  dequantization : MaslovDequantization
```

---

## II. MAIN THEOREMS

### Theorem 1: `idempotent_least_action_principle`
**The fundamental variational principle of max-plus mechanics.** The max-plus action achieves its minimum on characteristic curves satisfying the tropical Hamilton-Jacobi equation.

```lean
/-- **Idempotent Least Action Principle** (Max-Plus Variational Principle).
    For a max-plus Hamiltonian H₊ on idempotent phase space, the max-plus action
    S₊[γ] = maxₜ H₊(γ(t), γ̇(t)) achieves its minimum on characteristic curves
    satisfying max(∂ₜS₊, H₊(∇₊S₊)) = 0.
    
    Bridge: connects calculus of variations to tropical optimization.
    Application: tropical_optimal_control, certified_robustness_bounds
    
    This is the tropical analogue of the classical least action principle:
    just as classical mechanics minimizes ∫L dt, tropical mechanics minimizes maxₜ L₊.
    The proof proceeds by showing that the first-order optimality condition
    for the max-plus functional is precisely the tropical HJ equation. -/
theorem idempotent_least_action_principle {n : ℕ} [hN : NeZero n]
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (S_plus : ℝ → (Fin n → ℝ) → ℝ)
    (h_lipschitz : ∃ L : ℝ, 0 < L ∧ ∀ p q : MaxPlusPhaseSpace n, 
      |H_plus p - H_plus q| ≤ L * Finset.sup' Finset.univ 
        (Finset.univ_nonempty) (fun i => max |p.q_plus i - q.q_plus i| |p.p_plus i - q.p_plus i|))
    (h_coercive : ∃ C : ℝ, 0 < C ∧ ∀ p, C * (Finset.sup' Finset.univ 
        (Finset.univ_nonempty) (fun i => max |p.q_plus 0| |p.p_plus 0|)) ≤ H_plus p)
    (h_tropical_HJ : ∀ t x, max (deriv (fun s => S_plus s x) t) (H_plus ⟨x, fun i => deriv (fun y => S_plus t y) x i, by sorry⟩) = 0)
    (γ : ℝ → MaxPlusPhaseSpace n)
    (h_char : ∀ t, MaxPlusPhaseSpace.q_plus (γ t) = fun i => deriv (fun s => MaxPlusPhaseSpace.q_plus (γ s) i) t)
    (h_endpoint : MaxPlusPhaseSpace.q_plus (γ 0) = MaxPlusPhaseSpace.q_plus (γ 1)) :
    ∀ δ : ℝ → MaxPlusPhaseSpace n, 
      (∀ t, MaxPlusPhaseSpace.q_plus (δ t) = MaxPlusPhaseSpace.q_plus (γ t)) →
      MaxPlusActionFunctional.action (MaxPlusActionFunctional.mk n H_plus 1 sorry) γ ≤
      MaxPlusActionFunctional.action (MaxPlusActionFunctional.mk n H_plus 1 sorry) δ := by
  sorry -- FILL WITH ACTUAL PROOF
```

**Proof Strategy A (Direct — Most Promising):** 
1. Show that for any curve γ, `S₊[γ] = maxₜ H₊(γ(t),γ̇(t))` satisfies a max-plus dynamic programming principle: `S₊(t,x) = min_{γ:γ(t)=x} max_{s∈[0,t]} H₊(γ(s),γ̇(s))`.
2. Prove that the first-order optimality condition for this max-min problem yields `max(∂ₜS₊, H₊(∇₊S₊)) = 0` by differentiating through the max (using Lipschitz regularity from `h_lipschitz`).
3. Establish uniqueness of viscosity solutions to the tropical HJ equation via the max-plus doubling variable technique (adapted from Barles' method).
4. Conclude by showing the characteristic curve γ achieves the minimum since `S₊` evaluated along γ satisfies the tropical HJ equation identically.

**Proof Strategy B (Perturbation):**
1. Consider perturbations γ + εη of the characteristic curve.
2. Use the max-plus analog of the Euler-Lagrange equations: `max(∂H₊/∂p, ∂H₊/∂q) = 0` along characteristics.
3. Show that `d/dε|_{ε=0} S₊[γ + εη] ≥ 0` for all η, using the tropical HJ equation as the stationarity condition.
4. The coercivity condition `h_coercive` ensures existence of minimizers.

**Proof Strategy C (Dequantization limit — connects to Theorem 2):**
1. Approximate the max-plus action by a family of classical actions with parameter β.
2. Use the Maslov dequantization to show the classical least action principle converges to the tropical one.
3. This is mathematically elegant but requires establishing Theorem 2 first.

### Theorem 2: `maslov_dequantization_convergence`
**The foundational convergence theorem.** Classical viscosity solutions of HJ converge exponentially fast to their tropical counterparts under Maslov dequantization.

```lean
/-- **Maslov Dequantization Convergence Theorem**.
    Let S_β be a viscosity solution of the classical HJ equation ∂ₜS + H(∇S,x) = 0,
    and let S₊ be the max-plus solution of max(∂ₜS₊, H₊(∇₊S₊)) = 0.
    Then as β → ∞, the dequantized classical solution converges to the tropical solution:
    
    S₊(t,x) = lim_{β→∞} (1/β) log(exp(β · S_β(t,x)))
    
    with explicit convergence rate: |(1/β)log(exp(β·S_β(t,x))) - S₊(t,x)| ≤ C·exp(-β·δ)
    for constants C > 0 and δ > 0 depending only on the Lipschitz constant of H.
    
    Bridge: connects PDE viscosity theory to tropical geometry via deformation quantization.
    Application: post_quantum_security (dequantization bounds for lattice problems),
                certified_robustness_bounds (tropical limits of neural network dynamics) -/
theorem maslov_dequantization_convergence {n : ℕ} [hN : NeZero n]
    (S_beta : ℝ → MaslovDequantization → (Fin n → ℝ) → ℝ)
    (S_plus : ℝ → (Fin n → ℝ) → ℝ)
    (H : (Fin n → ℝ) → ℝ → ℝ)
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (L_H : ℝ) (h_L_H : 0 < L_H)
    (h_lipschitz_H : ∀ x y, |H x L_H - H y L_H| ≤ L_H * Finset.sup' Finset.univ 
        (Finset.univ_nonempty) (fun i => |x i - y i|))
    (h_viscosity : ∀ β, IsViscositySolution (S_beta · (MaslovDequantization.mk β sorry) · ) H)
    (h_tropical : ∀ t x, max (deriv (fun s => S_plus s x) t) (H_plus ⟨x, fun i => deriv (fun y => S_plus t y) x i, sorry⟩) = 0)
    (h_compat : ∀ β x t, H_plus ⟨x, fun i => deriv (fun y => S_beta t (MaslovDequantization.mk β sorry) y) x i, sorry⟩ = 
        (1/β) * Real.log (Real.exp (β * H x (deriv (fun y => S_beta t (MaslovDequantization.mk β sorry) y) x 0)))) :
    ∃ (C : ℝ) (δ : ℝ), 0 < C ∧ 0 < δ ∧
      ∀ β (t : ℝ) (x : Fin n → ℝ),
        β ≥ 1 →
        |(1/β) * Real.log (Real.exp (β * S_beta t (MaslovDequantization.mk β sorry) x)) - S_plus t x| ≤ 
          C * Real.exp (-β * δ) := by
  sorry -- FILL WITH ACTUAL PROOF
```

**Proof Strategy A (Comparison Principle — Most Promising):**
1. Define `S̃_β(t,x) = (1/β)log(exp(β·S_β(t,x)))`. This is the "dequantized" classical solution.
2. Prove that `S̃_β` satisfies a deformed HJ equation: `max(∂ₜS̃_β, H_β(∇S̃_β)) ≤ ε(β)` where `ε(β) = O(exp(-cβ))`.
3. Use the max-plus comparison principle: if two functions satisfy `max(∂ₜu, H₊(∇u)) ≤ ε` and `max(∂ₜv, H₊(∇v)) ≥ 0` with `u ≤ v` at the boundary, then `u ≤ v + C·ε` everywhere.
4. Apply this with `u = S̃_β` and `v = S₊` to get `|S̃_β - S₊| ≤ C·ε(β) = C·exp(-δβ)`.
5. The key lemma is step 2, which follows from the exponential convergence of `logsumexp` to `max`.

**Proof Strategy B (Semigroup Approach):**
1. Use the Lax-Oleinik semigroup representation: `S_β(t,x) = inf_{γ} [S_β(0,γ(0)) + ∫₀ᵗ L_β(γ(s),γ̇(s))ds]`.
2. Show that `(1/β)log(exp(β·S_β(t,x))) → inf_γ max_{s∈[0,t]} L₊(γ(s),γ̇(s))` as β → ∞.
3. This uses the Laplace principle: `(1/β)log(∫exp(β·f)μ(dx)) → max_x f(x)`.
4. The convergence rate follows from precise Laplace asymptotics.

### Theorem 3: `max_plus_symplectic_darboux`
**The tropical Darboux theorem.** Every 2n-dimensional max-plus symplectic manifold admits local canonical coordinates.

```lean
/-- **Max-Plus Symplectic Darboux Theorem**.
    Every 2n-dimensional max-plus symplectic manifold (M, ω₊) admits local
    canonical coordinates (pᵢ₊, qᵢ₊) such that ω₊ = ⊕ᵢ max(dpᵢ₊, dqᵢ₊).
    
    The proof uses an idempotent version of Moser's homotopy trick:
    given two idempotent symplectic forms ω₊⁰ and ω₊¹ in the same idempotent
    cohomology class, the Moser flow φₜ satisfying φₜ*ω₊ᵗ = ω₊⁰ for
    ω₊ᵗ = max((1-t)·ω₊⁰, t·ω₊¹) provides the desired coordinate change.
    
    Bridge: connects symplectic topology to idempotent algebra via tropical geometry.
    Application: hamiltonian_flow_invariance (canonical transformations preserve ω₊) -/
theorem max_plus_symplectic_darboux {n : ℕ} [hN : NeZero n]
    (M : Type*) [TopologicalSpace M] [Manifold M]
    (omega_plus : IdempotentSymplecticForm n)
    (x : M)
    (h_smooth : ∀ v w, Continuous (fun p => omega_plus.omega_plus v w)) :
    ∃ (phi : M ≃ᵐ M) (p_coords q_coords : M → Fin n → ℝ),
      phi x = x ∧
      ∀ y ∈ nhds x, 
        omega_plus.omega_plus (p_coords y) (q_coords y) = 
          Finset.max' (Finset.univ.image (fun i : Fin n => max (p_coords y i) (q_coords y i))) 
            (Finset.univ_nonempty.mpr (Fin.cast hN.ne_zero · ▸ Finset.mem_univ (0 : Fin n))) := by
  sorry -- FILL WITH ACTUAL PROOF
```

**Proof Strategy A (Idempotent Moser Homotopy — Most Promising):**
1. Let `ω₊⁰` be the standard idempotent symplectic form in local coordinates and `ω₊¹ = ω₊`.
2. Define the idempotent Moser path: `ω₊ᵗ = max((1-t)·ω₊⁰, t·ω₊¹)` for `t ∈ [0,1]`.
3. Since `ω₊⁰` and `ω₊¹` are in the same idempotent cohomology class, `ω₊¹ = ω₊⁰ ⊕ d₊α` for some idempotent 1-form `α`.
4. The idempotent Moser equation: find `Xₜ` such that `ι_{Xₜ}ω₊ᵗ = -α` (non-degeneracy guarantees existence).
5. The flow `φₜ` of `Xₜ` satisfies `φ₁*ω₊¹ = ω₊⁰`, giving the Darboux chart.
6. The key step is establishing the idempotent homotopy formula: `d/dt(φₜ*ω₊ᵗ) = 0`, which uses `max`-differentiability.

### Theorem 4: `hamiltonian_flow_preserves_idempotent_symplectic`
Max-plus Hamiltonian flows preserve the idempotent symplectic form — the tropical analogue of Liouville's theorem.

```lean
/-- **Tropical Liouville Theorem**: Max-plus Hamiltonian flows preserve ω₊.
    Bridge: connects Hamiltonian mechanics to tropical conservation laws.
    Application: hamiltonian_flow_invariance, tropical_optimal_control -/
theorem hamiltonian_flow_preserves_idempotent_symplectic {n : ℕ} [hN : NeZero n]
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (omega_plus : IdempotentSymplecticForm n)
    (phi : ℝ → MaxPlusPhaseSpace n → MaxPlusPhaseSpace n)
    (h_flow : ∀ t x, deriv (fun s => phi s x) t = 
      idempotent_hamiltonian_vector_field H_plus omega_plus (phi t x))
    (t : ℝ) (v w : Fin n → ℝ) :
    omega_plus.omega_plus ((phi t)⁻¹* v) ((phi t)⁻¹* w) = 
      omega_plus.omega_plus v w := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 5: `dequantization_error_bound_lipschitz_certified`
An explicit, certified Lipschitz bound on the dequantization error, connecting tropical mechanics to certified robustness in ML.

```lean
/-- **Certified Dequantization Error Bound**.
    The error between the dequantized classical HJ solution and the tropical HJ solution
    satisfies a Lipschitz-certified bound with explicit constants.
    
    This is the key quantitative result connecting Maslov dequantization to
    certified_robustness_bounds for neural network dynamics in the tropical limit.
    
    Bridge: connects PDE error analysis to certified ML robustness.
    Application: certified_robustness_bounds, post_quantum_security -/
theorem dequantization_error_bound_lipschitz_certified {n : ℕ} [hN : NeZero n]
    (S_beta : ℝ → MaslovDequantization → (Fin n → ℝ) → ℝ)
    (S_plus : ℝ → (Fin n → ℝ) → ℝ)
    (L_H : ℝ) (h_L_H : 0 < L_H)
    (L_S : ℝ) (h_L_S : 0 < L_S)
    (h_lipschitz_S_beta : ∀ β ≥ 1, IsLipschitz (fun x => S_beta 0 (MaslovDequantization.mk β sorry) x) L_S)
    (h_lipschitz_S_plus : IsLipschitz (fun x => S_plus 0 x) L_S) :
    ∃ (C : ℝ) (δ : ℝ), 0 < C ∧ 0 < δ ∧ C ≤ 2 * L_S + 1 ∧ δ ≥ 1 / (2 * L_H + 1) ∧
      ∀ β ≥ 1 (t : ℝ) (x y : Fin n → ℝ),
        |(1/β) * Real.log (Real.exp (β * S_beta t (MaslovDequantization.mk β sorry) x)) - S_plus t x| ≤ 
          C * Real.exp (-β * δ) ∧
        |((1/β) * Real.log (Real.exp (β * S_beta t (MaslovDequantization.mk β sorry) x))) - 
         ((1/β) * Real.log (Real.exp (β * S_beta t (MaslovDequantization.mk β sorry) y)))| ≤ 
          L_S * Finset.sup' Finset.univ (Finset.univ_nonempty) (fun i => |x i - y i|) + C * Real.exp (-β * δ) := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 6: `tropical_noether_conservation`
Idempotent Noether theorem: symmetries of the max-plus Lagrangian yield tropical conservation laws.

```lean
/-- **Tropical Noether Theorem**: Continuous symmetries of the max-plus Lagrangian
    yield tropical conservation laws.
    
    If the max-plus Lagrangian L₊(q, q̇) = maxᵢ(qᵢ + q̇ᵢ) is invariant under
    a one-parameter family of idempotent transformations, then the corresponding
    tropical momentum is conserved along characteristic curves.
    
    Bridge: connects Noether's theorem to tropical invariant theory.
    Application: hamiltonian_flow_invariance, tropical_optimal_control -/
theorem tropical_noether_conservation {n : ℕ} [hN : NeZero n]
    (L_plus : MaxPlusPhaseSpace n → ℝ)
    (phi : ℝ → MaxPlusPhaseSpace n → MaxPlusPhaseSpace n)
    (h_symmetry : ∀ ε q, L_plus (phi ε q) = L_plus q)
    (gamma : ℝ → MaxPlusPhaseSpace n)
    (h_characteristic : IsMaxPlusCharacteristicCurve L_plus gamma) :
    ∃ (J : ℝ → ℝ) (h_const : ∀ t s, J t = J s),
      J = fun t => L_plus (gamma t) ⊖ deriv (fun s => L_plus (gamma s)) t := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 7: `logsumexp_tropical_convergence_rate`
The fundamental quantitative lemma: `logsumexp` converges to `max` with explicit rate, the computational engine behind dequantization.

```lean
/-- **LogSumExp Tropical Convergence Rate**.
    For any finite set of reals x₁,...,xₙ and parameter β > 0:
    |(1/β)log(Σᵢ exp(β·xᵢ)) - maxᵢ xᵢ| ≤ (log n)/β
    
    This is the precise quantitative bound that makes all dequantization
    convergence theorems work. The rate O(log(n)/β) is tight.
    
    Bridge: connects computational statistics to tropical algebra.
    Application: certified_robustness_bounds, tropical_hash_collision -/
theorem logsumexp_tropical_convergence_rate (n : ℕ) (hn : 0 < n) 
    (x : Fin n → ℝ) (beta : ℝ) (hbeta : 0 < beta) :
    let softmax_val := (1/beta) * Real.log (Finset.sum Finset.univ (fun i => Real.exp (beta * x i)))
    let max_val := Finset.max' (Finset.univ.image x) (Finset.univ_nonempty.mpr (Fin.cast hn.ne_zero · ▸ Finset.mem_univ (0 : Fin n)))
    |softmax_val - max_val| ≤ Real.log n / beta := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 8: `idempotent_hamilton_jacobi_characteristics`
Characteristic curves of the max-plus HJ equation are geodesics of the idempotent action.

```lean
/-- **Idempotent HJ Characteristics are Action Geodesics**.
    The characteristic curves of max(∂ₜS₊, H₊(∇₊S₊)) = 0 are precisely
    the geodesics minimizing the max-plus action functional.
    
    Bridge: connects PDE characteristic theory to tropical metric geometry.
    Application: tropical_optimal_control, certified_robustness_bounds -/
theorem idempotent_hamilton_jacobi_characteristics {n : ℕ} [hN : NeZero n]
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (S_plus : ℝ → (Fin n → ℝ) → ℝ)
    (gamma : ℝ → MaxPlusPhaseSpace n)
    (h_HJ : ∀ t x, max (deriv (fun s => S_plus s x) t) 
      (H_plus ⟨x, fun i => deriv (fun y => S_plus t y) x i, sorry⟩) = 0)
    (h_char : IsMaxPlusCharacteristic H_plus gamma) :
    IsMaxPlusActionGeodesic H_plus gamma := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 9: `moser_homotopy_idempotent_existence`
Existence of the idempotent Moser flow — the key technical ingredient for the Darboux theorem.

```lean
/-- **Idempotent Moser Homotopy Existence**.
    Given two idempotent symplectic forms ω₊⁰, ω₊¹ in the same idempotent
    cohomology class, there exists a smooth family of diffeomorphisms φₜ
    such that φₜ*ω₊ᵗ = ω₊⁰ where ω₊ᵗ = max((1-t)ω₊⁰, tω₊¹).
    
    Bridge: connects differential topology to tropical cohomology.
    Application: hamiltonian_flow_invariance -/
theorem moser_homotopy_idempotent_existence {n : ℕ} [hN : NeZero n]
    (omega_0 omega_1 : IdempotentSymplecticForm n)
    (h_cohomologous : ∃ alpha : (Fin n → ℝ) → (Fin n → ℝ) → ℝ,
      ∀ v w, omega_1.omega_plus v w = max (omega_0.omega_plus v w) (alpha v w) ∧
      ∀ u v w, alpha (max u v) w = max (alpha u w) (alpha v w)) :
    ∃ (phi : ℝ → (MaxPlusPhaseSpace n) ≃ (MaxPlusPhaseSpace n)) 
        (X : ℝ → MaxPlusPhaseSpace n → (Fin n → ℝ)),
      ∀ t v w, (phi t).symm (omega_t.omega_plus v w) = omega_0.omega_plus v w ∧
      deriv (fun s => (phi s) x) t = X t ((phi t) x) ∧
      ∀ v, max (omega_t.omega_plus (X t x) v) (alpha v (X t x)) = (0 : ℝ) := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 10: `tropical_hamiltonian_convexity_certified`
Certified convexity of the max-plus Hamiltonian — essential for uniqueness of viscosity solutions.

```lean
/-- **Certified Tropical Hamiltonian Convexity**.
    A max-plus Hamiltonian H₊ that is convex in the momentum variable
    satisfies a strong quantitative convexity bound with explicit modulus.
    
    Bridge: connects convex analysis to tropical optimization.
    Application: certified_robustness_bounds, tropical_optimal_control -/
theorem tropical_hamiltonian_convexity_certified {n : ℕ} [hN : NeZero n]
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (h_convex : ∀ q p₁ p₂ t, 
      H_plus ⟨q, fun i => max ((1-t) * p₁ i) (t * p₂ i), sorry⟩ ≤ 
      max ((1-t) * H_plus ⟨q, p₁, sorry⟩) (t * H_plus ⟨q, p₂, sorry⟩))
    (h_strict : ∃ mu : ℝ, 0 < mu ∧ 
      ∀ q p₁ p₂ t, t ∈ Set.Icc 0 1 → p₁ ≠ p₂ →
      H_plus ⟨q, fun i => max ((1-t) * p₁ i) (t * p₂ i), sorry⟩ ≤ 
      max ((1-t) * H_plus ⟨q, p₁, sorry⟩) (t * H_plus ⟨q, p₂, sorry⟩) - mu * t * (1-t) * 
        Finset.sup' Finset.univ (Finset.univ_nonempty) (fun i => |p₁ i - p₂ i|)) :
    mu > 0 := by
  sorry -- FILL WITH ACTUAL PROOF
```

### Theorem 11: `idempotent_poincare_recurrence`
Tropical Poincaré recurrence: max-plus Hamiltonian flows on compact phase space exhibit recurrence with explicit bounds.

```lean
/-- **Tropical Poincaré Recurrence**: Max-plus Hamiltonian flows on compact
    idempotent phase space return arbitrarily close to their starting point.
    Bridge: connects ergodic theory to tropical dynamical systems.
    Application: hamiltonian_flow_invariance, post_quantum_security -/
theorem idempotent_poincare_recurrence {n : ℕ} [hN : NeZero n]
    (H_plus : MaxPlusPhaseSpace n → ℝ)
    (phi : ℝ → MaxPlusPhaseSpace n → MaxPlusPhaseSpace n)
    (K : Set (MaxPlusPhaseSpace n))
    (h_compact : IsCompact K)
    (h_invariant : ∀ t x, x ∈ K → phi t x ∈ K)
    (h_measure : IsIdempotentHaarMeasure K)
    (epsilon : ℝ) (h_eps : 0 < epsilon) :
    ∃ (T : ℝ) (hT : 0 < T) (x₀ : MaxPlusPhaseSpace n) (hx₀ : x₀ ∈ K),
      ∃ t ∈ Set.Icc T (2 * T), 
        Finset.sup' Finset.univ (Finset.univ_nonempty) 
          (fun i => max |(phi t x₀).q_plus i - x₀.q_plus i| | |(phi t x₀).p_plus i - x₀.p_plus i|) < epsilon := by
  sorry -- FILL WITH ACTUAL PROOF
```

---

## III. SUPPORTING DEFINITIONS AND INSTANCES

```lean
/-- The idempotent Hamiltonian vector field: the tropical analogue of X_H.
    Defined by the idempotent symplectic equation ι_{X₊}ω₊ = d₊H₊. -/
def idempotent_hamiltonian_vector_field {n : ℕ} 
    (H : MaxPlusPhaseSpace n → ℝ) 
    (ω : IdempotentSymplecticForm n) 
    (p : MaxPlusPhaseSpace n) : Fin n → ℝ := 
  fun i => max (deriv (fun q => H q) p.q_plus i) (deriv (fun q => H q) p.p_plus i)

/-- A max-plus characteristic curve: tropical analogue of a Hamiltonian trajectory. -/
def IsMaxPlusCharacteristicCurve {n : ℕ} 
    (H : MaxPlusPhaseSpace n → ℝ) 
    (γ : ℝ → MaxPlusPhaseSpace n) : Prop :=
  ∀ t, deriv (fun s => (γ s).q_plus) t = 
    fun i => max (H (γ t)) (deriv (fun s => (γ s).p_plus) t i)

/-- A max-plus action geodesic: curve minimizing the tropical action. -/
def IsMaxPlusActionGeodesic {n : ℕ}
    (H : MaxPlusPhaseSpace n → ℝ)
    (γ : ℝ → MaxPlusPhaseSpace n) : Prop :=
  ∀ δ, IsMaxPlusCharacteristicCurve H δ → 
    MaxPlusActionFunctional.action (MaxPlusActionFunctional.mk n H 1 sorry) γ ≤
    MaxPlusActionFunctional.action (MaxPlusActionFunctional.mk n H 1 sorry) δ

/-- Idempotent Haar measure on compact subsets of max-plus phase space. -/
class IsIdempotentHaarMeasure (K : Set (MaxPlusPhaseSpace n)) : Prop where
  /-- Translation invariance under max-plus addition -/
  translation_invariant : ∀ v ∈ K, ∀ x ∈ K, max x v ∈ K
  /-- Finite measure -/
  finite : True -- placeholder for actual finiteness condition

/-- Viscosity solution typeclass for classical HJ equations. -/
class IsViscositySolution (S : ℝ → (Fin n → ℝ) → ℝ) (H : (Fin n → ℝ) → ℝ → ℝ) : Prop where
  is_subsolution : ∀ t x φ, (∀ s y, s = t ∧ y = x → φ s y ≤ S s y) → 
    deriv (fun s => φ s x) t + H (fun i => deriv (fun y => φ t y) x i) (x 0) ≤ 0
  is_supersolution : ∀ t x φ, (∀ s y, s = t ∧ y = x → φ s y ≥ S s y) →
    deriv (fun s => φ s x) t + H (fun i => deriv (fun y => φ t y) x i) (x 0) ≥ 0

/-- Lipschitz continuity typeclass. -/
def IsLipschitz (f : (Fin n → ℝ) → ℝ) (L : ℝ) : Prop :=
  ∀ x y, |f x - f y| ≤ L * Finset.sup' Finset.univ (Finset.univ_nonempty) (fun i => |x i - y i|)
```

---

## IV. CROSS-DOMAIN CONNECTIONS

1. **Physics ↔ Tropical Geometry**: The Maslov dequantization is the mathematical bridge between classical mechanics and tropical geometry. The parameter β plays the role of inverse temperature (ℏ → 0 in the classical limit), and the tropical limit β → ∞ is the "zero-temperature" or "idempotent" limit.

2. **PDE Theory ↔ Cryptography**: The dequantization convergence rate `O(log(n)/β)` is directly related to the hardness of lattice problems in post-quantum cryptography. The tropical limit of lattice-based hash functions connects to the convergence of viscosity solutions.

3. **Symplectic Geometry ↔ ML**: The idempotent symplectic form ω₊ = max(dp, dq) provides a certified Lipschitz bound for tropical neural network dynamics. The Darboux theorem guarantees the existence of canonical coordinates for tropical learning.

4. **Optimal Control ↔ Certified Robustness**: The max-plus least action principle gives a variational characterization of worst-case perturbations in tropical neural networks, enabling certified_robustness_bounds via tropical optimal control.

---

## V. SIGNIFICANCE AND FUTURE DIRECTIONS

This work opens the field of **tropical classical mechanics** — a complete idempotent counterpart to Hamiltonian mechanics. The three main theorems (Idempotent Least Action, Maslov Dequantization Convergence, Max-Plus Darboux) are the foundational pillars, analogous to the classical pillars of variational mechanics, PDE existence theory, and symplectic topology.

**Immediate applications:**
- **Certified robustness for tropical neural networks**: The Lipschitz bound in `dequantization_error_bound_lipschitz_certified` directly certifies robustness of tropical ReLU networks.
- **Post-quantum cryptography**: The dequantization convergence rate connects to lattice hardness assumptions.
- **Tropical optimal control**: The least action principle enables tropical MPC (Model Predictive Control).

**Requested FUTURE_DIRECTIONS.md:**
1. Tropical Hamilton-Jacobi-Bellman equation and its connection to RL value functions
2. Idempotent quantization: from max-plus to quantum (reverse Maslov dequantization)
3. Tropical symplectic topology: idempotent Floer homology and tropical Arnold conjecture
4. Certified tropical robustness for multi-class classification via max-plus Darboux charts
5. Tropical thermodynamic limit: max-plus statistical mechanics and idempotent partition functions

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of max-plus classical mechanics by proving three foundational theorems: (1) The Idempotent Least Action Principle — for a max-plus Hamiltonian H₊: ℝ²₊ → ℝ₊ on idempotent phase space, the max-plus action functional S₊[γ] = maxₜ H₊(γ(t), γ̇(t)) achieves its minimum on characteristic curves satisfying the idempotent Hamilton-Jacobi equation max(∂ₜS, H₊(∇S)) = 0, and the max-plus Hamiltonian flow preserves the idempotent symplectic form ω₊ = max(dp₊, dq₊). (2) Maslov Dequantization Convergence — the classical viscosity solution S_β of the Hamilton-Jacobi equation converges to the max-plus solution S₊ = lim_{β→∞} (1/β) log(exp(β · S_β)) as the deformation parameter β → ∞, establishing the tropical limit as a rigorous dequantization of classical mechanics. (3) Max-Plus Symplectic Darboux Theorem — every 2n-dimensional max-plus symplectic manifold (M, ω₊) admits local canonical coordinates (pᵢ₊, qᵢ₊) with ω₊ = maxᵢ(dpᵢ₊, dqᵢ₊), proved via idempotent Moser homotopy.

            ### Precise Mathematical Framing
            Define the max-plus phase space T₊ℝⁿ = ℝⁿ₊ × ℝⁿ₊ with idempotent symplectic form ω₊(u,v) = max(uᵖ, vᵍ) where (p,g) are canonical coordinates. A max-plus Hamiltonian H₊: T₊ℝⁿ → ℝ₊ generates flow via the idempotent Hamilton equations: ṗ₊ = ∂H₊/∂q₊, q̇₊ = ∂H₊/∂p₊ (derivatives in max-plus calculus). The idempotent Hamilton-Jacobi equation is max(∂ₜS, H₊(∇S)) = 0 with solution S₊ given by the max-plus Lax-Oleinik semigroup S₊(x,t) = max_y {S₊(y,0) + A₊(y,x,t)} where A₊ is the max-plus action. Maslov dequantization: define S_β = (1/β)log(exp(β·S_classical)) and prove S_β → S₊ as β→∞ in the sup-norm, using the log-limit relation between arithmetic and max-plus. The Darboux theorem: given ω₊ a closed idempotent 2-form on M, construct canonical coordinates by idempotent Moser iteration: define ωₜ = max((1-t)ω₊, tω₀) and prove the isotopy ϕₜ*ωₜ = ω₊ via the idempotent homotopy formula.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_universal_idempotent` : theorem tropical_universal_idempotent (a : ℝ) : max a a = a := max_self a
     (file: Physics/ArchitectureOfReality/TropicalLanglands.lean)
  2. `stationary_achieves_tropical` : theorem stationary_achieves_tropical {n : ℕ} [NeZero n]
     (file: Physics/Quantum/TropicalFeynman.lean)
  3. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  4. `logsumexp_le_max_plus_log2` : theorem logsumexp_le_max_plus_log2 (x y : ℝ) :
     (file: Bridges/UnifiedFramework.lean)
  5. `power_via_exp_log` : theorem power_via_exp_log (a b : ℝ) (ha : 0 < a) :
     (file: EML/ExtendedTheory.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Berggren Lattice Cryptography: Hyperbolic SVP Hardness, Factoring Reduction, and Post-Quantum Key Exchange via Pythagorean Geometry, Tropical Arithmetic Geometry: Cuspidal Factorization, Max-Plus Valuation Superadditivity, and Prime Decomposition Recovery on the Berggren Tree, Tropical Certified Robustness: Max-Plus Spectral Composition and Layerwise Verification Bounds for Deep Networks


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Physics
Research mode: prove
