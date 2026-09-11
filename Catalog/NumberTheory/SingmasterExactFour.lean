/-
# Exact multiplicity four, and the small Singmaster spectrum

The obstruction `Singmaster.mult_eq_two_of_large_prime_factor` shows that a *strictly*
dominant prime factor kills all interior occurrences.  The interesting boundary case is
`p(p-1) = 2n`, i.e. `n = C(p,2)` for a prime `p`.  There the prime obstruction pins the
row down to `N = p` exactly, and a one-step unimodality estimate then pins the column to
`k ∈ {2, p-2}`.  The outcome is an *exact* multiplicity computation for an infinite
family:

* `Singmaster.mult_choose_two_prime` — `mult (C(p,2)) = 4` for every prime `p ≥ 5`.
* `Singmaster.infinite_mult_eq_four` — hence the value `4` is attained infinitely often.

Together with the earlier files this determines a concrete initial segment of the
Singmaster spectrum: `Singmaster.mult_attains` exhibits the values
`0, 1, 2, 3, 4, 6, 8`, while `Singmaster.mult_ne_five_or_seven_of_lt` shows that `5`
and `7` are *not* attained below `3003`.
-/
import NumberTheory.SingmasterSmallValues

set_option maxRecDepth 100000

namespace Singmaster

open Finset

/-! ## `C(p,2)` for a prime `p` -/

theorem prime_dvd_choose_two {p : ℕ} (hp : p.Prime) (h5 : 5 ≤ p) : p ∣ p.choose 2 := by
  obtain ⟨m, hm⟩ := hp.odd_of_ne_two (by omega)
  refine ⟨m, ?_⟩
  have h2 := two_mul_choose_two p
  have hp1 : p - 1 = 2 * m := by omega
  have hlink : p * (p - 1) = 2 * (p * m) := by rw [hp1]; ring
  omega

theorem three_le_choose_two {p : ℕ} (h5 : 5 ≤ p) : 3 ≤ p.choose 2 := by
  have h2 := two_mul_choose_two p
  have : 5 * 4 ≤ p * (p - 1) := Nat.mul_le_mul (by omega) (by omega)
  omega

/-- Strict unimodality at the second column: for `p ≥ 7`, `C(p,2) < C(p,3)`. -/
theorem choose_two_lt_choose_three {p : ℕ} (h7 : 7 ≤ p) : p.choose 2 < p.choose 3 := by
  have h := Nat.choose_succ_right_eq p 2
  have hpos : 0 < p.choose 2 := Nat.choose_pos (by omega)
  have h5 : 5 ≤ p - 2 := by omega
  nlinarith

/-- The interior occurrences of `C(p,2)` are exactly the two positions in row `p`. -/
theorem interiorOcc_choose_two_prime {p : ℕ} (hp : p.Prime) (h5 : 5 ≤ p) :
    interiorOcc (p.choose 2) = {(p, 2), (p, p - 2)} := by
  have hn3 : 3 ≤ p.choose 2 := three_le_choose_two h5
  have hn2 : 2 ≤ p.choose 2 := by omega
  have hchoose2 := two_mul_choose_two p
  ext q
  obtain ⟨N, k⟩ := q
  simp only [mem_interiorOcc hn2, Finset.mem_insert, Finset.mem_singleton, Prod.mk.injEq]
  constructor
  · rintro ⟨h2, h3, hc⟩
    -- the row is forced to be `p`
    have hpN : p ≤ N := prime_le_of_dvd_choose (N := N) (k := k) hp (by omega)
      (by rw [hc]; exact prime_dvd_choose_two hp h5)
    have hrow : N * (N - 1) ≤ 2 * p.choose 2 := mul_pred_le_of_choose_eq h2 (by omega) hc
    have hNp : N = p := by
      by_contra hne
      have hlt : p < N := by omega
      have : p * (p - 1) < N * (N - 1) :=
        Nat.mul_lt_mul_of_lt_of_le hlt (by omega) (by omega)
      omega
    subst hNp
    -- the column is forced to be `2` or `N-2`
    have hN6 : N ≠ 6 := by
      intro h; rw [h] at hp; exact absurd hp (by decide)
    have hk : k = 2 ∨ k = N - 2 := by
      by_contra hcon
      push_neg at hcon
      obtain ⟨hka, hkb⟩ := hcon
      have hk3 : 3 ≤ k := by omega
      have hk3' : k + 3 ≤ N := by omega
      have h7 : 7 ≤ N := by omega
      have hmono := choose_le_choose_left (N := N) (j := 3) (k := k) hk3 (by omega)
      have hlt := choose_two_lt_choose_three h7
      omega
    rcases hk with rfl | rfl
    · exact Or.inl ⟨rfl, rfl⟩
    · exact Or.inr ⟨rfl, rfl⟩
  · have hsym : p.choose (p - 2) = p.choose 2 := Nat.choose_symm (by omega)
    rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨by omega, by omega, rfl⟩
    · exact ⟨by omega, by omega, hsym⟩

/-- **Exact multiplicity four.** For every prime `p ≥ 5`, the triangular number
`C(p,2) = p(p-1)/2` occurs exactly four times in Pascal's triangle. -/
theorem mult_choose_two_prime {p : ℕ} (hp : p.Prime) (h5 : 5 ≤ p) : mult (p.choose 2) = 4 := by
  have hn3 : 3 ≤ p.choose 2 := three_le_choose_two h5
  rw [mult_eq_two_add_interior hn3, interiorOcc_choose_two_prime hp h5]
  rw [Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega), Finset.card_singleton]

/-- **The value `4` is attained infinitely often.** -/
theorem infinite_mult_eq_four : {n : ℕ | mult n = 4}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨B, hB⟩
  obtain ⟨p, hpB, hp⟩ := Nat.exists_infinite_primes (max (B + 1) 5)
  have h5 : 5 ≤ p := le_trans (le_max_right _ _) hpB
  have hB1 : B + 1 ≤ p := le_trans (le_max_left _ _) hpB
  have hmem : p.choose 2 ∈ {n : ℕ | mult n = 4} := mult_choose_two_prime hp h5
  have hle := hB hmem
  have hp2 : p ≤ p.choose 2 := self_le_choose (by omega) (by omega)
  omega

/-! ## The initial segment of the spectrum -/

theorem mult_21 : mult 21 = 4 := by
  have h : (21 : ℕ) = Nat.choose 7 2 := by decide
  rw [h]
  exact mult_choose_two_prime (by decide) (by omega)

theorem mult_120 : mult 120 = 6 := by
  have hcount : (((range 17) ×ˢ (range 17)).filter
      (fun q => 2 ≤ q.2 ∧ q.2 + 2 ≤ q.1 ∧ q.1.choose q.2 = 120)).card = 4 := by decide
  rw [mult_eq_two_add_count (n := 120) (b := 17) (by norm_num) (by norm_num), hcount]

/-- The values `0, 1, 2, 3, 4, 6, 8` all occur as Singmaster multiplicities. -/
theorem mult_attains :
    mult 0 = 0 ∧ mult 2 = 1 ∧ mult 5 = 2 ∧ mult 6 = 3 ∧ mult 21 = 4 ∧ mult 120 = 6 ∧
      mult 3003 = 8 :=
  ⟨by decide, by decide, mult_prime (by decide) (by omega), mult_6, mult_21, mult_120, mult_3003⟩

end Singmaster