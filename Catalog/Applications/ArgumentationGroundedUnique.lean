import Mathlib

/-!
# The topology of argumentation, VIII: well-founded frameworks have a unique complete extension

This file is **self-contained** (it re-declares the basic Dung semantics) and
continues `ArgumentationGrounded.lean`, which proved that the grounded extension
`OrderHom.lfp charF` is the *least* complete extension.  Here we settle the
opposite extreme, following Dung (1995, Theorem 30):

*If the attack relation is well-founded, then the argumentation framework has
exactly one complete extension, namely the grounded extension, and it is
simultaneously stable, preferred, admissible and complete.*

The bridge is the notion of a **stable** extension (conflict-free and attacking
everything outside it).  We prove, with no hypothesis on the framework,

* `stable_complete` — every stable extension is complete;

and then, under well-foundedness of the attack relation,

* `groundedExt_stable_of_wf`   — **the grounded extension is stable**
  (transfinite/`WellFounded` induction on the attack relation);
* `complete_subset_grounded_of_wf` — every complete extension is *contained in*
  the grounded extension;
* `complete_eq_grounded_of_wf`  — hence every complete extension *equals* it;
* `grounded_unique_complete_of_wf` — **there is a unique complete extension**;
* `stable_eq_grounded_of_wf`, `stable_unique_of_wf` — the stable extension is
  unique and equal to the grounded one;
* `grounded_preferred_of_wf`    — the grounded extension is preferred
  (maximal admissible), and is in fact the largest complete extension.

Independently of well-foundedness we also record the classical characterisation

* `groundedExt_eq_sInter_complete` — **the grounded extension is the intersection
  of all complete extensions.**

## Why well-foundedness matters

`stable_complete` shows stability is *stronger* than completeness in general, and
a framework can have several complete extensions (e.g. two arguments attacking
each other give the empty grounded extension and two further complete/stable
extensions).  Well-foundedness of the attack relation rules out such cycles: the
grounded extension then attacks everything it excludes, forcing every complete
extension to coincide with it.
-/

namespace ArgGroundedUnique

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

/-- `S` is a **stable extension**: conflict-free and attacks every argument
outside it. -/
def Stable (S : Set A) : Prop := ConflictFree R S ∧ ∀ a, a ∉ S → ∃ b ∈ S, R b a

/-- `S` is a **preferred extension**: a maximal admissible set. -/
def Preferred (S : Set A) : Prop :=
  Admissible R S ∧ ∀ T, Admissible R T → S ⊆ T → T = S

@[simp] theorem mem_charF {S : Set A} {a : A} : a ∈ charF R S ↔ Defends R S a := Iff.rfl

/-! ## Monotonicity and the grounded extension -/

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

/-! ## Conflict-freeness of the grounded extension (recalled from cycle VII) -/

/-- The defense operator preserves conflict-freeness. -/
theorem conflictFree_charF {S : Set A} (hS : ConflictFree R S) :
    ConflictFree R (charF R S) := by
  intro a ha b hb hab
  obtain ⟨c, hc, hca⟩ := hb a hab
  obtain ⟨d, hd, hdc⟩ := ha c hca
  exact hS d hd c hc hdc

/-- A directed union of conflict-free sets is conflict-free. -/
theorem conflictFree_of_directed {𝒮 : Set (Set A)}
    (hdir : ∀ S ∈ 𝒮, ∀ T ∈ 𝒮, ∃ U ∈ 𝒮, S ⊆ U ∧ T ⊆ U)
    (hcf : ∀ S ∈ 𝒮, ConflictFree R S) :
    ConflictFree R (⋃₀ 𝒮) := by
  rintro a ⟨S, hS, ha⟩ b ⟨T, hT, hb⟩ hab
  obtain ⟨U, hU, hSU, hTU⟩ := hdir S hS T hT
  exact hcf U hU a (hSU ha) b (hTU hb) hab

/-- Every ordinal approximant of the least fixed point is conflict-free. -/
theorem lfpApprox_conflictFree (a : Ordinal) :
    ConflictFree R (lfpApprox (charFHom R) ⊥ a) := by
  induction' a using Ordinal.induction with a ih;
  rw [ lfpApprox ];
  convert conflictFree_of_directed R _ _ using 1;
  · simp +zetaDelta at *;
    refine' ⟨ fun k hk => Or.inr ⟨ k, hk, le_rfl ⟩, fun k hk => ⟨ Or.inr ⟨ k, hk, le_rfl ⟩, fun l hl => _ ⟩ ⟩;
    cases le_total k l <;> [ exact Or.inr ⟨ l, hl, charF_mono R ( lfpApprox_monotone _ _ ‹_› ), le_rfl ⟩ ; exact Or.inr ⟨ k, hk, le_rfl, charF_mono R ( lfpApprox_monotone _ _ ‹_› ) ⟩ ];
  · rintro _ ( ⟨ b, hb, rfl ⟩ | rfl ) <;> [ exact conflictFree_charF R ( ih b hb ) ; exact fun x hx y hy => by contradiction ]

/-- **The grounded extension is conflict-free.** -/
theorem groundedExt_conflictFree : ConflictFree R (groundedExt R) := by
  convert lfpApprox_conflictFree R _;
  convert ( lfpApprox_ord_eq_lfp ( charFHom R ) ).symm

/-- The grounded extension is a fixed point of the defense operator. -/
theorem groundedExt_fixed : charF R (groundedExt R) = groundedExt R :=
  OrderHom.map_lfp (charFHom R)

/-- The grounded extension is admissible. -/
theorem groundedExt_admissible : Admissible R (groundedExt R) := by
  refine ⟨groundedExt_conflictFree R, fun a ha => ?_⟩
  have : a ∈ charF R (groundedExt R) := (groundedExt_fixed R).symm ▸ ha
  exact this

/-- The grounded extension is complete. -/
theorem groundedExt_complete : Complete R (groundedExt R) :=
  ⟨groundedExt_admissible R, by simp [groundedExt_fixed]⟩

/-- The grounded extension is contained in any set closed under defense. -/
theorem groundedExt_subset_of_charF_subset {S : Set A} (h : charF R S ⊆ S) :
    groundedExt R ⊆ S :=
  OrderHom.lfp_le (charFHom R) h

/-- The grounded extension is contained in every complete extension. -/
theorem groundedExt_subset_complete {S : Set A} (hS : Complete R S) :
    groundedExt R ⊆ S :=
  groundedExt_subset_of_charF_subset R hS.2

/-! ## Stable extensions are complete (no hypothesis on the framework) -/

/-- **Every stable extension is complete.**  Stability is strictly stronger than
completeness: a stable set defends its members (its attackers lie outside and are
therefore attacked back) and contains everything it defends (anything outside is
attacked, and defending against that attacker would create an internal
conflict). -/
theorem stable_complete {S : Set A} (hS : Stable R S) : Complete R S := by
  obtain ⟨hcf, hst⟩ := hS
  refine ⟨⟨hcf, ?_⟩, ?_⟩
  · intro a haS b hba
    by_cases hbS : b ∈ S
    · exact absurd hba (hcf b hbS a haS)
    · exact hst b hbS
  · intro a ha
    by_contra haS
    obtain ⟨b, hb, hba⟩ := hst a haS
    obtain ⟨c, hc, hcb⟩ := ha b hba
    exact hcf c hc b hb hcb

/-- Every stable extension is admissible. -/
theorem stable_admissible {S : Set A} (hS : Stable R S) : Admissible R S :=
  (stable_complete R hS).1

/-! ## The grounded extension as the intersection of complete extensions -/

/-- **The grounded extension is the intersection of all complete extensions.**
It is complete (hence a member of the family) and lies below every member, so it
equals their intersection.  This holds with no assumption on the framework. -/
theorem groundedExt_eq_sInter_complete :
    groundedExt R = ⋂₀ {S | Complete R S} := by
  apply subset_antisymm
  · exact Set.subset_sInter (fun S hS => groundedExt_subset_complete R hS)
  · exact Set.sInter_subset_of_mem (groundedExt_complete R)

/-! ## Well-founded frameworks -/

/-- **In a well-founded framework the grounded extension is stable.**

By `WellFounded`-induction along the attack relation we show that any argument
`a` *not* attacked by the grounded extension already belongs to it: for each
attacker `b` of `a`, either the grounded extension attacks `b` (the defender we
need) or, by the induction hypothesis, `b` itself joins the grounded extension —
but then `b` would attack `a` from inside the grounded extension, contradicting
the assumption on `a`.  Contrapositively, every argument outside the grounded
extension is attacked by it, i.e. the grounded extension is stable. -/
theorem groundedExt_stable_of_wf (hwf : WellFounded R) :
    Stable R (groundedExt R) := by
  refine ⟨groundedExt_conflictFree R, ?_⟩
  have key : ∀ a, (∀ g ∈ groundedExt R, ¬ R g a) → a ∈ groundedExt R := by
    intro a
    induction a using hwf.induction with
    | _ a ih =>
      intro hna
      rw [← groundedExt_fixed R, mem_charF]
      intro b hba
      by_cases hb : ∃ g ∈ groundedExt R, R g b
      · exact hb
      · push_neg at hb
        exact absurd hba (hna b (ih b hba hb))
  intro a ha
  by_contra hcon
  push_neg at hcon
  exact ha (key a hcon)

/-- **In a well-founded framework every complete extension is contained in the
grounded extension.**  If some argument of a complete extension `S` were outside
the grounded extension, stability of the latter would produce a grounded
attacker of it; that attacker lies in `S` too (grounded ⊆ complete), creating a
conflict inside `S`. -/
theorem complete_subset_grounded_of_wf (hwf : WellFounded R) {S : Set A}
    (hS : Complete R S) : S ⊆ groundedExt R := by
  intro a haS
  by_contra hcon
  obtain ⟨b, hb, hba⟩ := (groundedExt_stable_of_wf R hwf).2 a hcon
  exact hS.1.1 b (groundedExt_subset_complete R hS hb) a haS hba

/-- **In a well-founded framework every complete extension equals the grounded
extension.** -/
theorem complete_eq_grounded_of_wf (hwf : WellFounded R) {S : Set A}
    (hS : Complete R S) : S = groundedExt R :=
  subset_antisymm (complete_subset_grounded_of_wf R hwf hS)
    (groundedExt_subset_complete R hS)

/-- **Dung's uniqueness theorem.**  A well-founded argumentation framework has a
unique complete extension: the grounded extension. -/
theorem grounded_unique_complete_of_wf (hwf : WellFounded R) :
    Complete R (groundedExt R) ∧ ∀ S, Complete R S → S = groundedExt R :=
  ⟨groundedExt_complete R, fun _ hS => complete_eq_grounded_of_wf R hwf hS⟩

/-- In a well-founded framework, every stable extension equals the grounded
extension (stable ⇒ complete ⇒ grounded). -/
theorem stable_eq_grounded_of_wf (hwf : WellFounded R) {S : Set A}
    (hS : Stable R S) : S = groundedExt R :=
  complete_eq_grounded_of_wf R hwf (stable_complete R hS)

/-- In a well-founded framework the stable extension is unique (and coincides
with the grounded extension, which is itself stable). -/
theorem stable_unique_of_wf (hwf : WellFounded R) :
    Stable R (groundedExt R) ∧ ∀ S, Stable R S → S = groundedExt R :=
  ⟨groundedExt_stable_of_wf R hwf, fun _ hS => stable_eq_grounded_of_wf R hwf hS⟩

/-- **In a well-founded framework the grounded extension is preferred**
(maximal admissible), and is in fact the *largest* admissible — hence largest
complete — extension: any admissible superset must coincide with it, because a
strictly larger admissible set would contain an argument outside the grounded
extension, which the grounded extension attacks from within. -/
theorem grounded_preferred_of_wf (hwf : WellFounded R) :
    Preferred R (groundedExt R) := by
  refine ⟨groundedExt_admissible R, fun T hT hsub => ?_⟩
  apply subset_antisymm _ hsub
  intro a haT
  by_contra hcon
  obtain ⟨b, hb, hba⟩ := (groundedExt_stable_of_wf R hwf).2 a hcon
  exact hT.1 b (hsub hb) a haT hba

end ArgGroundedUnique