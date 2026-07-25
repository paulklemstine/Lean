/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.GraphTheory.ConjugationProductCover

/-!
# Small doubling in right-ordered groups: representation mass and coset covers

This chapter isolates several mechanisms behind the threshold
`|S²| = 3|S| - 3`.  The order-theoretic argument supplies the universal
Cauchy–Davenport floor, while a fiber count converts the same hypothesis into
an exact formula for multiplicative collisions.  A final theorem combines this
with normal-subgroup product covering, connecting small doubling to quotient
and double-coset geometry.
-/

open scoped Pointwise
open Finset

namespace RightOrderedSmallDoubling

variable {G : Type*} [Group G] [DecidableEq G]

/-- The number of ordered representations `x = a b` with `a,b ∈ S`. -/
def representationCount (S : Finset G) (x : G) : ℕ :=
  ((S ×ˢ S).filter fun p => p.1 * p.2 = x).card

/-
A product belongs to `S²` exactly when its representation count is positive.
-/
theorem representationCount_pos_iff (S : Finset G) (x : G) :
    0 < representationCount S x ↔ x ∈ S * S := by
  unfold representationCount;
  simp +decide [ Finset.mem_mul, Finset.Nonempty ];
  grind

/-
The total representation mass over the product set is `|S|²`.
-/
theorem sum_representationCount (S : Finset G) :
    ∑ x ∈ S * S, representationCount S x = S.card ^ 2 := by
  simp +decide [ representationCount, sq ];
  rw [ ← Finset.card_eq_sum_card_fiberwise ];
  · exact Finset.card_product _ _;
  · exact fun p hp => Finset.mul_mem_mul ( Finset.mem_product.mp hp |>.1 ) ( Finset.mem_product.mp hp |>.2 )

/-
Removing one unit of mass at every occupied product leaves exactly the
collision surplus `|S|²-|S²|`.
-/
theorem collision_surplus_identity (S : Finset G) :
    ∑ x ∈ S * S, (representationCount S x - 1) = S.card ^ 2 - (S * S).card := by
  rw [ ← sum_representationCount, Nat.sub_eq_of_eq_add ];
  rw [ ← Finset.sum_congr rfl fun x hx => Nat.sub_add_cancel <| Nat.one_le_iff_ne_zero.mpr <| ne_of_gt <| by rw [ representationCount_pos_iff ] ; aesop, Finset.sum_add_distrib, Finset.sum_const, smul_eq_mul, mul_one ]

/-
Under the `3k-3` hypothesis, the total collision surplus is the explicit
quadratic `k²-3k+3`.
-/
theorem collision_surplus_of_three_k_minus_three (S : Finset G)
    (hsmall : (S * S).card = 3 * S.card - 3) :
    ∑ x ∈ S * S, (representationCount S x - 1) =
      S.card ^ 2 - (3 * S.card - 3) := by
  rw [collision_surplus_identity, hsmall]

/-
The ordered-group Cauchy–Davenport floor for a square product set.
-/
theorem ordered_square_lower_bound [LinearOrder G] [MulLeftMono G] [MulRightMono G]
    (S : Finset G) (hS : S.Nonempty) :
    2 * S.card - 1 ≤ (S * S).card := by
  convert cauchy_davenport_mul_of_linearOrder_isCancelMul hS hS using 1
  · omega
  · convert rfl

/-
At the `3k-3` threshold, the excess over the ordered Cauchy–Davenport floor
is exactly `k-2`.  In particular, a nonempty threshold set has at least two
elements.
-/
theorem three_k_minus_three_excess
    (S : Finset G) (hS : S.Nonempty)
    (hsmall : (S * S).card = 3 * S.card - 3) :
    2 ≤ S.card ∧ (S * S).card - (2 * S.card - 1) = S.card - 2 := by
  rcases n : S.card with ( _ | _ | n ) <;> simp_all +decide;
  omega

/-
Normal coset control and representation mass coexist at the small-doubling
threshold.  Thus quotient geometry bounds where products occur, while the
fiber identity records exactly how much multiplicative collision occurs there.
-/
theorem smallDoubling_normal_cover
    (H : Subgroup G) (hN : H.Normal) (S : Finset G) (T : Finset G)
    (hcover : ConjugationCover.SetCoveredByCosets (S : Set G) H T)
    (hsmall : (S * S).card = 3 * S.card - 3) :
    ConjugationCover.SetCoveredByCosets ((S * S : Finset G) : Set G) H (T * T) ∧
      (T * T).card ≤ T.card ^ 2 ∧
      ∑ x ∈ S * S, (representationCount S x - 1) =
        S.card ^ 2 - (3 * S.card - 3) := by
  refine' ⟨ _, _, collision_surplus_of_three_k_minus_three _ hsmall ⟩;
  · convert ConjugationCover.normal_product_covering H hN ( S : Set G ) T hcover;
    simp +decide [ Finset.coe_mul ];
  · simpa only [ sq ] using Finset.card_mul_le

-- !-- Lab Notes -- !--
/-
Hypothesis (Hypothesizer): The threshold `3k-3` should be studied through the
entire representation distribution, not only through product-set cardinality.
A second hypothesis proposed that normal-coset covers provide a quotient-level
shadow of the same phenomenon.  More ambitious conjectures concerning complete
Baumslag–Solitar classification were retained for future work because they
require a dedicated normal-form and order theory.

Experiment (Experimenter): The representation function was counted fiberwise
on `S × S`.  Independently, the ordered Cauchy–Davenport theorem was specialized
to `S²`, and normal product covering was applied to the underlying set of `S`.

Analysis (Analyst): The `3k-3` condition has two exact consequences.  Its gap
above the universal ordered floor is `k-2`, while its representation-collision
surplus is `k²-3k+3`.  These are complementary linear and quadratic statistics.
The normal-cover statement shows that collision mass and quotient geometry can
be controlled simultaneously without assuming commutativity.

Critique (Critic): Nonemptiness is indispensable for the ordered lower bound.
Natural-number subtraction is deliberately retained: positivity of each
occupied fiber justifies subtracting one representation per product.  The
normal-cover theorem does not claim a converse or a Baumslag–Solitar
classification; it records only the rigorously supported bridge.  None of the
main statements is definitional, and all depend on substantive fiber counting,
ordered-product growth, or coset-cover structure.

Synthesis (Principal Investigator): The resulting hierarchy proceeds from
support of the representation function, through mass conservation and exact
collision surplus, to ordered growth and normal quotient covering.  This gives
a reusable foundation for later structural classification at `3k-3`.
-/
-- !-- Lab Notes -- !--

end RightOrderedSmallDoubling