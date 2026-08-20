import Catalog.Shared.GilbertLatticeBasic

/-!
# Two explicit configurations of the conditioned Gilbert model

This file contains the two extremal *placements* of the points which govern two of the
three critical radii of the model.

## The line configuration and the radius `1/2`

`GilbertLattice.lineConfig` puts the point of the cell `(i,0)` at `(i + 3/4, 1)` and the
point of the cell `(i,1)` at `(i + 1/4, 1)`.  All these points lie on the horizontal line
`y = 1` and consecutive ones are at distance exactly `1/2`, so as soon as `R > 1/2` the
whole double row `ℤ × {0,1}` is one infinite connected component
(`GilbertLattice.lineConfig_component_infinite`).

Thus the *geometric* critical radius
`R_min = inf {R : some placement of the points percolates}` satisfies `R_min ≤ 1/2`;
the companion file `GilbertLatticeLowerBound.lean` proves `R_min ≥ 1/3`.

## The cut configuration and full connectivity

`GilbertLattice.cutConfig` pushes the points of the rows `j ≥ 1` up to the line
`y = j+1` and staggers them horizontally by `1/2`, while the points of the rows `j ≤ 0`
are pushed down to the line `y = j`.  Two points on opposite sides of the horizontal
line `y = 1` are then at distance at least `√17 / 2 ≈ 2.0616`, so for `R ≤ √17/2` the
graph is disconnected.  Hence the critical radius for full connectivity satisfies
`R_full ≥ √17/2` (`GilbertLattice.cutConfig_not_connected`), to be compared with the
upper bound `R_full ≤ √5 ≈ 2.2360` proved in `GilbertLatticeConnectivity.lean`.
-/

namespace GilbertLattice

/-! ## The line configuration -/

/-- Offsets of the line configuration: the points of the two rows `j = 0` and `j = 1`
are placed on the line `y = 1`, alternately at abscissa `i + 3/4` and `i + 1/4`. -/
noncomputable def lineOff : ℤ × ℤ → ℝ × ℝ := fun c =>
  if c.2 = 0 then (3 / 4, 1) else if c.2 = 1 then (1 / 4, 0) else (0, 0)

/-- The line configuration. -/
noncomputable def lineConfig : Config where
  off := lineOff
  off_nonneg_fst := by intro c; unfold lineOff; split_ifs <;> norm_num
  off_nonneg_snd := by intro c; unfold lineOff; split_ifs <;> norm_num
  off_le_one_fst := by intro c; unfold lineOff; split_ifs <;> norm_num
  off_le_one_snd := by intro c; unfold lineOff; split_ifs <;> norm_num

lemma px_line_zero (i : ℤ) : px lineConfig (i, 0) = (i : ℝ) + 3 / 4 := by
  simp [px, lineConfig, lineOff]

lemma px_line_one (i : ℤ) : px lineConfig (i, 1) = (i : ℝ) + 1 / 4 := by
  simp [px, lineConfig, lineOff]

lemma py_line_zero (i : ℤ) : py lineConfig (i, 0) = 1 := by
  simp [py, lineConfig, lineOff]

lemma py_line_one (i : ℤ) : py lineConfig (i, 1) = 1 := by
  simp [py, lineConfig, lineOff]

/-- In the line configuration the points of `(i,1)` and `(i,0)` are at distance `1/2`. -/
lemma adj_line_same {R : ℝ} (hR : 1 / 2 < R) (i : ℤ) :
    (gilbert R lineConfig).Adj (i, 1) (i, 0) := by
  have hR0 : (0 : ℝ) < R := by linarith
  refine adj_of_sqdist_lt hR0 (by simp) ?_
  unfold sqdist
  rw [px_line_one, px_line_zero, py_line_one, py_line_zero]
  nlinarith

/-- In the line configuration the points of `(i,0)` and `(i+1,1)` are at distance `1/2`. -/
lemma adj_line_next {R : ℝ} (hR : 1 / 2 < R) (i : ℤ) :
    (gilbert R lineConfig).Adj (i, 0) (i + 1, 1) := by
  have hR0 : (0 : ℝ) < R := by linarith
  refine adj_of_sqdist_lt hR0 (by simp) ?_
  unfold sqdist
  rw [px_line_zero, px_line_one, py_line_zero, py_line_one]
  push_cast
  nlinarith

/-- Consecutive cells of the bottom row are connected in the line configuration. -/
lemma reachable_line_succ {R : ℝ} (hR : 1 / 2 < R) (i : ℤ) :
    (gilbert R lineConfig).Reachable (i, 0) (i + 1, 0) :=
  ((adj_line_next hR i).reachable).trans ((adj_line_same hR (i + 1)).reachable)

/-- All cells `(n, 0)`, `n : ℕ`, lie in the connected component of `(0,0)`. -/
lemma reachable_line_nat {R : ℝ} (hR : 1 / 2 < R) (n : ℕ) :
    (gilbert R lineConfig).Reachable (0, 0) ((n : ℤ), 0) := by
  induction n with
  | zero => simp
  | succ n ih =>
      refine ih.trans ?_
      have := reachable_line_succ hR (n : ℤ)
      simpa [Nat.cast_succ] using this

/-- **Percolation above `1/2` for a suitable placement.**  For every radius `R > 1/2`
the line configuration has an infinite connected component. -/
theorem lineConfig_component_infinite {R : ℝ} (hR : 1 / 2 < R) :
    {c : ℤ × ℤ | (gilbert R lineConfig).Reachable (0, 0) c}.Infinite := by
  apply Set.infinite_of_injective_forall_mem
    (f := fun n : ℕ => (((n : ℤ)), (0 : ℤ)))
  · intro a b hab
    simpa using hab
  · intro n
    exact reachable_line_nat hR n

/-- **Upper bound for the geometric critical radius.**  For every `R > 1/2` there is a
placement of the points whose Gilbert graph has an infinite connected component. -/
theorem exists_config_infinite_component {R : ℝ} (hR : 1 / 2 < R) :
    ∃ C : Config, {c : ℤ × ℤ | (gilbert R C).Reachable (0, 0) c}.Infinite :=
  ⟨lineConfig, lineConfig_component_infinite hR⟩

/-! ## The centred configuration -/

/-- The configuration placing every point at the centre of its cell. -/
noncomputable def centerConfig : Config where
  off := fun _ => (1 / 2, 1 / 2)
  off_nonneg_fst := by intro c; norm_num
  off_nonneg_snd := by intro c; norm_num
  off_le_one_fst := by intro c; norm_num
  off_le_one_snd := by intro c; norm_num

/-- **A placement connecting all points above `1`.**  In the centred configuration the
points of edge-adjacent cells are at distance exactly `1`, hence for `R > 1` the whole
graph is connected: all points are connected to each other. -/
theorem centerConfig_connected {R : ℝ} (hR : 1 < R) : (gilbert R centerConfig).Connected := by
  have hR0 : (0 : ℝ) < R := by linarith
  refine connected_of_grid_adj (fun i j => ?_) (fun i j => ?_)
  · refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
    unfold sqdist px py centerConfig
    push_cast
    nlinarith
  · refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
    unfold sqdist px py centerConfig
    push_cast
    nlinarith

/-! ## The cut configuration -/

/-- Offsets of the cut configuration: the rows `j ≥ 1` are pushed up to the top of their
cell and shifted right by `1/2`, the rows `j ≤ 0` are pushed to the bottom-left corner. -/
noncomputable def cutOff : ℤ × ℤ → ℝ × ℝ := fun c => if 1 ≤ c.2 then (1 / 2, 1) else (0, 0)

/-- The cut configuration. -/
noncomputable def cutConfig : Config where
  off := cutOff
  off_nonneg_fst := by intro c; unfold cutOff; split_ifs <;> norm_num
  off_nonneg_snd := by intro c; unfold cutOff; split_ifs <;> norm_num
  off_le_one_fst := by intro c; unfold cutOff; split_ifs <;> norm_num
  off_le_one_snd := by intro c; unfold cutOff; split_ifs <;> norm_num

/-- In the cut configuration, no edge joins the upper half plane to the lower one, as
soon as `R ^ 2 ≤ 17/4`. -/
lemma cutConfig_no_crossing_edge {R : ℝ} (hR : R ^ 2 ≤ 17 / 4) {c c' : ℤ × ℤ}
    (hc : 1 ≤ c.2) (hc' : c'.2 ≤ 0) : ¬ (gilbert R cutConfig).Adj c c' := by
  refine not_adj_of_le_sqdist (le_trans hR ?_)
  have hpx : px cutConfig c = (c.1 : ℝ) + 1 / 2 := by
    simp [px, cutConfig, cutOff, hc]
  have hpy : py cutConfig c = (c.2 : ℝ) + 1 := by
    simp [py, cutConfig, cutOff, hc]
  have hpx' : px cutConfig c' = (c'.1 : ℝ) := by
    have : ¬ (1 ≤ c'.2) := by omega
    simp [px, cutConfig, cutOff, this]
  have hpy' : py cutConfig c' = (c'.2 : ℝ) := by
    have : ¬ (1 ≤ c'.2) := by omega
    simp [py, cutConfig, cutOff, this]
  unfold sqdist
  rw [hpx, hpy, hpx', hpy']
  have hy : (2 : ℝ) ≤ ((c.2 : ℝ) + 1) - (c'.2 : ℝ) := by
    have h : (c'.2 : ℤ) + 1 ≤ c.2 := by omega
    have h' : ((c'.2 : ℤ) : ℝ) + 1 ≤ ((c.2 : ℤ) : ℝ) := by exact_mod_cast h
    linarith
  have hx : (1 / 2 : ℝ) ≤ |((c.1 : ℝ) + 1 / 2) - (c'.1 : ℝ)| := by
    by_cases h : (c'.1 : ℤ) ≤ c.1
    · have h' : ((c'.1 : ℤ) : ℝ) ≤ ((c.1 : ℤ) : ℝ) := by exact_mod_cast h
      rw [abs_of_nonneg (by linarith)]
      linarith
    · have h2 : (c.1 : ℤ) + 1 ≤ c'.1 := by omega
      have h' : ((c.1 : ℤ) : ℝ) + 1 ≤ ((c'.1 : ℤ) : ℝ) := by exact_mod_cast h2
      rw [abs_of_nonpos (by linarith)]
      linarith
  have hx2 : (1 / 4 : ℝ) ≤ (((c.1 : ℝ) + 1 / 2) - (c'.1 : ℝ)) ^ 2 := by
    have := sq_abs (((c.1 : ℝ) + 1 / 2) - (c'.1 : ℝ))
    nlinarith [abs_nonneg (((c.1 : ℝ) + 1 / 2) - (c'.1 : ℝ))]
  nlinarith

/-- The upper half plane is stable under the adjacency relation of the cut
configuration. -/
lemma cutConfig_upper_closed {R : ℝ} (hR : R ^ 2 ≤ 17 / 4) {c c' : ℤ × ℤ}
    (hadj : (gilbert R cutConfig).Adj c c') (hc : 1 ≤ c.2) : 1 ≤ c'.2 := by
  by_contra hcon
  exact cutConfig_no_crossing_edge hR hc (by omega) hadj

/-- The upper half plane is stable under reachability in the cut configuration. -/
lemma cutConfig_reachable_upper {R : ℝ} (hR : R ^ 2 ≤ 17 / 4) {c c' : ℤ × ℤ}
    (h : (gilbert R cutConfig).Reachable c c') (hc : 1 ≤ c.2) : 1 ≤ c'.2 := by
  obtain ⟨w⟩ := h
  revert hc
  induction w with
  | nil => exact id
  | cons hadj w ih => exact fun hc => ih (cutConfig_upper_closed hR hadj hc)

/-- **Lower bound for the radius of full connectivity.**  For `R ≤ √17/2` there is a
placement of the points whose Gilbert graph is disconnected: the cells `(0,1)` and
`(0,0)` are in different components. -/
theorem cutConfig_not_reachable {R : ℝ} (hR : R ^ 2 ≤ 17 / 4) :
    ¬ (gilbert R cutConfig).Reachable (0, 1) (0, 0) := by
  intro h
  have := cutConfig_reachable_upper hR h (by norm_num)
  norm_num at this

/-- For `R ≤ √17/2` the Gilbert graph of the cut configuration is not connected. -/
theorem cutConfig_not_connected {R : ℝ} (hR : R ^ 2 ≤ 17 / 4) :
    ¬ (gilbert R cutConfig).Connected := fun h =>
  cutConfig_not_reachable hR (h.preconnected (0, 1) (0, 0))

end GilbertLattice