import Physics.PlanckFoamStochastic

/-!
# Entropy of the stochastic Planck foam

The Bernoulli foam measure of `Physics.PlanckFoamStochastic` assigns to each
configuration `A` of excited Planck cells inside a cell set `s` the weight
`weightOn p s A = ∏ i ∈ s, (if i ∈ A then p else 1 - p)`.

Here we compute its Shannon entropy exactly.

## Main results

* `PlanckFoam.Stochastic.sum_weightOn_mul_log` — the fundamental identity
  `∑ A ⊆ s, w(A) log w(A) = |s| * (p log p + (1-p) log (1-p))`, proved by
  induction over the cell set.
* `PlanckFoam.Stochastic.foamEntropy_eq` — **extensivity**: the entropy of the
  foam over `|s|` Planck cells is `|s| * H(p)` with `H` the binary entropy.
* `PlanckFoam.Stochastic.foamEntropy_le_card_mul_log_two` — **one bit per
  Planck cell**: the entropy never exceeds `|s| * log 2`, and
  `foamEntropy_eq_card_mul_log_two_iff` shows the bound is attained exactly at
  the maximally foamy value `p = 1/2` (or for an empty cell set).
* `PlanckFoam.Stochastic.cellEntropy_eq`, `cellEntropy_le` — the same statements
  for `N` Planck cells of the line foam, together with
  `hausdorffWeight_lt_one_of_maximal_entropy`: at maximal entropy the foam is
  Hausdorff with probability `2 ^ (-N)`.
-/

open Finset

namespace PlanckFoam
namespace Stochastic

variable {α : Type*} [DecidableEq α]

/-- For a genuinely random foam (`0 < p < 1`) every configuration has positive
weight. -/
theorem weightOn_pos {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s A : Finset α) :
    0 < weightOn p s A := by
  refine Finset.prod_pos fun i _ => ?_
  by_cases h : i ∈ A
  · simpa [h] using hp0
  · simpa [h] using hp1

/-- Shannon entropy (in nats) of the Bernoulli foam measure on the cell set
`s`. -/
noncomputable def foamEntropy (p : ℝ) (s : Finset α) : ℝ :=
  -∑ A ∈ s.powerset, weightOn p s A * Real.log (weightOn p s A)

/-- The fundamental entropy identity, by induction on the set of Planck
cells. -/
theorem sum_weightOn_mul_log {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s : Finset α) :
    ∑ A ∈ s.powerset, weightOn p s A * Real.log (weightOn p s A)
      = s.card * (p * Real.log p + (1 - p) * Real.log (1 - p)) := by
  have hp0' : p ≠ 0 := ne_of_gt hp0
  have hq0 : (0 : ℝ) < 1 - p := by linarith
  have hq0' : (1 : ℝ) - p ≠ 0 := ne_of_gt hq0
  induction s using Finset.induction_on with
  | empty => simp [weightOn]
  | insert a s has ih =>
      rw [Finset.sum_powerset_insert has]
      have h₁ : ∑ A ∈ s.powerset,
            weightOn p (insert a s) A * Real.log (weightOn p (insert a s) A)
          = (1 - p) * Real.log (1 - p) * (∑ A ∈ s.powerset, weightOn p s A)
            + (1 - p) * ∑ A ∈ s.powerset, weightOn p s A * Real.log (weightOn p s A) := by
        rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
        refine Finset.sum_congr rfl fun A hA => ?_
        have hAs : A ⊆ s := Finset.mem_powerset.1 hA
        have hw : 0 < weightOn p s A := weightOn_pos hp0 hp1 s A
        rw [weightOn_insert_notMem has hAs, Real.log_mul hq0' (ne_of_gt hw)]
        ring
      have h₂ : ∑ A ∈ s.powerset,
            weightOn p (insert a s) (insert a A) * Real.log (weightOn p (insert a s) (insert a A))
          = p * Real.log p * (∑ A ∈ s.powerset, weightOn p s A)
            + p * ∑ A ∈ s.powerset, weightOn p s A * Real.log (weightOn p s A) := by
        rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
        refine Finset.sum_congr rfl fun A hA => ?_
        have hw : 0 < weightOn p s A := weightOn_pos hp0 hp1 s A
        rw [weightOn_insert_mem has, Real.log_mul hp0' (ne_of_gt hw)]
        ring
      rw [h₁, h₂, ih, sum_weightOn p s, Finset.card_insert_of_notMem has]
      push_cast
      ring

/-- `Real.binEntropy` in the `- p log p - (1-p) log (1-p)` form. -/
theorem binEntropy_eq_neg (p : ℝ) :
    Real.binEntropy p = -(p * Real.log p + (1 - p) * Real.log (1 - p)) := by
  simp [Real.binEntropy, Real.log_inv]
  ring

/-- **Extensivity of foam entropy.** The Shannon entropy of a stochastic Planck
foam on `|s|` cells is `|s|` times the binary entropy of the excitation
probability. -/
theorem foamEntropy_eq {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s : Finset α) :
    foamEntropy p s = s.card * Real.binEntropy p := by
  rw [foamEntropy, sum_weightOn_mul_log hp0 hp1, binEntropy_eq_neg]
  ring

/-- **One bit per Planck cell.** The foam entropy never exceeds `|s| log 2`. -/
theorem foamEntropy_le_card_mul_log_two {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s : Finset α) :
    foamEntropy p s ≤ s.card * Real.log 2 := by
  rw [foamEntropy_eq hp0 hp1]
  have hcard : (0 : ℝ) ≤ s.card := Nat.cast_nonneg _
  exact mul_le_mul_of_nonneg_left Real.binEntropy_le_log_two hcard

/-- The bound of one bit per Planck cell is attained exactly at the maximally
foamy excitation probability `p = 1/2`. -/
theorem foamEntropy_eq_card_mul_log_two_iff {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (s : Finset α) :
    foamEntropy p s = s.card * Real.log 2 ↔ (s = ∅ ∨ p = 1 / 2) := by
  rw [foamEntropy_eq hp0 hp1]
  constructor
  · intro h
    rcases eq_or_ne s.card 0 with hc | hc
    · exact Or.inl (Finset.card_eq_zero.1 hc)
    · have hcard : (s.card : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hc
      have := mul_left_cancel₀ hcard h
      rw [Real.binEntropy_eq_log_two] at this
      exact Or.inr (by rw [this]; norm_num)
  · rintro (rfl | rfl)
    · simp
    · rw [show (1 : ℝ) / 2 = 2⁻¹ by norm_num, Real.binEntropy_two_inv]

/-! ### Specialisation to `N` Planck cells of the line foam -/

/-- Entropy of the stochastic foam on `N` Planck cells. -/
noncomputable def cellEntropy (p : ℝ) (N : ℕ) : ℝ :=
  foamEntropy p (Finset.univ : Finset (Fin N))

theorem cellEntropy_eq {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (N : ℕ) :
    cellEntropy p N = N * Real.binEntropy p := by
  rw [cellEntropy, foamEntropy_eq hp0 hp1]
  simp

theorem cellEntropy_le {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (N : ℕ) :
    cellEntropy p N ≤ N * Real.log 2 := by
  rw [cellEntropy_eq hp0 hp1]
  exact mul_le_mul_of_nonneg_left Real.binEntropy_le_log_two (Nat.cast_nonneg _)

/-- At the maximal-entropy excitation probability `p = 1/2`, the probability
that the Planck foam over the line is Hausdorff is exactly `2 ^ (-N)`, and it is
`< 1` as soon as there is at least one Planck cell. -/
theorem hausdorffWeight_of_maximal_entropy (ℓ : ℝ) (N : ℕ) :
    hausdorffWeight (1 / 2) ℓ N = (1 / 2) ^ N := by
  rw [hausdorffWeight_eq]
  norm_num

theorem hausdorffWeight_lt_one_of_maximal_entropy (ℓ : ℝ) {N : ℕ} (hN : 0 < N) :
    hausdorffWeight (1 / 2) ℓ N < 1 := by
  rw [hausdorffWeight_of_maximal_entropy]
  exact pow_lt_one₀ (by norm_num) (by norm_num) hN.ne'

end Stochastic
end PlanckFoam