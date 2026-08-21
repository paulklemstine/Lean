import Catalog.Geometry.PadicBerggrenOrbits

/-!
# The prime `2`: total collapse of the Berggren dynamics, and the parity of the tree

The p-adic analysis in `Catalog/Geometry/PadicBerggrenDynamics.lean` always excludes `p = 2`.
This file explains why, and turns the exclusion into a theorem: **mod `2` all three Berggren
generators are the identity matrix**, so the reduced dynamical system degenerates completely —
the infinite ternary tree maps to a single point.  The arithmetic shadow of this degeneracy is
the classical parity pattern of Pythagorean triples produced by the tree.

## Main results

* `PadicBerggren.B₁_mod_two`, `B₂_mod_two`, `B₃_mod_two`, `gen_mod_two` : each generator
  reduces to `1` in `ZMod 2`.
* `PadicBerggren.wordMat_mod_two` : hence every word in the generators reduces to `1`.
* `PadicBerggren.tree_mod_two` : every vertex of the Berggren tree is congruent to the root
  `(3,4,5) ≡ (1,0,1)` mod `2`; the mod-`2` dynamical system has exactly one orbit, a fixed
  point.  This is the "`if false`" scenario of the research programme, realised exactly at the
  prime `2`.
* `PadicBerggren.tree_parity_int` : the integral form — for every word `w`, the triple
  `wordMat ℤ w *ᵥ (3,4,5)` has odd first entry, even second entry and odd third entry.
  In particular no Berggren move can ever produce a triple with two odd legs.
* `PadicBerggren.tree_parity_not_all_odd` : consequently no vertex of the tree has both legs
  odd (an obstruction which, over `ZMod 2`, is exactly the statement that the null cone mod `2`
  is *not* all of `(ZMod 2)³`).
-/

namespace PadicBerggren

open Matrix

theorem B₁_mod_two : B₁ (ZMod 2) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [B₁] <;> decide

theorem B₂_mod_two : B₂ (ZMod 2) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [B₂] <;> decide

theorem B₃_mod_two : B₃ (ZMod 2) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [B₃] <;> decide

theorem gen_mod_two (i : Fin 3) : gen (ZMod 2) i = 1 := by
  fin_cases i
  · exact B₁_mod_two
  · exact B₂_mod_two
  · exact B₃_mod_two

/-- **Mod `2` the whole tree collapses.**  Every word in the Berggren generators reduces to the
identity matrix. -/
theorem wordMat_mod_two (w : List (Fin 3)) : wordMat (ZMod 2) w = 1 := by
  induction w with
  | nil => simp [wordMat]
  | cons a w ih =>
      have hstep : wordMat (ZMod 2) (a :: w) = gen (ZMod 2) a * wordMat (ZMod 2) w := by
        simp [wordMat, List.map_cons, List.prod_cons]
      rw [hstep, ih, gen_mod_two, one_mul]

/-- Every vertex of the Berggren tree is congruent to `(1,0,1)` mod `2`. -/
theorem tree_mod_two (w : List (Fin 3)) :
    wordMat (ZMod 2) w *ᵥ root (ZMod 2) = ![1, 0, 1] := by
  rw [wordMat_mod_two, Matrix.one_mulVec]
  funext i
  fin_cases i <;> simp [root] <;> decide

/-- **Integral parity of the tree.**  Every Pythagorean triple produced by the Berggren moves
from `(3,4,5)` has an odd leg, an even leg and an odd hypotenuse, in this order. -/
theorem tree_parity_int (w : List (Fin 3)) :
    (wordMat ℤ w *ᵥ root ℤ) 0 % 2 = 1 ∧ (wordMat ℤ w *ᵥ root ℤ) 1 % 2 = 0 ∧
      (wordMat ℤ w *ᵥ root ℤ) 2 % 2 = 1 := by
  induction w with
  | nil =>
      refine ⟨?_, ?_, ?_⟩ <;>
        simp [wordMat, Matrix.one_mulVec, root]
  | cons a w ih =>
      obtain ⟨h0, h1, h2⟩ := ih
      have hstep : wordMat ℤ (a :: w) *ᵥ root ℤ = gen ℤ a *ᵥ (wordMat ℤ w *ᵥ root ℤ) := by
        simp [wordMat, List.map_cons, List.prod_cons, Matrix.mulVec_mulVec]
      rw [hstep]
      set v : Fin 3 → ℤ := wordMat ℤ w *ᵥ root ℤ with hv
      fin_cases a <;>
        refine ⟨?_, ?_, ?_⟩ <;>
        simp [gen, B₁, B₂, B₃, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;>
        omega

/-- No vertex of the tree has two odd legs. -/
theorem tree_parity_not_all_odd (w : List (Fin 3)) :
    ¬ ((wordMat ℤ w *ᵥ root ℤ) 0 % 2 = 1 ∧ (wordMat ℤ w *ᵥ root ℤ) 1 % 2 = 1) := by
  rintro ⟨-, h1⟩
  obtain ⟨-, h1', -⟩ := tree_parity_int w
  omega

end PadicBerggren