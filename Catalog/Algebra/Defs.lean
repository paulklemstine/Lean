--- a/Bridges/Defs.lean
+++ b/Bridges/Defs.lean
@@ -1,313 +1,169 @@
---- a/Bridges/Defs.lean
-+++ b/Bridges/Defs.lean
-@@ -1,182 +1,169 @@
- /-
- Copyright (c) 2025. All rights reserved.
--Released under Apache 2.0 license.
-+Released under Apache 2.0 license as described in the file LICENSE.
-+-/
-+import Mathlib
- 
--# Idempotent Kantorovich–Rubinstein Duality: Core Definitions
-+/-!
-+# Functorial Mackey Completion for Maxitive Measures on Finite T₀ Spaces
- 
--This file defines the fundamental objects for tropical/idempotent optimal transport:
--maxitive probability profiles, their integral functionals, 1-Lipschitz test functions,
--the KR dual distance, couplings, and the primal Wasserstein cost.
-+## Overview
- 
--## Mathematical context
-+In a finite T₀ space, topology is equivalent to a specialization preorder:
-+closed sets are lower sets, and irreducible closed sets are principal lower
-+sets `↓x = {y | y ≤ x}`. We develop a completion theory for set functions
-+(modeling maxitive measures / capacities) via **codensity assignments** on
-+these irreducible closed sets.
- 
--In the max-plus semiring (ℝ, max, +), the analogue of a probability measure is a
--"maxitive probability profile" μ : X → ℝ with values ≤ 0 and sup = 0. The
--analogue of integration is the maxitive integral Λ_μ(f) = sup_x(μ(x) + f(x)).
-+## Main definitions
- 
--The Kantorovich–Rubinstein dual distance is then defined as
--  d_KR(μ, ν) = sup_{f 1-Lip} (Λ_μ(f) - Λ_ν(f))
-+* `FiniteT0SupportClass` — the finite T₀ separation principle
-+* `irreducibleClosed` — principal lower set `↓x`
-+* `irreducibleClosedWeight` — weight of a set function on `↓x`
-+* `supportGaugeEq` — equality of codensity weights
-+* `CodensityAssignment` — monotone function `X → ℝ≥0∞`
-+* `measureToCodensity` — canonical map from monotone set functions to codensity
-+* `codensityToMeasure` — inverse: construct a set function from codensity data
-+* `idempotentKantorovich` — pseudodistance via monotone test functions
-+* `pushforward` — pushforward of a set function along a map
- 
--This is the tropical analogue of the classical Wasserstein-1 / earth mover's distance.
-+## Main results
-+
-+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
-+* `idempotentKantorovich_eq_zero_iff_supportGaugeEq` — zero distance ⟺ codensity equality
-+* `quotient_equiv_codensityAssignment` — the quotient by zero-distance ≃ CodensityAssignment
-+* `idempotentKantorovich_pushforward_le` — pushforward is nonexpansive
-+* `FunctorialIdempotentMackeyCompletion` — the full functorial completion theorem
- -/
--
--import Mathlib
- 
- noncomputable section
- 
--open scoped BigOperators
-+open scoped ENNReal
-+open Set
- 
--/-! ## 1-Lipschitz functions -/
-+/-! ## The Finite T₀ Separation Principle -/
- 
--/-- The type of 1-Lipschitz real-valued functions on a pseudo-metric space. -/
--def LipOne (X : Type*) [PseudoMetricSpace X] :=
--  {f : X → ℝ // LipschitzWith 1 f}
-+/-- The finite T₀ separation principle: if two points have the same principal
-+    lower set, they are equal. On a finite preorder, this is equivalent to
-+    antisymmetry, hence to the T₀ separation axiom on the Alexandrov topology. -/
-+class FiniteT0SupportClass (X : Type*) [Fintype X] [Preorder X] : Prop where
-+  antisymm_of_closure_eq : ∀ {x y : X}, (∀ z : X, z ≤ x ↔ z ≤ y) → x = y
- 
--namespace LipOne
-+/-- Every finite partial order is a finite T₀ space. -/
-+instance instFiniteT0SupportClassOfPartialOrder
-+    {X : Type*} [Fintype X] [PartialOrder X] : FiniteT0SupportClass X where
-+  antisymm_of_closure_eq h := le_antisymm ((h _).mp le_rfl) ((h _).mpr le_rfl)
- 
--variable {X : Type*} [PseudoMetricSpace X]
-+/-! ## Irreducible Closed Sets and Codensity Weights -/
- 
--instance : CoeFun (LipOne X) (fun _ => X → ℝ) :=
--  ⟨fun f => f.1⟩
-+/-- The irreducible closed set (principal lower set) associated to a point `x`.
-+    In the Alexandrov topology on a preorder, this is `↓x = {y | y ≤ x}`,
-+    which is always closed and irreducible. -/
-+def irreducibleClosed (X : Type*) [Preorder X] (x : X) : Set X := {y | y ≤ x}
- 
--/-- The constant zero function is 1-Lipschitz. -/
--def zero : LipOne X :=
--  ⟨fun _ => 0, LipschitzWith.of_dist_le_mul (fun _ _ => by simp [dist_nonneg])⟩
-+/-- The codensity weight of a point `x` under a set function `μ`:
-+    the value of `μ` on the principal lower set `↓x`. -/
-+def irreducibleClosedWeight {X : Type*} [Preorder X]
-+    (μ : Set X → ℝ≥0∞) (x : X) : ℝ≥0∞ :=
-+  μ (irreducibleClosed X x)
- 
--/-- The negation of a 1-Lipschitz function is 1-Lipschitz. -/
--def neg (f : LipOne X) : LipOne X :=
--  ⟨-f.1, f.2.neg⟩
-+/-- Two set functions agree on codensity if they assign equal weight to
-+    every principal lower set. This is the kernel of `measureToCodensity`. -/
-+def supportGaugeEq {X : Type*} [Preorder X]
-+    (μ ν : Set X → ℝ≥0∞) : Prop :=
-+  ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x
- 
--/-- The distance function from a fixed point is 1-Lipschitz. -/
--def distFrom (x₀ : X) : LipOne X :=
--  ⟨fun x => dist x x₀, LipschitzWith.of_dist_le_mul fun a b => by
--    simp only [Real.dist_eq, NNReal.coe_one, one_mul]
--    exact abs_dist_sub_le a b x₀⟩
-+/-! ## Test Functions and Idempotent Kantorovich Distance -/
- 
--/-- Composing a 1-Lipschitz function with a 1-Lipschitz map yields a 1-Lipschitz function. -/
--def comp {Y : Type*} [PseudoMetricSpace Y] (f : LipOne Y) (T : X → Y)
--    (hT : LipschitzWith 1 T) : LipOne X :=
--  ⟨fun x => f.1 (T x), by
--    have h := f.2.comp hT
--    simp only [one_mul] at h; exact h⟩
-+/-- A test function on a preorder is a monotone real-valued function.
-+    These serve as the dual objects in the idempotent Kantorovich theory. -/
-+def IsTestFunction {X : Type*} [Preorder X] (f : X → ℝ) : Prop :=
-+  Monotone f
- 
--end LipOne
-+/-- The idempotent Kantorovich pseudodistance between two set functions.
-+    This is the supremum over monotone test functions of the absolute
-+    discrepancy in their "idempotent integrals" (max-plus pairings).
-+    The symmetrization ensures `d(μ,ν) = 0 ↔ supportGaugeEq μ ν`. -/
-+def idempotentKantorovich {X : Type*} [Fintype X] [Preorder X]
-+    (μ ν : Set X → ℝ≥0∞) : ℝ≥0∞ :=
-+  ⨆ f : {f : X → ℝ // IsTestFunction f},
-+    ENNReal.ofReal (abs
-+      ((⨆ x : X, (f.1 x - (irreducibleClosedWeight μ x).toReal)) -
-+       (⨆ x : X, (f.1 x - (irreducibleClosedWeight ν x).toReal))))
- 
--/-! ## Maxitive probability profiles -/
-+/-! ## Codensity Assignments -/
- 
--/-- A maxitive probability profile on a finite type `X`: a function `X → ℝ` with
--    values ≤ 0 and max = 0. This is the tropical analogue of a probability measure.
-+/-- A codensity assignment on a preorder is a monotone function `X → ℝ≥0∞`.
-+    Each value `c x` represents the "codensity" on the irreducible closed
-+    set `↓x`. In finite T₀ spaces, this is the completed/canonical form
-+    of a maxitive measure. -/
-+structure CodensityAssignment (X : Type*) [Preorder X] where
-+  /-- The underlying function assigning weights to points. -/
-+  toFun : X → ℝ≥0∞
-+  /-- The assignment is monotone with respect to the preorder. -/
-+  monotone' : Monotone toFun
- 
--    The value μ(x) represents the log-possibility weight at x. Points with μ(x) = 0
--    are "fully possible" (the mode), while μ(x) < 0 indicates reduced possibility. -/
--structure MaxitiveProb (X : Type*) [Fintype X] [Nonempty X] where
--  /-- The log-possibility density function. -/
--  toFun : X → ℝ
--  /-- All values are non-positive. -/
--  nonpos : ∀ x, toFun x ≤ 0
--  /-- The profile is normalized: the maximum is 0. -/
--  normalized : Finset.univ.sup' Finset.univ_nonempty toFun = 0
-+namespace CodensityAssignment
- 
--namespace MaxitiveProb
-+variable {X : Type*} [Preorder X]
- 
--variable {X : Type*} [Fintype X] [Nonempty X]
-+instance : FunLike (CodensityAssignment X) X ℝ≥0∞ where
-+  coe := CodensityAssignment.toFun
-+  coe_injective' a b h := by cases a; cases b; congr
- 
--instance : CoeFun (MaxitiveProb X) (fun _ => X → ℝ) :=
--  ⟨fun μ => μ.toFun⟩
-+@[simp] theorem coe_mk (f : X → ℝ≥0∞) (hf) : (CodensityAssignment.mk f hf : X → ℝ≥0∞) = f := rfl
- 
--/-- The Dirac maxitive profile at a point. -/
--def dirac [DecidableEq X] (x₀ : X) : MaxitiveProb X where
--  toFun x := if x = x₀ then 0 else -1
--  nonpos x := by split_ifs <;> norm_num
--  normalized := by
--    apply le_antisymm
--    · exact Finset.sup'_le _ _ fun x _ => by split_ifs <;> norm_num
--    · exact Finset.le_sup' _ (Finset.mem_univ x₀) |>.trans' (by simp)
-+@[ext]
-+theorem ext {c d : CodensityAssignment X} (h : ∀ x, c x = d x) : c = d :=
-+  DFunLike.ext c d h
- 
--/-
--Existence of a mode point: there exists x with μ(x) = 0.
---/
--theorem exists_mode (μ : MaxitiveProb X) : ∃ x₀ : X, μ.toFun x₀ = 0 := by
--  -- Let `x₀` be the mode point of `μ`, which is defined as the element that maximizes `μ`.
--  obtain ⟨x₀, hx₀⟩ :
--      ∃ x₀, (μ.toFun x₀) = (Finset.univ.sup' Finset.univ_nonempty μ.toFun) := by
--        have := Finset.exists_max_image Finset.univ μ.toFun ( Finset.univ_nonempty );
--        exact ⟨ this.choose, le_antisymm ( Finset.le_sup' ( fun x => μ.toFun x ) ( Finset.mem_univ _ ) ) ( Finset.sup'_le _ _ fun x _ => this.choose_spec.2 x ( Finset.mem_univ x ) ) ⟩;
--  exact ⟨ x₀, hx₀.trans μ.normalized ⟩
-+theorem monotone (c : CodensityAssignment X) : Monotone c := c.monotone'
- 
--end MaxitiveProb
-+end CodensityAssignment
- 
--/-! ## Maxitive integral (tropical expectation) -/
-+/-! ## Maps Between Measures and Codensity Assignments -/
- 
--/-- The maxitive integral of f with respect to μ:
--    `Λ_μ(f) = max_x (μ(x) + f(x))`.
--    This is the tropical analogue of the expectation `𝔼_μ[f]`. -/
--def maxIntegral {X : Type*} [Fintype X] [Nonempty X]
--    (μ : MaxitiveProb X) (f : X → ℝ) : ℝ :=
--  Finset.univ.sup' Finset.univ_nonempty fun x => μ.toFun x + f x
-+/-- A set function is *monotone* if it preserves subset ordering. This is
-+    a basic property of measures, capacities, and maxitive measures. -/
-+def IsMonotoneSetFun {X : Type*} (μ : Set X → ℝ≥0∞) : Prop :=
-+  ∀ ⦃A B : Set X⦄, A ⊆ B → μ A ≤ μ B
- 
--/-! ## KR Dual Distance -/
-+/-- The canonical map from monotone set functions to codensity assignments.
-+    Maps `μ` to the function `x ↦ μ(↓x)`. -/
-+def measureToCodensity {X : Type*} [Preorder X]
-+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) : CodensityAssignment X where
-+  toFun := irreducibleClosedWeight μ
-+  monotone' := fun _ _ hxy => hμ (fun _ hz => le_trans hz hxy)
- 
--/-- The idempotent Kantorovich–Rubinstein dual discrepancy:
--    `d_KR(μ, ν) = sup_{f 1-Lip} (Λ_μ(f) - Λ_ν(f))`.
-+/-- Construct a set function from a codensity assignment by taking the
-+    supremum over elements in the set. This is a right inverse of
-+    `measureToCodensity` and models a "maxitive measure". -/
-+def codensityToMeasure {X : Type*} [Preorder X]
-+    (c : CodensityAssignment X) : Set X → ℝ≥0∞ :=
-+  fun A => ⨆ x ∈ A, c.toFun x
- 
--    This is the directed tropical analogue of the Wasserstein-1 distance.
--    It measures how much μ "exceeds" ν as tested by 1-Lipschitz observables. -/
--def iKRDual {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
--    (μ ν : MaxitiveProb X) : ℝ :=
--  sSup {r : ℝ | ∃ f : LipOne X, r = maxIntegral μ f.1 - maxIntegral ν f.1}
-+/-- Pushforward of a set function along a map `f`: `(f_* μ)(B) = μ(f⁻¹(B))`. -/
-+def pushforward {X Y : Type*} (f : X → Y)
-+    (μ : Set X → ℝ≥0∞) : Set Y → ℝ≥0∞ :=
-+  fun B => μ (f ⁻¹' B)
- 
--/-! ## Maxitive Coupling -/
-+/-- A set function is *maxitive* if its value on any set equals the supremum
-+    of its values on principal lower sets of elements in that set.
-+    This is the key property of "max-plus measures" / capacities in
-+    idempotent measure theory. -/
-+def IsMaxitiveSetFun {X : Type*} [Preorder X] (μ : Set X → ℝ≥0∞) : Prop :=
-+  ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x)
- 
--/-- A maxitive coupling of two profiles μ and ν on a finite type:
--    a joint weight function π : X → X → ℝ with prescribed max-marginals. -/
--structure MaxitiveCoupling {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
--    (μ ν : MaxitiveProb X) where
--  /-- The joint weight function. -/
--  toFun : X → X → ℝ
--  /-- All values are non-positive. -/
--  nonpos : ∀ x y, toFun x y ≤ 0
--  /-- First marginal: max over Y gives μ. -/
--  fst_marginal : ∀ x, Finset.univ.sup' Finset.univ_nonempty (toFun x) = μ.toFun x
--  /-- Second marginal: max over X gives ν. -/
--  snd_marginal : ∀ y, Finset.univ.sup' Finset.univ_nonempty (fun x => toFun x y) = ν.toFun y
-+/-! ## The Zero-Distance Setoid -/
- 
--/-! ## Transport Cost -/
--
--/-- The max-plus transport cost of a coupling π:
--    `C(π) = max_{x,y} (π(x,y) + dist(x,y))`. -/
--def transportCost {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
--    {μ ν : MaxitiveProb X} (π : MaxitiveCoupling μ ν) : ℝ :=
--  (Finset.univ ×ˢ Finset.univ).sup'
--    (by simp [Finset.Nonempty]) fun p => π.toFun p.1 p.2 + dist p.1 p.2
--
--/-- The idempotent Wasserstein distance (primal formulation):
--    `W(μ,ν) = inf_π C(π)`. -/
--def iWasserstein {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
--    (μ ν : MaxitiveProb X) : ℝ :=
--  sInf {r : ℝ | ∃ π : MaxitiveCoupling μ ν, transportCost π ≤ r}
--
--/-! ## Tropical Kernel Mean Embedding -/
--
--/-- A tropical kernel on X: a function k : X → X → ℝ. -/
--abbrev TropicalKernel (X : Type*) := X → X → ℝ
--
--/-- The tropical kernel mean embedding (finite version):
--    `kme_μ(y) = max_x (μ(x) + k(x, y))`. -/
--def tropKME {X : Type*} [Fintype X] [Nonempty X]
--    (k : TropicalKernel X) (μ : MaxitiveProb X) : X → ℝ :=
--  fun y => Finset.univ.sup' Finset.univ_nonempty fun x => μ.toFun x + k x y
--
--/-- A kernel is characteristic if tropKME is injective. -/
--def IsCharacteristicKernel {X : Type*} [Fintype X] [Nonempty X]
--    (k : TropicalKernel X) : Prop :=
--  Function.Injective (tropKME k : MaxitiveProb X → X → ℝ)
--
--/-- A kernel represents all 1-Lipschitz functions if every 1-Lip test is in the
--    max-plus span of kernel slices. -/
--def KernelRepresentsLipOne {X : Type*} [Fintype X] [Nonempty X] [PseudoMetricSpace X]
--    (k : TropicalKernel X) : Prop :=
--  ∀ f : LipOne X, ∃ (a : X → ℝ),
--    ∀ x, f.1 x = Finset.univ.sup' Finset.univ_nonempty fun z => a z + k z x
-+/-- The zero-distance equivalence relation on set functions:
-+    `μ ≈ ν` iff they have the same codensity weights on all principal lower sets. -/
-+def supportGaugeSetoid (X : Type*) [Preorder X] : Setoid (Set X → ℝ≥0∞) where
-+  r := supportGaugeEq
-+  iseqv := {
-+    refl := fun _ _ => rfl
-+    symm := fun h x => (h x).symm
-+    trans := fun h₁ h₂ x => (h₁ x).trans (h₂ x)
-+  }
- 
- end+/-
+Copyright (c) 2025. All rights reserved.
+Released under Apache 2.0 license as described in the file LICENSE.
+-/
+import Mathlib
+
+/-!
+# Functorial Mackey Completion for Maxitive Measures on Finite T₀ Spaces
+
+## Overview
+
+In a finite T₀ space, topology is equivalent to a specialization preorder:
+closed sets are lower sets, and irreducible closed sets are principal lower
+sets `↓x = {y | y ≤ x}`. We develop a completion theory for set functions
+(modeling maxitive measures / capacities) via **codensity assignments** on
+these irreducible closed sets.
+
+## Main definitions
+
+* `FiniteT0SupportClass` — the finite T₀ separation principle
+* `irreducibleClosed` — principal lower set `↓x`
+* `irreducibleClosedWeight` — weight of a set function on `↓x`
+* `supportGaugeEq` — equality of codensity weights
+* `CodensityAssignment` — monotone function `X → ℝ≥0∞`
+* `measureToCodensity` — canonical map from monotone set functions to codensity
+* `codensityToMeasure` — inverse: construct a set function from codensity data
+* `idempotentKantorovich` — pseudodistance via monotone test functions
+* `pushforward` — pushforward of a set function along a map
+
+## Main results
+
+* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
+* `idempotentKantorovich_eq_zero_iff_supportGaugeEq` — zero distance ⟺ codensity equality
+* `quotient_equiv_codensityAssignment` — the quotient by zero-distance ≃ CodensityAssignment
+* `idempotentKantorovich_pushforward_le` — pushforward is nonexpansive
+* `FunctorialIdempotentMackeyCompletion` — the full functorial completion theorem
+-/
+
+noncomputable section
+
+open scoped ENNReal
+open Set
+
+/-! ## The Finite T₀ Separation Principle -/
+
+/-- The finite T₀ separation principle: if two points have the same principal
+    lower set, they are equal. On a finite preorder, this is equivalent to
+    antisymmetry, hence to the T₀ separation axiom on the Alexandrov topology. -/
+class FiniteT0SupportClass (X : Type*) [Fintype X] [Preorder X] : Prop where
+  antisymm_of_closure_eq : ∀ {x y : X}, (∀ z : X, z ≤ x ↔ z ≤ y) → x = y
+
+/-- Every finite partial order is a finite T₀ space. -/
+instance instFiniteT0SupportClassOfPartialOrder
+    {X : Type*} [Fintype X] [PartialOrder X] : FiniteT0SupportClass X where
+  antisymm_of_closure_eq h := le_antisymm ((h _).mp le_rfl) ((h _).mpr le_rfl)
+
+/-! ## Irreducible Closed Sets and Codensity Weights -/
+
+/-- The irreducible closed set (principal lower set) associated to a point `x`.
+    In the Alexandrov topology on a preorder, this is `↓x = {y | y ≤ x}`,
+    which is always closed and irreducible. -/
+def irreducibleClosed (X : Type*) [Preorder X] (x : X) : Set X := {y | y ≤ x}
+
+/-- The codensity weight of a point `x` under a set function `μ`:
+    the value of `μ` on the principal lower set `↓x`. -/
+def irreducibleClosedWeight {X : Type*} [Preorder X]
+    (μ : Set X → ℝ≥0∞) (x : X) : ℝ≥0∞ :=
+  μ (irreducibleClosed X x)
+
+/-- Two set functions agree on codensity if they assign equal weight to
+    every principal lower set. This is the kernel of `measureToCodensity`. -/
+def supportGaugeEq {X : Type*} [Preorder X]
+    (μ ν : Set X → ℝ≥0∞) : Prop :=
+  ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x
+
+/-! ## Test Functions and Idempotent Kantorovich Distance -/
+
+/-- A test function on a preorder is a monotone real-valued function.
+    These serve as the dual objects in the idempotent Kantorovich theory. -/
+def IsTestFunction {X : Type*} [Preorder X] (f : X → ℝ) : Prop :=
+  Monotone f
+
+/-- The idempotent Kantorovich pseudodistance between two set functions.
+    This is the supremum over monotone test functions of the absolute
+    discrepancy in their "idempotent integrals" (max-plus pairings).
+    The symmetrization ensures `d(μ,ν) = 0 ↔ supportGaugeEq μ ν`. -/
+def idempotentKantorovich {X : Type*} [Fintype X] [Preorder X]
+    (μ ν : Set X → ℝ≥0∞) : ℝ≥0∞ :=
+  ⨆ f : {f : X → ℝ // IsTestFunction f},
+    ENNReal.ofReal (abs
+      ((⨆ x : X, (f.1 x - (irreducibleClosedWeight μ x).toReal)) -
+       (⨆ x : X, (f.1 x - (irreducibleClosedWeight ν x).toReal))))
+
+/-! ## Codensity Assignments -/
+
+/-- A codensity assignment on a preorder is a monotone function `X → ℝ≥0∞`.
+    Each value `c x` represents the "codensity" on the irreducible closed
+    set `↓x`. In finite T₀ spaces, this is the completed/canonical form
+    of a maxitive measure. -/
+structure CodensityAssignment (X : Type*) [Preorder X] where
+  /-- The underlying function assigning weights to points. -/
+  toFun : X → ℝ≥0∞
+  /-- The assignment is monotone with respect to the preorder. -/
+  monotone' : Monotone toFun
+
+namespace CodensityAssignment
+
+variable {X : Type*} [Preorder X]
+
+instance : FunLike (CodensityAssignment X) X ℝ≥0∞ where
+  coe := CodensityAssignment.toFun
+  coe_injective' a b h := by cases a; cases b; congr
+
+@[simp] theorem coe_mk (f : X → ℝ≥0∞) (hf) : (CodensityAssignment.mk f hf : X → ℝ≥0∞) = f := rfl
+
+@[ext]
+theorem ext {c d : CodensityAssignment X} (h : ∀ x, c x = d x) : c = d :=
+  DFunLike.ext c d h
+
+theorem monotone (c : CodensityAssignment X) : Monotone c := c.monotone'
+
+end CodensityAssignment
+
+/-! ## Maps Between Measures and Codensity Assignments -/
+
+/-- A set function is *monotone* if it preserves subset ordering. This is
+    a basic property of measures, capacities, and maxitive measures. -/
+def IsMonotoneSetFun {X : Type*} (μ : Set X → ℝ≥0∞) : Prop :=
+  ∀ ⦃A B : Set X⦄, A ⊆ B → μ A ≤ μ B
+
+/-- The canonical map from monotone set functions to codensity assignments.
+    Maps `μ` to the function `x ↦ μ(↓x)`. -/
+def measureToCodensity {X : Type*} [Preorder X]
+    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) : CodensityAssignment X where
+  toFun := irreducibleClosedWeight μ
+  monotone' := fun _ _ hxy => hμ (fun _ hz => le_trans hz hxy)
+
+/-- Construct a set function from a codensity assignment by taking the
+    supremum over elements in the set. This is a right inverse of
+    `measureToCodensity` and models a "maxitive measure". -/
+def codensityToMeasure {X : Type*} [Preorder X]
+    (c : CodensityAssignment X) : Set X → ℝ≥0∞ :=
+  fun A => ⨆ x ∈ A, c.toFun x
+
+/-- Pushforward of a set function along a map `f`: `(f_* μ)(B) = μ(f⁻¹(B))`. -/
+def pushforward {X Y : Type*} (f : X → Y)
+    (μ : Set X → ℝ≥0∞) : Set Y → ℝ≥0∞ :=
+  fun B => μ (f ⁻¹' B)
+
+/-- A set function is *maxitive* if its value on any set equals the supremum
+    of its values on principal lower sets of elements in that set.
+    This is the key property of "max-plus measures" / capacities in
+    idempotent measure theory. -/
+def IsMaxitiveSetFun {X : Type*} [Preorder X] (μ : Set X → ℝ≥0∞) : Prop :=
+  ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x)
+
+/-! ## The Zero-Distance Setoid -/
+
+/-- The zero-distance equivalence relation on set functions:
+    `μ ≈ ν` iff they have the same codensity weights on all principal lower sets. -/
+def supportGaugeSetoid (X : Type*) [Preorder X] : Setoid (Set X → ℝ≥0∞) where
+  r := supportGaugeEq
+  iseqv := {
+    refl := fun _ _ => rfl
+    symm := fun h x => (h x).symm
+    trans := fun h₁ h₂ x => (h₁ x).trans (h₂ x)
+  }
+
+end