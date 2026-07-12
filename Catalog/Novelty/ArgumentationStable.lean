import Mathlib

/-!
# The topology of argumentation, V: stable extensions and the stable/preferred/Euler chain

This file is **self-contained** (it re-declares the basic Dung semantics) and
deepens the theory begun in `ArgumentationCore`, `ArgumentationExtensions`,
`ArgumentationSimplicial` and `ArgumentationSymmetric` by developing the
strongest of the classical *extension-based* semantics — the **stable
extension** — and situating it inside the full hierarchy

  `stable ⟹ preferred ⟹ complete ⟹ admissible ⟹ conflict-free`.

A set `S` is a **stable extension** when it is conflict-free and *attacks every
argument it does not contain* (`∀ a ∉ S, ∃ b ∈ S, R b a`).  Stable extensions are
the "no abstention" positions: every argument is either accepted or explicitly
defeated.

## The chain of results

* `stable_defends`     — a stable set defends each of its members;
* `stable_admissible`  — every stable extension is admissible;
* `stable_complete`    — every stable extension is complete (closed under defense);
* `stable_preferred`   — **every stable extension is preferred** (maximal admissible);
* `stable_maximalConflictFree` — every stable extension is a *facet* of `K(AF)`;
* `groundedExt_subset_stable` — the grounded extension is contained in every
  stable extension (skeptical ⊆ every stable position).

## The symmetric bridge and the Euler correspondence

For **symmetric irreflexive** frameworks (the model of two-sided disagreement)
we prove the exact collapse

* `maximalConflictFree_stable_of_symmetric` and hence
* `stable_iff_preferred_of_symmetric_irrefl` — **stable = preferred = facet** of
  the conflict-free complex `K(AF)`.

Specialising to the **complete conflict graph** `completeAF n` (which is
symmetric and irreflexive) we obtain, entirely self-contained:

* `stable_completeAF_iff` — the stable extensions are exactly the singletons;
* `stable_completeAF_ncard` — there are exactly `n` of them;
* `euler_eq_stable_completeAF` — **the Euler characteristic of `K(AF)` equals the
  number of stable extensions** (for `n ≥ 1`), extending the Euler/semantics
  bridge of `ArgumentationSymmetric` from preferred to stable extensions.
-/

namespace ArgTop

open Finset

variable {A : Type*} (R : A → A → Prop)

/-! ## Basic Dung semantics (self-contained) -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: conflict-free and defends all its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The *characteristic (defense) operator*. -/
def charF (S : Set A) : Set A := {a | Defends R S a}

/-- `S` is a **complete extension**: admissible and closed under defense. -/
def Complete (S : Set A) : Prop := Admissible R S ∧ charF R S ⊆ S

/-- `S` is a **preferred extension**: a maximal admissible set. -/
def Preferred (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

/-- `S` is **maximal conflict-free**: a facet of the conflict-free complex. -/
def MaximalConflictFree (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ T, ConflictFree R T → S ⊆ T → T = S

/-- `S` is a **stable extension**: conflict-free and it attacks every argument it
does not contain. -/
def Stable (S : Set A) : Prop :=
  ConflictFree R S ∧ ∀ a, a ∉ S → ∃ b ∈ S, R b a

theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

/-! ## The stable hierarchy -/

/-- A stable set defends each of its members: an attacker `b` of `a ∈ S` cannot
lie in `S` (that would be a conflict), so it lies outside `S` and is therefore
attacked back by some member of `S`. -/
theorem stable_defends {S : Set A} (hS : Stable R S) {a : A} (ha : a ∈ S) :
    Defends R S a := by
  obtain ⟨hcf, hdom⟩ := hS
  intro b hba
  by_cases hb : b ∈ S
  · exact absurd hba (hcf b hb a ha)
  · exact hdom b hb

/-- **Every stable extension is admissible.** -/
theorem stable_admissible {S : Set A} (hS : Stable R S) : Admissible R S :=
  ⟨hS.1, fun _ ha => stable_defends R hS ha⟩

/-- **Every stable extension is complete**: it already contains every argument it
defends. -/
theorem stable_complete {S : Set A} (hS : Stable R S) : Complete R S := by
  refine ⟨stable_admissible R hS, ?_⟩
  obtain ⟨hcf, hdom⟩ := hS
  intro a ha
  by_contra haS
  obtain ⟨b, hb, hba⟩ := hdom a haS
  obtain ⟨c, hc, hcb⟩ := ha b hba
  exact hcf c hc b hb hcb

/-- **Every stable extension is preferred** (a maximal admissible set): any
admissible `T ⊇ S` must equal `S`, because every argument outside `S` is attacked
from `S ⊆ T` and so cannot belong to the conflict-free set `T`. -/
theorem stable_preferred {S : Set A} (hS : Stable R S) : Preferred R S := by
  refine ⟨stable_admissible R hS, ?_⟩
  obtain ⟨hcf, hdom⟩ := hS
  intro T hT hST
  apply Set.Subset.antisymm _ hST
  intro a ha
  by_contra haS
  obtain ⟨b, hb, hba⟩ := hdom a haS
  exact hT.1 b (hST hb) a ha hba

/-- **Every stable extension is a facet** (maximal conflict-free set) of the
complex `K(AF)`. -/
theorem stable_maximalConflictFree {S : Set A} (hS : Stable R S) :
    MaximalConflictFree R S := by
  refine ⟨hS.1, ?_⟩
  obtain ⟨hcf, hdom⟩ := hS
  intro T hT hST
  apply Set.Subset.antisymm _ hST
  intro a ha
  by_contra haS
  obtain ⟨b, hb, hba⟩ := hdom a haS
  exact hT b (hST hb) a ha hba

/-! ## The grounded extension is below every stable extension -/

/-- The defense operator as a monotone self-map of `Set A`. -/
def charFHom : Set A →o Set A := ⟨charF R, fun _ _ h => charF_mono R h⟩

/-- The **grounded extension**: least fixed point of the defense operator. -/
noncomputable def groundedExt : Set A := OrderHom.lfp (charFHom R)

/-- The grounded extension is contained in every set closed under defense. -/
theorem groundedExt_subset_of_charF_subset {S : Set A} (h : charF R S ⊆ S) :
    groundedExt R ⊆ S :=
  OrderHom.lfp_le (charFHom R) h

/-- **The grounded (skeptical) extension is contained in every stable
extension.** -/
theorem groundedExt_subset_stable {S : Set A} (hS : Stable R S) :
    groundedExt R ⊆ S :=
  groundedExt_subset_of_charF_subset R (stable_complete R hS).2

/-! ## Symmetric frameworks: stable = preferred = facet -/

/-- In a symmetric framework a conflict-free set defends each of its members with
that member itself. -/
theorem defends_self_of_symmetric (hsym : Symmetric R) {S : Set A}
    {a : A} (ha : a ∈ S) : Defends R S a :=
  fun _ hb => ⟨a, ha, hsym hb⟩

/-- In a symmetric framework every conflict-free set is admissible. -/
theorem conflictFree_admissible_of_symmetric (hsym : Symmetric R) {S : Set A}
    (hS : ConflictFree R S) : Admissible R S :=
  ⟨hS, fun _ ha => defends_self_of_symmetric R hsym ha⟩

/-- The preferred extensions of a symmetric framework are the maximal
conflict-free sets. -/
theorem preferred_iff_maximalConflictFree_of_symmetric (hsym : Symmetric R)
    {S : Set A} : Preferred R S ↔ MaximalConflictFree R S := by
  constructor
  · rintro ⟨hadm, hmax⟩
    exact ⟨hadm.1, fun T hT hST =>
      hmax T (conflictFree_admissible_of_symmetric R hsym hT) hST⟩
  · rintro ⟨hcf, hmax⟩
    exact ⟨conflictFree_admissible_of_symmetric R hsym hcf,
      fun T hT hST => hmax T hT.1 hST⟩

/-- **In a symmetric irreflexive framework every maximal conflict-free set is
stable.**  Since `S` is maximal, no argument `a ∉ S` can be added without a
conflict; irreflexivity rules out a self-attack and symmetry turns the conflict
into an attack `b ∈ S` on `a`. -/
theorem maximalConflictFree_stable_of_symmetric (hsym : Symmetric R)
    (hirr : ∀ a, ¬ R a a) {S : Set A} (hS : MaximalConflictFree R S) :
    Stable R S := by
  obtain ⟨hcf, hmax⟩ := hS
  refine ⟨hcf, ?_⟩
  intro a haS
  by_contra hcon
  push_neg at hcon
  -- `S ∪ {a}` is conflict-free, contradicting maximality of `S`.
  have hcf' : ConflictFree R (insert a S) := by
    intro x hx y hy hxy
    simp only [Set.mem_insert_iff] at hx hy
    rcases hx with rfl | hx <;> rcases hy with rfl | hy
    · exact hirr _ hxy
    · exact hcon _ hy (hsym hxy)
    · exact hcon _ hx hxy
    · exact hcf _ hx _ hy hxy
  have := hmax (insert a S) hcf' (Set.subset_insert a S)
  exact haS (this ▸ Set.mem_insert a S)

/-- **The stable/preferred collapse for symmetric irreflexive frameworks.**  A
set is stable iff it is preferred iff it is a facet (maximal conflict-free set)
of the conflict-free complex `K(AF)`. -/
theorem stable_iff_preferred_of_symmetric_irrefl (hsym : Symmetric R)
    (hirr : ∀ a, ¬ R a a) {S : Set A} : Stable R S ↔ Preferred R S := by
  rw [preferred_iff_maximalConflictFree_of_symmetric R hsym]
  exact ⟨stable_maximalConflictFree R,
    maximalConflictFree_stable_of_symmetric R hsym hirr⟩

end ArgTop

/-! ## The complete conflict graph: stable count and the Euler bridge -/

namespace ArgTop

open Finset

/-- The **complete conflict graph** on `n` arguments: every two distinct
arguments attack each other. -/
def completeAF (n : ℕ) : Fin n → Fin n → Prop := fun a b => a ≠ b

theorem completeAF_symmetric (n : ℕ) : Symmetric (completeAF n) :=
  fun _ _ h => Ne.symm h

theorem completeAF_irreflexive (n : ℕ) : ∀ a : Fin n, ¬ completeAF n a a :=
  fun _ h => h rfl

/-- In the complete conflict graph a set is conflict-free iff it is a
subsingleton. -/
theorem conflictFree_completeAF_iff (n : ℕ) (S : Set (Fin n)) :
    ConflictFree (completeAF n) S ↔ S.Subsingleton := by
  constructor
  · intro h a ha b hb
    exact not_ne_iff.mp (h a ha b hb)
  · intro h a ha b hb hab
    exact hab (h ha hb)

/-- The stable extensions of the complete conflict graph on `n ≥ 1` arguments are
exactly the singletons. -/
theorem stable_completeAF_iff (n : ℕ) (hn : 0 < n) (S : Set (Fin n)) :
    Stable (completeAF n) S ↔ ∃ a, S = {a} := by
  rw [stable_iff_preferred_of_symmetric_irrefl (completeAF n)
    (completeAF_symmetric n) (completeAF_irreflexive n)]
  -- reproduce the preferred = singleton characterisation
  rw [preferred_iff_maximalConflictFree_of_symmetric (completeAF n)
    (completeAF_symmetric n)]
  constructor
  · rintro ⟨hcf, hmax⟩
    rw [conflictFree_completeAF_iff] at hcf
    rcases S.eq_empty_or_nonempty with hS | ⟨a, ha⟩
    · exfalso
      subst hS
      have : ({(⟨0, hn⟩ : Fin n)} : Set (Fin n)) = ∅ :=
        hmax {⟨0, hn⟩} ((conflictFree_completeAF_iff n _).mpr Set.subsingleton_singleton)
          (Set.empty_subset _)
      exact absurd (this ▸ Set.mem_singleton (⟨0, hn⟩ : Fin n)) (Set.notMem_empty _)
    · refine ⟨a, ?_⟩
      apply Set.eq_singleton_iff_unique_mem.mpr
      exact ⟨ha, fun b hb => hcf hb ha⟩
  · rintro ⟨a, rfl⟩
    refine ⟨(conflictFree_completeAF_iff n {a}).mpr Set.subsingleton_singleton, ?_⟩
    intro T hT hsub
    rw [conflictFree_completeAF_iff] at hT
    apply Set.eq_singleton_iff_unique_mem.mpr
    exact ⟨hsub rfl, fun b hb => hT hb (hsub rfl)⟩

/-- There are exactly `n` stable extensions of the complete conflict graph on
`n ≥ 1` arguments. -/
theorem stable_completeAF_ncard (n : ℕ) (hn : 0 < n) :
    Set.ncard {S : Set (Fin n) | Stable (completeAF n) S} = n := by
  have hset : {S : Set (Fin n) | Stable (completeAF n) S}
      = Set.range (fun a : Fin n => ({a} : Set (Fin n))) := by
    ext S
    simp only [Set.mem_setOf_eq, Set.mem_range]
    rw [stable_completeAF_iff n hn]
    constructor
    · rintro ⟨a, rfl⟩; exact ⟨a, rfl⟩
    · rintro ⟨a, rfl⟩; exact ⟨a, rfl⟩
  rw [hset]
  have hinj : Function.Injective (fun a : Fin n => ({a} : Set (Fin n))) := by
    intro a b hab; simpa using hab
  rw [← Set.image_univ, Set.ncard_image_of_injective _ hinj, Set.ncard_univ,
    Nat.card_eq_fintype_card, Fintype.card_fin]

/-! ### Euler characteristic -/

/-- (Unreduced) **Euler characteristic** of a finite family of faces. -/
def eulerChar [DecidableEq A] (F : Finset (Finset A)) : ℤ :=
  ∑ s ∈ F, if s = ∅ then 0 else (-1) ^ (s.card - 1)

open Classical in
/-- The finite face set of `K(AF)` for a finite framework. -/
noncomputable def facesFinset [Fintype A] (R : A → A → Prop) : Finset (Finset A) :=
  Finset.univ.filter (fun s => ConflictFree R (↑s : Set A))

/-- The faces of the complete conflict graph are the finsets of cardinality
at most one. -/
theorem facesFinset_completeAF (n : ℕ) :
    facesFinset (completeAF n) =
      Finset.univ.filter (fun s : Finset (Fin n) => s.card ≤ 1) := by
  classical
  apply Finset.filter_congr
  intro s _
  rw [conflictFree_completeAF_iff, Finset.card_le_one]
  constructor
  · intro h a ha b hb
    exact h (Finset.mem_coe.mpr ha) (Finset.mem_coe.mpr hb)
  · intro h a ha b hb
    exact h a (Finset.mem_coe.mp ha) b (Finset.mem_coe.mp hb)

/-- The Euler characteristic of the complete conflict graph on `n` arguments is
`n` — the complex is `n` isolated points. -/
theorem euler_completeAF (n : ℕ) : eulerChar (facesFinset (completeAF n)) = n := by
  rw [facesFinset_completeAF]
  unfold eulerChar; simp +decide [Finset.sum_filter]
  rw [Finset.sum_congr rfl fun x hx => ?_]
  rotate_left
  exact fun x => if x.card = 1 then 1 else 0
  · cases x using Finset.induction <;> aesop
  · simp +decide [Finset.card_univ]

/-- **The stable Euler bridge for symmetric frameworks.**  For the complete
conflict graph on `n ≥ 1` arguments, the Euler characteristic of the
conflict-free complex equals the number of stable extensions. -/
theorem euler_eq_stable_completeAF (n : ℕ) (hn : 0 < n) :
    (eulerChar (facesFinset (completeAF n)) : ℤ)
      = (Set.ncard {S : Set (Fin n) | Stable (completeAF n) S} : ℤ) := by
  rw [euler_completeAF, stable_completeAF_ncard n hn]

/-- Concrete instantiation of the stable Euler bridge at `n = 4`. -/
example :
    (eulerChar (facesFinset (completeAF 4)) : ℤ)
      = (Set.ncard {S : Set (Fin 4) | Stable (completeAF 4) S} : ℤ) :=
  euler_eq_stable_completeAF 4 (by norm_num)

end ArgTop