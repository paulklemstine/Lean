/-
# A cubic search window: `N(C(2m,m)) = 3` up to `m = 20`, and no fives or sevens below
# `538257874440`

Sixth research cycle.  `Combinatorics.SingmasterCentralBinomial` reduced the open
question *"does any number occur exactly five or exactly seven times?"* to the single
sequence of central binomial coefficients and made the reduction effective: for
`t = C(2m,m)` the multiplicity is `3` as soon as no interior entry `C(n,k) = t` occurs
in a row `2m < n < N` with `N ≈ √(2t)` and `2 ≤ k ≤ n/2`.  Executing that quadratic
search cost `(N - 2m) · (N/2)` kernel tests and stopped at `m = 10`.

This file removes both factors of the search box.

## Two structural reductions

* **The column collapse** (`Singmaster.column_lt_of_choose_eq_centralBinom`).  In the
  escape window the column index is *tiny*: if `2k ≤ n`, `n > 2m` and
  `C(n,k) = C(2m,m)`, then `k < m`.  Indeed `C(2k,k) ≤ C(n,k)` (monotonicity in the
  row) and `m ↦ C(2m,m)` is strictly increasing, so `k ≥ m` would force
  `C(2m,m) ≤ C(2k,k) ≤ C(n,k) = C(2m,m)` with a strict inequality somewhere (from
  `k > m`, or from `n > 2m` when `k = m`).  So the columns run over `[3, m-1]`, a strip
  of height `m`, instead of a triangle of height `N/2`.

* **The triangular obstruction** (`Singmaster.choose_two_ne_of_not_sq`).  The column
  `k = 2` is the one that forces the large window `N ≈ √(2t)`, and it need not be
  searched at all: `C(n,2) = t` happens iff `t` is a triangular number, i.e. iff
  `8t + 1` is a perfect square.  A single square test therefore eliminates the whole
  column `k = 2`, after which every remaining entry satisfies `C(n,3) ≤ t` and the row
  window shrinks from `√(2t)` to `(6t)^{1/3}`.

For `m = 20` the box shrinks from `524248 × 262124` to `9347 × 17`: a saving of more
than nine orders of magnitude, which is what makes the kernel verification of
`m = 11, …, 20` possible.

## Results

* `Singmaster.two_mul_choose_two`, `Singmaster.choose_two_ne_of_not_sq` — the
  triangular obstruction;
* `Singmaster.column_lt_of_choose_eq_centralBinom` — the column collapse;
* `Singmaster.mult_centralBinom_eq_three_cubic` — the resulting criterion;
* `Singmaster.mult_centralBinom_eq_three_of_le_twenty` — `N(C(2m,m)) = 3` for every
  `2 ≤ m ≤ 20`, i.e. up to `C(40,20) = 137846528820`;
* `Singmaster.mult_ne_five_or_seven_of_lt_large` — **unconditionally, no `t` with
  `2 ≤ t < 538257874440 = C(42,21)` occurs exactly five or exactly seven times**,
  extending the previous range `705432` by a factor of more than `700000`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterRefinements
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterCentralBinomial
import Combinatorics.SingmasterExactCounts

open Finset

namespace Singmaster

/-! ## The triangular obstruction: the column `k = 2` -/

/-- `2·C(n+1,2) = (n+1)·n`, proved by induction; the `ℕ`-subtraction-free form of
`Nat.choose_two_right`. -/
theorem two_mul_choose_two (n : ℕ) : 2 * (n + 1).choose 2 = (n + 1) * n := by
  induction n with
  | zero => decide
  | succ r ih =>
    rw [Nat.choose_succ_succ (r + 1) 1, Nat.choose_one_right]
    have hsplit : 2 * ((r + 1) + (r + 1).choose 2) = 2 * (r + 1) + 2 * (r + 1).choose 2 := by
      ring
    rw [hsplit, ih]
    ring

/-- **Triangular obstruction.**  If `t` occurs in the column `k = 2` of Pascal's
triangle then `8t + 1` is a perfect square (`t` is a triangular number).  Hence
exhibiting an `s` with `s² < 8t + 1 < (s+1)²` rules out the entire column `k = 2` — the
column responsible for the largest rows, and therefore for the size of the search
window. -/
theorem choose_two_ne_of_not_sq {n t s : ℕ} (hs1 : s * s < 8 * t + 1)
    (hs2 : 8 * t + 1 < (s + 1) * (s + 1)) : n.choose 2 ≠ t := by
  intro heq
  obtain ⟨S, hS⟩ : ∃ S : ℕ, S * S = 8 * t + 1 := by
    match n with
    | 0 =>
      refine ⟨1, ?_⟩
      rw [← heq]
      decide
    | 1 =>
      refine ⟨1, ?_⟩
      rw [← heq]
      decide
    | (j + 2) =>
      refine ⟨2 * j + 3, ?_⟩
      have hkey : 2 * ((j + 2).choose 2) = (j + 2) * (j + 1) := two_mul_choose_two (j + 1)
      rw [heq] at hkey
      nlinarith [hkey]
  rw [← hS] at hs1 hs2
  have h1 : s < S := by nlinarith
  have h2 : S < s + 1 := by nlinarith
  omega

/-! ## The column collapse -/

/-- **The escape window has small columns.**  If a row `n` below the central row
(i.e. `n > 2m`) contains the central binomial coefficient `C(2m,m)` at a folded column
`k` (so `2k ≤ n`), then `k < m`.

This truncates the finite search from a triangle of height `N/2` to a strip of
height `m`. -/
theorem column_lt_of_choose_eq_centralBinom {m n k : ℕ} (hk : 2 ≤ k) (hkn : 2 * k ≤ n)
    (hn : 2 * m < n) (heq : n.choose k = (2 * m).choose m) : k < m := by
  by_contra hcon
  push_neg at hcon
  have h1 : (2 * k).choose k ≤ n.choose k := Nat.choose_le_choose k hkn
  rcases eq_or_lt_of_le hcon with hmk | hmk
  · -- `k = m`: strict monotonicity in the row index gives `C(2m,m) < C(n,m)`
    have hlt : (2 * k).choose k < n.choose k :=
      choose_lt_choose_left (by omega) (by omega) (by omega)
    have he : (2 * m).choose m = (2 * k).choose k := by rw [hmk]
    omega
  · -- `k > m`: strict monotonicity of the central binomial coefficients
    have h2 : (2 * m).choose m < (2 * k).choose k := centralBinom_strictMono hmk
    omega

/-! ## Comparison lemmas for the truncated box -/

/-- If `j` is at most the folded index of `k` in row `n`, then `C(n,j) ≤ C(n,k)`:
Pascal's rows are unimodal and symmetric. -/
theorem choose_le_choose_of_le_fold {n j k : ℕ} (hk : k ≤ n) (hj : j ≤ min k (n - k)) :
    n.choose j ≤ n.choose k := by
  have hval : n.choose (min k (n - k)) = n.choose k := by
    rw [← fold_mk n k, choose_fold hk]
  have hhalf : 2 * min k (n - k) ≤ n := by omega
  rcases eq_or_lt_of_le hj with heq | hlt
  · rw [heq, hval]
  · exact le_of_lt (hval ▸ choose_lt_choose_right hlt hhalf)

/-- A cheap sufficient condition for `t < C(N,k)`, phrased through the descending
factorial so that the kernel can check it with `k` multiplications. -/
theorem lt_choose_of_descFactorial {N k t : ℕ}
    (h : Nat.factorial k * t < N.descFactorial k) : t < N.choose k := by
  rw [Nat.descFactorial_eq_factorial_mul_choose] at h
  exact lt_of_mul_lt_mul_left h (Nat.zero_le _)

/-! ## The criterion -/

/-- The cubic search predicate: no entry `C(n,k) = t` with `2m < n < N` and
`3 ≤ k ≤ m - 1`.  As before the test is phrased through `Nat.descFactorial`, which
costs `k` multiplications instead of `C(n,k)` additions. -/
abbrev NoCubicRepeat (m N t : ℕ) : Prop :=
  ∀ n ∈ Finset.Ico (2 * m + 1) N, ∀ k ∈ Finset.Icc 3 (m - 1),
    n.descFactorial k ≠ Nat.factorial k * t

/-- Splitting a bounded search into two consecutive windows; used to keep the individual
kernel computations of manageable size. -/
theorem forall_Ico_glue {a b c : ℕ} {P : ℕ → Prop} (h1 : ∀ n ∈ Finset.Ico a b, P n)
    (h2 : ∀ n ∈ Finset.Ico b c, P n) : ∀ n ∈ Finset.Ico a c, P n := by
  intro n hn
  rw [Finset.mem_Ico] at hn
  rcases Nat.lt_or_ge n b with h | h
  · exact h1 n (by rw [Finset.mem_Ico]; omega)
  · exact h2 n (by rw [Finset.mem_Ico]; omega)

/-- **Effective criterion for `N(C(2m,m)) = 3`, cubic form.**  Suppose `m ≥ 3`,
`t = C(2m,m)`, and

* `8t + 1` is strictly between the consecutive squares `s²` and `(s+1)²`, so `t` is not
  triangular and the column `k = 2` is empty,
* `C(N,3)` already exceeds `t` (so every remaining escape row is `< N`),
* no entry with row in `(2m, N)` and column in `[3, m-1]` equals `t`.

Then `t` occurs exactly three times: at `(t,1)`, `(t,t-1)` and at the central position
`(2m,m)`. -/
theorem mult_centralBinom_eq_three_cubic {m N t s : ℕ} (hm : 3 ≤ m)
    (hval : (2 * m).choose m = t) (hN : t < N.choose 3)
    (hs1 : s * s < 8 * t + 1) (hs2 : 8 * t + 1 < (s + 1) * (s + 1))
    (H : NoCubicRepeat m N t) : mult t = 3 := by
  classical
  have ht2 : 2 ≤ t := hval ▸ two_le_centralBinom (by omega)
  have htm : 2 * m < t := hval ▸ two_mul_lt_centralBinom (by omega)
  refine le_antisymm ?_ (hval ▸ three_le_mult_centralBinom (by omega))
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
      set j := min k (n - k) with hj
      have hvj : n.choose j = t := by
        rw [hj, ← fold_mk n k, choose_fold hk, hck]
      have hj2 : 2 ≤ j := by omega
      have hjhalf : 2 * j ≤ n := by omega
      rcases eq_or_lt_of_le hj2 with hj2eq | hj3
      · -- the column `k = 2` is excluded by the triangular obstruction
        exact choose_two_ne_of_not_sq hs1 hs2 (hj2eq ▸ hvj)
      · -- every remaining column satisfies `C(n,3) ≤ t`, which bounds the row by `N`
        have hj3' : 3 ≤ j := hj3
        have hc3 : n.choose 3 ≤ t := by
          rw [← hvj]
          exact choose_le_choose_of_le_fold (by omega) (by omega)
        have hnN : n < N := by
          by_contra hcon
          push_neg at hcon
          have hmono : N.choose 3 ≤ n.choose 3 := Nat.choose_le_choose 3 hcon
          omega
        have hjm : j < m :=
          column_lt_of_choose_eq_centralBinom (by omega) hjhalf hbig (by rw [hvj, hval])
        refine H n ?_ j ?_ ?_
        · rw [Finset.mem_Ico]; omega
        · rw [Finset.mem_Icc]; omega
        · rw [Nat.descFactorial_eq_factorial_mul_choose, hvj]
    · refine Or.inr (Or.inr ?_)
      by_contra hcon
      have hne : n ≠ 2 * m ∨ k ≠ m := by
        by_contra hc
        push_neg at hc
        exact hcon ⟨hc.1, hc.2⟩
      have hlt := choose_lt_centralBinom (m := m) (n := n) (k := k) (by omega) hk hsmall hne
      rw [hval] at hlt
      omega
  have hcard : ({(t, 1), (t, t - 1), (2 * m, m)} : Finset (ℕ × ℕ)).card ≤ 3 := by
    refine le_trans (card_insert_le _ _) ?_
    have h1 : ({(t, t - 1), (2 * m, m)} : Finset (ℕ × ℕ)).card ≤ 2 :=
      le_trans (card_insert_le _ _) (by simp)
    omega
  exact le_trans (card_le_card hsub) hcard

/-! ## Executing the criterion for `11 ≤ m ≤ 20`

Each search runs over the rectangle `2m < n < (6t)^{1/3}`, `3 ≤ k ≤ m - 1`; the largest
is `40 < n < 9388`, `3 ≤ k ≤ 19` for `m = 20`.  Every step is a kernel computation:
`decide +kernel` type-checks the Boolean evaluation in the kernel, it is *not*
`native_decide`. -/

set_option maxRecDepth 10000 in
/-- `C(22,11) = 705432` occurs exactly three times. -/
theorem mult_centralBinom_eleven : mult 705432 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 11) (s := 2375) (N := 163) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 20000 in
/-- `C(24,12) = 2704156` occurs exactly three times. -/
theorem mult_centralBinom_twelve : mult 2704156 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 12) (s := 4651) (N := 255) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 40000 in
/-- `C(26,13) = 10400600` occurs exactly three times. -/
theorem mult_centralBinom_thirteen : mult 10400600 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 13) (s := 9121) (N := 398) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 40000 in
/-- `C(28,14) = 40116600` occurs exactly three times. -/
theorem mult_centralBinom_fourteen : mult 40116600 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 14) (s := 17914) (N := 624) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 80000 in
/-- `C(30,15) = 155117520` occurs exactly three times. -/
theorem mult_centralBinom_fifteen : mult 155117520 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 15) (s := 35226) (N := 978) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 200000 in
/-- `C(32,16) = 601080390` occurs exactly three times. -/
theorem mult_centralBinom_sixteen : mult 601080390 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 16) (s := 69344) (N := 1535) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 400000 in
/-- `C(34,17) = 2333606220` occurs exactly three times. -/
theorem mult_centralBinom_seventeen : mult 2333606220 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 17) (s := 136633) (N := 2412) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 800000 in
/-- `C(36,18) = 9075135300` occurs exactly three times. -/
theorem mult_centralBinom_eighteen : mult 9075135300 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 18) (s := 269445) (N := 3792) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 2000000 in
/-- `C(38,19) = 35345263800` occurs exactly three times. -/
theorem mult_centralBinom_nineteen : mult 35345263800 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 19) (s := 531753) (N := 5965) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  decide +kernel

set_option maxRecDepth 8000000 in
/-- `C(40,20) = 137846528820` occurs exactly three times. -/
theorem mult_centralBinom_twenty : mult 137846528820 = 3 := by
  refine mult_centralBinom_eq_three_cubic (m := 20) (s := 1050129) (N := 9388) (by norm_num)
    (choose_eq_iff_descFactorial.2 (by decide)) (lt_choose_of_descFactorial (by decide))
    (by norm_num) (by norm_num) ?_
  refine forall_Ico_glue (b := 3000) (by decide +kernel) ?_
  refine forall_Ico_glue (b := 6000) (by decide +kernel) ?_
  decide +kernel

/-- **Every central binomial coefficient `C(2m,m)` with `2 ≤ m ≤ 20` occurs exactly
three times.**  This extends `Singmaster.mult_centralBinom_eq_three_of_le_ten` from
`184756` to `137846528820`. -/
theorem mult_centralBinom_eq_three_of_le_twenty {m : ℕ} (hm : 2 ≤ m) (hm' : m ≤ 20) :
    mult ((2 * m).choose m) = 3 := by
  rcases Nat.lt_or_ge m 11 with hlow | hhigh
  · exact mult_centralBinom_eq_three_of_le_ten hm (by omega)
  · have e11 : (2 * 11).choose 11 = 705432 := choose_eq_iff_descFactorial.2 (by decide)
    have e12 : (2 * 12).choose 12 = 2704156 := choose_eq_iff_descFactorial.2 (by decide)
    have e13 : (2 * 13).choose 13 = 10400600 := choose_eq_iff_descFactorial.2 (by decide)
    have e14 : (2 * 14).choose 14 = 40116600 := choose_eq_iff_descFactorial.2 (by decide)
    have e15 : (2 * 15).choose 15 = 155117520 := choose_eq_iff_descFactorial.2 (by decide)
    have e16 : (2 * 16).choose 16 = 601080390 := choose_eq_iff_descFactorial.2 (by decide)
    have e17 : (2 * 17).choose 17 = 2333606220 := choose_eq_iff_descFactorial.2 (by decide)
    have e18 : (2 * 18).choose 18 = 9075135300 := choose_eq_iff_descFactorial.2 (by decide)
    have e19 : (2 * 19).choose 19 = 35345263800 := choose_eq_iff_descFactorial.2 (by decide)
    have e20 : (2 * 20).choose 20 = 137846528820 := choose_eq_iff_descFactorial.2 (by decide)
    interval_cases m
    · rw [e11]; exact mult_centralBinom_eleven
    · rw [e12]; exact mult_centralBinom_twelve
    · rw [e13]; exact mult_centralBinom_thirteen
    · rw [e14]; exact mult_centralBinom_fourteen
    · rw [e15]; exact mult_centralBinom_fifteen
    · rw [e16]; exact mult_centralBinom_sixteen
    · rw [e17]; exact mult_centralBinom_seventeen
    · rw [e18]; exact mult_centralBinom_eighteen
    · rw [e19]; exact mult_centralBinom_nineteen
    · rw [e20]; exact mult_centralBinom_twenty

/-! ## Unconditional consequences below `C(42,21) = 538257874440` -/

/-- Below `C(42,21) = 538257874440`, an odd multiplicity is `1` (only for `t = 2`) or
`3` (exactly for the central binomial coefficients `6, 20, …, 137846528820`). -/
theorem odd_mult_lt_of_lt_large {t : ℕ} (ht : 2 ≤ t) (hlt : t < 538257874440)
    (hodd : Odd (mult t)) : mult t = 1 ∨ mult t = 3 := by
  obtain ⟨m, hm⟩ := (odd_mult_iff_centralBinom ht).1 hodd
  have hm20 : m ≤ 20 := by
    by_contra hc
    push_neg at hc
    have hmono : (2 * 21).choose 21 ≤ (2 * m).choose m := centralBinom_monotone (by omega)
    have hval : (2 * 21).choose 21 = 538257874440 := choose_eq_iff_descFactorial.2 (by decide)
    omega
  rcases Nat.lt_or_ge m 2 with hlow | hge
  · have e0 : (2 * 0).choose 0 = 1 := by decide
    have e1 : (2 * 1).choose 1 = 2 := by decide
    interval_cases m
    · rw [e0] at hm; omega
    · rw [e1] at hm
      subst hm
      exact Or.inl mult_two
  · rw [hm, mult_centralBinom_eq_three_of_le_twenty hge hm20]
    exact Or.inr rfl

/-- **No number below `C(42,21) = 538257874440` occurs exactly five or exactly seven
times.**  This extends `Singmaster.mult_ne_five_or_seven_of_lt` (which reached
`705432`) by a factor of more than `700000`, still without any scan over `t`: the parity
criterion confines odd multiplicities to central binomial coefficients, and the
nineteen searches above settle those. -/
theorem mult_ne_five_or_seven_of_lt_large {t : ℕ} (ht : 2 ≤ t) (hlt : t < 538257874440) :
    mult t ≠ 5 ∧ mult t ≠ 7 := by
  constructor <;> intro hcon
  · have hodd : Odd (mult t) := ⟨2, by omega⟩
    rcases odd_mult_lt_of_lt_large ht hlt hodd with h | h <;> omega
  · have hodd : Odd (mult t) := ⟨3, by omega⟩
    rcases odd_mult_lt_of_lt_large ht hlt hodd with h | h <;> omega

end Singmaster