/-
# Orbits over a small alphabet: the binary case is a power of two

Over an alphabet of size `a` the orbits of `Equiv.Perm α` on `n`-tuples are the patterns
with at most `a` blocks (`KernelPattern.card_orbits_eq_card_patterns_le`), so their number
is the truncated Stirling row `∑_{k ≤ a} S(n,k)`.  For `a = 2` this collapses to a clean
closed form:

`KernelPattern.card_orbits_binary` : the `n+1`-tuples over a two-letter alphabet fall into
exactly `2 ^ n` orbits,

which is the Bell number `Nat.bell (n+1)` only for `n ≤ 2`; from `n = 3` on the truncation
is strict.
-/
import Algebra.KernelPatterns.Blocks
import Algebra.KernelPatterns.Stirling

namespace KernelPattern

open Finset

variable {n : ℕ}

/-! ## Two Stirling rows in closed form -/

/-- There is exactly one partition of a nonempty set into a single block. -/
theorem stirling2_succ_one (n : ℕ) : stirling2 (n + 1) 1 = 1 := by
  induction n with
  | zero => decide
  | succ n ih => rw [stirling2_succ_succ, ih, stirling2_succ_zero]

/-- `S(n+2, 2) = 2 ^ (n+1) - 1`, stated without truncated subtraction. -/
theorem stirling2_two_succ (n : ℕ) : stirling2 (n + 2) 2 + 1 = 2 ^ (n + 1) := by
  induction n with
  | zero => decide
  | succ n ih =>
    have h : stirling2 (n + 3) 2 = 2 * stirling2 (n + 2) 2 + 1 := by
      rw [stirling2_succ_succ, stirling2_succ_one]
    rw [h, pow_succ]
    omega

/-! ## Truncated Stirling rows count the orbits -/

theorem card_patterns_le (n a : ℕ) :
    (Finset.univ.filter fun p : Pattern n => numBlocks p ≤ a).card
      = ∑ k ∈ Finset.range (a + 1), stirling2 n k := by
  have hfib : (Finset.univ.filter fun p : Pattern n => numBlocks p ≤ a).card
      = ∑ k ∈ Finset.range (a + 1),
          ((Finset.univ.filter fun p : Pattern n => numBlocks p ≤ a).filter
            fun p => numBlocks p = k).card :=
    Finset.card_eq_sum_card_fiberwise fun p hp =>
      Finset.mem_range.2 (Nat.lt_succ_of_le (Finset.mem_filter.mp hp).2)
  rw [hfib]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ a := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
  have hset : ((Finset.univ.filter fun p : Pattern n => numBlocks p ≤ a).filter
      fun p => numBlocks p = k) = Finset.univ.filter fun p : Pattern n => numBlocks p = k := by
    ext p
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h
      exact ⟨by rw [h]; exact hk', h⟩
  rw [hset, card_patternWithBlocks]

/-- The number of orbits of `Equiv.Perm α` on `n`-tuples over a finite alphabet is the
truncated Stirling row of length `|α|`. -/
theorem card_orbits_eq_sum_stirling2 (α : Type*) [DecidableEq α] [Finite α] (n : ℕ) :
    Nat.card (Quotient (permSetoid α n))
      = ∑ k ∈ Finset.range (Nat.card α + 1), stirling2 n k := by
  rw [card_orbits_eq_card_patterns_le α n, ← card_patterns_le n (Nat.card α)]
  simp [Fintype.card_subtype]

/-- Partitions into three blocks exist as soon as there are three points. -/
theorem stirling2_three_pos (n : ℕ) : 0 < stirling2 (n + 3) 3 := by
  induction n with
  | zero => decide
  | succ n ih =>
    have h : stirling2 (n + 1 + 3) 3 = 3 * stirling2 (n + 3) 3 + stirling2 (n + 3) 2 :=
      stirling2_succ_succ (n + 3) 2
    omega

/-- **Binary alphabet**: the `n+1`-tuples of bits fall into exactly `2 ^ n` orbits under
relabelling of the two letters. -/
theorem card_orbits_binary (n : ℕ) :
    Nat.card (Quotient (permSetoid (Fin 2) (n + 1))) = 2 ^ n := by
  have hcard : Nat.card (Fin 2) = 2 := by simp
  rw [card_orbits_eq_sum_stirling2 (Fin 2) (n + 1), hcard,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one]
  cases n with
  | zero => decide
  | succ m =>
    have e0 : stirling2 (m + 1 + 1) 0 = 0 := stirling2_succ_zero _
    have e1 : stirling2 (m + 1 + 1) 1 = 1 := stirling2_succ_one _
    have e2 : stirling2 (m + 1 + 1) 2 + 1 = 2 ^ (m + 1) := stirling2_two_succ m
    omega

/-- From `n = 3` on, the binary orbit count is strictly smaller than the Bell number: not
every equality pattern can be realised over two letters. -/
theorem card_orbits_binary_lt_bell (n : ℕ) (hn : 3 ≤ n) :
    Nat.card (Quotient (permSetoid (Fin 2) n)) < Nat.bell n := by
  obtain ⟨l, rfl⟩ : ∃ l, n = l + 3 := ⟨n - 3, by omega⟩
  have h1 : Nat.card (Quotient (permSetoid (Fin 2) (l + 3))) = 2 ^ (l + 2) :=
    card_orbits_binary (l + 2)
  have hlow : ∑ k ∈ Finset.range 3, stirling2 (l + 3) k = 2 ^ (l + 2) := by
    rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one]
    have e0 : stirling2 (l + 3) 0 = 0 := stirling2_succ_zero _
    have e1 : stirling2 (l + 3) 1 = 1 := stirling2_succ_one _
    have e2 : stirling2 (l + 3) 2 + 1 = 2 ^ (l + 2) := stirling2_two_succ (l + 1)
    omega
  have hsplit : ∑ k ∈ Finset.range (l + 3 + 1), stirling2 (l + 3) k
      = ∑ k ∈ Finset.range 3, stirling2 (l + 3) k
        + ∑ k ∈ Finset.Ico 3 (l + 3 + 1), stirling2 (l + 3) k :=
    (Finset.sum_range_add_sum_Ico _ (by omega : 3 ≤ l + 3 + 1)).symm
  have hmem : (3 : ℕ) ∈ Finset.Ico 3 (l + 3 + 1) := Finset.mem_Ico.2 ⟨le_rfl, by omega⟩
  have hIco : 0 < ∑ k ∈ Finset.Ico 3 (l + 3 + 1), stirling2 (l + 3) k :=
    Finset.sum_pos' (fun i _ => Nat.zero_le _) ⟨3, hmem, stirling2_three_pos l⟩
  rw [h1, ← sum_stirling2_eq_bell (l + 3), hsplit, hlow]
  omega

/-! ## The ternary alphabet -/

/-- The truncated Stirling row of length three, in closed form. -/
theorem two_mul_sum_stirling2_three (n : ℕ) :
    2 * ∑ k ∈ Finset.range 4, stirling2 (n + 1) k = 3 ^ n + 1 := by
  induction n with
  | zero => decide
  | succ m ih =>
    rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
      Finset.sum_range_one] at ih ⊢
    have e0 : stirling2 (m + 1 + 1) 0 = 0 := stirling2_succ_zero _
    have e1 : stirling2 (m + 1 + 1) 1 = 1 := stirling2_succ_one _
    have e2 : stirling2 (m + 1 + 1) 2 = 2 * stirling2 (m + 1) 2 + stirling2 (m + 1) 1 :=
      stirling2_succ_succ (m + 1) 1
    have e3 : stirling2 (m + 1 + 1) 3 = 3 * stirling2 (m + 1) 3 + stirling2 (m + 1) 2 :=
      stirling2_succ_succ (m + 1) 2
    have e1' : stirling2 (m + 1) 1 = 1 := stirling2_succ_one _
    have e0' : stirling2 (m + 1) 0 = 0 := stirling2_succ_zero _
    have hp : (3 : ℕ) ^ (m + 1) = 3 * 3 ^ m := by ring
    omega

/-- **Ternary alphabet**: the `n+1`-tuples over three letters fall into `(3 ^ n + 1) / 2`
orbits, stated without truncated division. -/
theorem card_orbits_ternary (n : ℕ) :
    2 * Nat.card (Quotient (permSetoid (Fin 3) (n + 1))) = 3 ^ n + 1 := by
  have hcard : Nat.card (Fin 3) = 3 := by simp
  rw [card_orbits_eq_sum_stirling2 (Fin 3) (n + 1), hcard]
  exact two_mul_sum_stirling2_three n

end KernelPattern