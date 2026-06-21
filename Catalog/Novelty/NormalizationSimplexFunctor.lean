/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The normalization map as a natural transformation into the probability simplex

For a finite index type `ι`, Mathlib's `stdSimplex ℝ ι` is the *probability simplex*
`{p : ι → ℝ | (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1}`.  This file studies the **normalization map**

  `normalize v i = v i / ∑ j, v j`,

which sends a vector to its `ℓ¹`-normalized version, and the **pushforward** of a
finite weight vector along a map of index types

  `pushforward f v k = ∑ i, if f i = k then v i else 0`   (marginalization / image measure).

The two combine into a clean categorical picture, which is the object of study here:

* `pushforward` is a (covariant) functor on weight vectors: it respects identities
  (`pushforward_id`) and composition (`pushforward_comp`), and it preserves total mass
  (`pushforward_mass`), hence restricts to an **endofunctor of the probability simplex**
  (`pushforward_mem_stdSimplex`).
* `normalize` is the **object map** of a retraction of the nonnegative cone onto the
  simplex (`normalize_mem_stdSimplex`), is the identity on the simplex
  (`normalize_id_of_mem`), is idempotent (`normalize_idem`), and is invariant under
  positive (indeed nonzero) rescaling (`normalize_smul`), i.e. it factors through the
  projectivization of the cone.
* The two are compatible: `normalize` is a **natural transformation** from the
  pushforward functor on the cone to the pushforward functor on the simplex
  (`normalize_pushforward`): normalizing then marginalizing equals marginalizing then
  normalizing.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the right ambient object is Mathlib's `stdSimplex ℝ ι`, and the
  "normalization functor into the simplex" is best captured not as a literal `CategoryTheory`
  functor but as the conjunction of (a) functoriality of marginalization `pushforward`
  and (b) naturality of `normalize` with respect to it.  This avoids heavy categorical
  scaffolding while making every functor/naturality law a concrete, checkable equation.

Experiment (Stage 2): `div_zero` in Lean is a feature here.  Because `x / 0 = 0`,
  `normalize` is *totally* defined: on the degenerate vector with `∑ v = 0` it returns the
  zero vector.  We found that idempotence (`normalize_idem`) and naturality
  (`normalize_pushforward`) then hold *unconditionally* — no positivity hypothesis needed —
  since both sides collapse to `0` in the degenerate case.  Only simplex *membership*
  (`normalize_mem_stdSimplex`) needs `0 < ∑ v`, exactly because the constraint `∑ p = 1`
  cannot be met by the zero vector.

Analysis (Stage 3): the workhorse lemmas are `Finset.sum_div` (pull a constant denominator
  out of a sum, giving naturality and the mass-1 computation), `Finset.sum_comm` (swap order
  of summation, giving `pushforward_mass` and `pushforward_comp`), and `Finset.sum_ite_eq'`
  (collapse a one-hot indicator sum, giving `pushforward_id`/`pushforward_comp`).
  The naturality square reduces, after `pushforward_mass`, to the single scalar identity
  `(∑ g)/c = ∑ (g/c)`.

Failure analysis: an early attempt unfolded `normalize` everywhere inside the idempotence
  proof, exposing a triple-quotient `(v i / S) / S / S` and breaking the rewrite; the fix was
  to unfold only one layer via a definitional `have ... := rfl` and rewrite the denominator
  `∑ j, normalize v j = 1`.  A second snag: `pushforward` needs `DecidableEq` on the target
  index type for the `if f i = k` indicator to elaborate.
-/

open scoped BigOperators
open Finset

namespace NormalizationSimplex

variable {ι κ μ : Type*} [Fintype ι] [Fintype κ] [Fintype μ] [DecidableEq κ] [DecidableEq μ]

/-- `ℓ¹`-normalization of a finite weight vector. Total when `∑ v = 0` (returns `0`). -/
noncomputable def normalize (v : ι → ℝ) : ι → ℝ := fun i => v i / ∑ j, v j

/-- Pushforward (marginalization / image measure) of a weight vector along `f : ι → κ`. -/
def pushforward (f : ι → κ) (v : ι → ℝ) : κ → ℝ := fun k => ∑ i, if f i = k then v i else 0

/-! ### Basic properties of `normalize` -/

theorem normalize_sum (v : ι → ℝ) :
    (∑ i, normalize v i) = (∑ i, v i) / (∑ j, v j) := by
  unfold normalize
  rw [← Finset.sum_div]

theorem normalize_nonneg {v : ι → ℝ} (hnn : ∀ i, 0 ≤ v i) (i : ι) :
    0 ≤ normalize v i := by
  unfold normalize
  exact div_nonneg (hnn i) (Finset.sum_nonneg (fun j _ => hnn j))

/-- The normalization of a nonnegative vector of positive total mass lies in the simplex. -/
theorem normalize_mem_stdSimplex {v : ι → ℝ} (hnn : ∀ i, 0 ≤ v i)
    (hpos : 0 < ∑ j, v j) : normalize v ∈ stdSimplex ℝ ι := by
  refine ⟨fun i => normalize_nonneg hnn i, ?_⟩
  rw [normalize_sum]
  exact div_self (ne_of_gt hpos)

/-- `normalize` is the identity on the simplex (it is a retraction). -/
theorem normalize_id_of_mem {p : ι → ℝ} (hp : p ∈ stdSimplex ℝ ι) :
    normalize p = p := by
  funext i
  unfold normalize
  rw [hp.2, div_one]

/-- `normalize` is idempotent (unconditionally, including the degenerate case). -/
theorem normalize_idem (v : ι → ℝ) : normalize (normalize v) = normalize v := by
  by_cases h : (∑ j, v j) = 0
  · have hz : normalize v = fun _ => (0 : ℝ) := by
      funext i; unfold normalize; rw [h, div_zero]
    rw [hz]; funext i; unfold normalize; simp
  · have hsum : (∑ i, normalize v i) = 1 := by
      rw [normalize_sum]; exact div_self h
    funext i
    have e : normalize (normalize v) i = normalize v i / (∑ j, normalize v j) := rfl
    rw [e, hsum, div_one]

/-- `normalize` is invariant under nonzero rescaling: it factors through projectivization. -/
theorem normalize_smul {c : ℝ} (hc : c ≠ 0) (v : ι → ℝ) :
    normalize (fun i => c * v i) = normalize v := by
  funext i
  unfold normalize
  rw [← Finset.mul_sum, mul_div_mul_left _ _ hc]

/-! ### Functoriality of `pushforward` -/

/-- Pushforward preserves total mass. -/
theorem pushforward_mass (f : ι → κ) (v : ι → ℝ) :
    (∑ k, pushforward f v k) = ∑ i, v i := by
  unfold pushforward
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  simp

/-- Functor identity law: pushing forward along `id` does nothing. -/
theorem pushforward_id [DecidableEq ι] (v : ι → ℝ) : pushforward id v = v := by
  funext k
  unfold pushforward
  simp

/-- Functor composition law: pushforward of a composite is the composite of pushforwards. -/
omit [Fintype μ] in
theorem pushforward_comp (f : ι → κ) (g : κ → μ) (v : ι → ℝ) :
    pushforward (g ∘ f) v = pushforward g (pushforward f v) := by
  unfold pushforward
  simp +decide [Finset.sum_ite]
  ext k
  rw [Finset.sum_sigma']
  refine Finset.sum_bij (fun x _ => ⟨f x, x⟩) ?_ ?_ ?_ ?_ <;> aesop

/-- Pushforward of a probability vector is a probability vector: `pushforward f`
restricts to an endofunctor of the simplex. -/
theorem pushforward_mem_stdSimplex (f : ι → κ) {p : ι → ℝ}
    (hp : p ∈ stdSimplex ℝ ι) : pushforward f p ∈ stdSimplex ℝ κ := by
  refine ⟨fun k => ?_, ?_⟩
  · unfold pushforward
    exact Finset.sum_nonneg (fun i _ => by by_cases h : f i = k <;> simp [h, hp.1 i])
  · rw [pushforward_mass]; exact hp.2

/-! ### Naturality: `normalize` is a natural transformation -/

/-- Naturality square: normalizing then marginalizing equals marginalizing then
normalizing. Holds unconditionally. -/
theorem normalize_pushforward (f : ι → κ) (v : ι → ℝ) :
    normalize (pushforward f v) = pushforward f (normalize v) := by
  funext k
  have hmass : (∑ k', pushforward f v k') = ∑ j, v j := pushforward_mass f v
  show (pushforward f v k) / (∑ k', pushforward f v k')
      = ∑ i, if f i = k then v i / (∑ j, v j) else 0
  rw [hmass]
  unfold pushforward
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hk : f i = k <;> simp [hk]

end NormalizationSimplex