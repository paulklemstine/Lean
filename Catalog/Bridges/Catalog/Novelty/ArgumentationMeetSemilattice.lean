import Mathlib

/-!
# The topology of argumentation, IX: the complete extensions form a meet-semilattice

This file is **self-contained** (it re-declares the basic Dung semantics from
`ArgumentationCore` / `ArgumentationExtensions`) and settles **Conjecture 1** of
the *Future Directions* cycle:

> Every nonempty family of complete extensions has a greatest lower bound that is
> again complete, and this bound is computed by iterating the defense operator
> from the intersection.

Recall from the earlier development that an argumentation framework is a relation
`R : A → A → Prop`, with defense operator `charF`, and that a set `S` is
*complete* when it is conflict-free and a fixed point of `charF`.  A complete
extension is exactly a conflict-free fixed point of the (monotone) defense
operator.

## The construction

Given a family `𝒮` of complete extensions, put `I := ⋂₀ 𝒮`.  The decisive
observation is that

  `charF I ⊆ I`   (`charF_sInter_subset`)

because `I ⊆ E` for each `E ∈ 𝒮`, monotonicity gives `charF I ⊆ charF E = E`,
and intersecting over `E` yields `charF I ⊆ I`.  Thus `charF` restricts to a
monotone self-map of the interval `[⊥, I]`, and its **greatest fixed point there**
— the largest conflict-free fixed point below `I` — is the desired meet.  We build
that greatest post-fixed point by hand (a Knaster–Tarski union):

  `familyMeet 𝒮 := ⋃₀ {S | S ⊆ I ∧ S ⊆ charF S}`.

## The chain of results

* `complete_charF_eq`        — a complete extension is a fixed point of `charF`;
* `charF_sInter_subset`      — `charF` maps the intersection of complete
  extensions into itself;
* `familyMeet_subset_sInter` — the meet lies below the intersection;
* `familyMeet_postfixed`     — the meet is a post-fixed point of `charF`;
* `familyMeet_fixed`         — the meet is a **fixed point** of `charF`;
* `familyMeet_conflictFree`  — the meet is conflict-free;
* `familyMeet_complete`      — **the meet is a complete extension**;
* `familyMeet_subset_of_mem` / `le_familyMeet` — it is a lower bound, and the
  *greatest* lower bound, among complete extensions;
* `familyMeet_isGLB`         — **the complete extensions form a meet-semilattice**:
  every nonempty family has a complete greatest lower bound;
* `completeInf` / `completeInf_complete` / `completeInf_isGLB` — the binary meet
  of two complete extensions.

## The order-theoretic derivation of the grounded extension

Feeding the family of *all* complete extensions into the meet reconstructs the
**least complete extension** — the grounded extension — purely order-theoretically,
sidestepping the transfinite fixed-point induction of `ArgumentationGrounded`:

* `exists_complete`        — a complete extension exists (Zorn + Fundamental Lemma);
* `exists_least_complete`  — **there is a least complete extension**, namely the
  meet of the family of all complete extensions;
* `least_complete_unique`  — it is unique (the grounded extension, characterized
  order-theoretically as the bottom of the meet-semilattice).
-/

namespace ArgMeet

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

/-! ## Monotonicity and elementary facts -/

theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

/-- Conflict-free sets are downward closed. -/
theorem conflictFree_subset {S T : Set A} (h : S ⊆ T) (hT : ConflictFree R T) :
    ConflictFree R S :=
  fun a ha b hb => hT a (h ha) b (h hb)

/-- **A complete extension is a fixed point of the defense operator.**  It is
closed under defense (`charF S ⊆ S`) and, being admissible, contained in its own
defended set (`S ⊆ charF S`). -/
theorem complete_charF_eq {S : Set A} (h : Complete R S) : charF R S = S :=
  Set.Subset.antisymm h.2 (fun _ ha => h.1.2 _ ha)

/-! ## The defense operator maps `⋂₀ 𝒮` into itself -/

/-- **The defense operator maps the intersection of complete extensions into
itself.**  If every member of `𝒮` is complete, then `charF (⋂₀ 𝒮) ⊆ ⋂₀ 𝒮`. -/
theorem charF_sInter_subset {𝒮 : Set (Set A)}
    (h : ∀ E ∈ 𝒮, Complete R E) : charF R (⋂₀ 𝒮) ⊆ ⋂₀ 𝒮 := by
  intro x hx
  rw [Set.mem_sInter]
  intro E hE
  have hstep : charF R (⋂₀ 𝒮) ⊆ charF R E :=
    charF_mono R (Set.sInter_subset_of_mem hE)
  have hEeq : charF R E = E := complete_charF_eq R (h E hE)
  rw [hEeq] at hstep
  exact hstep hx

/-! ## The meet of a family of complete extensions -/

/-- **The meet** of a family `𝒮`: the union of all post-fixed points of `charF`
contained in the intersection `⋂₀ 𝒮`.  This is the greatest fixed point of the
defense operator below the intersection. -/
def familyMeet (𝒮 : Set (Set A)) : Set A :=
  ⋃₀ {S | S ⊆ ⋂₀ 𝒮 ∧ S ⊆ charF R S}

/-- The meet lies below the intersection of the family. -/
theorem familyMeet_subset_sInter (𝒮 : Set (Set A)) :
    familyMeet R 𝒮 ⊆ ⋂₀ 𝒮 := by
  rintro x ⟨S, ⟨hSI, _⟩, hxS⟩
  exact hSI hxS

/-- The meet is a post-fixed point of the defense operator: `familyMeet ⊆
charF (familyMeet)`. -/
theorem familyMeet_postfixed (𝒮 : Set (Set A)) :
    familyMeet R 𝒮 ⊆ charF R (familyMeet R 𝒮) := by
  rintro x ⟨S, ⟨hSI, hSpost⟩, hxS⟩
  have hsub : S ⊆ familyMeet R 𝒮 := fun y hy => ⟨S, ⟨hSI, hSpost⟩, hy⟩
  exact charF_mono R hsub (hSpost hxS)

/-- The defense operator maps the meet into itself: `charF (familyMeet) ⊆
familyMeet`.  Indeed `charF (familyMeet)` is itself a post-fixed point contained
in `⋂₀ 𝒮`, hence a member of the union defining the meet. -/
theorem familyMeet_charF_subset {𝒮 : Set (Set A)}
    (h : ∀ E ∈ 𝒮, Complete R E) :
    charF R (familyMeet R 𝒮) ⊆ familyMeet R 𝒮 := by
  intro x hx
  have hpost : familyMeet R 𝒮 ⊆ charF R (familyMeet R 𝒮) := familyMeet_postfixed R 𝒮
  have hfmI : familyMeet R 𝒮 ⊆ ⋂₀ 𝒮 := familyMeet_subset_sInter R 𝒮
  have hcharI : charF R (familyMeet R 𝒮) ⊆ ⋂₀ 𝒮 :=
    (charF_mono R hfmI).trans (charF_sInter_subset R h)
  have hcharpost : charF R (familyMeet R 𝒮) ⊆ charF R (charF R (familyMeet R 𝒮)) :=
    charF_mono R hpost
  exact ⟨charF R (familyMeet R 𝒮), ⟨hcharI, hcharpost⟩, hx⟩

/-- **The meet is a fixed point of the defense operator.** -/
theorem familyMeet_fixed {𝒮 : Set (Set A)} (h : ∀ E ∈ 𝒮, Complete R E) :
    charF R (familyMeet R 𝒮) = familyMeet R 𝒮 :=
  Set.Subset.antisymm (familyMeet_charF_subset R h) (familyMeet_postfixed R 𝒮)

/-- The meet of a nonempty family of complete extensions is conflict-free (it is
contained in any member, which is conflict-free). -/
theorem familyMeet_conflictFree {𝒮 : Set (Set A)} (hne : 𝒮.Nonempty)
    (h : ∀ E ∈ 𝒮, Complete R E) : ConflictFree R (familyMeet R 𝒮) := by
  obtain ⟨E, hE⟩ := hne
  have hsub : familyMeet R 𝒮 ⊆ E :=
    (familyMeet_subset_sInter R 𝒮).trans (Set.sInter_subset_of_mem hE)
  exact conflictFree_subset R hsub (h E hE).1.1

/-- **The meet of a nonempty family of complete extensions is complete.**  It is
a conflict-free fixed point of the defense operator. -/
theorem familyMeet_complete {𝒮 : Set (Set A)} (hne : 𝒮.Nonempty)
    (h : ∀ E ∈ 𝒮, Complete R E) : Complete R (familyMeet R 𝒮) := by
  refine ⟨⟨familyMeet_conflictFree R hne h, ?_⟩, familyMeet_charF_subset R h⟩
  intro a ha
  exact familyMeet_postfixed R 𝒮 ha

/-! ## The meet is the greatest lower bound -/

/-- The meet is a lower bound: it is contained in every member of the family. -/
theorem familyMeet_subset_of_mem {𝒮 : Set (Set A)} {E : Set A} (hE : E ∈ 𝒮) :
    familyMeet R 𝒮 ⊆ E :=
  (familyMeet_subset_sInter R 𝒮).trans (Set.sInter_subset_of_mem hE)

/-- **The meet is the greatest lower bound.**  Any complete extension `L` that is
a lower bound of the family is contained in the meet: `L` is a post-fixed point
of `charF` contained in `⋂₀ 𝒮`. -/
theorem le_familyMeet {𝒮 : Set (Set A)} {L : Set A} (hL : Complete R L)
    (hLb : ∀ E ∈ 𝒮, L ⊆ E) : L ⊆ familyMeet R 𝒮 := by
  have hLI : L ⊆ ⋂₀ 𝒮 := Set.subset_sInter hLb
  have hLpost : L ⊆ charF R L := fun a ha => hL.1.2 a ha
  exact fun x hx => ⟨L, ⟨hLI, hLpost⟩, hx⟩

/-- **Conjecture 1 — the complete extensions form a meet-semilattice.**  Every
nonempty family `𝒮` of complete extensions has a greatest lower bound that is
again complete: the meet `familyMeet 𝒮` is a complete extension, is a lower bound
of `𝒮`, and dominates every complete lower bound. -/
theorem familyMeet_isGLB {𝒮 : Set (Set A)} (hne : 𝒮.Nonempty)
    (h : ∀ E ∈ 𝒮, Complete R E) :
    Complete R (familyMeet R 𝒮) ∧
      (∀ E ∈ 𝒮, familyMeet R 𝒮 ⊆ E) ∧
      (∀ L, Complete R L → (∀ E ∈ 𝒮, L ⊆ E) → L ⊆ familyMeet R 𝒮) :=
  ⟨familyMeet_complete R hne h,
   fun _ hE => familyMeet_subset_of_mem R hE,
   fun _ hL hLb => le_familyMeet R hL hLb⟩

/-! ## The binary meet of two complete extensions -/

/-- The **binary meet** of two complete extensions. -/
def completeInf (S T : Set A) : Set A := familyMeet R ({S, T} : Set (Set A))

/-- The binary meet of two complete extensions is complete. -/
theorem completeInf_complete {S T : Set A} (hS : Complete R S) (hT : Complete R T) :
    Complete R (completeInf R S T) := by
  apply familyMeet_complete R ⟨S, by simp⟩
  intro E hE
  rcases hE with rfl | rfl <;> assumption

/-- The binary meet is a lower bound of each argument. -/
theorem completeInf_le_left {S T : Set A} : completeInf R S T ⊆ S :=
  familyMeet_subset_of_mem R (by simp)

theorem completeInf_le_right {S T : Set A} : completeInf R S T ⊆ T :=
  familyMeet_subset_of_mem R (by simp)

/-- **The binary meet is the greatest lower bound** of two complete extensions. -/
theorem completeInf_isGLB {S T : Set A} (hS : Complete R S) (hT : Complete R T) :
    Complete R (completeInf R S T) ∧ completeInf R S T ⊆ S ∧
      completeInf R S T ⊆ T ∧
      (∀ L, Complete R L → L ⊆ S → L ⊆ T → L ⊆ completeInf R S T) := by
  refine ⟨completeInf_complete R hS hT, completeInf_le_left R,
    completeInf_le_right R, ?_⟩
  intro L hL hLS hLT
  apply le_familyMeet R hL
  intro E hE
  rcases hE with rfl | rfl <;> assumption

/-! ## Existence of complete extensions (Zorn + Fundamental Lemma) -/

/-- **Dung's Fundamental Lemma.**  If `S` is admissible and defends `a`, then
`insert a S` is again admissible. -/
theorem fundamental_lemma {S : Set A} (hS : Admissible R S) {a : A}
    (ha : Defends R S a) : Admissible R (insert a S) := by
  obtain ⟨hcf, hdef⟩ := hS
  have H1 : ∀ c ∈ S, ¬ R c a := fun c hc hca => by
    obtain ⟨d, hd, hdc⟩ := ha c hca; exact hcf d hd c hc hdc
  have H2 : ∀ c ∈ S, ¬ R a c := fun c hc hac => by
    obtain ⟨d, hd, hda⟩ := hdef c hc a hac; exact H1 d hd hda
  have H3 : ¬ R a a := fun haa => by
    obtain ⟨c, hc, hca⟩ := ha a haa; exact H1 c hc hca
  refine ⟨?_, ?_⟩
  · intro x hx y hy hxy
    rcases hx with rfl | hx <;> rcases hy with rfl | hy
    · exact H3 hxy
    · exact H2 y hy hxy
    · exact H1 x hx hxy
    · exact hcf x hx y hy hxy
  · intro x hx
    rcases hx with rfl | hx
    · exact defends_mono R (Set.subset_insert _ _) ha
    · exact defends_mono R (Set.subset_insert _ _) (hdef x hx)

/-- The union of a chain of admissible sets is admissible. -/
theorem admissible_sUnion_chain {c : Set (Set A)} (hc : IsChain (· ⊆ ·) c)
    (hadm : ∀ S ∈ c, Admissible R S) : Admissible R (⋃₀ c) := by
  refine ⟨?_, ?_⟩
  · rintro a ⟨S1, hS1, ha⟩ b ⟨S2, hS2, hb⟩ hab
    rcases hc.total hS1 hS2 with h | h
    · exact (hadm S2 hS2).1 a (h ha) b hb hab
    · exact (hadm S1 hS1).1 a ha b (h hb) hab
  · rintro a ⟨S, hS, ha⟩
    exact defends_mono R (Set.subset_sUnion_of_mem hS) ((hadm S hS).2 a ha)

/-- **Existence of a complete extension.**  By Zorn's Lemma the empty admissible
set extends to a maximal admissible (preferred) set, and by the Fundamental Lemma
every maximal admissible set is complete. -/
theorem exists_complete : ∃ S, Complete R S := by
  obtain ⟨m, _, hmax⟩ := zorn_subset_nonempty {T | Admissible R T}
    (fun c hcsub hchain _ => ⟨⋃₀ c,
      admissible_sUnion_chain R hchain (fun S hS => hcsub hS),
      fun s hs => Set.subset_sUnion_of_mem hs⟩) ∅
    ⟨fun a ha => absurd ha (Set.notMem_empty a),
     fun a ha => absurd ha (Set.notMem_empty a)⟩
  refine ⟨m, hmax.prop, ?_⟩
  intro a ha
  have hins : Admissible R (insert a m) := fundamental_lemma R hmax.prop ha
  have heq : insert a m = m := hmax.eq_of_ge hins (Set.subset_insert a m)
  rw [← heq]; exact Set.mem_insert a m

/-! ## The least complete extension (the grounded extension, order-theoretically) -/

/-- **There is a least complete extension.**  It is the meet of the family of
*all* complete extensions; the family is nonempty by `exists_complete`, so the
meet is complete, and it is a lower bound of every complete extension.  This
recovers the grounded extension purely order-theoretically, without the
transfinite fixed-point induction used in `ArgumentationGrounded`. -/
theorem exists_least_complete :
    ∃ L, Complete R L ∧ ∀ E, Complete R E → L ⊆ E := by
  obtain ⟨C, hC⟩ := exists_complete R
  have hne : ({S : Set A | Complete R S}).Nonempty := ⟨C, hC⟩
  have hall : ∀ E ∈ {S : Set A | Complete R S}, Complete R E := fun _ hE => hE
  refine ⟨familyMeet R {S : Set A | Complete R S},
    familyMeet_complete R hne hall, ?_⟩
  intro E hE
  exact familyMeet_subset_of_mem R hE

/-- **The least complete extension is unique** — the bottom element of the
complete-extension meet-semilattice (the grounded extension). -/
theorem least_complete_unique {L L' : Set A}
    (hL : Complete R L) (hLmin : ∀ E, Complete R E → L ⊆ E)
    (hL' : Complete R L') (hL'min : ∀ E, Complete R E → L' ⊆ E) : L = L' :=
  Set.Subset.antisymm (hLmin L' hL') (hL'min L hL)

end ArgMeet