import Catalog.Shared.GilbertLatticeBasic
import Catalog.Shared.GilbertLatticeConnectivity
import Catalog.Shared.GilbertLatticeCriticalRadii

/-!
# The exact value of the full-connectivity radius: `R_full = √5`

For the model *Gilbert's disc model conditioned on the square lattice* (one point per
cell of `ℤ²`, two points joined when their distance is `< R`) the file
`GilbertLatticeCriticalRadii.lean` bounds the radius of *full connectivity*

`R_full = inf {R : for every placement of the points, the graph is connected}`

between `√17 / 2 ≈ 2.0616` (a horizontal cut) and `√5 ≈ 2.2360`.

This file closes the gap: it produces a placement built along a **diagonal** cut for
which every crossing pair of points is at distance at least `√5`, so that the graph is
disconnected for every `R ≤ √5`.  Together with the upper bound of
`GilbertLatticeConnectivity.lean` this gives the exact value

* `GilbertLattice.Rfull_eq_sqrt_five` : `R_full = √5`,

and even the exact description of the set of radii of full connectivity,

* `GilbertLattice.fullyConnectedRadii_eq` : `{R : every placement is connected} = (√5, ∞)`.

## The diagonal configuration

Cells are split along the diagonal: `c` is *upper* when `c.1 ≤ c.2` and *lower*
otherwise.  The point of an upper cell is pushed to the top-left corner of the cell,
the point of a lower cell to the bottom-right corner.  If `c` is upper and `c'` is
lower, the displacement between the two points is `(u, v)` with

`u = c.1 - c'.1 - 1`,  `v = c.2 + 1 - c'.2`,  and  `v ≥ u + 3`;

over the integers this forces `u² + v² ≥ 5` (`GilbertLattice.five_le_sq_add_sq`), the
minimum `5` being attained at `(u, v) = (-1, 2)` and `(-2, 1)`.  Note that the naive
continuous bound would only give `u² + v² ≥ 9/2`: the value `5` is genuinely arithmetic.
-/

namespace GilbertLattice

/-- **The integral gap estimate.**  If two integers satisfy `v ≥ u + 3`, then
`u² + v² ≥ 5`.  (Over the reals the optimum would be `9/2`.) -/
lemma five_le_sq_add_sq {u v : ℤ} (h : u + 3 ≤ v) : 5 ≤ u ^ 2 + v ^ 2 := by
  rcases le_or_gt u (-3) with hu | hu
  · nlinarith [sq_nonneg v]
  rcases le_or_gt 0 u with hu0 | hu0
  · nlinarith [sq_nonneg u]
  · interval_cases u <;> nlinarith

/-- Offsets of the diagonal cut configuration: cells above the diagonal put their point
at the top-left corner, cells below it at the bottom-right corner. -/
noncomputable def diagOff : ℤ × ℤ → ℝ × ℝ := fun c => if c.1 ≤ c.2 then (0, 1) else (1, 0)

/-- The diagonal cut configuration. -/
noncomputable def diagConfig : Config where
  off := diagOff
  off_nonneg_fst := by intro c; unfold diagOff; split_ifs <;> norm_num
  off_nonneg_snd := by intro c; unfold diagOff; split_ifs <;> norm_num
  off_le_one_fst := by intro c; unfold diagOff; split_ifs <;> norm_num
  off_le_one_snd := by intro c; unfold diagOff; split_ifs <;> norm_num

lemma px_diag_upper {c : ℤ × ℤ} (h : c.1 ≤ c.2) : px diagConfig c = (c.1 : ℝ) := by
  simp [px, diagConfig, diagOff, h]

lemma py_diag_upper {c : ℤ × ℤ} (h : c.1 ≤ c.2) : py diagConfig c = (c.2 : ℝ) + 1 := by
  simp [py, diagConfig, diagOff, h]

lemma px_diag_lower {c : ℤ × ℤ} (h : ¬ c.1 ≤ c.2) : px diagConfig c = (c.1 : ℝ) + 1 := by
  simp [px, diagConfig, diagOff, h]

lemma py_diag_lower {c : ℤ × ℤ} (h : ¬ c.1 ≤ c.2) : py diagConfig c = (c.2 : ℝ) := by
  simp [py, diagConfig, diagOff, h]

/-- **The diagonal cut is `√5`-wide.**  In the diagonal configuration, the point of a
cell above the diagonal and the point of a cell below it are at squared distance at
least `5`. -/
theorem five_le_sqdist_diag {c c' : ℤ × ℤ} (hc : c.1 ≤ c.2) (hc' : ¬ c'.1 ≤ c'.2) :
    5 ≤ sqdist diagConfig c c' := by
  set u : ℤ := c.1 - c'.1 - 1 with hu
  set v : ℤ := c.2 + 1 - c'.2 with hv
  have hkey : u + 3 ≤ v := by simp only [hu, hv]; omega
  have hint : (5 : ℤ) ≤ u ^ 2 + v ^ 2 := five_le_sq_add_sq hkey
  have hreal : (5 : ℝ) ≤ ((u : ℝ)) ^ 2 + ((v : ℝ)) ^ 2 := by exact_mod_cast hint
  have hx : px diagConfig c - px diagConfig c' = (u : ℝ) := by
    rw [px_diag_upper hc, px_diag_lower hc', hu]; push_cast; ring
  have hy : py diagConfig c - py diagConfig c' = (v : ℝ) := by
    rw [py_diag_upper hc, py_diag_lower hc', hv]; push_cast; ring
  unfold sqdist
  rw [hx, hy]
  exact hreal

/-- No edge of the diagonal configuration crosses the diagonal when `R² ≤ 5`. -/
lemma diagConfig_no_crossing_edge {R : ℝ} (hR : R ^ 2 ≤ 5) {c c' : ℤ × ℤ}
    (hc : c.1 ≤ c.2) (hc' : ¬ c'.1 ≤ c'.2) : ¬ (gilbert R diagConfig).Adj c c' :=
  not_adj_of_le_sqdist (le_trans hR (five_le_sqdist_diag hc hc'))

/-- The set of cells above the diagonal is stable under adjacency when `R² ≤ 5`. -/
lemma diagConfig_upper_closed {R : ℝ} (hR : R ^ 2 ≤ 5) {c c' : ℤ × ℤ}
    (hadj : (gilbert R diagConfig).Adj c c') (hc : c.1 ≤ c.2) : c'.1 ≤ c'.2 := by
  by_contra hcon
  exact diagConfig_no_crossing_edge hR hc hcon hadj

/-- The set of cells above the diagonal is stable under reachability when `R² ≤ 5`. -/
lemma diagConfig_reachable_upper {R : ℝ} (hR : R ^ 2 ≤ 5) {c c' : ℤ × ℤ}
    (h : (gilbert R diagConfig).Reachable c c') (hc : c.1 ≤ c.2) : c'.1 ≤ c'.2 := by
  obtain ⟨w⟩ := h
  revert hc
  induction w with
  | nil => exact id
  | cons hadj w ih => exact fun hc => ih (diagConfig_upper_closed hR hadj hc)

/-- For `R² ≤ 5` the diagonal configuration separates the cell `(0,0)` from `(0,-1)`. -/
theorem diagConfig_not_reachable {R : ℝ} (hR : R ^ 2 ≤ 5) :
    ¬ (gilbert R diagConfig).Reachable (0, 0) (0, -1) := by
  intro h
  have := diagConfig_reachable_upper hR h (by norm_num)
  norm_num at this

/-- **Lower bound for the radius of full connectivity.**  For every `R ≤ √5` there is a
placement of one point per cell whose Gilbert graph is disconnected. -/
theorem diagConfig_not_connected {R : ℝ} (hR : R ^ 2 ≤ 5) :
    ¬ (gilbert R diagConfig).Connected := fun h =>
  diagConfig_not_reachable hR (h.preconnected (0, 0) (0, -1))

/-- Any radius of full connectivity is `> √5`. -/
theorem sqrt_five_lt_of_mem_fullyConnectedRadii {R : ℝ} (hR : R ∈ fullyConnectedRadii) :
    Real.sqrt 5 < R := by
  by_contra hcon
  push_neg at hcon
  have hRpos : 0 < R := by
    by_contra hle
    push_neg at hle
    obtain ⟨w⟩ := (hR diagConfig).preconnected (0, 0) (1, 0)
    cases w with
    | cons hadj w' => exact absurd (radius_pos_of_adj hadj) (not_lt.2 hle)
  have hs : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hsnn : (0 : ℝ) ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  have hR2 : R ^ 2 ≤ 5 := by nlinarith
  exact diagConfig_not_connected hR2 (hR diagConfig)

/-- **The exact set of radii of full connectivity.**  Every placement of one point per
cell of `ℤ²` gives a connected graph exactly when `R > √5`. -/
theorem fullyConnectedRadii_eq : fullyConnectedRadii = Set.Ioi (Real.sqrt 5) := by
  ext R
  exact ⟨fun hR => sqrt_five_lt_of_mem_fullyConnectedRadii hR,
    fun hR => mem_fullyConnectedRadii_of_sqrt_five_lt hR⟩

/-- **The full-connectivity radius of the conditioned Gilbert model is exactly `√5`.**
This closes the gap `√17/2 ≤ R_full ≤ √5` of `GilbertLattice.Rfull_bounds`. -/
theorem Rfull_eq_sqrt_five : Rfull = Real.sqrt 5 := by
  unfold Rfull
  rw [fullyConnectedRadii_eq, csInf_Ioi]

end GilbertLattice