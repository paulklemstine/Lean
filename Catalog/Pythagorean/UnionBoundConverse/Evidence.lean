import Pythagorean.UnionBoundConverse.PairwiseIndependence

/-!
# Kernel-checked numerics for the extremal collision probability

This file turns the tables of `ComputationalEvidence.md` into checked Lean
statements.  For the Carter–Wegman affine family over `ZMod p` we

* count, by kernel evaluation, the number of indices `(a,b)` at which the hash
  function collides on the full key set (it is exactly `p`, namely `a = 0`);
* deduce the exact collision probability `1/p` for `p = 2, 3, 5, 7`, matching
  the linear-programming optimum reported in Section 4 of the evidence file to
  the digit;
* exhibit the gap to the union bound: for `p = 7` and all seven keys the union
  bound allows `21/7 = 3`, the truth is `1/7 ≈ 0.1428…`, and the converse bound
  `1/7` is attained exactly.

The counts are genuine computations (`decide`), the probabilities are
consequences of the general theorems, not of numerical evaluation.
-/

namespace UnionBoundConverse

open Finset

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

instance fact_prime_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩

/-! ### Collision counts of the affine family, by kernel evaluation -/

theorem affine_collision_count_two :
    (Finset.univ.filter (fun ab : ZMod 2 × ZMod 2 =>
      ∃ x y : ZMod 2, x ≠ y ∧ affineHash 2 ab x = affineHash 2 ab y)).card = 2 := by
  decide

theorem affine_collision_count_three :
    (Finset.univ.filter (fun ab : ZMod 3 × ZMod 3 =>
      ∃ x y : ZMod 3, x ≠ y ∧ affineHash 3 ab x = affineHash 3 ab y)).card = 3 := by
  decide

theorem affine_collision_count_five :
    (Finset.univ.filter (fun ab : ZMod 5 × ZMod 5 =>
      ∃ x y : ZMod 5, x ≠ y ∧ affineHash 5 ab x = affineHash 5 ab y)).card = 5 := by
  decide

theorem affine_collision_count_seven :
    (Finset.univ.filter (fun ab : ZMod 7 × ZMod 7 =>
      ∃ x y : ZMod 7, x ≠ y ∧ affineHash 7 ab x = affineHash 7 ab y)).card = 7 := by
  decide

/-- The counts above are `p` out of `p²` indices, i.e. a fraction `1/p`; note
also that only a `1/p` fraction of the affine maps is constant. -/
theorem affine_collision_fraction_five :
    ((Finset.univ.filter (fun ab : ZMod 5 × ZMod 5 =>
      ∃ x y : ZMod 5, x ≠ y ∧ affineHash 5 ab x = affineHash 5 ab y)).card : ℚ)
      / (Fintype.card (ZMod 5 × ZMod 5) : ℚ) = 1 / 5 := by
  rw [affine_collision_count_five]
  norm_num [Fintype.card_prod, ZMod.card]

/-! ### Exact collision probabilities -/

theorem card_univ_zmod (p : ℕ) [NeZero p] :
    (Finset.univ : Finset (ZMod p)).card = p := by
  simp [Finset.card_univ, ZMod.card]

theorem affine_collisionProb_two :
    (affineLaw 2).prob (Collides (affineHash 2) (Finset.univ : Finset (ZMod 2)))
      = 1 / 2 := by
  have := affine_collisionProb 2 (S := (Finset.univ : Finset (ZMod 2)))
    (by rw [card_univ_zmod])
  simpa using this

theorem affine_collisionProb_three :
    (affineLaw 3).prob (Collides (affineHash 3) (Finset.univ : Finset (ZMod 3)))
      = 1 / 3 := by
  have := affine_collisionProb 3 (S := (Finset.univ : Finset (ZMod 3)))
    (by rw [card_univ_zmod]; norm_num)
  simpa using this

theorem affine_collisionProb_five :
    (affineLaw 5).prob (Collides (affineHash 5) (Finset.univ : Finset (ZMod 5)))
      = 1 / 5 := by
  have := affine_collisionProb 5 (S := (Finset.univ : Finset (ZMod 5)))
    (by rw [card_univ_zmod]; norm_num)
  simpa using this

theorem affine_collisionProb_seven :
    (affineLaw 7).prob (Collides (affineHash 7) (Finset.univ : Finset (ZMod 7)))
      = 1 / 7 := by
  have := affine_collisionProb 7 (S := (Finset.univ : Finset (ZMod 7)))
    (by rw [card_univ_zmod]; norm_num)
  simpa using this

/-! ### The gap between the two endpoints -/

/-- For `p = 7` and all seven keys, the union bound gives the vacuous value `3`
while the exact collision probability of the affine family, and hence the
extremal value over all exactly `2`-universal families, is `1/7`. -/
theorem union_bound_gap_seven :
    ((Finset.univ : Finset (ZMod 7)).card.choose 2 : ℝ) / (Fintype.card (ZMod 7) : ℝ) = 3 ∧
      (affineLaw 7).prob (Collides (affineHash 7) (Finset.univ : Finset (ZMod 7))) = 1 / 7 ∧
      (1 : ℝ) / 7 < 3 := by
  refine ⟨?_, affine_collisionProb_seven, by norm_num⟩
  rw [card_univ_zmod, ZMod.card]
  have hchoose : Nat.choose 7 2 = 21 := by decide
  rw [hchoose]
  norm_num

/-- The extremal value is *independent of the number of keys*: over `ZMod 7`
the collision probability of the affine family on two keys and on all seven
keys is the same number `1/7`, whereas the union bound grows from `1/7` to
`3`. -/
theorem extremal_value_key_independent :
    (affineLaw 7).prob (Collides (affineHash 7) ({0, 1} : Finset (ZMod 7))) =
      (affineLaw 7).prob (Collides (affineHash 7) (Finset.univ : Finset (ZMod 7))) := by
  have h2 : ((0 : ZMod 7) ≠ 1) := by decide
  have hcard : ({0, 1} : Finset (ZMod 7)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simp [h2]), Finset.card_singleton]
  rw [affine_collisionProb 7 (S := ({0, 1} : Finset (ZMod 7))) (by rw [hcard]),
    affine_collisionProb_seven]
  norm_num

/-! ### Pigeonhole degeneration, checked on a concrete family -/

/-- With eight keys and seven buckets every hash function collides: the affine
family over `ZMod 7`, viewed on the key set `Fin 8` through `i ↦ (i : ZMod 7)`,
has collision probability `1`. -/
theorem pigeonhole_eight_keys_seven_buckets :
    (affineLaw 7).prob
        (Collides (fun ab (i : Fin 8) => affineHash 7 ab (i : ZMod 7))
          (Finset.univ : Finset (Fin 8))) = 1 := by
  refine collisionProb_eq_one_of_card_lt _ _ ?_
  rw [ZMod.card]
  simp

end UnionBoundConverse