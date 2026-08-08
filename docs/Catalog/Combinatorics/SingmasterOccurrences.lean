/-
# Singmaster's problem: how often can a number occur in Pascal's triangle?

Let `N(t) = #{(n,k) : k ≤ n and C(n,k) = t}` be the *multiplicity* of `t` in Pascal's
triangle.  Singmaster (1971) asked whether `N` is bounded on `t ≥ 2`; this is open.
This file develops the elementary structure theory that *is* provable:

* every occurrence of `t ≥ 2` lies in row `n ≤ t` (`Singmaster.row_le_of_choose_eq`),
  so `N(t)` is finite and is computed by the explicit `Finset` `Singmaster.occ t`;
* `N(2) = 1`, `N(3) = N(4) = N(5) = 2`, `N(6) = 3`, `N(10) = 4` (verified by decision
  procedure on the explicit finite search box);
* `N(t) ≥ 2` for every `t ≥ 3` (`Singmaster.two_le_mult`);
* `N(p) = 2` for every odd prime `p` (`Singmaster.mult_odd_prime`);
* `N(3003) ≥ 8` (`Singmaster.eight_le_mult_3003`);
* infinitely many `t` have `N(t) ≥ 4` (`Singmaster.four_le_mult_choose_two`);
* **an unconditional logarithmic upper bound** `N(t) ≤ 2 * Nat.log 2 t` for `t ≥ 2`
  (`Singmaster.mult_le_two_mul_log`).  This is the strongest general statement
  available by elementary means; Singmaster's conjecture asks to replace
  `2 * log₂ t` by an absolute constant.

The engine behind the upper bound is a cross-cutting pair of facts:
a *monotonicity* fact (for fixed `k ≥ 1`, `n ↦ C(n,k)` is strictly increasing, so each
column meets each value at most once) and a *growth* fact (`2^k ≤ C(n,k)` whenever
`2k ≤ n`, so only logarithmically many columns are relevant at all).
-/
import Mathlib

open Finset

namespace Singmaster

/-! ## Elementary inequalities for binomial coefficients -/

/-- Pascal's rule makes `n ↦ C(n,k)` strictly increasing for `1 ≤ k ≤ n`. -/
theorem choose_lt_choose_succ_left {n k : ℕ} (h1 : 1 ≤ k) (h2 : k ≤ n) :
    n.choose k < (n + 1).choose k := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  rw [Nat.choose_succ_succ]
  simp only [Nat.succ_eq_add_one]
  have : 0 < n.choose j := Nat.choose_pos (by omega)
  omega

/-- Strict monotonicity of `n ↦ C(n,k)` in the row index, for a fixed column `k ≥ 1`. -/
theorem choose_lt_choose_left {n m k : ℕ} (h1 : 1 ≤ k) (h2 : k ≤ n) (h3 : n < m) :
    n.choose k < m.choose k := by
  induction m with
  | zero => omega
  | succ p ih =>
    rcases Nat.lt_or_ge n p with h | h
    · exact lt_trans (ih h) (choose_lt_choose_succ_left h1 (by omega))
    · have hnp : n = p := by omega
      subst hnp
      exact choose_lt_choose_succ_left h1 h2

/-- **Column uniqueness.**  For a fixed column `k ≥ 1`, a value occurs at most once. -/
theorem row_unique {n m k : ℕ} (h1 : 1 ≤ k) (hn : k ≤ n) (hm : k ≤ m)
    (h : n.choose k = m.choose k) : n = m := by
  rcases lt_trichotomy n m with hlt | heq | hgt
  · exact absurd h (Nat.ne_of_lt (choose_lt_choose_left h1 hn hlt))
  · exact heq
  · exact absurd h.symm (Nat.ne_of_lt (choose_lt_choose_left h1 hm hgt))

/-- Every interior entry of row `n` is at least `n`. -/
theorem row_le_choose {n k : ℕ} (h1 : 1 ≤ k) (h2 : k + 1 ≤ n) : n ≤ n.choose k := by
  induction n using Nat.strong_induction_on generalizing k with
  | _ n ih =>
    rcases eq_or_lt_of_le h1 with h | h
    · subst h; simp [Nat.choose_one_right]
    rcases Nat.lt_or_ge (k + 1) n with hk | hk
    · obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨n - 1, by omega⟩
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
      rw [Nat.choose_succ_succ]
      simp only [Nat.succ_eq_add_one]
      have h1' : p ≤ p.choose j := ih p (by omega) (by omega) (by omega)
      have h2' : p ≤ p.choose (j + 1) := ih p (by omega) (by omega) (by omega)
      omega
    · have hkn : k = n - 1 := by omega
      subst hkn
      have := Nat.choose_symm (n := n) (k := 1) (by omega)
      simp [Nat.choose_one_right] at this
      omega

/-- Entries strictly inside row `n` (i.e. `2 ≤ k ≤ n-2`) are at least `C(n,2)`. -/
theorem choose_two_le_choose {n k : ℕ} (h1 : 2 ≤ k) (h2 : k + 2 ≤ n) :
    n.choose 2 ≤ n.choose k := by
  induction n using Nat.strong_induction_on generalizing k with
  | _ n ih =>
    rcases eq_or_lt_of_le h1 with h | h
    · subst h; exact le_rfl
    rcases Nat.lt_or_ge (k + 2) n with hk | hk
    · obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨n - 1, by omega⟩
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
      have hA : (p + 1).choose (j + 1) = p.choose j + p.choose (j + 1) := Nat.choose_succ_succ p j
      have hB : (p + 1).choose 2 = p.choose 1 + p.choose 2 := Nat.choose_succ_succ p 1
      have h1' : p.choose 2 ≤ p.choose j := ih p (by omega) (by omega) (by omega)
      have h2' : p.choose 2 ≤ p.choose (j + 1) := ih p (by omega) (by omega) (by omega)
      have h3' : p ≤ p.choose 2 := row_le_choose (by omega) (by omega)
      rw [Nat.choose_one_right] at hB
      omega
    · have hkn : k = n - 2 := by omega
      subst hkn
      have := Nat.choose_symm (n := n) (k := 2) (by omega)
      omega

/-- The central binomial coefficient grows at least geometrically. -/
theorem two_pow_le_centralBinom (k : ℕ) : 2 ^ k ≤ (2 * k).choose k := by
  induction k with
  | zero => simp
  | succ j ih =>
    have e1 : (2 * (j + 1)).choose (j + 1) = (2 * j + 1).choose j + (2 * j + 1).choose (j + 1) := by
      have h : 2 * (j + 1) = (2 * j + 1) + 1 := by ring
      rw [h, Nat.choose_succ_succ]
    have e2 : (2 * j + 1).choose j = (2 * j + 1).choose (j + 1) := by
      have h := Nat.choose_symm (n := 2 * j + 1) (k := j) (by omega)
      rw [show 2 * j + 1 - j = j + 1 by omega] at h
      omega
    have e3 : (2 * j + 1).choose (j + 1) = (2 * j).choose j + (2 * j).choose (j + 1) :=
      Nat.choose_succ_succ (2 * j) j
    have e4 : 2 ^ (j + 1) = 2 * 2 ^ j := by ring
    omega

/-- **Growth in the column index.**  If `k` is at most half of `n`, then `C(n,k) ≥ 2^k`. -/
theorem two_pow_le_choose {n k : ℕ} (h : 2 * k ≤ n) : 2 ^ k ≤ n.choose k := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simp
  refine le_trans (two_pow_le_centralBinom k) ?_
  rcases eq_or_lt_of_le h with h' | h'
  · rw [h']
  · exact le_of_lt (choose_lt_choose_left hk (by omega) h')

/-! ## The occurrence set and the multiplicity function -/

/-- Rows containing an entry equal to `t ≥ 2` are bounded by `t`. -/
theorem row_le_of_choose_eq {n k t : ℕ} (ht : 2 ≤ t) (hk : k ≤ n) (h : n.choose k = t) :
    n ≤ t := by
  have hk0 : k ≠ 0 := by rintro rfl; simp at h; omega
  have hkn : k ≠ n := by rintro rfl; simp at h; omega
  have := row_le_choose (n := n) (k := k) (by omega) (by omega)
  omega

/-- The (finite) set of positions of `t` in Pascal's triangle, as a concrete `Finset`.
Positions are pairs `(n, k)` with `k ≤ n` and `C(n,k) = t`, searched in the box
`[0, t] × [0, t]`, which is provably exhaustive for `t ≥ 2`. -/
def occ (t : ℕ) : Finset (ℕ × ℕ) :=
  ((range (t + 1)) ×ˢ (range (t + 1))).filter (fun p => p.2 ≤ p.1 ∧ p.1.choose p.2 = t)

/-- Singmaster's multiplicity function `N(t)`. -/
def mult (t : ℕ) : ℕ := (occ t).card

/-- **Exhaustiveness.**  For `t ≥ 2` the finite box really captures *all* occurrences. -/
theorem mem_occ_iff {t : ℕ} (ht : 2 ≤ t) (n k : ℕ) :
    (n, k) ∈ occ t ↔ k ≤ n ∧ n.choose k = t := by
  constructor
  · intro h
    simp only [occ, mem_filter] at h
    exact h.2
  · rintro ⟨hk, h⟩
    have hn : n ≤ t := row_le_of_choose_eq ht hk h
    simp only [occ, mem_filter, mem_product, mem_range]
    exact ⟨⟨by omega, by omega⟩, hk, h⟩

/-- Membership helper: an explicit position of `t` belongs to `occ t`. -/
theorem mem_occ {t n k : ℕ} (ht : 2 ≤ t) (hk : k ≤ n) (h : n.choose k = t) :
    (n, k) ∈ occ t := (mem_occ_iff ht n k).2 ⟨hk, h⟩

/-! ## Small values -/

/-- `2` occurs exactly once: it is the unique number of multiplicity one besides `1`'s
degenerate behaviour. -/
theorem mult_two : mult 2 = 1 := by decide

theorem mult_three : mult 3 = 2 := by decide

theorem mult_four : mult 4 = 2 := by decide

theorem mult_five : mult 5 = 2 := by decide

/-- `6 = C(6,1) = C(6,5) = C(4,2)` occurs exactly three times. -/
theorem mult_six : mult 6 = 3 := by decide

/-- `10 = C(10,1) = C(10,9) = C(5,2) = C(5,3)` occurs exactly four times. -/
theorem mult_ten : mult 10 = 4 := by decide

/- From here on `occ` is treated as an opaque finite set: all further reasoning goes
through `mem_occ_iff`, and this prevents the elaborator from trying to expand the
(astronomically large) search box for big values of `t`. -/
attribute [irreducible] occ

/-! ## Lower bounds -/

/-- Every `t ≥ 3` occurs at least twice, namely as `C(t,1)` and `C(t,t-1)`. -/
theorem two_le_mult {t : ℕ} (ht : 3 ≤ t) : 2 ≤ mult t := by
  have h1 : (t, 1) ∈ occ t := mem_occ (by omega) (by omega) (Nat.choose_one_right t)
  have h2 : (t, t - 1) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have := Nat.choose_symm (n := t) (k := 1) (by omega)
    rw [Nat.choose_one_right] at this
    exact this
  have hsub : ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)) ⊆ occ t := by
    intro x hx
    simp only [mem_insert, mem_singleton] at hx
    rcases hx with rfl | rfl <;> assumption
  have hcard : ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simp; omega), card_singleton]
  calc 2 = ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)).card := hcard.symm
    _ ≤ mult t := card_le_card hsub

/-- Infinitely many numbers occur at least four times: every triangular number
`C(n,2)` with `n ≥ 5` does, at `(C(n,2),1)`, `(C(n,2),C(n,2)-1)`, `(n,2)` and `(n,n-2)`. -/
theorem four_le_mult_choose_two {n : ℕ} (hn : 5 ≤ n) : 4 ≤ mult (n.choose 2) := by
  set t := n.choose 2 with hT
  have hnt : n < t := by
    have h1 : n * 4 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
    have h2 : t = n * (n - 1) / 2 := Nat.choose_two_right n
    omega
  have ht : 3 ≤ t := by omega
  have hsymm : n.choose (n - 2) = t := Nat.choose_symm (by omega)
  have m1 : (t, 1) ∈ occ t := mem_occ (by omega) (by omega) (Nat.choose_one_right t)
  have m2 : (t, t - 1) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have h := Nat.choose_symm (n := t) (k := 1) (by omega)
    rw [Nat.choose_one_right] at h
    exact h
  have m3 : (n, 2) ∈ occ t := mem_occ (by omega) (by omega) rfl
  have m4 : (n, n - 2) ∈ occ t := mem_occ (by omega) (by omega) hsymm
  have hsub : ({(t, 1), (t, t - 1), (n, 2), (n, n - 2)} : Finset (ℕ × ℕ)) ⊆ occ t := by
    intro x hx
    simp only [mem_insert, mem_singleton] at hx
    rcases hx with rfl | rfl | rfl | rfl <;> assumption
  have hcard : ({(t, 1), (t, t - 1), (n, 2), (n, n - 2)} : Finset (ℕ × ℕ)).card = 4 := by
    rw [Finset.card_insert_of_notMem (by simp; omega), Finset.card_insert_of_notMem (by simp; omega),
      Finset.card_insert_of_notMem (by simp; omega), card_singleton]
  calc 4 = ({(t, 1), (t, t - 1), (n, 2), (n, n - 2)} : Finset (ℕ × ℕ)).card := hcard.symm
    _ ≤ mult t := card_le_card hsub

/-- `3003` occupies eight positions in Pascal's triangle:
`C(3003,1)`, `C(3003,3002)`, `C(78,2)`, `C(78,76)`, `C(15,5)`, `C(15,10)`, `C(14,6)`, `C(14,8)`.
It is the smallest number known to occur eight times. -/
theorem eight_le_mult_3003 : 8 ≤ mult 3003 := by
  have c1 : Nat.choose 3003 1 = 3003 := Nat.choose_one_right 3003
  have c2 : Nat.choose 3003 3002 = 3003 := by
    rw [show (3002 : ℕ) = 3003 - 1 by norm_num, Nat.choose_symm (by norm_num),
      Nat.choose_one_right]
  have c3 : Nat.choose 78 2 = 3003 := by rw [Nat.choose_two_right]
  have c4 : Nat.choose 78 76 = 3003 := by
    rw [show (76 : ℕ) = 78 - 2 by norm_num, Nat.choose_symm (by norm_num), Nat.choose_two_right]
  have c5 : Nat.choose 15 5 = 3003 := by norm_num [Nat.choose]
  have c6 : Nat.choose 15 10 = 3003 := by norm_num [Nat.choose]
  have c7 : Nat.choose 14 6 = 3003 := by norm_num [Nat.choose]
  have c8 : Nat.choose 14 8 = 3003 := by norm_num [Nat.choose]
  have hsub : ({(3003, 1), (3003, 3002), (78, 2), (78, 76), (15, 5), (15, 10), (14, 6), (14, 8)} :
      Finset (ℕ × ℕ)) ⊆ occ 3003 := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨mem_occ (by norm_num) (by norm_num) c1, mem_occ (by norm_num) (by norm_num) c2,
      mem_occ (by norm_num) (by norm_num) c3, mem_occ (by norm_num) (by norm_num) c4,
      mem_occ (by norm_num) (by norm_num) c5, mem_occ (by norm_num) (by norm_num) c6,
      mem_occ (by norm_num) (by norm_num) c7, mem_occ (by norm_num) (by norm_num) c8⟩
  have hcard : ({(3003, 1), (3003, 3002), (78, 2), (78, 76), (15, 5), (15, 10), (14, 6), (14, 8)} :
      Finset (ℕ × ℕ)).card = 8 := by decide
  calc 8 = _ := hcard.symm
    _ ≤ mult 3003 := card_le_card hsub

/-! ## Odd primes occur exactly twice -/

/-- If `C(n,k) = p` with `p` prime, then the row index is exactly `p`.
The reason is arithmetic rather than combinatorial: `p ∣ n!`, hence `p ≤ n`, while
`n ≤ C(n,k) = p` for an interior entry. -/
theorem row_eq_of_choose_eq_prime {n k p : ℕ} (hp : p.Prime) (hk : k ≤ n)
    (h : n.choose k = p) : n = p := by
  have hp2 : 2 ≤ p := hp.two_le
  have hle : n ≤ p := row_le_of_choose_eq hp2 hk h
  have hfac : n.choose k * (Nat.factorial k * Nat.factorial (n - k)) = Nat.factorial n := by
    rw [← mul_assoc]
    exact Nat.choose_mul_factorial_mul_factorial hk
  have hdvd : p ∣ Nat.factorial n :=
    ⟨Nat.factorial k * Nat.factorial (n - k), by rw [← hfac, h]⟩
  have := (hp.dvd_factorial).1 hdvd
  omega

/-- **Odd primes occur exactly twice.**  `N(p) = 2` for every odd prime `p`. -/
theorem mult_odd_prime {p : ℕ} (hp : p.Prime) (hodd : p ≠ 2) : mult p = 2 := by
  have hp2 : 2 ≤ p := hp.two_le
  have hp3 : 3 ≤ p := by omega
  have hp5 : p = 3 ∨ 5 ≤ p := by
    rcases Nat.lt_or_ge p 5 with h | h
    · interval_cases p
      · exact Or.inl rfl
      · norm_num at hp
    · exact Or.inr h
  refine le_antisymm ?_ (two_le_mult hp3)
  -- show `occ p ⊆ {(p,1), (p,p-1)}`
  have hsub : occ p ⊆ ({(p, 1), (p, p - 1)} : Finset (ℕ × ℕ)) := by
    rintro ⟨n, k⟩ hx
    rw [mem_occ_iff (by omega)] at hx
    obtain ⟨hk, h⟩ := hx
    have hn : n = p := row_eq_of_choose_eq_prime hp hk h
    rw [hn] at h hk ⊢
    have hk0 : k ≠ 0 := by rintro rfl; simp at h; omega
    have hkn : k ≠ p := by rintro rfl; simp at h; omega
    simp only [mem_insert, mem_singleton, Prod.mk.injEq, true_and]
    by_contra hcon
    push_neg at hcon
    have h2k : 2 ≤ k ∧ k + 2 ≤ p := by
      refine ⟨by omega, ?_⟩
      have hne : k ≠ p - 1 := hcon.2
      omega
    have hbig : p.choose 2 ≤ p.choose k := choose_two_le_choose h2k.1 h2k.2
    rw [Nat.choose_two_right, h] at hbig
    rcases hp5 with h3 | h5
    · rw [h3] at hbig; omega
    · have hgt : p * (p - 1) / 2 > p := by
        have h1 : p * (p - 1) ≥ p * 4 := Nat.mul_le_mul_left p (by omega)
        omega
      omega
  calc mult p ≤ ({(p, 1), (p, p - 1)} : Finset (ℕ × ℕ)).card := card_le_card hsub
    _ ≤ 2 := card_insert_le _ _ |>.trans (by simp)

/-! ## An unconditional logarithmic upper bound

Singmaster's conjecture asserts `N(t) = O(1)`.  Unconditionally we can prove
`N(t) ≤ 2 log₂ t`, by combining column uniqueness with geometric growth. -/

/-- The "folded column index" `min k (n-k)` of a position `(n,k)`. -/
def fold (p : ℕ × ℕ) : ℕ := min p.2 (p.1 - p.2)

@[simp] theorem fold_mk (n k : ℕ) : fold (n, k) = min k (n - k) := rfl

/-- At a position `(n,k)` the value only depends on the folded index. -/
theorem choose_fold {n k : ℕ} (hk : k ≤ n) : n.choose (fold (n, k)) = n.choose k := by
  rw [fold_mk]
  rcases Nat.lt_or_ge (n - k) k with hc | hc
  · rw [show min k (n - k) = n - k by omega, Nat.choose_symm hk]
  · rw [show min k (n - k) = k by omega]

/-- Positions whose folded index is `≤ 1` are the two boundary positions. -/
theorem occ_boundary {t : ℕ} (ht : 2 ≤ t) :
    (occ t).filter (fun p => fold p ≤ 1) ⊆ ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)) := by
  rintro ⟨n, k⟩ hx
  rw [mem_filter, mem_occ_iff ht] at hx
  obtain ⟨⟨hk, h⟩, hfold⟩ := hx
  rw [fold_mk] at hfold
  have hk0 : k ≠ 0 := by rintro rfl; simp at h; omega
  have hkn : k ≠ n := by rintro rfl; simp at h; omega
  have hcase : k = 1 ∨ n - k = 1 := by omega
  simp only [mem_insert, mem_singleton, Prod.mk.injEq]
  rcases hcase with rfl | hnk
  · rw [Nat.choose_one_right] at h
    exact Or.inl ⟨h, rfl⟩
  · have hkk : k = n - 1 := by omega
    subst hkk
    have hs := Nat.choose_symm (n := n) (k := 1) (by omega)
    rw [Nat.choose_one_right] at hs
    rw [hs] at h
    exact Or.inr ⟨h, by omega⟩

/-- The folded index of any occurrence of `t` is at most `log₂ t`. -/
theorem fold_le_log {t n k : ℕ} (ht : 2 ≤ t) (hk : k ≤ n) (h : n.choose k = t) :
    fold (n, k) ≤ Nat.log 2 t := by
  rw [fold_mk]
  have hjhalf : 2 * min k (n - k) ≤ n := by omega
  have hle : n.choose (min k (n - k)) = t := by
    rw [← fold_mk n k, choose_fold hk, h]
  have hpow : 2 ^ min k (n - k) ≤ t := by
    rw [← hle]; exact two_pow_le_choose hjhalf
  exact (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 hpow

/-- Each folded index `b ≥ 2` is attained by at most two positions of `t`. -/
theorem fibre_card_le_two {t : ℕ} (ht : 2 ≤ t) (b : ℕ) (hb : 2 ≤ b) :
    ((occ t).filter (fun p => fold p = b)).card ≤ 2 := by
  classical
  have colval : ∀ p ∈ (occ t).filter (fun p => fold p = b), p.1.choose b = t ∧ b ≤ p.1 := by
    rintro ⟨n, k⟩ hp
    rw [mem_filter, mem_occ_iff ht] at hp
    obtain ⟨⟨hk, hck⟩, hfold⟩ := hp
    have h1 : n.choose b = t := by rw [← hfold, choose_fold hk, hck]
    refine ⟨h1, ?_⟩
    rw [fold_mk] at hfold
    omega
  have key : ∀ p ∈ (occ t).filter (fun p => fold p = b),
      p ∈ ({(p.1, b), (p.1, p.1 - b)} : Finset (ℕ × ℕ)) := by
    rintro ⟨n, k⟩ hp
    have hcp := hp
    rw [mem_filter, mem_occ_iff ht] at hcp
    obtain ⟨⟨hk, _⟩, hfold⟩ := hcp
    rw [fold_mk] at hfold
    simp only [mem_insert, mem_singleton, Prod.mk.injEq, true_and]
    omega
  rcases Finset.eq_empty_or_nonempty ((occ t).filter (fun p => fold p = b)) with hE | ⟨p0, hp0⟩
  · simp [hE]
  · have hsub : (occ t).filter (fun p => fold p = b) ⊆
        ({(p0.1, b), (p0.1, p0.1 - b)} : Finset (ℕ × ℕ)) := by
      intro q hq
      obtain ⟨hq1, hq2⟩ := colval q hq
      obtain ⟨hp1, hp2⟩ := colval p0 hp0
      have hrow : q.1 = p0.1 := row_unique (by omega) hq2 hp2 (by rw [hq1, hp1])
      have hkey := key q hq
      rw [hrow] at hkey
      exact hkey
    exact le_trans (card_le_card hsub) (le_trans (card_insert_le _ _) (by simp))

/-- **Unconditional Singmaster-type bound.**  For every `t ≥ 2`, the number of positions
of `t` in Pascal's triangle is at most `2 log₂ t`.

Singmaster's 1971 conjecture predicts that the right-hand side can be replaced by an
absolute constant; the best bound known in the literature is `O(log t / log log t)`. -/
theorem mult_le_two_mul_log {t : ℕ} (ht : 2 ≤ t) : mult t ≤ 2 * Nat.log 2 t := by
  classical
  set L := Nat.log 2 t with hL
  have hL1 : 1 ≤ L := by
    rw [hL]
    exact (Nat.le_log_iff_pow_le (by norm_num) (by omega)).2 (by simpa using ht)
  set A := (occ t).filter (fun p => fold p ≤ 1) with hA
  set B := (occ t).filter (fun p => ¬ fold p ≤ 1) with hB
  have hsplit : mult t = A.card + B.card := by
    rw [hA, hB, mult]
    exact (Finset.card_filter_add_card_filter_not _).symm
  have hAcard : A.card ≤ 2 :=
    le_trans (card_le_card (occ_boundary ht)) (le_trans (card_insert_le _ _) (by simp))
  have himg : B.image fold ⊆ Finset.Icc 2 L := by
    intro b hb
    rw [mem_image] at hb
    obtain ⟨⟨n, k⟩, hmem, rfl⟩ := hb
    rw [hB, mem_filter, mem_occ_iff ht] at hmem
    obtain ⟨⟨hk, h⟩, hf⟩ := hmem
    rw [Finset.mem_Icc]
    exact ⟨by omega, fold_le_log ht hk h⟩
  have hfib : ∀ b ∈ B.image fold, (B.filter (fun p => fold p = b)).card ≤ 2 := by
    intro b hb
    have hb2 : 2 ≤ b := by
      have hmem := himg hb
      rw [Finset.mem_Icc] at hmem
      exact hmem.1
    refine le_trans (card_le_card ?_) (fibre_card_le_two ht b hb2)
    intro x hx
    rw [mem_filter] at hx ⊢
    rw [hB, mem_filter] at hx
    exact ⟨hx.1.1, hx.2⟩
  have hBcard : B.card ≤ 2 * (B.image fold).card := Finset.card_le_mul_card_image B 2 hfib
  have hIcc : (B.image fold).card ≤ L - 1 := by
    refine le_trans (card_le_card himg) ?_
    rw [Nat.card_Icc]
    omega
  omega

end Singmaster