/-
Copyright (c) 2025. All rights reserved.

# The Sphere-Packing (Hamming) Bound for Block Codes

## Overview

This file formalizes the classical **sphere-packing bound** (also called the
**Hamming bound**) of algebraic coding theory, working over an arbitrary finite
additive group alphabet `G` indexed by a finite type `ι`. A *code* is a finite
set of words `C : Finset (ι → G)`. If the minimum Hamming distance of `C` is at
least `2 * t + 1`, then the Hamming balls of radius `t` centred at the codewords
are pairwise disjoint, and hence

    |C| · V(t) ≤ qⁿ

where `V(t)` is the (translation-invariant) volume of a Hamming ball of radius
`t`, `q = |G|` and `n = |ι|`. We further compute the volume exactly as

    V(t) = ∑_{i=0}^{t} C(n, i) · (q - 1)ⁱ,

yielding the standard closed form of the Hamming bound.

## Main Results

* `hammingDist_add_right` — Hamming distance is invariant under translation.
* `hammingBall_card_translation` — every Hamming ball has the same cardinality.
* `hammingBall_pairwise_disjoint` — radius-`t` balls about a min-distance-`(2t+1)`
  code are pairwise disjoint.
* `sphere_packing_bound` — `|C| · V(t) ≤ qⁿ` (the Hamming bound).
* `hammingBall_card_formula` — `V(t) = ∑_{i≤t} C(n,i)(q-1)ⁱ` (ball volume).
* `sphere_packing_bound_formula` — the closed-form Hamming bound.

## Catalog Synthesis

This extends the information-theoretic coding results of
`Catalog/Tropical/QarySourceCoding.lean` (q-ary entropy, Kraft inequality,
Shannon source-coding bounds) from the *compression* side to the
*error-correction* side: where `QarySourceCoding` bounds expected code length
from below by entropy, here we bound code *cardinality* from above by the
packing volume. Both are instances of the same volume/counting principle over
q-ary alphabets.
-/
import Mathlib

open Finset BigOperators

noncomputable section

namespace SpherePackingBound

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {G : Type*} [Fintype G] [DecidableEq G] [AddCommGroup G]

/-! ## Translation invariance of Hamming distance -/

/-
!-- Translation by a constant `c` cancels in the difference `(x+c) - (y+c) = x - y`,
so the Hamming norm (and hence distance) is unchanged. -- !--

**Hamming distance is translation invariant.**
-/
omit [DecidableEq ι] [Fintype G] in
theorem hammingDist_add_right (x y c : ι → G) :
    hammingDist (x + c) (y + c) = hammingDist x y := by
  unfold hammingDist;
  simp +decide

/-! ## Hamming balls -/

/-- The (closed) Hamming ball of radius `t` centred at `x`: all words within
    Hamming distance `t` of `x`. -/
def hammingBall (x : ι → G) (t : ℕ) : Finset (ι → G) :=
  Finset.univ.filter (fun y => hammingDist x y ≤ t)

omit [AddCommGroup G] in
@[simp] theorem mem_hammingBall {x y : ι → G} {t : ℕ} :
    y ∈ hammingBall x t ↔ hammingDist x y ≤ t := by
  simp [hammingBall]

/-
!-- The map `y ↦ y - x` is a bijection from the ball about `x` to the ball about `0`,
preserving the membership condition via translation invariance. -- !--

**All Hamming balls have the same cardinality**, equal to the volume of the
    ball about the origin.
-/
theorem hammingBall_card_translation (x : ι → G) (t : ℕ) :
    (hammingBall x t).card = (hammingBall (0 : ι → G) t).card := by
  -- Define the function that maps y to y - x and show it's a bijection.
  have h_bij : Finset.image (fun y => y - x) (hammingBall x t) = hammingBall 0 t := by
    ext y
    simp [hammingBall];
    constructor <;> intro h;
    · obtain ⟨ a, ha, rfl ⟩ := h; simp_all +decide [ hammingDist, hammingNorm ] ;
      simpa only [ sub_eq_zero, eq_comm ] using ha;
    · refine' ⟨ y + x, _, _ ⟩ <;> simp_all +decide [ hammingDist, hammingNorm ];
  rw [ ← h_bij, Finset.card_image_of_injective _ ( sub_left_injective ) ]

/-! ## Disjointness for codes of large minimum distance -/

/-
!-- If a word `y` lay in two radius-`t` balls, the triangle inequality would force
the two centres within distance `2t < 2t+1`, contradicting the minimum distance. -- !--

**Packing disjointness.** If every two distinct codewords of `C` are at
    Hamming distance at least `2 * t + 1`, the radius-`t` balls about the
    codewords are pairwise disjoint.
-/
omit [AddCommGroup G] in
theorem hammingBall_pairwise_disjoint
    (C : Finset (ι → G)) (t : ℕ)
    (hC : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    (C : Set (ι → G)).PairwiseDisjoint (fun c => hammingBall c t) := by
  intro c hc c' hc' hcc'
  simp only [Function.onFun, Finset.disjoint_left, mem_hammingBall]
  intro y hcy hc'y
  have hmin := hC c hc c' hc' hcc'
  have htri := hammingDist_triangle c y c'
  rw [hammingDist_comm y c'] at htri
  omega

/-! ## The sphere-packing bound -/

/-
!-- The codeword balls are pairwise disjoint subsets of the whole space, so the sum
of their (equal) cardinalities is at most `qⁿ`; rewrite the sum as `|C| · V(t)`. -- !--

**Sphere-packing / Hamming bound.** A code `C` of minimum distance at least
    `2 * t + 1` satisfies `|C| · V(t) ≤ qⁿ`, where `V(t)` is the volume of a
    radius-`t` Hamming ball and `qⁿ = |ι → G|` is the size of the whole space.
-/
theorem sphere_packing_bound
    (C : Finset (ι → G)) (t : ℕ)
    (hC : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card * (hammingBall (0 : ι → G) t).card ≤ Fintype.card (ι → G) := by
  -- Consider the set of all points in the Hamming space that are within distance $t$ from any codeword in $C$.
  set S := Finset.biUnion C (fun c => hammingBall c t) with hS_def;
  -- Since the Hamming balls are pairwise disjoint, the cardinality of their union is the sum of their cardinalities.
  have h_card_union : Finset.card S = Finset.sum C (fun c => Finset.card (hammingBall c t)) := by
    rw [ Finset.card_biUnion ] ; exact hammingBall_pairwise_disjoint C t hC;
  -- Since the Hamming balls are pairwise disjoint, the cardinality of their union is the sum of their cardinalities, which is at most the cardinality of the entire space.
  have h_card_le : Finset.card S ≤ Fintype.card (ι → G) := by
    exact Finset.card_le_univ _;
  rw [ h_card_union, Finset.sum_congr rfl fun x hx => hammingBall_card_translation x t ] at h_card_le ; aesop

/-! ## Exact volume of a Hamming ball -/

/-
!-- Group words by support set `S` of size `k`: words with support exactly `S`
biject with nonzero-valued functions on `S`, giving `(q-1)^k` each, and there are
`C(n,k)` such sets. -- !--

**Exact Hamming-sphere count.** The number of words at Hamming distance exactly
    `k` from the origin is `C(n, k) · (q-1)^k`.
-/
theorem hammingWeight_count (k : ℕ) :
    (Finset.univ.filter (fun y : ι → G => hammingDist 0 y = k)).card =
      (Fintype.card ι).choose k * (Fintype.card G - 1) ^ k := by
  -- The set of words with Hamming distance exactly k from the origin is in bijection with the set of functions from a fixed subset of size k to G'.
  set S := Finset.univ.filter (fun y : ι → G => hammingDist 0 y = k) with hS_def;
  -- For each subset T of size k, there are (q - 1)^k functions that are nonzero exactly on T.
  have h_subset_count : ∀ T : Finset ι, T.card = k → (Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)).card = (Fintype.card G - 1) ^ k := by
    intro T hT_card
    have h_subset_count : (Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)).card = (Finset.univ.filter (fun y : T → G => ∀ i : T, y i ≠ 0)).card := by
      refine' Finset.card_bij ( fun y hy => fun i => y i ) _ _ _ <;> simp_all +decide [ Finset.ext_iff ];
      · intro a₁ ha₁ a₂ ha₂ h; ext i; by_cases hi : i ∈ T <;> simp_all +decide [ funext_iff ] ;
        grind +ring;
      · intro b hb; use fun i => if hi : i ∈ T then b ⟨ i, hi ⟩ else 0; aesop;
    rw [ h_subset_count, ← hT_card ];
    rw [ show ( Finset.univ.filter fun y : T → G => ∀ i : T, y i ≠ 0 ) = Finset.image ( fun y : T → { x : G // x ≠ 0 } => fun i => ( y i : G ) ) ( Finset.univ : Finset ( T → { x : G // x ≠ 0 } ) ) from ?_, Finset.card_image_of_injective ];
    · simp +decide [ Finset.card_univ ];
    · exact fun x y hxy => funext fun i => Subtype.ext <| congr_fun hxy i;
    · ext; simp [Finset.mem_image];
      exact ⟨ fun h => ⟨ fun i => ⟨ _, h i i.2 ⟩, rfl ⟩, by rintro ⟨ a, rfl ⟩ i hi; exact a ⟨ i, hi ⟩ |>.2 ⟩;
  -- By summing over all subsets T of size k, we get the total number of words with Hamming distance exactly k from the origin.
  have h_sum : S = Finset.biUnion (Finset.powersetCard k (Finset.univ : Finset ι)) (fun T => Finset.univ.filter (fun y : ι → G => Finset.univ.filter (fun i => y i ≠ 0) = T)) := by
    ext y; simp [S];
    simp +decide [ hammingNorm ];
  rw [ h_sum, Finset.card_biUnion ];
  · rw [ Finset.sum_congr rfl fun T hT => h_subset_count T <| Finset.mem_powersetCard.mp hT |>.2 ] ; simp +decide [ Finset.card_univ ];
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z hz hz' => hxy <| by aesop;

/-
!-- A word of Hamming weight exactly `i` is chosen by selecting the `i` nonzero
positions (`C(n,i)` ways) and a nonzero symbol at each (`(q-1)ⁱ` ways); sum over `i ≤ t`. -- !--

**Volume of a Hamming ball.** The number of words within Hamming distance
    `t` of the origin equals `∑_{i=0}^{t} C(n, i) · (q-1)ⁱ`, where `n = |ι|`
    and `q = |G|`.
-/
theorem hammingBall_card_formula (t : ℕ) :
    (hammingBall (0 : ι → G) t).card =
      ∑ i ∈ Finset.range (t + 1),
        (Fintype.card ι).choose i * (Fintype.card G - 1) ^ i := by
  rw [ hammingBall ];
  rw [ show ( Finset.filter ( fun y => hammingDist 0 y ≤ t ) Finset.univ : Finset ( ι → G ) ) = Finset.biUnion ( Finset.range ( t + 1 ) ) fun i => Finset.filter ( fun y => hammingDist 0 y = i ) Finset.univ from ?_, Finset.card_biUnion ];
  · exact Finset.sum_congr rfl fun i hi => hammingWeight_count i;
  · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx hx' => hij <| by aesop;
  · ext y; simp [Finset.mem_biUnion]

/-
!-- Substitute the closed-form volume into `sphere_packing_bound` and rewrite
`|ι → G|` as `qⁿ`. -- !--

**Closed-form Hamming bound.** Combining the packing bound with the explicit
    ball volume gives `|C| · ∑_{i≤t} C(n,i)(q-1)ⁱ ≤ qⁿ`.
-/
theorem sphere_packing_bound_formula
    (C : Finset (ι → G)) (t : ℕ)
    (hC : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card *
        (∑ i ∈ Finset.range (t + 1),
          (Fintype.card ι).choose i * (Fintype.card G - 1) ^ i)
      ≤ (Fintype.card G) ^ (Fintype.card ι) := by
  convert sphere_packing_bound C t hC using 1;
  · rw [ hammingBall_card_formula ];
  · rw [ Fintype.card_fun ]

end SpherePackingBound
end