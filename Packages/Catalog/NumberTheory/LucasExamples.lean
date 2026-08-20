/-
# Worked instances of the `q`-analogue of Lucas' theorem

These three instances exercise the three distinct regimes of
`QKummer.qBinom_cast_lucas_orderOf`, each time deriving the answer *from the general theorem* and
checking it against the exact value of the Gaussian binomial coefficient.

* `qLucas_two_five_nine_five` : the carry-free regime.  `q = 2`, `ℓ = 5`, `d = ord_5(2) = 4`,
  `9 = 4·2 + 1`, `5 = 4·1 + 1`, so `binom(9,5)_2 ≡ C(2,1) · binom(1,1)_2 = 2 (mod 5)`; indeed
  `binom(9,5)_2 = 3309747 = 5·661949 + 2`.
* `qLucas_two_five_six_three_carry` : the carry regime, at the falsifiable datum of the mission.
  `6 % 4 = 2 < 3 = 3 % 4`, so the residual block coefficient `binom(2,3)_2` vanishes and the
  theorem predicts `5 ∣ binom(6,3)_2 = 1395`, which is correct.
* `qLucas_two_three_thirteen_six` : the *large block index* regime, `N = 6 ≥ ℓ = 3`, which the
  naive unit-cancellation argument cannot reach.  `d = ord_3(2) = 2`, `13 = 2·6 + 1`,
  `6 = 2·3 + 0`, so `binom(13,6)_2 ≡ C(6,3) · binom(1,0)_2 = 20 ≡ 2 (mod 3)`; indeed
  `binom(13,6)_2 = 14877590196755 ≡ 2 (mod 3)`.
-/
import Catalog.NumberTheory.QKummer.Lucas
import Catalog.NumberTheory.QKummer.Examples
import Catalog.NumberTheory.QKummer.RowCount
import Catalog.NumberTheory.QKummer.Sharpness
import Catalog.NumberTheory.QKummer.FullRows

namespace QKummer

open Finset

/-- **Carry-free instance.**  `binom(9,5)_2 ≡ C(2,1) · binom(1,1)_2 = 2 (mod 5)`, matching the
exact value `binom(9,5)_2 = 3309747`. -/
theorem qLucas_two_five_nine_five :
    ((qBinom 2 9 5 : ℕ) : ZMod 5) = 2 ∧ qBinom 2 9 5 = 3309747 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := qBinom_cast_lucas_orderOf (q := 2) (ℓ := 5) (le_refl 2) (by decide)
    (show (5 : ℕ) ≤ 9 by norm_num)
  rw [orderOf_two_zmod_five] at key
  refine ⟨?_, rfl⟩
  rw [key]
  norm_num

/-- **Carry instance** (the falsifiable datum `binom(6,3)_2 = 1395 = 3²·5·31`).  Here
`3 % 4 = 3` exceeds `6 % 4 = 2`, the residual coefficient `binom(2,3)_2` is zero, and the
theorem forces `5 ∣ binom(6,3)_2`. -/
theorem qLucas_two_five_six_three_carry :
    ((qBinom 2 6 3 : ℕ) : ZMod 5) = 0 ∧ (5 : ℕ) ∣ qBinom 2 6 3 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := qBinom_cast_lucas_orderOf (q := 2) (ℓ := 5) (le_refl 2) (by decide)
    (show (3 : ℕ) ≤ 6 by norm_num)
  rw [orderOf_two_zmod_five] at key
  have hzero : ((qBinom 2 6 3 : ℕ) : ZMod 5) = 0 := by
    rw [key]; norm_num [show qBinom 2 2 3 = 0 from rfl]
  exact ⟨hzero, (ZMod.natCast_eq_zero_iff _ 5).mp hzero⟩

/-- **Large block index.**  With `q = 2`, `ℓ = 3`, `d = 2` and `n = 13`, the block index is
`N = 6 ≥ ℓ`, a range in which the naive cancellation of factorials fails; the theorem still
gives `binom(13,6)_2 ≡ C(6,3) = 20 ≡ 2 (mod 3)`. -/
theorem qLucas_two_three_thirteen_six :
    ((qBinom 2 13 6 : ℕ) : ZMod 3) = 2 ∧ qBinom 2 13 6 = 14877590196755 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have key := qBinom_cast_lucas_orderOf (q := 2) (ℓ := 3) (le_refl 2) (by decide)
    (show (6 : ℕ) ≤ 13 by norm_num)
  rw [orderOf_two_zmod_three] at key
  refine ⟨?_, rfl⟩
  rw [key]
  norm_num [show Nat.choose 6 3 = 20 from rfl]
  rfl

/-- **Row count, `q = 2`, `ℓ = 5`, `n = 6`.**  Here `d = 4`, so the residual factor is
`6 % 4 + 1 = 3` and the block row is row `1` of Pascal's triangle, whose two entries are prime
to `5`: the prediction `3 · 2 = 6` matches the row `1, 63, 651, 1395, 651, 63, 1`, in which only
`1395` is divisible by `5`. -/
theorem card_row_two_five_six :
    ((range 7).filter (fun k => ¬ (5 : ℕ) ∣ qBinom 2 6 k)).card = 6 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := card_row_not_dvd_qBinom_orderOf (q := 2) (ℓ := 5) (le_refl 2) (by decide) 6
  rw [orderOf_two_zmod_five] at key
  rw [key]
  decide

/-- **Row count, `q = 2`, `ℓ = 3`, `n = 20`.**  Here `d = 2`, the residual factor is
`20 % 2 + 1 = 1`, and the block row `10 = (101)_3` contributes `2 · 1 · 2 = 4`. -/
theorem card_row_two_three_twenty :
    ((range 21).filter (fun k => ¬ (3 : ℕ) ∣ qBinom 2 20 k)).card = 4 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have key := card_row_not_dvd_qBinom_orderOf (q := 2) (ℓ := 3) (le_refl 2) (by decide) 20
  rw [orderOf_two_zmod_three] at key
  rw [key]
  decide

/-- The same count obtained from the **digit-product closed form**: with `d = 2`,
`⌊20/2⌋ = 10 = (101)_3`, so the answer is `(20 % 2 + 1) · (1+1)(0+1)(1+1) = 4`. -/
theorem card_row_two_three_twenty_digits :
    ((range 21).filter (fun k => ¬ (3 : ℕ) ∣ qBinom 2 20 k)).card
      = (20 % 2 + 1) * ((Nat.digits 3 10).map (fun t => t + 1)).prod := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have key := card_row_not_dvd_qBinom_digits_orderOf (q := 2) (ℓ := 3) (le_refl 2) (by decide) 20
  rw [orderOf_two_zmod_three] at key
  rw [key]

/-- **Extremal instance of the growth bound.**  With `q = 2`, `ℓ = 5`, `d = 4`, `e = v_5(15) = 1`
and `s = 1`, the sharpness theorem predicts `v_5(binom(20,5)_2) = e + s = 2`; indeed
`binom(20,5)_2 = 126769425631762997934675` is divisible by `25` but not by `125`. -/
theorem padicValNat_five_qBinom_two_twenty_five :
    padicValNat 5 (qBinom 2 20 5) = 2 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have hreg := isQRegular_of_odd_prime (ℓ := 5) (q := 2) (by decide) (le_refl 2) (by decide)
  rw [orderOf_two_zmod_five] at hreg
  have hv15 : padicValNat 5 (qNat 2 4) = 1 := by
    have h : qNat 2 4 = 5 * 3 := rfl
    rw [h, padicValNat.mul (by norm_num) (by norm_num), padicValNat.self (by norm_num),
      padicValNat.eq_zero_of_not_dvd (by norm_num)]
  rw [hv15] at hreg
  have key := padicValNat_qBinom_sharp hreg (by norm_num) (s := 1) (le_refl 1)
  norm_num at key
  exact key

/-- **A full `q`-row.**  With `q = 2`, `ℓ = 5` and `d = ord_5(2) = 4`, the row `n = 7` satisfies
`n + 1 = 8 = 4 · (2 · 5^0)`, so the full-row criterion predicts that *every* entry of the seventh
`q`-Pascal row is prime to `5`. -/
theorem full_row_two_five_seven : ∀ k ≤ 7, ¬ (5 : ℕ) ∣ qBinom 2 7 k := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := not_dvd_qBinom_row_iff_orderOf (q := 2) (ℓ := 5) (le_refl 2) (by decide) 7
  rw [orderOf_two_zmod_five] at key
  exact key.mpr (Or.inr ⟨2, 0, by norm_num, by norm_num, by norm_num⟩)

/-- **A row that is not full.**  For `q = 2`, `ℓ = 5`, the row `n = 4` has `n + 1 = 5`, which is
neither `≤ 4` nor a multiple of `d = 4`; the criterion therefore forces some entry of the row to
be divisible by `5` (indeed `binom(4,2)_2 = 35`). -/
theorem not_full_row_two_five_four : ¬ ∀ k ≤ 4, ¬ (5 : ℕ) ∣ qBinom 2 4 k := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have key := not_dvd_qBinom_row_iff_orderOf (q := 2) (ℓ := 5) (le_refl 2) (by decide) 4
  rw [orderOf_two_zmod_five] at key
  intro hfull
  rcases key.mp hfull with h | ⟨c, t, _, _, hct⟩
  · omega
  · exact absurd (Dvd.intro _ hct.symm) (by norm_num : ¬ (4 : ℕ) ∣ 5)

/-- **Refutation of the "row maximum decouples" conjecture.**  The conjecture
`max_{k ≤ n} v_ℓ(binom(n,k)_q) = e + max_{A ≤ ⌊n/d⌋} v_ℓ(C(⌊n/d⌋,A))` for `n ≥ d` is false:
at `q = 2`, `ℓ = 5` (so `d = 4` and `e = v_5([4]_2) = v_5(15) = 1`) and `n = 7 ≥ d`, the block
index is `⌊7/4⌋ = 1`, whose classical row maximum is `0`, so the conjecture predicts `1`; but the
seventh `q`-row is full, i.e. every entry has valuation `0`.  The obstruction is exactly the
residue `n % d = d - 1`, for which no base-`d` carry is possible. -/
theorem row_max_decoupling_fails :
    (∀ k ≤ 7, padicValNat 5 (qBinom 2 7 k) = 0) ∧ padicValNat 5 (qNat 2 4) = 1 := by
  refine ⟨fun k hk => padicValNat.eq_zero_of_not_dvd (full_row_two_five_seven k hk), ?_⟩
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h : qNat 2 4 = 5 * 3 := rfl
  rw [h, padicValNat.mul (by norm_num) (by norm_num), padicValNat.self (by norm_num),
    padicValNat.eq_zero_of_not_dvd (by norm_num)]

end QKummer