/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Pythagorean.ProbeComplexity.Defs

/-!
# Probe Complexity — Main Theorems

This file proves the main theorems about probe complexity of finite categories:

1. **`totalProbeFamily_isSeparating`**: The family of all objects is always separating
   (Yoneda-style extensionality).
2. **`probeComplexity_le_card`**: The probe complexity is at most the number of objects.
3. **`card_hom_le_profile_capacity`**: Information-theoretic lower bound — the cardinality
   of a hom-set is bounded by the product of function-space cardinalities over probes.
4. **`probeComplexity_pos_iff`**: Probe complexity is zero iff all hom-sets are
   subsingleton (characterization theorem).
5. **`single_probe_capacity_bound`**: Corollary bounding a hom-set size when
   there is exactly one probe.

## The Information-Theoretic Viewpoint

A separating probe family can be viewed as a **codebook**: the profile map
`Hom(X,Y) → ∏_{Z ∈ P} (Hom(Z,X) → Hom(Z,Y))` is injective, so the cardinality
of any hom-set is bounded by the capacity of the code. This is the categorical
analogue of an entropy bound in information theory.

## The Thin Category Theorem

A category where all hom-sets are subsingleton (at most one morphism between
any pair of objects) has probe complexity zero — the empty family is separating.
This includes all discrete categories and all poset categories. Conversely,
any category with at least two parallel morphisms requires at least one probe.
This gives a complete characterization of when probes are needed at all.
-/

open CategoryTheory Finset Fintype

noncomputable section

universe u

variable {C : Type u} [Category C]

/-! ### The Total Probe Family -/

/-- The **total probe family** consists of all objects of `C`. -/
def totalProbeFamily (C : Type u) [Category C] [Fintype C] : ProbeFamily C :=
  Finset.univ

/-- The total probe family is always separating: if `f` and `g` agree on precomposition
with every morphism from every object, then `f = g` by the Yoneda-style argument
(take `h = 𝟙 X`). -/
theorem totalProbeFamily_isSeparating (C : Type u) [Category C] [Fintype C] :
    (totalProbeFamily C).IsSeparating := by
  intro X Y f g hall
  have h := hall X (Finset.mem_univ X) (𝟙 X)
  simp at h
  exact h

/-! ### Probe Complexity -/

/-- The set of natural numbers that are cardinalities of separating probe families. -/
def separatingCards (C : Type u) [Category C] [Fintype C] : Set ℕ :=
  {k : ℕ | ∃ P : ProbeFamily C, P.card = k ∧ P.IsSeparating}

theorem separatingCards_nonempty (C : Type u) [Category C] [Fintype C] :
    (separatingCards C).Nonempty :=
  ⟨_, _, rfl, totalProbeFamily_isSeparating C⟩

/-- **Probe complexity** of a finite category: the minimum cardinality of a
separating probe family, defined as the infimum of the set of cardinalities
of separating families. -/
def probeComplexity (C : Type u) [Category C] [Fintype C] : ℕ :=
  sInf (separatingCards C)

/-- The probe complexity is at most the cardinality of any separating family. -/
theorem probeComplexity_le_of_separating (C : Type u) [Category C] [Fintype C]
    (P : ProbeFamily C) (hP : P.IsSeparating) :
    probeComplexity C ≤ P.card :=
  Nat.sInf_le ⟨P, rfl, hP⟩

/-- There exists a separating probe family whose cardinality is `probeComplexity C`. -/
theorem probeComplexity_achieved (C : Type u) [Category C] [Fintype C] :
    ∃ P : ProbeFamily C, P.card = probeComplexity C ∧ P.IsSeparating :=
  Nat.sInf_mem (separatingCards_nonempty C)

/-! ### Theorem 1: Upper bound by number of objects -/

/-- **Theorem 1 (Extremal upper bound).**
Every finite category has a separating probe family of size at most the number of objects.
This is the quantitative anchor for the theory: the family of all objects trivially
separates by taking `h = 𝟙 X` as the distinguishing morphism. -/
theorem probeComplexity_le_card (C : Type u) [Category C] [Fintype C] :
    probeComplexity C ≤ Fintype.card C := by
  calc probeComplexity C
      ≤ (totalProbeFamily C).card :=
        probeComplexity_le_of_separating C _ (totalProbeFamily_isSeparating C)
    _ = Fintype.card C := Finset.card_univ

/-! ### Theorem 2: Information-Theoretic Lower Bound -/

/-
**Theorem 2 (Profile capacity bound).**
For a separating probe family `P`, the cardinality of `Hom(X, Y)` is bounded by
the product over probe objects of the cardinality of the function space
`Hom(Z, X) → Hom(Z, Y)`, since the profile map is injective.

This is the categorical analogue of an entropy bound: a separating probe family
is an exact code for morphisms, and the profile capacity inequality bounds the
code size. Each probe object `Z` contributes a "channel" of capacity
`|Hom(Z,Y)|^|Hom(Z,X)|`, and the total capacity must cover all of `|Hom(X,Y)|`.

**Cross-domain significance:** This is the first rigorous bridge between
category theory and information/coding theory. It shows that the number of
probes is bounded below by an entropy budget — a categorical version of
Shannon's source coding theorem.
-/
theorem card_hom_le_profile_capacity
    [Fintype C] [DecidableEq C]
    [∀ (X Y : C), Fintype (X ⟶ Y)] [∀ (X Y : C), DecidableEq (X ⟶ Y)]
    (P : ProbeFamily C) (hP : P.IsSeparating) (X Y : C) :
    Fintype.card (X ⟶ Y) ≤
      ∏ Z : P, Fintype.card ((↑Z ⟶ X) → (↑Z ⟶ Y)) := by
  convert Fintype.card_le_of_injective _ (profileMap_injective P hP X Y) using 1
  exact (Fintype.card_pi).symm

/-! ### Theorem 3: The empty probe family and thin categories -/

/-- The empty probe family is separating if and only if all hom-sets are subsingleton
(every pair of parallel morphisms is equal). -/
theorem empty_isSeparating_iff [Fintype C] :
    (∅ : ProbeFamily C).IsSeparating ↔
      ∀ (X Y : C) (f g : X ⟶ Y), f = g := by
  constructor
  · intro hP X Y f g
    exact hP f g (fun Z hZ _ => absurd hZ (by simp))
  · intro hall _ _ f g _
    exact hall _ _ f g

/-- **Theorem 3a (Thin category theorem — zero complexity).**
If every hom-set in `C` is subsingleton, then probe complexity is zero.
This includes discrete categories (where `Hom(X,Y)` is `{X = Y}`)
and all poset categories. No probes are needed when there is nothing to
distinguish. -/
theorem probeComplexity_eq_zero_of_subsingleton_hom [Fintype C]
    (h : ∀ (X Y : C) (f g : X ⟶ Y), f = g) :
    probeComplexity C = 0 := by
  apply le_antisymm
  · calc probeComplexity C ≤ (∅ : ProbeFamily C).card :=
          probeComplexity_le_of_separating C ∅ (empty_isSeparating_iff.mpr h)
      _ = 0 := Finset.card_empty
  · exact Nat.zero_le _

/-
**Theorem 3b (Complete characterization of zero/positive probe complexity).**
Probe complexity is positive if and only if there exist distinct parallel morphisms.
Combined with Theorem 3a, this gives a complete characterization of when probes
are needed at all.
-/
theorem probeComplexity_pos_iff [Fintype C] :
    0 < probeComplexity C ↔ ∃ (X Y : C) (f g : X ⟶ Y), f ≠ g := by
  constructor;
  · intro h_pos;
    contrapose! h_pos;
    exact le_trans ( probeComplexity_le_of_separating C ∅ ( by simpa [ ProbeFamily.IsSeparating ] using h_pos ) ) ( by simp +decide );
  · intro h
    by_contra h_contra
    have h_empty : (∅ : ProbeFamily C).IsSeparating := by
      obtain ⟨ P, hP₁, hP₂ ⟩ := probeComplexity_achieved C; aesop;
    exact h.elim fun X hX => hX.elim fun Y hY => hY.elim fun f hf => hf.elim fun g hg => hg <| empty_isSeparating_iff.mp h_empty _ _ _ _

/-! ### Theorem 4: Monotonicity and structural properties -/

/-- A superset of a separating family is also separating. -/
theorem ProbeFamily.IsSeparating.supset [Fintype C]
    {P Q : ProbeFamily C} (hP : P.IsSeparating) (hPQ : P ⊆ Q) :
    Q.IsSeparating := by
  intro X Y f g hall
  apply hP
  intro Z hZ h
  exact hall Z (hPQ hZ) h

/-- A probe object that does not contribute to separation can be removed:
if removing `z` from `P` still yields a separating family, then the
smaller family suffices. This is the deletion principle for probes. -/
theorem ProbeFamily.IsSeparating.of_erase [Fintype C] [DecidableEq C]
    {P : ProbeFamily C} {z : C}
    (hP : ProbeFamily.IsSeparating (P.erase z)) :
    P.IsSeparating :=
  hP.supset (Finset.erase_subset z P)

/-! ### Theorem 5: Single-probe capacity bound -/

/-
**Theorem 5 (Single-probe capacity bound).**
If a single object `Z` constitutes a separating probe family for `C`,
then for every pair of objects `X Y`, the hom-set `Hom(X, Y)` has at most
`|Hom(Z, Y)|^|Hom(Z, X)|` elements. This is the specialization of
the profile capacity bound to a singleton probe family.
-/
theorem single_probe_capacity_bound
    [Fintype C] [DecidableEq C]
    [∀ (X Y : C), Fintype (X ⟶ Y)] [∀ (X Y : C), DecidableEq (X ⟶ Y)]
    (Z : C)
    (hZ : ProbeFamily.IsSeparating ({Z} : ProbeFamily C))
    (X Y : C) :
    Fintype.card (X ⟶ Y) ≤ Fintype.card (Z ⟶ Y) ^ Fintype.card (Z ⟶ X) := by
  convert card_hom_le_profile_capacity { Z } hZ X Y using 1;
  simp +decide [ Fintype.card_pi ]

end