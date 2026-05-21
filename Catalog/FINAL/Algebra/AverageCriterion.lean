/-
# Frankl Witness from Average Set Size Criterion

If the average set size is at least half the ground size, then
there exists an element appearing in at least half the sets.

Formally: if ground.card * |F| ≤ 2 * totalIncidence and ground is nonempty,
then HasFranklWitness.

This is Strategy 1 (double-counting + pigeonhole) from the Frankl program.
-/

import Algebra.Frankl.DoubleCount

open Finset BigOperators

namespace UnionClosedFamily

variable {α : Type*} [DecidableEq α]

/-
**Average cardinality criterion for Frankl witness.**

If the average set size in the family is at least half the ground size,
i.e., `ground.card * |F| ≤ 2 * totalIncidence`, and the ground is nonempty,
then some element appears in at least half the sets.

Proof: By the double counting identity, ∑_a freq(a) = totalIncidence.
By contradiction: if every freq(a) < |F|/2, then
  totalIncidence = ∑_a freq(a) < |ground| * |F| / 2 ≤ totalIncidence,
a contradiction. So some element has 2 * freq(a) ≥ |F|.
-/
theorem frankl_of_average_card_large (F : UnionClosedFamily α)
    (hg : F.ground.Nonempty)
    (h : F.ground.card * F.sets.card ≤ 2 * F.totalIncidence) :
    F.HasFranklWitness := by
  -- Assume for contradiction that every element in the ground set appears in fewer than half the sets.
  by_contra h_contra
  have h_bound : ∑ a ∈ F.ground, 2 * F.elemFreq a < F.ground.card * F.sets.card := by
    simp_all +decide [ UnionClosedFamily.HasFranklWitness ];
    simpa using Finset.sum_lt_sum_of_nonempty hg fun x hx => h_contra x;
  -- By the double counting identity, $2 \cdot \text{totalIncidence} = \sum_{a \in \text{ground}} 2 \cdot \text{elemFreq}(a)$.
  have h_double_counting : 2 * F.totalIncidence = ∑ a ∈ F.ground, 2 * F.elemFreq a := by
    rw [ ← Finset.mul_sum _ _ _, totalIncidence_eq_sum_elemFreq_ground ];
  grind

end UnionClosedFamily