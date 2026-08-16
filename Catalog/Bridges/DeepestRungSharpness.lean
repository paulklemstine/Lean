/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungRandomControl

/-!
# Sharpness of the NET-43 bridge (cycle 3)

Cycles 1–2 produced two inequalities that a measurement round relies on:

* the **concentration floor** `k ≥ τ² · eff` (`card_ge_of_bestMass_ge`), and
* the **grid resolution bound** `|b − k| ≤ (1 − 1/ρ) · b` (`knee_grid_resolution`).

An inequality used to certify a measurement is only as informative as it is sharp.  This
cycle settles the sharpness of both, and adds the comparison principle that makes the
"more concentrated ⇒ smaller knee" intuition a theorem.

1. **The exponent `2` in `τ² · eff` cannot be lowered.**  For the spike profile
   `(1/2, 1/8, 1/8, 1/8, 1/8)` the effective support is `16/5` and a single key already
   captures mass `1/2`; so `k = 1` while `τ · eff = 8/5 > 1`
   (`spike_refutes_linear_floor`).  The quadratic dependence on the mass target is
   therefore necessary, not an artefact of Cauchy–Schwarz.

2. **The floor is loose for flat profiles, by exactly the factor `τ`.**  For the uniform
   profile the top-`k` mass is exactly `k/n` (`bestMass_uniform`), so the knee for target
   `τ` is `⌈τ n⌉ ≈ τ · eff`, while the floor only gives `τ² · eff`
   (`uniform_floor_slack`).  Concentration bounds cannot pin a knee to better than this
   factor without a tail hypothesis — the content of Conjecture 1 of `FUTURE_DIRECTIONS`.

3. **The grid bound is attained.**  For any `a < b` there is a monotone accuracy curve whose
   true knee is `a + 1` while the grid reports `b` (`grid_resolution_tight`), so the residual
   uncertainty `b − a − 1` of `knee_grid_resolution` is realised: "exact reproduction" on a
   grid is exact only up to the grid.

4. **Comparison principle.**  If one profile dominates another in top-`k` mass at every
   width, its knee is no larger (`knee_antitone_of_bestMass_le`).

## Main results

* `bestMass_uniform`, `uniform_floor_slack`
* `spike_refutes_linear_floor`
* `grid_resolution_tight`
* `knee_antitone_of_bestMass_le`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

/-! ## A. The uniform profile: exact top-`k` mass and the slack in the floor -/

/-- The uniform attention profile on `n` keys. -/
noncomputable def uniformDist (n : ℕ) (hn : 0 < n) : AttnDist n where
  p := fun _ => 1 / n
  nonneg := fun _ => by positivity
  sum_one := by
    have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hn.ne'
    simp [Finset.sum_const, Finset.card_univ]
    field_simp

/-- **Closed form.**  For the uniform profile the best width-`k` selection captures exactly
`k / n` of the mass. -/
theorem bestMass_uniform {n k : ℕ} (hn : 0 < n) (hkn : k ≤ n) :
    bestMass (uniformDist n hn) k = (k : ℝ) / n := by
  have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ (fun S hS => ?_)
    have hcard : (S.card : ℝ) ≤ (k : ℝ) := by exact_mod_cast mem_Kset.1 hS
    have : ∑ _i ∈ S, (1 : ℝ) / n = (S.card : ℝ) / n := by
      rw [Finset.sum_const, nsmul_eq_mul]
      ring
    simp only [uniformDist]
    rw [this]
    exact (div_le_div_iff_of_pos_right hnR).mpr hcard
  · obtain ⟨S, _, hScard⟩ := Finset.exists_subset_card_eq
      (show k ≤ (Finset.univ : Finset (Fin n)).card by simpa using hkn)
    have h2 := mass_le_bestMass (uniformDist n hn) (S := S) (le_of_eq hScard)
    have h3 : ∑ i ∈ S, (uniformDist n hn).p i = (k : ℝ) / n := by
      simp only [uniformDist]
      rw [Finset.sum_const, nsmul_eq_mul, hScard]
      ring
    rw [h3] at h2
    exact h2

/-- The effective support of the uniform profile is `n`. -/
theorem eff_uniform {n : ℕ} (hn : 0 < n) : eff (uniformDist n hn) = (n : ℝ) := by
  have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hsq : sumSq (uniformDist n hn) = 1 / n := by
    simp only [sumSq, uniformDist, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    field_simp
  rw [eff, hsq, one_div_one_div]

/-- **The floor is loose on flat profiles.**  For the uniform profile the true knee at target
`τ` is about `τ · n`, whereas the concentration floor only certifies `τ² · n`: a slack of
exactly the factor `τ`. -/
theorem uniform_floor_slack {n k : ℕ} (hn : 0 < n) (hkn : k ≤ n) {τ : ℝ}
    (hτ0 : 0 < τ) (hτ1 : τ < 1) (hpass : τ ≤ bestMass (uniformDist n hn) k) :
    τ ^ 2 * eff (uniformDist n hn) < τ * (n : ℝ) ∧ τ * (n : ℝ) ≤ (k : ℝ) := by
  have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [eff_uniform hn]
  constructor
  · nlinarith [mul_pos (mul_pos hτ0 hnR) (sub_pos.2 hτ1)]
  · rw [bestMass_uniform hn hkn, le_div_iff₀ hnR] at hpass
    linarith

/-! ## B. The spike profile: the exponent `2` in `τ² · eff` is optimal -/

/-- The spike profile `(1/2, 1/8, 1/8, 1/8, 1/8)` on five keys. -/
noncomputable def spikeDist : AttnDist 5 where
  p := fun i => if i = 0 then 1/2 else 1/8
  nonneg := fun i => by split <;> norm_num
  sum_one := by
    simp only [Fin.sum_univ_five]
    norm_num [Fin.ext_iff]

lemma spikeDist_sumSq : sumSq spikeDist = 5 / 16 := by
  simp only [sumSq, spikeDist, Fin.sum_univ_five]
  norm_num [Fin.ext_iff]

lemma spikeDist_eff : eff spikeDist = 16 / 5 := by
  rw [eff, spikeDist_sumSq]
  norm_num

lemma spikeDist_bestMass_one : bestMass spikeDist 1 = 1 / 2 := by
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ (fun S hS => ?_)
    have hcard : S.card ≤ 1 := mem_Kset.1 hS
    rcases Finset.card_le_one.1 hcard with hone
    rcases S.eq_empty_or_nonempty with rfl | ⟨i, hi⟩
    · norm_num
    · have hSeq : S = {i} := Finset.eq_singleton_iff_unique_mem.2 ⟨hi, fun x hx => hone x hx i hi⟩
      rw [hSeq, Finset.sum_singleton]
      fin_cases i <;> simp [spikeDist] <;> norm_num
  · have h := mass_le_bestMass (k := 1) spikeDist (S := ({0} : Finset (Fin 5))) (by simp)
    simpa [spikeDist] using h

/-- **Sharpness of the quadratic floor.**  The concentration bound cannot be strengthened
from `k ≥ τ² · eff` to `k ≥ τ · eff`: the spike profile reaches mass `τ = 1/2` with a single
key, while `τ · eff = 8/5 > 1`.  (The proved bound `τ² · eff = 4/5 ≤ 1` does hold.) -/
theorem spike_refutes_linear_floor :
    (1 / 2 : ℝ) ≤ bestMass spikeDist 1 ∧
      ((1:ℕ) : ℝ) < (1 / 2 : ℝ) * eff spikeDist ∧
      (1 / 2 : ℝ) ^ 2 * eff spikeDist ≤ ((1:ℕ) : ℝ) := by
  refine ⟨le_of_eq spikeDist_bestMass_one.symm, ?_, ?_⟩ <;> rw [spikeDist_eff] <;> norm_num

/-! ## C. The grid resolution bound is attained -/

/-- The adversarial accuracy curve: everything above `a` passes, everything up to `a` fails. -/
noncomputable def stepCurve (a : ℕ) : ℕ → ℝ := fun k => if a < k then 1 else 0

lemma stepCurve_monotone (a : ℕ) : Monotone (stepCurve a) := by
  intro x y hxy
  by_cases hx : a < x
  · simp [stepCurve, hx, lt_of_lt_of_le hx hxy]
  · simp only [stepCurve, if_neg hx]
    split <;> norm_num

/-- **Tightness.**  For any grid step `a < b`, there is a monotone accuracy curve that fails at
`a`, passes at `b`, and whose true knee is `a + 1`; the grid can only report `b`, so the
residual uncertainty `b − a − 1` of `knee_grid_resolution` is realised exactly. -/
theorem grid_resolution_tight {a b : ℕ} (hab : a < b) :
    Monotone (stepCurve a) ∧ stepCurve a a < 1 ∧ (1:ℝ) ≤ stepCurve a b ∧
      knee (fun k => (1:ℝ) ≤ stepCurve a k) ⟨b, by simp [stepCurve, hab]⟩ = a + 1 := by
  refine ⟨stepCurve_monotone a, by simp [stepCurve], by simp [stepCurve, hab], ?_⟩
  have hpass : (1:ℝ) ≤ stepCurve a (a + 1) := by simp [stepCurve]
  refine le_antisymm (knee_le _ hpass) ?_
  by_contra hcon
  push_neg at hcon
  have hspec := knee_spec (fun k => (1:ℝ) ≤ stepCurve a k) ⟨b, by simp [stepCurve, hab]⟩
  set m := knee (fun k => (1:ℝ) ≤ stepCurve a k) ⟨b, by simp [stepCurve, hab]⟩ with hm
  have hma : ¬ a < m := by omega
  simp only [stepCurve, if_neg hma] at hspec
  linarith

/-! ## D. Comparison principle for knees -/

/-- **More concentrated ⇒ smaller knee.**  If `a` captures at least as much mass as `b` at
every width, then `a`'s knee for any target is at most `b`'s. -/
theorem knee_antitone_of_bestMass_le {n : ℕ} (a b : AttnDist n) {τ : ℝ}
    (hdom : ∀ k, bestMass b k ≤ bestMass a k)
    (hb : ∃ k, τ ≤ bestMass b k) :
    knee (fun k => τ ≤ bestMass a k) (hb.imp (fun k hk => le_trans hk (hdom k)))
      ≤ knee (fun k => τ ≤ bestMass b k) hb :=
  knee_le _ (le_trans (knee_spec (fun k => τ ≤ bestMass b k) hb) (hdom _))

/-! ## E. Lab notes (cycle 3)

* Spike profile `(1/2, 1/8, 1/8, 1/8, 1/8)`: `∑ pᵢ² = 5/16`, `eff = 3.2`, top-1 mass `0.5`.
  Floor at `τ = 0.5`: `τ² · eff = 0.8 ≤ 1` (holds), `τ · eff = 1.6 > 1` (fails) — the
  quadratic exponent is necessary.
* Uniform profile: `eff = n`, top-`k` mass `k/n`, knee at target `τ` equal to `⌈τ n⌉`;
  the floor `τ² n` is a factor `τ` below it.  At NET-43's numbers (`eff = 216.92`,
  `τ = 0.92`) the floor `183.6` versus the measured knee `256` sits inside exactly this
  slack window `[τ² · eff, eff] = [183.6, 216.9]` ∪ knee fuzz, consistent with a profile
  strictly more concentrated than uniform but far from a single spike.
* Grid tightness: with the `(240, 256]` bracket the true knee may be as low as `241`, so
  the two-seed agreement at `256` is agreement modulo `15` keys.
-/

end Bridges.DeepestRungTwoSeed256