/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Algebraic Foundations for Tropical Büchi–Elgot

Key algebraic lemmas about `WithTop ℕ` that underpin the tropical automata–logic
correspondence, especially the distributivity of addition over infimum.
-/

import Mathlib
import Tropical.WeightedMSO.Defs

namespace TropicalMSO

open Classical

/-! ## Distributivity in WithTop ℕ -/

/-
Addition distributes over binary infimum in `WithTop ℕ`.
    This is the algebraic engine behind synchronized product semantics.
-/
theorem tropical_add_distrib_inf (a b c : Weight) :
    a + (b ⊓ c) = (a + b) ⊓ (a + c) := by
  exact?

/-
Right-hand distributivity of addition over binary infimum.
-/
theorem tropical_add_distrib_inf_right (a b c : Weight) :
    (a ⊓ b) + c = (a + c) ⊓ (b + c) := by
  cases a <;> cases b <;> cases c <;> simp_all +decide [ min_def ];
  all_goals aesop

/-
Addition distributes over finite infimum (`Finset.inf`).
-/
theorem tropical_add_distrib_finset_inf {ι : Type*}
    (a : Weight) (s : Finset ι) (hs : s.Nonempty) (f : ι → Weight) :
    a + s.inf' hs f = s.inf' hs (fun i => a + f i) := by
  induction hs using Finset.Nonempty.cons_induction <;> simp_all +decide [ Finset.inf'_insert ];
  convert tropical_add_distrib_inf a ( f _ ) _ using 2 ; aesop

/-
Addition distributes over `iInf` for `Fintype` index sets.
-/
theorem tropical_add_distrib_iInf {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : Weight) (f : ι → Weight) :
    a + ⨅ i, f i = ⨅ i, (a + f i) := by
  -- Apply the lemma that states addition distributes over the infimum of a finite set.
  have h_inf : ⨅ i, f i = Finset.inf' Finset.univ (Finset.univ_nonempty) f := by
    exact?;
  have h_inf : Finset.inf' Finset.univ (Finset.univ_nonempty) (fun i => a + f i) = ⨅ i, a + f i := by
    exact?;
  rw [ ← h_inf, ‹⨅ i, f i = Finset.univ.inf' ⋯ f›, tropical_add_distrib_finset_inf ]

/-
Right-hand version of `iInf` distributivity.
-/
theorem tropical_iInf_add_distrib {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → Weight) (a : Weight) :
    (⨅ i, f i) + a = ⨅ i, (f i + a) := by
  -- By definition of addition and infimum in the tropical semiring, we can rewrite the left-hand side.
  have h_lhs : (⨅ i, f i) + a = ⨅ i, (f i + a) := by
    have h_add_comm : ∀ (x y : Weight), x + y = y + x := by
      exact fun x y => add_comm x y
    convert tropical_add_distrib_iInf a f using 1;
    · exact h_add_comm _ _;
    · simp +decide only [h_add_comm];
  exact h_lhs

/-
Key identity for product automaton correctness: independent infima of sums
    equal the sum of independent infima.
-/
theorem tropical_iInf_prod_eq {ι₁ ι₂ : Type*} [Fintype ι₁] [Fintype ι₂]
    [Nonempty ι₁] [Nonempty ι₂]
    (f : ι₁ → Weight) (g : ι₂ → Weight) :
    (⨅ i, f i) + (⨅ j, g j) = ⨅ (p : ι₁ × ι₂), (f p.1 + g p.2) := by
  convert tropical_add_distrib_iInf ( ⨅ j, g j ) f using 1;
  · exact add_comm _ _;
  · simp +decide only [add_comm];
    rw [ show ( ⨅ p : ι₁ × ι₂, f p.1 + g p.2 ) = ⨅ i : ι₁, ⨅ j : ι₂, f i + g j from ?_ ];
    · congr! 1;
      exact funext fun i => by rw [ tropical_add_distrib_iInf ] ;
    · exact?

/-! ## WithTop ℕ arithmetic -/

/-
Zero is the identity for tropical addition (left).
-/
theorem tropical_zero_add (a : Weight) : (0 : Weight) + a = a := by
  grobner

/-
Zero is the identity for tropical addition (right).
-/
theorem tropical_add_zero (a : Weight) : a + (0 : Weight) = a := by
  cases a <;> aesop

/-
Top absorbs under tropical addition (left).
-/
theorem tropical_top_add (a : Weight) : (⊤ : Weight) + a = ⊤ := by
  cases a <;> aesop

/-
Top absorbs under tropical addition (right).
-/
theorem tropical_add_top (a : Weight) : a + (⊤ : Weight) = ⊤ := by
  cases a <;> aesop

/-
Top is the identity for tropical infimum (left).
-/
theorem tropical_top_inf (a : Weight) : (⊤ : Weight) ⊓ a = a := by
  cases a <;> rfl

/-
Top is the identity for tropical infimum (right).
-/
theorem tropical_inf_top (a : Weight) : a ⊓ (⊤ : Weight) = a := by
  grind

end TropicalMSO