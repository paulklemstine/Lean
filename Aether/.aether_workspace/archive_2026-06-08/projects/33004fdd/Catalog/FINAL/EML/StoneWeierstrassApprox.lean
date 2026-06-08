/-
# Stone–Weierstrass Universal Approximation for EML-Generated Subalgebras

This file establishes a full Stone–Weierstrass-style universal approximation framework
for EML (Exponential-Multiplicative-Logarithmic) generated subalgebras of `C(X, ℝ)`.

## Main results

### Part 1: Stone–Weierstrass core
- `eml_topologicalClosure_eq_top_of_separatesPoints`: closure = ⊤ for separating subalgebras
- `eml_dense_range_of_subalgebra_separatesPoints`: density formulation
- `eml_exists_uniform_approx`: ε-approximation formulation

### Part 2: Pullback subalgebra and density transfer
- `precompAlgHom`: the precomposition algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`
- `pullbackSubalgebra`: pullback of a subalgebra along a continuous map
- `factorsThroughSubalgebra`: subalgebra of functions factoring through `φ`
- `pullback_closure_eq_factorsThrough`: density on Y transfers to factor-through subalgebra
- `pullback_dense_on_factoring_functions`: ε-approximation for factoring functions

### Part 3: Injective pullback
- `factorsThrough_eq_top_of_injective`: all functions factor through injective maps
- `pullback_dense_of_injective`: density transfers fully through injective maps

### Part 4: EML-facing corollaries
- `eml_universalApproximation`: the main EML universal approximation theorem
-/
import Mathlib

noncomputable section

open ContinuousMap Real Topology

/-! ## Part 1: Stone–Weierstrass core theorems -/

section StoneWeierstrassCore

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

/-- **Stone–Weierstrass for a real subalgebra of `C(X, ℝ)`.**
A point-separating subalgebra has topological closure equal to `⊤`. -/
theorem eml_topologicalClosure_eq_top_of_separatesPoints
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints) :
    A.topologicalClosure = ⊤ :=
  ContinuousMap.subalgebra_topologicalClosure_eq_top_of_separatesPoints A hsep

/-- The carrier of a point-separating subalgebra is dense in `C(X, ℝ)`. -/
theorem eml_dense_range_of_subalgebra_separatesPoints
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints) :
    Dense (A : Set C(X, ℝ)) := by
  rw [dense_iff_closure_eq]
  have : closure (A : Set C(X, ℝ)) = (A.topologicalClosure : Set C(X, ℝ)) :=
    (Subalgebra.topologicalClosure_coe A).symm
  rw [this, eml_topologicalClosure_eq_top_of_separatesPoints A hsep]
  simp

omit [T2Space X] in
/-- **Universal ε-approximation.**
Every continuous function on a compact Hausdorff space can be uniformly approximated
to within any `ε > 0` by an element of a point-separating subalgebra. -/
theorem eml_exists_uniform_approx
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g : A, ‖(g : C(X, ℝ)) - f‖ < ε :=
  ContinuousMap.exists_mem_subalgebra_near_continuousMap_of_separatesPoints A hsep f ε hε

end StoneWeierstrassCore

/-! ## Part 2: Pullback subalgebra and density transfer -/

section Pullback

variable {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]

/-- The precomposition algebra homomorphism: `g ↦ g ∘ φ`.
Given a continuous map `φ : C(X, Y)`, this sends `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`. -/
def precompAlgHom (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) :=
  ContinuousMap.compRightAlgHom ℝ ℝ φ

@[simp]
theorem precompAlgHom_apply (φ : C(X, Y)) (g : C(Y, ℝ)) :
    precompAlgHom φ g = g.comp φ := rfl

/-- The pullback of a subalgebra `A ≤ C(Y, ℝ)` along `φ : C(X, Y)` is
the image of `A` under precomposition with `φ`. -/
def pullbackSubalgebra (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    Subalgebra ℝ C(X, ℝ) :=
  A.map (precompAlgHom φ)

theorem mem_pullbackSubalgebra_iff (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ))
    (f : C(X, ℝ)) :
    f ∈ pullbackSubalgebra φ A ↔ ∃ g ∈ A, f = g.comp φ := by
  simp [pullbackSubalgebra, Subalgebra.mem_map, eq_comm]

/-- The subalgebra of continuous functions on `X` that factor through `φ : C(X, Y)`. -/
def factorsThroughSubalgebra (φ : C(X, Y)) :
    Subalgebra ℝ C(X, ℝ) :=
  (⊤ : Subalgebra ℝ C(Y, ℝ)).map (precompAlgHom φ)

theorem mem_factorsThroughSubalgebra_iff (φ : C(X, Y)) (f : C(X, ℝ)) :
    f ∈ factorsThroughSubalgebra φ ↔ ∃ g : C(Y, ℝ), f = g.comp φ := by
  simp [factorsThroughSubalgebra, eq_comm]

/-- The pullback subalgebra is contained in the factors-through subalgebra. -/
theorem pullbackSubalgebra_le_factorsThroughSubalgebra
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    pullbackSubalgebra φ A ≤ factorsThroughSubalgebra φ :=
  Subalgebra.map_mono le_top

/-- The sup norm is contractive under precomposition: `‖g ∘ φ - h ∘ φ‖ ≤ ‖g - h‖`. -/
theorem norm_comp_le [CompactSpace X] [CompactSpace Y]
    (φ : C(X, Y)) (g h : C(Y, ℝ)) :
    ‖g.comp φ - h.comp φ‖ ≤ ‖g - h‖ := by
  rw [(g.comp φ - h.comp φ).norm_le (norm_nonneg _)]
  intro x
  simp only [ContinuousMap.coe_sub, Pi.sub_apply, ContinuousMap.comp_apply]
  exact ContinuousMap.norm_coe_le_norm (g - h) (φ x)

/-- Precomposition with a continuous map is a continuous (hence Lipschitz) operation
on `C(Y, ℝ)`. This is the key estimate for density transfer. -/
theorem continuous_precomp [CompactSpace Y]
    (φ : C(X, Y)) : Continuous (precompAlgHom φ) :=
  ContinuousMap.compRightAlgHom_continuous ℝ ℝ φ

/-
If `g` is in the closure of `A`, then `g ∘ φ` is in the closure of `{h ∘ φ | h ∈ A}`.
-/
theorem pullback_mem_closure_of_mem_closure [CompactSpace X] [CompactSpace Y]
    (φ : C(X, Y)) (A : Set C(Y, ℝ)) {g : C(Y, ℝ)}
    (hg : g ∈ closure A) :
    g.comp φ ∈ closure ((fun h : C(Y, ℝ) => h.comp φ) '' A) := by
  refine' mem_closure_image _ hg;
  convert ( continuous_precomp φ ).continuousAt using 1

/-
**Density transfer theorem.**
If `A` is dense in `C(Y, ℝ)` (i.e., `A.topologicalClosure = ⊤`),
then the pullback of `A` along `φ` has topological closure equal to
the factors-through subalgebra.
-/
theorem pullback_closure_eq_factorsThrough
    [CompactSpace X] [T2Space X]
    [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = factorsThroughSubalgebra φ := by
  refine' le_antisymm _ _;
  · -- Let's show that `factorsThroughSubalgebra φ` is closed.
    have h_closed : IsClosed {f : C(X, ℝ) | ∃ g : C(Y, ℝ), f = g.comp φ} := by
      refine' isClosed_of_closure_subset _;
      intro f hf
      have h_eq : ∀ x₁ x₂ : X, φ x₁ = φ x₂ → f x₁ = f x₂ := by
        intro x₁ x₂ hφx
        by_contra hfx;
        rw [ mem_closure_iff_nhds ] at hf;
        specialize hf { g : C(X, ℝ) | g x₁ ≠ g x₂ } ?_;
        · exact IsOpen.mem_nhds ( isOpen_compl_iff.mpr <| isClosed_eq ( by continuity ) ( by continuity ) ) hfx;
        · obtain ⟨ g, hg₁, g', rfl ⟩ := hf; simp_all +decide ;
      -- Define $g$ on the image of $\varphi$ by $g(\varphi(x)) = f(x)$.
      obtain ⟨g, hg⟩ : ∃ g : Set.range φ → ℝ, ∀ x : X, g ⟨φ x, Set.mem_range_self x⟩ = f x := by
        exact ⟨ fun ⟨ y, hy ⟩ => f ( Classical.choose hy ), fun x => h_eq _ _ ( Classical.choose_spec ( Set.mem_range.mp ( Set.mem_range_self x ) ) ) ⟩;
      -- Extend $g$ to a continuous function on $Y$.
      obtain ⟨g_ext, hg_ext⟩ : ∃ g_ext : C(Y, ℝ), ∀ y : Set.range φ, g_ext y = g y := by
        have h_ext : Continuous g := by
          rw [ continuous_iff_isClosed ];
          intro s hs
          have h_preimage : IsClosed (f ⁻¹' s) := by
            exact hs.preimage f.continuous;
          have h_preimage : IsClosed (Set.image (fun x : X => ⟨φ x, Set.mem_range_self x⟩ : X → Set.range φ) (f ⁻¹' s)) := by
            exact IsCompact.isClosed ( IsCompact.image ( h_preimage.isCompact ) ( by continuity ) );
          convert h_preimage using 1;
          grind;
        have := @ContinuousMap.exists_restrict_eq;
        specialize this ( show IsClosed ( Set.range φ ) from isCompact_range φ.continuous |> IsCompact.isClosed ) ( ContinuousMap.mk g h_ext );
        exact ⟨ this.choose, fun y => congr_arg ( fun f => f y ) this.choose_spec ⟩;
      exact ⟨ g_ext, by ext x; specialize hg_ext ⟨ φ x, Set.mem_range_self x ⟩ ; aesop ⟩;
    convert h_closed.closure_subset_iff.mpr _;
    any_goals exact ( pullbackSubalgebra φ A : Set C(X, ℝ) );
    · simp +decide [ SetLike.le_def, mem_factorsThroughSubalgebra_iff ];
      rfl;
    · exact fun f hf => by obtain ⟨ g, hg, rfl ⟩ := mem_pullbackSubalgebra_iff φ A f |>.1 hf; exact ⟨ g, rfl ⟩ ;
  · intro f hf
    obtain ⟨g, rfl⟩ := mem_factorsThroughSubalgebra_iff φ f |>.1 hf
    have hg : g ∈ A.topologicalClosure := by
      aesop
    have hfg : g.comp φ ∈ (pullbackSubalgebra φ A).topologicalClosure := by
      convert pullback_mem_closure_of_mem_closure φ A hg using 1
    aesop

/-
**Approximation for factoring functions.**
If `A` is dense in `C(Y, ℝ)`, then any continuous function on `X` that factors
through `φ` can be uniformly approximated by pullbacks of elements of `A`.
-/
theorem pullback_dense_on_factoring_functions
    [CompactSpace X] [T2Space X]
    [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤)
    (f : C(X, ℝ))
    (hf : f ∈ factorsThroughSubalgebra φ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ g : pullbackSubalgebra φ A, ‖(g : C(X, ℝ)) - f‖ < ε := by
  -- By the density of pullbackSubalgebra, there exists g in pullbackSubalgebra such that ‖g - f‖ < ε.
  have h_pullback : f ∈ (pullbackSubalgebra φ A).topologicalClosure := by
    exact pullback_closure_eq_factorsThrough φ A hA ▸ hf;
  obtain ⟨ g, hg ⟩ := mem_closure_iff_nhds.mp h_pullback ( Metric.ball f ε ) ( Metric.ball_mem_nhds f hε );
  exact ⟨ ⟨ g, hg.2 ⟩, by simpa [ dist_eq_norm ] using hg.1 ⟩

end Pullback

/-! ## Part 3: Injective pullback — all functions factor through injective maps -/

section InjectivePullback

variable {X Y : Type*}
  [TopologicalSpace X] [CompactSpace X] [T2Space X]
  [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]

/-
Every continuous function on `X` factors through an injective continuous map `φ : X → Y`,
using the Tietze extension theorem. An injective continuous map from a compact space to a
Hausdorff space is a closed embedding, so Tietze extension provides the factoring.
-/
omit [T2Space X] in
theorem factorsThrough_eq_top_of_injective
    (φ : C(X, Y)) (hφinj : Function.Injective φ) :
    factorsThroughSubalgebra φ = ⊤ := by
  -- Since φ is injective, it is a closed embedding.
  have h_closed_embedding : Topology.IsClosedEmbedding φ := by
    refine' Continuous.isClosedEmbedding _ hφinj;
    exact φ.continuous;
  refine' eq_top_iff.2 fun f => _;
  exact fun _ => ContinuousMap.exists_extension h_closed_embedding f |> fun ⟨ g, hg ⟩ => ( mem_factorsThroughSubalgebra_iff φ f ).mpr ⟨ g, hg ▸ rfl ⟩

/-
**Injective pullback density.**
If `A` is dense in `C(Y, ℝ)` and `φ : X → Y` is injective,
then the pullback of `A` is dense in all of `C(X, ℝ)`.
-/
theorem pullback_dense_of_injective
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = ⊤ := by
  convert pullback_closure_eq_factorsThrough φ A hA;
  exact Eq.symm ( factorsThrough_eq_top_of_injective φ hφinj )

end InjectivePullback

/-! ## Part 4: EML-facing corollaries -/

section EMLCorollaries

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

/-- **EML Universal Approximation Theorem.**
Given a subalgebra `A ≤ C(X, ℝ)` generated by EML primitives, if `A` separates points,
then `A` is uniformly dense in `C(X, ℝ)`. This is the abstract form that encompasses
any EML-generated function class. -/
theorem eml_universalApproximation
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : A.SeparatesPoints) :
    A.topologicalClosure = ⊤ :=
  eml_topologicalClosure_eq_top_of_separatesPoints A hsep

/-- **EML Pullback Universal Approximation.**
If `A` is a point-separating subalgebra of `C(Y, ℝ)` and `φ : X → Y` is injective,
then the pullback class `{g ∘ φ | g ∈ A}` is uniformly dense in `C(X, ℝ)`. -/
theorem eml_pullback_universalApproximation
    {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hsep : A.SeparatesPoints) :
    (pullbackSubalgebra φ A).topologicalClosure = ⊤ :=
  pullback_dense_of_injective φ hφinj A
    (eml_topologicalClosure_eq_top_of_separatesPoints A hsep)

/-- **EML ε-approximation via pullback.**
Given `φ : X → Y` injective and `A ≤ C(Y, ℝ)` separating points,
every `f : C(X, ℝ)` is within `ε` of some `g ∘ φ` with `g ∈ A`. -/
theorem eml_pullback_exists_approx
    {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hsep : A.SeparatesPoints)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g : pullbackSubalgebra φ A, ‖(g : C(X, ℝ)) - f‖ < ε := by
  have hcl := eml_pullback_universalApproximation φ hφinj A hsep
  have hdense : Dense ((pullbackSubalgebra φ A) : Set C(X, ℝ)) := by
    rw [dense_iff_closure_eq, ← Subalgebra.topologicalClosure_coe]
    simp [hcl]
  obtain ⟨g, hgB, hgf⟩ := hdense.exists_dist_lt f hε
  rw [dist_comm, dist_eq_norm] at hgf
  exact ⟨⟨g, hgB⟩, hgf⟩

end EMLCorollaries

end