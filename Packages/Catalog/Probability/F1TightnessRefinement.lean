import Mathlib
import Probability.F1TightnessCore

/-!
# Grid refinement raises the measured slack (paper 250, profile half)

`Probability.F1TightnessDiscretisation` settled the *scalar* half of the
discretisation question: at a **fixed** mean probe position `E < 1/2` the
grid-dependent slack `X_M(E) = (M+1)/(2ME+1)` increases in `M`.  That statement
holds the profile fixed, which is not what happens when a grid is refined: both
the number of cells *and* the measured mean position change.

This file closes the profile half in the dyadic setting.  A profile is presented
as a function `g : ℕ → ℝ` read on the first `2M` cells; its **coarsening**
merges cells pairwise, `coarseFn g j = g (2j) + g (2j+1)`, giving an `M`-cell
profile with the same total mass.  The two measured mean positions differ by an
explicit non-negative amount on a front-loaded profile, and the resulting
comparison of slack factors is strict:

* `meanPos_coarseFn` — the exact identity
  `E_coarse = E_fine + (∑_{j<M} (g(2j) − g(2j+1)))/(4M)`;
* `meanPos_coarseFn_le` — coarsening moves the mean position *forward* when the
  profile is front-loaded pairwise;
* `gapX_coarseFn_lt` — **the coarse grid strictly underestimates the slack**:
  `X(coarse) < X(fine)` whenever the fine mean position is below `1/2`;
* `refinement_increases_slack` — the packaged statement, phrased for an antitone
  profile.

Together with `finite_grid_underestimates` this says that every reported slack
value computed on a finite grid is a *lower* bound: the booked `X = 1.15302`
computed on 27 cells can be read one-sidedly.
-/

namespace F1Tightness

open Finset

/-- The dyadic coarsening of a cell profile presented as a function on `ℕ`:
cells `2j` and `2j+1` are merged. -/
def coarseFn (g : ℕ → ℝ) (j : ℕ) : ℝ := g (2 * j) + g (2 * j + 1)

/-- Splitting a sum over `2M` indices into `M` consecutive pairs. -/
theorem sum_range_two_mul (g : ℕ → ℝ) (M : ℕ) :
    ∑ i ∈ range (2 * M), g i = ∑ j ∈ range M, (g (2 * j) + g (2 * j + 1)) := by
  induction M with
  | zero => simp
  | succ n ih =>
      have h : 2 * (n + 1) = 2 * n + 1 + 1 := by ring
      rw [h, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, ih]
      ring

/-- Coarsening preserves the total mass. -/
theorem sum_coarseFn (g : ℕ → ℝ) (M : ℕ) :
    ∑ j : Fin M, coarseFn g (j : ℕ) = ∑ i : Fin (2 * M), g (i : ℕ) := by
  rw [Fin.sum_univ_eq_sum_range (fun j => coarseFn g j) M,
    Fin.sum_univ_eq_sum_range (fun i => g i) (2 * M), sum_range_two_mul]
  rfl

/-- Coarsening preserves non-negativity. -/
theorem coarseFn_nonneg {g : ℕ → ℝ} (hg : ∀ i, 0 ≤ g i) (j : ℕ) : 0 ≤ coarseFn g j :=
  add_nonneg (hg _) (hg _)

/-- **The exact refinement identity for the mean probe position.**  Merging the
cells pairwise moves the measured mean position by
`(∑_{j<M} (g(2j) − g(2j+1)))/(4M)`. -/
theorem meanPos_coarseFn {M : ℕ} (hM : 0 < M) (g : ℕ → ℝ) :
    meanPos (fun j : Fin M => coarseFn g (j : ℕ))
      = meanPos (fun i : Fin (2 * M) => g (i : ℕ))
        + (∑ j ∈ range M, (g (2 * j) - g (2 * j + 1))) / (4 * (M : ℝ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hfine :
      meanPos (fun i : Fin (2 * M) => g (i : ℕ))
        = ∑ j ∈ range M,
            (((2 * (j : ℝ) + 1 / 2) / (2 * (M : ℝ))) * g (2 * j)
              + ((2 * (j : ℝ) + 3 / 2) / (2 * (M : ℝ))) * g (2 * j + 1)) := by
    rw [meanPos]
    rw [Fin.sum_univ_eq_sum_range
      (fun i => ((((i : ℕ) : ℝ) + 1 / 2) / ((2 * M : ℕ) : ℝ)) * g i) (2 * M)]
    rw [sum_range_two_mul]
    refine Finset.sum_congr rfl fun j _ => ?_
    push_cast
    ring
  have hcoarse :
      meanPos (fun j : Fin M => coarseFn g (j : ℕ))
        = ∑ j ∈ range M,
            (((j : ℝ) + 1 / 2) / (M : ℝ)) * (g (2 * j) + g (2 * j + 1)) := by
    rw [meanPos]
    rw [Fin.sum_univ_eq_sum_range
      (fun j => ((((j : ℕ) : ℝ) + 1 / 2) / ((M : ℕ) : ℝ)) * coarseFn g j) M]
    rfl
  rw [hcoarse, hfine, Finset.sum_div, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  field_simp
  ring

/-- On a pairwise front-loaded profile, coarsening moves the mean position
forward. -/
theorem meanPos_coarseFn_le {M : ℕ} (hM : 0 < M) {g : ℕ → ℝ}
    (hfront : ∀ j, j < M → g (2 * j + 1) ≤ g (2 * j)) :
    meanPos (fun i : Fin (2 * M) => g (i : ℕ))
      ≤ meanPos (fun j : Fin M => coarseFn g (j : ℕ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hD : 0 ≤ ∑ j ∈ range M, (g (2 * j) - g (2 * j + 1)) :=
    Finset.sum_nonneg fun j hj => by
      have := hfront j (Finset.mem_range.mp hj); linarith
  rw [meanPos_coarseFn hM g]
  have : 0 ≤ (∑ j ∈ range M, (g (2 * j) - g (2 * j + 1))) / (4 * (M : ℝ)) := by positivity
  linarith

/-- **The coarse grid strictly underestimates the slack.**  If the fine-grid mean
probe position is front-loaded (`< 1/2`) and the profile is pairwise decreasing,
then the slack factor computed after merging cells is strictly smaller than the
one computed on the fine grid. -/
theorem gapX_coarseFn_lt {M : ℕ} (hM : 0 < M) {g : ℕ → ℝ}
    (hg : ∀ i, 0 ≤ g i) (hsum : ∑ i : Fin (2 * M), g (i : ℕ) = 1)
    (hfront : ∀ j, j < M → g (2 * j + 1) ≤ g (2 * j))
    (hE : meanPos (fun i : Fin (2 * M) => g (i : ℕ)) < 1 / 2) :
    gapX (fun j : Fin M => coarseFn g (j : ℕ)) < gapX (fun i : Fin (2 * M) => g (i : ℕ)) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  set E : ℝ := meanPos (fun i : Fin (2 * M) => g (i : ℕ)) with hEdef
  set D : ℝ := ∑ j ∈ range M, (g (2 * j) - g (2 * j + 1)) with hDdef
  have hD : 0 ≤ D :=
    Finset.sum_nonneg fun j hj => by
      have := hfront j (Finset.mem_range.mp hj); linarith
  have hE0 : 0 ≤ E := by
    rw [hEdef, meanPos]
    refine Finset.sum_nonneg fun i _ => ?_
    have : (0 : ℝ) ≤ ((((i : ℕ) : ℝ) + 1 / 2) / ((2 * M : ℕ) : ℝ)) := by positivity
    exact mul_nonneg this (hg _)
  -- the fine grid
  have hfine : gapX (fun i : Fin (2 * M) => g (i : ℕ))
      = (2 * (M : ℝ) + 1) / (4 * (M : ℝ) * E + 1) := by
    have h2M : 0 < 2 * M := by omega
    rw [gapX_eq_meanPos h2M (fun i => hg _) hsum]
    push_cast
    rw [← hEdef]
    ring_nf
  -- the coarse grid
  have hcsum : ∑ j : Fin M, coarseFn g (j : ℕ) = 1 := by rw [sum_coarseFn]; exact hsum
  have hcoarse : gapX (fun j : Fin M => coarseFn g (j : ℕ))
      = ((M : ℝ) + 1) / (2 * (M : ℝ) * E + D / 2 + 1) := by
    rw [gapX_eq_meanPos hM (fun j => coarseFn_nonneg hg _) hcsum, meanPos_coarseFn hM g,
      ← hEdef, ← hDdef]
    congr 1
    field_simp
    ring
  rw [hfine, hcoarse]
  have hden1 : 0 < 2 * (M : ℝ) * E + D / 2 + 1 := by positivity
  have hden2 : 0 < 4 * (M : ℝ) * E + 1 := by positivity
  rw [div_lt_div_iff₀ hden1 hden2]
  nlinarith [mul_pos hMR hMR, mul_nonneg hD hMR.le, mul_nonneg hE0 hMR.le]

/-- **Packaged statement.**  For an antitone profile with front-loaded mean
position, refining the grid strictly increases the measured slack factor: every
finite-grid slack estimate is a lower bound. -/
theorem refinement_increases_slack {M : ℕ} (hM : 0 < M) {g : ℕ → ℝ}
    (hg : ∀ i, 0 ≤ g i) (hanti : ∀ ⦃i j : ℕ⦄, i ≤ j → g j ≤ g i)
    (hsum : ∑ i : Fin (2 * M), g (i : ℕ) = 1)
    (hE : meanPos (fun i : Fin (2 * M) => g (i : ℕ)) < 1 / 2) :
    gapX (fun j : Fin M => coarseFn g (j : ℕ)) < gapX (fun i : Fin (2 * M) => g (i : ℕ)) :=
  gapX_coarseFn_lt hM hg hsum (fun _ _ => hanti (Nat.le_succ _)) hE

/-! ## A fully explicit instance (non-vacuity of the hypotheses) -/

/-- The four-cell front-loaded profile `(2/5, 3/10, 1/5, 1/10)`. -/
noncomputable def demoFn : ℕ → ℝ :=
  fun i => if i = 0 then 2 / 5 else if i = 1 then 3 / 10 else if i = 2 then 1 / 5
    else if i = 3 then 1 / 10 else 0

theorem demoFn_sum : ∑ i : Fin (2 * 2), demoFn (i : ℕ) = 1 := by
  norm_num [demoFn, Fin.sum_univ_succ]

theorem demoFn_meanPos : meanPos (fun i : Fin (2 * 2) => demoFn (i : ℕ)) = 3 / 8 := by
  norm_num [meanPos, demoFn, Fin.sum_univ_succ]

theorem demoFn_gapX_fine : gapX (fun i : Fin (2 * 2) => demoFn (i : ℕ)) = 5 / 4 := by
  norm_num [gapX, scanCost, baseCost, demoFn, Fin.sum_univ_succ]

theorem demoFn_gapX_coarse : gapX (fun j : Fin 2 => coarseFn demoFn (j : ℕ)) = 15 / 13 := by
  norm_num [gapX, scanCost, baseCost, coarseFn, demoFn, Fin.sum_univ_succ]

/-- The refinement theorem is not vacuous: on the explicit four-cell profile the
coarse slack `15/13 ≈ 1.1538` is strictly below the fine slack `5/4`. -/
theorem demoFn_refinement :
    gapX (fun j : Fin 2 => coarseFn demoFn (j : ℕ))
      < gapX (fun i : Fin (2 * 2) => demoFn (i : ℕ)) := by
  rw [demoFn_gapX_coarse, demoFn_gapX_fine]
  norm_num

end F1Tightness