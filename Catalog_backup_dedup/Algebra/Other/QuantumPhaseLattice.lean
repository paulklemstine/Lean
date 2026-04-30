import Mathlib

/-! # CatalogBuild.Speculative.Other.QuantumPhaseLattice

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18
-/

noncomputable section

/-- The submodules of a complex vector space form a complete lattice,
i.e. every set of submodules has a supremum. This is the quantum
phase lattice: the lattice of closed subspaces of a Hilbert space
generalizes the classical ECSTASIS phase lattice. -/
theorem quantum_phase_lattice_is_complete_lattice
    (V : Type*) [AddCommGroup V] [Module ℂ V] :
    ∀ (S : Set (Submodule ℂ V)), ∃ s, IsLUB S s := fun S =>
  ⟨sSup S, isLUB_sSup S⟩

/-- The norm of a quantum superposition is bounded by the sum of norms. -/
theorem superposition_norm_bound
    {V : Type*} [SeminormedAddCommGroup V]
    (ψ φ : V) :
    ‖ψ + φ‖ ≤ ‖ψ‖ + ‖φ‖ :=
  norm_add_le ψ φ

/-- Generalized superposition bound for n quantum states. -/
theorem superposition_norm_bound_finset
    {V : Type*} [SeminormedAddCommGroup V]
    (n : ℕ) (states : Fin n → V) :
    ‖∑ i, states i‖ ≤ ∑ i, ‖states i‖ :=
  norm_sum_le _ _

/-- The Born rule probability |⟨ψ|φ⟩|² is non-negative. -/
theorem born_rule_nonneg
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    0 ≤ ‖@inner ℂ V _ ψ φ‖ ^ 2 := by
  positivity

/-- Cauchy-Schwarz bounds Born rule: |⟨ψ|φ⟩| ≤ ‖ψ‖·‖φ‖. -/
theorem born_rule_cauchy_schwarz
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    ‖@inner ℂ V _ ψ φ‖ ≤ ‖ψ‖ * ‖φ‖ :=
  norm_inner_le_norm ψ φ

/-- Global phase invariance of norm: ‖e^{iθ} · ψ‖ = ‖ψ‖. -/
theorem phase_invariance_norm
    {V : Type*} [NormedAddCommGroup V] [NormedSpace ℂ V]
    (ψ : V) (θ : ℝ) :
    ‖Complex.exp (↑θ * Complex.I) • ψ‖ = ‖ψ‖ := by
  rw [norm_smul, Complex.norm_exp_ofReal_mul_I, one_mul]

/-- Phase invariance of inner product magnitude: |⟨ψ|e^{iθ}φ⟩| = |⟨ψ|φ⟩|. -/
theorem phase_invariance_inner_norm
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) (θ : ℝ) :
    ‖@inner ℂ V _ ψ (Complex.exp (↑θ * Complex.I) • φ)‖ =
    ‖@inner ℂ V _ ψ φ‖ := by
  rw [inner_smul_right]
  simp [Complex.norm_exp_ofReal_mul_I]

/-- The real part of the inner product (interference term) is bounded:
|Re⟨ψ|φ⟩| ≤ ‖ψ‖·‖φ‖. -/
theorem quantum_coherence_bound
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    |RCLike.re (@inner ℂ V _ ψ φ)| ≤ ‖ψ‖ * ‖φ‖ := by
  calc |RCLike.re (@inner ℂ V _ ψ φ)|
      ≤ ‖@inner ℂ V _ ψ φ‖ := Complex.abs_re_le_norm _
    _ ≤ ‖ψ‖ * ‖φ‖ := norm_inner_le_norm ψ φ

/-- [Section: # CatalogBuild.Speculative.Other.QuantumPhaseLattice
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18] -/
theorem quantum_interference_formula
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    ‖ψ + φ‖ ^ 2 = ‖ψ‖ ^ 2 + ‖φ‖ ^ 2 + 2 * RCLike.re (@inner ℂ V _ ψ φ) := by
  rw [ @norm_add_sq ℂ ];
  ring

/-- [Section: # CatalogBuild.Speculative.Other.QuantumPhaseLattice
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 18] -/
theorem projection_norm_le
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (K : Submodule ℂ V) [K.HasOrthogonalProjection]
    (ψ : V) :
    ‖(orthogonalProjection K ψ : V)‖ ≤ ‖ψ‖ := by
  -- Use the fact that the orthogonal projection $P$ of $\psi$ onto $K$ satisfies $\|P\psi\| \leq \|\psi\|$.
  have hProj : ∀ ψ : V, ‖K.orthogonalProjection ψ‖ ≤ ‖ψ‖ := by
    exact fun ψ => norm_orthogonalProjection_apply_le K ψ;
  exact hProj ψ

/-- Fidelity is symmetric: |⟨ψ|φ⟩| = |⟨φ|ψ⟩|. -/
theorem fidelity_symmetric
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    ‖@inner ℂ V _ ψ φ‖ = ‖@inner ℂ V _ φ ψ‖ := by
  rw [← inner_conj_symm ψ φ, RCLike.norm_conj]

/-- Orthogonal states have zero fidelity. -/
theorem fidelity_orthogonal
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) (horth : @inner ℂ V _ ψ φ = 0) :
    ‖@inner ℂ V _ ψ φ‖ = 0 := by
  simp [horth]

/-- The submodule lattice is modular: if A ≤ C then A ⊔ (B ⊓ C) = (A ⊔ B) ⊓ C. -/
theorem quantum_lattice_modular
    {V : Type*} [AddCommGroup V] [Module ℂ V]
    (A B C : Submodule ℂ V) (hAC : A ≤ C) :
    A ⊔ (B ⊓ C) = (A ⊔ B) ⊓ C :=
  (sup_inf_assoc_of_le B hAC).symm

/-- The norm of αψ + βφ is bounded by |α|‖ψ‖ + |β|‖φ‖. -/
theorem quantum_phase_sensitivity_bound
    {V : Type*} [NormedAddCommGroup V] [NormedSpace ℂ V]
    (ψ φ : V) (α β : ℂ) :
    ‖α • ψ + β • φ‖ ≤ ‖α‖ * ‖ψ‖ + ‖β‖ * ‖φ‖ := by
  calc ‖α • ψ + β • φ‖
      ≤ ‖α • ψ‖ + ‖β • φ‖ := norm_add_le _ _
    _ = ‖α‖ * ‖ψ‖ + ‖β‖ * ‖φ‖ := by rw [norm_smul, norm_smul]

/-- A norm-nonincreasing linear map is 1-Lipschitz, enabling application
of the ECSTASIS fixed-point convergence framework. -/
theorem quantum_channel_lipschitz
    {V W : Type*} [NormedAddCommGroup V] [NormedAddCommGroup W]
    [NormedSpace ℂ V] [NormedSpace ℂ W]
    (T : V →L[ℂ] W) (hT : ‖T‖ ≤ 1) :
    LipschitzWith 1 T :=
  T.lipschitz.weaken (by exact_mod_cast hT)

/-- Composition of quantum channels: ‖T₂ ∘ T₁‖ ≤ ‖T₂‖ · ‖T₁‖. -/
theorem quantum_channel_composition_bound
    {V W U : Type*} [NormedAddCommGroup V] [NormedAddCommGroup W]
    [NormedAddCommGroup U]
    [NormedSpace ℂ V] [NormedSpace ℂ W] [NormedSpace ℂ U]
    (T₁ : V →L[ℂ] W) (T₂ : W →L[ℂ] U) :
    ‖T₂.comp T₁‖ ≤ ‖T₂‖ * ‖T₁‖ :=
  ContinuousLinearMap.opNorm_comp_le T₂ T₁

/-- The parallelogram law: ‖ψ+φ‖² + ‖ψ-φ‖² = 2(‖ψ‖² + ‖φ‖²).
This characterizes inner product spaces and constrains the geometry
of the quantum phase lattice. -/
theorem quantum_parallelogram_law
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) :
    ‖ψ + φ‖ ^ 2 + ‖ψ - φ‖ ^ 2 = 2 * (‖ψ‖ ^ 2 + ‖φ‖ ^ 2) := by
  have h := parallelogram_law_with_norm ℂ ψ φ
  nlinarith [sq_abs ‖ψ + φ‖, sq_abs ‖ψ - φ‖, sq_abs ‖ψ‖, sq_abs ‖φ‖]

/-- A norm-bounded linear self-map is Lipschitz, connecting to the
ECSTASIS contraction/fixed-point framework for quantum channels. -/
theorem quantum_phase_lattice_transport
    {V : Type*} [NormedAddCommGroup V] [NormedSpace ℂ V]
    (U : V →L[ℂ] V) (hU : ‖U‖ ≤ 1) :
    LipschitzWith 1 U :=
  U.lipschitz.weaken (by exact_mod_cast hU)

end
