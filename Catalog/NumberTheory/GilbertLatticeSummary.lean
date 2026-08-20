import Catalog.Shared.GilbertLatticeCriticalRadii
import Catalog.Shared.GilbertLatticeDiagonalCut
import Catalog.Shared.GilbertLatticeZigzag
import Catalog.Shared.GilbertLatticeSumTwoSquares

/-!
# The three critical radii of the conditioned Gilbert model: the current picture

This file collects the sharpest statements proved about the three deterministic critical
radii of *Gilbert's disc model conditioned on the square lattice*:

* `R_min` — infimum of the radii for which **some** placement of one point per cell of
  `ℤ²` percolates (has an infinite component);
* `R_conn` — infimum of the radii for which **some** placement makes all points
  connected;
* `R_full` — infimum of the radii for which **every** placement makes all points
  connected.

The results, with the file where the crucial construction lives:

| radius   | bound                            | source                                |
|----------|----------------------------------|---------------------------------------|
| `R_min`  | `1/3 ≤ R_min ≤ 1/2`              | lower bound / line placement          |
| `R_conn` | `1/3 ≤ R_conn ≤ √10/4 < 1`       | zig-zag placement (`…Zigzag.lean`)    |
| `R_full` | `R_full = √5` (exact)            | diagonal cut (`…DiagonalCut.lean`)    |

and the strict separation `R_conn < R_full`.

Beyond the geometry, `…SumTwoSquares.lean` links the model to the arithmetic of sums of
two squares; the summary statement `GilbertLattice.spectrum_and_full_radius` records
that the exact value `R_full = √5` is the square root of a prime that is a sum of two
squares, hence that `R_full` is itself realised as an edge length of the model.
-/

namespace GilbertLattice

/-- **Summary of the geometry.**  Two-sided bounds for the three critical radii, the
exact value of `R_full`, their ordering, and the strict separation `R_conn < R_full`. -/
theorem critical_radii_summary :
    (1 / 3 ≤ Rmin ∧ Rmin ≤ 1 / 2) ∧
    (1 / 3 ≤ Rconn ∧ Rconn ≤ Real.sqrt 10 / 4) ∧
    Rfull = Real.sqrt 5 ∧
    Rmin ≤ Rconn ∧ Rconn < Rfull := by
  refine ⟨Rmin_bounds, ⟨Rconn_bounds.1, Rconn_le_sqrt_ten_div_four⟩, Rfull_eq_sqrt_five,
    Rmin_le_Rconn_le_Rfull.1, ?_⟩
  have h1 : Rconn < 1 := Rconn_bounds_sharp.2.2
  have h2 : (1 : ℝ) < Real.sqrt 5 := by
    have h : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 5]
  rw [Rfull_eq_sqrt_five]
  linarith

/-- **The exact full-connectivity radius is an arithmetic quantity.**  `R_full = √5`,
and `5` belongs to the spectrum of squared edge lengths of the model precisely because
`5 % 4 ≠ 3` (Fermat's two-square theorem). -/
theorem spectrum_and_full_radius :
    Rfull = Real.sqrt 5 ∧ (5 : ℕ) ∈ latticeSpectrum := by
  refine ⟨Rfull_eq_sqrt_five, ?_⟩
  exact (prime_mem_latticeSpectrum_iff (by norm_num)).2 (by norm_num)

/-- **The two regimes of the model are genuinely different.**  There are radii for which
some placement connects everything while another placement is disconnected, namely every
`R` with `√10/4 < R ≤ √5`. -/
theorem exists_connected_and_disconnected_placement {R : ℝ} (h1 : Real.sqrt 10 / 4 < R)
    (h2 : R ≤ Real.sqrt 5) :
    (∃ C : Config, (gilbert R C).Connected) ∧ (∃ C : Config, ¬ (gilbert R C).Connected) := by
  refine ⟨⟨zigConfig, zigConfig_connected h1⟩, ⟨diagConfig, ?_⟩⟩
  have hnn : (0 : ℝ) ≤ Real.sqrt 10 / 4 := by positivity
  have hR0 : 0 < R := lt_of_le_of_lt hnn h1
  have hs : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hR2 : R ^ 2 ≤ 5 := by nlinarith [Real.sqrt_nonneg 5]
  exact diagConfig_not_connected hR2

end GilbertLattice