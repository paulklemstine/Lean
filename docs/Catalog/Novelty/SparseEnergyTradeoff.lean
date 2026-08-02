import Mathlib
import Novelty.NeuralCoding

/-!
# Sparse neural coding: exact capacity and an energy–information bound

A binary pattern on `N` neurons has energy equal to its Hamming weight.  This
file studies the codebook consisting of all patterns using at most `k` spikes.
Its size is exactly the Hamming-ball volume

`∑ j ∈ range (k+1), N.choose j`.

For exactly `k` spikes, the number of concepts is `N.choose k`.  The central
energy theorem proves that this capacity is at most `N^k`; consequently its
information content per spike is at most `log₂ N`.  Thus fixed sparsity gives
polynomial raw capacity while information per unit energy grows only
logarithmically with population size.  The result also applies directly to a
one-percent budget by substituting `k = N / 100`.
-/

namespace NeuralCoding.SparseEnergyTradeoff

open Finset
open NeuralCoding

/-- All neural patterns whose spike-energy is at most `k`. -/
def budgetCodebook (N k : ℕ) : Finset (NeuralCode N) :=
  Finset.univ.filter (fun c => weight c ≤ k)

/-- All neural patterns using exactly `k` spikes. -/
def exactEnergyCodebook (N k : ℕ) : Finset (NeuralCode N) :=
  Finset.univ.filter (fun c => weight c = k)

/-- The exact capacity under a spike budget is the lower binomial sum. -/
theorem card_budgetCodebook (N k : ℕ) :
    (budgetCodebook N k).card = ∑ j ∈ Finset.range (k + 1), N.choose j := by
  unfold budgetCodebook
  calc
    (Finset.univ.filter (fun c : NeuralCode N => weight c ≤ k)).card =
        (Finset.univ.filter (fun c : NeuralCode N => weight c ∈ Finset.range (k + 1))).card := by
      congr 1
      ext c
      simp
    _ = ∑ j ∈ Finset.range (k + 1),
          (Finset.univ.filter (fun c : NeuralCode N => weight c = j)).card := by
      rw [Finset.sum_card_fiberwise_eq_card_filter]
    _ = ∑ j ∈ Finset.range (k + 1), N.choose j := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [NeuralCoding.card_sparse]

/-- Small cases used as computational checks of the exact budget formula. -/
example : (budgetCodebook 4 0).card = 1 := by
  rw [card_budgetCodebook]
  norm_num [Nat.choose]

example : (budgetCodebook 4 1).card = 5 := by
  rw [card_budgetCodebook]
  decide

example : (budgetCodebook 4 2).card = 11 := by
  rw [card_budgetCodebook]
  decide

/-- Exact-energy capacity is a binomial coefficient. -/
theorem card_exactEnergyCodebook (N k : ℕ) :
    (exactEnergyCodebook N k).card = N.choose k := by
  exact NeuralCoding.card_sparse N k

/-- **Polynomial sparse-capacity bound.** With exactly `k` spikes, a population
of `N` neurons represents at most `N^k` concepts. -/
theorem exactEnergy_capacity_le_pow (N k : ℕ) :
    (exactEnergyCodebook N k).card ≤ N ^ k := by
  rw [card_exactEnergyCodebook]
  exact Nat.choose_le_pow N k

/-- The bound specializes to the commonly cited one-percent activity budget. -/
theorem onePercent_capacity_le_pow (N : ℕ) :
    (exactEnergyCodebook N (N / 100)).card ≤ N ^ (N / 100) := by
  exact exactEnergy_capacity_le_pow N (N / 100)

/-- Every sparse codebook (not necessarily the full weight layer) obeys the same
polynomial capacity ceiling. -/
theorem sparse_codebook_capacity {N k : ℕ}
    (C : Finset (NeuralCode N))
    (hC : ∀ c ∈ C, weight c = k) :
    C.card ≤ N ^ k := by
  calc
    C.card ≤ (exactEnergyCodebook N k).card := by
      apply Finset.card_le_card
      intro c hc
      simp [exactEnergyCodebook, hC c hc]
    _ ≤ N ^ k := exactEnergy_capacity_le_pow N k

/-- **Information per unit energy.** For `N ≥ 2` and `k ≥ 1`, the information
in the full exact-`k` sparse layer, divided by its spike cost, is at most
`log₂ N` bits per spike. -/
theorem information_per_energy_le_log_population (N k : ℕ)
    (hN : 2 ≤ N) (hk : 1 ≤ k) (hkN : k ≤ N) :
    information ((exactEnergyCodebook N k).card) / (k : ℝ) ≤ Real.logb 2 N := by
  unfold information
  rw [card_exactEnergyCodebook]
  have hchoose_pos : 0 < N.choose k := Nat.choose_pos hkN
  have hpow_pos : 0 < N ^ k := pow_pos (by omega) k
  have hlog : Real.logb 2 (N.choose k) ≤ Real.logb 2 (N ^ k) := by
    apply (Real.logb_le_logb (by norm_num)
      (by exact_mod_cast hchoose_pos) (by exact_mod_cast hpow_pos)).2
    exact_mod_cast Nat.choose_le_pow N k
  have hpow : Real.logb 2 ((N : ℝ) ^ k) = (k : ℝ) * Real.logb 2 N := by
    rw [Real.logb_pow]
  norm_num only [Nat.cast_pow] at hlog
  rw [hpow] at hlog
  have hkpos : (0 : ℝ) < k := by exact_mod_cast hk
  apply (div_le_iff₀ hkpos).2
  simpa [mul_comm] using hlog

/-- One-hot coding attains the logarithmic upper bound exactly: it represents
`N` concepts using one spike per concept. -/
theorem oneHot_attains_log_rate (N : ℕ) :
    information ((exactEnergyCodebook N 1).card) / (1 : ℝ) = Real.logb 2 N := by
  rw [card_exactEnergyCodebook, Nat.choose_one_right]
  exact sparseRate_eq N

end NeuralCoding.SparseEnergyTradeoff