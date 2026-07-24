import Mathlib
import Geometry.HadwigerDebrunner.Combinatorial

/-!
# Combinatorial certificates for rectangle piercing constructions

This file isolates three reusable certificates underlying horizontal–vertical
rectangle constructions.  The geometric coordinates enter only when checking
the hypotheses: triangle-freeness forces every point to pierce at most two
members; an ordered-slot map bounds a disjoint subfamily; and the squaring
recurrence of the recursive construction has a closed form.
-/

open Finset

namespace WegnerRectangles

variable {ι X : Type*}

/-- No point belongs to three distinct members of the indexed family. -/
def PointTriangleFree (s : Finset ι) (F : ι → Set X) : Prop :=
  ∀ x i, i ∈ s → x ∈ F i → ∀ j, j ∈ s → x ∈ F j →
    ∀ k, k ∈ s → x ∈ F k → i = j ∨ i = k ∨ j = k

/-
A triangle-free family needs at least half as many piercing points as
members.  This is the counting certificate used for the lower bound `τ ≥ 32`:
each chosen point can account for at most two indexed rectangles.
-/
theorem triangleFree_transversal_count [DecidableEq ι] [DecidableEq X]
    {s : Finset ι} {F : ι → Set X} {T : Finset X}
    (hfree : PointTriangleFree s F)
    (hT : HadwigerDebrunner.IsTransversal T s F) :
    s.card ≤ 2 * T.card := by
  choose! f hf₁ hf₂ using hT;
  -- By partitioning $s$ by the chosen point, we can show that each fiber has at most two elements.
  have h_partition : ∀ t ∈ T, Finset.card (Finset.filter (fun i => f i.1 i.2 = t) (Finset.attach s)) ≤ 2 := by
    intro t ht; by_contra h_contra; simp_all +decide ;
    obtain ⟨ i, hi, j, hj, hij ⟩ := Finset.two_lt_card.mp h_contra;
    grind +locals;
  have h_card : Finset.card s = Finset.sum T (fun t => Finset.card (Finset.filter (fun i => f i.1 i.2 = t) (Finset.attach s))) := by
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  exact h_card.symm ▸ le_trans ( Finset.sum_le_sum h_partition ) ( by simp +decide [ mul_comm ] )

/-
The numerical piercing consequence for a 64-member triangle-free family.
-/
theorem sixtyFour_requires_thirtyTwo [DecidableEq ι] [DecidableEq X]
    {s : Finset ι} {F : ι → Set X} {T : Finset X}
    (hs : s.card = 64) (hfree : PointTriangleFree s F)
    (hT : HadwigerDebrunner.IsTransversal T s F) :
    32 ≤ T.card := by
  linarith [ triangleFree_transversal_count hfree hT ]

/-
An ordered-slot certificate for packing.  If each selected member is assigned
one of `m` slots and no slot receives more than `b` selected members, then the
selection has size at most `m*b`.  In the eight-rectangle gadget one takes four
slots; applying the certificate to the four horizontal blocks gives the bound
`ν ≤ 16`.
-/
theorem card_le_slots_times_capacity [DecidableEq ι]
    {s : Finset ι} {m b : ℕ} (slot : ι → Fin m)
    (hcap : ∀ q : Fin m, (s.filter fun i => slot i = q).card ≤ b) :
    s.card ≤ m * b := by
  convert Finset.sum_le_sum fun q ( hq : q ∈ Finset.univ ) => hcap q;
  · simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  · simp +decide

/-
Four blocks, each controlled by four ordered slots of capacity one, contain
at most sixteen selected rectangles.
-/
theorem four_by_four_packing_bound [DecidableEq ι]
    {s : Finset ι} (block slot : ι → Fin 4)
    (hcap : ∀ p q : Fin 4,
      (s.filter fun i => block i = p ∧ slot i = q).card ≤ 1) :
    s.card ≤ 16 := by
  exact le_trans ( Finset.card_le_card ( show s ⊆ Finset.biUnion ( Finset.univ : Finset ( Fin 4 × Fin 4 ) ) fun p => Finset.filter ( fun i => block i = p.1 ∧ slot i = p.2 ) s from fun i hi => by aesop ) ) ( Finset.card_biUnion_le.trans <| Finset.sum_le_card_nsmul _ _ _ fun x hx ↦ hcap _ _ ) |> le_trans <| by simp +arith +decide;

/-
Closed form of the squaring recurrence appearing in the recursive families:
starting from four and squaring at each horizontal–vertical step gives
`4^(2^r)`.
-/
theorem squaring_recurrence_closed_form (a : ℕ → ℕ)
    (hzero : a 0 = 4) (hstep : ∀ r, a (r + 1) = (a r) ^ 2) :
    ∀ r, a r = 4 ^ (2 ^ r) := by
  exact fun x => by induction x <;> simp +decide [ *, pow_succ, pow_mul ] ;

/-- A finite subfamily is pairwise disjoint when each two distinct indexed sets
have empty intersection. -/
def PairwiseDisjointIn (A : Finset ι) (F : ι → Set X) : Prop :=
  ∀ i ∈ A, ∀ j ∈ A, i ≠ j → Disjoint (F i) (F j)

/-- A coordinate certificate with 64 members, triangle-freeness, a disjoint
16-subfamily, and an upper bound of 16 on every disjoint subfamily simultaneously
certifies exact packing number 16 and piercing number at least 32. -/
theorem certified_counterexample_bounds [DecidableEq ι] [DecidableEq X]
    {s witness : Finset ι} {F : ι → Set X}
    (hs : s.card = 64) (hwsub : witness ⊆ s) (hwcard : witness.card = 16)
    (hwdisj : PairwiseDisjointIn witness F)
    (hpack : ∀ A ⊆ s, PairwiseDisjointIn A F → A.card ≤ 16)
    (hfree : PointTriangleFree s F) :
    witness ⊆ s ∧ PairwiseDisjointIn witness F ∧ witness.card = 16 ∧
      (∀ A ⊆ s, PairwiseDisjointIn A F → A.card ≤ witness.card) ∧
      (∀ T : Finset X, HadwigerDebrunner.IsTransversal T s F → 32 ≤ T.card) := by
  refine ⟨hwsub, hwdisj, hwcard, ?_, ?_⟩
  · intro A hAs hAdisj
    simpa [hwcard] using hpack A hAs hAdisj
  · intro T hT
    exact sixtyFour_requires_thirtyTwo hs hfree hT

/-- The two certified bounds violate Wegner's proposed inequality at packing
number sixteen: a piercing lower bound of thirty-two is strictly larger than
`2*16-1`. -/
theorem wegner_numeric_violation {packing piercing : ℕ}
    (hpacking : packing = 16) (hpiercing : 32 ≤ piercing) :
    2 * packing - 1 < piercing := by
  omega

/-- The finite level-three ratio exceeds the earlier value `17891/8064`. -/
theorem gap_seventyThree_over_thirtyTwo_improves :
    (17891 : ℚ) / 8064 < 73 / 32 := by
  norm_num

-- !-- Lab Notes -- !--
/-!
## Hypothesis

The geometric argument can be separated into three finite certificates. First,
triangle-freeness limits every transversal point to two rectangles. Second, an
ordered-slot assignment limits every disjoint selection by bounded fibers.
Third, horizontal–vertical composition squares the packing number.

## Experiment

The fiber-counting statements were tested at their sharp boundary. A
triangle-free family permits fibers of size two, so the coefficient two in the
transversal inequality cannot be reduced without additional hypotheses. Four
blocks with four capacity-one slots give sixteen available cells. Iterated
squaring from four gives the values `4, 16, 256, 65536` through level three.

## Analysis

Both the piercing and packing estimates are instances of the same principle:
a finite selection mapped into a certificate space has cardinality at most the
sum of its fiber capacities. This isolates the reusable combinatorics from the
coordinate comparisons needed for a particular rectangle realization.

## Critique

The results here are conditional certificate theorems. They do not themselves
supply the endpoint coordinates of the 64 rectangles, nor do they derive the
level-three linear-program optimum. Thus they establish the implications that
a coordinate certificate must discharge, rather than claiming an independent
reconstruction of all geometric and optimization data. The factor-two bound
is sharp under triangle-freeness alone.

## Synthesis

A 64-member coordinate family satisfying the stated triangle-free and packing
certificates has packing number sixteen and requires at least thirty-two
piercing points. Since `32 > 2 · 16 - 1`, these certificates imply the desired
numerical violation. The recursive squaring certificate simultaneously yields
the closed packing scale `4^(2^r)`.
-/

end WegnerRectangles