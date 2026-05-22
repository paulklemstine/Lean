/-
Copyright (c) 2025. All rights reserved.
Ordered/Unordered Representation Transfer Law.
-/
import Mathlib

/-!
# Ordered/Unordered Goldbach Witness Transfer Law

We prove the exact relationship between ordered and unordered Goldbach
witness counts via the swap symmetry.

## Main Results

* `goldbachWitnessesOrd_swap` — swap preserves ordered witnesses
* `ordered_goldbach_count_split` — the orbit decomposition formula
* `goldbachWitnessesDiag_card_le_one` — diagonal has at most one element
* `goldbachWitnessesUnord_eq_union` — unordered = strict ∪ diagonal
-/

open Finset Nat

namespace PrimeDecomp

/-- The finset of ordered pairs `(p, q)` of primes with `p + q = n`. -/
def goldbachWitnessesOrd (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n)

/-- The finset of unordered (canonical) pairs `(p, q)` with `p ≤ q`,
both prime, and `p + q = n`. -/
def goldbachWitnessesUnord (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n ∧ pq.1 ≤ pq.2)

/-- The strictly-less-than part of Goldbach witnesses. -/
def goldbachWitnessesStrict (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n ∧ pq.1 < pq.2)

/-- The diagonal part of Goldbach witnesses: pairs `(p, p)` with `p + p = n`. -/
def goldbachWitnessesDiag (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n ∧ pq.1 = pq.2)

/-- The greater-than part of Goldbach witnesses. -/
def goldbachWitnessesGt (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n + 1)) ×ˢ (Finset.range (n + 1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n ∧ pq.2 < pq.1)

/-
Swapping coordinates preserves membership in the ordered Goldbach witness set.
-/
theorem goldbachWitnessesOrd_swap {n p q : ℕ}
    (h : (p, q) ∈ goldbachWitnessesOrd n) :
    (q, p) ∈ goldbachWitnessesOrd n := by
  unfold goldbachWitnessesOrd at *; simp_all +decide [ add_comm ] ;

/-
The strict and greater-than parts are in bijection via swap.
-/
theorem goldbachWitnessesStrict_card_eq_gt (n : ℕ) :
    (goldbachWitnessesStrict n).card = (goldbachWitnessesGt n).card := by
  rw [ Finset.card_eq_sum_ones, Finset.card_eq_sum_ones ];
  refine' Finset.sum_bij ( fun x hx => ( x.2, x.1 ) ) _ _ _ _ <;> simp +contextual [ goldbachWitnessesStrict, goldbachWitnessesGt ];
  · intros; rw [ add_comm ] ; assumption;
  · intros; rw [ add_comm ] ; aesop;

/-
The ordered witness set splits as strict + diagonal + gt.
-/
theorem goldbachWitnessesOrd_card_eq (n : ℕ) :
    (goldbachWitnessesOrd n).card =
      (goldbachWitnessesStrict n).card +
      (goldbachWitnessesDiag n).card +
      (goldbachWitnessesGt n).card := by
  rw [ ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ] <;> congr;
  · ext ⟨ p, q ⟩ ; simp +decide [ goldbachWitnessesOrd, goldbachWitnessesStrict, goldbachWitnessesDiag, goldbachWitnessesGt ] ;
    grind;
  · simp +contextual [ Finset.disjoint_left, goldbachWitnessesStrict, goldbachWitnessesDiag, goldbachWitnessesGt ];
    grind;
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;

/-
**The orbit decomposition formula:** ordered = 2 * strict + diagonal.
-/
theorem ordered_goldbach_count_split (n : ℕ) :
    (goldbachWitnessesOrd n).card
      = 2 * (goldbachWitnessesStrict n).card
        + (goldbachWitnessesDiag n).card := by
  rw [ ( goldbachWitnessesOrd_card_eq n ), ( goldbachWitnessesStrict_card_eq_gt n ) ] ; ring

/-
The diagonal has at most one element.
-/
theorem goldbachWitnessesDiag_card_le_one (n : ℕ) :
    (goldbachWitnessesDiag n).card ≤ 1 := by
  exact Finset.card_le_one.mpr fun x hx y hy => by
    have hx_diag := (Finset.mem_filter.mp hx)
    have hy_diag := (Finset.mem_filter.mp hy)
    have h1 := hx_diag.right
    have h2 := hy_diag.right
    grind

/-
The strict and diagonal parts are disjoint.
-/
theorem strict_diag_disjoint (n : ℕ) :
    Disjoint (goldbachWitnessesStrict n) (goldbachWitnessesDiag n) := by
  exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;

/-
The unordered witness set equals the union of strict and diagonal parts.
-/
theorem goldbachWitnessesUnord_eq_union (n : ℕ) :
    goldbachWitnessesUnord n = goldbachWitnessesStrict n ∪ goldbachWitnessesDiag n := by
  -- By definition of $goldbachWitnessesUnord$, we know that
  ext ⟨p, q⟩
  simp [goldbachWitnessesUnord, goldbachWitnessesStrict, goldbachWitnessesDiag];
  grind

/-
Unordered = strict + diagonal (cardinality).
-/
theorem goldbachWitnessesUnord_card (n : ℕ) :
    (goldbachWitnessesUnord n).card =
      (goldbachWitnessesStrict n).card + (goldbachWitnessesDiag n).card := by
  rw [ ← Finset.card_union_of_disjoint ( strict_diag_disjoint n ), goldbachWitnessesUnord_eq_union ]

end PrimeDecomp