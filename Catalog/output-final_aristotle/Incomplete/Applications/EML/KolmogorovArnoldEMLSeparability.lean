/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Which targets admit a rank-one EML Kolmogorov–Arnold representation?

`Catalog/Applications/KolmogorovArnoldEML.lean` exhibits the product `x·y` as a
*rank-one* EML Kolmogorov–Arnold superposition `exp(log x + log y)` on the
positive quadrant, and its Lab Notes flag the open frontier:

> "Non-separable continuous targets cannot collapse to rank one — that is the
>  natural next frontier."

This file settles that frontier with an exact **characterization**. For a
two-variable target `f : ℝ → ℝ → ℝ` we introduce:

* `MulSeparable f` — `f x y = a x · b y` for some univariate `a, b`;
* `CrossMul f` — the cross-multiplicative identity
  `f x y · f x' y' = f x y' · f x' y` for all `x y x' y'`.

The main results are:

* `mulSeparable_iff_crossMul` — over any target with a single nonzero value,
  `MulSeparable f ↔ CrossMul f`.  (`CrossMul` is the checkable invariant.)
* `rankOne_exp_of_pos_crossMul` / `rankOne_eml_of_pos_crossMul` — a **strictly
  positive** target satisfying `CrossMul` has an explicit rank-one EML
  representation `f x y = exp(ψ x + φ y) = outerExp.eval (ψ x + φ y)`.
* `rankOne_exp_continuous` — when the two coordinate slices of `f` are
  continuous, the inner functions `ψ, φ` are continuous, matching the continuity
  demanded by the Kolmogorov–Arnold theorem.
* `crossMul_of_rankOne_exp` — the converse: every rank-one `exp(ψ+φ)` target is
  `CrossMul`.
* **Sharp obstruction.** `add_not_crossMul`, `add_not_mulSeparable`,
  `add_not_rankOne_exp` — the additive target `x + y` is *not* `CrossMul`, hence
  has *no* rank-one EML representation.  This is the precise sense in which `x·y`
  (multiplicatively separable) and `x+y` (not) sit on opposite sides of the
  rank-one boundary.

## Lab Notes — see `-- !-- Lab Notes -- !--` block below.
-/
import Mathlib
import Applications.EMLTermAlgebra
import Applications.KolmogorovArnoldEML

open Real

namespace KolmogorovArnoldEMLSep

open KolmogorovArnoldEML

/-! ### The two structural predicates -/

/-- `f` is **multiplicatively separable**: `f x y = a x · b y` for univariate
`a, b`. -/
def MulSeparable (f : ℝ → ℝ → ℝ) : Prop :=
  ∃ a b : ℝ → ℝ, ∀ x y, f x y = a x * b y

/-- The **cross-multiplicative identity** — a *checkable* (4-point) invariant. -/
def CrossMul (f : ℝ → ℝ → ℝ) : Prop :=
  ∀ x y x' y', f x y * f x' y' = f x y' * f x' y

/-! ### `MulSeparable ↔ CrossMul` -/

/-- Separable targets satisfy the cross-multiplicative identity (easy direction). -/
theorem crossMul_of_mulSeparable {f : ℝ → ℝ → ℝ} (h : MulSeparable f) :
    CrossMul f := by
  obtain ⟨ a, b, h ⟩ := h; exact fun x y x' y' => by rw [ h x y, h x' y', h x y', h x' y ] ; ring;

/-- **Reconstruction.** A `CrossMul` target with one nonzero value `f x₀ y₀ ≠ 0`
is multiplicatively separable: the slices `a x = f x y₀ / f x₀ y₀` and
`b y = f x₀ y` factor it. -/
theorem mulSeparable_of_crossMul {f : ℝ → ℝ → ℝ} (x₀ y₀ : ℝ)
    (h0 : f x₀ y₀ ≠ 0) (h : CrossMul f) : MulSeparable f := by
  exact ⟨ fun x => f x y₀ / f x₀ y₀, fun y => f x₀ y, fun x y => by rw [ div_mul_eq_mul_div, eq_div_iff h0 ] ; linarith [ h x y x₀ y₀ ] ⟩

/-- **Characterization.** For targets with at least one nonzero value,
multiplicative separability is exactly the cross-multiplicative identity. -/
theorem mulSeparable_iff_crossMul {f : ℝ → ℝ → ℝ} (x₀ y₀ : ℝ)
    (h0 : f x₀ y₀ ≠ 0) : MulSeparable f ↔ CrossMul f :=
  ⟨crossMul_of_mulSeparable, mulSeparable_of_crossMul x₀ y₀ h0⟩

/-! ### Rank-one EML representation of positive `CrossMul` targets -/

/-- **Rank-one EML representation.** A strictly positive `CrossMul` target is a
single outer `exp` applied to a sum of two inner univariate functions:
`f x y = exp (ψ x + φ y)`. -/
theorem rankOne_exp_of_pos_crossMul {f : ℝ → ℝ → ℝ} (hpos : ∀ x y, 0 < f x y)
    (h : CrossMul f) :
    ∃ ψ φ : ℝ → ℝ, ∀ x y, f x y = Real.exp (ψ x + φ y) := by
  use fun x => Real.log ( f x 0 / f 0 0 ), fun y => Real.log ( f 0 y );
  intro x y; rw [ Real.exp_add, Real.exp_log ( div_pos ( hpos _ _ ) ( hpos _ _ ) ), Real.exp_log ( hpos _ _ ) ] ; rw [ div_mul_eq_mul_div, eq_div_iff ] <;> nlinarith [ hpos x y, hpos x 0, hpos 0 y, hpos 0 0, h x y 0 0 ] ;

/-- The same representation phrased through the catalog's EML term algebra:
the outer function is `KolmogorovArnoldEML.outerExp` (i.e. `expOf var`). -/
theorem rankOne_eml_of_pos_crossMul {f : ℝ → ℝ → ℝ} (hpos : ∀ x y, 0 < f x y)
    (h : CrossMul f) :
    ∃ ψ φ : ℝ → ℝ, ∀ x y, f x y = outerExp.eval (ψ x + φ y) := by
  obtain ⟨ψ, φ, hψφ⟩ := rankOne_exp_of_pos_crossMul hpos h;
  exact ⟨ ψ, φ, fun x y => hψφ x y ▸ rfl ⟩

/-- **Continuity of the inner functions.** If the coordinate slices `x ↦ f x 0`
and `y ↦ f 0 y` are continuous (and `f > 0`), the inner functions `ψ, φ` of the
rank-one EML representation can be chosen continuous — matching the continuity
required by the Kolmogorov–Arnold theorem. -/
theorem rankOne_exp_continuous {f : ℝ → ℝ → ℝ} (hpos : ∀ x y, 0 < f x y)
    (hx : Continuous fun x => f x 0) (hy : Continuous fun y => f 0 y)
    (h : CrossMul f) :
    ∃ ψ φ : ℝ → ℝ, Continuous ψ ∧ Continuous φ ∧
      ∀ x y, f x y = Real.exp (ψ x + φ y) := by
  refine ⟨fun x => Real.log (f x 0 / f 0 0), fun y => Real.log (f 0 y), ?_, ?_, ?_⟩
  · exact Continuous.log (hx.div_const _) fun x => ne_of_gt (div_pos (hpos _ _) (hpos _ _))
  · exact Continuous.log hy fun y => ne_of_gt (hpos _ _)
  · intro x y
    rw [Real.exp_add, Real.exp_log (div_pos (hpos _ _) (hpos _ _)), Real.exp_log (hpos _ _),
      div_mul_eq_mul_div, eq_div_iff (hpos 0 0).ne']
    nlinarith [h x y 0 0]

/-! ### Converse: rank-one `exp` targets are `CrossMul` -/

/-- Every rank-one `exp(ψ x + φ y)` target satisfies the cross-multiplicative
identity. -/
theorem crossMul_of_rankOne_exp (ψ φ : ℝ → ℝ) :
    CrossMul (fun x y => Real.exp (ψ x + φ y)) := by
  intro x y x' y'
  simp only [← Real.exp_add]
  ring_nf

/-! ### The sharp obstruction: the additive target `x + y` -/

/-- The additive target `x + y` violates the cross-multiplicative identity at the
four points `(1,1), (0,0), (1,0), (0,1)`: `2·0 ≠ 1·1`. -/
theorem add_not_crossMul : ¬ CrossMul (fun x y => x + y) := by
  exact fun h => by have := h 1 1 0 0; norm_num at this;

/-- Consequently `x + y` is **not** multiplicatively separable. -/
theorem add_not_mulSeparable : ¬ MulSeparable (fun x y => x + y) :=
  fun h => add_not_crossMul (crossMul_of_mulSeparable h)

/-- **No rank-one EML representation of the sum.** There are no inner functions
`ψ, φ` with `x + y = exp(ψ x + φ y)` for all `x, y` — in sharp contrast to the
product `x·y = exp(log x + log y)`. -/
theorem add_not_rankOne_exp :
    ¬ ∃ ψ φ : ℝ → ℝ, ∀ x y, (x + y : ℝ) = Real.exp (ψ x + φ y) := by
  rintro ⟨ψ, φ, h_eq⟩
  refine add_not_crossMul ?_
  intro x y x' y'
  dsimp only
  rw [h_eq x y, h_eq x' y', h_eq x y', h_eq x' y]
  exact crossMul_of_rankOne_exp ψ φ x y x' y'

/-! ### Consistency: the product sits on the separable side -/

/-- The product target is multiplicatively separable (with `a = b = id`). -/
theorem mul_mulSeparable : MulSeparable (fun x y => x * y) :=
  ⟨id, id, fun _ _ => rfl⟩

/-- The product target satisfies the cross-multiplicative identity. -/
theorem mul_crossMul : CrossMul (fun x y => x * y) :=
  crossMul_of_mulSeparable mul_mulSeparable

end KolmogorovArnoldEMLSep