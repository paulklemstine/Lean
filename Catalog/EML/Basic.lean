/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Pullback Stability of Universal Approximation

Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
When `φ` is injective, this gives density in all of `C(X, ℝ)`.

This establishes a transport principle: universal approximation results (like
Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
with the precise target being the fiber-constant functions.

## Main definitions

* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
  fibers of `φ`.
* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.

## Main results

### Basic properties (§1)
* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
* `norm_pullback_le` — the pullback map is norm-nonincreasing.
* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.

### Factorization (§2)
* `fiberConst_subset_range_pullback` — every fiber-constant function factors
  through `Set.range φ`, hence is a pullback (via Tietze extension).

### Density transport (§3)
* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
  subalgebra equals `FiberConst φ`.
* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.

### ε-approximation (§4)
* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-/

open scoped Topology
open Topology

variable {X Y : Type*}
variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]

/-! ### §1: Definitions and basic properties -/

/-- Continuous functions on `X` that are constant on fibers of `φ`.
This is the natural functional-analytic object associated to a feature map:
it captures exactly the observables visible through `φ`. -/
def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
  algebraMap_mem' r := by intro x x' _; simp
  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
  zero_mem' := by intro x x' _; simp
  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
  one_mem' := by intro x x' _; simp

/-- Pullback of continuous real-valued functions along `φ`. -/
def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
  toFun f := f.comp φ
  map_zero' := by ext; simp
  map_one' := by ext; simp
  map_add' := by intros; ext; simp
  map_mul' := by intros; ext; simp
  commutes' := by intros; ext; simp

@[simp]
theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
    pullbackAlg φ f x = f (φ x) := rfl

theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
    pullbackAlg φ f ∈ FiberConst φ := by
  intro x x' h; simp [h]

theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f

theorem range_comp_subalgebra_subset_fiberConst
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f

/-- `FiberConst φ` is closed in the uniform topology. -/
theorem fiberConst_closed (φ : C(X, Y)) :
    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
  refine isClosed_of_closure_subset ?_
  intro g hg x x' h
  rw [mem_closure_iff_nhds] at hg
  contrapose! hg
  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩

omit [T2Space X] [T2Space Y] in
/-- The pullback map is norm-nonincreasing. -/
theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
    simpa using ContinuousMap.norm_coe_le_norm f (φ x)

/-- When `φ` is surjective, pullback is an isometry. -/
theorem pullback_isometry_of_surjective
    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
    ‖pullbackAlg φ f‖ = ‖f‖ := by
  refine le_antisymm (norm_pullback_le φ f) ?_
  rw [ContinuousMap.norm_le _ (by positivity)]
  intro y; obtain ⟨x, rfl⟩ := hφ y
  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x

omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
theorem mem_fiberConst_of_injective
    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
    g ∈ FiberConst φ := by
  intro x x' h; exact congrArg g (hφ h)

omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
theorem fiberConst_eq_top_of_injective
    (φ : C(X, Y)) (hφ : Function.Injective φ) :
    FiberConst φ = ⊤ := by
  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top

omit [CompactSpace Y] [T2Space Y] in
/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
    FiberConst φ = ⊤ ↔ Function.Injective φ := by
  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
  intro x x' hφ; by_contra h_ne
  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
    have := exists_continuous_zero_one_of_isClosed
      (show IsClosed {x} from isClosed_singleton)
      (show IsClosed {x'} from isClosed_singleton) (by aesop)
    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
      this.choose_spec.2.1 (Set.mem_singleton x')⟩
  replace h := SetLike.ext_iff.mp h g
  simp_all +decide [FiberConst]
  exact absurd (h hφ) (by simp +decide [hg])

/-! ### §2: Image factorization -/

instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)

/-
The corestriction `X → Set.range φ` is a quotient map.
-/
theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
  apply IsClosedMap.isQuotientMap;
  · intro s hs;
    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
    constructor <;> intro h;
    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
    · convert h.preimage ( continuous_subtype_val ) using 1;
      ext; simp [Set.rangeFactorization];
      grind;
  · exact continuous_induced_rng.mpr φ.continuous;
  · exact Set.rangeFactorization_surjective

/-- Lift a fiber-constant function to `Set.range φ`. -/
noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
  toFun z := g z.property.choose
  continuous_toFun := by
    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
      ext x; apply hg
      exact (Set.rangeFactorization φ x).property.choose_spec
    rw [this]; exact g.continuous

theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
    (hg : g ∈ FiberConst φ) (x : X) :
    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
  simp only [fiberConstLift]
  apply hg
  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec

/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
  intro g hg
  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
  refine ⟨F, ?_⟩
  ext x
  simp only [pullbackAlg_apply]
  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
    simp [ContinuousMap.comp_apply] at this; exact this
  rw [key, fiberConstLift_comp]

/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
theorem fiberConst_eq_range_pullback_of_surjective
    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
    (range_pullback_subset_fiberConst φ)

/-! ### §3: Density transport -/

/-
The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-/
theorem closure_range_pullback_eq_fiberConst
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ))) :
    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
      = (FiberConst φ : Set C(X, ℝ)) := by
  refine' le_antisymm ( closure_minimal _ _ ) _;
  · exact range_comp_subalgebra_subset_fiberConst φ A;
  · exact fiberConst_closed φ;
  · intro g hg;
    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
    rw [ Metric.mem_closure_iff ];
    intro ε εpos;
    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
    nontriviality;
    rw [ hF, dist_eq_norm ] at *;
    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1

/-
Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-/
theorem closure_range_pullback_eq_top_of_injective
    (φ : C(X, Y))
    (hφ : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ))) :
    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )

/-! ### §4: ε-approximation -/

/-
ε-approximation within `FiberConst φ`.
-/
theorem exists_pullback_approx_of_fiberConst
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ)))
    (g : C(X, ℝ))
    (hg : g ∈ FiberConst φ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
  rw [ Metric.mem_closure_iff ] at h_closure;
  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;

/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
theorem exists_pullback_approx_of_injective
    (φ : C(X, Y))
    (hφ : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ)))
    (g : C(X, ℝ))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
  exact exists_pullback_approx_of_fiberConst φ A hA g
    (mem_fiberConst_of_injective φ hφ g) hε