/-
# The Noise-Floor Principle, Part VIII: a formal scaling law

Round-6 hypothesis closure, Phase A, cycle 5.

Neural scaling laws assert that the irreducible risk of a model decays like a
power (or a power times a log) of the amount of data.  Parts I–VII reduce the
irreducible risk to the single functional `noiseFloor a b`, so a scaling law is
now a *computation with a fixed spectrum*, not a modelling assumption.

We carry this out for the geometric (exponentially decaying) spectrum
`a i = r ^ i`, `0 < r < 1`, at noise level `b = σ²/N`.  The head/tail sandwich
of Part IV yields matching bounds

  `b (m+1) / 2  ≤  noiseFloor  ≤  b (m+1) + r^{m+1} / (1 - r)`

for every cut index `m`, and taking the natural cut `r^{m+1} ≤ b ≤ r^m` gives

  `b (m+1) / 2  ≤  noiseFloor  ≤  b (m+1) + b / (1 - r)`,

i.e. `noiseFloor ≍ b · m ≍ b · log(1/b) / log(1/r)`: **the log-corrected `1/N`
law**, derived rather than assumed.

## Main results

* `noiseFloor_geom_eq`        — the floor of a geometric spectrum as a range sum
* `geometric_scaling_upper`   — upper bound for every cut `m`
* `geometric_scaling_lower`   — matching lower bound when `b ≤ r^m`
* `geometric_scaling_law`     — the two-sided law at the natural cut
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension
import MachineLearning.NoiseFloor.NoiseFloorPrinciple
import MachineLearning.NoiseFloor.HeadTailSandwich

namespace Catalog.MachineLearning.NoiseFloor

open Finset

section Geometric

variable {r b : ℝ}

/-- The noise floor of the geometric spectrum, as a sum over `range n`. -/
lemma noiseFloor_geom_eq (r b : ℝ) (n : ℕ) :
    noiseFloor (fun i : Fin n => r ^ (i : ℕ)) b
      = ∑ i ∈ Finset.range n, r ^ i * b / (r ^ i + b) := by
  rw [noiseFloor_eq_sum]
  exact Fin.sum_univ_eq_sum_range (fun i => r ^ i * b / (r ^ i + b)) n

/-- Geometric tail bound `∑_{i ∈ [k, n)} r^i ≤ r^k / (1-r)`. -/
lemma geom_tail_le (hr0 : 0 < r) (hr1 : r < 1) (k n : ℕ) :
    ∑ i ∈ Finset.Ico k n, r ^ i ≤ r ^ k / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  rw [Finset.sum_Ico_eq_sum_range]
  have hfac : ∑ j ∈ Finset.range (n - k), r ^ (k + j)
      = r ^ k * ∑ j ∈ Finset.range (n - k), r ^ j := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun j _ => by rw [pow_add]
  rw [hfac]
  have hgeom : ∑ j ∈ Finset.range (n - k), r ^ j ≤ 1 / (1 - r) := by
    rw [geom_sum_eq (by linarith : r ≠ 1)]
    have hK : (r ^ (n - k) - 1) / (r - 1) = (1 - r ^ (n - k)) / (1 - r) := by
      rw [div_eq_div_iff (by linarith : r - 1 ≠ 0) (by linarith : (1:ℝ) - r ≠ 0)]
      ring
    rw [hK, div_le_div_iff₀ h1r h1r]
    nlinarith [pow_nonneg hr0.le (n - k)]
  have hrk : (0:ℝ) ≤ r ^ k := pow_nonneg hr0.le k
  calc r ^ k * ∑ j ∈ Finset.range (n - k), r ^ j ≤ r ^ k * (1 / (1 - r)) := by
        exact mul_le_mul_of_nonneg_left hgeom hrk
    _ = r ^ k / (1 - r) := by ring

/-- **Upper scaling bound.**  For every cut index `m`, the noise floor of a
geometric spectrum is at most `b(m+1)` (one noise unit per resolvable mode) plus
the geometric tail. -/
theorem geometric_scaling_upper (hr0 : 0 < r) (hr1 : r < 1) (hb : 0 < b) (n m : ℕ) :
    noiseFloor (fun i : Fin n => r ^ (i : ℕ)) b ≤ b * (m + 1) + r ^ (m + 1) / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  rw [noiseFloor_geom_eq]
  have hterm : ∀ i ∈ Finset.range n,
      r ^ i * b / (r ^ i + b) ≤ min (r ^ i) b := fun i _ =>
    (mode_min_sandwich (pow_nonneg hr0.le i) hb).2
  refine (Finset.sum_le_sum hterm).trans ?_
  have htail0 : (0:ℝ) ≤ r ^ (m + 1) / (1 - r) := by positivity
  rcases le_or_gt n (m + 1) with hn | hn
  · have hle : ∑ i ∈ Finset.range n, min (r ^ i) b ≤ ∑ _i ∈ Finset.range n, b :=
      Finset.sum_le_sum fun i _ => min_le_right _ _
    rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hle
    have hnb : (n : ℝ) * b ≤ b * (m + 1) := by
      have : (n : ℝ) ≤ (m : ℝ) + 1 := by exact_mod_cast hn
      nlinarith
    linarith
  · rw [← Finset.sum_range_add_sum_Ico _ (le_of_lt hn)]
    have hhead : ∑ i ∈ Finset.range (m + 1), min (r ^ i) b ≤ b * (m + 1) := by
      have := Finset.sum_le_sum (fun i (_ : i ∈ Finset.range (m + 1)) => min_le_right (r ^ i) b)
      rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at this
      push_cast at this ⊢
      linarith
    have htail : ∑ i ∈ Finset.Ico (m + 1) n, min (r ^ i) b ≤ r ^ (m + 1) / (1 - r) := by
      refine le_trans (Finset.sum_le_sum fun i _ => min_le_left (r ^ i) b) ?_
      exact geom_tail_le hr0 hr1 (m + 1) n
    linarith

/-- **Lower scaling bound.**  If the mode `m` is still above the noise level,
then at least `m+1` modes are resolvable and each costs `b/2`. -/
theorem geometric_scaling_lower (hr0 : 0 < r) (hr1 : r < 1) (hb : 0 < b) {n m : ℕ}
    (hmn : m + 1 ≤ n) (hbm : b ≤ r ^ m) :
    b * (m + 1) / 2 ≤ noiseFloor (fun i : Fin n => r ^ (i : ℕ)) b := by
  rw [noiseFloor_geom_eq]
  have hsub : Finset.range (m + 1) ⊆ Finset.range n := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have hnonneg : ∀ i ∈ Finset.range n, i ∉ Finset.range (m + 1) →
      0 ≤ r ^ i * b / (r ^ i + b) := by
    intro i _ _
    have hp : (0:ℝ) ≤ r ^ i := pow_nonneg hr0.le i
    have : 0 < r ^ i + b := by linarith
    positivity
  refine le_trans ?_ (Finset.sum_le_sum_of_subset_of_nonneg hsub hnonneg)
  have hhead : ∀ i ∈ Finset.range (m + 1), b / 2 ≤ r ^ i * b / (r ^ i + b) := by
    intro i hi
    have him : i ≤ m := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
    have hri : r ^ m ≤ r ^ i := pow_le_pow_of_le_one hr0.le hr1.le him
    have hbi : b ≤ r ^ i := le_trans hbm hri
    have hp : (0:ℝ) < r ^ i + b := by linarith
    rw [div_le_div_iff₀ (by norm_num) hp]
    nlinarith
  have := Finset.sum_le_sum hhead
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at this
  push_cast at this
  linarith

/-- **The geometric scaling law.**  At the natural cut `r^{m+1} ≤ b ≤ r^m` the
noise floor is pinned between `b(m+1)/2` and `b(m+1) + b/(1-r)`; since
`m ≍ log(1/b)/log(1/r)`, the irreducible risk obeys the log-corrected law
`noiseFloor ≍ b log(1/b)`. -/
theorem geometric_scaling_law (hr0 : 0 < r) (hr1 : r < 1) (hb : 0 < b) {n m : ℕ}
    (hmn : m + 1 ≤ n) (hbm : b ≤ r ^ m) (hbm' : r ^ (m + 1) ≤ b) :
    b * (m + 1) / 2 ≤ noiseFloor (fun i : Fin n => r ^ (i : ℕ)) b ∧
      noiseFloor (fun i : Fin n => r ^ (i : ℕ)) b ≤ b * (m + 1) + b / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  refine ⟨geometric_scaling_lower hr0 hr1 hb hmn hbm, ?_⟩
  have hup := geometric_scaling_upper hr0 hr1 hb n m
  have htail : r ^ (m + 1) / (1 - r) ≤ b / (1 - r) := by
    gcongr
  linarith

/-- A concrete non-vacuous instance: `r = 1/2`, `b = 1/10`, `n = 10` modes.  The
natural cut is `m = 3` (`(1/2)^4 ≤ 1/10 ≤ (1/2)^3`), so the floor lies between
`0.2` and `0.6`. -/
theorem geometric_scaling_law_example :
    (1 / 10 : ℝ) * ((3 : ℕ) + 1) / 2
        ≤ noiseFloor (fun i : Fin 10 => (1 / 2 : ℝ) ^ (i : ℕ)) (1 / 10) ∧
      noiseFloor (fun i : Fin 10 => (1 / 2 : ℝ) ^ (i : ℕ)) (1 / 10)
        ≤ (1 / 10 : ℝ) * ((3 : ℕ) + 1) + (1 / 10) / (1 - 1 / 2) :=
  geometric_scaling_law (r := 1 / 2) (b := 1 / 10) (n := 10) (m := 3)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)

end Geometric

end Catalog.MachineLearning.NoiseFloor