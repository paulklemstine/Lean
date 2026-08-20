import Catalog.Shared.GilbertLatticeBasic

/-!
# No percolation below the radius `1/3`, for any placement of the points

This file proves a *deterministic* lower bound for the geometric critical radius of the
conditioned Gilbert model: if `R < 1/3` then, whatever the placement of the points, all
connected components of the Gilbert graph are contained in a `3 × 3` block of cells; in
particular every connected component is finite and no placement percolates.

## The argument

Write `p_c = (px c, py c)` for the point of the cell `c`.

*Crossing lemma.*  If an edge joins two cells with different first coordinates, then the
two points lie on either side of the vertical line `x = K` separating the two columns,
at distance `< R` from it (`GilbertLattice.cross_x`); similarly for rows
(`GilbertLattice.cross_y`).

*Uniqueness of the crossed line.*  Two integers at distance `< 3R < 1` are equal.  Hence
all the vertical lines crossed along a path are the same one, provided the current point
stays within `2R` of the previously crossed line.

*The invariant.*  Along a path with previous cell `prev` and current cell `c` we
maintain (`GilbertLattice.Inv`): the columns of `prev` and `c` are among `{K-1, K}`, the
rows among `{J-1, J}`, the abscissa of the current point is within `2R` of `K` — and
even within `R` of `K` if the last step changed the column — and symmetrically for the
ordinate.  The invariant propagates along an edge as soon as the new cell differs from
`prev` (`GilbertLattice.inv_step`): a step which does not change the column can only
increase the slack in `x` from `R` to `2R`, and a step which changes neither the slack
in `x` nor the slack in `y` would force the walk to come back to `prev`.

Since a path enters the invariant after at most two steps
(`GilbertLattice.inv_start`), every cell reachable from `c` differs from `c` by at most
one in each coordinate (`GilbertLattice.reachable_abs_le_one`), components are finite
(`GilbertLattice.component_finite`) and no configuration percolates
(`GilbertLattice.not_infinite_component`).
-/

namespace GilbertLattice

variable {R : ℝ} {C : Config}

/-- Two integers whose distance is `< 1` are equal. -/
lemma int_eq_of_abs_sub_lt_one {K K' : ℤ} (h : |(K : ℝ) - (K' : ℝ)| < 1) : K = K' := by
  by_contra hne
  have h1 : 1 ≤ |K - K'| := Int.one_le_abs (sub_ne_zero_of_ne hne)
  have h2 : ((1 : ℤ) : ℝ) ≤ ((|K - K'| : ℤ) : ℝ) := by exact_mod_cast h1
  rw [Int.cast_abs] at h2
  push_cast at h2
  linarith

/-- The point of a cell lies in the closed cell. -/
lemma px_bounds (C : Config) (c : ℤ × ℤ) : (c.1 : ℝ) ≤ px C c ∧ px C c ≤ (c.1 : ℝ) + 1 :=
  ⟨by have := C.off_nonneg_fst c; unfold px; linarith,
   by have := C.off_le_one_fst c; unfold px; linarith⟩

/-- The point of a cell lies in the closed cell. -/
lemma py_bounds (C : Config) (c : ℤ × ℤ) : (c.2 : ℝ) ≤ py C c ∧ py C c ≤ (c.2 : ℝ) + 1 :=
  ⟨by have := C.off_nonneg_snd c; unfold py; linarith,
   by have := C.off_le_one_snd c; unfold py; linarith⟩

/-- If an edge changes the column, both endpoints are within `R` of the vertical line
separating the two columns. -/
lemma cross_x (hR : R < 1) {c c' : ℤ × ℤ} (hadj : (gilbert R C).Adj c c')
    (hne : c.1 ≠ c'.1) :
    ∃ K : ℤ, (c.1 = K ∨ c.1 = K - 1) ∧ (c'.1 = K ∨ c'.1 = K - 1) ∧
      |px C c - (K : ℝ)| < R ∧ |px C c' - (K : ℝ)| < R := by
  have hd := abs_dx_lt hadj
  have hle := abs_col_le_one hR.le hadj
  rw [abs_le] at hle
  have hb := px_bounds C c
  have hb' := px_bounds C c'
  rw [abs_lt] at hd
  rcases (show c'.1 = c.1 + 1 ∨ c'.1 = c.1 - 1 by omega) with h1 | h1
  · refine ⟨c.1 + 1, Or.inr (by omega), Or.inl (by omega), ?_, ?_⟩
    · have e : ((c'.1 : ℤ) : ℝ) = (c.1 : ℝ) + 1 := by rw [h1]; push_cast; ring
      push_cast
      rw [abs_lt]
      constructor <;> [linarith [hb.2, hd.1, hd.2]; linarith [hb'.1, hd.1, hd.2, e]]
    · have e : ((c'.1 : ℤ) : ℝ) = (c.1 : ℝ) + 1 := by rw [h1]; push_cast; ring
      push_cast
      rw [abs_lt]
      constructor <;> [linarith [hb'.1, hd.1, hd.2, e]; linarith [hb.2, hd.1, hd.2]]
  · refine ⟨c.1, Or.inl rfl, Or.inr (by omega), ?_, ?_⟩
    · have e : ((c'.1 : ℤ) : ℝ) = (c.1 : ℝ) - 1 := by rw [h1]; push_cast; ring
      rw [abs_lt]
      constructor <;> [linarith [hb'.2, hd.1, hd.2, e]; linarith [hb.1, hd.1, hd.2]]
    · have e : ((c'.1 : ℤ) : ℝ) = (c.1 : ℝ) - 1 := by rw [h1]; push_cast; ring
      rw [abs_lt]
      constructor <;> [linarith [hb'.2, hd.1, hd.2, e]; linarith [hb.1, hd.1, hd.2]]

/-- If an edge changes the row, both endpoints are within `R` of the horizontal line
separating the two rows. -/
lemma cross_y (hR : R < 1) {c c' : ℤ × ℤ} (hadj : (gilbert R C).Adj c c')
    (hne : c.2 ≠ c'.2) :
    ∃ J : ℤ, (c.2 = J ∨ c.2 = J - 1) ∧ (c'.2 = J ∨ c'.2 = J - 1) ∧
      |py C c - (J : ℝ)| < R ∧ |py C c' - (J : ℝ)| < R := by
  have hd := abs_dy_lt hadj
  have hle := abs_row_le_one hR.le hadj
  rw [abs_le] at hle
  have hb := py_bounds C c
  have hb' := py_bounds C c'
  rw [abs_lt] at hd
  rcases (show c'.2 = c.2 + 1 ∨ c'.2 = c.2 - 1 by omega) with h1 | h1
  · refine ⟨c.2 + 1, Or.inr (by omega), Or.inl (by omega), ?_, ?_⟩
    · have e : ((c'.2 : ℤ) : ℝ) = (c.2 : ℝ) + 1 := by rw [h1]; push_cast; ring
      push_cast
      rw [abs_lt]
      constructor <;> [linarith [hb.2, hd.1, hd.2]; linarith [hb'.1, hd.1, hd.2, e]]
    · have e : ((c'.2 : ℤ) : ℝ) = (c.2 : ℝ) + 1 := by rw [h1]; push_cast; ring
      push_cast
      rw [abs_lt]
      constructor <;> [linarith [hb'.1, hd.1, hd.2, e]; linarith [hb.2, hd.1, hd.2]]
  · refine ⟨c.2, Or.inl rfl, Or.inr (by omega), ?_, ?_⟩
    · have e : ((c'.2 : ℤ) : ℝ) = (c.2 : ℝ) - 1 := by rw [h1]; push_cast; ring
      rw [abs_lt]
      constructor <;> [linarith [hb'.2, hd.1, hd.2, e]; linarith [hb.1, hd.1, hd.2]]
    · have e : ((c'.2 : ℤ) : ℝ) = (c.2 : ℝ) - 1 := by rw [h1]; push_cast; ring
      rw [abs_lt]
      constructor <;> [linarith [hb'.2, hd.1, hd.2, e]; linarith [hb.1, hd.1, hd.2]]

/-- The invariant carried along a path: `K` and `J` are the only vertical and horizontal
lines that the path may cross, the current point is within `2R` of them, and within `R`
of the one that the last step crossed. -/
structure Inv (R : ℝ) (C : Config) (K J : ℤ) (prev c : ℤ × ℤ) : Prop where
  ne : prev ≠ c
  prevCol : prev.1 = K ∨ prev.1 = K - 1
  prevRow : prev.2 = J ∨ prev.2 = J - 1
  col : c.1 = K ∨ c.1 = K - 1
  row : c.2 = J ∨ c.2 = J - 1
  tightX : prev.1 ≠ c.1 → |px C c - (K : ℝ)| < R
  looseX : |px C c - (K : ℝ)| < 2 * R
  tightY : prev.2 ≠ c.2 → |py C c - (J : ℝ)| < R
  looseY : |py C c - (J : ℝ)| < 2 * R

/-- **Propagation of the invariant.**  If the invariant holds at `(prev, c)` and `c` is
joined to a cell `c' ≠ prev`, then the invariant holds at `(c, c')`. -/
lemma inv_step (hR : R < 1 / 3) (hR0 : 0 < R) {K J : ℤ} {prev c c' : ℤ × ℤ}
    (h : Inv R C K J prev c) (hadj : (gilbert R C).Adj c c') (hne : c' ≠ prev) :
    Inv R C K J c c' := by
  have hR1 : R < 1 := by linarith
  have hdx := abs_dx_lt hadj
  have hdy := abs_dy_lt hadj
  have hcc' : c ≠ c' := hadj.ne
  -- uniqueness of the crossed lines
  have hKu : ∀ K' : ℤ, |px C c - (K' : ℝ)| < R → K' = K := by
    intro K' hK'
    refine (int_eq_of_abs_sub_lt_one ?_)
    have h1 : |((K' : ℝ)) - (K : ℝ)| ≤ |(K' : ℝ) - px C c| + |px C c - (K : ℝ)| :=
      abs_sub_le _ _ _
    rw [abs_sub_comm ((K' : ℝ)) (px C c)] at h1
    have := h.looseX
    linarith
  have hJu : ∀ J' : ℤ, |py C c - (J' : ℝ)| < R → J' = J := by
    intro J' hJ'
    refine (int_eq_of_abs_sub_lt_one ?_)
    have h1 : |((J' : ℝ)) - (J : ℝ)| ≤ |(J' : ℝ) - py C c| + |py C c - (J : ℝ)| :=
      abs_sub_le _ _ _
    rw [abs_sub_comm ((J' : ℝ)) (py C c)] at h1
    have := h.looseY
    linarith
  by_cases hx : c'.1 = c.1
  · by_cases hy : c'.2 = c.2
    · exact absurd (Prod.ext hx hy) (Ne.symm hcc')
    · -- the step crosses a horizontal line only
      obtain ⟨J', hJ1, hJ2, hJ3, hJ4⟩ := cross_y hR1 hadj (fun hcon => hy hcon.symm)
      have hJJ : J' = J := hJu J' hJ3
      subst hJJ
      -- tightness in x at `c` is needed; otherwise the walk returns to `prev`
      have htx : |px C c - (K : ℝ)| < R := by
        by_cases hpx : prev.1 = c.1
        · exfalso
          have hpy : prev.2 ≠ c.2 := by
            intro hcon
            exact h.ne (Prod.ext hpx hcon)
          have : prev.2 = c'.2 := by
            rcases h.prevRow with h1 | h1 <;> rcases h.row with h2 | h2 <;>
              rcases hJ2 with h3 | h3 <;> omega
          exact hne (Prod.ext (by omega) this.symm)
        · exact h.tightX hpx
      refine ⟨hcc', h.col, h.row, by rcases h.col with a | a <;> omega, hJ2, ?_, ?_, ?_, ?_⟩
      · intro hcon; exact absurd hx (fun hh => hcon hh.symm)
      · have : |px C c' - (K : ℝ)| ≤ |px C c' - px C c| + |px C c - (K : ℝ)| := abs_sub_le _ _ _
        rw [abs_sub_comm (px C c') (px C c)] at this
        linarith
      · intro _; exact hJ4
      · linarith [hJ4]
  · -- the step crosses a vertical line
    obtain ⟨K', hK1, hK2, hK3, hK4⟩ := cross_x hR1 hadj (fun hcon => hx hcon.symm)
    have hKK : K' = K := hKu K' hK3
    subst hKK
    by_cases hy : c'.2 = c.2
    · -- vertical line only
      have hty : |py C c - (J : ℝ)| < R := by
        by_cases hpy : prev.2 = c.2
        · exfalso
          have hpx : prev.1 ≠ c.1 := by
            intro hcon
            exact h.ne (Prod.ext hcon hpy)
          have : prev.1 = c'.1 := by
            rcases h.prevCol with h1 | h1 <;> rcases h.col with h2 | h2 <;>
              rcases hK2 with h3 | h3 <;> omega
          exact hne (Prod.ext this.symm (by omega))
        · exact h.tightY hpy
      refine ⟨hcc', h.col, h.row, hK2, by rcases h.row with a | a <;> omega, ?_, ?_, ?_, ?_⟩
      · intro _; exact hK4
      · linarith [hK4]
      · intro hcon; exact absurd hy (fun hh => hcon hh.symm)
      · have : |py C c' - (J : ℝ)| ≤ |py C c' - py C c| + |py C c - (J : ℝ)| := abs_sub_le _ _ _
        rw [abs_sub_comm (py C c') (py C c)] at this
        linarith
    · -- both lines are crossed
      obtain ⟨J', hJ1, hJ2, hJ3, hJ4⟩ := cross_y hR1 hadj (fun hcon => hy hcon.symm)
      have hJJ : J' = J := hJu J' hJ3
      subst hJJ
      exact ⟨hcc', h.col, h.row, hK2, hJ2, fun _ => hK4, by linarith [hK4],
        fun _ => hJ4, by linarith [hJ4]⟩

/-- The invariant confines the remainder of a path to the block
`{K-1, K} × {J-1, J}`. -/
lemma inv_walk (hR : R < 1 / 3) (hR0 : 0 < R) {K J : ℤ} {c d : ℤ × ℤ}
    (w : (gilbert R C).Walk c d) :
    ∀ {prev : ℤ × ℤ}, Inv R C K J prev c → w.IsPath → prev ∉ w.support →
      ∀ e ∈ w.support, (e.1 = K ∨ e.1 = K - 1) ∧ (e.2 = J ∨ e.2 = J - 1) := by
  induction w with
  | nil =>
      intro prev hinv _ _ e he
      simp only [SimpleGraph.Walk.support_nil, List.mem_singleton] at he
      subst he
      exact ⟨hinv.col, hinv.row⟩
  | @cons u v z hadj w ih =>
      intro prev hinv hpath hprev e he
      rw [SimpleGraph.Walk.support_cons, List.mem_cons] at he
      rcases he with rfl | he
      · exact ⟨hinv.col, hinv.row⟩
      · rw [SimpleGraph.Walk.cons_isPath_iff] at hpath
        rw [SimpleGraph.Walk.support_cons, List.mem_cons] at hprev
        push_neg at hprev
        have hne' : v ≠ prev := by
          intro hcon
          exact hprev.2 (hcon ▸ SimpleGraph.Walk.start_mem_support w)
        exact ih (inv_step hR hR0 hinv hadj hne') hpath.1 hpath.2 e he

/-- Two consecutive steps of a path cannot both leave the column unchanged. -/
lemma no_double_x_trivial (hR : R < 1 / 3) (hR0 : 0 < R) {c₀ c₁ c₂ : ℤ × ℤ}
    (h1 : (gilbert R C).Adj c₀ c₁) (h2 : (gilbert R C).Adj c₁ c₂) (hne : c₂ ≠ c₀)
    (hx1 : c₁.1 = c₀.1) (hx2 : c₂.1 = c₁.1) : False := by
  have hR1 : R < 1 := by linarith
  have hy1 : c₀.2 ≠ c₁.2 := by
    intro hcon; exact h1.ne (Prod.ext hx1.symm hcon)
  have hy2 : c₁.2 ≠ c₂.2 := by
    intro hcon; exact h2.ne (Prod.ext hx2.symm hcon)
  obtain ⟨J₁, hJ11, hJ12, hJ13, hJ14⟩ := cross_y hR1 h1 hy1
  obtain ⟨J₂, hJ21, hJ22, hJ23, hJ24⟩ := cross_y hR1 h2 hy2
  have hJJ : J₁ = J₂ := by
    refine int_eq_of_abs_sub_lt_one ?_
    have hb : |((J₁ : ℝ)) - (J₂ : ℝ)| ≤ |(J₁ : ℝ) - py C c₁| + |py C c₁ - (J₂ : ℝ)| :=
      abs_sub_le _ _ _
    rw [abs_sub_comm ((J₁ : ℝ)) (py C c₁)] at hb
    linarith
  subst hJJ
  have : c₂.2 = c₀.2 := by
    rcases hJ12 with a | a <;> rcases hJ11 with b | b <;> rcases hJ22 with d | d <;> omega
  exact hne (Prod.ext (by omega) this)

/-- Two consecutive steps of a path cannot both leave the row unchanged. -/
lemma no_double_y_trivial (hR : R < 1 / 3) (hR0 : 0 < R) {c₀ c₁ c₂ : ℤ × ℤ}
    (h1 : (gilbert R C).Adj c₀ c₁) (h2 : (gilbert R C).Adj c₁ c₂) (hne : c₂ ≠ c₀)
    (hy1 : c₁.2 = c₀.2) (hy2 : c₂.2 = c₁.2) : False := by
  have hR1 : R < 1 := by linarith
  have hx1 : c₀.1 ≠ c₁.1 := by
    intro hcon; exact h1.ne (Prod.ext hcon hy1.symm)
  have hx2 : c₁.1 ≠ c₂.1 := by
    intro hcon; exact h2.ne (Prod.ext hcon hy2.symm)
  obtain ⟨K₁, hK11, hK12, hK13, hK14⟩ := cross_x hR1 h1 hx1
  obtain ⟨K₂, hK21, hK22, hK23, hK24⟩ := cross_x hR1 h2 hx2
  have hKK : K₁ = K₂ := by
    refine int_eq_of_abs_sub_lt_one ?_
    have hb : |((K₁ : ℝ)) - (K₂ : ℝ)| ≤ |(K₁ : ℝ) - px C c₁| + |px C c₁ - (K₂ : ℝ)| :=
      abs_sub_le _ _ _
    rw [abs_sub_comm ((K₁ : ℝ)) (px C c₁)] at hb
    linarith
  subst hKK
  have : c₂.1 = c₀.1 := by
    rcases hK12 with a | a <;> rcases hK11 with b | b <;> rcases hK22 with d | d <;> omega
  exact hne (Prod.ext this (by omega))

/-- After two steps of a path the invariant holds, for lines adjacent to the starting
cell. -/
lemma inv_start (hR : R < 1 / 3) (hR0 : 0 < R) {c₀ c₁ c₂ : ℤ × ℤ}
    (h1 : (gilbert R C).Adj c₀ c₁) (h2 : (gilbert R C).Adj c₁ c₂) (hne : c₂ ≠ c₀) :
    ∃ K J : ℤ, Inv R C K J c₁ c₂ ∧ (K = c₀.1 ∨ K = c₀.1 + 1) ∧
      (J = c₀.2 ∨ J = c₀.2 + 1) := by
  have hR1 : R < 1 := by linarith
  -- the horizontal data
  have claimX : ∃ K : ℤ, (K = c₀.1 ∨ K = c₀.1 + 1) ∧ (c₁.1 = K ∨ c₁.1 = K - 1) ∧
      (c₂.1 = K ∨ c₂.1 = K - 1) ∧ (c₁.1 ≠ c₂.1 → |px C c₂ - (K : ℝ)| < R) ∧
      |px C c₂ - (K : ℝ)| < 2 * R := by
    by_cases hx2 : c₂.1 = c₁.1
    · have hx1 : c₁.1 ≠ c₀.1 := by
        intro hcon; exact no_double_x_trivial hR hR0 h1 h2 hne hcon hx2
      obtain ⟨K, hK1, hK2, hK3, hK4⟩ := cross_x hR1 h1 (fun hcon => hx1 hcon.symm)
      refine ⟨K, by omega, hK2, by omega, ?_, ?_⟩
      · intro hcon; exact absurd hx2 (fun hh => hcon hh.symm)
      · have hd := abs_dx_lt h2
        have hb : |px C c₂ - (K : ℝ)| ≤ |px C c₂ - px C c₁| + |px C c₁ - (K : ℝ)| :=
          abs_sub_le _ _ _
        rw [abs_sub_comm (px C c₂) (px C c₁)] at hb
        linarith
    · obtain ⟨K, hK1, hK2, hK3, hK4⟩ := cross_x hR1 h2 (fun hcon => hx2 hcon.symm)
      refine ⟨K, ?_, hK1, hK2, fun _ => hK4, by linarith [hK4]⟩
      by_cases hx1 : c₁.1 = c₀.1
      · omega
      · obtain ⟨K', hK'1, hK'2, hK'3, hK'4⟩ := cross_x hR1 h1 (fun hcon => hx1 hcon.symm)
        have : K' = K := by
          refine int_eq_of_abs_sub_lt_one ?_
          have hb : |((K' : ℝ)) - (K : ℝ)| ≤ |(K' : ℝ) - px C c₁| + |px C c₁ - (K : ℝ)| :=
            abs_sub_le _ _ _
          rw [abs_sub_comm ((K' : ℝ)) (px C c₁)] at hb
          linarith
        omega
  have claimY : ∃ J : ℤ, (J = c₀.2 ∨ J = c₀.2 + 1) ∧ (c₁.2 = J ∨ c₁.2 = J - 1) ∧
      (c₂.2 = J ∨ c₂.2 = J - 1) ∧ (c₁.2 ≠ c₂.2 → |py C c₂ - (J : ℝ)| < R) ∧
      |py C c₂ - (J : ℝ)| < 2 * R := by
    by_cases hy2 : c₂.2 = c₁.2
    · have hy1 : c₁.2 ≠ c₀.2 := by
        intro hcon; exact no_double_y_trivial hR hR0 h1 h2 hne hcon hy2
      obtain ⟨J, hJ1, hJ2, hJ3, hJ4⟩ := cross_y hR1 h1 (fun hcon => hy1 hcon.symm)
      refine ⟨J, by omega, hJ2, by omega, ?_, ?_⟩
      · intro hcon; exact absurd hy2 (fun hh => hcon hh.symm)
      · have hd := abs_dy_lt h2
        have hb : |py C c₂ - (J : ℝ)| ≤ |py C c₂ - py C c₁| + |py C c₁ - (J : ℝ)| :=
          abs_sub_le _ _ _
        rw [abs_sub_comm (py C c₂) (py C c₁)] at hb
        linarith
    · obtain ⟨J, hJ1, hJ2, hJ3, hJ4⟩ := cross_y hR1 h2 (fun hcon => hy2 hcon.symm)
      refine ⟨J, ?_, hJ1, hJ2, fun _ => hJ4, by linarith [hJ4]⟩
      by_cases hy1 : c₁.2 = c₀.2
      · omega
      · obtain ⟨J', hJ'1, hJ'2, hJ'3, hJ'4⟩ := cross_y hR1 h1 (fun hcon => hy1 hcon.symm)
        have : J' = J := by
          refine int_eq_of_abs_sub_lt_one ?_
          have hb : |((J' : ℝ)) - (J : ℝ)| ≤ |(J' : ℝ) - py C c₁| + |py C c₁ - (J : ℝ)| :=
            abs_sub_le _ _ _
          rw [abs_sub_comm ((J' : ℝ)) (py C c₁)] at hb
          linarith
        omega
  obtain ⟨K, hK0, hK1, hK2, hK3, hK4⟩ := claimX
  obtain ⟨J, hJ0, hJ1, hJ2, hJ3, hJ4⟩ := claimY
  exact ⟨K, J, ⟨(h2.ne), hK1, hJ1, hK2, hJ2, hK3, hK4, hJ3, hJ4⟩, hK0, hJ0⟩

/-- **Main lower bound.**  If `R < 1/3` then, for every placement of the points, every
cell reachable from `c` differs from `c` by at most one in each coordinate. -/
theorem reachable_abs_le_one (hR : R < 1 / 3) {c d : ℤ × ℤ}
    (h : (gilbert R C).Reachable c d) : |d.1 - c.1| ≤ 1 ∧ |d.2 - c.2| ≤ 1 := by
  rcases le_or_gt R 0 with hR0 | hR0
  · obtain ⟨w⟩ := h
    cases w with
    | nil => simp
    | cons hadj w => exact absurd (radius_pos_of_adj hadj) (not_lt.2 hR0)
  · obtain ⟨w⟩ := h
    obtain ⟨p, hp⟩ : ∃ p : (gilbert R C).Walk c d, p.IsPath := ⟨w.toPath.1, w.toPath.2⟩
    clear w
    match p, hp with
    | SimpleGraph.Walk.nil, _ => simp
    | SimpleGraph.Walk.cons hadj SimpleGraph.Walk.nil, hp =>
        exact ⟨abs_col_le_one (by linarith) hadj, abs_row_le_one (by linarith) hadj⟩
    | SimpleGraph.Walk.cons (v := c₁) hadj (SimpleGraph.Walk.cons (v := c₂) hadj₂ p₂), hp =>
        have hp1 : (SimpleGraph.Walk.cons hadj₂ p₂).IsPath := hp.of_cons
        have hnec : c₂ ≠ c := by
          intro hcon
          rw [SimpleGraph.Walk.cons_isPath_iff] at hp
          apply hp.2
          rw [SimpleGraph.Walk.support_cons, ← hcon]
          exact List.mem_cons_of_mem _ (SimpleGraph.Walk.start_mem_support p₂)
        obtain ⟨K, J, hinv, hK, hJ⟩ := inv_start hR hR0 hadj hadj₂ hnec
        have hprev : c₁ ∉ p₂.support := by
          rw [SimpleGraph.Walk.cons_isPath_iff] at hp1
          exact hp1.2
        have hd := inv_walk hR hR0 p₂ hinv (hp1.of_cons) hprev d
          (SimpleGraph.Walk.end_mem_support p₂)
        refine ⟨?_, ?_⟩
        · rw [abs_le]
          rcases hd.1 with a | a <;> rcases hK with b | b <;> omega
        · rw [abs_le]
          rcases hd.2 with a | a <;> rcases hJ with b | b <;> omega

/-- For `R < 1/3` every connected component of the Gilbert graph is finite (it is
contained in a `3 × 3` block of cells). -/
theorem component_finite (hR : R < 1 / 3) (c : ℤ × ℤ) :
    {d : ℤ × ℤ | (gilbert R C).Reachable c d}.Finite := by
  apply Set.Finite.subset (Set.finite_Icc (c.1 - 1, c.2 - 1) (c.1 + 1, c.2 + 1))
  intro d hd
  obtain ⟨h1, h2⟩ := reachable_abs_le_one hR hd
  rw [abs_le] at h1 h2
  rw [Set.mem_Icc, Prod.le_def, Prod.le_def]
  exact ⟨⟨by omega, by omega⟩, ⟨by omega, by omega⟩⟩

/-- **No percolation below `1/3`.**  For `R < 1/3` no placement of the points produces an
infinite connected component. -/
theorem not_infinite_component (hR : R < 1 / 3) (c : ℤ × ℤ) :
    ¬ {d : ℤ × ℤ | (gilbert R C).Reachable c d}.Infinite :=
  fun h => h (component_finite hR c)

end GilbertLattice