/-
# Ideal Prouhet–Tarry–Escott solutions of small degree, and the exact value of `m(N, K)`
for `K ≤ 5`

`Probability.PowerSumMinimalCollision` defines the minimal collision size
`m(N, K) = minCollisionCard N K` and shows `K < m(N, K) ≤ 2^K` on the non-rigid range
`K < N` (the upper bound in `Probability.PowerSumProuhet`).  It also computes `m(N, K)` on the
PTE floor `K + 1` for `K ≤ 3`, but the degree-`3` statement there needs the wide alphabet
`N ≥ 11`, because the witness used is the classical *set* solution `{0,4,7,11}` versus
`{1,2,9,10}`.

Allowing genuine **multisets** (repeated entries) makes much narrower ideal solutions
available.  An exhaustive kernel search (recorded in `ComputationalEvidence.md`) gives the
minimal alphabets
`d(3) = 7`, `d(4) = 18`, `d(5) = 16`,
with witnesses

* degree `3`: `{1,1,6,6}` versus `{0,3,4,7}`;
* degree `4`: `{0,4,8,16,17}` versus `{1,2,10,14,18}`;
* degree `5`: `{0,3,5,11,13,16}` versus `{1,1,8,8,15,15}`.

Formalising these gives the exact values

  `m(N,3) = 4` for `N ≥ 7`, `m(N,4) = 5` for `N ≥ 18`, `m(N,5) = 6` for `N ≥ 16`,

so the Prouhet–Tarry–Escott floor `K + 1` of `PowerSumMinCollision.lt_minCollisionCard` is
attained for every degree `K ≤ 5` (`pte_floor_attained_of_le_five`).  Two intermediate
witnesses, `{1,1,1,4,4,4}` versus `{0,2,2,3,3,5}` (degree `3`, alphabet `5`) and
`{1,1,1,5,6,6,8}` versus `{0,2,2,3,7,7,7}` (degree `4`, alphabet `8`), show that the invariant
already drops well below the Prouhet value `2^K` long before the floor is reached.
-/
import Mathlib
import Probability.PowerSumSharpness
import Probability.PowerSumNewtonThreshold
import Probability.PowerSumMinimalCollision
import Probability.PowerSumProuhet

namespace PowerSumIdealPTE

open PowerSumMinCollision

/-! ## 1. Transfer lemmas from an explicit witness -/

/-- An explicit collision of size `K + 1` inside the alphabet `{0, …, D}` pins the invariant
down to the Prouhet–Tarry–Escott floor for every alphabet at least as wide. -/
theorem minCollisionCard_eq_of_ideal_witness {D K N : ℕ} {s t : Multiset ℕ}
    (hD : K < D) (hN : D ≤ N) (hs : ∀ x ∈ s, x ≤ D) (ht : ∀ x ∈ t, x ≤ D)
    (hagree : ∀ k ≤ K, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum)
    (hne : s ≠ t) (hcard : Multiset.card s = K + 1) :
    minCollisionCard N K = K + 1 := by
  refine le_antisymm (minCollisionCard_le
    ⟨fun x hx => le_trans (hs x hx) hN, fun x hx => le_trans (ht x hx) hN, hagree, hne⟩ hcard) ?_
  have := lt_minCollisionCard (N := N) (K := K) (by omega)
  omega

/-- An explicit collision of size `n` inside the alphabet `{0, …, D}` bounds the invariant by
`n` for every alphabet at least as wide. -/
theorem minCollisionCard_le_of_witness {D K N n : ℕ} {s t : Multiset ℕ}
    (hN : D ≤ N) (hs : ∀ x ∈ s, x ≤ D) (ht : ∀ x ∈ t, x ≤ D)
    (hagree : ∀ k ≤ K, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum)
    (hne : s ≠ t) (hcard : Multiset.card s = n) :
    minCollisionCard N K ≤ n :=
  minCollisionCard_le
    ⟨fun x hx => le_trans (hs x hx) hN, fun x hx => le_trans (ht x hx) hN, hagree, hne⟩ hcard

/-! ## 2. The narrow ideal solutions -/

/-- **A degree-`3` ideal PTE solution of diameter `7`.**  `{1,1,6,6}` and `{0,3,4,7}` agree in
all power sums of order `k ≤ 3` (`4`, `14`, `74`, `434`) and differ at `k = 4`
(`2594` versus `2498`).  This is much narrower than the classical set solution
`{0,4,7,11}`/`{1,2,9,10}` of `PowerSumNewton.ideal_pte_degree_three`, because repeated entries
are allowed. -/
theorem ideal_pte_three_narrow :
    (∀ x ∈ ({1, 1, 6, 6} : Multiset ℕ), x ≤ 7) ∧ (∀ x ∈ ({0, 3, 4, 7} : Multiset ℕ), x ≤ 7) ∧
    (∀ k ≤ 3, (({1, 1, 6, 6} : Multiset ℕ).map (fun x => x ^ k)).sum
      = (({0, 3, 4, 7} : Multiset ℕ).map (fun x => x ^ k)).sum) ∧
    (({1, 1, 6, 6} : Multiset ℕ).map (fun x => x ^ 4)).sum
      ≠ (({0, 3, 4, 7} : Multiset ℕ).map (fun x => x ^ 4)).sum ∧
    Multiset.card ({1, 1, 6, 6} : Multiset ℕ) = 4 ∧
    ({1, 1, 6, 6} : Multiset ℕ) ≠ ({0, 3, 4, 7} : Multiset ℕ) := by
  refine ⟨by decide, by decide, ?_, by decide, by decide, by decide⟩
  intro k hk
  interval_cases k <;> decide

/-- **A degree-`4` ideal PTE solution of diameter `18`.**  `{0,4,8,16,17}` and `{1,2,10,14,18}`
have five elements and agree in all power sums of order `k ≤ 4`, while differing at `k = 5`. -/
theorem ideal_pte_four :
    (∀ x ∈ ({0, 4, 8, 16, 17} : Multiset ℕ), x ≤ 18) ∧
    (∀ x ∈ ({1, 2, 10, 14, 18} : Multiset ℕ), x ≤ 18) ∧
    (∀ k ≤ 4, (({0, 4, 8, 16, 17} : Multiset ℕ).map (fun x => x ^ k)).sum
      = (({1, 2, 10, 14, 18} : Multiset ℕ).map (fun x => x ^ k)).sum) ∧
    (({0, 4, 8, 16, 17} : Multiset ℕ).map (fun x => x ^ 5)).sum
      ≠ (({1, 2, 10, 14, 18} : Multiset ℕ).map (fun x => x ^ 5)).sum ∧
    Multiset.card ({0, 4, 8, 16, 17} : Multiset ℕ) = 5 ∧
    ({0, 4, 8, 16, 17} : Multiset ℕ) ≠ ({1, 2, 10, 14, 18} : Multiset ℕ) := by
  refine ⟨by decide, by decide, ?_, by decide, by decide, by decide⟩
  intro k hk
  interval_cases k <;> decide

/-- **A degree-`5` ideal PTE solution of diameter `16`.**  `{0,3,5,11,13,16}` and
`{1,1,8,8,15,15}` have six elements and agree in all power sums of order `k ≤ 5`, while
differing at `k = 6`.  Note that it is *narrower* than the degree-`4` optimum: the minimal
alphabet `d(K)` is not monotone in `K`. -/
theorem ideal_pte_five :
    (∀ x ∈ ({0, 3, 5, 11, 13, 16} : Multiset ℕ), x ≤ 16) ∧
    (∀ x ∈ ({1, 1, 8, 8, 15, 15} : Multiset ℕ), x ≤ 16) ∧
    (∀ k ≤ 5, (({0, 3, 5, 11, 13, 16} : Multiset ℕ).map (fun x => x ^ k)).sum
      = (({1, 1, 8, 8, 15, 15} : Multiset ℕ).map (fun x => x ^ k)).sum) ∧
    (({0, 3, 5, 11, 13, 16} : Multiset ℕ).map (fun x => x ^ 6)).sum
      ≠ (({1, 1, 8, 8, 15, 15} : Multiset ℕ).map (fun x => x ^ 6)).sum ∧
    Multiset.card ({0, 3, 5, 11, 13, 16} : Multiset ℕ) = 6 ∧
    ({0, 3, 5, 11, 13, 16} : Multiset ℕ) ≠ ({1, 1, 8, 8, 15, 15} : Multiset ℕ) := by
  refine ⟨by decide, by decide, ?_, by decide, by decide, by decide⟩
  intro k hk
  interval_cases k <;> decide

/-! ## 3. Exact values of the invariant for `K = 3, 4, 5` -/

/-- **`m(N, 3) = 4` for every `N ≥ 7`.**  This improves
`PowerSumMinCollision.minCollisionCard_three`, which needed `N ≥ 11`. -/
theorem minCollisionCard_three_narrow {N : ℕ} (hN : 7 ≤ N) : minCollisionCard N 3 = 4 := by
  obtain ⟨hs, ht, hagree, -, hcard, hne⟩ := ideal_pte_three_narrow
  exact minCollisionCard_eq_of_ideal_witness (D := 7) (by norm_num) hN hs ht hagree hne hcard

/-- **`m(N, 4) = 5` for every `N ≥ 18`.** -/
theorem minCollisionCard_four {N : ℕ} (hN : 18 ≤ N) : minCollisionCard N 4 = 5 := by
  obtain ⟨hs, ht, hagree, -, hcard, hne⟩ := ideal_pte_four
  exact minCollisionCard_eq_of_ideal_witness (D := 18) (by norm_num) hN hs ht hagree hne hcard

/-- **`m(N, 5) = 6` for every `N ≥ 16`.** -/
theorem minCollisionCard_five {N : ℕ} (hN : 16 ≤ N) : minCollisionCard N 5 = 6 := by
  obtain ⟨hs, ht, hagree, -, hcard, hne⟩ := ideal_pte_five
  exact minCollisionCard_eq_of_ideal_witness (D := 16) (by norm_num) hN hs ht hagree hne hcard

/-- **The PTE floor is attained for every degree `K ≤ 5`**: for each such `K` there is an
alphabet on which the minimal collision has exactly `K + 1` elements, the least possible value
by `PowerSumMinCollision.lt_minCollisionCard`. -/
theorem pte_floor_attained_of_le_five {K : ℕ} (hK : 1 ≤ K) (hK5 : K ≤ 5) :
    ∃ N, K < N ∧ minCollisionCard N K = K + 1 := by
  interval_cases K
  · exact ⟨2, by norm_num, minCollisionCard_one (by norm_num)⟩
  · exact ⟨4, by norm_num, minCollisionCard_two (by norm_num)⟩
  · exact ⟨7, by norm_num, minCollisionCard_three_narrow (by norm_num)⟩
  · exact ⟨18, by norm_num, minCollisionCard_four (by norm_num)⟩
  · exact ⟨16, by norm_num, minCollisionCard_five (by norm_num)⟩

/-! ## 4. Intermediate witnesses: the invariant drops below `2^K` early -/

/-- A degree-`3` collision of size `6` inside the very narrow alphabet `{0,…,5}`:
`{1,1,1,4,4,4}` versus `{0,2,2,3,3,5}`.  Hence `m(N,3) ≤ 6 < 8 = 2^3` already for `N ≥ 5`,
two letters below the ideal threshold `d(3) = 7`. -/
theorem minCollisionCard_three_le_six {N : ℕ} (hN : 5 ≤ N) : minCollisionCard N 3 ≤ 6 := by
  refine minCollisionCard_le_of_witness (D := 5) (s := ({1, 1, 1, 4, 4, 4} : Multiset ℕ))
    (t := ({0, 2, 2, 3, 3, 5} : Multiset ℕ)) hN (by decide) (by decide) ?_ (by decide) (by decide)
  intro k hk
  interval_cases k <;> decide

/-- A degree-`4` collision of size `7` inside the alphabet `{0,…,8}`: `{1,1,1,5,6,6,8}` versus
`{0,2,2,3,7,7,7}`.  Hence `m(N,4) ≤ 7 < 16 = 2^4` already for `N ≥ 8`, ten letters below the
ideal threshold `d(4) = 18`. -/
theorem minCollisionCard_four_le_seven {N : ℕ} (hN : 8 ≤ N) : minCollisionCard N 4 ≤ 7 := by
  refine minCollisionCard_le_of_witness (D := 8) (s := ({1, 1, 1, 5, 6, 6, 8} : Multiset ℕ))
    (t := ({0, 2, 2, 3, 7, 7, 7} : Multiset ℕ)) hN (by decide) (by decide) ?_ (by decide) (by decide)
  intro k hk
  interval_cases k <;> decide

/-- **The invariant is not monotone-trivial in the degree.**  At the alphabet `N = 8` the
degree-`3` and degree-`4` values are already `4` and `≤ 7`, both far below the Prouhet ceiling
`2^K`; and the ceiling is still exactly attained at the critical windows `K = N - 1`.  The
profile at `N = 8` therefore reads `m(8,1) = 2`, `m(8,2) = 3`, `m(8,3) = 4`, `m(8,4) ≤ 7`,
`m(8,7) = 128`. -/
theorem minCollisionCard_profile_eight :
    minCollisionCard 8 1 = 2 ∧ minCollisionCard 8 2 = 3 ∧ minCollisionCard 8 3 = 4 ∧
    minCollisionCard 8 4 ≤ 7 ∧ minCollisionCard 8 7 = 128 :=
  ⟨minCollisionCard_one (by norm_num), minCollisionCard_two (by norm_num),
    minCollisionCard_three_narrow (by norm_num), minCollisionCard_four_le_seven (by norm_num),
    by simpa using minCollisionCard_critical (N := 8) (by norm_num)⟩

end PowerSumIdealPTE