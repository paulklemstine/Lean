/-
  # Concrete Knot Examples

  Explicit link diagrams for the trefoil and figure-eight knots.
  Loop counts computed from standard PD codes.
-/
import Mathlib
import Speculative.Knot.Defs
import Speculative.Knot.KauffmanBracket
import Speculative.Knot.Jones

namespace Knot

open LaurentPolynomial

/-! ## Left Trefoil Knot (3 negative crossings, writhe = -3)

Loop counts from PD code [[1,5,2,4],[3,1,4,6],[5,3,6,2]]:
  AAA: 3, AAB: 2, ABA: 2, ABB: 1
  BAA: 2, BAB: 1, BBA: 1, BBB: 2
-/

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

def trefoilDiagram : LinkDiagram 3 where
  loops := trefoilLoops
  loops_pos := trefoilLoops_pos

def trefoil : OrientedLinkDiagram 3 where
  toLinkDiagram := trefoilDiagram
  sign := fun _ => CrossingSign.neg

theorem writhe_trefoil : writhe trefoil = -3 := by
  simp [writhe, trefoil, CrossingSign.toInt]

/-! ## Figure-Eight Knot (4 crossings, alternating signs, writhe = 0) -/

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

def figureEightDiagram : LinkDiagram 4 where
  loops := figureEightLoops
  loops_pos := figureEightLoops_pos

def figureEight : OrientedLinkDiagram 4 where
  toLinkDiagram := figureEightDiagram
  sign := fun i => match i with
    | ⟨0, _⟩ => .pos
    | ⟨1, _⟩ => .neg
    | ⟨2, _⟩ => .pos
    | ⟨3, _⟩ => .neg

theorem writhe_figureEight : writhe figureEight = 0 := by
  simp [writhe, figureEight, CrossingSign.toInt, Fin.sum_univ_four]

/-- Torus knot T(2,3) is the trefoil -/
def torusKnot_2_3 : OrientedLinkDiagram 3 := trefoil

end Knot