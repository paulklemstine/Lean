import Physics.PlanckFoamConcentration
import Physics.PlanckFoamEntropy
import Physics.PlanckFoamRGFixedPoints

/-!
# Lab notes: measured data for the stochastic Planck foam

This file records the *experimental* side of the Planck-foam project.  The
`#eval` blocks below are exact rational computations of the Bernoulli foam
measure on small cell sets, run inside Lean; the theorems that follow check the
measured numbers against the general results proved in
`Physics.PlanckFoamStochastic` and `Physics.PlanckFoamConcentration`.

Measured data (exact `ℚ` arithmetic, all reproduced by the `#eval`s below):

| quantity | parameters | measured | predicted |
|---|---|---|---|
| total mass `∑ w` | `p = 1/3`, `n = 0..5` | `1,1,1,1,1,1` | `1` |
| mean `∑ w·|A|` | `p = 1/3`, `n = 4` | `4/3` | `n p = 4/3` |
| mean | `p = 2/5`, `n = 6` | `12/5` | `12/5` |
| second moment | `p = 1/3`, `n = 3` | `5/3` | `np(1-p)+(np)² = 5/3` |
| second moment | `p = 2/5`, `n = 4` | `88/25` | `88/25` |
| variance | `p = 1/3`, `n = 5` | `10/9` | `np(1-p) = 10/9` |
| variance | `p = 2/5`, `n = 6` | `36/25` | `36/25` |
| Hausdorff probability | `p = 1/2`, `N = 5` | `1/32` | `(1-p)^N = 1/32` |
| Hausdorff probability | `p = 1/3`, `N = 4` | `16/81` | `16/81` |

Float measurements of the Shannon entropy (nats):
`E(0.5, 4) = 2.772589 = 4·log 2`, `E(0.3, 5) = 3.054322 = 5·H(0.3)`,
`E(0.7, 3) = 1.832593`, `E(0.25, 6) = 3.374011`.
-/

open Finset

namespace PlanckFoam
namespace LabNotes

/-! ### Instruments: exact rational versions of the foam measure -/

/-- Rational Bernoulli weight of a configuration, for measurements. -/
def wQ (p : ℚ) {n : ℕ} (A : Finset (Fin n)) : ℚ := ∏ i : Fin n, (if i ∈ A then p else 1 - p)

/-- Measured total mass. -/
def measuredMass (p : ℚ) (n : ℕ) : ℚ := ∑ A ∈ (univ : Finset (Fin n)).powerset, wQ p A

/-- Measured mean branch number. -/
def measuredMean (p : ℚ) (n : ℕ) : ℚ := ∑ A ∈ (univ : Finset (Fin n)).powerset, wQ p A * A.card

/-- Measured second moment of the branch number. -/
def measuredSecondMoment (p : ℚ) (n : ℕ) : ℚ :=
  ∑ A ∈ (univ : Finset (Fin n)).powerset, wQ p A * (A.card : ℚ) ^ 2

/-- Measured variance of the branch number. -/
def measuredVariance (p : ℚ) (n : ℕ) : ℚ :=
  ∑ A ∈ (univ : Finset (Fin n)).powerset, wQ p A * ((A.card : ℚ) - n * p) ^ 2

/-- Measured probability that the foam is Hausdorff. -/
def measuredHausdorff (p : ℚ) (n : ℕ) : ℚ := wQ p (∅ : Finset (Fin n))

#eval (List.range 6).map (fun n => measuredMass (1/3) n)      -- [1, 1, 1, 1, 1, 1]
#eval (measuredMean (1/3) 4, measuredMean (2/5) 6)            -- (4/3, 12/5)
#eval (measuredSecondMoment (1/3) 3, measuredSecondMoment (2/5) 4)  -- (5/3, 88/25)
#eval (measuredVariance (1/3) 5, measuredVariance (2/5) 6)    -- (10/9, 36/25)
#eval (measuredHausdorff (1/2) 5, measuredHausdorff (1/3) 4)  -- (1/32, 16/81)

/-! ### Checks of the measured values against the proved general theorems -/

open PlanckFoam.Stochastic

/-- Measured mean `4/3` at `p = 1/3` over four Planck cells. -/
theorem mean_four_cells_one_third :
    ∑ A ∈ (univ : Finset (Fin 4)).powerset, cellWeight (1/3 : ℝ) A * A.card = 4 / 3 := by
  rw [expected_branch_count]
  norm_num

/-- Measured mean `12/5` at `p = 2/5` over six Planck cells. -/
theorem mean_six_cells_two_fifths :
    ∑ A ∈ (univ : Finset (Fin 6)).powerset, cellWeight (2/5 : ℝ) A * A.card = 12 / 5 := by
  rw [expected_branch_count]
  norm_num

/-- Measured variance `10/9` at `p = 1/3` over five Planck cells. -/
theorem variance_five_cells_one_third :
    ∑ A ∈ (univ : Finset (Fin 5)).powerset,
      weightOn (1/3 : ℝ) univ A * ((A.card : ℝ) - 5 * (1/3 : ℝ)) ^ 2 = 10 / 9 := by
  have h := variance_branch_count (1/3 : ℝ) (univ : Finset (Fin 5))
  rw [Finset.card_univ, Fintype.card_fin] at h
  rw [show ((5 : ℕ) : ℝ) = (5 : ℝ) by norm_num] at h
  rw [h]
  norm_num

/-- Measured Hausdorff probability `1/32` at the maximally foamy `p = 1/2`
over five Planck cells. -/
theorem hausdorff_five_cells_half (ℓ : ℝ) : hausdorffWeight (1/2 : ℝ) ℓ 5 = 1 / 32 := by
  rw [hausdorffWeight_eq]
  norm_num

/-- Measured Hausdorff probability `16/81` at `p = 1/3` over four Planck cells. -/
theorem hausdorff_four_cells_one_third (ℓ : ℝ) : hausdorffWeight (1/3 : ℝ) ℓ 4 = 16 / 81 := by
  rw [hausdorffWeight_eq]
  norm_num

/-- Measured entropy of the maximally foamy state on four cells: exactly four
bits, i.e. `4 log 2`. -/
theorem entropy_four_cells_half :
    cellEntropy (1/2 : ℝ) 4 = 4 * Real.log 2 := by
  rw [cellEntropy_eq (by norm_num) (by norm_num)]
  rw [show (1/2 : ℝ) = 2⁻¹ by norm_num, Real.binEntropy_two_inv]
  norm_num

/-! ### Cycle-2 measurements: excess, metric defect and the renormalisation tower

Measured data (all reproduced by the `#eval`s below):

| quantity | parameters | measured | predicted |
|---|---|---|---|
| lattice sites in `[-16,16]` | spacings `1,2,4,8,16` | `33,17,9,5,3` | halving per RG step |
| foam excess `\|S\|·(\|ι\|-1)` | `\|S\| = 3`, `\|ι\| = 2,3,4` | `3,6,9` | `card_foam_eq_card_add_excess` |
| metric defect `\|∂S\|·(\|ι\|²-\|ι\|)` | `\|∂S\| = 1,2,3`, `\|ι\| = 2` | `2,4,6` | `card_defectSet` |
| metric defect | `\|∂S\| = 2`, `\|ι\| = 3,4` | `12,24` | `card_defectSet` |
-/

/-- Number of lattice sites of integer spacing `l` inside the window
`[-L, L]` — the observable that the renormalisation flow halves. -/
def siteCount (l L : ℕ) : ℕ :=
  ((Finset.Icc (-(L : ℤ)) (L : ℤ)).filter (fun m => (l : ℤ) ∣ m)).card

/-- Predicted foam excess: one extra point per branch point per extra sheet. -/
def excessCount (b n : ℕ) : ℕ := b * (n - 1)

/-- Predicted metric defect: off-diagonal branch pairs over each boundary
point. -/
def defectCount (b n : ℕ) : ℕ := b * (n * n - n)

#eval [1, 2, 4, 8, 16].map (fun l => siteCount l 16)   -- [33, 17, 9, 5, 3]
#eval [2, 3, 4].map (fun n => excessCount 3 n)         -- [3, 6, 9]
#eval [1, 2, 3].map (fun b => defectCount b 2)         -- [2, 4, 6]
#eval [3, 4].map (fun n => defectCount 2 n)            -- [12, 24]

/-- Measured metric defect `2` for a single Planck branch point on the line with
two sheets. -/
theorem defect_one_site : Nat.card (defectSet ℝ ({0} : Set ℝ) Bool) = 2 :=
  card_defectSet_line_point

/-- Measured metric defect `4` for two Planck branch points on the line with two
sheets: the defect is additive over boundary points. -/
theorem defect_two_sites : Nat.card (defectSet ℝ ({0, 1} : Set ℝ) Bool) = 4 := by
  have hfin : ({0, 1} : Set ℝ).Finite := (Set.finite_singleton (1 : ℝ)).insert 0
  rw [card_defectSet_bool, Stochastic.interior_eq_empty_of_finite hfin, Set.diff_empty,
    Nat.card_coe_set_eq, Set.ncard_pair (by norm_num : (0 : ℝ) ≠ 1)]

/-- Measured RG datum: the spacing-`2` lattice foam is a strict coarse graining
of the spacing-`1` lattice foam, so one step of the flow destroys information. -/
theorem rg_step_loses_information :
    ¬ Function.Injective
      (foamCollapse (ι := Bool) (latticeSet 1) (latticeSet (2 * 1))
        (latticeSet_two_mul_subset 1)) :=
  foamCollapse_not_injective_of_ne_zero one_ne_zero

end LabNotes
end PlanckFoam