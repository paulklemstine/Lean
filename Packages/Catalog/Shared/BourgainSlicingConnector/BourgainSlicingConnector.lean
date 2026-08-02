import Mathlib

/-!
# A finite multiplicative bridge for coordinate slices of unit-volume boxes

For an axis-aligned box with positive side lengths `a i`, its volume is the product
of the side lengths.  Its coordinate section perpendicular to axis `i` has volume
the product of all the other side lengths.  Thus the geometric slicing assertion for
boxes is exactly a finite multiplicative pigeonhole principle.

This is a rigorously proved special case and structural model of Bourgain's slicing
problem; it does not claim the open dimension-free theorem for arbitrary convex bodies.
-/

namespace BourgainSlicingConnector

/-- The `n`-dimensional volume of an axis-aligned box represented by its side lengths. -/
def boxVolume {n : ℕ} (a : Fin n → ℝ) : ℝ := ∏ i, a i

/-- The `(n-1)`-dimensional volume of the central coordinate section perpendicular to
axis `i`, represented as the product of all side lengths except `a i`. -/
def coordinateSectionVolume {n : ℕ} (a : Fin n → ℝ) (i : Fin n) : ℝ :=
  ∏ j, if j = i then 1 else a j

/-- The geometric product identity: section volume times the omitted width is the box
volume.  This is the bridge between coordinate slicing and finite multiplication. -/
theorem coordinateSectionVolume_mul_width {n : ℕ} (a : Fin n → ℝ) (i : Fin n) :
    coordinateSectionVolume a i * a i = boxVolume a := by
  simp [coordinateSectionVolume, boxVolume]
  have h : ∏ j, (if j = i then (1 : ℝ) else a j) = ∏ j ∈ Finset.univ.erase i, a j := by
    rw [← Finset.prod_erase_mul (a := i) Finset.univ (fun j => if j = i then (1 : ℝ) else a j)]
    simp
    rw [← Finset.prod_congr rfl]
    · intro j hj
      simp [Finset.mem_erase] at hj
      simp [hj]
    simp
  rw [h, Finset.prod_erase_mul _ _ (Finset.mem_univ i)]

/-- Finite multiplicative pigeonhole principle: a positive finite family with product
one has a member at most one. -/
theorem exists_width_le_one {n : ℕ} (hn : 0 < n) (a : Fin n → ℝ)
    (hvol : boxVolume a = 1) :
    ∃ i, a i ≤ 1 := by
  by_contra h
  push_neg at h
  rw [boxVolume] at hvol
  have hprod : ∏ i, a i > 1 := by
    have aux : ∀ m : ℕ, 0 < m → ∀ (f : Fin m → ℝ), (∀ i, 1 < f i) → ∏ i, f i > 1 := by
      intro m hm f hf
      induction hm with
      | refl => simp [hf 0]
      | step _ ih =>
        rw [Fin.prod_univ_succ]
        have h2 : 1 < ∏ i : Fin _, f i.succ := ih (fun i => f i.succ) (fun i => hf i.succ)
        exact one_lt_mul_of_lt_of_le (hf 0) h2.le
    exact aux n hn a h
  linarith

/-- **Coordinate-box slicing theorem.** Every positive axis-aligned box of volume one
in positive dimension has a central coordinate hyperplane section of volume at least
one.  The universal constant is exactly `1` for this class of convex bodies. -/
theorem unit_box_has_large_coordinate_section {n : ℕ} (hn : 0 < n)
    (a : Fin n → ℝ) (ha : ∀ i, 0 < a i) (hvol : boxVolume a = 1) :
    ∃ i, 1 ≤ coordinateSectionVolume a i := by
  obtain ⟨i, hi⟩ := exists_width_le_one hn a hvol
  refine ⟨i, ?_⟩
  have h := coordinateSectionVolume_mul_width a i
  rw [hvol] at h
  nlinarith [ha i]

/-- The connection in equivalence form: for a positive unit-volume box, a coordinate
width is at most one exactly when its perpendicular section has volume at least one. -/
theorem width_le_one_iff_section_ge_one {n : ℕ} (a : Fin n → ℝ)
    (ha : ∀ i, 0 < a i) (hvol : boxVolume a = 1) (i : Fin n) :
    a i ≤ 1 ↔ 1 ≤ coordinateSectionVolume a i := by
  have h := coordinateSectionVolume_mul_width a i
  rw [hvol] at h
  constructor
  · intro ha1
    nlinarith [ha i]
  · intro hsec
    nlinarith [ha i]

end BourgainSlicingConnector