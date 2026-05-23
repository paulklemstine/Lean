/-
  # Concrete Knot Examples and Computations

  Explicit link diagrams for the trefoil and figure-eight knots
  with Jones polynomial computations.

  ## Main results
  - `writhe_trefoil`: w(trefoil) = -3
  - `writhe_figureEight`: w(figure-eight) = 0
  - `jones_invariant_under_equiv`: Jones polynomial is invariant under
    Reidemeister equivalence
-/
import Mathlib
import Geometry.KnotTheory.Defs
import Geometry.KnotTheory.KauffmanBracket
import Geometry.KnotTheory.Jones

namespace Knot

open LaurentPolynomial

/-! ## Left Trefoil Knot

Loop counts from PD code [[1,5,2,4],[3,1,4,6],[5,3,6,2]]:
3 negative crossings, writhe = -3.
-/

/-- Loop counts for the left trefoil diagram, computed from
the planar diagram code. -/
def trefoilLoops : (Fin 3 → Smoothing) → ℕ := fun s =>
  match s 0, s 1, s 2 with
  | .A, .A, .A => 3
  | .A, .A, .B => 2
  | .A, .B, .A => 2
  | .A, .B, .B => 1
  | .B, .A, .A => 2
  | .B, .A, .B => 1
  | .B, .B, .A => 1
  | .B, .B, .B => 2

private theorem trefoilLoops_pos : ∀ s, 0 < trefoilLoops s := by
  intro s; simp only [trefoilLoops]
  cases s 0 <;> cases s 1 <;> cases s 2 <;> norm_num

/-- The unoriented trefoil diagram with 3 crossings. -/
def trefoilDiagram : LinkDiagram 3 where
  loops := trefoilLoops
  loops_pos := trefoilLoops_pos

/-- The oriented left trefoil: all 3 crossings are negative. -/
def trefoil : OrientedLinkDiagram 3 where
  toLinkDiagram := trefoilDiagram
  sign := fun _ => CrossingSign.neg

/-- The writhe of the left trefoil is -3. -/
theorem writhe_trefoil : writhe trefoil = -3 := by
  simp [writhe, trefoil, CrossingSign.toInt]

/-! ## Figure-Eight Knot -/

/-- Loop counts for the figure-eight knot (4 crossings, alternating). -/
def figureEightLoops : (Fin 4 → Smoothing) → ℕ := fun s =>
  match s 0, s 1, s 2, s 3 with
  | .A, .A, .A, .A => 3
  | .A, .A, .A, .B => 2
  | .A, .A, .B, .A => 2
  | .A, .A, .B, .B => 1
  | .A, .B, .A, .A => 2
  | .A, .B, .A, .B => 1
  | .A, .B, .B, .A => 1
  | .A, .B, .B, .B => 2
  | .B, .A, .A, .A => 2
  | .B, .A, .A, .B => 1
  | .B, .A, .B, .A => 1
  | .B, .A, .B, .B => 2
  | .B, .B, .A, .A => 1
  | .B, .B, .A, .B => 2
  | .B, .B, .B, .A => 2
  | .B, .B, .B, .B => 3

private theorem figureEightLoops_pos : ∀ s, 0 < figureEightLoops s := by
  intro s; simp only [figureEightLoops]
  cases s 0 <;> cases s 1 <;> cases s 2 <;> cases s 3 <;> norm_num

/-- The unoriented figure-eight diagram. -/
def figureEightDiagram : LinkDiagram 4 where
  loops := figureEightLoops
  loops_pos := figureEightLoops_pos

/-- The oriented figure-eight: alternating signs, writhe = 0. -/
def figureEight : OrientedLinkDiagram 4 where
  toLinkDiagram := figureEightDiagram
  sign := fun i => match i with
    | ⟨0, _⟩ => .pos
    | ⟨1, _⟩ => .neg
    | ⟨2, _⟩ => .pos
    | ⟨3, _⟩ => .neg

/-- The writhe of the figure-eight knot is 0. -/
theorem writhe_figureEight : writhe figureEight = 0 := by
  simp [writhe, figureEight, CrossingSign.toInt, Fin.sum_univ_four]

/-! ## Jones polynomial is a knot invariant -/

/-- The Jones polynomial is invariant under Reidemeister equivalence.
    This is the fundamental theorem: any two diagrams of the same
    knot have the same Jones polynomial. -/
theorem jones_invariant_under_equiv {D₁ D₂ : Σ n, OrientedLinkDiagram n}
    (h : ReidemeisterEquiv D₁ D₂) :
    jones D₁.2 = jones D₂.2 := by
  induction h with
  | refl _ => rfl
  | symm _ ih => exact ih.symm
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | ri_pos h => exact jones_RI_invariant h
  | ri_neg h => exact jones_RI_neg_invariant h
  | riii h => exact jones_RIII_invariant h

end Knot