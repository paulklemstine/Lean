import Catalog.Shared.HalfPeriodDigitSum

/-!
# Generalized Midy's Theorem for Prime Reciprocals

This file distills the `2^m` framing of `HalfPeriodDigitSum.digitSum_half_period`
into its structural core: the only thing the arithmetic hypotheses ever buy us is
that the period length `l = ord_p(b)` is **even**. Whenever that holds, the
base-`b` digit sum of one full period of `1/p` equals `(b-1)·(l/2)`.

-- !-- Lab Notes -- !--
Hypothesis: the `2^m`/`p ≡ 1 [MOD 2^(m+1)]` conditions are a proxy for "the period
is even"; the true theorem needs only evenness of the multiplicative order.
Experiment: re-derived the digit-sum value from `Even l` alone.
Analysis: the square-root argument `b^(l/2) = -1` in the field `ZMod p` is the sole
mechanism; the number-theoretic input is exactly `Even (ord_p b)`. This explains
*why* Midy-style theorems always pair the two halves of a period.
Critique: `l` must be positive; in `ZMod p` (finite, `p` prime) the order of a unit
is automatically positive, so `Even l` gives `l ≥ 2`, hence `l/2 ≥ 1`.
Synthesis: `digitSum_half_period` is recovered as the special case where evenness
comes from `p ≡ 1 [MOD 2^(m+1)]`.
-/

namespace HalfPeriodDigitSum

open Nat

/-
**Generalized Midy's theorem.** For a prime `p ≥ 3`, base `b ≥ 2` with `p ∤ b`,
if the multiplicative order `l` of `b` mod `p` is even, then the base-`b` digit sum
of one full period of `1/p` (the digits of `(b^l - 1)/p`) equals `(b-1)·(l/2)`.
-/
theorem digitSum_midy_even
    (p b l : ℕ) (hp : p.Prime) (hp3 : 3 ≤ p) (hb : 2 ≤ b) (hpb : ¬ p ∣ b)
    (hord : orderOf ((b : ZMod p)) = l) (hl : Even l) :
    dsum b ((b ^ l - 1) / p) = (b - 1) * (l / 2) := by
  -- Let $h := l/2$. Then $l = 2h$.
  obtain ⟨h, rfl⟩ : ∃ h, l = 2 * h := even_iff_two_dvd.mp hl;
  -- From `x^h = -1`, `((b^h + 1 : ℕ) : ZMod p) = 0`, so `p ∣ b^h + 1` by `ZMod.natCast_eq_zero_iff`.
  have h_div : p ∣ b ^ h + 1 := by
    haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
    have := pow_orderOf_eq_one ( b : ZMod p ) ; simp_all +decide [ pow_mul' ] ;
    cases this <;> simp_all +decide;
    have := orderOf_dvd_iff_pow_eq_one.mpr ‹_›; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
    rcases h with ( _ | _ | h ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
    exact False.elim <| hord <| isOfFinOrder_iff_pow_eq_one.mpr ⟨ p - 1, Nat.sub_pos_of_lt hp.one_lt, by rw [ ZMod.pow_card_sub_one_eq_one hpb ] ⟩;
  -- Let `k := (b^h+1)/p`, giving `p*k = b^h+1`.
  obtain ⟨k, hk⟩ : ∃ k, b ^ h + 1 = p * k := h_div
  have hk_bounds : 1 ≤ k ∧ k ≤ b ^ h - 1 := by
    exact ⟨ by nlinarith [ pow_pos ( zero_lt_two.trans_le hb ) h ], Nat.le_sub_one_of_lt <| by nlinarith [ pow_pos ( zero_lt_two.trans_le hb ) h ] ⟩;
  -- Then `b^(2h) - 1` = (b^h-1)*(b^h+1) = p*(k*(b^h-1)), so `(b^(2h)-1)/p = k*(b^h-1)`.
  have h_div : (b ^ (2 * h) - 1) / p = k * (b ^ h - 1) := by
    exact Nat.div_eq_of_eq_mul_left hp.pos ( by zify at *; cases b <;> cases h <;> norm_num [ pow_mul' ] at * ; nlinarith );
  rw [ h_div, dsum_midy b h k hb hk_bounds.1 hk_bounds.2 ] ; norm_num

end HalfPeriodDigitSum