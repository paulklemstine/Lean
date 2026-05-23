/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Algebraic Exactness Lemmas for Low-Dimensional Homotopy Computations

This file contains purely algebraic results about exact sequences that are used
to derive homotopy group computations from long exact sequences. The key result
is that in a four-term exact sequence A → B → C → D where A and D vanish,
the middle map B → C is bijective (and hence an isomorphism).

This is the algebraic engine behind the computation π₃(S²) ≅ ℤ via the Hopf
fibration: the vanishing of π₃(S¹), π₂(S¹), and π₂(S³) forces the map
π₃(S³) → π₃(S²) to be an isomorphism.
-/

import Mathlib

/-! ## Exactness-Forces-Isomorphism Lemma

The central algebraic fact: in a four-term exact sequence with vanishing ends,
the middle map is bijective.
-/

/-
In an exact sequence `A →[f] B →[g] C` where `A` is subsingleton (trivial group),
exactness implies `g` is injective. This is because exactness says `ker g = im f`,
and when `A` is trivial, `im f = {0}`, so `ker g = {0}`.
-/
theorem injective_of_exact_of_subsingleton_left
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (f : A →+ B) (g : B →+ C)
    (hex : Function.Exact f g)
    (hA : Subsingleton A) :
    Function.Injective g := by
  intro a₁ a₂ h; have := hex ( a₁ - a₂ ) ; simp_all +decide;
  obtain ⟨ y, hy ⟩ := this; simp_all +decide [ eq_sub_iff_add_eq ];
  rw [ ← hy, Subsingleton.elim y 0, map_zero, zero_add ]

/-
In an exact sequence `B →[g] C →[h] D` where `D` is subsingleton (trivial group),
exactness implies `g` is surjective. This is because exactness says `ker h = im g`,
and when `D` is trivial, `ker h = C`, so `im g = C`.
-/
theorem surjective_of_exact_of_subsingleton_right
    {B C D : Type*} [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (g : B →+ C) (h : C →+ D)
    (hex : Function.Exact g h)
    (hD : Subsingleton D) :
    Function.Surjective g := by
  intro c
  by_contra hc_not_mem_range_g
  have h_contra : h c ≠ 0 := by
    exact fun h' => hc_not_mem_range_g <| hex _ |>.1 h'
  exact h_contra (by
  exact Subsingleton.elim _ _)

/-
**Exactness-Forces-Isomorphism.** In a four-term exact sequence
`A →[f] B →[g] C →[h] D` with `A` and `D` both trivial (subsingleton),
the middle map `g : B →+ C` is bijective.

This is the algebraic core of the Hopf fibration computation:
from the exact sequence `π₃(S¹) → π₃(S³) → π₃(S²) → π₂(S¹)`,
the vanishing of `π₃(S¹)` and `π₂(S¹)` gives bijectivity of `π₃(S³) → π₃(S²)`.
-/
theorem bijective_of_exact_of_vanishing_ends
    {A B C D : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (f : A →+ B) (g : B →+ C) (h : C →+ D)
    (hex_fg : Function.Exact f g)
    (hex_gh : Function.Exact g h)
    (hA : Subsingleton A) (hD : Subsingleton D) :
    Function.Bijective g := by
  exact ⟨ injective_of_exact_of_subsingleton_left f g hex_fg hA, surjective_of_exact_of_subsingleton_right g h hex_gh hD ⟩

/-
The main algebraic derivation: in a four-term exact sequence
`A → B → C → D` with A, D trivial and `B ≃+ ℤ`, we get `C ≃+ ℤ`.
-/
theorem equiv_int_from_exact_sequence
    {A B C D : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (f : A →+ B) (g : B →+ C) (h : C →+ D)
    (hex_fg : Function.Exact f g)
    (hex_gh : Function.Exact g h)
    (hA : Subsingleton A) (hD : Subsingleton D)
    (eB : Nonempty (B ≃+ ℤ)) :
    Nonempty (C ≃+ ℤ) := by
  -- By bijective_of_exact_of_vanishing_ends, we get g bijective.
  have hg_bijective : Function.Bijective g := by
    exact bijective_of_exact_of_vanishing_ends f g h hex_fg hex_gh hA hD
  exact ⟨ ( AddEquiv.ofBijective g hg_bijective ).symm.trans eB.some ⟩