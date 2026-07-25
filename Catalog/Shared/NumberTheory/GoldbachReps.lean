import Mathlib

/-!
# Combinatorial properties of the Goldbach representation counter

This file defines a representation counter `reps A n`, counting the number of
*unordered* representations `n = p + q` with `p, q ∈ A` (encoded by `p ≤ n - p`),
and proves several structural results about it.

The headline result is `reps_symmetric_eq`: if a set `A` is symmetric about `n/2`
(closed under `k ↦ n - k` on its elements `≤ n`), then `reps A n` simply counts the
elements of `A` in the lower half `{0, …, ⌊n/2⌋}`.  From it we derive the value for the
full set, an upper bound valid for every set, and the exact value for the set of even
numbers.

All core arguments are explicit Finset manipulations (`Finset.ext`, `Finset.card_nbij'`,
`Finset.card_le_card`, `Finset.filter_eq_empty_iff`), with arithmetic discharged by
`omega`; no `aesop`/`grind` is used.
-/

namespace GoldbachReps

open Classical

noncomputable def reps (A : Set ℕ) (n : ℕ) : ℕ :=
  (Finset.filter (fun p => p ∈ A ∧ (n - p) ∈ A ∧ p ≤ n - p) (Finset.range (n + 1))).card

noncomputable def goldbachReps (n : ℕ) : ℕ := reps {p : ℕ | Prime p} n

/-- The number of elements `≤ m` inside `range (n+1)` is `m + 1`, provided `m ≤ n`. -/
lemma card_filter_le_range {n m : ℕ} (h : m ≤ n) :
    (Finset.filter (fun p => p ≤ m) (Finset.range (n + 1))).card = m + 1 := by
  have hset : Finset.filter (fun p => p ≤ m) (Finset.range (n + 1)) = Finset.range (m + 1) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff]
    constructor
    · rintro ⟨_, hx⟩; exact hx
    · intro hx; exact ⟨le_trans hx h, hx⟩
  rw [hset, Finset.card_range]

/-- The number of even numbers in `range (M+1)` is `M / 2 + 1`.
Proved by the explicit bijection `i ↦ 2 * i` with inverse `p ↦ p / 2`. -/
lemma card_filter_even_range (M : ℕ) :
    (Finset.filter (fun p => Even p) (Finset.range (M + 1))).card = M / 2 + 1 := by
  rw [← Finset.card_range (M / 2 + 1)]
  refine Finset.card_nbij' (fun p => p / 2) (fun i => 2 * i) ?_ ?_ ?_ ?_
  · -- forward map lands in `range (M/2+1)`
    intro p hp
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq, Nat.even_iff] at hp
    simp only [Finset.coe_range, Set.mem_Iio]
    omega
  · -- inverse map lands in the filtered set
    intro i hi
    simp only [Finset.coe_range, Set.mem_Iio] at hi
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq, Nat.even_iff]
    omega
  · -- left inverse on the filtered set: `2 * (p / 2) = p` since `p` is even
    intro p hp
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq, Nat.even_iff] at hp
    show 2 * (p / 2) = p
    omega
  · -- right inverse on `range (M/2+1)`: `(2 * i) / 2 = i`
    intro i _
    show (2 * i) / 2 = i
    omega

/-- **Theorem 4 (structural).**  If `A` is symmetric about `n/2` — i.e. closed under
`k ↦ n - k` on its elements that are `≤ n` — then `reps A n` counts exactly the elements
of `A` lying in the lower half `{0, …, ⌊n/2⌋}`. -/
theorem reps_symmetric_eq (A : Set ℕ) (n : ℕ)
    (hsym : ∀ k ∈ A, k ≤ n → (n - k) ∈ A) :
    reps A n = (Finset.filter (fun p => p ∈ A ∧ p ≤ n / 2) (Finset.range (n + 1))).card := by
  unfold reps
  congr 1
  ext p
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff]
  constructor
  · rintro ⟨hpr, hpA, _hnpA, hple⟩
    exact ⟨hpr, hpA, by omega⟩
  · rintro ⟨hpr, hpA, hpd⟩
    exact ⟨hpr, hpA, hsym p hpA hpr, by omega⟩

/-- **Theorem 1.**  For the full set of summands, every `p ≤ n/2` gives a representation,
so there are exactly `n / 2 + 1` of them.

(The informal statement used `Set.range (n+1)`, which does not type-check; the intended
"full set" is `Set.univ`.  See `reps_Iio` for the variant using the actual set
`{x | x < n + 1}`.) -/
theorem reps_full_set (n : ℕ) : reps Set.univ n = n / 2 + 1 := by
  rw [reps_symmetric_eq Set.univ n (fun k _ _ => Set.mem_univ _),
      ← card_filter_le_range (Nat.div_le_self n 2)]
  congr 1
  ext p
  simp only [Finset.mem_filter, Set.mem_univ, true_and]

/-- **Theorem 1 (faithful variant).**  The set `{x | x < n + 1}` (i.e. the "range" up to
`n`) yields `n / 2 + 1` representations. -/
theorem reps_Iio (n : ℕ) : reps (Set.Iio (n + 1)) n = n / 2 + 1 := by
  rw [reps_symmetric_eq (Set.Iio (n + 1)) n
        (fun k _ _ => Set.mem_Iio.mpr (Nat.lt_succ_of_le (Nat.sub_le n k))),
      ← card_filter_le_range (Nat.div_le_self n 2)]
  congr 1
  ext p
  simp only [Finset.mem_filter, Finset.mem_range, Set.mem_Iio]
  tauto

/-- **Theorem 2.**  No set can have more than `n / 2 + 1` representations of `n`. -/
theorem reps_upper_bound (A : Set ℕ) (n : ℕ) : reps A n ≤ n / 2 + 1 := by
  unfold reps
  rw [← card_filter_le_range (Nat.div_le_self n 2)]
  apply Finset.card_le_card
  intro p hp
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff] at hp ⊢
  obtain ⟨hpr, _hpA, _hnpA, hple⟩ := hp
  exact ⟨hpr, by omega⟩

/-- **Theorem 3 (odd case).**  An odd number has no representation as a sum of two even
numbers. -/
theorem reps_even_odd (n : ℕ) (hn : n % 2 = 1) :
    reps {m : ℕ | Even m} n = 0 := by
  rw [reps, Finset.filter_congr_decidable]
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro p hp
  rw [Finset.mem_range, Nat.lt_succ_iff] at hp
  simp only [Set.mem_setOf_eq, Nat.even_iff]
  rintro ⟨hpe, hnpe, hple⟩
  omega

/-- **Theorem 3 (even case).**  An even number `n` has exactly `(n / 2) / 2 + 1`
representations as a sum of two even numbers. -/
theorem reps_even_even (n : ℕ) (hn : n % 2 = 0) :
    reps {m : ℕ | Even m} n = (n / 2) / 2 + 1 := by
  rw [reps, Finset.filter_congr_decidable]
  rw [← card_filter_even_range (n / 2)]
  congr 1
  ext p
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff, Set.mem_setOf_eq, Nat.even_iff]
  constructor
  · rintro ⟨_hpr, hpe, _hnpe, hple⟩
    exact ⟨by omega, hpe⟩
  · rintro ⟨hpd, hpe⟩
    exact ⟨by omega, hpe, by omega, by omega⟩

end GoldbachReps