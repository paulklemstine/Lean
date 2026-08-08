/-
# Refinements of the Singmaster occurrence theory

Second research cycle on top of `Combinatorics.SingmasterOccurrences` and
`Combinatorics.SingmasterFibonacci`.

* **Strict unimodality of a row** (`Singmaster.choose_lt_choose_right`): the left half
  of a Pascal row is strictly increasing.  This is the sharpest possible local
  statement, and it upgrades the "at most two positions per folded column" estimate of
  the first file into an exact *row* statement.
* **At most two entries per row** (`Singmaster.row_solutions_le_two`): for any value
  `t` and any row `n`, at most two entries of row `n` are equal to `t`.  Consequently a
  value of multiplicity `N` must be spread over at least `⌈N/2⌉` different rows
  (`Singmaster.two_mul_rows_card`).
* **`2` is the unique number of multiplicity one** (`Singmaster.mult_eq_one_iff`).
* **Central binomial coefficients occur at least three times**
  (`Singmaster.three_le_mult_centralBinom`), the pattern behind "6 occurs three times".
* **The six-fold values form an infinite set** (`Singmaster.setOf_six_infinite`),
  the set-theoretic form of the Fibonacci construction.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterFibonacci

open Finset

namespace Singmaster

/-! ## Strict unimodality of a Pascal row -/

/-- One step of strict increase in the left half of a row. -/
theorem choose_lt_choose_succ_right {n k : ℕ} (h : 2 * (k + 1) ≤ n) :
    n.choose k < n.choose (k + 1) := by
  have e := Nat.choose_succ_right_eq n k
  have hpos : 0 < n.choose k := Nat.choose_pos (by omega)
  have h1 : n.choose k * (k + 1) < n.choose k * (n - k) :=
    Nat.mul_lt_mul_of_pos_left (by omega) hpos
  have h2 : n.choose k * (k + 1) < n.choose (k + 1) * (k + 1) := by omega
  exact Nat.lt_of_mul_lt_mul_right h2

/-- **Strict unimodality.**  On the left half of row `n`, the entries strictly increase. -/
theorem choose_lt_choose_right {n j j' : ℕ} (hjj : j < j') (h : 2 * j' ≤ n) :
    n.choose j < n.choose j' := by
  induction j' with
  | zero => omega
  | succ p ih =>
    rcases Nat.lt_or_ge j p with hp | hp
    · exact lt_trans (ih hp (by omega)) (choose_lt_choose_succ_right (by omega))
    · have hjp : j = p := by omega
      subst hjp
      exact choose_lt_choose_succ_right (by omega)

/-- Injectivity of a row on its left half. -/
theorem fold_unique {n j j' : ℕ} (hj : 2 * j ≤ n) (hj' : 2 * j' ≤ n)
    (h : n.choose j = n.choose j') : j = j' := by
  rcases lt_trichotomy j j' with hlt | heq | hgt
  · exact absurd h (Nat.ne_of_lt (choose_lt_choose_right hlt hj'))
  · exact heq
  · exact absurd h.symm (Nat.ne_of_lt (choose_lt_choose_right hgt hj))

/-! ## At most two entries per row -/

/-- The set of columns of row `n` carrying the value `t`. -/
def rowOcc (n t : ℕ) : Finset ℕ := (range (n + 1)).filter (fun k => n.choose k = t)

theorem mem_rowOcc {n t k : ℕ} : k ∈ rowOcc n t ↔ k ≤ n ∧ n.choose k = t := by
  simp only [rowOcc, mem_filter, mem_range]
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨by omega, h2⟩
  · rintro ⟨h1, h2⟩; exact ⟨by omega, h2⟩

/-- **A value occurs at most twice in a single row.**  This strengthens
`Singmaster.fibre_card_le_two`, which only bounded the positions sharing a folded
column index, and it needs no hypothesis on `t`. -/
theorem row_solutions_le_two (n t : ℕ) : (rowOcc n t).card ≤ 2 := by
  classical
  rcases Finset.eq_empty_or_nonempty (rowOcc n t) with hE | ⟨k0, hk0⟩
  · simp [hE]
  · rw [mem_rowOcc] at hk0
    obtain ⟨hk0n, hk0t⟩ := hk0
    set j0 := min k0 (n - k0) with hj0
    have hj0half : 2 * j0 ≤ n := by omega
    have hj0t : n.choose j0 = t := by
      rw [← hk0t, hj0, ← fold_mk n k0, choose_fold hk0n]
    have hsub : rowOcc n t ⊆ ({j0, n - j0} : Finset ℕ) := by
      intro k hk
      rw [mem_rowOcc] at hk
      obtain ⟨hkn, hkt⟩ := hk
      set j := min k (n - k) with hj
      have hjhalf : 2 * j ≤ n := by omega
      have hjt : n.choose j = t := by
        rw [← hkt, hj, ← fold_mk n k, choose_fold hkn]
      have : j = j0 := fold_unique hjhalf hj0half (by rw [hjt, hj0t])
      simp only [mem_insert, mem_singleton]
      omega
    exact le_trans (card_le_card hsub) (le_trans (card_insert_le _ _) (by simp))

/-- The rows in which `t` occurs. -/
def rowsOf (t : ℕ) : Finset ℕ := (occ t).image Prod.fst

/-- **A value of high multiplicity must be spread over many rows.**  Since each row
contributes at most two positions, `N(t) ≤ 2 · #rows`. -/
theorem two_mul_rows_card {t : ℕ} (ht : 2 ≤ t) : mult t ≤ 2 * (rowsOf t).card := by
  classical
  refine Finset.card_le_mul_card_image (occ t) 2 ?_
  intro n _
  have hsub : ((occ t).filter (fun p => p.1 = n)).card ≤ (rowOcc n t).card := by
    refine Finset.card_le_card_of_injOn Prod.snd ?_ ?_
    · rintro ⟨m, k⟩ hp
      simp only [Finset.mem_coe, mem_filter] at hp
      obtain ⟨hmem, hm⟩ := hp
      rw [mem_occ_iff ht] at hmem
      subst hm
      simp only [Finset.mem_coe, mem_rowOcc]
      exact hmem
    · rintro ⟨m, k⟩ hp ⟨m', k'⟩ hp' hkk
      simp only [Finset.mem_coe, mem_filter] at hp hp'
      rw [Prod.mk.injEq]
      exact ⟨hp.2.trans hp'.2.symm, hkk⟩
  exact le_trans hsub (row_solutions_le_two n t)

/-! ## `2` is the unique number of multiplicity one -/

/-- Apart from `1`, the number `2` is the only entry of Pascal's triangle that occurs
exactly once. -/
theorem mult_eq_one_iff {t : ℕ} (ht : 2 ≤ t) : mult t = 1 ↔ t = 2 := by
  constructor
  · intro h
    by_contra hne
    have h3 : 3 ≤ t := by omega
    have := two_le_mult h3
    omega
  · rintro rfl
    exact mult_two

/-! ## Central binomial coefficients occur at least three times -/

/-- **Central binomial coefficients occur at least three times.**  The value
`t = C(2m,m)` sits at `(t,1)`, `(t,t-1)` and at the single central position `(2m,m)`.
The case `m = 2` is `6 = C(6,1) = C(6,5) = C(4,2)`, whose multiplicity is exactly `3`
by `Singmaster.mult_six`. -/
theorem three_le_mult_centralBinom {m : ℕ} (hm : 2 ≤ m) : 3 ≤ mult ((2 * m).choose m) := by
  set n := 2 * m with hn
  set t := n.choose m with hT
  have hn4 : 4 ≤ n := by omega
  have hn2 : n.choose 2 ≤ t := choose_two_le_choose (by omega) (by omega)
  have hnt : n < t := by
    have h1 : n * 3 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
    have h2 : n.choose 2 = n * (n - 1) / 2 := Nat.choose_two_right n
    omega
  have m1 : (t, 1) ∈ occ t := mem_occ (by omega) (by omega) (Nat.choose_one_right t)
  have m2 : (t, t - 1) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have h := Nat.choose_symm (n := t) (k := 1) (by omega)
    rw [Nat.choose_one_right] at h
    exact h
  have m3 : (n, m) ∈ occ t := mem_occ (by omega) (by omega) rfl
  have hsub : ({(t, 1), (t, t - 1), (n, m)} : Finset (ℕ × ℕ)) ⊆ occ t := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨m1, m2, m3⟩
  have hcard : ({(t, 1), (t, t - 1), (n, m)} : Finset (ℕ × ℕ)).card = 3 := by
    rw [Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_singleton]
  calc 3 = _ := hcard.symm
    _ ≤ mult t := card_le_card hsub

/-! ## The six-fold values form an infinite set -/

/-- **Set-theoretic form of the Fibonacci construction.** -/
theorem setOf_six_infinite : {t : ℕ | 6 ≤ mult t}.Infinite := by
  refine Set.infinite_of_forall_exists_gt ?_
  intro a
  obtain ⟨t, hta, hmt⟩ := infinitely_many_six a
  exact ⟨t, hmt, hta⟩

/-- The four-fold values also form an infinite set (triangular numbers). -/
theorem setOf_four_infinite : {t : ℕ | 4 ≤ mult t}.Infinite := by
  refine Set.infinite_of_forall_exists_gt ?_
  intro a
  refine ⟨(a + 5).choose 2, four_le_mult_choose_two (by omega), ?_⟩
  have h1 : a + 5 ≤ (a + 5).choose 2 := row_le_choose (by omega) (by omega)
  have h2 : (a + 5).choose 2 = (a + 5) * (a + 5 - 1) / 2 := Nat.choose_two_right _
  omega

end Singmaster