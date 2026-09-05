import Mathlib
import Bridges.DenseSumsetFree.General

/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The two-summand `(log n)³` theorem

The development referred to a module `Bridges.DenseSumsetFree.Main` for the
two-summand theorem `exists_dense_set_avoiding_polylog_sumsets`, but that module is
absent from the repository.  It is reconstructed here as the `t = 2` case of the
native `t`-summand theorem `exists_dense_set_avoiding_N_sumsets` proved in
`Bridges.DenseSumsetFree.General`, whose threshold exponent `(2t-1)/(t-1)` equals `3`
at `t = 2`.

The `t`-fold corollary `exists_dense_set_avoiding_polylog_multifold_sumsets` (which
deduces avoidance of iterated sumsets from the two-summand statement) also lives here,
since it depends on the two-summand theorem; `Bridges.DenseSumsetFree.MultiFold` keeps
the purely combinatorial part `avoidsSumsets_multifold`.
-/

open Finset Pointwise

namespace DenseSumsetFree

/-- `sumsetNat [A, B]` is the ordinary sumset `A + B`. -/
lemma sumsetNat_pair (A B : Finset ℕ) : sumsetNat [A, B] = A + B := by
  have h0 : ({0} : Finset ℕ) = (0 : Finset ℕ) := rfl
  simp [sumsetNat, h0]

/-- **The `(log n)³` theorem for two summands.**  For every density `0 < δ < 1` there is
`C > 0` such that for all large `n` there is `S ⊆ [n]` with `|S| ≥ δ n` containing no
sumset `A + B` with `|A|, |B| ≥ C (log n)³`. -/
theorem exists_dense_set_avoiding_polylog_sumsets (δ : ℝ) (hδ0 : 0 < δ) (hδ1 : δ < 1) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ A B : Finset ℕ, C * (Real.log n) ^ 3 ≤ A.card → C * (Real.log n) ^ 3 ≤ B.card →
          ¬ A + B ⊆ S := by
  obtain ⟨c, hc0, N, hN⟩ := exists_dense_set_avoiding_N_sumsets 2 le_rfl δ hδ0 hδ1
  refine ⟨c, hc0, max N 1, fun n hn => ?_⟩
  obtain ⟨S, hSsub, hScard, hSavoid⟩ := hN n (le_trans (le_max_left _ _) hn)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A B hA hB hsub
  have hn1 : 1 ≤ n := le_trans (le_max_right N 1) hn
  have hnR : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn1
  have hlog0 : 0 ≤ Real.log n := Real.log_nonneg hnR
  have hrpow : (Real.log n) ^ ((2 * ((2 : ℕ) : ℝ) - 1) / (((2 : ℕ) : ℝ) - 1))
      = (Real.log n) ^ (3 : ℕ) := by
    have h3 : (2 * ((2 : ℕ) : ℝ) - 1) / (((2 : ℕ) : ℝ) - 1) = ((3 : ℕ) : ℝ) := by
      norm_num
    rw [h3, Real.rpow_natCast]
  refine hSavoid [A, B] (by simp) ?_ ?_
  · intro X hX
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hX
    rcases hX with rfl | rfl
    · rw [hrpow]; exact hA
    · rw [hrpow]; exact hB
  · rwa [sumsetNat_pair]

/-- **The polylogarithmic theorem for `t`-fold sumsets.**  For every density
`0 < δ < 1` there is `C > 0` such that for all large `n` there is `S ⊆ [n]` with
`|S| ≥ δ n` containing **no** iterated sumset `A₁ + ⋯ + A_t` (`t ≥ 2` arbitrary)
whose parts all have at least `C (log n)³` elements. -/
theorem exists_dense_set_avoiding_polylog_multifold_sumsets (δ : ℝ) (hδ0 : 0 < δ)
    (hδ1 : δ < 1) :
    ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∃ S : Finset ℕ, S ⊆ Finset.range n ∧ δ * n ≤ S.card ∧
        ∀ L : List (Finset ℕ), 2 ≤ L.length → (∀ A ∈ L, A.Nonempty) →
          (∀ A ∈ L, C * (Real.log n) ^ 3 ≤ A.card) → ¬ sumsetNat L ⊆ S := by
  obtain ⟨C, hC0, N, hN⟩ := exists_dense_set_avoiding_polylog_sumsets δ hδ0 hδ1
  refine ⟨C, hC0, N, fun n hn => ?_⟩
  obtain ⟨S, hSsub, hScard, hSavoid⟩ := hN n hn
  refine ⟨S, hSsub, hScard, ?_⟩
  intro L hlen hne hk
  -- the two-summand avoidance holds at the natural-number threshold `⌈C (log n)³⌉`
  have havoid : AvoidsSumsets S ⌈C * (Real.log n) ^ 3⌉₊ := by
    intro A B hA hB
    refine hSavoid A B ?_ ?_
    · exact le_trans (Nat.le_ceil _) (by exact_mod_cast hA)
    · exact le_trans (Nat.le_ceil _) (by exact_mod_cast hB)
  refine avoidsSumsets_multifold havoid L hlen hne ?_
  intro A hA
  exact Nat.ceil_le.2 (hk A hA)

end DenseSumsetFree