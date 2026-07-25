import Mathlib

/-!
# The topology of argumentation, VI: the existence gap for stable extensions

This file is **self-contained** (it re-declares the basic Dung semantics) and
pursues, in *contrarian* mode, the **existence gap** left open by
`ArgumentationStable.lean`:

> Unlike preferred extensions, **stable extensions need not exist.**

We formulate four bold conjectures about the existence of stable extensions and
settle each one, proving two and disproving two.

## Bold conjectures, settled

* **`no_stable_cycle3`** — *Disproves* "every finite framework has a stable
  extension": the odd 3-cycle `0 → 1 → 2 → 0` has **no** stable extension.
* **`cycle3_preferred_not_stable`** — *Disproves* "every preferred extension is
  stable": in the 3-cycle the empty set is a preferred (indeed the unique
  admissible) extension, yet it is not stable.  So the strict inclusion
  `stable ⊊ preferred` of `ArgumentationStable.lean` is genuinely strict.
* **`stable_exists_of_finite_symmetric_irrefl`** — *Proves* "every finite
  symmetric irreflexive framework has a stable extension" (the existence gap
  closes on the symmetric side): a maximal conflict-free set exists by finiteness
  and is stable.
* **`no_stable_of_reflexive`** / **`no_stable_reflAF`** — *Disproves* "symmetry
  alone suffices for existence": a symmetric framework with a self-attack (hence
  reflexive) and at least one argument has no stable extension.  Irreflexivity in
  the previous item is therefore necessary.

Quantitatively, `stable_cycle3_ncard` records that the number of stable
extensions of the 3-cycle is `0`, in contrast with the count `n` for the
complete conflict graph (`ArgumentationStable.stable_completeAF_ncard`).
-/

namespace ArgStableGap

open Finset

variable {A : Type*} (R : A → A → Prop)

/-! ## Basic Dung semantics (self-contained) -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: conflict-free and defends all its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

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

/-! ## The symmetric collapse (re-proved, self-contained) -/

/-- In a symmetric framework every conflict-free set is admissible. -/
theorem conflictFree_admissible_of_symmetric (hsym : Symmetric R) {S : Set A}
    (hS : ConflictFree R S) : Admissible R S :=
  ⟨hS, fun a ha _ hb => ⟨a, ha, hsym hb⟩⟩

/-- In a symmetric irreflexive framework every maximal conflict-free set is
stable. -/
theorem maximalConflictFree_stable_of_symmetric (hsym : Symmetric R)
    (hirr : ∀ a, ¬ R a a) {S : Set A} (hS : MaximalConflictFree R S) :
    Stable R S := by
  refine ⟨hS.1, ?_⟩
  contrapose! hS
  simp_all +decide [MaximalConflictFree]
  obtain ⟨a, ha₁, ha₂⟩ := hS
  refine fun h => ⟨Insert.insert a S, ?_, Set.subset_insert _ _, ?_⟩ <;>
    simp_all +decide [ConflictFree]
  exact fun b hb => by rintro H; exact ha₂ b hb (hsym H)

/-! ## Positive existence: finite symmetric irreflexive frameworks -/

/-- On a finite type a maximal conflict-free set exists (the conflict-free sets
form a nonempty finite family, so an inclusion-maximal one exists). -/
theorem exists_maximalConflictFree [Fintype A] :
    ∃ S : Set A, MaximalConflictFree R S := by
  set CF := {S : Set A | ConflictFree R S} with hCF_def
  obtain ⟨S, hS⟩ : ∃ S ∈ CF, ∀ T ∈ CF, S ⊆ T → T ⊆ S := by
    have h_finite : CF.Finite := Set.toFinite CF
    have := h_finite.toFinset.exists_maximal
    exact Exists.elim (this ⟨∅, h_finite.mem_toFinset.mpr (by tauto)⟩)
      fun S hS => ⟨S, h_finite.mem_toFinset.mp hS.1,
        fun T hT hST => hS.2 (h_finite.mem_toFinset.mpr hT) hST⟩
  exact ⟨S, hS.1, fun T hT hST => Set.Subset.antisymm (hS.2 T hT hST) hST⟩

/-- **C3 (proved): every finite symmetric irreflexive framework has a stable
extension.** -/
theorem stable_exists_of_finite_symmetric_irrefl [Fintype A]
    (hsym : Symmetric R) (hirr : ∀ a, ¬ R a a) :
    ∃ S : Set A, Stable R S := by
  obtain ⟨S, hS⟩ := exists_maximalConflictFree R
  exact ⟨S, maximalConflictFree_stable_of_symmetric R hsym hirr hS⟩

/-! ## Negative: reflexivity destroys existence -/

/-- **C4 (disproves symmetry-suffices): any nonempty reflexive framework has no
stable extension.**  A self-attack forbids every argument from a conflict-free
set, so the only candidate is `∅`, which cannot attack the (nonempty) universe. -/
theorem no_stable_of_reflexive [Nonempty A] (hrefl : ∀ a, R a a) :
    ¬ ∃ S : Set A, Stable R S := by
  simp +decide [Stable, ConflictFree]
  exact fun S hS => ⟨Classical.arbitrary A, fun h => hS _ h _ h (hrefl _),
    fun a ha _ => hS _ ha _ ha (hrefl _)⟩

end ArgStableGap

/-! ## The odd 3-cycle: no stable extension -/

namespace ArgStableGap

open Finset

/-- The **3-cycle** framework `0 → 1 → 2 → 0` on `Fin 3`. -/
def cycle3 : Fin 3 → Fin 3 → Prop := fun a b => b = a + 1

instance : DecidableRel cycle3 := fun a b => by unfold cycle3; infer_instance

/-- The 3-cycle is irreflexive. -/
theorem cycle3_irreflexive : ∀ a : Fin 3, ¬ cycle3 a a := by decide

/-- The 3-cycle is **not** symmetric (it is a directed odd cycle). -/
theorem cycle3_not_symmetric : ¬ Symmetric cycle3 := by
  intro h
  exact absurd (h (show cycle3 0 1 by decide)) (by decide)

/-- **C1 (disproved): the 3-cycle has no stable extension.**  This refutes the
conjecture that every finite framework admits a stable extension. -/
theorem no_stable_cycle3 : ¬ ∃ S : Set (Fin 3), Stable cycle3 S := by
  rintro ⟨S, hS₁, hS₂⟩
  fin_cases S <;> simp_all +decide [ConflictFree] <;> simp_all +decide [coeEmb]

/-- The number of stable extensions of the 3-cycle is `0`. -/
theorem stable_cycle3_ncard :
    Set.ncard {S : Set (Fin 3) | Stable cycle3 S} = 0 := by
  by_contra h
  obtain ⟨S, hS⟩ := Set.nonempty_of_ncard_ne_zero h
  exact no_stable_cycle3 ⟨S, hS⟩

/-! ## The 3-cycle: a preferred extension that is not stable -/

/-- In the 3-cycle the empty set is admissible (vacuously). -/
theorem cycle3_admissible_empty : Admissible cycle3 (∅ : Set (Fin 3)) :=
  ⟨by tauto, by tauto⟩

/-- In the 3-cycle the empty set is a preferred extension: it is the unique
admissible set, since no nonempty admissible set can defend its members. -/
theorem cycle3_preferred_empty : Preferred cycle3 (∅ : Set (Fin 3)) := by
  refine ⟨cycle3_admissible_empty, ?_⟩
  rintro T ⟨hcf, hdef⟩ -
  fin_cases T <;> simp_all +decide [ConflictFree, Defends]
  all_goals simp_all +decide [coeEmb]

/-- The empty set is not stable in the 3-cycle (it attacks nothing). -/
theorem cycle3_empty_not_stable : ¬ Stable cycle3 (∅ : Set (Fin 3)) := by
  unfold Stable; simp +decide

/-- **C2 (disproved): a preferred extension that is not stable.**  In the
3-cycle the empty set is preferred but not stable, so `stable ⊊ preferred`
strictly. -/
theorem cycle3_preferred_not_stable :
    ∃ S : Set (Fin 3), Preferred cycle3 S ∧ ¬ Stable cycle3 S :=
  ⟨∅, cycle3_preferred_empty, cycle3_empty_not_stable⟩

/-! ## A concrete symmetric framework with no stable extension -/

/-- The single-argument framework with a self-attack: symmetric but reflexive. -/
def reflAF : Fin 1 → Fin 1 → Prop := fun _ _ => True

theorem reflAF_symmetric : Symmetric reflAF := fun _ _ _ => trivial

theorem reflAF_reflexive : ∀ a : Fin 1, reflAF a a := fun _ => trivial

/-- **C4 witness: a symmetric framework with no stable extension.**  Symmetry
alone does not guarantee existence — irreflexivity is needed. -/
theorem no_stable_reflAF : ¬ ∃ S : Set (Fin 1), Stable reflAF S :=
  no_stable_of_reflexive reflAF reflAF_reflexive

end ArgStableGap