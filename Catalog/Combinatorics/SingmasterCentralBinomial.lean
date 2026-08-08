/-
# Central binomial coefficients occur exactly three times (verified initial segment)

Fourth research cycle, building on

* `Combinatorics.SingmasterOccurrences` (the occurrence set `occ`, the multiplicity
  `mult`, monotonicity and growth of binomial coefficients),
* `Combinatorics.SingmasterRefinements` (strict unimodality of a row),
* `Combinatorics.SingmasterParity` (the parity criterion: `N(t)` is odd iff `t` is a
  central binomial coefficient).

The parity criterion reduced the open question "does any number occur exactly five or
exactly seven times?" to the single sequence `C(2m,m) = 2, 6, 20, 70, 252, 924, …`.
This file makes that reduction *effective* and then executes it for `m ≤ 10`.

## The effective criterion

For `t = C(2m,m)` with `m ≥ 2` we prove a **sandwich theorem**
(`Singmaster.choose_lt_centralBinom`): every entry `C(n,k)` with `n ≤ 2m` other than
the central entry itself is *strictly smaller* than `t`.  Hence any further occurrence
of `t` lies in a row `n > 2m`, and being an interior entry it satisfies
`C(n,2) ≤ C(n,k) = t`, which caps `n` by an explicit `N` with `t < C(N,2)`.

So the multiplicity of `C(2m,m)` is exactly three as soon as a *finite, explicitly
bounded* search over `2m < n < N`, `2 ≤ k ≤ n/2` finds no further occurrence
(`Singmaster.mult_centralBinom_eq_three`).  The search is phrased with
`Nat.descFactorial` rather than `Nat.choose`, which is what makes it feasible for the
kernel: `C(n,k) = t` is equivalent to `n.descFactorial k = k ! * t`, and the descending
factorial costs `k` multiplications instead of `C(n,k)` additions.

## Results

* `Singmaster.mult_centralBinom_eq_three` — the effective criterion;
* `Singmaster.mult_centralBinom_eq_three_of_le_ten` — `N(C(2m,m)) = 3` for `2 ≤ m ≤ 10`,
  i.e. for `6, 20, 70, 252, 924, 3432, 12870, 48620, 184756`;
* `Singmaster.mult_ne_five_or_seven_of_lt` — **unconditionally, no `t < 705432` occurs
  exactly five or exactly seven times**.  This is the machine-checked version of the
  empirical observation quoted in the problem statement, and it is obtained from only
  ten finite searches rather than from a scan of all `t`;
* `Singmaster.odd_mult_lt_of_lt` — below `705432` an odd multiplicity is `1` or `3`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterRefinements
import Combinatorics.SingmasterParity

open Finset

namespace Singmaster

/-! ## Basic size estimates for `C(2m,m)` -/

/-- The central binomial coefficient is at least `2`. -/
theorem two_le_centralBinom {m : ℕ} (hm : 1 ≤ m) : 2 ≤ (2 * m).choose m := by
  have h1 : 2 ^ m ≤ (2 * m).choose m := two_pow_le_choose (le_refl _)
  have h2 : 2 ^ 1 ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) hm
  simp only [pow_one] at h2
  omega

/-- The central binomial coefficient of `2m` exceeds its own row index, for `m ≥ 2`. -/
theorem two_mul_lt_centralBinom {m : ℕ} (hm : 2 ≤ m) : 2 * m < (2 * m).choose m := by
  set n := 2 * m with hn
  have hc2 : n.choose 2 ≤ n.choose m := choose_two_le_choose hm (by omega)
  have h1 : n * 3 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
  have h2 : n.choose 2 = n * (n - 1) / 2 := Nat.choose_two_right n
  omega

/-- `m ↦ C(2m,m)` is strictly increasing (exported form of the estimate used in the
parity file). -/
theorem centralBinom_strictMono {a b : ℕ} (h : a < b) :
    (2 * a).choose a < (2 * b).choose b := by
  induction b with
  | zero => omega
  | succ r ih =>
    rcases Nat.lt_or_ge a r with hr | hr
    · exact lt_trans (ih hr) (centralBinom_lt_succ r)
    · have : a = r := by omega
      subst this
      exact centralBinom_lt_succ a

theorem centralBinom_monotone {a b : ℕ} (h : a ≤ b) :
    (2 * a).choose a ≤ (2 * b).choose b := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · exact le_rfl
  · exact le_of_lt (centralBinom_strictMono hlt)

/-! ## The sandwich theorem -/

/-- **Sandwich theorem.**  In the triangle truncated at row `2m`, the central entry
`C(2m,m)` is the strict maximum: every other entry `C(n,k)` with `k ≤ n ≤ 2m` is
strictly smaller.  Consequently a repetition of `C(2m,m)` can only occur *below*
row `2m`. -/
theorem choose_lt_centralBinom {m n k : ℕ} (hm : 1 ≤ m) (hk : k ≤ n) (hn : n ≤ 2 * m)
    (hne : n ≠ 2 * m ∨ k ≠ m) : n.choose k < (2 * m).choose m := by
  set j := min k (n - k) with hj
  have hval : n.choose j = n.choose k := by
    rw [hj, ← fold_mk n k, choose_fold hk]
  rcases Nat.eq_zero_or_pos j with hj0 | hj1
  · have h1 : n.choose k = 1 := by rw [← hval, hj0, Nat.choose_zero_right]
    have h2 := two_le_centralBinom hm
    omega
  · have hjm : j < m := by
      rcases eq_or_lt_of_le hn with heq | hlt
      · have hkm : k ≠ m := by
          rcases hne with h | h
          · exact absurd heq h
          · exact h
        omega
      · omega
    have h1 : n.choose j ≤ (2 * m).choose j := by
      rcases eq_or_lt_of_le hn with heq | hlt
      · rw [heq]
      · exact le_of_lt (choose_lt_choose_left hj1 (by omega) hlt)
    have h2 : (2 * m).choose j < (2 * m).choose m := choose_lt_choose_right hjm (by omega)
    omega

/-! ## The effective criterion -/

/-- The finite search predicate: no interior entry of a row `n` with `2m < n < N`
equals `C(2m,m)`.  Phrased through `Nat.descFactorial` so that it is cheaply
decidable: `C(n,k) = t` iff `n.descFactorial k = k ! * t`. -/
abbrev NoInteriorRepeat (m N : ℕ) : Prop :=
  ∀ n ∈ Finset.Ico (2 * m + 1) N, ∀ k ∈ Finset.Icc 2 (n / 2),
    n.descFactorial k ≠ Nat.factorial k * ((2 * m).choose m)

/-- **Effective criterion for Conjecture "N(C(2m,m)) = 3".**  If `N` is large enough
that `C(N,2)` already exceeds `C(2m,m)`, and no interior entry in the finitely many
rows `2m < n < N` equals `C(2m,m)`, then `C(2m,m)` occurs exactly three times:
at `(t,1)`, `(t,t-1)` and at the central position `(2m,m)`. -/
theorem mult_centralBinom_eq_three {m N : ℕ} (hm : 2 ≤ m) (hN2 : 2 ≤ N)
    (hN : (2 * m).choose m < N.choose 2) (H : NoInteriorRepeat m N) :
    mult ((2 * m).choose m) = 3 := by
  classical
  set t := (2 * m).choose m with hT
  have ht2 : 2 ≤ t := two_le_centralBinom (by omega)
  have htm : 2 * m < t := two_mul_lt_centralBinom hm
  refine le_antisymm ?_ (three_le_mult_centralBinom hm)
  have hsub : occ t ⊆ ({(t, 1), (t, t - 1), (2 * m, m)} : Finset (ℕ × ℕ)) := by
    rintro ⟨n, k⟩ hp
    rw [mem_occ_iff ht2] at hp
    obtain ⟨hk, hck⟩ := hp
    simp only [mem_insert, mem_singleton, Prod.mk.injEq]
    by_cases hk0 : k = 0
    · subst hk0
      rw [Nat.choose_zero_right] at hck
      omega
    by_cases hkn : k = n
    · subst hkn
      rw [Nat.choose_self] at hck
      omega
    by_cases hk1 : k = 1
    · subst hk1
      rw [Nat.choose_one_right] at hck
      exact Or.inl ⟨hck, rfl⟩
    by_cases hkn1 : k = n - 1
    · subst hkn1
      have hs := Nat.choose_symm (n := n) (k := 1) (by omega)
      rw [Nat.choose_one_right] at hs
      rw [hs] at hck
      exact Or.inr (Or.inl ⟨hck, by omega⟩)
    have hk2 : 2 ≤ k := by omega
    have hkk : k + 2 ≤ n := by omega
    rcases Nat.lt_or_ge (2 * m) n with hbig | hsmall
    · exfalso
      have hc2 : n.choose 2 ≤ t := by rw [← hck]; exact choose_two_le_choose hk2 hkk
      have hnN : n < N := by
        by_contra hcon
        push_neg at hcon
        have hmono : N.choose 2 ≤ n.choose 2 := by
          rcases eq_or_lt_of_le hcon with heq | hlt
          · rw [heq]
          · exact le_of_lt (choose_lt_choose_left (by norm_num) hN2 hlt)
        omega
      set j := min k (n - k) with hj
      have hvj : n.choose j = t := by
        rw [hj, ← fold_mk n k, choose_fold hk, hck]
      have hj2 : 2 ≤ j := by omega
      have hjhalf : j ≤ n / 2 := by omega
      refine H n ?_ j ?_ ?_
      · rw [Finset.mem_Ico]; omega
      · rw [Finset.mem_Icc]; exact ⟨hj2, hjhalf⟩
      · rw [Nat.descFactorial_eq_factorial_mul_choose, hvj]
    · refine Or.inr (Or.inr ?_)
      by_contra hcon
      have hne : n ≠ 2 * m ∨ k ≠ m := by
        by_contra hc
        push_neg at hc
        exact hcon ⟨hc.1, hc.2⟩
      have hlt := choose_lt_centralBinom (m := m) (n := n) (k := k) (by omega) hk hsmall hne
      omega
  have hcard : ({(t, 1), (t, t - 1), (2 * m, m)} : Finset (ℕ × ℕ)).card ≤ 3 := by
    refine le_trans (card_insert_le _ _) ?_
    have h1 : ({(t, t - 1), (2 * m, m)} : Finset (ℕ × ℕ)).card ≤ 2 :=
      le_trans (card_insert_le _ _) (by simp)
    omega
  exact le_trans (card_le_card hsub) hcard

/-! ## Executing the criterion for `m ≤ 10`

Each of the following is a genuine finite search over the explicitly bounded window
produced by the criterion; the windows are empty for `m = 2, 3` and grow to
`20 < n < 609` for `m = 10`. -/

theorem mult_centralBinom_two : mult 6 = 3 := mult_six

set_option maxRecDepth 4000 in
theorem mult_centralBinom_three : mult 20 = 3 := by
  have h : (2 * 3).choose 3 = 20 := by decide
  have := mult_centralBinom_eq_three (m := 3) (N := 7) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 4000 in
theorem mult_centralBinom_four : mult 70 = 3 := by
  have h : (2 * 4).choose 4 = 70 := by decide
  have := mult_centralBinom_eq_three (m := 4) (N := 13) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 40000 in
theorem mult_centralBinom_five : mult 252 = 3 := by
  have h : (2 * 5).choose 5 = 252 := by decide
  have := mult_centralBinom_eq_three (m := 5) (N := 23) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 100000 in
theorem mult_centralBinom_six : mult 924 = 3 := by
  have h : (2 * 6).choose 6 = 924 := by decide
  have := mult_centralBinom_eq_three (m := 6) (N := 44) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 200000 in
theorem mult_centralBinom_seven : mult 3432 = 3 := by
  have h : (2 * 7).choose 7 = 3432 := by decide
  have := mult_centralBinom_eq_three (m := 7) (N := 84) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 400000 in
theorem mult_centralBinom_eight : mult 12870 = 3 := by
  have h : (2 * 8).choose 8 = 12870 := by decide
  have := mult_centralBinom_eq_three (m := 8) (N := 161) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxRecDepth 2000000 in
theorem mult_centralBinom_nine : mult 48620 = 3 := by
  have h : (2 * 9).choose 9 = 48620 := by decide
  have := mult_centralBinom_eq_three (m := 9) (N := 313) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 4000000 in
theorem mult_centralBinom_ten : mult 184756 = 3 := by
  have h : (2 * 10).choose 10 = 184756 := by decide
  have := mult_centralBinom_eq_three (m := 10) (N := 609) (by norm_num) (by norm_num)
    (by decide) (by decide)
  rwa [h] at this

/-- **The first nine nontrivial central binomial coefficients occur exactly three
times.**  (For `m = 1` the value is `2`, of multiplicity one.) -/
theorem mult_centralBinom_eq_three_of_le_ten {m : ℕ} (hm : 2 ≤ m) (hm' : m ≤ 10) :
    mult ((2 * m).choose m) = 3 := by
  have e2 : (2 * 2).choose 2 = 6 := by decide
  have e3 : (2 * 3).choose 3 = 20 := by decide
  have e4 : (2 * 4).choose 4 = 70 := by decide
  have e5 : (2 * 5).choose 5 = 252 := by decide
  have e6 : (2 * 6).choose 6 = 924 := by decide
  have e7 : (2 * 7).choose 7 = 3432 := by decide
  have e8 : (2 * 8).choose 8 = 12870 := by decide
  have e9 : (2 * 9).choose 9 = 48620 := by decide
  have e10 : (2 * 10).choose 10 = 184756 := by decide
  interval_cases m
  · rw [e2]; exact mult_centralBinom_two
  · rw [e3]; exact mult_centralBinom_three
  · rw [e4]; exact mult_centralBinom_four
  · rw [e5]; exact mult_centralBinom_five
  · rw [e6]; exact mult_centralBinom_six
  · rw [e7]; exact mult_centralBinom_seven
  · rw [e8]; exact mult_centralBinom_eight
  · rw [e9]; exact mult_centralBinom_nine
  · rw [e10]; exact mult_centralBinom_ten

/-! ## Unconditional consequences below `C(22,11) = 705432` -/

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 1000000 in
/-- Every `t ≥ 2` below `C(22,11) = 705432` whose multiplicity is odd is one of
`2, 6, 20, 70, 252, 924, 3432, 12870, 48620, 184756`, and its multiplicity is `1`
(only for `t = 2`) or `3`. -/
theorem odd_mult_lt_of_lt {t : ℕ} (ht : 2 ≤ t) (hlt : t < 705432) (hodd : Odd (mult t)) :
    mult t = 1 ∨ mult t = 3 := by
  obtain ⟨m, hm⟩ := (odd_mult_iff_centralBinom ht).1 hodd
  have hm10 : m ≤ 10 := by
    by_contra hc
    push_neg at hc
    have hmono : (2 * 11).choose 11 ≤ (2 * m).choose m := centralBinom_monotone (by omega)
    have hval : (2 * 11).choose 11 = 705432 := by decide
    omega
  rcases Nat.lt_or_ge m 2 with hlow | hge
  · have e0 : (2 * 0).choose 0 = 1 := by decide
    have e1 : (2 * 1).choose 1 = 2 := by decide
    interval_cases m
    · rw [e0] at hm; omega
    · rw [e1] at hm
      subst hm
      exact Or.inl mult_two
  · rw [hm, mult_centralBinom_eq_three_of_le_ten hge hm10]
    exact Or.inr rfl

/-- **Unconditional verification of the "no fives, no sevens" phenomenon below
`705432`.**  No number `t` with `2 ≤ t < 705432` occurs exactly five or exactly seven
times in Pascal's triangle.

The proof is *not* a scan over all `t`: the parity criterion
(`Singmaster.odd_mult_iff_centralBinom`) shows that an odd multiplicity forces `t` to be
a central binomial coefficient, and the ten finite searches above settle those. -/
theorem mult_ne_five_or_seven_of_lt {t : ℕ} (ht : 2 ≤ t) (hlt : t < 705432) :
    mult t ≠ 5 ∧ mult t ≠ 7 := by
  constructor <;> intro hcon
  · have hodd : Odd (mult t) := ⟨2, by omega⟩
    rcases odd_mult_lt_of_lt ht hlt hodd with h | h <;> omega
  · have hodd : Odd (mult t) := ⟨3, by omega⟩
    rcases odd_mult_lt_of_lt ht hlt hodd with h | h <;> omega

end Singmaster