/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# ECOC Robustness from Coordinatewise Lipschitz Margins

This file bridges coordinatewise Lipschitz stability of score-gap classifiers to
multiclass prediction robustness under nearest-codeword (ECOC) decoding.

The key insight is that tropical Satake/Hecke score maps for GL₃ provide
Lipschitz-bounded score gaps. When these gaps have sufficient margin, coordinate
bits are certified stable under perturbation. If enough coordinates are stable,
error-correcting code distance ensures the overall multiclass prediction is invariant.

## Main results

- `bit_fixed_of_margin`: A positive score gap with margin exceeding Lipschitz perturbation
  stays positive.
- `bit_fixed_of_margin_neg`: A negative score gap with sufficient margin stays negative.
- `ecoc_robust_of_coordinate_margins`: Global ECOC robustness from coordinatewise margin
  certificates and minimum code distance.
- `ecoc_robust_of_pairwise_majority_margins`: Refined pairwise majority version avoiding
  global minimum distance.

## References

The formulation is motivated by the tropical geometry / representation theory program
connecting GL₃ Hecke algebras to robust classification via tropical Satake transforms.
-/
import Mathlib
import Bridges.HammingCode
open Finset ECOC

namespace ECOC

/-! ## Coordinate-level stability from Lipschitz margins -/

/-
A positive score gap with margin exceeding `L j * r` is preserved under
any perturbation satisfying the Lipschitz bound.
-/
theorem bit_fixed_of_margin
    {m : ℕ} {α : Type*} {Perturb : α → α → ℝ → Prop}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {x x' : α} {r : ℝ} (_hr : 0 ≤ r) (hxx' : Perturb x x' r)
    {j : Fin m}
    (hmargin_pos : L j * r < gap j x) :
    0 < gap j x' := by
  linarith [ abs_le.mp ( hLip j x x' r hxx' ) ]

/-
A negative score gap with margin exceeding `L j * r` stays negative.
-/
theorem bit_fixed_of_margin_neg
    {m : ℕ} {α : Type*} {Perturb : α → α → ℝ → Prop}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {x x' : α} {r : ℝ} (_hr : 0 ≤ r) (hxx' : Perturb x x' r)
    {j : Fin m}
    (hmargin_neg : L j * r < -gap j x) :
    gap j x' < 0 := by
  linarith [ abs_le.mp ( hLip j x x' r hxx' ) ]

/-! ## Predicted bit vector and bad coordinates -/

/-- The predicted bit vector: coordinate `j` predicts `true` iff `0 ≤ gap j x`. -/
noncomputable def predBits {m : ℕ} {α : Type*} (gap : Fin m → α → ℝ) (x : α) : Fin m → Bool :=
  fun j => decide (0 ≤ gap j x)

/-- The "bad" coordinates for class `c` at input `x` with perturbation radius `r`:
those whose margin does not exceed the Lipschitz perturbation budget. -/
noncomputable def badCoords
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (L : Fin m → ℝ)
    (c : Fin n) (x : α) (r : ℝ) : Finset (Fin m) :=
  Finset.univ.filter fun j =>
    if code c j then gap j x ≤ L j * r else -gap j x ≤ L j * r

/-
Key lemma: if coordinate `j` is not bad (i.e., has sufficient margin) and
the clean prediction matches the code, then the perturbed prediction also matches.
-/
theorem coord_stable_of_not_bad
    {n m : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x x' : α} {r : ℝ}
    (hr : 0 ≤ r)
    (hxx' : Perturb x x' r)
    (hclean : predBits gap x = code c)
    {j : Fin m}
    (hgood : j ∉ badCoords code gap L c x r) :
    predBits gap x' j = code c j := by
  by_cases hc : code c j <;> simp_all +decide [ badCoords, predBits ];
  · linarith [ abs_le.mp ( hLip j x x' r hxx' ) ];
  · linarith [ abs_le.mp ( hLip j x x' r hxx' ) ]

/-
The Hamming distance between the perturbed prediction and the code for class `c`
is at most the number of bad coordinates.
-/
theorem hammingDist_perturbed_le_bad
    {n m : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x x' : α} {r : ℝ}
    (hr : 0 ≤ r)
    (hxx' : Perturb x x' r)
    (hclean : predBits gap x = code c) :
    hammingDist (predBits gap x') (code c) ≤ (badCoords code gap L c x r).card := by
  refine' Finset.card_le_card _;
  intro j hj; contrapose! hj; simp_all +decide [ Finset.ext_iff ] ;
  exact coord_stable_of_not_bad hLip hr hxx' hclean hj

/-! ## Main ECOC robustness theorem -/

/-- **ECOC Robustness Theorem**: If the code has minimum distance `δ`, the clean prediction
matches codeword `c`, and fewer than `δ/2` coordinates lack sufficient margin, then
every admissible perturbation preserves unique nearest-codeword decoding to class `c`. -/
theorem ecoc_robust_of_coordinate_margins
    {n m δ : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ}
    {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hδ : MinDistAtLeast code δ)
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x : α} {r : ℝ}
    (hr : 0 ≤ r)
    (hclean : predBits gap x = code c)
    (hbad : 2 * (badCoords code gap L c x r).card < δ) :
    ∀ x', Perturb x x' r → nearestUnique code (predBits gap x') c := by
  intro x' hxx'
  apply nearest_codeword_unique_of_lt_half_minDist hδ
  calc 2 * hammingDist (predBits gap x') (code c)
      ≤ 2 * (badCoords code gap L c x r).card :=
        Nat.mul_le_mul_left 2 (hammingDist_perturbed_le_bad hLip hr hxx' hclean)
    _ < δ := hbad

/-! ## Pairwise majority margins -/

/-- The number of disagreement coordinates where class `c` has robust margin over rival `c'`. -/
noncomputable def robustDisagreeCount
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (L : Fin m → ℝ)
    (c : Fin n) (x : α) (r : ℝ) (c' : Fin n) : ℕ :=
  ((disagreeSet code c c').filter fun j =>
    if code c j then L j * r < gap j x else L j * r < -gap j x).card

/-
On the disagreement set, each coordinate's Bool value equals either
`code c j` or `code c' j` (since these two differ there).
-/
theorem disagree_bool_dichotomy {n m : ℕ}
    (code : Fin n → Fin m → Bool) (c c' : Fin n)
    (y : Fin m → Bool) (j : Fin m)
    (hj : j ∈ disagreeSet code c c') :
    y j = code c j ∨ y j = code c' j := by
  cases h : code c j <;> cases h' : code c' j <;> cases h'' : y j <;> simp_all +decide;
  · unfold disagreeSet at hj; aesop;
  · unfold disagreeSet at hj; aesop;

/-
The disagreement set partitions into coordinates favoring `c` and those favoring `c'`.
-/
theorem disagree_card_split {n m : ℕ}
    (code : Fin n → Fin m → Bool) (c c' : Fin n) (y : Fin m → Bool) :
    ((disagreeSet code c c').filter fun j => y j = code c j).card +
    ((disagreeSet code c c').filter fun j => y j ≠ code c j).card =
    (disagreeSet code c c').card := by
  rw [ Finset.card_filter_add_card_filter_not ]

/-
On disagreement coordinates, `y j ≠ code c j` iff `y j = code c' j`.
-/
theorem disagree_ne_iff_eq {n m : ℕ}
    (code : Fin n → Fin m → Bool) (c c' : Fin n)
    (y : Fin m → Bool) (j : Fin m)
    (hj : j ∈ disagreeSet code c c') :
    (y j ≠ code c j) ↔ (y j = code c' j) := by
  cases h : code c j <;> cases h' : code c' j <;> simp_all +decide [ ne_of_apply_ne ];
  · unfold disagreeSet at hj; aesop;
  · unfold disagreeSet at hj; aesop;

/-
If strictly more than half the disagreement coordinates favor `c`,
then `y` is strictly closer to `code c` than to `code c'`.
-/
theorem hammingDist_lt_of_majority_favor {n m : ℕ}
    (code : Fin n → Fin m → Bool) (c c' : Fin n) (y : Fin m → Bool)
    (hmaj : 2 * ((disagreeSet code c c').filter fun j => y j = code c j).card >
            (disagreeSet code c c').card) :
    hammingDist y (code c) < hammingDist y (code c') := by
  -- By definition of Hamming distance, we can write
  have h_hamming_c : hammingDist y (code c) =
    ((Finset.univ \ disagreeSet code c c').filter (fun j => y j ≠ code c j)).card +
    ((disagreeSet code c c').filter (fun j => y j ≠ code c j)).card := by
      simp +decide [ hammingDist, Finset.filter_filter ];
      rw [ ← Finset.card_union_of_disjoint ];
      · congr with j ; by_cases hj : j ∈ disagreeSet code c c' <;> aesop;
      · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => Finset.mem_sdiff.mp ( Finset.mem_filter.mp hx₁ |>.1 ) |>.2 ( Finset.mem_filter.mp hx₂ |>.1 );
  have h_hamming_c' : hammingDist y (code c') =
    ((Finset.univ \ disagreeSet code c c').filter (fun j => y j ≠ code c' j)).card +
    ((disagreeSet code c c').filter (fun j => y j ≠ code c' j)).card := by
      rw [ hammingDist, ← Finset.card_union_of_disjoint ];
      · congr with j ; by_cases hj : j ∈ disagreeSet code c c' <;> aesop;
      · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => Finset.mem_sdiff.mp ( Finset.mem_filter.mp hx₁ |>.1 ) |>.2 ( Finset.mem_filter.mp hx₂ |>.1 );
  -- On the complement of the disagreement set, the Hamming distances are equal.
  have h_complement : ((Finset.univ \ disagreeSet code c c').filter (fun j => y j ≠ code c j)).card =
                      ((Finset.univ \ disagreeSet code c c').filter (fun j => y j ≠ code c' j)).card := by
                        congr 1 with j ; simp +contextual [ disagreeSet ];
  have h_disagree : ((disagreeSet code c c').filter (fun j => y j ≠ code c j)).card =
                     (disagreeSet code c c').card - ((disagreeSet code c c').filter (fun j => y j = code c j)).card := by
                       rw [ tsub_eq_of_eq_add_rev ];
                       rw [ Finset.card_filter_add_card_filter_not ];
  have h_disagree' : ((disagreeSet code c c').filter (fun j => y j ≠ code c' j)).card =
                           ((disagreeSet code c c').filter (fun j => y j = code c j)).card := by
                             refine' congr_arg Finset.card ( Finset.ext fun x => _ );
                             simp +decide [ disagreeSet ];
                             cases h : code c x <;> cases h' : code c' x <;> cases h'' : y x <;> simp +decide [ h, h', h'' ];
  omega

/-
Robust coordinates on the disagree set will agree with `code c` after perturbation.
-/
theorem robust_coords_agree_after_perturbation
    {n m : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x x' : α} {r : ℝ}
    (_hr : 0 ≤ r) (hxx' : Perturb x x' r)
    (c' : Fin n) :
    (disagreeSet code c c').filter (fun j =>
      if code c j then L j * r < gap j x else L j * r < -gap j x) ⊆
    (disagreeSet code c c').filter (fun j => predBits gap x' j = code c j) := by
  intro j hj
  simp [predBits] at hj ⊢;
  split_ifs at hj <;> simp_all +decide [ abs_le ];
  · linarith [ hLip j x x' r hxx' ];
  · linarith [ hLip j x x' r hxx' ]

/-
**Pairwise ECOC Robustness Theorem**: for each rival `c'`, if strictly more than
half the coordinates on which `c` and `c'` differ have certified margin, then
every admissible perturbation preserves unique nearest-codeword decoding to `c`.

This avoids introducing a global minimum distance and works with pairwise
tropical Satake margins.
-/
theorem ecoc_robust_of_pairwise_majority_margins
    {n m : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ}
    {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x : α} {r : ℝ}
    (_hr : 0 ≤ r)
    (_hclean : predBits gap x = code c)
    (hpair : ∀ c', c' ≠ c →
      2 * robustDisagreeCount code gap L c x r c' > (disagreeSet code c c').card) :
    ∀ x', Perturb x x' r → nearestUnique code (predBits gap x') c := by
  intro x' hx' c' hc';
  apply hammingDist_lt_of_majority_favor;
  exact lt_of_lt_of_le ( hpair c' hc' ) ( Nat.mul_le_mul_left _ ( Finset.card_mono ( robust_coords_agree_after_perturbation hLip _hr hx' c' ) ) )

end ECOC