import Pythagorean.JacobiSignedTwoAdicSemiprime

/-!
# The exact Weil deficiency, and a sharp improvement of the Weil floor

This file addresses conjecture **C4** of the JACSIGN future-directions list.  The conjecture
asks about primes at which the Weil floor `W(p)² ≤ 4p` is nearly attained.  We show that the
*deficiency* is not merely bounded but given by an exact formula:

`4p - W(p)² = 4b²`,   where `p = a² + b²`, `2a = W p`, `a` odd, `b` even.

Consequences.

* `JacSign.weil_deficiency` : the identity itself.
* `JacSign.weil_near_attainment_iff` : near-attainment at level `ε = u/v` is *equivalent* to the
  Diophantine condition `v b² < u p` on the even Gaussian leg — this is the analytic-to-
  Diophantine conversion asked for in C4, now a theorem rather than a heuristic.
* `JacSign.W_sq_le_four_p_sub_sixteen` : **a strict improvement of the Weil floor.**  For every
  prime `p ≡ 1 (mod 4)`, `W(p)² ≤ 4p - 16`.  (The even leg is a nonzero even integer, so the
  deficiency is at least `16`.)
* `JacSign.improved_floor_sharp` : the improved bound is *sharp*: it is an equality at
  `p = 13` and at `p = 173`, the near-attainment example of the catalog.  In particular no bound
  `W(p)² ≤ 4p - c` with `c > 16` can hold.
* `JacSign.attainment_ratio_173` : the `97.7 %` attainment of `p = 173` is explained exactly:
  `173 = 13² + 2²` and `4·173 - 26² = 4·2²`.
-/

open Finset

namespace JacSign

variable (p : ℕ) [Fact p.Prime]

/-- **The exact Weil deficiency.**  For `p ≡ 1 (mod 4)` write `p = a² + b²` with `2a = W p`
(`two_squares_odd_leg`).  Then the gap in the Weil bound is exactly `4b²`, four times the square
of the even Gaussian leg. -/
theorem weil_deficiency (h1 : p % 4 = 1) :
    ∃ a b : ℤ, 2 * a = W p ∧ ¬ (2 : ℤ) ∣ a ∧ (2 : ℤ) ∣ b ∧ (p : ℤ) = a ^ 2 + b ^ 2 ∧
      4 * (p : ℤ) - (W p) ^ 2 = 4 * b ^ 2 := by
  obtain ⟨a, b, hab, haW, hao⟩ := two_squares_odd_leg p (ne_two_of_one_mod_four h1) h1
  refine ⟨a, b, haW, hao, even_companion_leg (p := p) h1 hab hao, hab, ?_⟩
  rw [← haW, hab]
  ring

/-- The second Gaussian leg of a prime is nonzero: a prime is never a perfect square. -/
theorem even_leg_ne_zero {a b : ℤ} (hab : (p : ℤ) = a ^ 2 + b ^ 2) : b ≠ 0 := by
  have hprime := (Fact.out : p.Prime)
  rintro rfl
  have hp : (p : ℤ) = a ^ 2 := by rw [hab]; ring
  have hnat : p = a.natAbs ^ 2 := by
    have : ((p : ℤ)).natAbs = (a ^ 2).natAbs := by rw [hp]
    simpa [Int.natAbs_pow] using this
  have hdvd : a.natAbs ∣ p := ⟨a.natAbs, by rw [hnat]; ring⟩
  rcases (Nat.Prime.eq_one_or_self_of_dvd hprime _ hdvd) with h | h
  · rw [h] at hnat
    simp at hnat
    have := hprime.one_lt
    omega
  · rw [h] at hnat
    have := hprime.two_le
    nlinarith [hnat]

/-- **A strict improvement of the Weil floor.**  For every prime `p ≡ 1 (mod 4)`,
`W(p)² ≤ 4p - 16`: the deficiency is at least `16`, because the even Gaussian leg is a nonzero
even integer. -/
theorem W_sq_le_four_p_sub_sixteen (h1 : p % 4 = 1) : (W p) ^ 2 ≤ 4 * (p : ℤ) - 16 := by
  obtain ⟨a, b, haW, hao, hbe, hab, hdef⟩ := weil_deficiency p h1
  obtain ⟨c, hc⟩ := hbe
  have hb0 : b ≠ 0 := even_leg_ne_zero p hab
  have hc0 : c ≠ 0 := by rintro rfl; exact hb0 (by omega)
  have hc1 : 1 ≤ c ^ 2 := by
    rcases lt_or_gt_of_ne hc0 with h | h <;> nlinarith
  have hb2 : b ^ 2 = 4 * c ^ 2 := by rw [hc]; ring
  linarith [hdef, hb2, hc1]

/-- Near-attainment of the Weil floor at level `ε = u/v` is *exactly* the Diophantine statement
`v·b² < u·p` about the even Gaussian leg `b` of `p = a² + b²`.  This is the conversion of the
analytic conjecture C4 into a question about primes represented by thin quadratic families. -/
theorem weil_near_attainment_iff {a b : ℤ} (hab : (p : ℤ) = a ^ 2 + b ^ 2)
    (haW : 2 * a = W p) (u v : ℤ) :
    (v - u) * (4 * (p : ℤ)) < v * (W p) ^ 2 ↔ v * b ^ 2 < u * (p : ℤ) := by
  have hW : (W p) ^ 2 = 4 * (p : ℤ) - 4 * b ^ 2 := by rw [← haW, hab]; ring
  rw [hW]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ### The sharpness of the improved floor -/

/-- `173 = 13² + 2²`, and the Jacobi-signed count is twice the odd leg. -/
theorem gaussian_173 : (173 : ℤ) = 13 ^ 2 + 2 ^ 2 ∧ W 173 = 2 * 13 := by
  refine ⟨by norm_num, ?_⟩
  rw [W_173]
  norm_num

/-- The `97.7 %` near-attainment at `p = 173` is exactly the statement that its even Gaussian
leg is `2`: the deficiency is `4·2² = 16`. -/
theorem attainment_ratio_173 : 4 * (173 : ℤ) - (W 173) ^ 2 = 4 * 2 ^ 2 := by
  rw [W_173]; norm_num

/-- **The improved floor is sharp.**  Equality `W(p)² = 4p - 16` holds at `p = 13` and at
`p = 173`; hence no constant `c > 16` works in `W(p)² ≤ 4p - c`. -/
theorem improved_floor_sharp :
    (W 13) ^ 2 = 4 * (13 : ℤ) - 16 ∧ (W 173) ^ 2 = 4 * (173 : ℤ) - 16 := by
  refine ⟨?_, ?_⟩
  · rw [W_13]; norm_num
  · rw [W_173]; norm_num

/-- Consequently the Weil-floor ratio `W(p)²/(4p)` is bounded away from `1` by exactly
`4/p`: the "attainment" of C4 is a statement about how often `p - (odd square)` is as small
as possible. -/
theorem attainment_ratio_bound (h1 : p % 4 = 1) :
    (p : ℤ) * (W p) ^ 2 ≤ (4 * (p : ℤ) - 16) * (p : ℤ) := by
  have h := W_sq_le_four_p_sub_sixteen p h1
  have hp : (0 : ℤ) ≤ (p : ℤ) := Int.natCast_nonneg p
  nlinarith [h, hp]

end JacSign