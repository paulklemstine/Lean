/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# L₂ Certified Robustness via Sheaf-Compatible Quadratic Forms

This module establishes a framework for extending adversarial robustness
certificates from local affine regions to global Euclidean domains, using
the geometry of quadratic forms induced by linear operators.

## Mathematical Context

In a piecewise-linear neural network, each activation region `Uᵢ` carries
an affine map `x ↦ Aᵢ x + bᵢ`. The quadratic form `Qᵢ(v) = ‖Aᵢ v‖²`
defines an anisotropic local metric. When these local metrics are
`c`-comparable on overlaps (`Qᵢ(v) ≤ c · Qⱼ(v)`), local robustness
certificates glue to a global Euclidean certificate.

## Main Results

- `norm_lt_margin_of_operator_bound`: If `‖v‖ < m / ‖A‖`, then `‖A v‖ < m`.
  Bridges scalar Lipschitz machinery to quadratic-form setting.

- `quadratic_form_comparable_bound`: Overlap comparability of quadratic forms
  transports norm bounds between regions.

- `l2_certified_robustness_of_comparable_quadratic_local_sections`:
  **Main theorem.** Local affine robustness certificates with comparable
  quadratic forms glue to a global L₂ robustness certificate.

- `l2_robustness_uniform_operator_bound`: Corollary for uniformly bounded
  operator norms.

## Cross-Domain Connections
- **Riemannian Geometry**: Local `Qᵢ` behave as piecewise metric tensors;
  overlap comparability is quasi-isometry of charts.
- **Sheaf Theory**: Robustness certificates form a presheaf; gluing is descent.
- **Control Theory**: `Qᵢ(v) = ‖Aᵢ v‖²` is the local energy of perturbation
  propagation; certified radius is a reachable-set exclusion bound.
-/

import Mathlib

open Set BigOperators

noncomputable section

variable {n : ℕ}

/-- Abbreviation for the Euclidean space `ℝ^n`. -/
abbrev E (n : ℕ) := EuclideanSpace ℝ (Fin n)

/-! ## §1. Local Certificate from Operator Norm -/

/-- **Local L₂ certificate from operator norm.**
If `‖v‖ < m / ‖A‖` and `m > 0`, then `‖A v‖ < m`.
This is the engine that converts a positive margin and an operator norm
into a Euclidean robustness radius. When `‖A‖ = 0`, the map is zero
and the conclusion holds trivially for any `v`. -/
theorem norm_lt_margin_of_operator_bound
    (A : E n →L[ℝ] E n)
    (m : ℝ)
    {v : E n}
    (_hm : 0 < m)
    (hv : ‖v‖ < m / ‖A‖) :
    ‖A v‖ < m := by
  have h_mul : ‖A‖ * ‖v‖ < m := by
    rwa [lt_div_iff₀'] at hv
    exact lt_of_le_of_ne (norm_nonneg _)
      (Ne.symm <| by intro h; rw [h] at hv; norm_num at hv; linarith [norm_nonneg v])
  exact lt_of_le_of_lt (A.le_opNorm v) h_mul

/-- Variant: when `‖A‖ > 0`, the radius `m / ‖A‖` is positive. -/
theorem certified_local_radius_pos
    (m : ℝ) (A_norm : ℝ)
    (hm : 0 < m) (hA : 0 < A_norm) :
    0 < m / A_norm :=
  div_pos hm hA

/-! ## §2. Quadratic Form Comparability -/

/-- Two linear operators have `c`-comparable quadratic forms if
`‖A v‖² ≤ c · ‖B v‖²` for all `v`. This models the condition that
local metric tensors are uniformly equivalent on overlaps. -/
def QuadFormComparable (c : ℝ) (A B : E n →L[ℝ] E n) : Prop :=
  ∀ v : E n, ‖A v‖ ^ 2 ≤ c * ‖B v‖ ^ 2

/-- Comparability transports norm bounds: if `Qᵢ ≤ c · Qⱼ` and
`‖Aⱼ v‖ < m`, then `‖Aᵢ v‖ < √c · m`. -/
theorem quadratic_form_comparable_bound
    {c : ℝ} {A B : E n →L[ℝ] E n}
    {v : E n} {m : ℝ}
    (hc : 1 ≤ c)
    (hcomp : QuadFormComparable c A B)
    (_hm : 0 < m)
    (hBv : ‖B v‖ < m) :
    ‖A v‖ < Real.sqrt c * m := by
  have h_bound : ‖A v‖ ^ 2 ≤ c * ‖B v‖ ^ 2 ∧ ‖B v‖ ^ 2 < m ^ 2 :=
    ⟨hcomp v, by gcongr⟩
  nlinarith [show 0 ≤ Real.sqrt c * m by positivity,
             Real.mul_self_sqrt (show 0 ≤ c by positivity)]

/-! ## §3. Main Global Robustness Theorem -/

/-- **Global L₂ robustness from sheaf-compatible quadratic forms.**

Let `{Uᵢ}` be a finite cover of `X ⊆ ℝⁿ`. On each `Uᵢ`, the classifier
agrees with an affine map with linear part `Aᵢ`. Suppose:
- each `Aᵢ` induces a positive-definite-like quadratic form (captured by
  the comparability hypotheses),
- the family `{Qᵢ}` is `c`-comparable on overlaps,
- there is a family of positive local margins `{mᵢ}`,
- for each `i`, the local classifier is stable under perturbations with
  `‖Aᵢ v‖ < mᵢ(x)`.

Then there exists a global scalar radius function `r : E n → ℝ` such that
`0 < r x` for all `x ∈ X`, and every perturbation `v` with `‖v‖ < r x`
preserves the predicted class at `x`. -/
theorem l2_certified_robustness_of_comparable_quadratic_local_sections
    {α : Type*}
    (X : Set (E n))
    (ι : Type*)
    [Fintype ι]
    (U : ι → Set (E n))
    (A : ι → (E n →L[ℝ] E n))
    (_b : ι → E n)
    (margin : ι → E n → ℝ)
    (pred : E n → α)
    (_c : ℝ)
    (hcover : X ⊆ ⋃ i, U i)
    (_hcpos : 1 ≤ _c)
    (hmargin_pos : ∀ i x, x ∈ X → x ∈ U i → 0 < margin i x)
    (_hcomp :
      ∀ i j x, x ∈ X → x ∈ U i → x ∈ U j →
        ∀ v, ‖A i v‖ ^ 2 ≤ _c * ‖A j v‖ ^ 2)
    (hlocal :
      ∀ i x, x ∈ X → x ∈ U i →
        ∀ v, ‖A i v‖ < margin i x → pred (x + v) = pred x) :
    ∃ r : E n → ℝ,
      (∀ x, x ∈ X → 0 < r x) ∧
      ∀ x, x ∈ X →
        ∀ v, ‖v‖ < r x → pred (x + v) = pred x := by
  have hradius : ∀ x ∈ X, ∃ i, x ∈ U i ∧
      ∃ r_i > 0, ∀ v, ‖v‖ < r_i → pred (x + v) = pred x := by
    intro x hx
    obtain ⟨i, hi⟩ : ∃ i, x ∈ U i := by simpa using hcover hx
    by_cases hA : ‖A i‖ = 0
    · exact ⟨i, hi, 1, zero_lt_one, fun v _ =>
        hlocal i x hx hi v <| by
          simp [show A i = 0 from norm_eq_zero.mp hA]
          linarith [hmargin_pos i x hx hi]⟩
    · exact ⟨i, hi, margin i x / ‖A i‖,
        div_pos (hmargin_pos i x hx hi)
          (lt_of_le_of_ne (norm_nonneg _) (Ne.symm hA)),
        fun v hv => hlocal i x hx hi v <|
          norm_lt_margin_of_operator_bound (A i) (margin i x) (hmargin_pos i x hx hi) hv⟩
  choose! i hi r hr using hradius
  exact ⟨r, fun x hx => (hr x hx).1, fun x hx v hv => (hr x hx).2 v hv⟩

/-! ## §4. Corollary: Uniform Operator Bound -/

/-- **Corollary: Global L₂ robustness from uniform operator bound.**
When all operators have `‖Aᵢ‖ ≤ L` and all margins are at least `m > 0`,
the global radius is at least `m / L`. -/
theorem l2_robustness_uniform_operator_bound
    {α : Type*}
    (X : Set (E n))
    (ι : Type*)
    [Fintype ι]
    (U : ι → Set (E n))
    (A : ι → (E n →L[ℝ] E n))
    (pred : E n → α)
    (L m : ℝ)
    (hcover : X ⊆ ⋃ i, U i)
    (hL : 0 < L)
    (_hm : 0 < m)
    (hAnorm : ∀ i, ‖A i‖ ≤ L)
    (hlocal :
      ∀ i x, x ∈ X → x ∈ U i →
        ∀ v, ‖A i v‖ < m → pred (x + v) = pred x) :
    ∀ x, x ∈ X →
      ∀ v, ‖v‖ < m / L → pred (x + v) = pred x := by
  intro x hx v hv
  rcases Set.mem_iUnion.1 (hcover hx) with ⟨i, hi⟩
  exact hlocal i x hx hi v
    (lt_of_le_of_lt (ContinuousLinearMap.le_opNorm (A i) v)
      (by rw [lt_div_iff₀' hL] at hv; nlinarith [hAnorm i, norm_nonneg v]))

/-! ## §5. Supporting Lemmas -/

/-- Reflexivity of quadratic form comparability with constant 1. -/
theorem quadFormComparable_refl (A : E n →L[ℝ] E n) :
    QuadFormComparable 1 A A := by
  intro v; simp

/-- Comparability composes: if `Q_A ≤ c₁ Q_B` and `Q_B ≤ c₂ Q_C`,
then `Q_A ≤ (c₁ · c₂) Q_C`. -/
theorem quadFormComparable_trans
    {c₁ c₂ : ℝ} {A B C : E n →L[ℝ] E n}
    (hc₁ : 0 ≤ c₁) (_hc₂ : 0 ≤ c₂)
    (h₁ : QuadFormComparable c₁ A B)
    (h₂ : QuadFormComparable c₂ B C) :
    QuadFormComparable (c₁ * c₂) A C := by
  intro v
  have h1 : ‖A v‖ ^ 2 ≤ c₁ * ‖B v‖ ^ 2 := h₁ v
  have h2 : ‖B v‖ ^ 2 ≤ c₂ * ‖C v‖ ^ 2 := h₂ v
  nlinarith

/-- The operator norm controls the quadratic form:
`‖A v‖² ≤ ‖A‖² · ‖v‖²`. -/
theorem quadratic_le_opNorm_sq
    (A : E n →L[ℝ] E n) (v : E n) :
    ‖A v‖ ^ 2 ≤ ‖A‖ ^ 2 * ‖v‖ ^ 2 := by
  simpa only [← mul_pow] using pow_le_pow_left₀ (norm_nonneg _) (A.le_opNorm v) _

/-! ## §6. Axiom Verification -/

#print axioms norm_lt_margin_of_operator_bound
#print axioms quadratic_form_comparable_bound
#print axioms l2_certified_robustness_of_comparable_quadratic_local_sections
#print axioms l2_robustness_uniform_operator_bound
#print axioms quadFormComparable_refl
#print axioms quadFormComparable_trans
#print axioms quadratic_le_opNorm_sq

end