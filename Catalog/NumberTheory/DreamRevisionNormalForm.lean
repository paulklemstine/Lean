import Catalog.Novelty.DreamLogic

/-!
# Normal forms and reachability for dream-logic revision histories

This file develops the *global* theory of iterated signed-literal revision on top of
`Catalog/Novelty/DreamLogic.lean`, which supplied only the single-step operator
`DreamLogic.revise`.

Two local rewriting rules are isolated first:

* `revise_comm_of_ne_atom` — revisions at **distinct** atoms commute;
* `revise_revise_of_eq_atom` — revisions at the **same** atom obey *last write wins*.

They are then integrated into a global normalization theorem.  Writing
`reviseSeq B ls` for the state obtained by performing the revisions `ls` in order,
and `lastSign ls a` for the sign carried by the last occurrence of atom `a` in `ls`
(`none` if `a` is never revised), the main theorem `mem_reviseSeq` states

```
p ∈ reviseSeq B ls ↔ lastSign ls p.1 = some p.2 ∨ (lastSign ls p.1 = none ∧ p ∈ B)
```

so a revision history acts as *overwrite on the atoms it mentions, identity elsewhere*.
Consequences:

* `reviseSeq_ext_iff` — two histories act identically on **every** state iff they act
  identically on the empty state iff they have the same last-occurrence record
  (extensional rigidity);
* `normalForm` — an explicit normal form, one literal per mentioned atom, with the same
  action, unique up to permutation (`normalForm_unique`);
* `persistent_nonexplosion` — a frame property: a literal absent from the initial state
  and untouched by the history stays absent, however many times a contradictory atom is
  revised;
* `mutually_reachable_iff` — for finite consistent states, mutual reachability under
  revision is *exactly* equality of the set of assigned atoms, which classifies the
  strongly connected components of the oriented revision graph.
-/

namespace DreamLogic

variable {Atom : Type*}

/-! ## Two literals over the same atom -/

/-- Two literals based at the same atom are equal or complementary. -/
theorem eq_or_eq_opposite {l k : Literal Atom} (h : l.1 = k.1) : l = k ∨ l = opposite k := by
  rcases l with ⟨a, s⟩; rcases k with ⟨b, t⟩
  simp only at h; subst h
  cases s <;> cases t <;> simp [opposite]

/-- A consistent state assigns at most one sign to each atom. -/
theorem Consistent.eq_of_mem {B : Set (Literal Atom)} (hB : Consistent B) {a : Atom}
    {s t : Bool} (hs : (a, s) ∈ B) (ht : (a, t) ∈ B) : s = t := by
  by_contra hst
  refine hB a ?_
  cases s <;> cases t <;> simp_all [Contradictory]

/-! ## Local rewriting rules -/

/-- Revisions at distinct atoms commute. -/
theorem revise_comm_of_ne_atom (B : Set (Literal Atom)) {l k : Literal Atom}
    (h : l.1 ≠ k.1) : revise (revise B l) k = revise (revise B k) l := by
  have h1 : l ≠ opposite k := fun e => h (by rw [e, opposite_fst])
  have h2 : k ≠ opposite l := fun e => h (by rw [e, opposite_fst])
  ext x
  simp only [revise, Set.mem_insert_iff, Set.mem_diff, Set.mem_singleton_iff]
  constructor
  · rintro (rfl | ⟨(rfl | ⟨hx, hx2⟩), hx3⟩)
    · exact Or.inr ⟨Or.inl rfl, h2⟩
    · exact Or.inl rfl
    · exact Or.inr ⟨Or.inr ⟨hx, hx3⟩, hx2⟩
  · rintro (rfl | ⟨(rfl | ⟨hx, hx2⟩), hx3⟩)
    · exact Or.inr ⟨Or.inl rfl, h1⟩
    · exact Or.inl rfl
    · exact Or.inr ⟨Or.inr ⟨hx, hx3⟩, hx2⟩

/-- *Last write wins*: a revision at an atom erases the effect of any earlier revision at
the same atom. -/
theorem revise_revise_of_eq_atom (B : Set (Literal Atom)) {l k : Literal Atom}
    (h : l.1 = k.1) : revise (revise B l) k = revise B k := by
  ext x
  simp only [revise, Set.mem_insert_iff, Set.mem_diff, Set.mem_singleton_iff]
  constructor
  · rintro (rfl | ⟨(rfl | ⟨hx, hx2⟩), hx3⟩)
    · exact Or.inl rfl
    · exact Or.inl ((eq_or_eq_opposite h).resolve_right hx3)
    · exact Or.inr ⟨hx, hx3⟩
  · rintro (rfl | ⟨hx, hx2⟩)
    · exact Or.inl rfl
    · by_cases hxk : x = k
      · exact Or.inl hxk
      · have hfst : x.1 ≠ k.1 := fun e => by
          rcases eq_or_eq_opposite e with h' | h'
          · exact hxk h'
          · exact hx2 h'
        exact Or.inr ⟨Or.inr ⟨hx, fun e => hfst (by rw [e, opposite_fst, h])⟩, hx2⟩

/-! ## Revision histories -/

/-- Perform the revisions in `ls` from left to right. -/
def reviseSeq (B : Set (Literal Atom)) (ls : List (Literal Atom)) : Set (Literal Atom) :=
  ls.foldl revise B

@[simp] theorem reviseSeq_nil (B : Set (Literal Atom)) : reviseSeq B [] = B := rfl

@[simp] theorem reviseSeq_cons (B : Set (Literal Atom)) (l : Literal Atom)
    (ls : List (Literal Atom)) : reviseSeq B (l :: ls) = reviseSeq (revise B l) ls := rfl

theorem reviseSeq_append (B : Set (Literal Atom)) (ls ms : List (Literal Atom)) :
    reviseSeq B (ls ++ ms) = reviseSeq (reviseSeq B ls) ms := by
  simp [reviseSeq, List.foldl_append]

/-- `lastSign ls a` is the sign of the last literal of `ls` based at atom `a`, and `none`
when `a` is never revised along `ls`. -/
def lastSign [DecidableEq Atom] : List (Literal Atom) → Atom → Option Bool
  | [], _ => none
  | l :: t, a =>
      match lastSign t a with
      | some s => some s
      | none => if l.1 = a then some l.2 else none

@[simp] theorem lastSign_nil [DecidableEq Atom] (a : Atom) :
    lastSign ([] : List (Literal Atom)) a = none := rfl

/-- An atom has no last sign exactly when the history never mentions it. -/
theorem lastSign_eq_none_iff [DecidableEq Atom] (ls : List (Literal Atom)) (a : Atom) :
    lastSign ls a = none ↔ ∀ m ∈ ls, m.1 ≠ a := by
  induction ls with
  | nil => simp
  | cons l t ih =>
    constructor
    · intro h m hm
      simp only [lastSign] at h
      cases hl : lastSign t a with
      | some s => rw [hl] at h; simp at h
      | none =>
        rw [hl] at h
        by_cases hla : l.1 = a
        · rw [if_pos hla] at h; simp at h
        · rcases List.mem_cons.1 hm with rfl | hm'
          · exact hla
          · exact ih.1 hl m hm'
    · intro h
      simp only [lastSign]
      rw [ih.2 fun m hm => h m (List.mem_cons_of_mem _ hm)]
      exact if_neg (h l (List.mem_cons_self ..))

/-- A recorded last sign really occurs in the history. -/
theorem lastSign_eq_some_mem [DecidableEq Atom] {ls : List (Literal Atom)} {a : Atom}
    {s : Bool} (h : lastSign ls a = some s) : (a, s) ∈ ls := by
  induction ls with
  | nil => simp at h
  | cons l t ih =>
    simp only [lastSign] at h
    cases hl : lastSign t a with
    | some s' =>
      rw [hl] at h
      have hs : s' = s := by simpa using h
      subst hs
      exact List.mem_cons_of_mem _ (ih hl)
    | none =>
      rw [hl] at h
      by_cases hla : l.1 = a
      · rw [if_pos hla] at h
        have hs : l.2 = s := by simpa using h
        subst hla; subst hs
        simp
      · rw [if_neg hla] at h; simp at h

/-- Every mentioned atom has a last sign. -/
theorem lastSign_isSome_of_mem [DecidableEq Atom] {ls : List (Literal Atom)}
    {m : Literal Atom} (h : m ∈ ls) : (lastSign ls m.1).isSome := by
  cases hl : lastSign ls m.1 with
  | some s => simp
  | none => exact absurd rfl ((lastSign_eq_none_iff ls m.1).1 hl m h)

/-! ## The normalization theorem -/

/-- **Last-occurrence normal form.** A revision history overwrites each atom it mentions
with the sign of that atom's last occurrence, and leaves every other atom exactly as it
was in the initial state. -/
theorem mem_reviseSeq [DecidableEq Atom] (B : Set (Literal Atom))
    (ls : List (Literal Atom)) (p : Literal Atom) :
    p ∈ reviseSeq B ls ↔
      lastSign ls p.1 = some p.2 ∨ (lastSign ls p.1 = none ∧ p ∈ B) := by
  induction ls generalizing B with
  | nil => simp
  | cons l t ih =>
    rw [reviseSeq_cons, ih]
    simp only [lastSign]
    cases hl : lastSign t p.1 with
    | some s => simp
    | none =>
      dsimp only
      by_cases hlp : l.1 = p.1
      · rw [if_pos hlp]
        have key : p = l ↔ l.2 = p.2 := by
          constructor
          · rintro rfl; rfl
          · intro h
            rcases l with ⟨a, s⟩; rcases p with ⟨b, t'⟩
            simp only at hlp h
            subst hlp; subst h; rfl
        simp only [revise, Set.mem_insert_iff, Set.mem_diff, Set.mem_singleton_iff,
          reduceCtorEq, false_or, true_and, Option.some.injEq]
        constructor
        · rintro (h' | ⟨hpB, hpo⟩)
          · exact Or.inl (key.1 h')
          · exact Or.inl (key.1 ((eq_or_eq_opposite hlp.symm).resolve_right hpo))
        · rintro (h' | ⟨hf, -⟩)
          · exact Or.inl (key.2 h')
          · exact absurd hf (by simp)
      · rw [if_neg hlp]
        have hpl : p ≠ l := fun e => hlp (by rw [e])
        have hpo : p ≠ opposite l := fun e => hlp (by rw [e, opposite_fst])
        simp [revise, hpl, hpo]

/-- Set-level form of `mem_reviseSeq`. -/
theorem reviseSeq_eq [DecidableEq Atom] (B : Set (Literal Atom))
    (ls : List (Literal Atom)) :
    reviseSeq B ls =
      {p : Literal Atom | lastSign ls p.1 = some p.2} ∪
        {p | lastSign ls p.1 = none ∧ p ∈ B} := by
  ext p; simpa using mem_reviseSeq B ls p

/-- From the empty state, a history produces exactly its own last-occurrence record. -/
theorem reviseSeq_empty [DecidableEq Atom] (ls : List (Literal Atom)) :
    reviseSeq (∅ : Set (Literal Atom)) ls =
      {p : Literal Atom | lastSign ls p.1 = some p.2} := by
  ext p; simpa using mem_reviseSeq (∅ : Set (Literal Atom)) ls p

/-- The last-occurrence record is already determined by the action on the empty state. -/
theorem reviseSeq_ext_iff_empty [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    reviseSeq (∅ : Set (Literal Atom)) ls = reviseSeq (∅ : Set (Literal Atom)) ms ↔
      ∀ a, lastSign ls a = lastSign ms a := by
  constructor
  · intro h a
    have key : ∀ s : Bool, lastSign ls a = some s ↔ lastSign ms a = some s := by
      intro s
      have hs := Set.ext_iff.1 h (a, s)
      rw [reviseSeq_empty, reviseSeq_empty] at hs
      simpa using hs
    cases hls : lastSign ls a with
    | some s => exact ((key s).1 hls).symm
    | none =>
      cases hms : lastSign ms a with
      | some s => exact absurd ((key s).2 hms) (by simp [hls])
      | none => rfl
  · intro h
    ext p
    rw [mem_reviseSeq, mem_reviseSeq, h p.1]

/-- **Extensional rigidity of revision histories.** Acting alike on every state and having
the same last-occurrence record are equivalent. -/
theorem reviseSeq_ext_iff [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    (∀ B : Set (Literal Atom), reviseSeq B ls = reviseSeq B ms) ↔
      ∀ a, lastSign ls a = lastSign ms a := by
  constructor
  · intro h
    exact (reviseSeq_ext_iff_empty ls ms).1 (h ∅)
  · intro h B
    ext p
    rw [mem_reviseSeq, mem_reviseSeq, h p.1]

/-! ## An explicit normal form -/

/-- Delete every literal that is superseded by a later revision of the same atom. -/
def normalForm [DecidableEq Atom] : List (Literal Atom) → List (Literal Atom)
  | [] => []
  | l :: t => if t.any (fun m => m.1 = l.1) then normalForm t else l :: normalForm t

@[simp] theorem normalForm_nil [DecidableEq Atom] :
    normalForm ([] : List (Literal Atom)) = [] := rfl

theorem normalForm_sublist [DecidableEq Atom] (ls : List (Literal Atom)) :
    (normalForm ls).Sublist ls := by
  induction ls with
  | nil => simp
  | cons l t ih =>
    simp only [normalForm]
    by_cases hany : t.any (fun m => m.1 = l.1)
    · rw [if_pos hany]; exact ih.trans (List.sublist_cons_self l t)
    · rw [if_neg hany]; exact ih.cons₂ l

theorem mem_of_mem_normalForm [DecidableEq Atom] {ls : List (Literal Atom)}
    {m : Literal Atom} (h : m ∈ normalForm ls) : m ∈ ls :=
  (normalForm_sublist ls).mem h

/-- The normal form has the same last-occurrence record. -/
theorem lastSign_normalForm [DecidableEq Atom] (ls : List (Literal Atom)) (a : Atom) :
    lastSign (normalForm ls) a = lastSign ls a := by
  induction ls with
  | nil => rfl
  | cons l t ih =>
    simp only [normalForm]
    by_cases hany : t.any (fun m => m.1 = l.1)
    · rw [if_pos hany, ih]
      obtain ⟨m, hm, hm2⟩ := List.any_eq_true.1 hany
      have hml : m.1 = l.1 := by simpa using hm2
      simp only [lastSign]
      cases hl : lastSign t a with
      | some s => rfl
      | none =>
        rw [if_neg]
        intro hla
        exact (lastSign_eq_none_iff t a).1 hl m hm (by rw [hml, hla])
    · rw [if_neg hany]
      simp only [lastSign, ih]

theorem reviseSeq_normalForm [DecidableEq Atom] (B : Set (Literal Atom))
    (ls : List (Literal Atom)) : reviseSeq B (normalForm ls) = reviseSeq B ls := by
  ext p
  rw [mem_reviseSeq, mem_reviseSeq, lastSign_normalForm]

/-- The normal form mentions each atom at most once. -/
theorem normalForm_nodup_atoms [DecidableEq Atom] (ls : List (Literal Atom)) :
    ((normalForm ls).map Prod.fst).Nodup := by
  induction ls with
  | nil => simp
  | cons l t ih =>
    simp only [normalForm]
    by_cases hany : t.any (fun m => m.1 = l.1)
    · rw [if_pos hany]; exact ih
    · rw [if_neg hany]
      simp only [List.map_cons, List.nodup_cons]
      refine ⟨?_, ih⟩
      intro hmem
      obtain ⟨m, hm, hm2⟩ := List.mem_map.1 hmem
      exact hany (List.any_eq_true.2 ⟨m, mem_of_mem_normalForm hm, by simpa using hm2⟩)

/-- A history mentioning each atom at most once contains exactly the literals recorded by
its last-occurrence function. -/
theorem mem_iff_lastSign_of_nodup_atoms [DecidableEq Atom] {ms : List (Literal Atom)}
    (h : (ms.map Prod.fst).Nodup) (p : Literal Atom) :
    p ∈ ms ↔ lastSign ms p.1 = some p.2 := by
  constructor
  · intro hp
    cases hl : lastSign ms p.1 with
    | none => exact absurd rfl ((lastSign_eq_none_iff ms p.1).1 hl p hp)
    | some s =>
      have hmem := lastSign_eq_some_mem hl
      have := List.inj_on_of_nodup_map h hp hmem rfl
      rw [this]
  · intro hl
    have := lastSign_eq_some_mem hl
    simpa using this

/-- **Uniqueness of the normal form.** Any history that mentions each atom at most once and
has the same last-occurrence record as `ls` is a permutation of `normalForm ls`.
Permutation is the sharpest possible conclusion, since revisions at distinct atoms
commute. -/
theorem normalForm_unique [DecidableEq Atom] {ls ms : List (Literal Atom)}
    (hnodup : (ms.map Prod.fst).Nodup)
    (haction : ∀ a, lastSign ms a = lastSign ls a) :
    ms.Perm (normalForm ls) := by
  have h1 : ms.Nodup := List.Nodup.of_map _ hnodup
  have h2 : (normalForm ls).Nodup := List.Nodup.of_map _ (normalForm_nodup_atoms ls)
  refine (List.perm_ext_iff_of_nodup h1 h2).2 fun p => ?_
  rw [mem_iff_lastSign_of_nodup_atoms hnodup,
    mem_iff_lastSign_of_nodup_atoms (normalForm_nodup_atoms ls), lastSign_normalForm,
    haction]

/-! ## Persistent non-explosion (frame property) -/

/-- Atoms untouched by a history keep their initial status. -/
theorem reviseSeq_frame [DecidableEq Atom] {B : Set (Literal Atom)}
    {ls : List (Literal Atom)} {a : Atom} (h : ∀ m ∈ ls, m.1 ≠ a) (s : Bool) :
    (a, s) ∈ reviseSeq B ls ↔ (a, s) ∈ B := by
  have hnone : lastSign ls a = none := (lastSign_eq_none_iff ls a).2 h
  rw [mem_reviseSeq]
  simp [hnone]

/-- **Persistent non-explosion.**  If a state is contradictory at `a` and fails to accept
the literal `l` based at a different atom, then no revision history avoiding `l`'s atom
can make `l` accepted — however often the contradictory atom `a` is revised.

The hypothesis `Contradictory B a` is recorded because it is part of the conjecture being
tested; the frame argument itself does not need it. -/
theorem persistent_nonexplosion [DecidableEq Atom] {B : Set (Literal Atom)} {a : Atom}
    (_hcon : Contradictory B a) {l : Literal Atom} (_hne : l.1 ≠ a) (hl : ¬ Entails B l)
    {ls : List (Literal Atom)} (hls : ∀ m ∈ ls, m.1 ≠ l.1) :
    ¬ Entails (reviseSeq B ls) l := by
  intro hmem
  refine hl ?_
  have := (reviseSeq_frame (B := B) (ls := ls) (a := l.1) hls l.2).1 (by simpa using hmem)
  simpa using this

/-! ## Assigned atoms and the geometry of the revision graph -/

/-- The set of atoms to which the state assigns at least one sign. -/
def assigned (B : Set (Literal Atom)) : Set Atom := {a | ∃ s, (a, s) ∈ B}

/-- A consistent state is precisely a partial sign assignment: it chooses at most one of
the two complementary vertices over each atom. -/
theorem consistent_iff_partial_function (B : Set (Literal Atom)) :
    Consistent B ↔ ∃ f : Atom → Option Bool, B = {p : Literal Atom | f p.1 = some p.2} := by
  classical
  constructor
  · intro hB
    refine ⟨fun a => if (a, true) ∈ B then some true else if (a, false) ∈ B then some false
      else none, ?_⟩
    ext p
    obtain ⟨a, s⟩ := p
    simp only [Set.mem_setOf_eq]
    cases s with
    | true =>
      constructor
      · intro hp; rw [if_pos hp]
      · intro hp
        by_cases h1 : (a, true) ∈ B
        · exact h1
        · rw [if_neg h1] at hp
          by_cases h2 : (a, false) ∈ B <;> simp [h2] at hp
    | false =>
      constructor
      · intro hp
        have h1 : (a, true) ∉ B := fun h => hB a ⟨h, hp⟩
        rw [if_neg h1, if_pos hp]
      · intro hp
        by_cases h1 : (a, true) ∈ B
        · rw [if_pos h1] at hp; simp at hp
        · rw [if_neg h1] at hp
          by_cases h2 : (a, false) ∈ B
          · exact h2
          · rw [if_neg h2] at hp; simp at hp
  · rintro ⟨f, rfl⟩ a ⟨h1, h2⟩
    simp only [Set.mem_setOf_eq] at h1 h2
    rw [h1] at h2
    simp at h2

/-- A single revision adds exactly one atom to the assigned set. -/
theorem assigned_revise (B : Set (Literal Atom)) (l : Literal Atom) :
    assigned (revise B l) = insert l.1 (assigned B) := by
  ext a
  simp only [assigned, revise, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_diff,
    Set.mem_singleton_iff]
  constructor
  · rintro ⟨s, hs | ⟨hs, -⟩⟩
    · exact Or.inl (by rw [← hs])
    · exact Or.inr ⟨s, hs⟩
  · rintro (rfl | ⟨s, hs⟩)
    · exact ⟨l.2, Or.inl rfl⟩
    · by_cases h : (a, s) = opposite l
      · have ha : a = l.1 := by simpa using congrArg Prod.fst h
        exact ⟨l.2, Or.inl (by rw [ha])⟩
      · exact ⟨s, Or.inr ⟨hs, h⟩⟩

/-- The assigned set only grows along a history. -/
theorem assigned_subset_reviseSeq (B : Set (Literal Atom)) (ls : List (Literal Atom)) :
    assigned B ⊆ assigned (reviseSeq B ls) := by
  induction ls generalizing B with
  | nil => simp
  | cons l t ih =>
    rw [reviseSeq_cons]
    refine subset_trans ?_ (ih (revise B l))
    rw [assigned_revise]
    exact Set.subset_insert _ _

/-- `C` is reachable from `B` by some revision history. -/
def Reachable (B C : Set (Literal Atom)) : Prop := ∃ ls, reviseSeq B ls = C

theorem reachable_refl (B : Set (Literal Atom)) : Reachable B B := ⟨[], rfl⟩

theorem reachable_trans {B C D : Set (Literal Atom)} (h₁ : Reachable B C)
    (h₂ : Reachable C D) : Reachable B D := by
  obtain ⟨ls, rfl⟩ := h₁
  obtain ⟨ms, rfl⟩ := h₂
  exact ⟨ls ++ ms, reviseSeq_append B ls ms⟩

/-- Reachability can only enlarge the assigned set. -/
theorem assigned_subset_of_reachable {B C : Set (Literal Atom)} (h : Reachable B C) :
    assigned B ⊆ assigned C := by
  obtain ⟨ls, rfl⟩ := h
  exact assigned_subset_reviseSeq B ls

/-- Any finite consistent state with the same assigned atoms is reachable. -/
theorem reachable_of_assigned_eq [DecidableEq Atom] {B C : Set (Literal Atom)}
    (hC : Consistent C) (hCfin : C.Finite) (h : assigned B = assigned C) :
    Reachable B C := by
  classical
  refine ⟨hCfin.toFinset.toList, ?_⟩
  have hls : ∀ p : Literal Atom, p ∈ hCfin.toFinset.toList ↔ p ∈ C := by
    intro p; simp
  ext p
  rw [mem_reviseSeq]
  constructor
  · rintro (hsome | ⟨hnone, hpB⟩)
    · have := lastSign_eq_some_mem hsome
      simpa using (hls _).1 this
    · exfalso
      have hp1 : p.1 ∈ assigned C := h ▸ ⟨p.2, by simpa using hpB⟩
      obtain ⟨s, hs⟩ := hp1
      exact ((lastSign_eq_none_iff _ p.1).1 hnone (p.1, s) ((hls _).2 hs)) rfl
  · intro hp
    left
    have hmem : p ∈ hCfin.toFinset.toList := (hls p).2 hp
    cases hl : lastSign hCfin.toFinset.toList p.1 with
    | none => exact absurd rfl ((lastSign_eq_none_iff _ p.1).1 hl p hmem)
    | some s =>
      have hsC : (p.1, s) ∈ C := (hls _).1 (lastSign_eq_some_mem hl)
      have : s = p.2 := hC.eq_of_mem hsC (by simpa using hp)
      rw [this]

/-- **Classification of the strongly connected components.**  Among finite consistent
states, two states are mutually reachable by revision histories exactly when they assign
signs to the same atoms.  The strongly connected components of the oriented revision graph
are therefore indexed by the set of assigned atoms. -/
theorem mutually_reachable_iff [DecidableEq Atom] {B C : Set (Literal Atom)}
    (hB : Consistent B) (hBfin : B.Finite) (hC : Consistent C) (hCfin : C.Finite) :
    (Reachable B C ∧ Reachable C B) ↔ assigned B = assigned C := by
  constructor
  · rintro ⟨h1, h2⟩
    exact Set.Subset.antisymm (assigned_subset_of_reachable h1) (assigned_subset_of_reachable h2)
  · intro h
    exact ⟨reachable_of_assigned_eq hC hCfin h, reachable_of_assigned_eq hB hBfin h.symm⟩

/-! ## Invariants along a history -/

/-- Revision histories preserve consistency. -/
theorem consistent_reviseSeq {B : Set (Literal Atom)} (hB : Consistent B)
    (ls : List (Literal Atom)) : Consistent (reviseSeq B ls) := by
  induction ls generalizing B with
  | nil => simpa using hB
  | cons l t ih => exact ih (consistent_revise hB l)

/-- Revision histories preserve finiteness. -/
theorem finite_reviseSeq {B : Set (Literal Atom)} (hB : B.Finite)
    (ls : List (Literal Atom)) : (reviseSeq B ls).Finite := by
  induction ls generalizing B with
  | nil => simpa using hB
  | cons l t ih => exact ih (finite_revise hB l)

end DreamLogic