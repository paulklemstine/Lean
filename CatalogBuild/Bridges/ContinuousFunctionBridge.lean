/-! # CatalogBuild.Bridges.ContinuousFunctionBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

import Mathlib

/-- Sum of continuous functions is continuous. -/
theorem continuous_add {X : Type*} [TopologicalSpace X]
    {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous (f + g) :=
  Continuous.add hf hg


/-- Difference of continuous functions is continuous. -/
theorem continuous_sub {X : Type*} [TopologicalSpace X]
    {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous fun x => f x - g x :=
  Continuous.sub hf hg


/-- Product of continuous functions is continuous. -/
theorem continuous_mul {X : Type*} [TopologicalSpace X]
    {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous (f * g) :=
  Continuous.mul hf hg


/-- Negation is continuous. -/
theorem continuous_neg {X : Type*} [TopologicalSpace X]
    {f : X → ℝ} (hf : Continuous f) :
    Continuous fun x => -f x :=
  Continuous.neg hf


/-- Maximum of continuous functions is continuous. -/
theorem continuous_max {X : Type*} [TopologicalSpace X]
    {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous fun x => max (f x) (g x) :=
  Continuous.max hf hg


/-- Minimum of continuous functions is continuous. -/
theorem continuous_min {X : Type*} [TopologicalSpace X]
    {f g : X → ℝ} (hf : Continuous f) (hg : Continuous g) :
    Continuous fun x => min (f x) (g x) :=
  Continuous.min hf hg


/-- Absolute value of a continuous function is continuous. -/
theorem continuous_abs {X : Type*} [TopologicalSpace X]
    {f : X → ℝ} (hf : Continuous f) :
    Continuous fun x => |f x| :=
  Continuous.abs hf


/-- Composition of continuous functions is continuous. -/
theorem continuous_comp {X Y Z : Type*}
    [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z]
    {f : X → Y} {g : Y → Z} (hg : Continuous g) (hf : Continuous f) :
    Continuous (g ∘ f) :=
  Continuous.comp hg hf


/-- Powers of continuous functions are continuous. -/
theorem continuous_pow {X : Type*} [TopologicalSpace X]
    {f : X → ℝ} (hf : Continuous f) (n : ℕ) :
    Continuous fun x => f x ^ n :=
  Continuous.pow hf n


/-- exp is continuous on ℝ. -/
theorem exp_continuous : Continuous Real.exp :=
  Real.continuous_exp


/-- Constant functions are continuous. -/
theorem const_continuous {X : Type*} [TopologicalSpace X] (c : ℝ) :
    Continuous fun _ : X => c :=
  continuous_const


/-- The identity is continuous. -/
theorem id_continuous {X : Type*} [TopologicalSpace X] :
    Continuous (@id X) :=
  continuous_id

