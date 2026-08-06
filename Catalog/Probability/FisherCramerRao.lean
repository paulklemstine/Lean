/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Fisher information and the Cramér–Rao bound for nonlinear population codes

The population-coding results of `Catalog/Novelty/NeuralCoding.lean` and of
`Catalog/Probability/NeuralCoding/IIDPopulationCoding.lean` bound the error of an
*averaging* estimator.  The fundamental limit for an arbitrary decoder of a
(possibly nonlinear) population code is instead the Cramér–Rao bound, proved
here for a finitely supported response distribution.

## Model

A population code is a family of response distributions `p θ : X → ℝ` on a
finite response set `X`, parametrised by the encoded stimulus `θ ∈ ℝ`.  A
decoder is a function `T : X → ℝ`, unbiased near `θ` if `∑ x, T x * p t x = t`
for all `t` near `θ`.

## Results

1. `sum_deriv_eq_zero` — the scores have mean zero.
2. `sum_centered_mul_deriv` — the centred decoder correlates with the score
   exactly to first order.
3. `cramer_rao` — **the Cramér–Rao bound**: `1 ≤ Var(T) * I(θ)` for every
   locally unbiased decoder, i.e. no decoder beats `1 / I(θ)`.
4. `variance_ge_inv_fisher` — the same statement as a variance lower bound.
5. `bernoulli_cramer_rao_sharp` — the bound is **sharp**: a two-response
   population with `I = 4` admits an unbiased decoder of variance exactly `1/4`.
-/

namespace Catalog.Probability.NeuralCoding.Fisher

open Finset

variable {X : Type*} [Fintype X]

/-- **Fisher information** of a response distribution `p` with stimulus
derivative `p'`: `I = ∑ x, p'(x)² / p(x)`. -/
noncomputable def fisherInfo (p p' : X → ℝ) : ℝ := ∑ x, (p' x) ^ 2 / p x

/-- Variance of a decoder `T` about the true stimulus `θ`. -/
def estVariance (p T : X → ℝ) (θ : ℝ) : ℝ := ∑ x, p x * (T x - θ) ^ 2

variable {p : ℝ → X → ℝ} {p' T : X → ℝ} {θ : ℝ}

/-- **The scores have mean zero.**  Differentiating the normalisation identity
gives `∑ x, p' x = 0`. -/
theorem sum_deriv_eq_zero
    (hderiv : ∀ x, HasDerivAt (fun t => p t x) (p' x) θ)
    (hnorm : ∀ᶠ t in nhds θ, ∑ x, p t x = 1) :
    ∑ x, p' x = 0 := by
  have hd1 : HasDerivAt (fun t => ∑ x, p t x) (∑ x, p' x) θ :=
    HasDerivAt.fun_sum (fun x _ => hderiv x)
  have heq : (fun t => ∑ x, p t x) =ᶠ[nhds θ] (fun _ => (1 : ℝ)) := hnorm
  have hd2 : HasDerivAt (fun t => ∑ x, p t x) 0 θ :=
    (hasDerivAt_const θ (1 : ℝ)).congr_of_eventuallyEq heq
  exact hd1.unique hd2

/-- Differentiating local unbiasedness: `∑ x, T x * p' x = 1`. -/
theorem sum_mul_deriv_eq_one
    (hderiv : ∀ x, HasDerivAt (fun t => p t x) (p' x) θ)
    (hunb : ∀ᶠ t in nhds θ, ∑ x, T x * p t x = t) :
    ∑ x, T x * p' x = 1 := by
  have hd1 : HasDerivAt (fun t => ∑ x, T x * p t x) (∑ x, T x * p' x) θ :=
    HasDerivAt.fun_sum (fun x _ => (hderiv x).const_mul (T x))
  have heq : (fun t => ∑ x, T x * p t x) =ᶠ[nhds θ] (fun t => t) := hunb
  have hd2 : HasDerivAt (fun t => ∑ x, T x * p t x) 1 θ :=
    (hasDerivAt_id θ).congr_of_eventuallyEq heq
  exact hd1.unique hd2

/-- The centred decoder has unit correlation with the score. -/
theorem sum_centered_mul_deriv
    (hderiv : ∀ x, HasDerivAt (fun t => p t x) (p' x) θ)
    (hnorm : ∀ᶠ t in nhds θ, ∑ x, p t x = 1)
    (hunb : ∀ᶠ t in nhds θ, ∑ x, T x * p t x = t) :
    ∑ x, (T x - θ) * p' x = 1 := by
  have h0 := sum_deriv_eq_zero hderiv hnorm
  have h1 := sum_mul_deriv_eq_one (T := T) hderiv hunb
  have hsplit : ∑ x, (T x - θ) * p' x = (∑ x, T x * p' x) - θ * ∑ x, p' x := by
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun x _ => by ring)
  rw [hsplit, h0, h1]
  ring

/-- **Cramér–Rao bound for a finite population code.**  Every locally unbiased
decoder `T` of the stimulus `θ` satisfies `1 ≤ Var(T) * I(θ)`: the decoding
variance cannot beat the reciprocal Fisher information of the population. -/
theorem cramer_rao (hpos : ∀ x, 0 < p θ x)
    (hderiv : ∀ x, HasDerivAt (fun t => p t x) (p' x) θ)
    (hnorm : ∀ᶠ t in nhds θ, ∑ x, p t x = 1)
    (hunb : ∀ᶠ t in nhds θ, ∑ x, T x * p t x = t) :
    1 ≤ estVariance (p θ) T θ * fisherInfo (p θ) p' := by
  classical
  set f : X → ℝ := fun x => Real.sqrt (p θ x) * (T x - θ) with hf
  set g : X → ℝ := fun x => p' x / Real.sqrt (p θ x) with hg
  have hsqrt_pos : ∀ x, 0 < Real.sqrt (p θ x) := fun x => Real.sqrt_pos.mpr (hpos x)
  have hfg : ∀ x, f x * g x = (T x - θ) * p' x := by
    intro x
    have hne : Real.sqrt (p θ x) ≠ 0 := (hsqrt_pos x).ne'
    show Real.sqrt (p θ x) * (T x - θ) * (p' x / Real.sqrt (p θ x)) = (T x - θ) * p' x
    field_simp
  have hf2 : ∀ x, f x ^ 2 = p θ x * (T x - θ) ^ 2 := by
    intro x
    have : Real.sqrt (p θ x) ^ 2 = p θ x := Real.sq_sqrt (hpos x).le
    rw [hf]
    rw [mul_pow, this]
  have hg2 : ∀ x, g x ^ 2 = (p' x) ^ 2 / p θ x := by
    intro x
    have hs : Real.sqrt (p θ x) ^ 2 = p θ x := Real.sq_sqrt (hpos x).le
    rw [hg, div_pow, hs]
  have hcs : (∑ x, f x * g x) ^ 2 ≤ (∑ x, f x ^ 2) * (∑ x, g x ^ 2) :=
    Finset.sum_mul_sq_le_sq_mul_sq _ f g
  have hone : (∑ x, f x * g x) = 1 := by
    rw [Finset.sum_congr rfl (fun x _ => hfg x)]
    exact sum_centered_mul_deriv hderiv hnorm hunb
  rw [hone] at hcs
  rw [Finset.sum_congr rfl (fun x _ => hf2 x), Finset.sum_congr rfl (fun x _ => hg2 x)] at hcs
  simpa [estVariance, fisherInfo] using hcs

/-- **Variance form of the Cramér–Rao bound.** -/
theorem variance_ge_inv_fisher (hpos : ∀ x, 0 < p θ x)
    (hderiv : ∀ x, HasDerivAt (fun t => p t x) (p' x) θ)
    (hnorm : ∀ᶠ t in nhds θ, ∑ x, p t x = 1)
    (hunb : ∀ᶠ t in nhds θ, ∑ x, T x * p t x = t)
    (hI : 0 < fisherInfo (p θ) p') :
    1 / fisherInfo (p θ) p' ≤ estVariance (p θ) T θ := by
  have h := cramer_rao hpos hderiv hnorm hunb
  rw [div_le_iff₀ hI]
  linarith

/-! ## Sharpness: a two-response population attaining the bound -/

/-- A two-response population code: response `true` has probability `1/2 + θ`. -/
noncomputable def bernoulliCode : ℝ → Bool → ℝ := fun t b => if b then 1 / 2 + t else 1 / 2 - t

/-- Its stimulus derivative. -/
def bernoulliDeriv : Bool → ℝ := fun b => if b then 1 else -1

/-- The natural unbiased decoder. -/
noncomputable def bernoulliDecoder : Bool → ℝ := fun b => if b then 1 / 2 else -1 / 2

theorem bernoulli_hasDerivAt (b : Bool) :
    HasDerivAt (fun t => bernoulliCode t b) (bernoulliDeriv b) 0 := by
  cases b
  · simpa [bernoulliCode, bernoulliDeriv] using
      ((hasDerivAt_id (0 : ℝ)).const_sub (1 / 2 : ℝ))
  · simpa [bernoulliCode, bernoulliDeriv] using
      ((hasDerivAt_id (0 : ℝ)).const_add (1 / 2 : ℝ))

theorem bernoulli_normalized (t : ℝ) : ∑ b : Bool, bernoulliCode t b = 1 := by
  simp [bernoulliCode]
  ring

theorem bernoulli_unbiased (t : ℝ) :
    ∑ b : Bool, bernoulliDecoder b * bernoulliCode t b = t := by
  simp [bernoulliCode, bernoulliDecoder]
  ring

/-- **The Cramér–Rao bound is sharp.**  For the two-response population the
Fisher information is `4`, the natural decoder is unbiased with variance
`1/4`, and their product is exactly `1`. -/
theorem bernoulli_cramer_rao_sharp :
    fisherInfo (bernoulliCode 0) bernoulliDeriv = 4 ∧
    estVariance (bernoulliCode 0) bernoulliDecoder 0 = 1 / 4 ∧
    estVariance (bernoulliCode 0) bernoulliDecoder 0 *
      fisherInfo (bernoulliCode 0) bernoulliDeriv = 1 := by
  have hI : fisherInfo (bernoulliCode 0) bernoulliDeriv = 4 := by
    simp [fisherInfo, bernoulliCode, bernoulliDeriv]
    norm_num
  have hV : estVariance (bernoulliCode 0) bernoulliDecoder 0 = 1 / 4 := by
    simp [estVariance, bernoulliCode, bernoulliDecoder]
    norm_num
  exact ⟨hI, hV, by rw [hI, hV]; norm_num⟩

/-- The two-response population satisfies the hypotheses of `cramer_rao`, so the
theorem is not vacuous. -/
theorem bernoulli_satisfies_cramer_rao :
    1 ≤ estVariance (bernoulliCode 0) bernoulliDecoder 0 *
      fisherInfo (bernoulliCode 0) bernoulliDeriv :=
  cramer_rao (p := bernoulliCode) (p' := bernoulliDeriv) (T := bernoulliDecoder) (θ := 0)
    (fun b => by cases b <;> norm_num [bernoulliCode])
    bernoulli_hasDerivAt
    (Filter.Eventually.of_forall bernoulli_normalized)
    (Filter.Eventually.of_forall bernoulli_unbiased)

end Catalog.Probability.NeuralCoding.Fisher