/-
# Almost every integer occurs exactly twice in Pascal's triangle

Singmaster's conjecture says the multiplicity function is *bounded*.  Far short of that,
one can ask how *often* the multiplicity exceeds the trivial value `2`.  This file proves
an explicit, completely effective answer: the number of `n ≤ x` occurring three or more
times is at most `(⌊√(2x)⌋ + 2)(⌊log₂ x⌋ + 2)`, i.e. `O(√x log x)`.

The proof combines two independent squeezes on an interior occurrence `C(N,k) = n ≤ x`
with `2 ≤ k` and `2k ≤ N`:

* a **row squeeze** — `N(N-1) ≤ 2n ≤ 2x`, so `N ≤ √(2x) + 1`  (combinatorial unimodality);
* a **column squeeze** — `2^k ≤ C(2k,k) ≤ C(N,k) = n ≤ x`, so `k ≤ log₂ x`
  (`Singmaster.two_pow_le_centralBinom`).

Assigning to each such `n` one interior occurrence gives an injection into a rectangle of
size `(√(2x)+2)(log₂ x + 2)`.

Main results:
* `Singmaster.two_pow_le_centralBinom`
* `Singmaster.card_three_le_mult_le` — the `O(√x log x)` counting bound;
* `Singmaster.card_mult_ne_two_le` — "almost all integers occur exactly twice".
-/
import NumberTheory.SingmasterCore

namespace Singmaster

open Finset

/-! ## The column squeeze -/

/-- `2^k ≤ C(2k,k)`. -/
theorem two_pow_le_centralBinom (k : ℕ) : 2 ^ k ≤ Nat.centralBinom k := by
  induction k with
  | zero => decide
  | succ m ih =>
    have h := Nat.succ_mul_centralBinom_succ m
    have hstep : 2 * Nat.centralBinom m ≤ Nat.centralBinom (m + 1) := by
      refine Nat.le_of_mul_le_mul_left ?_ (show 0 < m + 1 by omega)
      rw [h]
      nlinarith [Nat.centralBinom_pos m]
    calc 2 ^ (m + 1) = 2 * 2 ^ m := by ring
      _ ≤ 2 * Nat.centralBinom m := by omega
      _ ≤ Nat.centralBinom (m + 1) := hstep

/-! ## A canonical interior occurrence left of the centre -/

/-- Interior occurrences in the left half of the triangle. -/
def halfInterior (n : ℕ) : Finset (ℕ × ℕ) := (interiorOcc n).filter (fun p => 2 * p.2 ≤ p.1)

theorem halfInterior_nonempty {n : ℕ} (hn : 2 ≤ n) (h : (interiorOcc n).Nonempty) :
    (halfInterior n).Nonempty := by
  obtain ⟨⟨N, k⟩, hmem⟩ := h
  rw [mem_interiorOcc hn] at hmem
  obtain ⟨h2, h3, hc⟩ := hmem
  rcases Nat.lt_or_ge N (2 * k) with hk | hk
  · refine ⟨(N, N - k), ?_⟩
    simp only [halfInterior, Finset.mem_filter, mem_interiorOcc hn]
    refine ⟨⟨by omega, by omega, ?_⟩, by omega⟩
    rw [Nat.choose_symm (by omega : k ≤ N)]
    exact hc
  · refine ⟨(N, k), ?_⟩
    simp only [halfInterior, Finset.mem_filter, mem_interiorOcc hn]
    exact ⟨⟨h2, h3, hc⟩, hk⟩

theorem mem_interiorOcc' {n : ℕ} (hn : 2 ≤ n) {p : ℕ × ℕ} :
    p ∈ interiorOcc n ↔ 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = n := by
  obtain ⟨N, k⟩ := p
  exact mem_interiorOcc hn

/-- A choice of one interior occurrence left of the centre. -/
noncomputable def canon (n : ℕ) : ℕ × ℕ :=
  if h : (halfInterior n).Nonempty then h.choose else (0, 0)

theorem canon_mem {n : ℕ} (h : (halfInterior n).Nonempty) : canon n ∈ halfInterior n := by
  rw [canon, dif_pos h]
  exact h.choose_spec

theorem canon_spec {n : ℕ} (hn : 3 ≤ n) (hmult : 3 ≤ mult n) :
    2 ≤ (canon n).2 ∧ (canon n).2 + 2 ≤ (canon n).1 ∧ 2 * (canon n).2 ≤ (canon n).1 ∧
      (canon n).1.choose (canon n).2 = n := by
  have hne : (interiorOcc n).Nonempty := by
    rw [← Finset.card_pos]
    have := mult_eq_two_add_interior hn
    omega
  have hmem := canon_mem (halfInterior_nonempty (by omega) hne)
  simp only [halfInterior, Finset.mem_filter, mem_interiorOcc' (by omega : 2 ≤ n)] at hmem
  exact ⟨hmem.1.1, hmem.1.2.1, hmem.2, hmem.1.2.2⟩

/-! ## The counting bound -/

/-- **Almost all integers occur exactly twice.** The number of `n` in `[3, x]` occurring at
least three times in Pascal's triangle is `O(√x · log x)`, with the explicit constant
below. -/
theorem card_three_le_mult_le (x : ℕ) :
    ((Finset.Icc 3 x).filter (fun n => 3 ≤ mult n)).card
      ≤ (Nat.sqrt (2 * x) + 2) * (Nat.log 2 x + 2) := by
  classical
  have hcard : ((range (Nat.sqrt (2 * x) + 2)) ×ˢ (range (Nat.log 2 x + 2))).card
      = (Nat.sqrt (2 * x) + 2) * (Nat.log 2 x + 2) := by
    rw [Finset.card_product, Finset.card_range, Finset.card_range]
  rw [← hcard]
  refine Finset.card_le_card_of_injOn canon ?_ ?_
  · intro n hn
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc] at hn
    obtain ⟨⟨hn3, hnx⟩, hmult⟩ := hn
    obtain ⟨h2, h3, hhalf, hc⟩ := canon_spec hn3 hmult
    have hrow : (canon n).1 * ((canon n).1 - 1) ≤ 2 * n :=
      mul_pred_le_of_choose_eq h2 (by omega) hc
    have hN : (canon n).1 < Nat.sqrt (2 * x) + 2 := by
      by_contra hcon
      push_neg at hcon
      have hs := Nat.lt_succ_sqrt (2 * x)
      have : (Nat.sqrt (2 * x) + 2) * (Nat.sqrt (2 * x) + 1) ≤ (canon n).1 * ((canon n).1 - 1) :=
        Nat.mul_le_mul hcon (by omega)
      nlinarith
    have hk : (canon n).2 < Nat.log 2 x + 2 := by
      have h1 : Nat.centralBinom (canon n).2 ≤ (canon n).1.choose (canon n).2 :=
        Nat.choose_le_choose _ hhalf
      have h2' : 2 ^ (canon n).2 ≤ x := by
        have := two_pow_le_centralBinom (canon n).2
        omega
      have := (Nat.le_log_iff_pow_le (b := 2) (by omega) (show x ≠ 0 by omega)).mpr h2'
      omega
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_range]
    exact ⟨hN, hk⟩
  · intro n hn m hm hnm
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc] at hn hm
    obtain ⟨⟨hn3, -⟩, hmultn⟩ := hn
    obtain ⟨⟨hm3, -⟩, hmultm⟩ := hm
    obtain ⟨-, -, -, hcn⟩ := canon_spec hn3 hmultn
    obtain ⟨-, -, -, hcm⟩ := canon_spec hm3 hmultm
    rw [← hcn, ← hcm, hnm]

/-- Restated: the set of `n ≤ x` whose multiplicity is not the generic value `2` has size
`O(√x log x)`. -/
theorem card_mult_ne_two_le (x : ℕ) :
    ((range (x + 1)).filter (fun n => mult n ≠ 2)).card
      ≤ (Nat.sqrt (2 * x) + 2) * (Nat.log 2 x + 2) + 3 := by
  classical
  have hsub : (range (x + 1)).filter (fun n => mult n ≠ 2)
      ⊆ ({0, 1, 2} : Finset ℕ) ∪ (Finset.Icc 3 x).filter (fun n => 3 ≤ mult n) := by
    intro n hn
    simp only [Finset.mem_filter, Finset.mem_range] at hn
    obtain ⟨hnx, hmult⟩ := hn
    rcases Nat.lt_or_ge n 3 with h | h
    · simp only [Finset.mem_union, Finset.mem_insert, Finset.mem_singleton]
      left; omega
    · have := mult_eq_two_add_interior h
      simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_Icc]
      right
      exact ⟨⟨h, by omega⟩, by omega⟩
  calc ((range (x + 1)).filter (fun n => mult n ≠ 2)).card
      ≤ (({0, 1, 2} : Finset ℕ) ∪ (Finset.Icc 3 x).filter (fun n => 3 ≤ mult n)).card :=
        Finset.card_le_card hsub
    _ ≤ ({0, 1, 2} : Finset ℕ).card + ((Finset.Icc 3 x).filter (fun n => 3 ≤ mult n)).card :=
        Finset.card_union_le _ _
    _ ≤ 3 + (Nat.sqrt (2 * x) + 2) * (Nat.log 2 x + 2) := by
        have := card_three_le_mult_le x
        have h3 : ({0, 1, 2} : Finset ℕ).card = 3 := by decide
        omega
    _ = (Nat.sqrt (2 * x) + 2) * (Nat.log 2 x + 2) + 3 := by ring

end Singmaster