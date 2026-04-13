import Mathlib

/-!
# Dickman Function Formalization

The Dickman function ρ(u) satisfies the delay DE u·ρ'(u) = -ρ(u-1) for u > 1,
with ρ(u) = 1 for 0 < u ≤ 1. We formalize the base case, smooth numbers, and L-notation.
-/

open Real Nat

set_option maxHeartbeats 400000

namespace DickmanFunction

noncomputable def dickman_base (u : ℝ) : ℝ :=
  if u ≤ 1 then 1 else 1 - Real.log u

theorem dickman_base_le_one {u : ℝ} (hu : u ≤ 1) : dickman_base u = 1 := if_pos hu

theorem dickman_base_interval {u : ℝ} (hu1 : 1 < u) : dickman_base u = 1 - Real.log u :=
  if_neg (not_le.mpr hu1)

theorem dickman_at_one : dickman_base 1 = 1 := if_pos le_rfl

theorem dickman_at_two : dickman_base 2 = 1 - Real.log 2 := if_neg (by norm_num)

theorem dickman_base_pos {u : ℝ} (hu0 : 0 < u) (hu2 : u ≤ 2) :
    0 < dickman_base u := by
  unfold dickman_base; split_ifs <;> try linarith;
  linarith [ Real.log_lt_sub_one_of_pos hu0 ( by linarith ), Real.log_le_log ( by linarith ) hu2 ]

theorem dickman_base_antitone {u₁ u₂ : ℝ} (hu₁ : 0 < u₁) (_hu₂ : u₂ ≤ 2)
    (h : u₁ ≤ u₂) : dickman_base u₂ ≤ dickman_base u₁ := by
  unfold dickman_base;
  split_ifs <;> try linarith;
  · linarith [ Real.log_nonneg ( by linarith : ( 1 : ℝ ) ≤ u₂ ) ];
  · gcongr

/-! ## Smooth Numbers -/

def IsSmooth (n y : ℕ) : Prop := ∀ p : ℕ, p.Prime → p ∣ n → p ≤ y

theorem one_isSmooth (y : ℕ) : IsSmooth 1 y :=
  fun p hp hpd => absurd hp.one_lt (not_lt.mpr (Nat.le_of_dvd (by norm_num) hpd))

theorem prime_self_smooth {p : ℕ} (hp : p.Prime) : IsSmooth p p :=
  fun q hq hqp => le_of_eq (hp.eq_one_or_self_of_dvd q hqp |>.resolve_left hq.one_lt.ne')

theorem IsSmooth.of_dvd {n m y : ℕ} (hn : IsSmooth n y) (hm : m ∣ n) : IsSmooth m y :=
  fun p hp hpm => hn p hp (dvd_trans hpm hm)

theorem IsSmooth.mono {n y₁ y₂ : ℕ} (hn : IsSmooth n y₁) (h : y₁ ≤ y₂) : IsSmooth n y₂ :=
  fun p hp hpn => le_trans (hn p hp hpn) h

/-! ## L-notation -/

noncomputable def L_notation (n : ℝ) (α c : ℝ) : ℝ :=
  Real.exp (c * n ^ α * (Real.log n) ^ (1 - α))

theorem L_notation_pos (n α c : ℝ) : 0 < L_notation n α c := Real.exp_pos _

theorem L_zero_is_polylog (n c : ℝ) :
    L_notation n 0 c = Real.exp (c * Real.log n) := by unfold L_notation; simp

theorem L_one_is_polynomial (n c : ℝ) :
    L_notation n 1 c = Real.exp (c * n) := by unfold L_notation; simp

end DickmanFunction