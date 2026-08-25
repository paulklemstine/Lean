import Physics.TernaryPythagoreanTrees.Triples

/-!
# A conservation law for the branches of a ternary Pythagorean tree

For a node-preserving map `M = (a, b; c, d)` the set of nodes whose image has first coordinate
at most `B` is the lattice-point set of the triangle
`{(x, y) : 0 < y < x, a x + b y ≤ B}`, whose area is `B² / (2 a (a + b))`.  So
`branchDensity M = 1 / (a (a + b))` is the *proportion of the node cone* that the branch `M`
occupies, and the fact that the three branches of a ternary tree partition the non-root nodes
predicts

  `branchDensity (T 0) + branchDensity (T 1) + branchDensity (T 2) = 1`.

`TernaryTree.branch_density_sum_one` proves this identity for every ternary Pythagorean tree,
as an exact statement in `ℚ`, by running through the classification.  (The area/density
interpretation above is the motivation; only the exact rational identity is formalised.)

The companion theorem `TernaryTree.det_natAbs_sum_mem` records the *determinant spectrum*
`|det| ∈ {1,1,1}, {2,2,2}, {1,2,2}` — the invariant that separates the three trees:
the sum of `|det|` over the branches is `3` (Berggren), `6` (Price) or `5` (mixed).
-/

namespace TernaryTree

/-- The proportion of the node cone occupied by the image of the branch `M`. -/
def branchDensity (M : IntMap) : ℚ := 1 / ((M.a : ℚ) * ((M.a : ℚ) + (M.b : ℚ)))

@[simp] lemma branchDensity_bergA : branchDensity bergA = 1 / 2 := by
  norm_num [branchDensity, bergA]

@[simp] lemma branchDensity_bergB : branchDensity bergB = 1 / 6 := by
  norm_num [branchDensity, bergB]

@[simp] lemma branchDensity_bergC : branchDensity bergC = 1 / 3 := by
  norm_num [branchDensity, bergC]

@[simp] lemma branchDensity_priceP0 : branchDensity priceP0 = 1 / 2 := by
  norm_num [branchDensity, priceP0]

@[simp] lemma branchDensity_priceP1 : branchDensity priceP1 = 1 / 4 := by
  norm_num [branchDensity, priceP1]

@[simp] lemma branchDensity_priceP2 : branchDensity priceP2 = 1 / 4 := by
  norm_num [branchDensity, priceP2]

@[simp] lemma branchDensity_mixF0 : branchDensity mixF0 = 1 / 4 := by
  norm_num [branchDensity, mixF0]

/-- **Conservation law.**  The three branch densities of any ternary Pythagorean tree sum to
`1`: the branches split the node cone into three pieces of complementary density. -/
theorem branch_density_sum_one {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    branchDensity (T 0) + branchDensity (T 1) + branchDensity (T 2) = 1 := by
  have hinj := branches_injective hT
  have h01 : T 0 ≠ T 1 := fun h => by simpa using hinj h
  have h02 : T 0 ≠ T 2 := fun h => by simpa using hinj h
  have h12 : T 1 ≠ T 2 := fun h => by simpa using hinj h
  rcases tree_classification hT with h | h | h <;>
    rcases h 0 with e0 | e0 | e0 <;> rcases h 1 with e1 | e1 | e1 <;>
      rcases h 2 with e2 | e2 | e2 <;> simp only [e0, e1, e2] at h01 h02 h12 ⊢ <;>
      first
        | exact absurd rfl h01
        | exact absurd rfl h02
        | exact absurd rfl h12
        | norm_num

/-- **Determinant spectrum.**  The sum of `|det|` over the three branches is `3` for the
Berggren tree, `6` for the Price tree and `5` for the mixed tree — in particular it is never
larger than `6`, a sharp quantitative form of the `±2` obstruction. -/
theorem det_natAbs_sum_mem {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    (T 0).det.natAbs + (T 1).det.natAbs + (T 2).det.natAbs = 3 ∨
      (T 0).det.natAbs + (T 1).det.natAbs + (T 2).det.natAbs = 6 ∨
      (T 0).det.natAbs + (T 1).det.natAbs + (T 2).det.natAbs = 5 := by
  have hinj := branches_injective hT
  have h01 : T 0 ≠ T 1 := fun h => by simpa using hinj h
  have h02 : T 0 ≠ T 2 := fun h => by simpa using hinj h
  have h12 : T 1 ≠ T 2 := fun h => by simpa using hinj h
  rcases tree_classification hT with h | h | h <;>
    rcases h 0 with e0 | e0 | e0 <;> rcases h 1 with e1 | e1 | e1 <;>
      rcases h 2 with e2 | e2 | e2 <;> simp only [e0, e1, e2] at h01 h02 h12 ⊢ <;>
      first
        | exact absurd rfl h01
        | exact absurd rfl h02
        | exact absurd rfl h12
        | (norm_num [IntMap.det, bergA, bergB, bergC, priceP0, priceP1, priceP2, mixF0])

/-- The determinant sum is at most `6` in every ternary Pythagorean tree. -/
theorem det_natAbs_sum_le_six {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    (T 0).det.natAbs + (T 1).det.natAbs + (T 2).det.natAbs ≤ 6 := by
  rcases det_natAbs_sum_mem hT with h | h | h <;> omega

end TernaryTree