import Logic.GawronMiskaUlasBase

/-!
# The exponent `m = 1` is bounded: necessity of `m ≥ 2`

The Gawron–Miska–Ulas conjecture is about `m ≥ 2`.  This file proves the sharp
*contrast*: for the exponent `m = 1` the sequence `T_{b,1}` is **bounded**, in fact
`|T_{b,1}(n)| ≤ 1` for every base `b ≥ 2` and every `n`.  Thus the hypothesis
`m ≥ 2` in the unboundedness theorem of `GawronMiskaUlasBase.lean` is genuinely
load-bearing — not an artifact of the proof.

The mechanism is a two-term Mahler recurrence coming from the functional equation
`Tpoly b 1 n = (1 - X) · expand b (Tpoly b 1 (n-1))`, namely

`T_{b,1}(n) = [b ∣ n]·T_{b,1}(n/b) − [b ∣ n-1]·T_{b,1}((n-1)/b)`,

in which at most one bracket is nonzero (because `b ∤ 1`).  A strong induction then
pins `|T_{b,1}(n)| ≤ 1`.

-- !-- Lab Notes — Cycle 2 (necessity of m ≥ 2) -- !--
-- !-- Hypothesis (Hypothesizer): for m = 1 the product ∏(1 - x^{bⁱ}) records the
--     base-b restricted-digit (digits 0/1) representation, which is *unique*; hence
--     each coefficient is a single ±1 or 0, so the sequence is bounded by 1. -- !--
-- !-- Experiment (Experimenter): confirmed |T_{b,1}(n)| ∈ {0,1} numerically for
--     b = 2..7, n ≤ 300. Formalized via the two-term Mahler recurrence + strong
--     induction rather than the digit argument (cleaner in Lean). -- !--
-- !-- Analysis (Analyst): the recurrence has exactly one active branch per n because
--     b ∣ n and b ∣ (n-1) are mutually exclusive (their difference is 1 < b). The
--     m ≥ 2 case escapes this because (1-x)^m then has interior coefficients that do
--     not cancel, allowing |T| to double along repunits (see the base file). -- !--
-- !-- Critique (Critic): T_one_recurrence and T_one_bounded are 0-sorry, use the
--     functional equation (not native_decide), and the boundedness directly certifies
--     that the m=2 unboundedness theorem is non-vacuous. -- !--
-/

namespace GawronMiskaUlas

open Polynomial Finset

/-
**Two-term Mahler recurrence** for the exponent `m = 1` (`n ≥ 1`):
`T_{b,1}(n) = [b ∣ n]·T_{b,1}(n/b) − [b ∣ n-1]·T_{b,1}((n-1)/b)`.
-/
lemma T_one_recurrence (b n : ℕ) (hb : 2 ≤ b) (hn : 1 ≤ n) :
    T b 1 n
      = (if b ∣ n then T b 1 (n / b) else 0)
          - (if b ∣ (n - 1) then T b 1 ((n - 1) / b) else 0) := by
  rw [ T, T ];
  rw [ show Tpoly b 1 n = ( 1 - X ) * ( Polynomial.expand ℤ b ) ( Tpoly b 1 ( n - 1 ) ) from ?_ ];
  · rcases n <;> simp_all +decide [ sub_mul ];
    rw [ Polynomial.coeff_expand, Polynomial.coeff_expand ];
    · congr! 2;
      · apply GawronMiskaUlas.coeff_eq_of_le;
        · lia;
        · exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by nlinarith );
      · apply GawronMiskaUlas.coeff_eq_of_le;
        · grobner;
        · exact Nat.div_le_self _ _;
    · linarith;
    · linarith;
  · convert factor_succ b 1 ( n - 1 ) using 1 ; cases n <;> trivial;
    norm_num

/-
**Boundedness for `m = 1`**: `|T_{b,1}(n)| ≤ 1` for every base `b ≥ 2`.
This shows the hypothesis `m ≥ 2` in `T_two_unbounded` is necessary.
-/
theorem T_one_bounded (b : ℕ) (hb : 2 ≤ b) (n : ℕ) : |T b 1 n| ≤ 1 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ T_one_recurrence ];
  · unfold T;
    unfold Tpoly; norm_num [ Polynomial.coeff_zero_eq_eval_zero ] ;
  · split_ifs <;> simp_all +decide [ abs_le ];
  · split_ifs <;> simp_all +decide [ abs_le ];
    · have := Nat.dvd_sub ‹b ∣ n + 1 + 1› ‹b ∣ n + 1›; aesop;
    · exact ih _ ( Nat.div_le_of_le_mul <| by nlinarith );
    · exact ih _ ( Nat.div_le_of_le_mul <| by nlinarith )

end GawronMiskaUlas