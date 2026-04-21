/-! # CatalogBuild.Speculative.Other.QuantumPhaseLatticeExtended

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

/-- **Theorem 21 (Orthogonal complement antimonotonicity).**
If K₁ ≤ K₂ then K₂ᗮ ≤ K₁ᗮ. The orthogonal complement reverses
the lattice ordering, forming a Galois connection. -/
theorem orthogonal_complement_antimono
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K₁ K₂ : Submodule ℂ E) (h : K₁ ≤ K₂) :
    K₂ᗮ ≤ K₁ᗮ :=
  Submodule.orthogonal_le h




/-- **Theorem 22 (Double orthogonal complement).**
For a closed subspace with orthogonal projection, Kᗮᗮ = K. -/
theorem double_orthogonal_eq
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K : Submodule ℂ E) [K.HasOrthogonalProjection] :
    Kᗮᗮ = K :=
  Submodule.orthogonal_orthogonal K




/-- **Theorem 23 (Orthogonal complement decomposition).**
Every vector decomposes as v = P_K(v) + P_{K⊥}(v), i.e. K ⊔ K⊥ = ⊤. -/
theorem orthogonal_complement_spans_top
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K : Submodule ℂ E) [K.HasOrthogonalProjection] :
    K ⊔ Kᗮ = ⊤ :=
  Submodule.sup_orthogonal_of_hasOrthogonalProjection




/-- **Theorem 24 (Orthogonal complement disjointness).**
K ⊓ K⊥ = ⊥: a vector orthogonal to itself in an inner product space is zero. -/
theorem orthogonal_complement_disjoint
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K : Submodule ℂ E) :
    Disjoint K Kᗮ :=
  Submodule.orthogonal_disjoint K




/-- [Section: # CatalogBuild.Speculative.Other.QuantumPhaseLatticeExtended
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
theorem orthomodular_law
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K L : Submodule ℂ E) [K.HasOrthogonalProjection]
    [L.HasOrthogonalProjection] (hKL : K ≤ L) :
    L = K ⊔ (L ⊓ Kᗮ) := by
  refine' le_antisymm _ _;
  · intro x hx;
    -- By the orthogonal decomposition theorem, we can write $x$ as $x = y + z$ where $y \in K$ and $z \in K^\perp$.
    obtain ⟨y, z, hyK, hzK, hx_eq⟩ : ∃ y ∈ K, ∃ z ∈ Kᗮ, x = y + z := by
      exact?;
    simp_all +decide [ Submodule.mem_sup, Submodule.mem_inf ];
    exact ⟨ y, z, hyK, ⟨ by simpa using L.sub_mem hx ( hKL z ), hzK ⟩, rfl ⟩;
  · aesop




/-- **Theorem 26 (De Morgan for orthogonal complements).**
(K₁ ⊔ K₂)ᗮ = K₁ᗮ ⊓ K₂ᗮ — meets and joins dualize under orthocomplementation. -/
theorem orthogonal_complement_sup
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    (K₁ K₂ : Submodule ℂ E) :
    (K₁ ⊔ K₂)ᗮ = K₁ᗮ ⊓ K₂ᗮ :=
  (Submodule.inf_orthogonal K₁ K₂).symm




/-- **Theorem 27 (Adjoint inner product identity).**
⟨A†y, x⟩ = ⟨y, Ax⟩ — the defining property of the adjoint. -/
theorem adjoint_inner_left'
    {E F : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]
    [InnerProductSpace ℂ E] [InnerProductSpace ℂ F]
    [CompleteSpace E] [CompleteSpace F]
    (A : E →L[ℂ] F) (x : E) (y : F) :
    @inner ℂ E _ (adjoint A y) x = @inner ℂ F _ y (A x) :=
  ContinuousLinearMap.adjoint_inner_left A x y




/-- [Section: # CatalogBuild.Speculative.Other.QuantumPhaseLatticeExtended
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20] -/
theorem adjoint_adjoint'
    {E F : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]
    [InnerProductSpace ℂ E] [InnerProductSpace ℂ F]
    [CompleteSpace E] [CompleteSpace F]
    (A : E →L[ℂ] F) :
    adjoint (adjoint A) = A := by
  exact?




theorem self_adjoint_real_inner
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    [CompleteSpace E]
    (A : E →L[ℂ] E) (hA : adjoint A = A) (v : E) :
    RCLike.im (@inner ℂ E _ (A v) v) = 0 := by
  rw [ ← hA, ← inner_conj_symm ];
  rw [ ← inner_conj_symm, ← ContinuousLinearMap.adjoint_inner_right ] ; simp +decide;
  -- By definition of adjoint, we know that ⟨Av, v⟩ = ⟨v, Av⟩.
  have h_adj : (inner ℂ (A v) v) = (inner ℂ v (A v)) := by
    rw [ ← ContinuousLinearMap.adjoint_inner_right, hA ];
  rw [ ← inner_conj_symm, ← Complex.conj_eq_iff_im ] at * ; aesop




theorem adjoint_norm_eq'
    {E F : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]
    [InnerProductSpace ℂ E] [InnerProductSpace ℂ F]
    [CompleteSpace E] [CompleteSpace F]
    (A : E →L[ℂ] F) :
    ‖adjoint A‖ = ‖A‖ := by
  simp_all +decide [ ContinuousLinearMap.adjointAux, ContinuousLinearMap.ext_iff ]




/-- **Theorem 31 (Quantum channel norm-boundedness).**
A bounded linear map satisfies ‖Tv‖ ≤ ‖T‖ · ‖v‖ for all v. -/
theorem quantum_channel_norm_bound
    {E F : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]
    [NormedSpace ℂ E] [NormedSpace ℂ F]
    (T : E →L[ℂ] F) (v : E) :
    ‖T v‖ ≤ ‖T‖ * ‖v‖ :=
  T.le_opNorm v




/-- **Theorem 32 (Identity channel has norm 1).**
The identity map on a nontrivial space has operator norm 1. -/
theorem identity_channel_norm
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E]
    [Nontrivial E] :
    ‖ContinuousLinearMap.id ℂ E‖ = 1 :=
  ContinuousLinearMap.norm_id




theorem contractive_channel_convergence
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℂ E]
    (T : E →L[ℂ] E) (hT : ‖T‖ < 1) (v : E) :
    Filter.Tendsto (fun n => ‖(T ^ n) v‖) Filter.atTop (nhds 0) := by
  -- Since ‖T‖ < 1, we have ‖T^n‖ ≤ ‖T‖^n.
  have h_norm_pow : ∀ n : ℕ, ‖T^n‖ ≤ ‖T‖^n := by
    intro n;
    induction' n with n ih;
    · exact ContinuousLinearMap.opNorm_le_bound _ zero_le_one fun v => by simp +decide;
    · simpa only [ pow_succ' ] using le_trans ( ContinuousLinearMap.opNorm_comp_le _ _ ) ( mul_le_mul_of_nonneg_left ih ( norm_nonneg _ ) );
  exact squeeze_zero ( fun _ => norm_nonneg _ ) ( fun n => ContinuousLinearMap.le_opNorm _ _ |> le_trans <| mul_le_mul_of_nonneg_right ( h_norm_pow n ) <| norm_nonneg _ ) <| by simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( norm_nonneg _ ) hT ) tendsto_const_nhds;




theorem adjoint_comp'
    {E F G : Type*} [NormedAddCommGroup E] [NormedAddCommGroup F]
    [NormedAddCommGroup G]
    [InnerProductSpace ℂ E] [InnerProductSpace ℂ F] [InnerProductSpace ℂ G]
    [CompleteSpace E] [CompleteSpace F] [CompleteSpace G]
    (T₁ : E →L[ℂ] F) (T₂ : F →L[ℂ] G) :
    adjoint (T₂.comp T₁) = (adjoint T₁).comp (adjoint T₂) := by
  ext x y; simp +decide [ adjoint_inner_right ] ;




theorem tensor_submodule_monotone
    {V W : Type*} [AddCommGroup V] [AddCommGroup W]
    [Module ℂ V] [Module ℂ W]
    (K₁ K₂ : Submodule ℂ V) (L₁ L₂ : Submodule ℂ W)
    (hK : K₁ ≤ K₂) (hL : L₁ ≤ L₂) :
    Submodule.map (TensorProduct.mapIncl K₁ L₁)
      ⊤ ≤ Submodule.map (TensorProduct.mapIncl K₂ L₂) ⊤ := by
  intro x hx;
  obtain ⟨ y, hy, rfl ⟩ := hx;
  induction y using TensorProduct.induction_on <;> simp_all +decide;
  · rename_i x y;
    exact ⟨ TensorProduct.tmul ℂ ⟨ x, hK x.2 ⟩ ⟨ y, hL y.2 ⟩, rfl ⟩;
  · case _ hx hy => obtain ⟨ y₁, hy₁ ⟩ := hx; obtain ⟨ y₂, hy₂ ⟩ := hy; exact ⟨ y₁ + y₂, by simp +decide [ hy₁, hy₂ ] ⟩ ;




theorem tensor_sup_contains
    {V W : Type*} [AddCommGroup V] [AddCommGroup W]
    [Module ℂ V] [Module ℂ W]
    (K₁ K₂ : Submodule ℂ V) (L : Submodule ℂ W) :
    Submodule.map (TensorProduct.mapIncl K₁ L) ⊤ ⊔
    Submodule.map (TensorProduct.mapIncl K₂ L) ⊤ ≤
    Submodule.map (TensorProduct.mapIncl (K₁ ⊔ K₂) L) ⊤ := by
  refine' sup_le _ _;
  · intro x;
    rintro ⟨ x, -, rfl ⟩;
    refine' ⟨ TensorProduct.map ( Submodule.inclusion le_sup_left ) ( LinearMap.id ) x, _ ⟩;
    induction x using TensorProduct.induction_on <;> aesop;
  · exact tensor_submodule_monotone _ _ _ _ le_sup_right le_rfl




theorem eigenspace_is_submodule
    {E : Type*} [AddCommGroup E] [Module ℂ E]
    (T : E →ₗ[ℂ] E) (mu : ℂ) :
    ∃ K : Submodule ℂ E, ∀ v : E, v ∈ K ↔ T v = mu • v := by
  refine' ⟨ LinearMap.ker ( T - mu • LinearMap.id ), _ ⟩;
  simp +decide [ sub_eq_zero ]




theorem eigenspaces_disjoint
    {E : Type*} [AddCommGroup E] [Module ℂ E]
    (T : E →ₗ[ℂ] E) (mu1 mu2 : ℂ) (hne : mu1 ≠ mu2)
    (v : E) (h1 : T v = mu1 • v) (h2 : T v = mu2 • v) :
    v = 0 := by
  exact Classical.not_not.1 fun h => hne <| smul_left_injective _ h <| by aesop;




theorem self_adjoint_eigenvalue_real
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    [CompleteSpace E]
    (A : E →L[ℂ] E) (hA : adjoint A = A)
    (v : E) (hv : v ≠ 0) (mu : ℂ) (heig : A v = mu • v) :
    RCLike.im mu = 0 := by
  have h_inner : inner ℂ (A v) v = inner ℂ v (A v) := by
    rw [ ← ContinuousLinearMap.adjoint_inner_right, hA ];
  simp_all +decide [ mul_comm, Complex.ext_iff, sq ];
  nlinarith [ norm_pos_iff.mpr hv, mul_pos ( norm_pos_iff.mpr hv ) ( norm_pos_iff.mpr hv ) ]




theorem self_adjoint_eigenvectors_orthogonal
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    [CompleteSpace E]
    (A : E →L[ℂ] E) (hA : adjoint A = A)
    (v w : E) (mu1 mu2 : ℂ) (hne : mu1 ≠ mu2)
    (h1 : A v = mu1 • v) (h2 : A w = mu2 • w) :
    @inner ℂ E _ v w = 0 := by
  by_contra h_neq;
  have h_inner : inner ℂ (A v) w = inner ℂ v (A w) := by
    rw [ ← ContinuousLinearMap.adjoint_inner_right, hA ];
  have h_real : RCLike.im mu1 = 0 := by
    apply self_adjoint_eigenvalue_real A hA v (by
    aesop) mu1 h1;
  simp_all +decide [ Complex.ext_iff, mul_comm ];
  have h_real2 : RCLike.im mu2 = 0 := by
    apply_rules [ self_adjoint_eigenvalue_real ];
    aesop;
  simp_all +decide [ RCLike.im ]




end
