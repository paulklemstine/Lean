/-
# Exact multiplicities: a certified finite algorithm, and `N(3003) = 8`

Fifth research cycle.  The earlier files bound or reduce the multiplicity function
`N(t) = Singmaster.mult t`; this file turns the structure theory into a *certified
decision procedure* for a single value of `t`, and runs it.

## The algorithm

Every occurrence of `t ≥ 3` is either one of the two boundary occurrences `(t,1)`,
`(t,t-1)`, or an **interior** one, i.e. `C(n,k) = t` with `2 ≤ k ≤ n - 2`.  An interior
occurrence satisfies `C(n,2) ≤ C(n,k) = t` (`Singmaster.choose_two_le_choose`), so its
row is capped by any `N` with `t < C(N,2)`; that is, by roughly `√(2t)`.  Hence

`N(t) = 2 + #{(n,k) : n,k < N, 2 ≤ k ≤ n-2, C(n,k) = t}`,

a search over an explicitly bounded box (`Singmaster.mult_eq_two_add_interior`).  As in
`Combinatorics.SingmasterCentralBinomial` the test `C(n,k) = t` is carried out through
`Nat.descFactorial` (`Singmaster.choose_eq_iff_descFactorial`), which costs `k`
multiplications instead of `C(n,k)` additions and is what makes kernel evaluation
possible.

## Results

* `Singmaster.mult_eq_two_add_interior` — the certified algorithm;
* `Singmaster.mult_eq_two_of_no_interior` — the "only the two trivial occurrences" case;
* `Singmaster.mult_3003` — **`3003` occurs exactly eight times**, upgrading
  `Singmaster.eight_le_mult_3003` from a lower bound to an equality.  This is the
  specimen singled out in Singmaster's problem;
* `Singmaster.mult_120`, `mult_210`, `mult_1540`, `mult_7140`, `mult_11628` — the other
  small numbers of multiplicity six: each occurs **exactly** six times.

Together with `Combinatorics.SingmasterCentralBinomial` this makes every multiplicity
claim in the classical folklore list machine-checked, except for the asymptotic ones.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences

open Finset

namespace Singmaster

/-! ## Binomial coefficients through descending factorials -/

/-- `C(n,k) = t` is equivalent to `n^{\underline{k}} = k! · t`.  This is the form in
which the finite searches below are executed: the descending factorial is a product of
`k` factors, whereas evaluating `Nat.choose` by its defining recursion costs about
`C(n,k)` additions. -/
theorem choose_eq_iff_descFactorial {n k t : ℕ} :
    n.choose k = t ↔ n.descFactorial k = Nat.factorial k * t := by
  constructor
  · rintro rfl
    exact Nat.descFactorial_eq_factorial_mul_choose n k
  · intro h
    rw [Nat.descFactorial_eq_factorial_mul_choose] at h
    exact Nat.eq_of_mul_eq_mul_left (Nat.factorial_pos k) h

/-! ## The interior occurrences -/

/-- The interior occurrences of `t` inside the box `[0,N) × [0,N)`: positions `(n,k)`
with `2 ≤ k ≤ n - 2` and `C(n,k) = t`. -/
def interiorOcc (t N : ℕ) : Finset (ℕ × ℕ) :=
  ((range N) ×ˢ (range N)).filter
    (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.descFactorial p.2 = Nat.factorial p.2 * t)

theorem mem_interiorOcc {t N n k : ℕ} :
    (n, k) ∈ interiorOcc t N ↔ (n < N ∧ k < N) ∧ 2 ≤ k ∧ k + 2 ≤ n ∧ n.choose k = t := by
  simp only [interiorOcc, mem_filter, mem_product, mem_range, choose_eq_iff_descFactorial]

/-! ## The certified algorithm -/

/-- **Exact multiplicity by a bounded search.**  For `t ≥ 3` and any cut-off `N ≥ 2`
whose triangular number already exceeds `t`, the multiplicity of `t` is exactly
`2` (the two boundary occurrences `C(t,1) = C(t,t-1) = t`) plus the number of interior
occurrences in the box `[0,N)²`.

The hypothesis `t < C(N,2)` is what makes the box exhaustive: an interior entry of row
`n` is at least `C(n,2)`, and `n ↦ C(n,2)` is strictly increasing. -/
theorem mult_eq_two_add_interior {t N : ℕ} (ht : 3 ≤ t) (hN2 : 2 ≤ N)
    (hN : t < N.choose 2) : mult t = 2 + (interiorOcc t N).card := by
  classical
  have ht2 : 2 ≤ t := by omega
  have hbnd : ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simp; omega), card_singleton]
  have hdisj : Disjoint ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)) (interiorOcc t N) := by
    rw [Finset.disjoint_left]
    rintro ⟨n, k⟩ h1 h2
    rw [mem_interiorOcc] at h2
    simp only [mem_insert, mem_singleton, Prod.mk.injEq] at h1
    rcases h1 with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;> omega
  have hunion : occ t = ({(t, 1), (t, t - 1)} : Finset (ℕ × ℕ)) ∪ interiorOcc t N := by
    ext ⟨n, k⟩
    constructor
    · intro hp
      rw [mem_occ_iff ht2] at hp
      obtain ⟨hk, hck⟩ := hp
      simp only [mem_union, mem_insert, mem_singleton, Prod.mk.injEq, mem_interiorOcc]
      by_cases hk0 : k = 0
      · subst hk0; rw [Nat.choose_zero_right] at hck; omega
      by_cases hkn : k = n
      · subst hkn; rw [Nat.choose_self] at hck; omega
      by_cases hk1 : k = 1
      · subst hk1; rw [Nat.choose_one_right] at hck; exact Or.inl (Or.inl ⟨hck, rfl⟩)
      by_cases hkn1 : k = n - 1
      · subst hkn1
        have hs := Nat.choose_symm (n := n) (k := 1) (by omega)
        rw [Nat.choose_one_right] at hs
        rw [hs] at hck
        exact Or.inl (Or.inr ⟨hck, by omega⟩)
      have hk2 : 2 ≤ k := by omega
      have hkk : k + 2 ≤ n := by omega
      have hc2 : n.choose 2 ≤ t := by rw [← hck]; exact choose_two_le_choose hk2 hkk
      have hnN : n < N := by
        by_contra hcon
        push_neg at hcon
        have hmono : N.choose 2 ≤ n.choose 2 := by
          rcases eq_or_lt_of_le hcon with heq | hlt
          · rw [heq]
          · exact le_of_lt (choose_lt_choose_left (by norm_num) hN2 hlt)
        omega
      exact Or.inr ⟨⟨hnN, by omega⟩, hk2, hkk, hck⟩
    · intro hp
      rw [mem_union] at hp
      rcases hp with hp | hp
      · simp only [mem_insert, mem_singleton, Prod.mk.injEq] at hp
        rcases hp with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · exact mem_occ ht2 (by omega) (Nat.choose_one_right _)
        · refine mem_occ ht2 (by omega) ?_
          have hs := Nat.choose_symm (n := n) (k := 1) (by omega)
          rw [Nat.choose_one_right] at hs
          exact hs
      · rw [mem_interiorOcc] at hp
        exact mem_occ ht2 (by omega) hp.2.2.2
  rw [mult, hunion, Finset.card_union_of_disjoint hdisj, hbnd]

/-- If a number `t ≥ 3` has no interior occurrence at all, it occurs exactly twice —
the situation of `3, 4, 5` and of every odd prime. -/
theorem mult_eq_two_of_no_interior {t N : ℕ} (ht : 3 ≤ t) (hN2 : 2 ≤ N)
    (hN : t < N.choose 2) (H : interiorOcc t N = ∅) : mult t = 2 := by
  rw [mult_eq_two_add_interior ht hN2 hN, H, card_empty]

/-! ## Running the algorithm

Each of the following is an honest finite search: for `t = 3003` the box is
`79 × 79` and the six interior occurrences found are `(78,2)`, `(78,76)`, `(15,5)`,
`(15,10)`, `(14,6)`, `(14,8)`. -/

set_option maxRecDepth 100000 in
/-- `120 = C(10,3) = C(10,7) = C(16,2) = C(16,14)` occurs exactly six times. -/
theorem mult_120 : mult 120 = 6 := by
  have hc : (interiorOcc 120 17).card = 4 := by decide
  rw [mult_eq_two_add_interior (t := 120) (N := 17) (by norm_num) (by norm_num)
    (by decide), hc]

set_option maxRecDepth 200000 in
/-- `210 = C(10,4) = C(10,6) = C(21,2) = C(21,19)` occurs exactly six times. -/
theorem mult_210 : mult 210 = 6 := by
  have hc : (interiorOcc 210 22).card = 4 := by decide
  rw [mult_eq_two_add_interior (t := 210) (N := 22) (by norm_num) (by norm_num)
    (by decide), hc]

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 1000000 in
/-- `1540 = C(22,3) = C(22,19) = C(56,2) = C(56,54)` occurs exactly six times. -/
theorem mult_1540 : mult 1540 = 6 := by
  have hc : (interiorOcc 1540 57).card = 4 := by decide
  rw [mult_eq_two_add_interior (t := 1540) (N := 57) (by norm_num) (by norm_num)
    (by decide), hc]

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 2000000 in
/-- **`3003` occurs exactly eight times.**  This upgrades
`Singmaster.eight_le_mult_3003` to an equality: the eight positions are `(3003,1)`,
`(3003,3002)`, `(78,2)`, `(78,76)`, `(15,5)`, `(15,10)`, `(14,6)`, `(14,8)`.
`3003` is the only number known to occur eight times. -/
theorem mult_3003 : mult 3003 = 8 := by
  have hc : (interiorOcc 3003 79).card = 6 := by decide
  rw [mult_eq_two_add_interior (t := 3003) (N := 79) (by norm_num) (by norm_num)
    (by decide), hc]

set_option maxHeartbeats 1000000 in
set_option maxRecDepth 2000000 in
/-- `7140 = C(36,3) = C(36,33) = C(120,2) = C(120,118)` occurs exactly six times. -/
theorem mult_7140 : mult 7140 = 6 := by
  have hc : (interiorOcc 7140 121).card = 4 := by decide
  rw [mult_eq_two_add_interior (t := 7140) (N := 121) (by norm_num) (by norm_num)
    (by decide), hc]

set_option maxHeartbeats 2000000 in
set_option maxRecDepth 3000000 in
/-- `11628 = C(19,5) = C(19,14) = C(153,2) = C(153,151)` occurs exactly six times. -/
theorem mult_11628 : mult 11628 = 6 := by
  have hc : (interiorOcc 11628 154).card = 4 := by decide
  rw [mult_eq_two_add_interior (t := 11628) (N := 154) (by norm_num) (by norm_num)
    (by decide), hc]

/-- **Some number occurs exactly eight times**, and some numbers occur exactly six
times: the multiplicity spectrum of Pascal's triangle contains `6` and `8`.  Contrast
`Combinatorics.SingmasterCentralBinomial.mult_ne_five_or_seven_of_lt`, which shows that
`5` and `7` are *absent* from the spectrum below `705432`. -/
theorem six_and_eight_are_attained :
    (∃ t, 2 ≤ t ∧ mult t = 6) ∧ (∃ t, 2 ≤ t ∧ mult t = 8) :=
  ⟨⟨120, by norm_num, mult_120⟩, ⟨3003, by norm_num, mult_3003⟩⟩

end Singmaster