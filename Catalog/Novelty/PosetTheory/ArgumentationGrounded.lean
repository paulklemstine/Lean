import Mathlib

/-!
# The topology of argumentation, VII: the grounded extension is the least complete extension

This file is **self-contained** (it re-declares the basic Dung semantics) and
closes the central gap left open by `ArgumentationCore.lean` /
`ArgumentationExtensions.lean`: those files *define* the grounded extension as
the least fixed point `OrderHom.lfp` of the characteristic (defense) operator
`charF`, and show it is contained in every complete extension, but they never
establish that the grounded extension is **itself** a legitimate extension — in
particular that it is *conflict-free* and hence *complete*.

Conflict-freeness of a general fixed point of `charF` is **false** (the whole
argument set is a fixed point when nobody attacks, and more relevantly a large
fixed point can contain conflicts); the grounded extension is conflict-free
precisely because it is the *least* fixed point.  We prove this by transfinite
induction along the ordinal approximation `lfpApprox` of the least fixed point,
using that

* `charF` **preserves** conflict-freeness (`conflictFree_charF`), and
* a **union of a chain** of conflict-free sets is conflict-free
  (`conflictFree_iUnion_of_chain` specialised to the monotone approximation).

## The chain of results

* `conflictFree_charF`            — the defense operator preserves conflict-freeness;
* `conflictFree_of_directed`      — a directed union of conflict-free sets is conflict-free;
* `lfpApprox_conflictFree`        — every ordinal approximant of the least fixed
  point is conflict-free (transfinite induction);
* `groundedExt_conflictFree`      — **the grounded extension is conflict-free**;
* `groundedExt_fixed`             — the grounded extension is a fixed point of `charF`;
* `groundedExt_admissible`        — **the grounded extension is admissible**;
* `groundedExt_complete`          — **the grounded extension is complete**;
* `groundedExt_subset_complete`   — it is contained in every complete extension;
* `groundedExt_least_complete`    — **the grounded extension is the least complete
  extension** (Dung): it is complete and below every complete extension.
* `complete_iff_conflictFree_fixed` — a set is complete iff it is a conflict-free
  fixed point of `charF`.
-/

namespace ArgGrounded

open OrdinalApprox

variable {A : Type*} (R : A → A → Prop)

/-! ## Basic Dung semantics (self-contained) -/

/-- `S` is *conflict-free*: no argument in `S` attacks another in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker of `a` is counter-attacked from `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: conflict-free and defends all its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The *characteristic (defense) operator*: `charF S` is the set of arguments
defended by `S`. -/
def charF (S : Set A) : Set A := {a | Defends R S a}

/-- `S` is a **complete extension**: admissible and closed under defense. -/
def Complete (S : Set A) : Prop := Admissible R S ∧ charF R S ⊆ S

@[simp] theorem mem_charF {S : Set A} {a : A} : a ∈ charF R S ↔ Defends R S a := Iff.rfl

/-! ## Monotonicity of the defense operator -/

theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

/-- The defense operator as a monotone self-map of the complete lattice `Set A`. -/
def charFHom : Set A →o Set A := ⟨charF R, fun _ _ h => charF_mono R h⟩

/-- The **grounded extension**: the least fixed point of the defense operator. -/
noncomputable def groundedExt : Set A := OrderHom.lfp (charFHom R)

/-! ## The defense operator preserves conflict-freeness -/

/-- **The defense operator preserves conflict-freeness.**  If `S` is conflict-free
then so is `charF S`. -/
theorem conflictFree_charF {S : Set A} (hS : ConflictFree R S) :
    ConflictFree R (charF R S) := by
  intro a ha b hb hab
  obtain ⟨c, hc, hca⟩ := hb a hab
  obtain ⟨d, hd, hdc⟩ := ha c hca
  exact hS d hd c hc hdc

/-! ## Conflict-freeness is preserved by chain unions -/

/-- **A directed union of conflict-free sets is conflict-free.**  If `𝒮` is a
family of conflict-free sets that is *directed* under inclusion (any two members
are contained in a common third), then `⋃₀ 𝒮` is conflict-free. -/
theorem conflictFree_of_directed {𝒮 : Set (Set A)}
    (hdir : ∀ S ∈ 𝒮, ∀ T ∈ 𝒮, ∃ U ∈ 𝒮, S ⊆ U ∧ T ⊆ U)
    (hcf : ∀ S ∈ 𝒮, ConflictFree R S) :
    ConflictFree R (⋃₀ 𝒮) := by
  rintro a ⟨S, hS, ha⟩ b ⟨T, hT, hb⟩ hab
  obtain ⟨U, hU, hSU, hTU⟩ := hdir S hS T hT
  exact hcf U hU a (hSU ha) b (hTU hb) hab

/-! ## Transfinite approximation of the grounded extension -/

/-
**Every ordinal approximant of the least fixed point is conflict-free.**
Proved by transfinite induction: the approximant at stage `a` is the union of the
sets `charF (lfpApprox … b)` for `b < a` together with `∅`; by the induction
hypothesis each `lfpApprox … b` is conflict-free, so each `charF (lfpApprox … b)`
is conflict-free by `conflictFree_charF`, and the family is a chain (the
approximation is monotone), whence the union is conflict-free by
`conflictFree_of_directed`.
-/
theorem lfpApprox_conflictFree (a : Ordinal) :
    ConflictFree R (lfpApprox (charFHom R) ⊥ a) := by
  induction' a using Ordinal.induction with a ih;
  rw [ lfpApprox ];
  convert conflictFree_of_directed R _ _ using 1;
  · simp +zetaDelta at *;
    refine' ⟨ fun k hk => Or.inr ⟨ k, hk, le_rfl ⟩, fun k hk => ⟨ Or.inr ⟨ k, hk, le_rfl ⟩, fun l hl => _ ⟩ ⟩;
    cases le_total k l <;> [ exact Or.inr ⟨ l, hl, charF_mono R ( lfpApprox_monotone _ _ ‹_› ), le_rfl ⟩ ; exact Or.inr ⟨ k, hk, le_rfl, charF_mono R ( lfpApprox_monotone _ _ ‹_› ) ⟩ ];
  · rintro _ ( ⟨ b, hb, rfl ⟩ | rfl ) <;> [ exact conflictFree_charF R ( ih b hb ) ; exact fun x hx y hy => by contradiction ]

/-
**The grounded extension is conflict-free.**  It is the value of the ordinal
approximation `lfpApprox` at a sufficiently large stage, so conflict-freeness
follows from `lfpApprox_conflictFree`.
-/
theorem groundedExt_conflictFree : ConflictFree R (groundedExt R) := by
  convert lfpApprox_conflictFree R _;
  convert ( lfpApprox_ord_eq_lfp ( charFHom R ) ).symm

/-! ## The grounded extension is complete -/

/-- The grounded extension is a fixed point of the defense operator. -/
theorem groundedExt_fixed : charF R (groundedExt R) = groundedExt R :=
  OrderHom.map_lfp (charFHom R)

/-
**The grounded extension is admissible.**
-/
theorem groundedExt_admissible : Admissible R (groundedExt R) := by
  refine' ⟨ _, fun a ha => _ ⟩;
  · grind +suggestions;
  · convert Set.mem_setOf.mp ( groundedExt_fixed R ▸ ha ) using 1

/-
**The grounded extension is complete.**
-/
theorem groundedExt_complete : Complete R (groundedExt R) := by
  exact ⟨ groundedExt_admissible R, by simp [ groundedExt_fixed ] ⟩

/-- The grounded extension is contained in any set closed under defense. -/
theorem groundedExt_subset_of_charF_subset {S : Set A} (h : charF R S ⊆ S) :
    groundedExt R ⊆ S :=
  OrderHom.lfp_le (charFHom R) h

/-- The grounded extension is contained in every complete extension. -/
theorem groundedExt_subset_complete {S : Set A} (hS : Complete R S) :
    groundedExt R ⊆ S :=
  groundedExt_subset_of_charF_subset R hS.2

/-- **The grounded extension is the least complete extension (Dung).**  It is a
complete extension, and it is contained in every complete extension. -/
theorem groundedExt_least_complete :
    Complete R (groundedExt R) ∧ ∀ S, Complete R S → groundedExt R ⊆ S :=
  ⟨groundedExt_complete R, fun _ hS => groundedExt_subset_complete R hS⟩

/-! ## Complete = conflict-free fixed point -/

/-
**A set is complete iff it is a conflict-free fixed point of the defense
operator.**
-/
theorem complete_iff_conflictFree_fixed {S : Set A} :
    Complete R S ↔ ConflictFree R S ∧ charF R S = S := by
  constructor;
  · intro hS;
    exact ⟨ hS.1.1, hS.2.antisymm <| by rintro a ha; exact hS.1.2 a ha ⟩;
  · intro h;
    constructor;
    · exact ⟨ h.1, fun a ha => h.2.symm.subset ha ⟩;
    · exact h.2.le

end ArgGrounded