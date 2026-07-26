import Mathlib

/-!
# Digit Sum Formula for Prime Reciprocals with Half-Order Periods

For a prime `p ≥ 3` and an integer `b ≥ 2` with `p ∤ b`, if the multiplicative
order of `b` modulo `p` is `l = (p-1)/2^m` and `p ≡ 1 [MOD 2^(m+1)]`, then the sum
of the base-`b` digits in one full period of the expansion of `1/p` equals
`(b-1)(p-1)/2^(m+1)`.

The repeating block of digits of `1/p` in base `b` is exactly the base-`b`
representation of `N = (b^l - 1)/p` (padded with leading zeros to length `l`).
Leading zeros do not affect the digit sum, so we work with `(Nat.digits b N).sum`.

The core is a generalized **Midy's theorem**: the hypotheses force
`b^(l/2) ≡ -1 [MOD p]`, hence `N = k·(b^h - 1)` with `h = l/2` and
`k = (b^h+1)/p`, which splits the period into two "nines-complement" halves.

-- !-- Lab Notes -- !--
Hypothesis: digit sum of the repeating block of 1/p equals (b-1)(p-1)/2^(m+1).
Experiment: verified numerically (b=10,p=13 → 27 ; b=10,p=7 → 27), then proved.
Analysis: the condition `p ≡ 1 [MOD 2^(m+1)]` with `l = (p-1)/2^m` is exactly the
statement that the period length `l` is even; combined with `l` being the order,
`b^(l/2)` is a square root of `1` different from `1`, hence `-1`. This is the
engine behind Midy's theorem. The digit-sum evaluation reduces to a clean
nines-complement induction on the number of digits.
Critique: leading zeros are handled automatically (they contribute 0 to the sum);
the bounds `1 ≤ k ≤ b^h - 1` require `p ≥ 3`, which is in the hypotheses.
Synthesis: three reusable digit-sum lemmas plus the order-theoretic bridge.
-/

namespace HalfPeriodDigitSum

open Nat

/-- Base-`b` digit sum. -/
def dsum (b n : ℕ) : ℕ := (Nat.digits b n).sum

/-
One-step recurrence for the digit sum.
-/
lemma dsum_step (b n : ℕ) (hb : 2 ≤ b) : dsum b n = n % b + dsum b (n / b) := by
  rcases eq_or_ne n 0 with rfl | hn <;> simp_all +decide [ dsum ];
  cases n <;> simp_all +decide

/-
Digit sum is "block additive": placing `A` above a low block `B < b^h`
just concatenates the digit lists.
-/
lemma dsum_mul_pow_add (b h A B : ℕ) (hb : 2 ≤ b) (hB : B < b ^ h) :
    dsum b (A * b ^ h + B) = dsum b A + dsum b B := by
  induction' h with h ih generalizing A B <;> simp_all +decide [ pow_succ' ];
  · unfold dsum; aesop;
  · rw [ ← mul_left_comm, dsum_step ];
    · norm_num [ Nat.add_mod, Nat.add_div, Nat.mul_mod, Nat.mul_div_assoc, hb ];
      rw [ show ( b * ( A * b ^ h ) + B ) / b = A * b ^ h + B / b by exact Nat.le_antisymm ( Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_add_mod B b, Nat.mod_lt B ( by linarith : 0 < b ) ] ) ( Nat.le_div_iff_mul_le ( by linarith ) |>.2 <| by nlinarith [ Nat.div_mul_le_self B b ] ) ];
      rw [ ih A ( B / b ) ( Nat.div_lt_of_lt_mul <| by linarith ) ];
      rw [ show dsum b B = B % b + dsum b ( B / b ) from dsum_step b B hb ] ; ring;
    · grind

/-
Nines-complement identity: for `c < b^h`, the digit sums of `c` and its
complement `b^h - 1 - c` add up to `(b-1)·h`.
-/
lemma dsum_complement (b h : ℕ) (hb : 2 ≤ b) :
    ∀ c < b ^ h, dsum b (b ^ h - 1 - c) + dsum b c = (b - 1) * h := by
  induction' h with h ih;
  · unfold dsum; aesop;
  · intro c hc;
    -- Let `d = b^(h+1) - 1 - c`. Compute the low digits: `c % b` and `d % b = (b-1) - (c % b)` (valid since `c % b ≤ b-1`), and quotients `c / b` and `d / b = b^h - 1 - c / b`.
    set d := b^(h+1) - 1 - c with hd
    have hd_mod : d % b = (b - 1) - (c % b) := by
      have hd_mod : d % b = (b - 1 - c % b) % b := by
        zify [ hd ];
        rw [ Nat.cast_sub, Nat.cast_sub ] <;> norm_num [ pow_succ' ];
        · rw [ Nat.cast_sub <| Nat.le_sub_of_add_le <| by nlinarith [ Nat.mod_lt c <| show 0 < b by linarith, pow_pos ( zero_lt_two.trans_le hb ) h ] ] ; simp +decide [ ← ZMod.intCast_eq_intCast_iff', Nat.cast_sub <| show 1 ≤ b by linarith ];
        · exact Nat.mul_pos ( by linarith ) ( pow_pos ( by linarith ) _ );
        · exact Nat.le_sub_one_of_lt ( by rw [ pow_succ' ] at hc; linarith );
      exact hd_mod.trans ( Nat.mod_eq_of_lt ( Nat.lt_of_le_of_lt ( Nat.sub_le _ _ ) ( Nat.pred_lt ( ne_bot_of_gt hb ) ) ) )
    have hd_div : d / b = b^h - 1 - (c / b) := by
      zify;
      rw [ Nat.cast_sub, Nat.cast_sub ] <;> norm_num [ pow_succ' ] at *;
      · rw [ Nat.cast_sub, Nat.cast_sub ] <;> norm_num;
        · exact Int.le_antisymm ( Int.le_of_lt_add_one <| Int.ediv_lt_of_lt_mul ( by positivity ) <| by linarith [ Int.mul_ediv_add_emod c b, Int.emod_nonneg c ( by positivity : ( b : ℤ ) ≠ 0 ), Int.emod_lt_of_pos c ( by positivity : ( b : ℤ ) > 0 ) ] ) ( Int.le_ediv_of_mul_le ( by positivity ) <| by linarith [ Int.mul_ediv_add_emod c b, Int.emod_nonneg c ( by positivity : ( b : ℤ ) ≠ 0 ), Int.emod_lt_of_pos c ( by positivity : ( b : ℤ ) > 0 ) ] );
        · exact Nat.one_le_pow _ _ ( by linarith );
        · exact Nat.le_sub_one_of_lt ( Nat.div_lt_of_lt_mul <| by linarith );
      · grind;
      · exact Nat.le_sub_one_of_lt hc;
    convert congr_arg₂ ( · + · ) ( ih ( c / b ) ( Nat.div_lt_of_lt_mul <| by rw [ pow_succ' ] at hc; linarith ) ) ( show c % b + ( b - 1 - c % b ) = b - 1 from Nat.add_sub_of_le <| Nat.le_sub_one_of_lt <| Nat.mod_lt _ <| by linarith ) using 1;
    rw [ dsum_step b d ( by linarith ), dsum_step b c ( by linarith ), hd_mod, hd_div ] ; ring

/-
Midy core: if `N = k·(b^h - 1)` with `1 ≤ k ≤ b^h - 1`, then the base-`b`
digit sum of `N` is `(b-1)·h`.
-/
lemma dsum_midy (b h k : ℕ) (hb : 2 ≤ b) (hk1 : 1 ≤ k) (hk2 : k ≤ b ^ h - 1) :
    dsum b (k * (b ^ h - 1)) = (b - 1) * h := by
  -- Set $N = k * (b^h - 1)$ and note that $N = (k-1) * b^h + (b^h - k)$.
  set N : ℕ := k * (b ^ h - 1)
  have hN : N = (k - 1) * b ^ h + (b ^ h - k) := by
    zify [ N ];
    grind;
  rw [ hN, dsum_mul_pow_add ];
  · convert dsum_complement b h hb ( k - 1 ) _ using 1;
    · rw [ add_comm, tsub_tsub, add_tsub_cancel_of_le hk1 ];
    · omega;
  · linarith;
  · exact Nat.sub_lt ( by positivity ) hk1

/-
**Main theorem.** For a prime `p ≥ 3`, `b ≥ 2` with `p ∤ b`, if the
multiplicative order of `b` mod `p` is `(p-1)/2^m` and `p ≡ 1 [MOD 2^(m+1)]`,
then the sum of the base-`b` digits in one period of `1/p` equals
`(b-1)(p-1)/2^(m+1)`.

The hypothesis `p ∤ b` (bound as `_hpb`) is kept because it is part of the
natural statement, but the proof does not need it: the order hypothesis `hord`
already pins down all the arithmetic that is used.
-/
theorem digitSum_half_period
    (p b m : ℕ) (hp : p.Prime) (hp3 : 3 ≤ p) (hb : 2 ≤ b) (_hpb : ¬ p ∣ b)
    (hord : orderOf ((b : ZMod p)) = (p - 1) / 2 ^ m)
    (hmod : p ≡ 1 [MOD 2 ^ (m + 1)]) :
    dsum b ((b ^ ((p - 1) / 2 ^ m) - 1) / p) = (b - 1) * (p - 1) / 2 ^ (m + 1) := by
  -- Let `l := (p-1)/2^m`. Since `p ≡ 1 [MOD 2^(m+1)]`, `l` is even. Write `l` as `2*h` with `h := (p-1)/2^(m+1)`. Note `h ≥ 1`.
  set l := (p - 1) / 2 ^ m
  set h := (p - 1) / 2 ^ (m + 1) with hh
  have hl_even : l = 2 * h := by
    have h_div : 2 ^ (m + 1) ∣ (p - 1) := by
      simpa [ ← Int.natCast_dvd_natCast, hp.pos ] using hmod.symm.dvd
    have hl : l = 2 * h := by
      exact Nat.div_eq_of_eq_mul_left ( pow_pos ( by decide ) _ ) ( by rw [ Nat.pow_succ' ] at *; nlinarith [ Nat.div_mul_cancel h_div, pow_pos ( by decide : 0 < 2 ) m ] )
    exact hl
  have hh_pos : 1 ≤ h := by
    exact Nat.div_pos ( Nat.le_of_dvd ( Nat.sub_pos_of_lt hp.one_lt ) ( by simpa [ ← Int.natCast_dvd_natCast, Nat.cast_sub hp.pos ] using hmod.symm.dvd ) ) ( by positivity );
  -- Step D: Prove `p ∣ b^h + 1`.
  have h_div : p ∣ b ^ h + 1 := by
    haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
    have h_exp : (b : ZMod p) ^ (2 * h) = 1 := by
      rw [ ← hord, pow_orderOf_eq_one ];
    have h_exp : (b : ZMod p) ^ h ≠ 1 := by
      intro H; have := orderOf_dvd_iff_pow_eq_one.mpr H; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
      rw [ Nat.mod_eq_of_lt ] at this <;> linarith;
    exact mul_left_cancel₀ ( sub_ne_zero_of_ne h_exp ) ( by linear_combination' ‹ ( b : ZMod p ) ^ ( 2 * h ) = 1 › );
  -- Step F: Prove bounds on `k := (b^h + 1)/p`.
  obtain ⟨k, hk⟩ : ∃ k, b ^ h + 1 = p * k := h_div
  have hk_bounds : 1 ≤ k ∧ k ≤ b ^ h - 1 := by
    exact ⟨ by nlinarith [ pow_pos ( zero_lt_two.trans_le hb ) h ], Nat.le_sub_one_of_lt <| by nlinarith [ pow_le_pow_right₀ ( by linarith : 1 ≤ b ) hh_pos ] ⟩;
  -- Step G: Prove the main theorem.
  have h_main : (b ^ l - 1) / p = k * (b ^ h - 1) := by
    rw [ Nat.div_eq_of_eq_mul_left hp.pos ];
    rw [ hl_even, pow_mul' ];
    exact Nat.sub_eq_of_eq_add <| by nlinarith only [ Nat.sub_add_cancel <| Nat.one_le_pow h b <| by linarith, hk ] ;
  rw [ h_main, dsum_midy b h k hb hk_bounds.1 hk_bounds.2 ];
  rw [ Nat.mul_div_assoc _ ( show 2 ^ ( m + 1 ) ∣ p - 1 from by rw [ ← Int.natCast_dvd_natCast ] ; simpa [ hp.pos ] using hmod.symm.dvd ) ]

end HalfPeriodDigitSum