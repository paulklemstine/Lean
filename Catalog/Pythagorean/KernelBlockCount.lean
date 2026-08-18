import Pythagorean.KernelPatternsBell

/-!
# Refining the Bell count by the number of blocks

Kernel patterns of length `n` are counted by `Nat.bell n`
(`KernelPattern.card_patterns_eq_bell`).  Refining the count by the number of blocks of the
pattern gives the Stirling numbers of the second kind, which we *define* combinatorially
here (Mathlib has no Stirling numbers) and connect back to the Bell numbers:

* `KernelPattern.sum_stirling2_eq_bell` : `∑_{k ≤ n} S(n,k) = Nat.bell n`;
* `KernelPattern.stirling2_eq_zero_of_lt`, `stirling2_self`, `stirling2_one`,
  `stirling2_zero_zero`, `stirling2_zero_succ` : the boundary values;
* `KernelPattern.stirling2_table_*` : the first rows of the Stirling triangle, by `decide`.
-/

open Finset

namespace KernelPattern

variable {n : ℕ}

/-- The number of blocks of a pattern: the number of distinct values it takes. -/
def nblocks (p : Fin n → Fin n) : ℕ := (univ.image p).card

theorem nblocks_le (p : Fin n → Fin n) : nblocks p ≤ n := by
  have := Finset.card_le_univ (univ.image p)
  simpa [nblocks] using this

/-- Stirling numbers of the second kind, defined as the number of kernel patterns of length
`n` with exactly `k` blocks. -/
def stirling2 (n k : ℕ) : ℕ := ((Patterns n).filter (fun p => nblocks p = k)).card

/-- Refining the Bell count by the number of blocks. -/
theorem sum_stirling2_eq_card (n : ℕ) :
    ∑ k ∈ range (n + 1), stirling2 n k = (Patterns n).card := by
  symm
  exact Finset.card_eq_sum_card_fiberwise
    (fun p _ => Finset.mem_range.2 (Nat.lt_succ_of_le (nblocks_le p)))

/-- **The Stirling numbers of the second kind sum to the Bell number.** -/
theorem sum_stirling2_eq_bell (n : ℕ) :
    ∑ k ∈ range (n + 1), stirling2 n k = Nat.bell n := by
  rw [sum_stirling2_eq_card, card_patterns_eq_bell]

/-! ## Boundary values -/

theorem stirling2_eq_zero_of_lt {n k : ℕ} (h : n < k) : stirling2 n k = 0 := by
  rw [stirling2, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro p _
  have := nblocks_le p
  omega

/-- The identity tuple is the unique pattern with `n` blocks: only the discrete partition
splits `n` points into `n` blocks. -/
theorem filter_nblocks_self (n : ℕ) :
    (Patterns n).filter (fun p => nblocks p = n) = {id} := by
  ext p
  simp only [Finset.mem_filter, Finset.mem_singleton, mem_patterns_iff]
  constructor
  · rintro ⟨hp, hn⟩
    have hsurj : Function.Surjective p := by
      have himg : univ.image p = (univ : Finset (Fin n)) := by
        refine Finset.eq_univ_of_card _ ?_
        simpa [nblocks] using hn
      intro y
      have : y ∈ univ.image p := by rw [himg]; exact Finset.mem_univ y
      simpa using this
    have hinj : Function.Injective p := Finite.injective_iff_surjective.2 hsurj
    rw [← hp, canon_eq_id_of_injective hinj]
  · rintro rfl
    refine ⟨canon_eq_id_of_injective Function.injective_id, ?_⟩
    simp [nblocks, Finset.image_id]

theorem stirling2_self (n : ℕ) : stirling2 n n = 1 := by
  rw [stirling2, filter_nblocks_self, Finset.card_singleton]

theorem stirling2_zero_zero : stirling2 0 0 = 1 := stirling2_self 0

theorem stirling2_zero_succ (k : ℕ) : stirling2 0 (k + 1) = 0 :=
  stirling2_eq_zero_of_lt (Nat.succ_pos k)

/-- A nonempty pattern has at least one block. -/
theorem stirling2_succ_zero (n : ℕ) : stirling2 (n + 1) 0 = 0 := by
  rw [stirling2, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro p _ hzero
  have hne : (univ.image p).Nonempty := ⟨p 0, Finset.mem_image_of_mem p (Finset.mem_univ 0)⟩
  have hpos := Finset.card_pos.2 hne
  rw [nblocks] at hzero
  omega

/-- The constant pattern is the unique pattern with one block. -/
theorem filter_nblocks_one (n : ℕ) :
    (Patterns (n + 1)).filter (fun p => nblocks p = 1) = {fun _ => 0} := by
  ext p
  simp only [Finset.mem_filter, Finset.mem_singleton, mem_patterns_iff]
  constructor
  · rintro ⟨hp, h1⟩
    have hconst : ∀ i j : Fin (n + 1), p i = p j := by
      intro i j
      have hcard : (univ.image p).card = 1 := h1
      obtain ⟨a, ha⟩ := Finset.card_eq_one.1 hcard
      have hi : p i ∈ univ.image p := Finset.mem_image_of_mem p (Finset.mem_univ i)
      have hj : p j ∈ univ.image p := Finset.mem_image_of_mem p (Finset.mem_univ j)
      rw [ha, Finset.mem_singleton] at hi hj
      rw [hi, hj]
    funext i
    have : canon p i = 0 := by
      refine canon_eq_iff_least.2 ⟨hconst 0 i, fun j _ => Fin.zero_le _⟩
    rw [← hp, this]
  · rintro rfl
    constructor
    · funext i
      refine canon_eq_iff_least.2 ⟨rfl, fun j _ => Fin.zero_le _⟩
    · rw [nblocks, Finset.image_const (Finset.univ_nonempty) 0, Finset.card_singleton]

theorem stirling2_one (n : ℕ) : stirling2 (n + 1) 1 = 1 := by
  rw [stirling2, filter_nblocks_one, Finset.card_singleton]

/-! ## The Stirling triangle, by `decide` -/

set_option maxRecDepth 40000 in
theorem stirling2_table_three : (stirling2 3 0, stirling2 3 1, stirling2 3 2, stirling2 3 3)
    = (0, 1, 3, 1) := by
  simp only [stirling2, patterns_eq_filter]
  decide

set_option maxRecDepth 400000 in
theorem stirling2_table_four :
    (stirling2 4 0, stirling2 4 1, stirling2 4 2, stirling2 4 3, stirling2 4 4)
    = (0, 1, 7, 6, 1) := by
  simp only [stirling2, patterns_eq_filter]
  decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
theorem stirling2_table_five :
    (stirling2 5 0, stirling2 5 1, stirling2 5 2, stirling2 5 3, stirling2 5 4, stirling2 5 5)
    = (0, 1, 15, 25, 10, 1) := by
  simp only [stirling2, patterns_eq_filter]
  decide

end KernelPattern