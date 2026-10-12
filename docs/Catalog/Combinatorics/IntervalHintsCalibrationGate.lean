/-
# ET-HINTS-FULL (III): the calibration gate (FACT round 40 #4, paper 148)

A hint is a *signal*: with probability `r` it fires and the searcher's posterior becomes `q`,
otherwise it becomes `q'`; truthfulness (calibration) means the prior splits as
`p = r q + (1 - r) q'`.  The round-39 model (`Logic.IntervalHintsTwoNumbers`) uses posteriors
that are *uniform given a hit*: `q j = α / W` on the window.

## Main results
* **`uniform_hit_mass_le`** — calibration forces `r α ≤ W · p j` for every window cell `j`:
  the hit mass of a uniform-given-hit hint is capped by the *lightest* window cell.
* **`signal_value_le`** — the expected saving of any calibrated signal is at most `r (n - 1)`
  probes (value of information is linear in the firing rate).
* **`right_uniform_gate`** — under the min-law prior with a right-placed window,
  `r α ≤ W / M²`, and `α · (expected saving) < W / M = x`: a uniform-given-hit right hint saves
  fewer than `x / α` probes on average — it can never produce gains of the order of the blind
  cost `≈ M/3` (no magnitude-ordering gains).
* `right_calibrated_trust` — the calibrated trust of a right window is `x² = W²/M²`; the
  `√N`-style rightmost commitment has calibrated capacity `→ 0`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): uniform-given-hit hints exist only at tiny coverage.
Experiment (Stage 2): `M = 512`, right `x = 1/16` (`W = 32`): cap `r α ≤ 32/512² ≈ 1.2e-4`;
  saving bound `α · saving < 1/16` probe vs blind cost `171.17`.  Left `x = 1/16`: the lightest
  window cell has mass `(2·480+1)/512² ≈ 3.7e-3`, cap `r α ≤ 0.117` — not tiny.
Analysis (Stage 3): the gate is a property of the *lightest* window cell, so it is a
  right-placement phenomenon under the min-law; for left windows the uniform family is
  merely limited (`≈ 2x(1-x)`), not negligible.
Critique (Stage 4): the bound uses only calibration and non-negativity; no symmetry or
  continuum assumption.
-/
import Combinatorics.IntervalHintsPlacementCeilings

namespace IntervalHintsCalibrationGate

open Finset IntervalHintsTwoNumbers IntervalHintsHedgingHump IntervalHintsPlacementCeilings

variable {n : ℕ}

/-- **Calibration caps the hit mass.**  If a signal firing with probability `r ≤ 1` produces a
posterior that is uniform (`α / W`) on the window `S`, then `r α / W ≤ p j` for every `j ∈ S`. -/
theorem uniform_hit_mass_le (p q q' : Fin n → ℝ) (r α : ℝ) (W : ℕ) (hr1 : r ≤ 1)
    (hq' : ∀ j, 0 ≤ q' j) (hsplit : ∀ j, p j = r * q j + (1 - r) * q' j)
    (S : Finset (Fin n)) (hunif : ∀ j ∈ S, q j = α / W) :
    ∀ j ∈ S, r * α / W ≤ p j := by
  intro j hj
  rw [hsplit j, hunif j hj, mul_div_assoc]
  have := mul_nonneg (sub_nonneg.2 hr1) (hq' j)
  linarith

lemma probeCost_le_card (q : Fin n → ℝ) (hq : ∀ j, 0 ≤ q j) (hs : ∑ j, q j = 1)
    (σ : Equiv.Perm (Fin n)) : probeCost q σ ≤ n := by
  unfold probeCost
  calc ∑ i : Fin n, (((i : ℕ) : ℝ) + 1) * q (σ i) ≤ ∑ i : Fin n, (n : ℝ) * q (σ i) := by
        refine sum_le_sum fun i _ => mul_le_mul_of_nonneg_right ?_ (hq _)
        have : (i : ℕ) + 1 ≤ n := i.isLt
        exact_mod_cast this
    _ = n := by rw [← mul_sum, Equiv.sum_comp σ q, hs, mul_one]

lemma one_le_optCost (q : Fin n → ℝ) (hq : ∀ j, 0 ≤ q j) (hs : ∑ j, q j = 1) :
    1 ≤ optCost q := by
  unfold optCost
  refine le_inf' _ _ fun σ _ => ?_
  unfold probeCost
  calc (1 : ℝ) = ∑ i : Fin n, 1 * q (σ i) := by rw [← mul_sum, Equiv.sum_comp σ q, hs, one_mul]
    _ ≤ _ := sum_le_sum fun i _ => mul_le_mul_of_nonneg_right
        (by have : (0 : ℝ) ≤ (i : ℕ) := Nat.cast_nonneg _; linarith) (hq _)

/-- **Value of a calibrated signal is linear in its firing rate.**  The expected saving of the
Bayes-optimal searcher who listens to the signal is at most `r (n - 1)` probes. -/
theorem signal_value_le (p q q' : Fin n → ℝ) (r : ℝ) (hr0 : 0 ≤ r)
    (hq : ∀ j, 0 ≤ q j) (hqs : ∑ j, q j = 1) (hsplit : ∀ j, p j = r * q j + (1 - r) * q' j) :
    optCost p - (r * optCost q + (1 - r) * optCost q') ≤ r * ((n : ℝ) - 1) := by
  obtain ⟨σ, -, hσ⟩ := exists_mem_eq_inf' (univ_nonempty (α := Equiv.Perm (Fin n)))
    (fun σ => probeCost q' σ)
  have hp : p = fun j => r * q j + (1 - r) * q' j := funext hsplit
  have h1 : optCost p ≤ probeCost p σ := inf'_le _ (mem_univ _)
  rw [hp, probeCost_mix] at h1
  have h2 := probeCost_le_card q hq hqs σ
  have h3 := one_le_optCost q hq hqs
  have h4 : optCost q' = probeCost q' σ := hσ
  rw [hp] at *
  nlinarith

/-- **The calibration gate (min-law, right window).**  A calibrated uniform-given-hit hint on
the right window of width `W` has hit mass `r α ≤ W / M²`, and coverage times expected saving
is below `W / M = x`. -/
theorem right_uniform_gate (M W : ℕ) (hW : 0 < W) (hWM : W ≤ M)
    (q q' : Fin M → ℝ) (r α : ℝ) (hα : 0 ≤ α) (hr0 : 0 ≤ r) (hr1 : r ≤ 1)
    (hq : ∀ j, 0 ≤ q j) (hqs : ∑ j, q j = 1) (hq' : ∀ j, 0 ≤ q' j)
    (hsplit : ∀ j, minPrior M j = r * q j + (1 - r) * q' j)
    (hunif : ∀ j ∈ rightWindow M W, q j = α / W) :
    r * α ≤ (W : ℝ) / (M : ℝ) ^ 2 ∧
      α * (optCost (minPrior M) - (r * optCost q + (1 - r) * optCost q')) < (W : ℝ) / M := by
  have hM : 0 < M := by omega
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  set last : Fin M := ⟨M - 1, by omega⟩
  have hlast : last ∈ rightWindow M W := by simp [rightWindow, last]; omega
  have hplast : minPrior M last = 1 / (M : ℝ) ^ 2 := by
    simp only [minPrior, minLaw, last]
    rw [Nat.cast_sub (by omega)]; push_cast; ring
  have hcap := uniform_hit_mass_le (minPrior M) q q' r α W hr1 hq' hsplit _ hunif last hlast
  rw [hplast, div_le_div_iff₀ hW' (by positivity)] at hcap
  have hra : r * α ≤ (W : ℝ) / (M : ℝ) ^ 2 := by
    rw [le_div_iff₀ (by positivity)]; linarith
  refine ⟨hra, ?_⟩
  have hval := signal_value_le (minPrior M) q q' r hr0 hq hqs hsplit
  have hM1 : (0 : ℝ) ≤ (M : ℝ) - 1 := by
    have : (1 : ℝ) ≤ M := by exact_mod_cast hM
    linarith
  calc α * (optCost (minPrior M) - (r * optCost q + (1 - r) * optCost q'))
      ≤ α * (r * ((M : ℝ) - 1)) := mul_le_mul_of_nonneg_left hval hα
    _ = (r * α) * ((M : ℝ) - 1) := by ring
    _ ≤ (W : ℝ) / (M : ℝ) ^ 2 * ((M : ℝ) - 1) := mul_le_mul_of_nonneg_right hra hM1
    _ < (W : ℝ) / M := by
        rw [div_mul_eq_mul_div, div_lt_div_iff₀ (by positivity) hM']
        nlinarith

/-- **Calibrated capacity of the rightmost commitment.**  The right window of width `W` carries
prior mass `W²/M² = x²`, so the calibrated trust of a "start at the right end" commitment
vanishes quadratically in the window fraction. -/
theorem right_calibrated_trust (M W : ℕ) (hWM : W ≤ M) :
    windowMass (minPrior M) (rightWindow M W) = (W : ℝ) ^ 2 / (M : ℝ) ^ 2 := by
  rw [← right_mass M W hWM]
  unfold windowMass minPrior rightWindow
  rw [sum_filter, Fin.sum_univ_eq_sum_range (fun i => if M - W ≤ i then minLaw M i else 0),
    ← sum_filter]
  have : (range M).filter (fun i => M - W ≤ i) = (range W).map (addLeftEmbedding (M - W)) := by
    ext i
    simp only [mem_filter, mem_range, mem_map, addLeftEmbedding_apply]
    constructor
    · intro h; exact ⟨i - (M - W), by omega, by omega⟩
    · rintro ⟨a, ha, rfl⟩; omega
  rw [this, sum_map]
  rfl

end IntervalHintsCalibrationGate