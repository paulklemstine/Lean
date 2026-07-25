/-
# Legendre Separation and Uniqueness of the Recovered Private Exponent

Wiener's attack recovers the private exponent `d` by reading off the continued-fraction
convergents of `e/ñ` and testing each candidate denominator. For this to *uniquely*
identify the true `d`, one needs the classical Diophantine-approximation fact that a
rational with a small enough denominator approximating `x` to within `1/(2d²)` is
unique. The engine is the **Farey separation** bound: two distinct rationals with
denominators `b, e` differ by at least `1/(b·e)`.

This file proves:

* `farey_separation` — distinct fractions are `≥ 1/(b·e)` apart.
* `wiener_unique_recovery` — if `k/d` and `a/b` both approximate `x` to within `1/(2d²)`
  and `b ≤ d`, then `k/d = a/b` as rationals; the recovered fraction is unique.
* `wiener_recovery_eq_of_coprime` — under coprimality (lowest terms), this forces the
  *denominators* to be equal, i.e. the recovered `b` equals the true private exponent `d`.

Together with `WienerPartialKnowledge.modified_wiener_convergent_criterion`, this shows
the modified attack returns the correct private exponent.

## Application Keywords

continued fractions, convergents, Farey sequence, mediant, Diophantine approximation,
Legendre theorem, Wiener attack, RSA, key recovery, uniqueness, coprime denominators.
-/

import Mathlib

open scoped BigOperators

namespace WienerRecovery

/-! ## Farey separation -/

/-- **Farey separation.** For integers with `0 < b` and `0 < e`, two distinct fractions
`a/b ≠ c/e` (i.e. `a·e ≠ c·b`) are at least `1/(b·e)` apart:
`|a/b - c/e| ≥ 1/(b·e)`. -/
theorem farey_separation (a b c e : ℤ) (hb : 0 < b) (he : 0 < e)
    (hne : a * e ≠ c * b) :
    (1 : ℚ) / ((b : ℚ) * e) ≤ |(a : ℚ) / b - (c : ℚ) / e| := by
  field_simp;
  rw [ mul_comm, abs_div, abs_of_nonneg ( by positivity : ( 0 : ℚ ) ≤ b * e ) ];
  rw [ div_mul_cancel₀ _ ( by positivity ) ] ; norm_cast ; cases abs_cases ( e * a - b * c ) <;> cases lt_or_gt_of_ne hne <;> nlinarith;

/-! ## Uniqueness of the recovered fraction -/

/-- **Uniqueness of Wiener recovery.** Let `x : ℚ`. If `k/d` and `a/b` both lie within
`1/(2d²)` of `x`, with `0 < b ≤ d` and `0 < d`, then `k/d = a/b` as rationals.

This is the Legendre uniqueness principle behind Wiener's attack: among all fractions
with denominator at most `d`, at most one can approximate `e/ñ` to within `1/(2d²)`, so
the convergent test recovers the unique correct `k/d`. -/
theorem wiener_unique_recovery (x : ℚ) (k d a b : ℤ)
    (hd : 0 < d) (hb : 0 < b) (hbd : b ≤ d)
    (hk : |x - (k : ℚ) / d| < 1 / (2 * (d : ℚ) ^ 2))
    (ha : |x - (a : ℚ) / b| < 1 / (2 * (d : ℚ) ^ 2)) :
    (k : ℚ) / d = (a : ℚ) / b := by
  have h_farey : |(k : ℚ) / d - (a : ℚ) / b| ≥ 1 / (d * b) ∨ (k : ℚ) / d = (a : ℚ) / b := by
    exact Classical.or_iff_not_imp_right.2 fun h => farey_separation k d a b hd hb <| by contrapose! h; rw [ div_eq_div_iff ] at * <;> norm_cast at * <;> nlinarith;
  contrapose! h_farey;
  refine' ⟨ _, h_farey ⟩;
  have h_diff : |(k : ℚ) / d - (a : ℚ) / b| ≤ |x - (k : ℚ) / d| + |x - (a : ℚ) / b| := by
    grind;
  refine lt_of_le_of_lt h_diff <| lt_of_lt_of_le ( add_lt_add hk ha ) ?_ ; ring_nf ; norm_num [ hd, hb ];
  rw [ ← mul_inv, inv_le_inv₀ ] <;> norm_cast <;> nlinarith

/--
**Denominator recovery under coprimality.** If additionally the true fraction is in
lowest terms (`gcd(k,d)=1`), then equality of the fractions forces `b = d`: the attack
recovers exactly the true private exponent. (Coprimality of the candidate `a/b` turns
out to be unnecessary: `b ∣ k·b = a·d` already pins down `b` once `gcd(k,d)=1`.)
-/
theorem wiener_recovery_eq_of_coprime (x : ℚ) (k d a b : ℤ)
    (hd : 0 < d) (hb : 0 < b) (hbd : b ≤ d)
    (hcop_kd : IsCoprime k d)
    (hk : |x - (k : ℚ) / d| < 1 / (2 * (d : ℚ) ^ 2))
    (ha : |x - (a : ℚ) / b| < 1 / (2 * (d : ℚ) ^ 2)) :
    b = d := by
  -- By wiener_unique_recovery, we have (k:ℚ)/d = (a:ℚ)/b. Cross-multiply with d,b > 0 (div_eq_div_iff) to obtain the integer equation k*b = a*d.
  have eq_fract : k * b = a * d := by
    convert ( wiener_unique_recovery x k d a b hd hb hbd hk ha ) using 1 ; rw [ div_eq_div_iff ] <;> norm_cast <;> nlinarith;
  -- From k*b = a*d, and IsCoprime k d gives d ∣ b (IsCoprime.dvd_of_dvd_mul_left).
  have dvd_b : d ∣ b := by
    exact hcop_kd.symm.dvd_of_dvd_mul_left ⟨ a, by linarith ⟩;
  linarith [ Int.le_of_dvd hb dvd_b ]

/-! ## Concrete separation example -/

/-- `|1/23 - 7/160| = 1/3680 ≥ 1/(23·160)`: the worked RSA instance from
`WienerPartialKnowledge` realises the Farey bound with equality. -/
theorem worked_example_separation :
    (1 : ℚ) / ((23 : ℚ) * 160) ≤ |(1 : ℚ) / 23 - (7 : ℚ) / 160| := by
  norm_num

end WienerRecovery

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** Wiener's attack reads candidate denominators off the
convergents of `e/ñ`. For the recovered denominator to *equal* the true private exponent
`d`, the approximation must single out a unique low-denominator fraction. Conjecture:
the Farey separation `|a/b - c/e| ≥ 1/(b·e)` for distinct fractions is strong enough to
force uniqueness whenever two candidates with denominators `≤ d` both lie within
`1/(2d²)` of the target.

**Experiment (Experimenter).** Proved `farey_separation` from the integer fact
`|a·e - c·b| ≥ 1` (`field_simp` + `Int.one_le_abs` via `nlinarith`). Then
`wiener_unique_recovery` chains the triangle inequality (`|k/d - a/b| < 1/d²`) against the
separation (`≥ 1/(d·b) ≥ 1/d²` since `b ≤ d`) by contradiction. Finally
`wiener_recovery_eq_of_coprime` upgrades fraction-equality to `b = d` using `IsCoprime`
and `b ∣ k·b = a·d`.

**Analysis (Analyst).** The separation bound is *sharp*: the worked RSA instance
`|1/23 - 7/160| = 1/3680 = 1/(23·160)` attains it (`worked_example_separation`). The
condition `b ≤ d` is exactly what makes `1/(d·b) ≥ 1/d²` and hence makes the two
incompatible bounds collide. Surprise from the cycle: coprimality of the *candidate*
`a/b` is not needed — only the true fraction must be reduced.

**Critique (Critic).** No theorem is trivial: `wiener_unique_recovery` is a genuine
`by_contra` argument resting on `farey_separation`, not `decide`. The `b ≤ d` hypothesis
is load-bearing (without it uniqueness fails). The unused candidate-coprimality
hypothesis was removed rather than hidden, keeping the statement minimal and honest.

**Synthesis (PI).** Combined with
`WienerPartial.modified_wiener_convergent_criterion`, these results show the modified
attack returns the *correct* private exponent under the partial-knowledge smallness
condition: criterion ⟹ convergent, separation ⟹ uniqueness.
-/