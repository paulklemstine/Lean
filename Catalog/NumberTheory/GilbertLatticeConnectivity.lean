import Catalog.Shared.GilbertLatticeBasic

/-!
# Full connectivity of the conditioned Gilbert model for large radii

The third critical radius of the model is

`R_full = inf {R : for every placement of the points, all points are connected}`.

Two points sitting in two cells sharing an edge are at distance at most
`√(2² + 1²) = √5`, whatever the placement.  Consequently, as soon as `R > √5`, every
placement produces a graph containing the whole nearest-neighbour grid graph of `ℤ²`,
which is connected.  This gives `R_full ≤ √5`; the companion file
`GilbertLatticeConstructions.lean` provides the lower bound `R_full ≥ √17 / 2`.
-/

namespace GilbertLattice

variable {R : ℝ} (C : Config)

lemma sq_five_lt (hR : Real.sqrt 5 < R) : 5 < R ^ 2 ∧ 0 < R := by
  have hs : (0 : ℝ) ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  have hR0 : 0 < R := lt_of_le_of_lt hs hR
  refine ⟨?_, hR0⟩
  have h := Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 5)
  nlinarith

/-- Horizontally neighbouring cells are always joined when `R > √5`. -/
lemma adj_horiz (hR : Real.sqrt 5 < R) (i j : ℤ) :
    (gilbert R C).Adj (i, j) (i + 1, j) := by
  obtain ⟨hR2, hR0⟩ := sq_five_lt hR
  refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
  have a1 := C.off_nonneg_fst (i, j)
  have a2 := C.off_le_one_fst (i, j)
  have a3 := C.off_nonneg_fst (i + 1, j)
  have a4 := C.off_le_one_fst (i + 1, j)
  have b1 := C.off_nonneg_snd (i, j)
  have b2 := C.off_le_one_snd (i, j)
  have b3 := C.off_nonneg_snd (i + 1, j)
  have b4 := C.off_le_one_snd (i + 1, j)
  unfold sqdist px py
  push_cast
  nlinarith [a1, a2, a3, a4, b1, b2, b3, b4]

/-- Vertically neighbouring cells are always joined when `R > √5`. -/
lemma adj_vert (hR : Real.sqrt 5 < R) (i j : ℤ) :
    (gilbert R C).Adj (i, j) (i, j + 1) := by
  obtain ⟨hR2, hR0⟩ := sq_five_lt hR
  refine adj_of_sqdist_lt hR0 (by intro h; rw [Prod.ext_iff] at h; omega) ?_
  have a1 := C.off_nonneg_fst (i, j)
  have a2 := C.off_le_one_fst (i, j)
  have a3 := C.off_nonneg_fst (i, j + 1)
  have a4 := C.off_le_one_fst (i, j + 1)
  have b1 := C.off_nonneg_snd (i, j)
  have b2 := C.off_le_one_snd (i, j)
  have b3 := C.off_nonneg_snd (i, j + 1)
  have b4 := C.off_le_one_snd (i, j + 1)
  unfold sqdist px py
  push_cast
  nlinarith [a1, a2, a3, a4, b1, b2, b3, b4]

/-- **All points are connected above `√5`.**  For every radius `R > √5` and every
placement of the points, the Gilbert graph is connected: any two points of the plane
are joined by a chain of points at mutual distance `< R`. -/
theorem connected_of_sqrt_five_lt (hR : Real.sqrt 5 < R) : (gilbert R C).Connected :=
  connected_of_grid_adj (fun i j => adj_horiz C hR i j) (fun i j => adj_vert C hR i j)

/-- Reformulation: above `√5` every pair of cells is connected, in every
configuration. -/
theorem reachable_of_sqrt_five_lt (hR : Real.sqrt 5 < R) (c c' : ℤ × ℤ) :
    (gilbert R C).Reachable c c' :=
  (connected_of_sqrt_five_lt C hR).preconnected c c'

end GilbertLattice