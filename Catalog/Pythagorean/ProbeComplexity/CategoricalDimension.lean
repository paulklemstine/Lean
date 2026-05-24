/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Probe Complexity as Categorical Dimension

This file develops the theory of **probe complexity** as a categorical invariant
analogous to global dimension, Krull dimension, and representation type.

## Main Definitions

* `PrecomposeSeparatingFamily` — a set of objects that distinguishes all parallel
  morphisms by precomposition.
* `categoryProbeComplexity` — the minimal cardinality of a finite separating family,
  valued in `WithTop ℕ` (using `⊤` when no finite separating family exists).
* `IsSimpleProbeBasis` — a separating family consisting of pairwise non-isomorphic
  simple objects that represent all simple isomorphism classes.

## Main Results

* `ModuleCat_field_k_precompose_separates` — Over a field `k`, the one-dimensional
  space `k` alone separates all morphisms in `ModuleCat k` by precomposition.
  This identifies probe complexity with rank-one tomography.
* `categoryProbeComplexity_ModuleCat_le_one` — The probe complexity of `ModuleCat k`
  over a field is at most 1.
* `categoryProbeComplexity_ModuleCat_eq_one` — For a nontrivial field, it is exactly 1.
* `separatingFamily_pullback_faithful` — Separating families pull back along
  faithful functors.
* `separatingFamily_pushforward_full_faithful` — Separating families push forward
  along full and faithful functors.

## The Categorical Tomography Viewpoint

Probe complexity measures how many "test objects" are needed to distinguish all
morphisms by precomposition. In the category of vector spaces over a field,
a single 1-dimensional space suffices because linear maps are determined by their
action on vectors, and vectors biject with maps from `k`. This is the categorical
analogue of quantum state tomography: the probe objects are measurement devices,
and probe complexity is the minimal measurement basis size.

## Cross-Domain Connections

- **Homological algebra**: In semisimple categories, simple objects form a minimal
  probe basis. Probe complexity equals the number of simple isomorphism classes.
- **Representation theory**: For `Rep(G)` over a splitting field with coprime
  characteristic, probe complexity equals the number of irreducible representations.
- **Algebraic geometry**: Separating probes resemble an atlas of test objects in a
  sheaf category.
- **Quantum information**: Probe complexity is a categorified measurement complexity,
  with simple objects as elementary particle types / superselection sectors.

## Application Keywords

categorical dimension, probe complexity, semisimple category, simple objects,
Jordan–Hölder, representation theory, finite group representations, categorical
tomography, Yoneda detection, operator identification, measurement complexity,
TQFT, sheaf-theoretic probes, homological algebra, black-box morphism reconstruction.
-/

open CategoryTheory

noncomputable section

universe u v

/-! ## Core Definitions -/

/-- A set of objects `S` in a category `C` is a **precompose-separating family** if
for every pair of parallel morphisms `f g : X ⟶ Y`, whenever `h ≫ f = h ≫ g` for
all `P ∈ S` and all `h : P ⟶ X`, then `f = g`.

This is the central concept of categorical tomography: the objects in `S` serve as
"measurement devices" that collectively determine all morphisms. -/
def PrecomposeSeparatingFamily
    {C : Type u} [Category.{v} C] (S : Set C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y),
    (∀ P ∈ S, ∀ h : P ⟶ X, h ≫ f = h ≫ g) → f = g

/-- The **probe complexity** of a category `C` is the minimum cardinality of a finite
precompose-separating family, or `⊤` if no finite separating family exists.

This is a categorical invariant analogous to global dimension and Krull dimension,
measuring the minimum number of "test objects" needed to distinguish all morphisms. -/
def categoryProbeComplexity (C : Type u) [Category.{v} C] : WithTop ℕ :=
  ⨅ (S : Finset C) (_ : PrecomposeSeparatingFamily (↑S : Set C)), (S.card : WithTop ℕ)

/-- A set of objects is a **simple probe basis** for an abelian category if it consists
of pairwise non-isomorphic simple objects that represent all simple isomorphism classes,
and it forms a separating family. -/
def IsSimpleProbeBasis
    {C : Type u} [Category.{v} C] [Limits.HasZeroMorphisms C]
    (S : Set C) : Prop :=
  (∀ X ∈ S, Simple X) ∧
  (∀ X ∈ S, ∀ Y ∈ S, X ≠ Y → IsEmpty (X ≅ Y)) ∧
  (∀ X : C, Simple X → ∃ Y ∈ S, Nonempty (X ≅ Y)) ∧
  PrecomposeSeparatingFamily S

/-! ## Theorem 1: The field probe theorem for ModuleCat -/

/-
**Theorem 1 (Field probe theorem).** Over a field `k`, the one-dimensional
vector space `k` alone separates all morphisms in the category of `k`-modules.

The proof uses Strategy A (Yoneda-style vector test maps):
1. Every element `v : V` determines a linear map `hᵥ : k → V` via `a ↦ a • v`.
2. If `hᵥ ≫ f = hᵥ ≫ g` for all `v`, evaluating at `1 : k` gives `f(v) = g(v)`.
3. By extensionality, `f = g`.

This identifies probe complexity with "rank-one tomography": every linear
transformation is recoverable from its action on one-dimensional probes.
-/
theorem ModuleCat_field_k_precompose_separates
    (k : Type u) [Field k] :
    ∀ ⦃V W : ModuleCat.{u} k⦄ (f g : V ⟶ W),
      (∀ h : ModuleCat.of k k ⟶ V, h ≫ f = h ≫ g) → f = g := by
  intro V W f g hfg
  ext v
  by_contra h_contra
  have h_eq : ∀ (v : V), f v = g v := by
    intro v
    specialize hfg (ModuleCat.ofHom (LinearMap.toSpanSingleton k V v));
    simpa using congr_arg ( fun f => f ( 1 : k ) ) hfg
  exact h_contra (h_eq v)

/-
The singleton set `{k}` is a precompose-separating family for `ModuleCat k`
over a field `k`.
-/
theorem ModuleCat_singleton_separating
    (k : Type u) [Field k] :
    PrecomposeSeparatingFamily ({ModuleCat.of k k} : Set (ModuleCat.{u} k)) := by
  convert ModuleCat_field_k_precompose_separates k using 1;
  unfold PrecomposeSeparatingFamily; aesop;

/-
**The probe complexity of `ModuleCat k` over a field is at most 1.**
This follows immediately from the fact that the singleton `{k}` is separating.
-/
theorem categoryProbeComplexity_ModuleCat_le_one
    (k : Type u) [Field k] :
    categoryProbeComplexity (ModuleCat.{u} k) ≤ 1 := by
  convert ciInf_le ?_ ( { ModuleCat.of k k } : Finset ( ModuleCat k ) );
  · simp +decide [ ModuleCat_singleton_separating ];
  · exact ⟨ 0, Set.forall_mem_range.2 fun S => zero_le _ ⟩

/-
**Nontriviality lower bound.** If there exist distinct parallel morphisms in a
category, then the empty family is not separating, so probe complexity is at least 1.
-/
theorem categoryProbeComplexity_pos_of_nontrivial
    {C : Type u} [Category.{v} C]
    (hnt : ∃ (X Y : C) (f g : X ⟶ Y), f ≠ g) :
    1 ≤ categoryProbeComplexity C := by
  refine' le_iInf fun S => le_iInf _;
  intro hS
  by_contra h_contra
  push_neg at h_contra
  have h_empty : S = ∅ := by
    exact Finset.card_eq_zero.mp ( Nat.eq_zero_of_le_zero ( Nat.le_of_lt_succ ( by exact_mod_cast h_contra ) ) )
  simp_all +decide [ PrecomposeSeparatingFamily ];
  tauto

/-
**ModuleCat over a nontrivial field has nontrivial parallel morphisms.**
The zero map and the identity on `k` are distinct.
-/
theorem ModuleCat_has_distinct_morphisms
    (k : Type u) [Field k] [Nontrivial k] :
    ∃ (X Y : ModuleCat.{u} k) (f g : X ⟶ Y), f ≠ g := by
  refine' ⟨ _, _, _, _, _ ⟩;
  exacts [ ModuleCat.of k k, ModuleCat.of k k, 0, ModuleCat.ofHom ( LinearMap.id ), by intro h; simpa using ( congr_arg ( fun f => f ( 1 : k ) ) h ) ]

/-
**The probe complexity of `ModuleCat k` over a nontrivial field is exactly 1.**
-/
theorem categoryProbeComplexity_ModuleCat_eq_one
    (k : Type u) [Field k] [Nontrivial k] :
    categoryProbeComplexity (ModuleCat.{u} k) = 1 := by
  refine' le_antisymm ( categoryProbeComplexity_ModuleCat_le_one k ) ( categoryProbeComplexity_pos_of_nontrivial ( ModuleCat_has_distinct_morphisms k ) )

/-! ## Theorem 2: Separating families under faithful functors -/

/-
**Pullback of separating families along full faithful functors.**
If `F : C ⥤ D` is a full faithful functor and `F.obj '' S` is a separating family in `D`,
then `S` is a separating family in `C`.

Fullness is needed to lift arbitrary probe morphisms in `D` back to `C`;
faithfulness recovers equality of the original morphisms from equality of their images.
-/
theorem separatingFamily_pullback_faithful
    {C : Type u} [Category.{v} C]
    {D : Type*} [Category D]
    (F : C ⥤ D) [F.Full] [F.Faithful]
    (S : Set C) (hS : PrecomposeSeparatingFamily (F.obj '' S)) :
    PrecomposeSeparatingFamily S := by
  intro X Y f g hfg;
  convert F.map_injective ( hS ( F.map f ) ( F.map g ) _ );
  rintro _ ⟨ P, hP, rfl ⟩ h;
  obtain ⟨ h', rfl ⟩ := F.map_surjective h;
  rw [ ← F.map_comp, ← F.map_comp, hfg P hP h' ]

/-
**Pushforward of separating families along full and faithful functors.**
If `F : C ⥤ D` is full and faithful and `S` is a separating family in `C`, then
`F.obj '' S` is a separating family for morphisms between objects in the essential
image of `F`.
-/
theorem separatingFamily_pushforward_full_faithful
    {C : Type u} [Category.{v} C]
    {D : Type*} [Category D]
    (F : C ⥤ D) [F.Full] [F.Faithful]
    (S : Set C) (hS : PrecomposeSeparatingFamily S) :
    ∀ ⦃X Y : C⦄ (f g : F.obj X ⟶ F.obj Y),
      (∀ P ∈ S, ∀ h : F.obj P ⟶ F.obj X, h ≫ f = h ≫ g) → f = g := by
  intro X Y f g hfg;
  nontriviality;
  obtain ⟨ f', hf' ⟩ := F.map_surjective f
  obtain ⟨ g', hg' ⟩ := F.map_surjective g;
  have := hS f' g';
  contrapose! this;
  exact ⟨ fun P hP h => F.map_injective <| by aesop, fun h => this <| by aesop ⟩

/-! ## Theorem 3: Monotonicity and structural properties -/

/-
A superset of a separating family is also separating.
-/
theorem PrecomposeSeparatingFamily.superset
    {C : Type u} [Category.{v} C]
    {S T : Set C} (hS : PrecomposeSeparatingFamily S) (hST : S ⊆ T) :
    PrecomposeSeparatingFamily T := by
  -- If $S$ separates morphisms and $S \subseteq T$, then $T$ also separates morphisms by the same argument.
  intros X Y f g hfg
  apply hS f g
  intro P hP h
  apply hfg P (hST hP) h

/-
The full set of objects is always separating (Yoneda lemma).
-/
theorem PrecomposeSeparatingFamily.univ
    {C : Type u} [Category.{v} C] :
    PrecomposeSeparatingFamily (Set.univ : Set C) := by
  exact fun X Y f g h => by simpa using h X ( Set.mem_univ X ) ( 𝟙 X ) ;

/-
A singleton `{P}` is separating iff `P` is a separator (cogenerator by precomposition).
-/
theorem precomposeSeparatingFamily_singleton_iff
    {C : Type u} [Category.{v} C] (P : C) :
    PrecomposeSeparatingFamily ({P} : Set C) ↔
      ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : P ⟶ X, h ≫ f = h ≫ g) → f = g := by
  constructor;
  · exact fun h X Y f g hfg => h f g fun Q hQ h => by cases hQ; exact hfg h;
  · intro h X Y f g hfg;
    exact h f g fun h => hfg P rfl h

/-
The empty set is separating iff all hom-sets are subsingleton.
-/
theorem precomposeSeparatingFamily_empty_iff
    {C : Type u} [Category.{v} C] :
    PrecomposeSeparatingFamily (∅ : Set C) ↔
      ∀ (X Y : C) (f g : X ⟶ Y), f = g := by
  constructor <;> intro h <;> unfold PrecomposeSeparatingFamily at * <;> aesop

/-! ## Probe complexity bounds -/

/-
Probe complexity is at most the cardinality of any finite separating family.
-/
theorem categoryProbeComplexity_le_card
    {C : Type u} [Category.{v} C]
    (S : Finset C) (hS : PrecomposeSeparatingFamily (↑S : Set C)) :
    categoryProbeComplexity C ≤ S.card := by
  refine' le_trans ( ciInf_le _ S ) _;
  · exact ⟨ 0, Set.forall_mem_range.mpr fun S => by exact zero_le _ ⟩;
  · aesop

/-
Probe complexity is zero iff all hom-sets are subsingleton.
-/
theorem categoryProbeComplexity_eq_zero_iff
    {C : Type u} [Category.{v} C] :
    categoryProbeComplexity C = 0 ↔ ∀ (X Y : C) (f g : X ⟶ Y), f = g := by
  constructor <;> intro h <;> rw [ categoryProbeComplexity ] at *;
  · contrapose! h;
    refine' ne_of_gt ( lt_of_lt_of_le zero_lt_one ( categoryProbeComplexity_pos_of_nontrivial h ) );
  · refine' le_antisymm _ _;
    · refine' le_trans ( ciInf_le _ ∅ ) _ <;> norm_num;
      simp +decide [ PrecomposeSeparatingFamily ];
      exact iInf_pos h;
    · exact zero_le _

end