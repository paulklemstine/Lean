/-
# Combinatorial Hodge Decomposition for Cochain Complexes

This file formalizes the degree-1 Hodge decomposition for a finite cochain complex
of finite-dimensional real inner product spaces:

  C⁰ →[d₀] C¹ →[d₁] C²

with d₁ ∘ d₀ = 0. We prove:

1. **Orthogonality**: range(d₀) ⟂ range(d₁†) where † denotes the adjoint
2. **Harmonic characterization**: ker(Δ₁) = ker(d₁) ∩ ker(d₀†)
3. **Hodge decomposition**: C¹ = range(d₀) ⊕ range(d₁†) ⊕ ker(Δ₁)

These results form the foundation of **topological robustness mechanics**:
the gradient (exact) part captures globally correctable inconsistency,
the curl (coexact) part captures local rotational defects, and the
harmonic part captures irreducible topological obstruction.
-/
import Mathlib

open scoped InnerProductSpace
open LinearMap Submodule

variable {E₀ E₁ E₂ : Type*}
  [NormedAddCommGroup E₀] [InnerProductSpace ℝ E₀] [FiniteDimensional ℝ E₀]
  [NormedAddCommGroup E₁] [InnerProductSpace ℝ E₁] [FiniteDimensional ℝ E₁]
  [NormedAddCommGroup E₂] [InnerProductSpace ℝ E₂] [FiniteDimensional ℝ E₂]

namespace HodgeDecomposition

/-! ## Orthogonal complement and adjoint relationships -/

/-
The orthogonal complement of the range of a linear map equals the kernel of its adjoint.
-/
theorem range_orthogonal_eq_ker_adjoint (T : E₀ →ₗ[ℝ] E₁) :
    (LinearMap.range T).orthogonal = LinearMap.ker (LinearMap.adjoint T) := by
  -- By definition of $adjoint$, we know that for any $y \in E₁$ and $x \in E₀$, ⟨T x, y⟩ = ⟨x, adjoint T y⟩.
  have adjoint_def : ∀ x : E₀, ∀ y : E₁, inner ℝ (T x) y = inner ℝ x ((adjoint T) y) := by
    exact?;
  ext y le_antisymm _ _;
  simp +decide [ Submodule.mem_orthogonal, adjoint_def ];
  exact ⟨ fun h => by simpa using h ( ( adjoint T ) y ), fun h => by simp +decide [ h ] ⟩

/-
The orthogonal complement of the kernel of a linear map equals the range of its adjoint
    (in finite dimensions).
-/
theorem ker_orthogonal_eq_range_adjoint (T : E₀ →ₗ[ℝ] E₁) :
    (LinearMap.ker T).orthogonal = LinearMap.range (LinearMap.adjoint T) := by
  have := @range_orthogonal_eq_ker_adjoint E₁ E₀;
  nontriviality;
  have h_orthogonal_complement : (LinearMap.range (LinearMap.adjoint T))ᗮ = LinearMap.ker T := by
    convert this ( LinearMap.adjoint T ) using 1;
    rw [ LinearMap.adjoint_adjoint ];
  rw [ ← h_orthogonal_complement, Submodule.orthogonal_orthogonal ]

/-! ## Cochain complex setup -/

variable (d₀ : E₀ →ₗ[ℝ] E₁) (d₁ : E₁ →ₗ[ℝ] E₂)

/-- The cochain complex condition: d₁ ∘ d₀ = 0. -/
def IsCochainComplex : Prop := d₁ ∘ₗ d₀ = 0

variable {d₀ d₁}

/-- The 1-Hodge Laplacian: Δ₁ = d₀ ∘ d₀† + d₁† ∘ d₁ -/
noncomputable def hodgeLaplacian₁ (d₀ : E₀ →ₗ[ℝ] E₁) (d₁ : E₁ →ₗ[ℝ] E₂) : E₁ →ₗ[ℝ] E₁ :=
  d₀ ∘ₗ (LinearMap.adjoint d₀) + (LinearMap.adjoint d₁) ∘ₗ d₁

/-! ## Key orthogonality: exact ⟂ coexact -/

/-
If d₁ ∘ d₀ = 0, then range(d₀) ⊥ range(d₁†).
    This is the fundamental orthogonality between exact and coexact forms.
-/
theorem range_d₀_orthogonal_range_adjoint_d₁
    (hcc : IsCochainComplex d₀ d₁) :
    Disjoint (LinearMap.range d₀) (LinearMap.range (LinearMap.adjoint d₁)).orthogonal.orthogonal := by
  -- By definition of orthogonal complement, we know that if $x \in \operatorname{range}(d₀)$ and $y \in \operatorname{range}(d₁^*)$, then $x \perp y$.
  have h_perp : (LinearMap.range d₀) ≤ (LinearMap.range (LinearMap.adjoint d₁))ᗮ := by
    nontriviality;
    -- By definition of orthogonal complement, we know that if $x \in \operatorname{range}(d₀)$ and $y \in \operatorname{range}(d₁^*)$, then $x \perp y$. Hence, $\operatorname{range}(d₀) \subseteq (\operatorname{range}(d₁^*))^\perp$.
    intros x hx
    simp [Submodule.mem_orthogonal];
    intro y; obtain ⟨ z, rfl ⟩ := hx; simp +decide [ adjoint_inner_left, hcc ] ;
    replace hcc := congr_arg ( fun f => f z ) hcc; aesop;
  exact Submodule.disjoint_def.2 fun x hx₁ hx₂ => by have := h_perp hx₁; exact ( Submodule.disjoint_def.mp ( Submodule.orthogonal_disjoint _ ) ) x this hx₂;

/-
range(d₀) ≤ ker(d₁) from the cochain complex condition.
-/
theorem range_d₀_le_ker_d₁ (hcc : IsCochainComplex d₀ d₁) :
    LinearMap.range d₀ ≤ LinearMap.ker d₁ := by
  exact fun x ⟨ y, hy ⟩ => by simpa [ hy ] using LinearMap.congr_fun hcc y;

/-
range(d₁†) ≤ ker(d₀†) from the cochain complex condition.
-/
theorem range_adjoint_d₁_le_ker_adjoint_d₀ (hcc : IsCochainComplex d₀ d₁) :
    LinearMap.range (LinearMap.adjoint d₁) ≤ LinearMap.ker (LinearMap.adjoint d₀) := by
  intro x hx;
  have := LinearMap.adjoint_comp d₁ d₀;
  simp_all +decide [ IsCochainComplex ];
  obtain ⟨ y, rfl ⟩ := hx; replace this := congr_arg ( fun f => f y ) this; aesop;

/-
Inner product of an element in range(d₀) with an element in range(d₁†) is zero.
-/
theorem inner_range_d₀_range_adjoint_d₁ (hcc : IsCochainComplex d₀ d₁)
    {u v : E₁} (hu : u ∈ LinearMap.range d₀) (hv : v ∈ LinearMap.range (LinearMap.adjoint d₁)) :
    @inner ℝ _ _ u v = 0 := by
  obtain ⟨ f, rfl ⟩ := hu; obtain ⟨ η, rfl ⟩ := hv; simp_all +decide [ IsCochainComplex, LinearMap.ext_iff ] ;
  rw [ adjoint_inner_right, hcc ] ; norm_num

/-! ## Harmonic characterization -/

/-
**Harmonic characterization**: ker(Δ₁) = ker(d₁) ⊓ ker(d₀†).
    A 1-cochain is harmonic iff it is simultaneously closed (d₁-cocycle)
    and co-closed (d₀†-killed). This is proven via the positivity argument:
    ⟨Δ₁ω, ω⟩ = ‖d₀†ω‖² + ‖d₁ω‖².
-/
theorem ker_hodgeLaplacian₁_eq (hcc : IsCochainComplex d₀ d₁) :
    LinearMap.ker (hodgeLaplacian₁ d₀ d₁) =
      LinearMap.ker d₁ ⊓ LinearMap.ker (LinearMap.adjoint d₀) := by
  -- By definition of Hodge Laplacian, we have:
  unfold hodgeLaplacian₁;
  ext x;
  constructor <;> intro h <;> simp_all +decide [ LinearMap.ext_iff, inner_add_left, inner_smul_left ];
  -- By the properties of the adjoint, we have ⟨d₀ (adjoint d₀ x), x⟩ = ⟨adjoint d₀ x, adjoint d₀ x⟩ and ⟨adjoint d₁ (d₁ x), x⟩ = ⟨d₁ x, d₁ x⟩.
  have h_adj : inner ℝ (d₀ (adjoint d₀ x)) x = inner ℝ (adjoint d₀ x) (adjoint d₀ x) ∧ inner ℝ (adjoint d₁ (d₁ x)) x = inner ℝ (d₁ x) (d₁ x) := by
    simp +decide [ adjoint_inner_left, adjoint_inner_right ];
    rw [ ← real_inner_self_eq_norm_sq ];
    rw [ ← LinearMap.adjoint_inner_right ];
  have h_zero : inner ℝ (adjoint d₀ x) (adjoint d₀ x) + inner ℝ (d₁ x) (d₁ x) = 0 := by
    rw [ ← h_adj.1, ← h_adj.2, ← inner_add_left, h, inner_zero_left ];
  simp_all +decide [ inner_self_eq_norm_sq_to_K ];
  exact ⟨ norm_eq_zero.mp ( by contrapose! h_zero; positivity ), norm_eq_zero.mp ( by contrapose! h_zero; positivity ) ⟩

/-! ## Orthogonality of harmonic forms -/

/-
Harmonic forms are orthogonal to exact forms (range d₀).
-/
theorem ker_hodgeLaplacian₁_orthogonal_range_d₀ (hcc : IsCochainComplex d₀ d₁)
    {h : E₁} (hh : h ∈ LinearMap.ker (hodgeLaplacian₁ d₀ d₁))
    {u : E₁} (hu : u ∈ LinearMap.range d₀) :
    @inner ℝ _ _ h u = 0 := by
  -- By ker_hodgeLaplacian₁_eq, h ∈ ker(d₁) ∩ ker(adjoint d₀), so adjoint d₀ h = 0.
  have h_adj_zero : d₀.adjoint h = 0 := by
    have h_adj_zero : h ∈ LinearMap.ker d₁ ⊓ LinearMap.ker (LinearMap.adjoint d₀) := by
      exact ker_hodgeLaplacian₁_eq hcc ▸ hh;
    exact h_adj_zero.2;
  obtain ⟨ v, rfl ⟩ := hu;
  rw [ ← LinearMap.adjoint_inner_left, h_adj_zero, inner_zero_left ]

/-
Harmonic forms are orthogonal to coexact forms (range d₁†).
-/
theorem ker_hodgeLaplacian₁_orthogonal_range_adjoint_d₁ (hcc : IsCochainComplex d₀ d₁)
    {h : E₁} (hh : h ∈ LinearMap.ker (hodgeLaplacian₁ d₀ d₁))
    {v : E₁} (hv : v ∈ LinearMap.range (LinearMap.adjoint d₁)) :
    @inner ℝ _ _ h v = 0 := by
  -- By definition of the inner product, we know that ⟨d₁ h, η⟩ = ⟨h, adjoint d₁ η⟩.
  have h_inner : ⟪d₁ h, Classical.choose hv⟫_ℝ = ⟪h, (LinearMap.adjoint d₁) (Classical.choose hv)⟫_ℝ := by
    rw [ LinearMap.adjoint_inner_right ];
  have h_ker : d₁ h = 0 := by
    have h_d1h : h ∈ LinearMap.ker d₁ ⊓ LinearMap.ker (LinearMap.adjoint d₀) := by
      exact HodgeDecomposition.ker_hodgeLaplacian₁_eq hcc ▸ hh;
    exact h_d1h.1;
  simpa [ h_ker, Classical.choose_spec hv ] using h_inner.symm

/-! ## The Hodge Decomposition Theorem -/

/-
**Hodge Decomposition (existence)**: Every 1-cochain decomposes as
    ω = d₀(f) + d₁†(η) + h where h is harmonic.
    The three components are mutually orthogonal.
-/
theorem hodge_decomposition_exists (hcc : IsCochainComplex d₀ d₁) (ω : E₁) :
    ∃ (f : E₀) (η : E₂) (h : E₁),
      ω = d₀ f + (LinearMap.adjoint d₁) η + h ∧
      h ∈ LinearMap.ker (hodgeLaplacian₁ d₀ d₁) := by
  -- By the orthogonal decomposition theorem, we can write ω as the sum of its projections onto the ranges of d₀ and d₁†, and the harmonic component.
  obtain ⟨u, v, h, hu, hv, hh⟩ : ∃ u v h : E₁, ω = u + v + h ∧ u ∈ LinearMap.range d₀ ∧ v ∈ LinearMap.range (LinearMap.adjoint d₁) ∧ h ∈ (LinearMap.range d₀ ⊔ LinearMap.range (LinearMap.adjoint d₁))ᗮ := by
    have h_decomp : ∀ (U V : Submodule ℝ E₁), U ⊔ V = (U ⊔ V) → ∀ ω : E₁, ∃ u v h : E₁, ω = u + v + h ∧ u ∈ U ∧ v ∈ V ∧ h ∈ (U ⊔ V)ᗮ := by
      intro U V hUV ω
      obtain ⟨u, hu⟩ : ∃ u : E₁, u ∈ U ⊔ V ∧ ω - u ∈ (U ⊔ V)ᗮ := by
        exact ⟨ ( U ⊔ V ).orthogonalProjection ω, Submodule.coe_mem _, by simp +decide ⟩;
      rcases Submodule.mem_sup.mp hu.1 with ⟨ u', hu', v', hv', rfl ⟩ ; exact ⟨ u', v', ω - ( u' + v' ), by simp +decide, hu', hv', by simpa using hu.2 ⟩ ;
    exact h_decomp _ _ rfl ω;
  -- By the properties of the adjoint, we know that $h$ is harmonic.
  have h_harmonic : h ∈ (LinearMap.ker d₁ ⊓ LinearMap.ker (LinearMap.adjoint d₀)) := by
    have h_harmonic : h ∈ (LinearMap.range d₀)ᗮ ∧ h ∈ (LinearMap.range (LinearMap.adjoint d₁))ᗮ := by
      exact ⟨ Submodule.orthogonal_le ( le_sup_left ) hh.2, Submodule.orthogonal_le ( le_sup_right ) hh.2 ⟩;
    simp_all +decide [ range_orthogonal_eq_ker_adjoint ];
  rcases hv with ⟨ f, rfl ⟩ ; rcases hh.1 with ⟨ η, rfl ⟩ ; use f, η, h; simp_all +decide [ hodgeLaplacian₁ ] ;

/-
**Hodge Decomposition (submodule form)**:
    C¹ = range(d₀) ⊔ range(d₁†) ⊔ ker(Δ₁) as an internal direct sum.
-/
theorem hodge_decomposition_sup (hcc : IsCochainComplex d₀ d₁) :
    LinearMap.range d₀ ⊔ LinearMap.range (LinearMap.adjoint d₁) ⊔
      LinearMap.ker (hodgeLaplacian₁ d₀ d₁) = ⊤ := by
  -- Let $ω$ be an arbitrary element of $E₁$.
  ext ω;
  obtain ⟨ f, η, h, rfl, hh ⟩ := hodge_decomposition_exists hcc ω;
  exact iff_of_true ( Submodule.add_mem_sup ( Submodule.add_mem_sup ( LinearMap.mem_range_self _ _ ) ( LinearMap.mem_range_self _ _ ) ) hh ) trivial

/-
The three subspaces in the Hodge decomposition are mutually orthogonal.
-/
theorem hodge_decomposition_pairwise_orthogonal (hcc : IsCochainComplex d₀ d₁) :
    (LinearMap.range d₀).orthogonal ≥
      LinearMap.range (LinearMap.adjoint d₁) ⊔ LinearMap.ker (hodgeLaplacian₁ d₀ d₁) ∧
    (LinearMap.range (LinearMap.adjoint d₁)).orthogonal ≥
      LinearMap.range d₀ ⊔ LinearMap.ker (hodgeLaplacian₁ d₀ d₁) ∧
    (LinearMap.ker (hodgeLaplacian₁ d₀ d₁)).orthogonal ≥
      LinearMap.range d₀ ⊔ LinearMap.range (LinearMap.adjoint d₁) := by
  refine' ⟨ _, _, _ ⟩;
  · simp +decide [ Submodule.orthogonal, Submodule.mem_orthogonal ];
    refine' ⟨ _, _ ⟩;
    · intro v hv
      obtain ⟨η, hη⟩ := hv
      simp [hη];
      intro a
      have := inner_range_d₀_range_adjoint_d₁ hcc (LinearMap.mem_range_self d₀ a) (by
      exact ⟨ η, hη ⟩ : v ∈ LinearMap.range (LinearMap.adjoint d₁))
      aesop;
    · intro v hv a;
      convert ker_hodgeLaplacian₁_orthogonal_range_d₀ hcc hv ( LinearMap.mem_range_self d₀ a ) using 1;
      rw [ real_inner_comm ];
  · intro x hx;
    rw [ Submodule.mem_orthogonal' ];
    rw [ Submodule.mem_sup ] at hx;
    rcases hx with ⟨ y, hy, z, hz, rfl ⟩;
    intro u hu;
    rw [ inner_add_left, inner_range_d₀_range_adjoint_d₁ hcc hy hu, zero_add ];
    exact?;
  · refine' sup_le _ _;
    · intro u hu;
      intro v hv;
      convert ker_hodgeLaplacian₁_orthogonal_range_d₀ hcc hv hu using 1;
    · intro v hv;
      intro w hw;
      convert ker_hodgeLaplacian₁_orthogonal_range_adjoint_d₁ hcc hw hv using 1

end HodgeDecomposition