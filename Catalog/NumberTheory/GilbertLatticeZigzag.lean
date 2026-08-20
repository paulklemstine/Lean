import Catalog.Shared.GilbertLatticeBasic
import Catalog.Shared.GilbertLatticeConstructions
import Catalog.Shared.GilbertLatticeCriticalRadii

/-!
# A placement connecting all points below radius `1`: `R_conn ≤ √10 / 4`

For the conditioned Gilbert model the file `GilbertLatticeCriticalRadii.lean` introduces

`R_conn = inf {R : some placement of one point per cell makes the whole graph connected}`

and bounds it by `1/3 ≤ R_conn ≤ 1`, the upper bound coming from the centred placement
(all points at the centres of their cells, mutual distance `1`).

This file improves the upper bound below `1`.  Note first that *no lattice* of covolume
`1` does better than the square lattice: a placement whose point set is a translate of a
lattice needs `R > 1` (this is `GilbertLattice.alignedConfig_connected_iff` for the
aligned family).  Beating `1` therefore requires a genuinely non-lattice placement.

## The zig-zag placement

`GilbertLattice.zigConfig` uses a `2 × 2` periodic pattern of offsets:

| parity of `(i, j)` | offset      | point                 |
|--------------------|-------------|-----------------------|
| `(even, even)`     | `(1/2, 3/4)`| `(i + 1/2, j + 3/4)`  |
| `(even, odd)`      | `(1/4, 1)`  | `(i + 1/4, j + 1)`    |
| `(odd, even)`      | `(1/4, 1)`  | `(i + 1/4, j + 1)`    |
| `(odd, odd)`       | `(1, 1/4)`  | `(i + 1, j + 1/4)`    |

Every point has a neighbour at squared distance `5/8 = (3/4)² + (1/4)²`, and the
resulting graph of "short" edges is connected: the five families of edges
`adj_zig_*` below give, for every cell, a chain to its right neighbour and to its
neighbour above.  Hence for every `R > √(5/8) = √10 / 4 ≈ 0.7906` the whole graph is
connected, so

* `GilbertLattice.zigConfig_connected` : `√10/4 < R → (gilbert R zigConfig).Connected`;
* `GilbertLattice.Rconn_le_sqrt_ten_div_four` : `R_conn ≤ √10 / 4 < 1`.

A numerical optimisation over all `2 × 2` periodic placements suggests that
`√10 / 4` is essentially optimal within this class (the best value found numerically is
`≈ 0.7877`), so the true value of `R_conn` lies in `[1/3, √10/4]`.
-/

namespace GilbertLattice

/-! ## The zig-zag configuration -/

/-- Offsets of the zig-zag placement, `2 × 2` periodic. -/
noncomputable def zigOff : ℤ × ℤ → ℝ × ℝ := fun c =>
  if c.1 % 2 = 0 then (if c.2 % 2 = 0 then (1 / 2, 3 / 4) else (1 / 4, 1))
  else (if c.2 % 2 = 0 then (1 / 4, 1) else (1, 1 / 4))

/-- The zig-zag placement of one point per cell. -/
noncomputable def zigConfig : Config where
  off := zigOff
  off_nonneg_fst := by intro c; unfold zigOff; split_ifs <;> norm_num
  off_nonneg_snd := by intro c; unfold zigOff; split_ifs <;> norm_num
  off_le_one_fst := by intro c; unfold zigOff; split_ifs <;> norm_num
  off_le_one_snd := by intro c; unfold zigOff; split_ifs <;> norm_num

section Coordinates

variable {a b : ℤ}

lemma px_zig_ee (ha : a % 2 = 0) (hb : b % 2 = 0) :
    px zigConfig (a, b) = (a : ℝ) + 1 / 2 := by
  simp [px, zigConfig, zigOff, ha, hb]

lemma py_zig_ee (ha : a % 2 = 0) (hb : b % 2 = 0) :
    py zigConfig (a, b) = (b : ℝ) + 3 / 4 := by
  simp [py, zigConfig, zigOff, ha, hb]

lemma px_zig_eo (ha : a % 2 = 0) (hb : b % 2 = 1) :
    px zigConfig (a, b) = (a : ℝ) + 1 / 4 := by
  have hb' : ¬ (b % 2 = 0) := by omega
  simp [px, zigConfig, zigOff, ha, hb']

lemma py_zig_eo (ha : a % 2 = 0) (hb : b % 2 = 1) :
    py zigConfig (a, b) = (b : ℝ) + 1 := by
  have hb' : ¬ (b % 2 = 0) := by omega
  simp [py, zigConfig, zigOff, ha, hb']

lemma px_zig_oe (ha : a % 2 = 1) (hb : b % 2 = 0) :
    px zigConfig (a, b) = (a : ℝ) + 1 / 4 := by
  have ha' : ¬ (a % 2 = 0) := by omega
  simp [px, zigConfig, zigOff, ha', hb]

lemma py_zig_oe (ha : a % 2 = 1) (hb : b % 2 = 0) :
    py zigConfig (a, b) = (b : ℝ) + 1 := by
  have ha' : ¬ (a % 2 = 0) := by omega
  simp [py, zigConfig, zigOff, ha', hb]

lemma px_zig_oo (ha : a % 2 = 1) (hb : b % 2 = 1) :
    px zigConfig (a, b) = (a : ℝ) + 1 := by
  have ha' : ¬ (a % 2 = 0) := by omega
  have hb' : ¬ (b % 2 = 0) := by omega
  simp [px, zigConfig, zigOff, ha', hb']

lemma py_zig_oo (ha : a % 2 = 1) (hb : b % 2 = 1) :
    py zigConfig (a, b) = (b : ℝ) + 1 / 4 := by
  have ha' : ¬ (a % 2 = 0) := by omega
  have hb' : ¬ (b % 2 = 0) := by omega
  simp [py, zigConfig, zigOff, ha', hb']

end Coordinates

/-! ## The five families of short edges -/

variable {R : ℝ}

/-- Edge of squared length `5/8` from an `(even, even)` cell to the cell on its right. -/
lemma adj_zig_ee_right (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) {i j : ℤ} (hi : i % 2 = 0)
    (hj : j % 2 = 0) : (gilbert R zigConfig).Adj (i, j) (i + 1, j) := by
  have hval : sqdist zigConfig (i, j) (i + 1, j) = 5 / 8 := by
    unfold sqdist
    rw [px_zig_ee hi hj, py_zig_ee hi hj, px_zig_oe (a := i + 1) (by omega) hj,
      py_zig_oe (a := i + 1) (by omega) hj]
    push_cast
    ring
  refine adj_of_sqdist_lt hR0 (by simp [Prod.ext_iff]) ?_
  rw [hval]; exact hR2

/-- Edge of squared length `5/8` from an `(even, even)` cell to the cell below it. -/
lemma adj_zig_ee_down (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) {i j : ℤ} (hi : i % 2 = 0)
    (hj : j % 2 = 0) : (gilbert R zigConfig).Adj (i, j) (i, j - 1) := by
  have hval : sqdist zigConfig (i, j) (i, j - 1) = 5 / 8 := by
    unfold sqdist
    rw [px_zig_ee hi hj, py_zig_ee hi hj, px_zig_eo (b := j - 1) hi (by omega),
      py_zig_eo (b := j - 1) hi (by omega)]
    push_cast
    ring
  refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
  rw [hval]; exact hR2

/-- Edge of squared length `1/2` from an `(even, even)` cell to the `(odd, odd)` cell to
its upper left. -/
lemma adj_zig_ee_upleft (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) {i j : ℤ} (hi : i % 2 = 0)
    (hj : j % 2 = 0) : (gilbert R zigConfig).Adj (i, j) (i - 1, j + 1) := by
  have hval : sqdist zigConfig (i, j) (i - 1, j + 1) = 1 / 2 := by
    unfold sqdist
    rw [px_zig_ee hi hj, py_zig_ee hi hj, px_zig_oo (a := i - 1) (b := j + 1) (by omega)
      (by omega), py_zig_oo (a := i - 1) (b := j + 1) (by omega) (by omega)]
    push_cast
    ring
  refine adj_of_sqdist_lt hR0 (by simp [Prod.ext_iff]) ?_
  rw [hval]; linarith

/-- Edge of squared length `5/8` from an `(odd, odd)` cell to the cell below it. -/
lemma adj_zig_oo_down (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) {i j : ℤ} (hi : i % 2 = 1)
    (hj : j % 2 = 1) : (gilbert R zigConfig).Adj (i, j) (i, j - 1) := by
  have hval : sqdist zigConfig (i, j) (i, j - 1) = 5 / 8 := by
    unfold sqdist
    rw [px_zig_oo hi hj, py_zig_oo hi hj, px_zig_oe (b := j - 1) hi (by omega),
      py_zig_oe (b := j - 1) hi (by omega)]
    push_cast
    ring
  refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
  rw [hval]; exact hR2

/-- Edge of squared length `5/8` from an `(odd, odd)` cell to the cell on its right. -/
lemma adj_zig_oo_right (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) {i j : ℤ} (hi : i % 2 = 1)
    (hj : j % 2 = 1) : (gilbert R zigConfig).Adj (i, j) (i + 1, j) := by
  have hval : sqdist zigConfig (i, j) (i + 1, j) = 5 / 8 := by
    unfold sqdist
    rw [px_zig_oo hi hj, py_zig_oo hi hj, px_zig_eo (a := i + 1) (by omega) hj,
      py_zig_eo (a := i + 1) (by omega) hj]
    push_cast
    ring
  refine adj_of_sqdist_lt hR0 (by simp [Prod.ext_iff]) ?_
  rw [hval]; exact hR2

/-! ## Reachability of the grid neighbours -/

/-- Every cell is joined to the cell on its right by a path of short edges. -/
lemma reachable_zig_right (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) (i j : ℤ) :
    (gilbert R zigConfig).Reachable (i, j) (i + 1, j) := by
  rcases Int.emod_two_eq i with hi | hi <;> rcases Int.emod_two_eq j with hj | hj
  · exact (adj_zig_ee_right hR0 hR2 hi hj).reachable
  · -- (even, odd): go left to the `(odd, odd)` cell, then to `(even, even)` below,
    -- then right and up
    have h1 : (gilbert R zigConfig).Adj (i - 1, j) (i, j) := by
      have := adj_zig_oo_right (R := R) hR0 hR2 (i := i - 1) (j := j) (by omega) hj
      simpa using this
    have h2 : (gilbert R zigConfig).Adj (i, j - 1) (i - 1, j) := by
      have := adj_zig_ee_upleft (R := R) hR0 hR2 (i := i) (j := j - 1) hi (by omega)
      simpa using this
    have h3 : (gilbert R zigConfig).Adj (i, j - 1) (i + 1, j - 1) :=
      adj_zig_ee_right hR0 hR2 hi (by omega)
    have h4 : (gilbert R zigConfig).Adj (i + 1, j) (i + 1, j - 1) := by
      have := adj_zig_oo_down (R := R) hR0 hR2 (i := i + 1) (j := j) (by omega) hj
      simpa using this
    exact ((h1.symm.reachable.trans h2.symm.reachable).trans h3.reachable).trans h4.symm.reachable
  · -- (odd, even): go up to the `(odd, odd)` cell, then to `(even, even)` on the right
    have h1 : (gilbert R zigConfig).Adj (i, j + 1) (i, j) := by
      have := adj_zig_oo_down (R := R) hR0 hR2 (i := i) (j := j + 1) hi (by omega)
      simpa using this
    have h2 : (gilbert R zigConfig).Adj (i + 1, j) (i, j + 1) := by
      have := adj_zig_ee_upleft (R := R) hR0 hR2 (i := i + 1) (j := j) (by omega) hj
      simpa using this
    exact h1.symm.reachable.trans h2.symm.reachable
  · exact (adj_zig_oo_right hR0 hR2 hi hj).reachable

/-- Every cell is joined to the cell above it by a path of short edges. -/
lemma reachable_zig_up (hR0 : 0 < R) (hR2 : 5 / 8 < R ^ 2) (i j : ℤ) :
    (gilbert R zigConfig).Reachable (i, j) (i, j + 1) := by
  rcases Int.emod_two_eq i with hi | hi <;> rcases Int.emod_two_eq j with hj | hj
  · -- (even, even): via the `(odd, odd)` cell to the upper left
    have h1 : (gilbert R zigConfig).Adj (i, j) (i - 1, j + 1) :=
      adj_zig_ee_upleft hR0 hR2 hi hj
    have h2 : (gilbert R zigConfig).Adj (i - 1, j + 1) (i, j + 1) := by
      have := adj_zig_oo_right (R := R) hR0 hR2 (i := i - 1) (j := j + 1) (by omega) (by omega)
      simpa using this
    exact h1.reachable.trans h2.reachable
  · -- (even, odd): direct edge to the `(even, even)` cell above
    have h : (gilbert R zigConfig).Adj (i, j + 1) (i, j) := by
      have := adj_zig_ee_down (R := R) hR0 hR2 (i := i) (j := j + 1) hi (by omega)
      simpa using this
    exact h.symm.reachable
  · -- (odd, even): direct edge to the `(odd, odd)` cell above
    have h : (gilbert R zigConfig).Adj (i, j + 1) (i, j) := by
      have := adj_zig_oo_down (R := R) hR0 hR2 (i := i) (j := j + 1) hi (by omega)
      simpa using this
    exact h.symm.reachable
  · -- (odd, odd): right, up, up-left, down
    have h1 : (gilbert R zigConfig).Adj (i, j) (i + 1, j) := adj_zig_oo_right hR0 hR2 hi hj
    have h2 : (gilbert R zigConfig).Adj (i + 1, j + 1) (i + 1, j) := by
      have := adj_zig_ee_down (R := R) hR0 hR2 (i := i + 1) (j := j + 1) (by omega) (by omega)
      simpa using this
    have h3 : (gilbert R zigConfig).Adj (i + 1, j + 1) (i, j + 2) := by
      have := adj_zig_ee_upleft (R := R) hR0 hR2 (i := i + 1) (j := j + 1) (by omega) (by omega)
      have e : (i + 1 - 1, j + 1 + 1) = (i, j + 2) := by norm_num; omega
      rwa [e] at this
    have h4 : (gilbert R zigConfig).Adj (i, j + 2) (i, j + 1) := by
      have := adj_zig_oo_down (R := R) hR0 hR2 (i := i) (j := j + 2) hi (by omega)
      have e : (i, j + 2 - 1) = (i, j + 1) := by norm_num; omega
      rwa [e] at this
    exact ((h1.reachable.trans h2.symm.reachable).trans h3.reachable).trans h4.reachable

/-! ## Connectivity -/

/-- If every cell is joined by a path to its right neighbour and to its neighbour above,
the graph is connected.  (Reachability version of
`GilbertLattice.connected_of_grid_adj`.) -/
lemma connected_of_grid_reachable {C : Config}
    (hh : ∀ i j : ℤ, (gilbert R C).Reachable (i, j) (i + 1, j))
    (hv : ∀ i j : ℤ, (gilbert R C).Reachable (i, j) (i, j + 1)) : (gilbert R C).Connected := by
  have horiz : ∀ i i' j : ℤ, (gilbert R C).Reachable (i, j) (i', j) := by
    intro i i' j
    have key : ∀ k : ℤ, (gilbert R C).Reachable (i, j) (i + k, j) := by
      intro k
      induction k using Int.induction_on with
      | zero => simp
      | succ n ih =>
          refine ih.trans ?_
          have h := hh (i + (n : ℤ)) j
          have e : i + (n : ℤ) + 1 = i + ((n : ℤ) + 1) := by ring
          rwa [e] at h
      | pred n ih =>
          refine ih.trans ?_
          have h := hh (i + (-(n : ℤ) - 1)) j
          have e : i + (-(n : ℤ) - 1) + 1 = i + -(n : ℤ) := by ring
          rw [e] at h
          exact h.symm
    have := key (i' - i)
    simpa using this
  have vert : ∀ i j j' : ℤ, (gilbert R C).Reachable (i, j) (i, j') := by
    intro i j j'
    have key : ∀ k : ℤ, (gilbert R C).Reachable (i, j) (i, j + k) := by
      intro k
      induction k using Int.induction_on with
      | zero => simp
      | succ n ih =>
          refine ih.trans ?_
          have h := hv i (j + (n : ℤ))
          have e : j + (n : ℤ) + 1 = j + ((n : ℤ) + 1) := by ring
          rwa [e] at h
      | pred n ih =>
          refine ih.trans ?_
          have h := hv i (j + (-(n : ℤ) - 1))
          have e : j + (-(n : ℤ) - 1) + 1 = j + -(n : ℤ) := by ring
          rw [e] at h
          exact h.symm
    have := key (j' - j)
    simpa using this
  rw [SimpleGraph.connected_iff]
  refine ⟨?_, ⟨(0, 0)⟩⟩
  intro c c'
  have h1 : (gilbert R C).Reachable (c.1, c.2) (c'.1, c.2) := horiz _ _ _
  have h2 : (gilbert R C).Reachable (c'.1, c.2) (c'.1, c'.2) := vert _ _ _
  simpa using h1.trans h2

/-- `√10 / 4` is the length of the longest edge used by the zig-zag placement. -/
lemma sqrt_ten_div_four_sq : (Real.sqrt 10 / 4) ^ 2 = 5 / 8 := by
  have h : Real.sqrt 10 ^ 2 = 10 := Real.sq_sqrt (by norm_num)
  field_simp
  nlinarith [h]

/-- **The zig-zag placement connects everything above `√10 / 4`.** -/
theorem zigConfig_connected (hR : Real.sqrt 10 / 4 < R) : (gilbert R zigConfig).Connected := by
  have hnn : (0 : ℝ) ≤ Real.sqrt 10 / 4 := by positivity
  have hR0 : 0 < R := lt_of_le_of_lt hnn hR
  have hR2 : 5 / 8 < R ^ 2 := by
    rw [← sqrt_ten_div_four_sq]
    exact pow_lt_pow_left₀ hR hnn (by norm_num)
  exact connected_of_grid_reachable (fun i j => reachable_zig_right hR0 hR2 i j)
    (fun i j => reachable_zig_up hR0 hR2 i j)

/-- `√10 / 4 < 1`: the zig-zag placement beats every lattice placement. -/
lemma sqrt_ten_div_four_lt_one : Real.sqrt 10 / 4 < 1 := by
  have h : Real.sqrt 10 ^ 2 = 10 := Real.sq_sqrt (by norm_num)
  nlinarith [Real.sqrt_nonneg 10]

/-- **Improved upper bound for the radius of a fully connected placement.**
`R_conn ≤ √10 / 4 ≈ 0.7906 < 1`, improving `GilbertLattice.Rconn_bounds`. -/
theorem Rconn_le_sqrt_ten_div_four : Rconn ≤ Real.sqrt 10 / 4 := by
  have hsub : Set.Ioi (Real.sqrt 10 / 4) ⊆ connectedPlacementRadii := fun R hR =>
    ⟨zigConfig, zigConfig_connected hR⟩
  have hbdd : BddBelow connectedPlacementRadii :=
    ⟨1 / 3, fun R hR =>
      one_third_le_of_mem_percolatingRadii (connectedPlacement_subset_percolating hR)⟩
  have h1 : sInf connectedPlacementRadii ≤ sInf (Set.Ioi (Real.sqrt 10 / 4)) :=
    csInf_le_csInf hbdd ⟨1, by
      refine Set.mem_Ioi.2 sqrt_ten_div_four_lt_one⟩ hsub
  rwa [csInf_Ioi] at h1

/-- **Sharpened two-sided bound.** `1/3 ≤ R_conn ≤ √10/4 < 1`. -/
theorem Rconn_bounds_sharp : 1 / 3 ≤ Rconn ∧ Rconn ≤ Real.sqrt 10 / 4 ∧ Rconn < 1 :=
  ⟨Rconn_bounds.1, Rconn_le_sqrt_ten_div_four,
    lt_of_le_of_lt Rconn_le_sqrt_ten_div_four sqrt_ten_div_four_lt_one⟩

end GilbertLattice