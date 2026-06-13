import Mathlib
import Logic.PolymodalGL

/-!
# Box does not factor over the synchronized product of GL frames

This file pursues **Direction 2** ("Box does not factor — a categorical obstruction
theorem") of the polymodal-GL research cycle, building directly on
`Catalog/Logic/PolymodalGL.lean`'s synchronized product `GLFrame.prod` and its
diamond-factorization theorem `GLFrame.prod_diamond_rectangle`
(`◇(A ×ˢ B) = (◇A) ×ˢ (◇B)`).

The cycle's `prod_diamond_rectangle` showed the **diamond** of a rectangle factors
*exactly* as a rectangle of diamonds — the modal signature of a categorical product.
The accompanying failure analysis conjectured that **box does not factor**, because a
world with no successor makes `□` vacuously true.  Here we turn that informal remark
into theorems.

## Main results

* `GLFrame.prod_box_rectangle_subset` — the *easy* inclusion always holds:
  `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` in the product frame.

* `GLFrame.prod_box_rectangle_of_edgeless` — when **both** factor frames are edgeless
  (no accessibility at all), the inclusion is an equality.  This is the only nonempty
  situation in which box factors.

* `GLFrame.prod_box_not_factor` — the **obstruction**: an explicit two-world frame `F`
  (one edge) and one-world dead-end frame `G`, with concrete sets `A`, `B`, for which
  `(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)` is a *strict* inclusion.  Box genuinely fails to factor.

## Correction to the cycle's Direction 2

Direction 2 conjectured that box factors *iff both frames are serial* (every world
has a successor).  This is **vacuous in the GL setting**: a serial GL frame is empty,
because converse well-foundedness (`GLFrame.flip_wellFounded`, hence
`exists_maximal_world`) always produces a dead-end world in any *nonempty* frame.  The
correct coincidence criterion is therefore **edge-freeness** of the factors, recorded
in `prod_box_rectangle_of_edgeless` and witnessed sharp by `prod_box_not_factor`.

-- !-- Lab Notebook -- !--
**Hypothesis.** The box of a rectangle does *not* factor as a rectangle of boxes in
the synchronized product, even though the diamond does (`prod_diamond_rectangle`).

**Result.** Confirmed. The inclusion `(□A)×ˢ(□B) ⊆ □(A×ˢB)` always holds; equality
holds when both frames are edgeless; and an explicit dead-end witness makes the
inclusion strict otherwise.

**Insight.** ◇ is an existential over a *synchronized* step, so the witness splits
coordinate-wise — a product. □ is a universal over synchronized steps, and a dead end
in one coordinate empties the quantifier, making □ vacuously true regardless of the
other coordinate. Asymmetry of ∃ vs ∀ over the product step is the categorical core of
why GL is "◇-natural".

**Failure analysis.** The seriality criterion conjectured in Direction 2 collapses:
converse well-foundedness forces every nonempty GL frame to have a dead end, so the
only serial GL frame is empty. Edge-freeness is the corrected criterion.
-- !-- end Lab Notebook -- !--
-/

open Set Function

namespace GLFrame

/-
!-- The easy inclusion: if every F-successor of w₁ is in A and every G-successor of
w₂ is in B, then every synchronized product-successor of (w₁,w₂) is in A ×ˢ B. -- !--

**The box rectangle inclusion (always holds).**  In the synchronized product,
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)`.  This is the half of the factorization that survives.
-/
theorem prod_box_rectangle_subset (F G : GLFrame) (A : Set F.World) (B : Set G.World) :
    (F.boxSet A) ×ˢ (G.boxSet B) ⊆ (F.prod G).boxSet (A ×ˢ B) := by
  intro x hx; simp_all +decide [ Set.mem_prod, GLFrame.boxSet ] ;
  exact fun v hv₁ hv₂ => ⟨ hx.1 _ hv₁, hx.2 _ hv₂ ⟩

/-
!-- If both frames are edgeless, every box is `univ` (vacuously) and the product is
edgeless too, so both sides equal `univ`. -- !--

**Box factors when both frames are edgeless.**  If neither `F` nor `G` has any
accessibility edge, then `(□A) ×ˢ (□B) = □(A ×ˢ B)` in the product.  This is the only
way box can factor over a nonempty product (serial GL frames being empty).
-/
theorem prod_box_rectangle_of_edgeless (F G : GLFrame)
    (hF : ∀ w v, ¬ F.R w v) (hG : ∀ w v, ¬ G.R w v)
    (A : Set F.World) (B : Set G.World) :
    (F.prod G).boxSet (A ×ˢ B) = (F.boxSet A) ×ˢ (G.boxSet B) := by
  ext ⟨w1, w2⟩; simp [GLFrame.boxSet, GLFrame.prod, Set.mem_prod];
  grind

/-! ## The obstruction: explicit frames where box fails to factor -/

/-- A two-world GL frame on `Bool` with the single edge `true → false`. -/
def boolEdge : GLFrame where
  World := Bool
  R := fun x y => x = true ∧ y = false
  irrefl := by rintro w ⟨h1, h2⟩; rw [h1] at h2; exact Bool.noConfusion h2
  trans := by rintro w v u ⟨-, hv⟩ ⟨hv', -⟩; rw [hv] at hv'; exact absurd hv' (by decide)

/-- A one-world dead-end GL frame on `Unit` with no edges. -/
def unitDead : GLFrame where
  World := Unit
  R := fun _ _ => False
  irrefl := by intro w h; exact h
  trans := by intro w v u h _; exact h.elim

/-
!-- At `(true, ())`: the product box of the rectangle holds vacuously because `()`
is a dead end, but `true` is *not* in `□{true}` because it sees `false ∉ {true}`. -- !--

**Box does not factor (the obstruction).**  For the concrete frames `boolEdge`
(one edge) and `unitDead` (a dead end), with `A = {true}` and `B = univ`, the box of
the rectangle *strictly* contains the rectangle of boxes:
`(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)`.  The point `(true, ())` lies in the right side (vacuously,
since `()` is a dead end) but not the left (since `true` sees `false ∉ A`).
-/
theorem prod_box_not_factor :
    (boolEdge.boxSet {true}) ×ˢ (unitDead.boxSet (Set.univ))
      ⊂ (boolEdge.prod unitDead).boxSet (({true} : Set Bool) ×ˢ (Set.univ : Set Unit)) := by
  unfold boolEdge unitDead GLFrame.boxSet GLFrame.prod; simp +decide [ Set.ssubset_def ] ;
  simp +decide [ Set.Subset.antisymm_iff, Set.subset_def ]

end GLFrame