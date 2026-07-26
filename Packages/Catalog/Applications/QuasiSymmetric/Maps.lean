/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quasi-symmetric maps generalize bi-Lipschitz maps

A homeomorphism `f` between metric spaces is *η-quasisymmetric* when the relative
distortion of any triple of points is controlled by a single one-variable gauge `η`:

  `dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)`.

Quasisymmetry is the natural conformal-geometry generalization of the bi-Lipschitz
condition: a bi-Lipschitz map distorts *absolute* distances by a bounded factor,
whereas a quasisymmetric map only distorts *relative* distances (ratios) by a
bounded amount.  This file builds a small but genuine theory:

* `biLipschitz_isQuasisymmetric` — every `L`-bi-Lipschitz map is quasisymmetric with
  the *linear* gauge `η t = L² · t`.  This is the precise sense in which the new class
  contains the classical one.
* `isQuasisymmetric_comp` — quasisymmetry is closed under composition, with the gauges
  composing as `η_g ∘ η_f`.  This makes the class a category of metric maps.
* `isQuasisymmetric_constant_or_injective` — the *rigidity dichotomy*: a quasisymmetric
  map is either constant or injective; there is no intermediate collapse.  This is the
  conceptual heart of why quasisymmetry is the right weakening of bi-Lipschitz.
* `isQuasisymmetric_const` and `isQuasisymmetric_id` — both branches of the dichotomy
  are realized, so the dichotomy is sharp.
-/

import Mathlib

namespace QuasiSymmetric

variable {X Y Z : Type*} [MetricSpace X] [MetricSpace Y] [MetricSpace Z]

/-- `f` is `η`-quasisymmetric: the distortion of every triple `(x, a, b)` with `x ≠ b`
is controlled by the one-variable gauge `η` applied to the input distance ratio. -/
def IsQuasisymmetric (f : X → Y) (η : ℝ → ℝ) : Prop :=
  ∀ x a b : X, x ≠ b →
    dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)

/-- `f` is `L`-bi-Lipschitz: absolute distances are distorted by a factor in `[L⁻¹, L]`. -/
def IsBiLipschitzWith (f : X → Y) (L : ℝ) : Prop :=
  1 ≤ L ∧ ∀ x y : X, L⁻¹ * dist x y ≤ dist (f x) (f y) ∧ dist (f x) (f y) ≤ L * dist x y

/-
!-- An `L`-bi-Lipschitz map is quasisymmetric with the linear gauge `η t = L²·t`:
bound `dist(fx,fa) ≤ L·dist(x,a)` from above and `dist(fx,fb) ≥ L⁻¹·dist(x,b)` from
below, then clear the ratio `dist(x,a)/dist(x,b)`.  Bi-Lipschitz ⊂ quasisymmetric. -!--

Every `L`-bi-Lipschitz map is quasisymmetric with the linear gauge `t ↦ L² · t`.
This exhibits the bi-Lipschitz class as a sub-class of the quasisymmetric maps.
-/
theorem biLipschitz_isQuasisymmetric (f : X → Y) (L : ℝ) (h : IsBiLipschitzWith f L) :
    IsQuasisymmetric f (fun t => L ^ 2 * t) := by
  intro x a b hx_ne_b
  have h_ineq : dist (f x) (f a) ≤ L * dist x a ∧ dist (f x) (f b) ≥ L⁻¹ * dist x b := by
    exact ⟨ h.2 x a |>.2, h.2 x b |>.1 ⟩;
  convert h_ineq.1.trans _ using 1;
  convert mul_le_mul_of_nonneg_left h_ineq.2 ( show 0 ≤ L ^ 2 * dist x a / dist x b by exact div_nonneg ( mul_nonneg ( sq_nonneg _ ) ( dist_nonneg ) ) ( dist_nonneg ) ) using 1 ; ring_nf ;
  · simp +decide [ sq, mul_assoc, mul_comm L, show L ≠ 0 by linarith [ h.1 ], show dist x b ≠ 0 by exact dist_ne_zero.2 hx_ne_b ];
  · ring!

/-
!-- Composition: apply `g`'s gauge at the image triple (using injectivity of `f` so
the centre/base images stay distinct), bound the inner ratio by `η_f` using positivity
of the base image distance, and push through the monotone outer gauge `η_g`. -!--

Quasisymmetry is closed under composition: if `f` is `η_f`-quasisymmetric and
injective, and `g` is `η_g`-quasisymmetric with a monotone gauge, then `g ∘ f` is
`(η_g ∘ η_f)`-quasisymmetric.
-/
theorem isQuasisymmetric_comp (f : X → Y) (g : Y → Z) (ηf ηg : ℝ → ℝ)
    (hf : IsQuasisymmetric f ηf) (hg : IsQuasisymmetric g ηg)
    (hmono : Monotone ηg) (hinj : Function.Injective f) :
    IsQuasisymmetric (g ∘ f) (ηg ∘ ηf) := by
  intro x a b hxb; have := hg ( f x ) ( f a ) ( f b ) ; simp_all +decide [ hinj.eq_iff ]
  refine' le_trans this ( mul_le_mul_of_nonneg_right ( hmono _ ) ( dist_nonneg ) );
  exact div_le_iff₀ ( dist_pos.mpr ( hinj.ne hxb ) ) |>.2 ( hf x a b hxb )

/-
!-- Rigidity dichotomy: if two distinct points collapse (`dist(fx,fa)=0`), the gauge
inequality with that pair as base forces `dist(fx,fc)=0` for every `c`, so `f` is
constant; otherwise `f` is injective. -!--

The quasisymmetric rigidity dichotomy: a quasisymmetric map is either constant
or injective.  There is no partial collapse.
-/
theorem isQuasisymmetric_constant_or_injective (f : X → Y) (η : ℝ → ℝ)
    (h : IsQuasisymmetric f η) :
    (∃ c : Y, ∀ z : X, f z = c) ∨ Function.Injective f := by
  by_contra! h_contra;
  obtain ⟨x, a, hxa, hfa⟩ : ∃ x a, x ≠ a ∧ f x = f a := by
    simpa [ Function.Injective, and_comm ] using h_contra.2;
  obtain ⟨c, hc⟩ : ∃ c : Y, ∀ z : X, f z = c := by
    use f x; intro z; have := h x z a; simp_all +decide
  exact h_contra.1 c |> fun ⟨ z, hz ⟩ => hz ( hc z )

/-
!-- A constant map satisfies the inequality trivially (both sides vanish), realizing
the constant branch of the dichotomy. -!--

Constant maps are quasisymmetric (with any gauge): the constant branch of the
dichotomy is realized.
-/
theorem isQuasisymmetric_const (c : Y) (η : ℝ → ℝ) :
    IsQuasisymmetric (fun _ : X => c) η := by
  intro x a b hxb; simp [dist_self]

/-
!-- The identity is `1`-bi-Lipschitz, hence quasisymmetric with the identity gauge;
the inequality is in fact an equality once `dist(x,b) ≠ 0`. -!--

The identity map is quasisymmetric with the identity gauge `t ↦ t`, realizing the
injective branch of the dichotomy.
-/
theorem isQuasisymmetric_id :
    IsQuasisymmetric (id : X → X) (fun t => t) := by
  intro x a b hxb; by_cases h : x = b <;> simp_all +decide

end QuasiSymmetric