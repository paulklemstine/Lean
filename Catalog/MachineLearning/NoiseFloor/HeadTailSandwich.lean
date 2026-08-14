/-
# The Noise-Floor Principle, Part IV: the head/tail sandwich

Round-6 hypothesis closure, Phase A, cycle 2.

Parts I–III computed the noise floor exactly (`b · d_eff`, a resolvent trace).
This file explains *what that number is made of*.  Splitting the spectrum at the
noise level into a **head** `{i : b ≤ a i}` (resolvable modes) and a **tail**
`{i : a i < b}` (modes drowned in noise), we prove the two-sided estimate

  `(1/2) * (b * #head + ∑_{tail} a i)  ≤  noiseFloor a b  ≤  b * #head + ∑_{tail} a i`,

i.e. *the irreducible risk is, up to a factor two, one unit of noise per
resolvable mode plus the entire energy of the drowned modes*.  Both constants
are attained, so the factor two cannot be removed by any sharper argument that
only sees `min (a i) b`.

Two consequences of independent interest:

* `no_learning_below_noise` — if every mode is below the noise level, **no**
  spectral filter beats the do-nothing estimator by more than a factor two;
* `saturation_above_noise`  — if every mode is above the noise level, the floor
  is at least `n b / 2`, so risk grows linearly in the ambient dimension.

## Main results

* `mode_min_sandwich`, `minSum_head_tail`
* `noiseFloor_le_minSum`, `half_minSum_le_noiseFloor`
* `no_learning_below_noise`, `saturation_above_noise`
* `sandwich_upper_sharp`, `sandwich_lower_sharp` — sharpness of both constants
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension
import MachineLearning.NoiseFloor.NoiseFloorPrinciple

namespace Catalog.MachineLearning.NoiseFloor

open Finset

variable {ι : Type*} [Fintype ι]

/-- `∑ i, min (a i) b`: one noise unit per resolvable mode plus the energy of the
drowned modes. -/
noncomputable def minSum (a : ι → ℝ) (b : ℝ) : ℝ := ∑ i, min (a i) b

section Mode

variable {x b : ℝ}

/-- Per-mode sandwich: the harmonic term `xb/(x+b)` is between `min x b / 2` and
`min x b`. -/
lemma mode_min_sandwich (hx : 0 ≤ x) (hb : 0 < b) :
    min x b / 2 ≤ x * b / (x + b) ∧ x * b / (x + b) ≤ min x b := by
  have hd : 0 < x + b := by linarith
  constructor
  · rcases le_total x b with h | h
    · rw [min_eq_left h, div_le_div_iff₀ (by norm_num) hd]
      nlinarith
    · rw [min_eq_right h, div_le_div_iff₀ (by norm_num) hd]
      nlinarith
  · refine le_min ?_ ?_
    · rw [div_le_iff₀ hd]; nlinarith
    · rw [div_le_iff₀ hd]; nlinarith

end Mode

section Sandwich

variable {a : ι → ℝ} {b : ℝ}

/-- **Upper half of the sandwich.** -/
theorem noiseFloor_le_minSum (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    noiseFloor a b ≤ minSum a b := by
  rw [noiseFloor_eq_sum, minSum]
  exact Finset.sum_le_sum fun i _ => (mode_min_sandwich (ha i) hb).2

/-- **Lower half of the sandwich.** -/
theorem half_minSum_le_noiseFloor (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    minSum a b / 2 ≤ noiseFloor a b := by
  rw [noiseFloor_eq_sum, minSum, Finset.sum_div]
  exact Finset.sum_le_sum fun i _ => (mode_min_sandwich (ha i) hb).1

/-- **Head/tail decomposition** of the sandwich quantity: `b` per resolvable mode
plus the full energy of the drowned modes. -/
theorem minSum_head_tail [DecidableEq ι] (a : ι → ℝ) (b : ℝ) :
    minSum a b = b * ((univ.filter fun i => b ≤ a i).card : ℝ)
      + ∑ i ∈ univ.filter fun i => a i < b, a i := by
  classical
  have hsplit := Finset.sum_filter_add_sum_filter_not univ (fun i => b ≤ a i)
    (fun i => min (a i) b)
  have h1 : ∑ i ∈ univ.filter fun i => b ≤ a i, min (a i) b
      = b * ((univ.filter fun i => b ≤ a i).card : ℝ) := by
    rw [Finset.sum_congr rfl fun i hi => min_eq_right (mem_filter.1 hi).2]
    rw [Finset.sum_const, nsmul_eq_mul, mul_comm]
  have h2 : ∑ i ∈ univ.filter fun i => ¬ b ≤ a i, min (a i) b
      = ∑ i ∈ univ.filter fun i => a i < b, a i := by
    have hfe : (univ.filter fun i => ¬ b ≤ a i) = univ.filter fun i => a i < b := by
      apply Finset.filter_congr
      intro i _
      simp [not_le]
    rw [hfe]
    exact Finset.sum_congr rfl fun i hi => min_eq_left (le_of_lt (mem_filter.1 hi).2)
  rw [minSum, ← hsplit, h1, h2]

/-- **No learning below the noise floor.**  If every mode is drowned
(`a i ≤ b`), then the best spectral filter in existence improves on the
do-nothing estimator `t = 0` by at most a factor of two. -/
theorem no_learning_below_noise (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (hsmall : ∀ i, a i ≤ b) :
    filterRisk a b (fun _ => 0) / 2 ≤ noiseFloor a b := by
  have hrisk : filterRisk a b (fun _ => 0) = ∑ i, a i := by
    rw [filterRisk]
    exact Finset.sum_congr rfl fun i _ => by ring
  have hmin : minSum a b = ∑ i, a i :=
    Finset.sum_congr rfl fun i _ => min_eq_left (hsmall i)
  have := half_minSum_le_noiseFloor ha hb
  rw [hmin] at this
  rw [hrisk]
  exact this

/-- **Saturation above the noise floor.**  If every mode is resolvable
(`b ≤ a i`), the floor is at least `n b / 2`: the irreducible risk grows
linearly in the ambient dimension however clever the filter. -/
theorem saturation_above_noise (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (hbig : ∀ i, b ≤ a i) :
    (Fintype.card ι : ℝ) * b / 2 ≤ noiseFloor a b := by
  have hmin : minSum a b = (Fintype.card ι : ℝ) * b := by
    rw [minSum, Finset.sum_congr rfl fun i _ => min_eq_right (hbig i)]
    rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  have h := half_minSum_le_noiseFloor ha hb
  rw [hmin] at h
  linarith

end Sandwich

section Sharpness

/-- The upper constant `1` is attained in the limit of a single dominant mode:
for `a = (b)` with one mode, floor `= b/2 = minSum/2`, so the *lower* constant
`1/2` is attained exactly. -/
theorem sandwich_lower_sharp :
    noiseFloor (fun _ : Fin 1 => (1 : ℝ)) 1 = minSum (fun _ : Fin 1 => (1 : ℝ)) 1 / 2 := by
  rw [noiseFloor_eq_sum, minSum]
  simp
  norm_num

/-- The upper constant is approached along a spectrum degenerating to a single
tiny mode: with `a = (ε)` and `b = 1`, the floor is `ε/(1+ε)`, which is
`minSum · (1/(1+ε))`.  At `ε = 0` the two sides agree. -/
theorem sandwich_upper_sharp (ε : ℝ) (hε : 0 ≤ ε) (hε1 : ε ≤ 1) :
    noiseFloor (fun _ : Fin 1 => ε) 1 = minSum (fun _ : Fin 1 => ε) 1 * (1 / (ε + 1)) := by
  rw [noiseFloor_eq_sum, minSum]
  simp only [Finset.univ_unique, Finset.sum_singleton, min_eq_left hε1]
  field_simp

end Sharpness

end Catalog.MachineLearning.NoiseFloor