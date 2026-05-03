--- a/Tropical/Basic.lean
+++ b/Tropical/Basic.lean
@@ -1,1315 +1,545 @@
 --- a/Tropical/Basic.lean
 +++ b/Tropical/Basic.lean
-@@ -1,930 +1,383 @@
----- a/Tropical/Basic.lean
--+++ b/Tropical/Basic.lean
--@@ -1,545 +1,383 @@
------ a/Tropical/Basic.lean
---+++ b/Tropical/Basic.lean
---@@ -1,383 +1,160 @@
------- a/EML/Basic.lean
----+++ b/EML/Basic.lean
----@@ -1,277 +1,125 @@
-----/-
-----Copyright (c) 2026 Harmonic. All rights reserved.
-----Released under Apache 2.0 license as described in the file LICENSE.
------/
---- import Mathlib
---- 
-----/-!
-----# Pullback Stability of Universal Approximation
----+/-! # CatalogBuild.EML.Basic
---- 
-----Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-----subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-----closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-----When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-----
-----This establishes a transport principle: universal approximation results (like
-----Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-----with the precise target being the fiber-constant functions.
-----
-----## Main definitions
-----
-----* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-----  fibers of `φ`.
-----* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-----
-----## Main results
-----
-----### Basic properties (§1)
-----* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-----* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-----* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-----* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-----* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-----
-----### Factorization (§2)
-----* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-----  through `Set.range φ`, hence is a pullback (via Tietze extension).
-----
-----### Density transport (§3)
-----* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-----  subalgebra equals `FiberConst φ`.
-----* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-----
-----### ε-approximation (§4)
-----* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-----* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
----+Auto-generated from theorem catalog database.
----+Domain: EML
----+Declarations: 15
---- -/
---- 
-----open scoped Topology
-----open Topology
----+noncomputable section
---- 
-----variable {X Y : Type*}
-----variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-----variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
----+/-- The inverse for hyperbolic SPB is also negation. -/
----+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
----+  simp [spbH]
---- 
-----/-! ### §1: Definitions and basic properties -/
----+/-- Wick duality: SPB with negated second argument equals the "difference"
----+in the hyperbolic SPB. This is the real-variable manifestation of the
----+Wick rotation t → it. -/
----+theorem wick_duality (x y : ℝ) :
----+    spb x (-y) = (x - y) / (1 + x * y) := by
----+  simp only [spb]
----+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
----+  rw [heq]; ring
---- 
-----/-- Continuous functions on `X` that are constant on fibers of `φ`.
-----This is the natural functional-analytic object associated to a feature map:
-----it captures exactly the observables visible through `φ`. -/
-----def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-----  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-----  algebraMap_mem' r := by intro x x' _; simp
-----  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----  zero_mem' := by intro x x' _; simp
-----  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-----  one_mem' := by intro x x' _; simp
----+/-- The tangent addition law IS the stereographic sum.
----+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
----+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
----+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
----+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
----+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
----+  field_simp
---- 
-----/-- Pullback of continuous real-valued functions along `φ`. -/
-----def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-----  toFun f := f.comp φ
-----  map_zero' := by ext; simp
-----  map_one' := by ext; simp
-----  map_add' := by intros; ext; simp
-----  map_mul' := by intros; ext; simp
-----  commutes' := by intros; ext; simp
----+/-- SPB expression trees — analogous to EML expression trees. -/
----+inductive SPBExpr where
----+  | zero : SPBExpr
----+  | one : SPBExpr
----+  | var : ℕ → SPBExpr
----+  | node : SPBExpr → SPBExpr → SPBExpr
----+  deriving Repr, BEq
---- 
-----@[simp]
-----theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-----    pullbackAlg φ f x = f (φ x) := rfl
----+/-- Evaluate an SPB expression. -/
----+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
----+  match e with
----+  | .zero => 0
----+  | .one => 1
----+  | .var n => vars n
----+  | .node l r => spb (l.eval vars) (r.eval vars)
---- 
-----theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----    pullbackAlg φ f ∈ FiberConst φ := by
-----  intro x x' h; simp [h]
----+/-- Depth of an SPB expression. -/
----+def SPBExpr.depth : SPBExpr → ℕ
----+  | .zero => 0
----+  | .one => 0
----+  | .var _ => 0
----+  | .node l r => 1 + max l.depth r.depth
---- 
-----theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-----    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
----+/-- Leaf count. -/
----+def SPBExpr.leafCount : SPBExpr → ℕ
----+  | .zero => 1
----+  | .one => 1
----+  | .var _ => 1
----+  | .node l r => l.leafCount + r.leafCount
---- 
-----theorem range_comp_subalgebra_subset_fiberConst
-----    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-----    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-----  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
----+/-- Internal node count. -/
----+def SPBExpr.nodeCount : SPBExpr → ℕ
----+  | .zero => 0
----+  | .one => 0
----+  | .var _ => 0
----+  | .node l r => 1 + l.nodeCount + r.nodeCount
---- 
-----/-- `FiberConst φ` is closed in the uniform topology. -/
-----theorem fiberConst_closed (φ : C(X, Y)) :
-----    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-----  refine isClosed_of_closure_subset ?_
-----  intro g hg x x' h
-----  rw [mem_closure_iff_nhds] at hg
-----  contrapose! hg
-----  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-----    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-----    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
----+/-- Binary tree identity: leaves = internal nodes + 1. -/
----+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
----+    e.leafCount = e.nodeCount + 1 := by
----+  induction e with
----+  | zero => rfl
----+  | one => rfl
----+  | var _ => rfl
----+  | node l r ihl ihr =>
----+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
----+    omega
---- 
-----omit [T2Space X] [T2Space Y] in
-----/-- The pullback map is norm-nonincreasing. -/
-----theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-----    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-----  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-----    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
----+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
----+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
---- 
-----/-- When `φ` is surjective, pullback is an isometry. -/
-----theorem pullback_isometry_of_surjective
-----    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-----    ‖pullbackAlg φ f‖ = ‖f‖ := by
-----  refine le_antisymm (norm_pullback_le φ f) ?_
-----  rw [ContinuousMap.norm_le _ (by positivity)]
-----  intro y; obtain ⟨x, rfl⟩ := hφ y
-----  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
----+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
----+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
----+  unfold logisticSigmoid
----+  rw [Real.exp_neg]
----+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+  field_simp; ring
---- 
-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----theorem mem_fiberConst_of_injective
-----    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-----    g ∈ FiberConst φ := by
-----  intro x x' h; exact congrArg g (hφ h)
----+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
----+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
----+  unfold softplus logisticSigmoid
----+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
----+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
----+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
----+  simp at this
----+  exact this
---- 
-----omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-----theorem fiberConst_eq_top_of_injective
-----    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-----    FiberConst φ = ⊤ := by
-----  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
----+/-- ShefferAlg is closed under affine pre-composition. -/
----+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
----+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
----+  obtain ⟨e, rfl⟩ := hf
----+  exact ⟨.affinePrecomp a b e, rfl⟩
---- 
-----omit [CompactSpace Y] [T2Space Y] in
-----/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-----theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-----    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-----  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-----  intro x x' hφ; by_contra h_ne
-----  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-----    have := exists_continuous_zero_one_of_isClosed
-----      (show IsClosed {x} from isClosed_singleton)
-----      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-----    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-----      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-----  replace h := SetLike.ext_iff.mp h g
-----  simp_all +decide [FiberConst]
-----  exact absurd (h hφ) (by simp +decide [hg])
----+/-- ShefferAlg is closed under affine combination. -/
----+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
----+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
----+  obtain ⟨ef, rfl⟩ := hf
----+  obtain ⟨eg, rfl⟩ := hg
----+  exact ⟨.affineComb α β γ ef eg, rfl⟩
---- 
-----/-! ### §2: Image factorization -/
----+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
----+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
----+  unfold softplus
----+  rw [Real.exp_neg]
----+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
----+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
----+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
----+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
----+  rw [this, Real.log_exp]
---- 
-----instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-----  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-----
-----/-
-----The corestriction `X → Set.range φ` is a quotient map.
------/
-----theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-----    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-----  apply IsClosedMap.isQuotientMap;
-----  · intro s hs;
-----    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-----    constructor <;> intro h;
-----    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-----    · convert h.preimage ( continuous_subtype_val ) using 1;
-----      ext; simp [Set.rangeFactorization];
-----      grind;
-----  · exact continuous_induced_rng.mpr φ.continuous;
-----  · exact Set.rangeFactorization_surjective
-----
-----/-- Lift a fiber-constant function to `Set.range φ`. -/
-----noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-----    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-----  toFun z := g z.property.choose
-----  continuous_toFun := by
-----    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-----    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-----    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-----      ext x; apply hg
-----      exact (Set.rangeFactorization φ x).property.choose_spec
-----    rw [this]; exact g.continuous
-----
-----theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-----    (hg : g ∈ FiberConst φ) (x : X) :
-----    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-----  simp only [fiberConstLift]
-----  apply hg
-----  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-----
-----/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-----theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-----    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-----  intro g hg
-----  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-----  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-----    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-----  refine ⟨F, ?_⟩
-----  ext x
-----  simp only [pullbackAlg_apply]
-----  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-----    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-----    simp [ContinuousMap.comp_apply] at this; exact this
-----  rw [key, fiberConstLift_comp]
-----
-----/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-----theorem fiberConst_eq_range_pullback_of_surjective
-----    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-----    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-----  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-----    (range_pullback_subset_fiberConst φ)
-----
-----/-! ### §3: Density transport -/
-----
-----/-
-----The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
------/
-----theorem closure_range_pullback_eq_fiberConst
-----    (φ : C(X, Y))
-----    (A : Subalgebra ℝ C(Y, ℝ))
-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-----      = (FiberConst φ : Set C(X, ℝ)) := by
-----  refine' le_antisymm ( closure_minimal _ _ ) _;
-----  · exact range_comp_subalgebra_subset_fiberConst φ A;
-----  · exact fiberConst_closed φ;
-----  · intro g hg;
-----    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-----    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-----      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-----    rw [ Metric.mem_closure_iff ];
-----    intro ε εpos;
-----    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-----    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-----    nontriviality;
-----    rw [ hF, dist_eq_norm ] at *;
-----    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-----
-----/-
-----Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
------/
-----theorem closure_range_pullback_eq_top_of_injective
-----    (φ : C(X, Y))
-----    (hφ : Function.Injective φ)
-----    (A : Subalgebra ℝ C(Y, ℝ))
-----    (hA : Dense (A : Set C(Y, ℝ))) :
-----    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-----  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-----  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-----
-----/-! ### §4: ε-approximation -/
-----
-----/-
-----ε-approximation within `FiberConst φ`.
------/
-----theorem exists_pullback_approx_of_fiberConst
-----    (φ : C(X, Y))
-----    (A : Subalgebra ℝ C(Y, ℝ))
-----    (hA : Dense (A : Set C(Y, ℝ)))
-----    (g : C(X, ℝ))
-----    (hg : g ∈ FiberConst φ)
-----    {ε : ℝ} (hε : 0 < ε) :
-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-----    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-----  rw [ Metric.mem_closure_iff ] at h_closure;
-----  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-----
-----/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-----theorem exists_pullback_approx_of_injective
-----    (φ : C(X, Y))
-----    (hφ : Function.Injective φ)
-----    (A : Subalgebra ℝ C(Y, ℝ))
-----    (hA : Dense (A : Set C(Y, ℝ)))
-----    (g : C(X, ℝ))
-----    {ε : ℝ} (hε : 0 < ε) :
-----    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-----  exact exists_pullback_approx_of_fiberConst φ A hA g
-----    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
---+Copyright (c) 2025. All rights reserved.
---+Released under Apache 2.0 license as described in the file LICENSE.
---+-/
---+import Mathlib
---+
---+/-!
---+# GL₃ Tropical Satake: Core Definitions
---+
---+This file establishes the foundational types and operations for the GL₃ tropical
---+Satake finite-determinacy theory.
---+
---+## Overview
---+
---+For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
---+The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
---+
---+We define three families of **tropical Satake observables**, corresponding to the
---+three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
---+
---+1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
---+   representation character. Uses the weights `e₁, e₂, e₃`.
---+2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
---+   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
---+3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
---+   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
---+   recovers function values without the information loss inherent in max operations.
---+
---+The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
---+equality of these observables on finite test sets forces equality of the underlying
---+functions.
---+-/
---+
---+open Finset
---+
---+/-! ### Dominance and support conditions -/
---+
---+/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
---+def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
---+
---+/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
---+    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
---+def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
---+  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
---+
---+/-- The box `BoxDom(B)` as a `Finset` of triples. -/
---+def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
---+  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
---+
---+lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
---+    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
---+  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
---+  omega
---+
---+/-! ### Tropical Satake observables -/
---+
---+/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
---+
---+The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
---+`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
---+`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
---+
---+Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
---+which serves as the tropical "zero" in this ℤ-valued model. -/
---+def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
---+  let v1 := if 1 ≤ a then f (a - 1) b c else 0
---+  let v2 := if 1 ≤ b then f a (b - 1) c else 0
---+  let v3 := if 1 ≤ c then f a b (c - 1) else 0
---+  max v1 (max v2 v3)
---+
---+/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
---+
---+The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
---+`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
---+`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
---+def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
---+  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
---+  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
---+  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
---+  max v1 (max v2 v3)
---+
---+/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
---+
---+This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
---+As a representation-theoretic operation, it corresponds to convolution with the
---+one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
---+rank-2 profiles (which use `max` and can lose information), the determinant
---+convolution perfectly preserves all function values.
---+
---+This is the key observable that makes finite determinacy possible: it acts as an
---+exact reconstruction tool rather than a lossy tropical projection. -/
---+def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
---+  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
---+
---+/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
---+    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
---+def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
---+  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
---+
---+/-! ### Finite test ranges -/
---+
---+/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
---+def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
---+
---+/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
---+def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
---+    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
---+
---+/-- The finite range of edge moment test parameters determined by box bound `B`.
---+    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
---+def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
---+  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
---+    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
---+
---+/-! ### Key computation lemmas -/
---+
---+/-- The edge moment at a shifted point exactly recovers the function value.
---+    This is the fundamental reconstruction identity. -/
---+@[simp]
---+lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
---+    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
---+  simp [edgeMoment]
---+
---+/-- Shifted dominant coweights lie in the edge moment range. -/
---+lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
---+    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
---+    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
---+  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
---+  omega
---+
---+/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
---+    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
---+    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
---+    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
---+lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
---+    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
---+  simp [rank2Profile]
---+
---+/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
---+lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
---+    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
---+    f a b c = 0 := by
---+  exact hf a b c (Or.inl ha)
---+
---+/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
---+lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
---+    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
---+    f a b c = 0 := by
---+  exact hf a b c (by tauto)
---+
---+/-- Bounded-support functions vanish outside the box: explicit formulation. -/
---+lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
---+    (hf : FiniteSupportWithin B f) {a b c : ℕ}
---+    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
---+    f a b c = 0 := by
---+  apply hf; push_neg at h; omega+--- a/EML/Basic.lean
--++++ b/EML/Basic.lean
--+@@ -1,277 +1,125 @@
--+-/-
--+-Copyright (c) 2026 Harmonic. All rights reserved.
--+-Released under Apache 2.0 license as described in the file LICENSE.
--+--/
--+ import Mathlib
--+ 
--+-/-!
--+-# Pullback Stability of Universal Approximation
--++/-! # CatalogBuild.EML.Basic
--+ 
--+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
--+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
--+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
--+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
--+-
--+-This establishes a transport principle: universal approximation results (like
--+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
--+-with the precise target being the fiber-constant functions.
--+-
--+-## Main definitions
--+-
--+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
--+-  fibers of `φ`.
--+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
--+-
--+-## Main results
--+-
--+-### Basic properties (§1)
--+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
--+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
--+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
--+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
--+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
--+-
--+-### Factorization (§2)
--+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
--+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
--+-
--+-### Density transport (§3)
--+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
--+-  subalgebra equals `FiberConst φ`.
--+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
--+-
--+-### ε-approximation (§4)
--+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
--+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
--++Auto-generated from theorem catalog database.
--++Domain: EML
--++Declarations: 15
--+ -/
--+ 
--+-open scoped Topology
--+-open Topology
--++noncomputable section
--+ 
--+-variable {X Y : Type*}
--+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
--+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
--++/-- The inverse for hyperbolic SPB is also negation. -/
--++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
--++  simp [spbH]
--+ 
--+-/-! ### §1: Definitions and basic properties -/
--++/-- Wick duality: SPB with negated second argument equals the "difference"
--++in the hyperbolic SPB. This is the real-variable manifestation of the
--++Wick rotation t → it. -/
--++theorem wick_duality (x y : ℝ) :
--++    spb x (-y) = (x - y) / (1 + x * y) := by
--++  simp only [spb]
--++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
--++  rw [heq]; ring
--+ 
--+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
--+-This is the natural functional-analytic object associated to a feature map:
--+-it captures exactly the observables visible through `φ`. -/
--+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
--+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
--+-  algebraMap_mem' r := by intro x x' _; simp
--+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
--+-  zero_mem' := by intro x x' _; simp
--+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
--+-  one_mem' := by intro x x' _; simp
--++/-- The tangent addition law IS the stereographic sum.
--++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
--++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
--++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
--++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
--++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
--++  field_simp
--+ 
--+-/-- Pullback of continuous real-valued functions along `φ`. -/
--+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
--+-  toFun f := f.comp φ
--+-  map_zero' := by ext; simp
--+-  map_one' := by ext; simp
--+-  map_add' := by intros; ext; simp
--+-  map_mul' := by intros; ext; simp
--+-  commutes' := by intros; ext; simp
--++/-- SPB expression trees — analogous to EML expression trees. -/
--++inductive SPBExpr where
--++  | zero : SPBExpr
--++  | one : SPBExpr
--++  | var : ℕ → SPBExpr
--++  | node : SPBExpr → SPBExpr → SPBExpr
--++  deriving Repr, BEq
--+ 
--+-@[simp]
--+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
--+-    pullbackAlg φ f x = f (φ x) := rfl
--++/-- Evaluate an SPB expression. -/
--++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
--++  match e with
--++  | .zero => 0
--++  | .one => 1
--++  | .var n => vars n
--++  | .node l r => spb (l.eval vars) (r.eval vars)
--+ 
--+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
--+-    pullbackAlg φ f ∈ FiberConst φ := by
--+-  intro x x' h; simp [h]
--++/-- Depth of an SPB expression. -/
--++def SPBExpr.depth : SPBExpr → ℕ
--++  | .zero => 0
--++  | .one => 0
--++  | .var _ => 0
--++  | .node l r => 1 + max l.depth r.depth
--+ 
--+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
--+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
--+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
--++/-- Leaf count. -/
--++def SPBExpr.leafCount : SPBExpr → ℕ
--++  | .zero => 1
--++  | .one => 1
--++  | .var _ => 1
--++  | .node l r => l.leafCount + r.leafCount
--+ 
--+-theorem range_comp_subalgebra_subset_fiberConst
--+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
--+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
--+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
--++/-- Internal node count. -/
--++def SPBExpr.nodeCount : SPBExpr → ℕ
--++  | .zero => 0
--++  | .one => 0
--++  | .var _ => 0
--++  | .node l r => 1 + l.nodeCount + r.nodeCount
--+ 
--+-/-- `FiberConst φ` is closed in the uniform topology. -/
--+-theorem fiberConst_closed (φ : C(X, Y)) :
--+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
--+-  refine isClosed_of_closure_subset ?_
--+-  intro g hg x x' h
--+-  rw [mem_closure_iff_nhds] at hg
--+-  contrapose! hg
--+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
--+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
--+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
--++/-- Binary tree identity: leaves = internal nodes + 1. -/
--++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
--++    e.leafCount = e.nodeCount + 1 := by
--++  induction e with
--++  | zero => rfl
--++  | one => rfl
--++  | var _ => rfl
--++  | node l r ihl ihr =>
--++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
--++    omega
--+ 
--+-omit [T2Space X] [T2Space Y] in
--+-/-- The pullback map is norm-nonincreasing. -/
--+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
--+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
--+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
--+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
--++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
--++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
--+ 
--+-/-- When `φ` is surjective, pullback is an isometry. -/
--+-theorem pullback_isometry_of_surjective
--+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
--+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
--+-  refine le_antisymm (norm_pullback_le φ f) ?_
--+-  rw [ContinuousMap.norm_le _ (by positivity)]
--+-  intro y; obtain ⟨x, rfl⟩ := hφ y
--+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
--++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
--++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
--++  unfold logisticSigmoid
--++  rw [Real.exp_neg]
--++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
--++  field_simp; ring
--+ 
--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
--+-theorem mem_fiberConst_of_injective
--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
--+-    g ∈ FiberConst φ := by
--+-  intro x x' h; exact congrArg g (hφ h)
--++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
--++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
--++  unfold softplus logisticSigmoid
--++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
--++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
--++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
--++  simp at this
--++  exact this
--+ 
--+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
--+-theorem fiberConst_eq_top_of_injective
--+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
--+-    FiberConst φ = ⊤ := by
--+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
--++/-- ShefferAlg is closed under affine pre-composition. -/
--++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
--++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
--++  obtain ⟨e, rfl⟩ := hf
--++  exact ⟨.affinePrecomp a b e, rfl⟩
--+ 
--+-omit [CompactSpace Y] [T2Space Y] in
--+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
--+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
--+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
--+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
--+-  intro x x' hφ; by_contra h_ne
--+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
--+-    have := exists_continuous_zero_one_of_isClosed
--+-      (show IsClosed {x} from isClosed_singleton)
--+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
--+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
--+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
--+-  replace h := SetLike.ext_iff.mp h g
--+-  simp_all +decide [FiberConst]
--+-  exact absurd (h hφ) (by simp +decide [hg])
--++/-- ShefferAlg is closed under affine combination. -/
--++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
--++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
--++  obtain ⟨ef, rfl⟩ := hf
--++  obtain ⟨eg, rfl⟩ := hg
--++  exact ⟨.affineComb α β γ ef eg, rfl⟩
--+ 
--+-/-! ### §2: Image factorization -/
--++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
--++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
--++  unfold softplus
--++  rw [Real.exp_neg]
--++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
--++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
--++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
--++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
--++  rw [this, Real.log_exp]
--+ 
--+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
--+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
--+-
--+-/-
--+-The corestriction `X → Set.range φ` is a quotient map.
--+--/
--+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
--+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
--+-  apply IsClosedMap.isQuotientMap;
--+-  · intro s hs;
--+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
--+-    constructor <;> intro h;
--+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
--+-    · convert h.preimage ( continuous_subtype_val ) using 1;
--+-      ext; simp [Set.rangeFactorization];
--+-      grind;
--+-  · exact continuous_induced_rng.mpr φ.continuous;
--+-  · exact Set.rangeFactorization_surjective
--+-
--+-/-- Lift a fiber-constant function to `Set.range φ`. -/
--+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
--+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
--+-  toFun z := g z.property.choose
--+-  continuous_toFun := by
--+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
--+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
--+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
--+-      ext x; apply hg
--+-      exact (Set.rangeFactorization φ x).property.choose_spec
--+-    rw [this]; exact g.continuous
--+-
--+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
--+-    (hg : g ∈ FiberConst φ) (x : X) :
--+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
--+-  simp only [fiberConstLift]
--+-  apply hg
--+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
--+-
--+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
--+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
--+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
--+-  intro g hg
--+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
--+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
--+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
--+-  refine ⟨F, ?_⟩
--+-  ext x
--+-  simp only [pullbackAlg_apply]
--+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
--+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
--+-    simp [ContinuousMap.comp_apply] at this; exact this
--+-  rw [key, fiberConstLift_comp]
--+-
--+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
--+-theorem fiberConst_eq_range_pullback_of_surjective
--+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
--+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
--+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
--+-    (range_pullback_subset_fiberConst φ)
--+-
--+-/-! ### §3: Density transport -/
--+-
--+-/-
--+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
--+--/
--+-theorem closure_range_pullback_eq_fiberConst
--+-    (φ : C(X, Y))
--+-    (A : Subalgebra ℝ C(Y, ℝ))
--+-    (hA : Dense (A : Set C(Y, ℝ))) :
--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
--+-      = (FiberConst φ : Set C(X, ℝ)) := by
--+-  refine' le_antisymm ( closure_minimal _ _ ) _;
--+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
--+-  · exact fiberConst_closed φ;
--+-  · intro g hg;
--+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
--+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
--+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
--+-    rw [ Metric.mem_closure_iff ];
--+-    intro ε εpos;
--+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
--+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
--+-    nontriviality;
--+-    rw [ hF, dist_eq_norm ] at *;
--+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
--+-
--+-/-
--+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
--+--/
--+-theorem closure_range_pullback_eq_top_of_injective
--+-    (φ : C(X, Y))
--+-    (hφ : Function.Injective φ)
--+-    (A : Subalgebra ℝ C(Y, ℝ))
--+-    (hA : Dense (A : Set C(Y, ℝ))) :
--+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
--+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
--+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
--+-
--+-/-! ### §4: ε-approximation -/
--+-
--+-/-
--+-ε-approximation within `FiberConst φ`.
--+--/
--+-theorem exists_pullback_approx_of_fiberConst
--+-    (φ : C(X, Y))
--+-    (A : Subalgebra ℝ C(Y, ℝ))
--+-    (hA : Dense (A : Set C(Y, ℝ)))
--+-    (g : C(X, ℝ))
--+-    (hg : g ∈ FiberConst φ)
--+-    {ε : ℝ} (hε : 0 < ε) :
--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
--+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
--+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
--+-  rw [ Metric.mem_closure_iff ] at h_closure;
--+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
--+-
--+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
--+-theorem exists_pullback_approx_of_injective
--+-    (φ : C(X, Y))
--+-    (hφ : Function.Injective φ)
--+-    (A : Subalgebra ℝ C(Y, ℝ))
--+-    (hA : Dense (A : Set C(Y, ℝ)))
--+-    (g : C(X, ℝ))
--+-    {ε : ℝ} (hε : 0 < ε) :
--+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
--+-  exact exists_pullback_approx_of_fiberConst φ A hA g
--+-    (mem_fiberConst_of_injective φ hφ g) hε+end+--- a/EML/Basic.lean
-++++ b/EML/Basic.lean
-+@@ -1,277 +1,125 @@
-+-/-
-+-Copyright (c) 2026 Harmonic. All rights reserved.
-+-Released under Apache 2.0 license as described in the file LICENSE.
-+--/
-+ import Mathlib
-+ 
-+-/-!
-+-# Pullback Stability of Universal Approximation
-++/-! # CatalogBuild.EML.Basic
-+ 
-+-Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
-+-subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
-+-closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
-+-When `φ` is injective, this gives density in all of `C(X, ℝ)`.
-+-
-+-This establishes a transport principle: universal approximation results (like
-+-Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
-+-with the precise target being the fiber-constant functions.
-+-
-+-## Main definitions
-+-
-+-* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
-+-  fibers of `φ`.
-+-* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
-+-
-+-## Main results
-+-
-+-### Basic properties (§1)
-+-* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
-+-* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
-+-* `norm_pullback_le` — the pullback map is norm-nonincreasing.
-+-* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
-+-* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
-+-
-+-### Factorization (§2)
-+-* `fiberConst_subset_range_pullback` — every fiber-constant function factors
-+-  through `Set.range φ`, hence is a pullback (via Tietze extension).
-+-
-+-### Density transport (§3)
-+-* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
-+-  subalgebra equals `FiberConst φ`.
-+-* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
-+-
-+-### ε-approximation (§4)
-+-* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
-+-* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
-++Auto-generated from theorem catalog database.
-++Domain: EML
-++Declarations: 15
-+ -/
-+ 
-+-open scoped Topology
-+-open Topology
-++noncomputable section
-+ 
-+-variable {X Y : Type*}
-+-variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
-+-variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
-++/-- The inverse for hyperbolic SPB is also negation. -/
-++theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
-++  simp [spbH]
-+ 
-+-/-! ### §1: Definitions and basic properties -/
-++/-- Wick duality: SPB with negated second argument equals the "difference"
-++in the hyperbolic SPB. This is the real-variable manifestation of the
-++Wick rotation t → it. -/
-++theorem wick_duality (x y : ℝ) :
-++    spb x (-y) = (x - y) / (1 + x * y) := by
-++  simp only [spb]
-++  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
-++  rw [heq]; ring
-+ 
-+-/-- Continuous functions on `X` that are constant on fibers of `φ`.
-+-This is the natural functional-analytic object associated to a feature map:
-+-it captures exactly the observables visible through `φ`. -/
-+-def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
-+-  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
-+-  algebraMap_mem' r := by intro x x' _; simp
-+-  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-+-  zero_mem' := by intro x x' _; simp
-+-  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
-+-  one_mem' := by intro x x' _; simp
-++/-- The tangent addition law IS the stereographic sum.
-++tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
-++theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
-++    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
-++  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
-++      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
-++  field_simp
-+ 
-+-/-- Pullback of continuous real-valued functions along `φ`. -/
-+-def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
-+-  toFun f := f.comp φ
-+-  map_zero' := by ext; simp
-+-  map_one' := by ext; simp
-+-  map_add' := by intros; ext; simp
-+-  map_mul' := by intros; ext; simp
-+-  commutes' := by intros; ext; simp
-++/-- SPB expression trees — analogous to EML expression trees. -/
-++inductive SPBExpr where
-++  | zero : SPBExpr
-++  | one : SPBExpr
-++  | var : ℕ → SPBExpr
-++  | node : SPBExpr → SPBExpr → SPBExpr
-++  deriving Repr, BEq
-+ 
-+-@[simp]
-+-theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
-+-    pullbackAlg φ f x = f (φ x) := rfl
-++/-- Evaluate an SPB expression. -/
-++def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
-++  match e with
-++  | .zero => 0
-++  | .one => 1
-++  | .var n => vars n
-++  | .node l r => spb (l.eval vars) (r.eval vars)
-+ 
-+-theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
-+-    pullbackAlg φ f ∈ FiberConst φ := by
-+-  intro x x' h; simp [h]
-++/-- Depth of an SPB expression. -/
-++def SPBExpr.depth : SPBExpr → ℕ
-++  | .zero => 0
-++  | .one => 0
-++  | .var _ => 0
-++  | .node l r => 1 + max l.depth r.depth
-+ 
-+-theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
-+-    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-+-  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
-++/-- Leaf count. -/
-++def SPBExpr.leafCount : SPBExpr → ℕ
-++  | .zero => 1
-++  | .one => 1
-++  | .var _ => 1
-++  | .node l r => l.leafCount + r.leafCount
-+ 
-+-theorem range_comp_subalgebra_subset_fiberConst
-+-    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
-+-    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
-+-  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
-++/-- Internal node count. -/
-++def SPBExpr.nodeCount : SPBExpr → ℕ
-++  | .zero => 0
-++  | .one => 0
-++  | .var _ => 0
-++  | .node l r => 1 + l.nodeCount + r.nodeCount
-+ 
-+-/-- `FiberConst φ` is closed in the uniform topology. -/
-+-theorem fiberConst_closed (φ : C(X, Y)) :
-+-    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
-+-  refine isClosed_of_closure_subset ?_
-+-  intro g hg x x' h
-+-  rw [mem_closure_iff_nhds] at hg
-+-  contrapose! hg
-+-  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
-+-    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
-+-    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
-++/-- Binary tree identity: leaves = internal nodes + 1. -/
-++theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
-++    e.leafCount = e.nodeCount + 1 := by
-++  induction e with
-++  | zero => rfl
-++  | one => rfl
-++  | var _ => rfl
-++  | node l r ihl ihr =>
-++    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
-++    omega
-+ 
-+-omit [T2Space X] [T2Space Y] in
-+-/-- The pullback map is norm-nonincreasing. -/
-+-theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
-+-    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
-+-  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
-+-    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
-++/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
-++def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
-+ 
-+-/-- When `φ` is surjective, pullback is an isometry. -/
-+-theorem pullback_isometry_of_surjective
-+-    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
-+-    ‖pullbackAlg φ f‖ = ‖f‖ := by
-+-  refine le_antisymm (norm_pullback_le φ f) ?_
-+-  rw [ContinuousMap.norm_le _ (by positivity)]
-+-  intro y; obtain ⟨x, rfl⟩ := hφ y
-+-  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
-++/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
-++theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
-++  unfold logisticSigmoid
-++  rw [Real.exp_neg]
-++  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-++  field_simp; ring
-+ 
-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-+-theorem mem_fiberConst_of_injective
-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
-+-    g ∈ FiberConst φ := by
-+-  intro x x' h; exact congrArg g (hφ h)
-++/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
-++theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
-++  unfold softplus logisticSigmoid
-++  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
-++  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
-++  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
-++  simp at this
-++  exact this
-+ 
-+-omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
-+-theorem fiberConst_eq_top_of_injective
-+-    (φ : C(X, Y)) (hφ : Function.Injective φ) :
-+-    FiberConst φ = ⊤ := by
-+-  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
-++/-- ShefferAlg is closed under affine pre-composition. -/
-++theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
-++    (fun x => f (a * x + b)) ∈ ShefferAlg := by
-++  obtain ⟨e, rfl⟩ := hf
-++  exact ⟨.affinePrecomp a b e, rfl⟩
-+ 
-+-omit [CompactSpace Y] [T2Space Y] in
-+-/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
-+-theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
-+-    FiberConst φ = ⊤ ↔ Function.Injective φ := by
-+-  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
-+-  intro x x' hφ; by_contra h_ne
-+-  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
-+-    have := exists_continuous_zero_one_of_isClosed
-+-      (show IsClosed {x} from isClosed_singleton)
-+-      (show IsClosed {x'} from isClosed_singleton) (by aesop)
-+-    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
-+-      this.choose_spec.2.1 (Set.mem_singleton x')⟩
-+-  replace h := SetLike.ext_iff.mp h g
-+-  simp_all +decide [FiberConst]
-+-  exact absurd (h hφ) (by simp +decide [hg])
-++/-- ShefferAlg is closed under affine combination. -/
-++theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
-++    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
-++  obtain ⟨ef, rfl⟩ := hf
-++  obtain ⟨eg, rfl⟩ := hg
-++  exact ⟨.affineComb α β γ ef eg, rfl⟩
-+ 
-+-/-! ### §2: Image factorization -/
-++/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
-++theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
-++  unfold softplus
-++  rw [Real.exp_neg]
-++  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
-++  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
-++  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
-++  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
-++  rw [this, Real.log_exp]
-+ 
-+-instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
-+-  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
-+-
-+-/-
-+-The corestriction `X → Set.range φ` is a quotient map.
-+--/
-+-theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
-+-    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
-+-  apply IsClosedMap.isQuotientMap;
-+-  · intro s hs;
-+-    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
-+-    constructor <;> intro h;
-+-    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
-+-    · convert h.preimage ( continuous_subtype_val ) using 1;
-+-      ext; simp [Set.rangeFactorization];
-+-      grind;
-+-  · exact continuous_induced_rng.mpr φ.continuous;
-+-  · exact Set.rangeFactorization_surjective
-+-
-+-/-- Lift a fiber-constant function to `Set.range φ`. -/
-+-noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
-+-    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
-+-  toFun z := g z.property.choose
-+-  continuous_toFun := by
-+-    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
-+-    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
-+-    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
-+-      ext x; apply hg
-+-      exact (Set.rangeFactorization φ x).property.choose_spec
-+-    rw [this]; exact g.continuous
-+-
-+-theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
-+-    (hg : g ∈ FiberConst φ) (x : X) :
-+-    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
-+-  simp only [fiberConstLift]
-+-  apply hg
-+-  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
-+-
-+-/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
-+-theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
-+-    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
-+-  intro g hg
-+-  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
-+-  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
-+-    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
-+-  refine ⟨F, ?_⟩
-+-  ext x
-+-  simp only [pullbackAlg_apply]
-+-  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
-+-    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
-+-    simp [ContinuousMap.comp_apply] at this; exact this
-+-  rw [key, fiberConstLift_comp]
-+-
-+-/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
-+-theorem fiberConst_eq_range_pullback_of_surjective
-+-    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
-+-    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
-+-  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
-+-    (range_pullback_subset_fiberConst φ)
-+-
-+-/-! ### §3: Density transport -/
-+-
-+-/-
-+-The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
-+--/
-+-theorem closure_range_pullback_eq_fiberConst
-+-    (φ : C(X, Y))
-+-    (A : Subalgebra ℝ C(Y, ℝ))
-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
-+-      = (FiberConst φ : Set C(X, ℝ)) := by
-+-  refine' le_antisymm ( closure_minimal _ _ ) _;
-+-  · exact range_comp_subalgebra_subset_fiberConst φ A;
-+-  · exact fiberConst_closed φ;
-+-  · intro g hg;
-+-    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
-+-    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
-+-      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
-+-    rw [ Metric.mem_closure_iff ];
-+-    intro ε εpos;
-+-    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
-+-    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
-+-    nontriviality;
-+-    rw [ hF, dist_eq_norm ] at *;
-+-    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
-+-
-+-/-
-+-Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
-+--/
-+-theorem closure_range_pullback_eq_top_of_injective
-+-    (φ : C(X, Y))
-+-    (hφ : Function.Injective φ)
-+-    (A : Subalgebra ℝ C(Y, ℝ))
-+-    (hA : Dense (A : Set C(Y, ℝ))) :
-+-    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
-+-  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
-+-  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
-+-
-+-/-! ### §4: ε-approximation -/
-+-
-+-/-
-+-ε-approximation within `FiberConst φ`.
-+--/
-+-theorem exists_pullback_approx_of_fiberConst
-+-    (φ : C(X, Y))
-+-    (A : Subalgebra ℝ C(Y, ℝ))
-+-    (hA : Dense (A : Set C(Y, ℝ)))
-+-    (g : C(X, ℝ))
-+-    (hg : g ∈ FiberConst φ)
-+-    {ε : ℝ} (hε : 0 < ε) :
-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-+-  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
-+-    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
-+-  rw [ Metric.mem_closure_iff ] at h_closure;
-+-  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
-+-
-+-/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
-+-theorem exists_pullback_approx_of_injective
-+-    (φ : C(X, Y))
-+-    (hφ : Function.Injective φ)
-+-    (A : Subalgebra ℝ C(Y, ℝ))
-+-    (hA : Dense (A : Set C(Y, ℝ)))
-+-    (g : C(X, ℝ))
-+-    {ε : ℝ} (hε : 0 < ε) :
-+-    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
-+-  exact exists_pullback_approx_of_fiberConst φ A hA g
-+-    (mem_fiberConst_of_injective φ hφ g) hε+end+@@ -1,383 +1,160 @@
+---- a/EML/Basic.lean
+-+++ b/EML/Basic.lean
+-@@ -1,277 +1,125 @@
+--/-
+--Copyright (c) 2026 Harmonic. All rights reserved.
+--Released under Apache 2.0 license as described in the file LICENSE.
+---/
+- import Mathlib
+- 
+--/-!
+--# Pullback Stability of Universal Approximation
+-+/-! # CatalogBuild.EML.Basic
+- 
+--Given a continuous map `φ : C(X, Y)` between compact Hausdorff spaces and a dense
+--subalgebra `A` of `C(Y, ℝ)`, the pullback `{f ∘ φ : f ∈ A}` is dense in the
+--closed subalgebra `FiberConst φ` of functions constant on fibers of `φ`.
+--When `φ` is injective, this gives density in all of `C(X, ℝ)`.
+--
+--This establishes a transport principle: universal approximation results (like
+--Stone–Weierstrass or EML density) can be pulled back along continuous feature maps,
+--with the precise target being the fiber-constant functions.
+--
+--## Main definitions
+--
+--* `FiberConst φ` — the closed subalgebra of `C(X, ℝ)` of functions constant on
+--  fibers of `φ`.
+--* `pullbackAlg φ` — the pullback `ℝ`-algebra homomorphism `C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)`.
+--
+--## Main results
+--
+--### Basic properties (§1)
+--* `pullback_mem_fiberConst` — pullbacks land in `FiberConst φ`.
+--* `fiberConst_closed` — `FiberConst φ` is closed in the uniform topology.
+--* `norm_pullback_le` — the pullback map is norm-nonincreasing.
+--* `pullback_isometry_of_surjective` — pullback is isometric when `φ` is surjective.
+--* `fiberConst_eq_top_iff_injective` — `FiberConst φ = ⊤ ↔ Injective φ`.
+--
+--### Factorization (§2)
+--* `fiberConst_subset_range_pullback` — every fiber-constant function factors
+--  through `Set.range φ`, hence is a pullback (via Tietze extension).
+--
+--### Density transport (§3)
+--* `closure_range_pullback_eq_fiberConst` — the closure of pullbacks from a dense
+--  subalgebra equals `FiberConst φ`.
+--* `closure_range_pullback_eq_top_of_injective` — injective case: closure is `⊤`.
+--
+--### ε-approximation (§4)
+--* `exists_pullback_approx_of_fiberConst` — ε-approximation within `FiberConst φ`.
+--* `exists_pullback_approx_of_injective` — ε-approximation for all of `C(X, ℝ)`.
+-+Auto-generated from theorem catalog database.
+-+Domain: EML
+-+Declarations: 15
+- -/
+- 
+--open scoped Topology
+--open Topology
+-+noncomputable section
+- 
+--variable {X Y : Type*}
+--variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
+--variable [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
+-+/-- The inverse for hyperbolic SPB is also negation. -/
+-+theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
+-+  simp [spbH]
+- 
+--/-! ### §1: Definitions and basic properties -/
+-+/-- Wick duality: SPB with negated second argument equals the "difference"
+-+in the hyperbolic SPB. This is the real-variable manifestation of the
+-+Wick rotation t → it. -/
+-+theorem wick_duality (x y : ℝ) :
+-+    spb x (-y) = (x - y) / (1 + x * y) := by
+-+  simp only [spb]
+-+  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
+-+  rw [heq]; ring
+- 
+--/-- Continuous functions on `X` that are constant on fibers of `φ`.
+--This is the natural functional-analytic object associated to a feature map:
+--it captures exactly the observables visible through `φ`. -/
+--def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
+--  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
+--  algebraMap_mem' r := by intro x x' _; simp
+--  add_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+--  zero_mem' := by intro x x' _; simp
+--  mul_mem' := by intro f g hf hg x x' h; simp [hf h, hg h]
+--  one_mem' := by intro x x' _; simp
+-+/-- The tangent addition law IS the stereographic sum.
+-+tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
+-+theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
+-+    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
+-+  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
+-+      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
+-+  field_simp
+- 
+--/-- Pullback of continuous real-valued functions along `φ`. -/
+--def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
+--  toFun f := f.comp φ
+--  map_zero' := by ext; simp
+--  map_one' := by ext; simp
+--  map_add' := by intros; ext; simp
+--  map_mul' := by intros; ext; simp
+--  commutes' := by intros; ext; simp
+-+/-- SPB expression trees — analogous to EML expression trees. -/
+-+inductive SPBExpr where
+-+  | zero : SPBExpr
+-+  | one : SPBExpr
+-+  | var : ℕ → SPBExpr
+-+  | node : SPBExpr → SPBExpr → SPBExpr
+-+  deriving Repr, BEq
+- 
+--@[simp]
+--theorem pullbackAlg_apply (φ : C(X, Y)) (f : C(Y, ℝ)) (x : X) :
+--    pullbackAlg φ f x = f (φ x) := rfl
+-+/-- Evaluate an SPB expression. -/
+-+def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
+-+  match e with
+-+  | .zero => 0
+-+  | .one => 1
+-+  | .var n => vars n
+-+  | .node l r => spb (l.eval vars) (r.eval vars)
+- 
+--theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
+--    pullbackAlg φ f ∈ FiberConst φ := by
+--  intro x x' h; simp [h]
+-+/-- Depth of an SPB expression. -/
+-+def SPBExpr.depth : SPBExpr → ℕ
+-+  | .zero => 0
+-+  | .one => 0
+-+  | .var _ => 0
+-+  | .node l r => 1 + max l.depth r.depth
+- 
+--theorem range_pullback_subset_fiberConst (φ : C(X, Y)) :
+--    Set.range (pullbackAlg φ) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+--  rintro _ ⟨f, rfl⟩; exact pullback_mem_fiberConst φ f
+-+/-- Leaf count. -/
+-+def SPBExpr.leafCount : SPBExpr → ℕ
+-+  | .zero => 1
+-+  | .one => 1
+-+  | .var _ => 1
+-+  | .node l r => l.leafCount + r.leafCount
+- 
+--theorem range_comp_subalgebra_subset_fiberConst
+--    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
+--    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
+--  rintro _ ⟨f, _, rfl⟩; exact pullback_mem_fiberConst φ f
+-+/-- Internal node count. -/
+-+def SPBExpr.nodeCount : SPBExpr → ℕ
+-+  | .zero => 0
+-+  | .one => 0
+-+  | .var _ => 0
+-+  | .node l r => 1 + l.nodeCount + r.nodeCount
+- 
+--/-- `FiberConst φ` is closed in the uniform topology. -/
+--theorem fiberConst_closed (φ : C(X, Y)) :
+--    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
+--  refine isClosed_of_closure_subset ?_
+--  intro g hg x x' h
+--  rw [mem_closure_iff_nhds] at hg
+--  contrapose! hg
+--  exact ⟨{f : C(X, ℝ) | f x ≠ f x'},
+--    IsOpen.mem_nhds (isOpen_compl_iff.mpr (isClosed_eq (by continuity) (by continuity))) hg,
+--    Set.eq_empty_of_forall_notMem fun f hf => hf.1 (hf.2 h)⟩
+-+/-- Binary tree identity: leaves = internal nodes + 1. -/
+-+theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
+-+    e.leafCount = e.nodeCount + 1 := by
+-+  induction e with
+-+  | zero => rfl
+-+  | one => rfl
+-+  | var _ => rfl
+-+  | node l r ihl ihr =>
+-+    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
+-+    omega
+- 
+--omit [T2Space X] [T2Space Y] in
+--/-- The pullback map is norm-nonincreasing. -/
+--theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
+--    ‖pullbackAlg φ f‖ ≤ ‖f‖ :=
+--  (ContinuousMap.norm_le _ (by positivity)).2 fun x => by
+--    simpa using ContinuousMap.norm_coe_le_norm f (φ x)
+-+/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
+-+def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}
+- 
+--/-- When `φ` is surjective, pullback is an isometry. -/
+--theorem pullback_isometry_of_surjective
+--    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
+--    ‖pullbackAlg φ f‖ = ‖f‖ := by
+--  refine le_antisymm (norm_pullback_le φ f) ?_
+--  rw [ContinuousMap.norm_le _ (by positivity)]
+--  intro y; obtain ⟨x, rfl⟩ := hφ y
+--  exact ContinuousMap.norm_coe_le_norm (pullbackAlg φ f) x
+-+/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
+-+theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
+-+  unfold logisticSigmoid
+-+  rw [Real.exp_neg]
+-+  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
+-+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
+-+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+  field_simp; ring
+- 
+--omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+--theorem mem_fiberConst_of_injective
+--    (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
+--    g ∈ FiberConst φ := by
+--  intro x x' h; exact congrArg g (hφ h)
+-+/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
+-+theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
+-+  unfold softplus logisticSigmoid
+-+  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
+-+  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
+-+  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
+-+  simp at this
+-+  exact this
+- 
+--omit [CompactSpace X] [T2Space X] [CompactSpace Y] [T2Space Y] in
+--theorem fiberConst_eq_top_of_injective
+--    (φ : C(X, Y)) (hφ : Function.Injective φ) :
+--    FiberConst φ = ⊤ := by
+--  ext g; exact iff_of_true (mem_fiberConst_of_injective φ hφ g) Algebra.mem_top
+-+/-- ShefferAlg is closed under affine pre-composition. -/
+-+theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
+-+    (fun x => f (a * x + b)) ∈ ShefferAlg := by
+-+  obtain ⟨e, rfl⟩ := hf
+-+  exact ⟨.affinePrecomp a b e, rfl⟩
+- 
+--omit [CompactSpace Y] [T2Space Y] in
+--/-- `FiberConst φ = ⊤ ↔ Injective φ`. Uses Urysohn separation for ←. -/
+--theorem fiberConst_eq_top_iff_injective (φ : C(X, Y)) :
+--    FiberConst φ = ⊤ ↔ Function.Injective φ := by
+--  refine ⟨fun h => ?_, fiberConst_eq_top_of_injective φ⟩
+--  intro x x' hφ; by_contra h_ne
+--  obtain ⟨g, hg⟩ : ∃ g : C(X, ℝ), g x = 0 ∧ g x' = 1 := by
+--    have := exists_continuous_zero_one_of_isClosed
+--      (show IsClosed {x} from isClosed_singleton)
+--      (show IsClosed {x'} from isClosed_singleton) (by aesop)
+--    exact ⟨this.choose, this.choose_spec.1 (Set.mem_singleton x),
+--      this.choose_spec.2.1 (Set.mem_singleton x')⟩
+--  replace h := SetLike.ext_iff.mp h g
+--  simp_all +decide [FiberConst]
+--  exact absurd (h hφ) (by simp +decide [hg])
+-+/-- ShefferAlg is closed under affine combination. -/
+-+theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
+-+    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
+-+  obtain ⟨ef, rfl⟩ := hf
+-+  obtain ⟨eg, rfl⟩ := hg
+-+  exact ⟨.affineComb α β γ ef eg, rfl⟩
+- 
+--/-! ### §2: Image factorization -/
+-+/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
+-+theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
+-+  unfold softplus
+-+  rw [Real.exp_neg]
+-+  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
+-+  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
+-+  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
+-+  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
+-+  rw [this, Real.log_exp]
+- 
+--instance rangeCompactSpace (φ : C(X, Y)) : CompactSpace (Set.range φ) :=
+--  isCompact_iff_compactSpace.mp (isCompact_range φ.continuous)
+--
+--/-
+--The corestriction `X → Set.range φ` is a quotient map.
+---/
+--theorem rangeFactorization_isQuotientMap (φ : C(X, Y)) :
+--    Topology.IsQuotientMap (Set.rangeFactorization φ) := by
+--  apply IsClosedMap.isQuotientMap;
+--  · intro s hs;
+--    convert ( IsCompact.isClosed ( hs.isCompact.image φ.continuous ) ) using 1;
+--    constructor <;> intro h;
+--    · exact hs.isCompact.image φ.continuous |> IsCompact.isClosed;
+--    · convert h.preimage ( continuous_subtype_val ) using 1;
+--      ext; simp [Set.rangeFactorization];
+--      grind;
+--  · exact continuous_induced_rng.mpr φ.continuous;
+--  · exact Set.rangeFactorization_surjective
+--
+--/-- Lift a fiber-constant function to `Set.range φ`. -/
+--noncomputable def fiberConstLift (φ : C(X, Y)) (g : C(X, ℝ))
+--    (hg : g ∈ FiberConst φ) : C(↥(Set.range φ), ℝ) where
+--  toFun z := g z.property.choose
+--  continuous_toFun := by
+--    rw [(rangeFactorization_isQuotientMap φ).continuous_iff]
+--    show Continuous (fun x => g (Set.rangeFactorization φ x).property.choose)
+--    have : (fun x => g (Set.rangeFactorization φ x).property.choose) = g := by
+--      ext x; apply hg
+--      exact (Set.rangeFactorization φ x).property.choose_spec
+--    rw [this]; exact g.continuous
+--
+--theorem fiberConstLift_comp (φ : C(X, Y)) (g : C(X, ℝ))
+--    (hg : g ∈ FiberConst φ) (x : X) :
+--    fiberConstLift φ g hg ⟨φ x, x, rfl⟩ = g x := by
+--  simp only [fiberConstLift]
+--  apply hg
+--  exact (⟨φ x, x, rfl⟩ : Set.range φ).property.choose_spec
+--
+--/-- Every fiber-constant function is a pullback. Uses Tietze extension. -/
+--theorem fiberConst_subset_range_pullback (φ : C(X, Y)) :
+--    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
+--  intro g hg
+--  have hcl : IsClosed (Set.range φ) := (isCompact_range φ.continuous).isClosed
+--  obtain ⟨F, hF⟩ := ContinuousMap.exists_extension
+--    hcl.isClosedEmbedding_subtypeVal (fiberConstLift φ g hg)
+--  refine ⟨F, ?_⟩
+--  ext x
+--  simp only [pullbackAlg_apply]
+--  have key : F (φ x) = fiberConstLift φ g hg ⟨φ x, x, rfl⟩ := by
+--    have := ContinuousMap.congr_fun hF ⟨φ x, x, rfl⟩
+--    simp [ContinuousMap.comp_apply] at this; exact this
+--  rw [key, fiberConstLift_comp]
+--
+--/-- When `φ` is surjective, fiber-constant functions are exactly pullbacks. -/
+--theorem fiberConst_eq_range_pullback_of_surjective
+--    (φ : C(X, Y)) (_hφ : Function.Surjective φ) :
+--    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) :=
+--  Set.Subset.antisymm (fiberConst_subset_range_pullback φ)
+--    (range_pullback_subset_fiberConst φ)
+--
+--/-! ### §3: Density transport -/
+--
+--/-
+--The closure of pullbacks from a dense subalgebra equals `FiberConst φ`.
+---/
+--theorem closure_range_pullback_eq_fiberConst
+--    (φ : C(X, Y))
+--    (A : Subalgebra ℝ C(Y, ℝ))
+--    (hA : Dense (A : Set C(Y, ℝ))) :
+--    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
+--      = (FiberConst φ : Set C(X, ℝ)) := by
+--  refine' le_antisymm ( closure_minimal _ _ ) _;
+--  · exact range_comp_subalgebra_subset_fiberConst φ A;
+--  · exact fiberConst_closed φ;
+--  · intro g hg;
+--    -- By fiberConst_subset_range_pullback, there exists $F \in C(Y, ℝ)$ such that $g = \phi^* F$.
+--    obtain ⟨F, hF⟩ : ∃ F : C(Y, ℝ), g = pullbackAlg φ F := by
+--      exact Exists.elim ( fiberConst_subset_range_pullback φ hg ) fun F hF => ⟨ F, hF.symm ⟩;
+--    rw [ Metric.mem_closure_iff ];
+--    intro ε εpos;
+--    rcases hA.exists_dist_lt F εpos with ⟨ a, ha, ha' ⟩;
+--    refine' ⟨ _, ⟨ a, ha, rfl ⟩, _ ⟩;
+--    nontriviality;
+--    rw [ hF, dist_eq_norm ] at *;
+--    convert lt_of_le_of_lt ( norm_pullback_le φ ( F - a ) ) ha' using 1
+--
+--/-
+--Injective case: pullbacks from a dense subalgebra are dense in all of `C(X, ℝ)`.
+---/
+--theorem closure_range_pullback_eq_top_of_injective
+--    (φ : C(X, Y))
+--    (hφ : Function.Injective φ)
+--    (A : Subalgebra ℝ C(Y, ℝ))
+--    (hA : Dense (A : Set C(Y, ℝ))) :
+--    closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
+--  convert closure_range_pullback_eq_fiberConst φ A hA using 1;
+--  exact Eq.symm ( fiberConst_eq_top_of_injective φ hφ ▸ rfl )
+--
+--/-! ### §4: ε-approximation -/
+--
+--/-
+--ε-approximation within `FiberConst φ`.
+---/
+--theorem exists_pullback_approx_of_fiberConst
+--    (φ : C(X, Y))
+--    (A : Subalgebra ℝ C(Y, ℝ))
+--    (hA : Dense (A : Set C(Y, ℝ)))
+--    (g : C(X, ℝ))
+--    (hg : g ∈ FiberConst φ)
+--    {ε : ℝ} (hε : 0 < ε) :
+--    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+--  have h_closure : g ∈ closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) := by
+--    exact closure_range_pullback_eq_fiberConst φ A hA ▸ hg;
+--  rw [ Metric.mem_closure_iff ] at h_closure;
+--  obtain ⟨ b, ⟨ f, hf, rfl ⟩, hb ⟩ := h_closure ε hε; exact ⟨ f, hf, by rwa [ dist_eq_norm' ] at hb ⟩ ;
+--
+--/-- ε-approximation for all of `C(X, ℝ)` when `φ` is injective. -/
+--theorem exists_pullback_approx_of_injective
+--    (φ : C(X, Y))
+--    (hφ : Function.Injective φ)
+--    (A : Subalgebra ℝ C(Y, ℝ))
+--    (hA : Dense (A : Set C(Y, ℝ)))
+--    (g : C(X, ℝ))
+--    {ε : ℝ} (hε : 0 < ε) :
+--    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
+--  exact exists_pullback_approx_of_fiberConst φ A hA g
+--    (mem_fiberConst_of_injective φ hφ g) hε+end+/-
++Copyright (c) 2025. All rights reserved.
++Released under Apache 2.0 license as described in the file LICENSE.
++-/
++import Mathlib
++
++/-!
++# GL₃ Tropical Satake: Core Definitions
++
++This file establishes the foundational types and operations for the GL₃ tropical
++Satake finite-determinacy theory.
++
++## Overview
++
++For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
++The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.
++
++We define three families of **tropical Satake observables**, corresponding to the
++three fundamental representations `ω₁, ω₂, ω₃` of GL₃:
++
++1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
++   representation character. Uses the weights `e₁, e₂, e₃`.
++2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
++   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
++3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
++   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
++   recovers function values without the information loss inherent in max operations.
++
++The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
++equality of these observables on finite test sets forces equality of the underlying
++functions.
++-/
++
++open Finset
++
++/-! ### Dominance and support conditions -/
++
++/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
++def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b
++
++/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
++    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
++def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
++  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0
++
++/-- The box `BoxDom(B)` as a `Finset` of triples. -/
++def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
++    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++
++lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
++    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
++  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
++  omega
++
++/-! ### Tropical Satake observables -/
++
++/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.
++
++The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
++`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
++`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.
++
++Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
++which serves as the tropical "zero" in this ℤ-valued model. -/
++def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++  let v1 := if 1 ≤ a then f (a - 1) b c else 0
++  let v2 := if 1 ≤ b then f a (b - 1) c else 0
++  let v3 := if 1 ≤ c then f a b (c - 1) else 0
++  max v1 (max v2 v3)
++
++/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.
++
++The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
++`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
++`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
++def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
++  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
++  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
++  max v1 (max v2 v3)
++
++/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.
++
++This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
++As a representation-theoretic operation, it corresponds to convolution with the
++one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
++rank-2 profiles (which use `max` and can lose information), the determinant
++convolution perfectly preserves all function values.
++
++This is the key observable that makes finite determinacy possible: it acts as an
++exact reconstruction tool rather than a lossy tropical projection. -/
++def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
++  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0
++
++/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
++    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
++def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
++  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2
++
++/-! ### Finite test ranges -/
++
++/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
++def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++
++/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
++def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b
++
++/-- The finite range of edge moment test parameters determined by box bound `B`.
++    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
++def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
++  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
++    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a
++
++/-! ### Key computation lemmas -/
++
++/-- The edge moment at a shifted point exactly recovers the function value.
++    This is the fundamental reconstruction identity. -/
++@[simp]
++lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
++    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
++  simp [edgeMoment]
++
++/-- Shifted dominant coweights lie in the edge moment range. -/
++lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
++    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
++    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
++  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
++  omega
++
++/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
++    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
++    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
++    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
++lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
++    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
++  simp [rank2Profile]
++
++/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
++lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
++    f a b c = 0 := by
++  exact hf a b c (Or.inl ha)
++
++/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
++lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
++    f a b c = 0 := by
++  exact hf a b c (by tauto)
++
++/-- Bounded-support functions vanish outside the box: explicit formulation. -/
++lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
++    (hf : FiniteSupportWithin B f) {a b c : ℕ}
++    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
++    f a b c = 0 := by
++  apply hf; push_neg at h; omega