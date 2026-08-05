import Mathlib

/-!
# Gilbert's disc model conditioned on the square lattice: the model

This file sets up the deterministic skeleton of the percolation model studied in
*Gilbert's disc model conditioned on the square lattice*.

One point is placed in each cell of the grid `ℤ²` (in the random model the point is
uniform in its cell; all the results formalised here are statements about *all*
admissible placements, hence they hold for every realisation of the random model).
Two points are joined by an edge when their Euclidean distance is smaller than a fixed
radius `R`.

* `GilbertLattice.Config` — a placement of one point per cell, encoded by its offset
  in the closed unit square `[0,1]²`.
* `GilbertLattice.px`, `GilbertLattice.py` — the coordinates of the point of a cell.
* `GilbertLattice.gilbert` — the resulting graph on the set of cells `ℤ × ℤ`.

The elementary facts proved here: an edge forces both coordinate differences to be
`< R`, an edge forces `0 < R`, for `R ≤ 1` neighbouring cells differ by at most one in
each coordinate, and the model is monotone in `R`.
-/

namespace GilbertLattice

/-- A *configuration*: the offset, inside its own cell, of the point of each cell of
the grid `ℤ²`.  Offsets range over the closed unit square `[0,1]²`. -/
structure Config where
  /-- The offset of the point of a given cell. -/
  off : ℤ × ℤ → ℝ × ℝ
  off_nonneg_fst : ∀ c, 0 ≤ (off c).1
  off_nonneg_snd : ∀ c, 0 ≤ (off c).2
  off_le_one_fst : ∀ c, (off c).1 ≤ 1
  off_le_one_snd : ∀ c, (off c).2 ≤ 1

/-- The first coordinate of the point placed in cell `c`. -/
def px (C : Config) (c : ℤ × ℤ) : ℝ := (c.1 : ℝ) + (C.off c).1

/-- The second coordinate of the point placed in cell `c`. -/
def py (C : Config) (c : ℤ × ℤ) : ℝ := (c.2 : ℝ) + (C.off c).2

/-- Squared Euclidean distance between the points of two cells. -/
def sqdist (C : Config) (c c' : ℤ × ℤ) : ℝ :=
  (px C c - px C c') ^ 2 + (py C c - py C c') ^ 2

lemma sqdist_comm (C : Config) (c c' : ℤ × ℤ) : sqdist C c c' = sqdist C c' c := by
  unfold sqdist; ring

lemma sqdist_nonneg (C : Config) (c c' : ℤ × ℤ) : 0 ≤ sqdist C c c' := by
  unfold sqdist; positivity

/-- Euclidean distance between the points of two cells. -/
noncomputable def pdist (C : Config) (c c' : ℤ × ℤ) : ℝ := Real.sqrt (sqdist C c c')

/-- The Gilbert graph of a configuration: two distinct cells are joined when the
Euclidean distance between their points is `< R`. -/
def gilbert (R : ℝ) (C : Config) : SimpleGraph (ℤ × ℤ) where
  Adj c c' := c ≠ c' ∧ pdist C c c' < R
  symm := by
    rintro a b ⟨h1, h2⟩
    refine ⟨h1.symm, ?_⟩
    unfold pdist at h2 ⊢
    rwa [sqdist_comm]
  loopless := ⟨fun _ h => h.1 rfl⟩

lemma gilbert_adj_iff {R : ℝ} {C : Config} {c c' : ℤ × ℤ} :
    (gilbert R C).Adj c c' ↔ c ≠ c' ∧ pdist C c c' < R := Iff.rfl

/-- Edges only exist for a positive radius. -/
lemma radius_pos_of_adj {R : ℝ} {C : Config} {c c' : ℤ × ℤ} (h : (gilbert R C).Adj c c') :
    0 < R :=
  lt_of_le_of_lt (Real.sqrt_nonneg _) h.2

/-- A convenient criterion for adjacency, in terms of the squared distance. -/
lemma adj_of_sqdist_lt {R : ℝ} (hR : 0 < R) {C : Config} {c c' : ℤ × ℤ} (hne : c ≠ c')
    (h : sqdist C c c' < R ^ 2) : (gilbert R C).Adj c c' := by
  exact ⟨hne, (Real.sqrt_lt' hR).2 h⟩

/-- Non-adjacency criterion, in terms of the squared distance. -/
lemma not_adj_of_le_sqdist {R : ℝ} {C : Config} {c c' : ℤ × ℤ} (h : R ^ 2 ≤ sqdist C c c') :
    ¬ (gilbert R C).Adj c c' := by
  rintro ⟨-, h2⟩
  rw [pdist] at h2
  have : R ^ 2 ≤ sqdist C c c' := h
  nlinarith [Real.sq_sqrt (sqdist_nonneg C c c'), Real.sqrt_nonneg (sqdist C c c')]

/-- Along an edge the horizontal displacement is `< R`. -/
lemma abs_dx_lt {R : ℝ} {C : Config} {c c' : ℤ × ℤ} (h : (gilbert R C).Adj c c') :
    |px C c - px C c'| < R := by
  refine lt_of_le_of_lt ?_ h.2
  rw [pdist, ← Real.sqrt_sq_eq_abs]
  exact Real.sqrt_le_sqrt (by unfold sqdist; nlinarith [sq_nonneg (py C c - py C c')])

/-- Along an edge the vertical displacement is `< R`. -/
lemma abs_dy_lt {R : ℝ} {C : Config} {c c' : ℤ × ℤ} (h : (gilbert R C).Adj c c') :
    |py C c - py C c'| < R := by
  refine lt_of_le_of_lt ?_ h.2
  rw [pdist, ← Real.sqrt_sq_eq_abs]
  exact Real.sqrt_le_sqrt (by unfold sqdist; nlinarith [sq_nonneg (px C c - px C c')])

/-- For `R ≤ 1` neighbouring cells differ by at most one in the first coordinate. -/
lemma abs_col_le_one {R : ℝ} (hR : R ≤ 1) {C : Config} {c c' : ℤ × ℤ}
    (h : (gilbert R C).Adj c c') : |c'.1 - c.1| ≤ 1 := by
  have hx := abs_dx_lt h
  have h1 := C.off_nonneg_fst c
  have h2 := C.off_le_one_fst c
  have h3 := C.off_nonneg_fst c'
  have h4 := C.off_le_one_fst c'
  have key : |((c'.1 - c.1 : ℤ) : ℝ)| < 2 := by
    have : ((c'.1 - c.1 : ℤ) : ℝ) = (px C c' - px C c) + ((C.off c).1 - (C.off c').1) := by
      unfold px; push_cast; ring
    rw [this]
    have := abs_lt.1 hx
    rw [abs_lt]
    constructor <;> [linarith [this.1, this.2]; linarith [this.1, this.2]]
  have h5 : ((|c'.1 - c.1| : ℤ) : ℝ) < 2 := by rw [Int.cast_abs]; exact key
  have h6 : |c'.1 - c.1| < (2 : ℤ) := by exact_mod_cast h5
  omega

/-- For `R ≤ 1` neighbouring cells differ by at most one in the second coordinate. -/
lemma abs_row_le_one {R : ℝ} (hR : R ≤ 1) {C : Config} {c c' : ℤ × ℤ}
    (h : (gilbert R C).Adj c c') : |c'.2 - c.2| ≤ 1 := by
  have hy := abs_dy_lt h
  have h1 := C.off_nonneg_snd c
  have h2 := C.off_le_one_snd c
  have h3 := C.off_nonneg_snd c'
  have h4 := C.off_le_one_snd c'
  have key : |((c'.2 - c.2 : ℤ) : ℝ)| < 2 := by
    have : ((c'.2 - c.2 : ℤ) : ℝ) = (py C c' - py C c) + ((C.off c).2 - (C.off c').2) := by
      unfold py; push_cast; ring
    rw [this]
    have := abs_lt.1 hy
    rw [abs_lt]
    constructor <;> [linarith [this.1, this.2]; linarith [this.1, this.2]]
  have h5 : ((|c'.2 - c.2| : ℤ) : ℝ) < 2 := by rw [Int.cast_abs]; exact key
  have h6 : |c'.2 - c.2| < (2 : ℤ) := by exact_mod_cast h5
  omega

/-- The model is monotone in the radius. -/
lemma gilbert_mono {R R' : ℝ} (h : R ≤ R') (C : Config) : gilbert R C ≤ gilbert R' C := by
  rintro c c' ⟨h1, h2⟩
  exact ⟨h1, lt_of_lt_of_le h2 h⟩

/-- Monotonicity of connectivity in the radius. -/
lemma reachable_mono {R R' : ℝ} (h : R ≤ R') (C : Config) {c c' : ℤ × ℤ}
    (hcc : (gilbert R C).Reachable c c') : (gilbert R' C).Reachable c c' :=
  hcc.mono (gilbert_mono h C)

/-- If all pairs of edge-adjacent cells are joined, the Gilbert graph is connected: this
is the connectivity of the nearest-neighbour grid graph of `ℤ²`. -/
lemma connected_of_grid_adj {R : ℝ} {C : Config}
    (hh : ∀ i j : ℤ, (gilbert R C).Adj (i, j) (i + 1, j))
    (hv : ∀ i j : ℤ, (gilbert R C).Adj (i, j) (i, j + 1)) : (gilbert R C).Connected := by
  have horiz : ∀ i i' j : ℤ, (gilbert R C).Reachable (i, j) (i', j) := by
    intro i i' j
    have key : ∀ k : ℤ, (gilbert R C).Reachable (i, j) (i + k, j) := by
      intro k
      induction k using Int.induction_on with
      | zero => simp
      | succ n ih =>
          refine ih.trans ?_
          have h := (hh (i + (n : ℤ)) j).reachable
          have e : i + (n : ℤ) + 1 = i + ((n : ℤ) + 1) := by ring
          rwa [e] at h
      | pred n ih =>
          refine ih.trans ?_
          have h := (hh (i + (-(n : ℤ) - 1)) j).reachable
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
          have h := (hv i (j + (n : ℤ))).reachable
          have e : j + (n : ℤ) + 1 = j + ((n : ℤ) + 1) := by ring
          rwa [e] at h
      | pred n ih =>
          refine ih.trans ?_
          have h := (hv i (j + (-(n : ℤ) - 1))).reachable
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

end GilbertLattice