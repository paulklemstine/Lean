/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Where the factor `1/2` comes from: `ℓ¹`–`ℓ^∞` duality of the test polytope

`EventSup` proved that the supremum of `p(A) − q(A)` over *events* is `d_TV`.
Here we prove the companion statement for **signed** tests: the supremum of
`∑ₓ (p x − q x) g x` over all `g` with `‖g‖_∞ ≤ 1` is `2 d_TV = ‖p − q‖₁`, and it
is attained at the sign pattern `g = sgn(p − q)`.

Putting the two side by side (`factor_two_dichotomy`) explains the notorious
factor of two *exactly*:

| test class            | attained supremum |
|-----------------------|-------------------|
| `g : X → [0,1]`       | `d_TV(p, q)`      |
| `g : X → [−1,1]`      | `2 d_TV(p, q)`    |

The `[0,1]` polytope is the affine image `g ↦ (1 + g)/2` of the `[−1,1]` one, and
because `∑ₓ (p x − q x) = 0` the affine shift is invisible while the factor `1/2`
survives.  The `ℓ¹` bound is therefore not merely wasteful: it is the *correct*
answer to a different, coarser question.

We also record that the sharp normalization makes `d_TV` a genuine metric
(`tvDist_triangle`, `tvDist_eq_zero_iff` from `EventSup`), with the two rigid
endpoints `0` and `1` bounding its range on the simplex — so the distinguishing
advantage is a distance, not just a divergence.

## Main results

* `signedAdvantage_le`, `exists_signedAdvantage_eq` , `isGreatest_signedAdvantage`
  — the `ℓ^∞`-dual description `‖p − q‖₁ = max_{‖g‖∞ ≤ 1} ⟨p − q, g⟩`;
* `factor_two_dichotomy` — the two suprema in one statement;
* `tvDist_triangle`, `tvDist_self` — `d_TV` is a metric on laws;
* `tvDist_affine_shift` — the invisible affine shift behind the factor two.

## Application keywords

total variation, dual norm, test polytope, linear programming duality, metric
-/

import MachineLearning.TotalVariation.EventSup

open Finset

namespace UniversalRedundancy

variable {X : Type*} [Fintype X]

/-- The advantage of a *signed* test `g : X → [−1, 1]`. -/
def signedAdvantage (p q : X → ℝ) (g : X → ℝ) : ℝ := ∑ x, (p x - q x) * g x

/-- Every signed test with `‖g‖_∞ ≤ 1` has advantage at most `‖p − q‖₁ = 2 d_TV`. -/
theorem signedAdvantage_le (p q : X → ℝ) {g : X → ℝ} (hg : ∀ x, |g x| ≤ 1) :
    signedAdvantage p q g ≤ 2 * tvDist p q := by
  rw [← l1_eq_two_mul_tvDist, signedAdvantage]
  refine Finset.sum_le_sum fun x _ => ?_
  calc (p x - q x) * g x ≤ |(p x - q x) * g x| := le_abs_self _
    _ = |p x - q x| * |g x| := abs_mul _ _
    _ ≤ |p x - q x| * 1 := by
        exact mul_le_mul_of_nonneg_left (hg x) (abs_nonneg _)
    _ = |p x - q x| := mul_one _

/-- The sign pattern of `p − q` attains it. -/
theorem exists_signedAdvantage_eq (p q : X → ℝ) :
    ∃ g : X → ℝ, (∀ x, |g x| ≤ 1) ∧ signedAdvantage p q g = 2 * tvDist p q := by
  classical
  refine ⟨fun x => if q x ≤ p x then 1 else -1, fun x => ?_, ?_⟩
  · by_cases h : q x ≤ p x <;> simp [h]
  · rw [← l1_eq_two_mul_tvDist, signedAdvantage]
    refine Finset.sum_congr rfl fun x _ => ?_
    by_cases h : q x ≤ p x
    · rw [if_pos h, mul_one, abs_of_nonneg (by linarith)]
    · rw [if_neg h, abs_of_nonpos (by linarith [not_le.mp h])]
      ring

/-- **`ℓ^∞`-duality.**  `‖p − q‖₁ = 2 d_TV(p, q)` is the *attained* maximum of the
signed advantage over the unit `ℓ^∞` ball.  No probability hypotheses are needed:
this is a pure norm-duality statement. -/
theorem isGreatest_signedAdvantage (p q : X → ℝ) :
    IsGreatest {r : ℝ | ∃ g : X → ℝ, (∀ x, |g x| ≤ 1) ∧ r = signedAdvantage p q g}
      (2 * tvDist p q) := by
  obtain ⟨g, hg, hval⟩ := exists_signedAdvantage_eq p q
  refine ⟨⟨g, hg, hval.symm⟩, ?_⟩
  rintro r ⟨h, hh, rfl⟩
  exact signedAdvantage_le p q hh

/-- **The factor-two dichotomy.**  Over `[0,1]`-valued tests the attained optimum
is `d_TV`; over `[−1,1]`-valued tests it is `2 d_TV`.  Both are maxima, both are
attained, and they differ by exactly the normalization factor that separates the
sharp characterization from the crude `ℓ¹` bound. -/
theorem factor_two_dichotomy {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    IsGreatest {r : ℝ | ∃ g : X → ℝ, (∀ x, 0 ≤ g x) ∧ (∀ x, g x ≤ 1) ∧
        r = ∑ x, (p x - q x) * g x} (tvDist p q) ∧
      IsGreatest {r : ℝ | ∃ g : X → ℝ, (∀ x, |g x| ≤ 1) ∧ r = signedAdvantage p q g}
        (2 * tvDist p q) := by
  refine ⟨⟨?_, ?_⟩, isGreatest_signedAdvantage p q⟩
  · obtain ⟨g, hg0, hg1, hval⟩ := exists_expectation_diff_eq_osc_mul_tvDist hp hq
    refine ⟨g, hg0, hg1, ?_⟩
    rw [← Finset.sum_sub_distrib] at hval
    rw [sub_zero, one_mul] at hval
    rw [← hval]
    exact Finset.sum_congr rfl fun x _ => by ring
  · rintro r ⟨g, hg0, hg1, rfl⟩
    have := abs_softAdvantage_le_tvDist hp hq hg0 hg1
    exact le_trans (le_abs_self _) this

/-- The affine reparametrisation `g ↦ (1 + g)/2` that carries the signed test
polytope onto the `[0,1]` one halves the advantage — because `p − q` integrates
to zero, the constant part contributes nothing.  This identity *is* the factor
`1/2`. -/
theorem tvDist_affine_shift {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1)
    (g : X → ℝ) :
    ∑ x, (p x - q x) * ((1 + g x) / 2) = signedAdvantage p q g / 2 := by
  have h0 : ∑ x, (p x - q x) = 0 := by
    rw [Finset.sum_sub_distrib, hp, hq]; ring
  have hsplit : ∑ x, (p x - q x) * ((1 + g x) / 2)
      = (∑ x, (p x - q x)) / 2 + (∑ x, (p x - q x) * g x) / 2 := by
    rw [Finset.sum_div, Finset.sum_div, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun x _ => by ring
  rw [hsplit, h0, signedAdvantage]
  ring

/-! ## `d_TV` is a metric -/

@[simp] lemma tvDist_self (p : X → ℝ) : tvDist p p = 0 := by
  unfold tvDist; simp

/-- The triangle inequality: distinguishing advantage is subadditive along
chains of hypotheses (the hybrid argument in its simplest form). -/
theorem tvDist_triangle (p q r : X → ℝ) : tvDist p r ≤ tvDist p q + tvDist q r := by
  have hpt : ∀ x, |p x - r x| ≤ |p x - q x| + |q x - r x| := by
    intro x
    have := abs_add_le (p x - q x) (q x - r x)
    simpa using this
  have := Finset.sum_le_sum fun x (_ : x ∈ univ) => hpt x
  rw [Finset.sum_add_distrib] at this
  unfold tvDist
  linarith [this]

end UniversalRedundancy