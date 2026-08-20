import Catalog.Shared.DreamRevisionNormalForm

/-!
# The monoid of revision histories

`Catalog/Shared/DreamRevisionNormalForm.lean` proved that a finite revision history
`ls : List (Literal Atom)` acts on belief states by overwriting each atom it mentions with
the sign of that atom's *last* occurrence.  This file turns that normal-form theorem into a
complete algebraic description of the dynamics.

Write `record ls` for the last-occurrence record of `ls`, viewed as a finitely supported
partial sign assignment `Atom → Option Bool`.  Partial assignments carry an *override*
multiplication, `(f * g) a = (g a).or (f a)` ("do `f`, then `g`"), which makes
`PartialAssign Atom` a monoid, and `record` a surjective monoid homomorphism from the free
monoid of histories.

Main results:

* `PartialAssign` is a monoid (`instance : Monoid (PartialAssign Atom)`) which is a
  **right regular band**: `f * f = f` (`PartialAssign.mul_self`) and `f * g * f = g * f`
  (`PartialAssign.mul_mul_self`).  It is not commutative as soon as one atom is available
  (`PartialAssign.not_commutative`).
* `record_append` : `record (ls ++ ms) = record ls * record ms`, and `record_surjective`:
  every finitely supported partial assignment is the record of a history.
* `RevisionMonoid.equivPartialAssign` : the monoid of revision histories modulo
  extensional equivalence is **isomorphic** to `PartialAssign Atom`.  Combined with `act_record` and
  `act_injective` this says that `PartialAssign Atom` *is* the transformation monoid of the
  revision dynamics: the action on belief states is faithful.
* `PartialAssign.isUnit_iff` : the only invertible history is the empty one — the dynamics
  is purely irreversible.
* `PartialAssign.mul_eq_right_iff` : `f * g = g` exactly when `supp f ⊆ supp g`, and
  `PartialAssign.support_mul` : the support map is a homomorphism onto the semilattice of
  finite atom sets (the maximal semilattice image of the band).
* `PartialAssign.mul_comm_iff` : two histories commute exactly when their records are
  *compatible* on the atoms both mention.
* `normalForm_length_eq_card_support` and `normalForm_length_le` : the normal form of a
  history is a shortest history with the same effect, of length the number of atoms it
  mentions.
* `histEq_iff_perm_normalForm` : extensional equivalence of histories is decidable —
  compare normal forms up to permutation.
* `card_partialAssign` : over a finite atom set there are exactly `3 ^ n` distinct
  revision behaviours.
* `histEq_iff_lastSign` and `histEq_iff_reviseSeq` : the two local rewrite rules — swap
  adjacent revisions of distinct atoms, delete an immediately superseded revision — are a
  **complete** presentation of the monoid: two histories act alike on all belief states iff
  they are connected by finitely many such rewrites.
-/

namespace DreamLogic

variable {Atom : Type*}

/-! ## Last-occurrence records of concatenations -/

/-- Concatenating histories overrides the earlier record by the later one. -/
theorem lastSign_append [DecidableEq Atom] (ls ms : List (Literal Atom)) (a : Atom) :
    lastSign (ls ++ ms) a = (lastSign ms a).or (lastSign ls a) := by
  induction ls with
  | nil => cases h : lastSign ms a <;> simp [h]
  | cons l t ih =>
    simp only [List.cons_append, lastSign, ih]
    cases hms : lastSign ms a with
    | some s => simp
    | none => cases ht : lastSign t a <;> simp

/-! ## Finitely supported partial sign assignments -/

/-- A **partial sign assignment**: a partial function from atoms to signs with finite
domain.  This is the semantic content of a revision history — the record of which atoms it
touched and with which sign. -/
structure PartialAssign (Atom : Type*) where
  /-- The sign assigned to an atom, `none` if the atom is untouched. -/
  sign : Atom → Option Bool
  /-- Only finitely many atoms are touched. -/
  finite_support : {a | sign a ≠ none}.Finite

namespace PartialAssign

@[ext] theorem ext {f g : PartialAssign Atom} (h : ∀ a, f.sign a = g.sign a) : f = g := by
  obtain ⟨f, hf⟩ := f
  obtain ⟨g, hg⟩ := g
  have : f = g := funext h
  subst this
  rfl

/-- Override multiplication: `f * g` performs `f` first and then `g`, so `g` wins wherever
it is defined. -/
instance : Mul (PartialAssign Atom) where
  mul f g :=
    { sign := fun a => (g.sign a).or (f.sign a)
      finite_support := by
        refine (g.finite_support.union f.finite_support).subset ?_
        intro a ha
        simp only [Set.mem_setOf_eq, ne_eq, Option.or_eq_none_iff, not_and] at ha
        by_cases hg : g.sign a = none
        · exact Or.inr (by simpa [hg] using ha)
        · exact Or.inl hg }

@[simp] theorem mul_sign (f g : PartialAssign Atom) (a : Atom) :
    (f * g).sign a = (g.sign a).or (f.sign a) := rfl

/-- The empty history: no atom is touched. -/
instance : One (PartialAssign Atom) where
  one := { sign := fun _ => none, finite_support := by simp }

@[simp] theorem one_sign (a : Atom) : (1 : PartialAssign Atom).sign a = none := rfl

instance : Monoid (PartialAssign Atom) where
  mul_assoc f g h := by ext a; simp [Option.or_assoc]
  one_mul f := by ext a; simp
  mul_one f := by ext a; simp

/-! ### Band structure -/

/-- Repeating a history changes nothing: the monoid is idempotent. -/
@[simp] theorem mul_self (f : PartialAssign Atom) : f * f = f := by ext a; simp

/-- **Right regular band law.**  Performing `f`, then `g`, then `f` again has the same
effect as performing `g` and then `f`. -/
theorem mul_mul_self (f g : PartialAssign Atom) : f * g * f = g * f := by
  ext a
  cases hf : f.sign a <;> simp [hf]

/-- Two partial assignments commute exactly when they are *compatible*: they agree on every
atom that both of them touch. -/
theorem mul_comm_iff (f g : PartialAssign Atom) :
    f * g = g * f ↔ ∀ a s t, f.sign a = some s → g.sign a = some t → s = t := by
  constructor
  · intro h a s t hs ht
    have := congrArg (fun x => PartialAssign.sign x a) h
    simp [hs, ht] at this
    exact this.symm
  · intro h
    ext a
    cases hf : f.sign a with
    | none => simp [hf]
    | some s =>
      cases hg : g.sign a with
      | none => simp [hf, hg]
      | some t => simp [hf, hg, h a s t hf hg]

/-- The only invertible partial assignment is the empty one: revision is irreversible. -/
theorem isUnit_iff (f : PartialAssign Atom) : IsUnit f ↔ f = 1 := by
  constructor
  · rintro ⟨u, rfl⟩
    refine ext fun a => ?_
    have h := congrArg (fun x => PartialAssign.sign x a) u.mul_inv
    simp only [mul_sign, one_sign] at h
    exact (Option.or_eq_none_iff.1 h).2
  · rintro rfl
    exact isUnit_one

/-! ### Supports -/

/-- The finite set of atoms touched. -/
noncomputable def support (f : PartialAssign Atom) : Finset Atom := f.finite_support.toFinset

@[simp] theorem mem_support {f : PartialAssign Atom} {a : Atom} :
    a ∈ f.support ↔ f.sign a ≠ none := by
  simp [support]

/-- Supports add up under composition: the support map is a semilattice homomorphism. -/
theorem support_mul [DecidableEq Atom] (f g : PartialAssign Atom) :
    (f * g).support = f.support ∪ g.support := by
  ext a
  cases hf : f.sign a <;> cases hg : g.sign a <;> simp [hf, hg]

@[simp] theorem support_one : (1 : PartialAssign Atom).support = ∅ := by
  ext a; simp

/-- A later history absorbs an earlier one exactly when it touches at least as many
atoms. -/
theorem mul_eq_right_iff (f g : PartialAssign Atom) : f * g = g ↔ f.support ⊆ g.support := by
  constructor
  · intro h a ha
    have := congrArg (fun x => PartialAssign.sign x a) h
    simp only [mul_sign] at this
    rw [mem_support] at ha ⊢
    intro hg
    rw [hg] at this
    simp at this
    exact ha this
  · intro h
    ext a
    cases hg : g.sign a with
    | some s => simp [hg]
    | none =>
      have : a ∉ f.support := fun ha => by simpa [hg] using (mem_support.1 (h ha))
      simp [hg, not_not.1 (by simpa using this)]

end PartialAssign

/-! ## Single revisions and the record homomorphism -/

namespace PartialAssign

/-- The partial assignment produced by a single revision of atom `a` by sign `s`. -/
def single [DecidableEq Atom] (a : Atom) (s : Bool) : PartialAssign Atom where
  sign b := if b = a then some s else none
  finite_support := by
    refine (Set.finite_singleton a).subset ?_
    intro b hb
    by_cases h : b = a
    · exact h
    · simp [h] at hb

@[simp] theorem single_sign [DecidableEq Atom] (a b : Atom) (s : Bool) :
    (single a s).sign b = if b = a then some s else none := rfl

/-- Revision is genuinely order dependent: opposite revisions of one atom do not
commute, so the monoid is non-commutative whenever there is at least one atom. -/
theorem not_commutative [DecidableEq Atom] (a : Atom) :
    single a true * single a false ≠ single a false * single a true := by
  intro h
  have := congrArg (fun x => PartialAssign.sign x a) h
  simp at this

end PartialAssign

/-- The **last-occurrence record** of a revision history, as a finitely supported partial
sign assignment. -/
def record [DecidableEq Atom] (ls : List (Literal Atom)) : PartialAssign Atom where
  sign := lastSign ls
  finite_support := by
    refine ((ls.map Prod.fst).finite_toSet).subset ?_
    intro a ha
    simp only [Set.mem_setOf_eq, ne_eq] at ha
    obtain ⟨m, hm, hma⟩ : ∃ m ∈ ls, m.1 = a := by
      by_contra hcon
      exact ha ((lastSign_eq_none_iff ls a).2 (by
        intro m hm hma
        exact hcon ⟨m, hm, hma⟩))
    simpa using List.mem_map.2 ⟨m, hm, hma⟩

@[simp] theorem record_sign [DecidableEq Atom] (ls : List (Literal Atom)) (a : Atom) :
    (record ls).sign a = lastSign ls a := rfl

@[simp] theorem record_nil [DecidableEq Atom] :
    record ([] : List (Literal Atom)) = 1 := by
  refine PartialAssign.ext fun a => ?_
  simp

/-- **`record` is a monoid homomorphism**: running one history after another composes
their records by override. -/
theorem record_append [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    record (ls ++ ms) = record ls * record ms := by
  refine PartialAssign.ext fun a => ?_
  simp [lastSign_append]

@[simp] theorem record_singleton [DecidableEq Atom] (a : Atom) (s : Bool) :
    record [(a, s)] = PartialAssign.single a s := by
  refine PartialAssign.ext fun b => ?_
  simp only [record_sign, PartialAssign.single_sign, lastSign]
  by_cases h : b = a
  · simp [h]
  · simp [h, Ne.symm h]

/-- A canonical history realizing a prescribed record: revise each atom of the support
once, in some order. -/
noncomputable def ofAssign [DecidableEq Atom] (f : PartialAssign Atom) :
    List (Literal Atom) :=
  f.support.toList.map (fun a => (a, (f.sign a).getD false))

theorem ofAssign_atoms [DecidableEq Atom] (f : PartialAssign Atom) :
    (ofAssign f).map Prod.fst = f.support.toList := by
  simp [ofAssign, List.map_map, Function.comp_def]

theorem ofAssign_nodup_atoms [DecidableEq Atom] (f : PartialAssign Atom) :
    ((ofAssign f).map Prod.fst).Nodup := by
  rw [ofAssign_atoms]
  exact f.support.nodup_toList

/-- **Every finitely supported partial assignment is the record of a history**: `record`
is surjective. -/
@[simp] theorem record_ofAssign [DecidableEq Atom] (f : PartialAssign Atom) :
    record (ofAssign f) = f := by
  refine PartialAssign.ext fun a => ?_
  simp only [record_sign]
  cases hf : f.sign a with
  | none =>
    refine (lastSign_eq_none_iff _ a).2 ?_
    intro m hm hma
    obtain ⟨b, hb, rfl⟩ := List.mem_map.1 hm
    have : b ∈ f.support := Finset.mem_toList.1 hb
    rw [PartialAssign.mem_support] at this
    have hba : b = a := hma
    subst hba
    exact this hf
  | some s =>
    have hmem : (a, s) ∈ ofAssign f := by
      refine List.mem_map.2 ⟨a, ?_, ?_⟩
      · exact Finset.mem_toList.2 (PartialAssign.mem_support.2 (by simp [hf]))
      · simp [hf]
    exact (mem_iff_lastSign_of_nodup_atoms (ofAssign_nodup_atoms f) (a, s)).1 hmem

theorem record_surjective [DecidableEq Atom] (f : PartialAssign Atom) :
    ∃ ls : List (Literal Atom), record ls = f :=
  ⟨ofAssign f, record_ofAssign f⟩

/-! ## The monoid of revision histories -/

/-- Extensional equivalence of revision histories: same last-occurrence record.  By
`reviseSeq_ext_iff` this is exactly the relation "act identically on every belief
state". -/
def histSetoid (Atom : Type*) [DecidableEq Atom] : Setoid (List (Literal Atom)) where
  r ls ms := ∀ a, lastSign ls a = lastSign ms a
  iseqv := ⟨fun _ _ => rfl, fun h a => (h a).symm, fun h₁ h₂ a => (h₁ a).trans (h₂ a)⟩

/-- The monoid of revision histories modulo extensional equivalence, with concatenation
as multiplication. -/
def RevisionMonoid (Atom : Type*) [DecidableEq Atom] := Quotient (histSetoid Atom)

namespace RevisionMonoid

variable [DecidableEq Atom]

/-- The extensional class of a revision history. -/
def mk (ls : List (Literal Atom)) : RevisionMonoid Atom := Quotient.mk (histSetoid Atom) ls

theorem mk_eq_mk {ls ms : List (Literal Atom)} :
    mk ls = mk ms ↔ ∀ a, lastSign ls a = lastSign ms a := Quotient.eq

instance : Mul (RevisionMonoid Atom) :=
  ⟨Quotient.map₂ (· ++ ·) (by
    intro ls ls' h ms ms' h' a
    simp [lastSign_append, h a, h' a])⟩

instance : One (RevisionMonoid Atom) := ⟨mk []⟩

@[simp] theorem mk_mul (ls ms : List (Literal Atom)) :
    mk ls * mk ms = mk (ls ++ ms) := rfl

@[simp] theorem mk_nil : mk ([] : List (Literal Atom)) = 1 := rfl

instance : Monoid (RevisionMonoid Atom) where
  mul_assoc a b c := by
    refine Quotient.inductionOn₃ a b c fun ls ms ns => ?_
    show mk (ls ++ ms ++ ns) = mk (ls ++ (ms ++ ns))
    rw [List.append_assoc]
  one_mul a := by
    refine Quotient.inductionOn a fun ls => ?_
    show mk ([] ++ ls) = mk ls
    rw [List.nil_append]
  mul_one a := by
    refine Quotient.inductionOn a fun ls => ?_
    show mk (ls ++ []) = mk ls
    rw [List.append_nil]

/-- **Structure theorem for revision histories.**  The monoid of finite revision histories
modulo extensional equivalence is isomorphic to the monoid of finitely supported partial
sign assignments under override. -/
noncomputable def equivPartialAssign : RevisionMonoid Atom ≃* PartialAssign Atom where
  toFun := Quotient.lift record fun _ _ h => PartialAssign.ext h
  invFun f := mk (ofAssign f)
  left_inv := by
    refine Quotient.ind fun ls => ?_
    refine mk_eq_mk.2 fun a => ?_
    exact congrArg (fun f : PartialAssign Atom => f.sign a) (record_ofAssign (record ls))
  right_inv f := record_ofAssign f
  map_mul' := by
    refine Quotient.ind₂ fun ls ms => ?_
    exact record_append ls ms

@[simp] theorem equivPartialAssign_mk (ls : List (Literal Atom)) :
    equivPartialAssign (mk ls) = record ls := rfl

end RevisionMonoid

/-! ## The faithful action on belief states -/

/-- The state transformation induced by a record: overwrite the atoms of the support with
their recorded signs and leave every other atom untouched. -/
def act (f : PartialAssign Atom) (B : Set (Literal Atom)) : Set (Literal Atom) :=
  {p : Literal Atom | f.sign p.1 = some p.2} ∪ {p | f.sign p.1 = none ∧ p ∈ B}

/-- The record of a history computes its action: this is the normal-form theorem
`mem_reviseSeq` in algebraic dress. -/
theorem act_record [DecidableEq Atom] (B : Set (Literal Atom)) (ls : List (Literal Atom)) :
    act (record ls) B = reviseSeq B ls := (reviseSeq_eq B ls).symm

@[simp] theorem act_one (B : Set (Literal Atom)) : act (1 : PartialAssign Atom) B = B := by
  ext p; simp [act]

/-- The action is a right action of the monoid of records. -/
theorem act_mul (f g : PartialAssign Atom) (B : Set (Literal Atom)) :
    act (f * g) B = act g (act f B) := by
  ext p
  cases hg : g.sign p.1 <;> cases hf : f.sign p.1 <;> simp [act, hf, hg]

/-- **Faithfulness.**  Distinct records induce distinct state transformations; in fact the
action on the empty state already separates them. -/
theorem act_injective {f g : PartialAssign Atom} (h : ∀ B, act f B = act g B) : f = g := by
  refine PartialAssign.ext fun a => ?_
  have key : ∀ s : Bool, f.sign a = some s ↔ g.sign a = some s := by
    intro s
    have := Set.ext_iff.1 (h ∅) (a, s)
    simpa [act] using this
  cases hf : f.sign a with
  | none =>
    cases hg : g.sign a with
    | none => rfl
    | some t => exact absurd ((key t).2 hg) (by simp [hf])
  | some s => rw [(key s).1 hf]

/-- Two histories act identically on all states exactly when they have the same record;
so `RevisionMonoid Atom` really is the transformation monoid of revision. -/
theorem reviseSeq_ext_iff_record [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    (∀ B : Set (Literal Atom), reviseSeq B ls = reviseSeq B ms) ↔ record ls = record ms := by
  constructor
  · intro h
    refine act_injective fun B => ?_
    rw [act_record, act_record, h B]
  · intro h B
    rw [← act_record, ← act_record, h]

/-! ## Shortest histories -/

/-- The support of the record is the set of atoms the history mentions. -/
theorem support_record [DecidableEq Atom] (ls : List (Literal Atom)) :
    (record ls).support = (ls.map Prod.fst).toFinset := by
  ext a
  simp only [PartialAssign.mem_support, record_sign, List.mem_toFinset, List.mem_map, ne_eq]
  constructor
  · intro h
    by_contra hcon
    exact h ((lastSign_eq_none_iff ls a).2 fun m hm hma => hcon ⟨m, hm, hma⟩)
  · rintro ⟨m, hm, hma⟩ hnone
    exact (lastSign_eq_none_iff ls a).1 hnone m hm hma

/-- A history is at least as long as the number of atoms it mentions. -/
theorem card_support_le_length [DecidableEq Atom] (ls : List (Literal Atom)) :
    (record ls).support.card ≤ ls.length := by
  rw [support_record]
  calc (ls.map Prod.fst).toFinset.card ≤ (ls.map Prod.fst).length := List.toFinset_card_le _
    _ = ls.length := by simp

/-- The normal form of a history has length exactly the number of atoms mentioned. -/
theorem normalForm_length_eq_card_support [DecidableEq Atom] (ls : List (Literal Atom)) :
    (normalForm ls).length = (record ls).support.card := by
  have hrec : record ls = record (normalForm ls) :=
    PartialAssign.ext fun a => (lastSign_normalForm ls a).symm
  rw [hrec, support_record, List.toFinset_card_of_nodup (normalForm_nodup_atoms ls),
    List.length_map]

/-- **The normal form is a shortest history with the given effect.**  Any history with the
same last-occurrence record is at least as long as the normal form. -/
theorem normalForm_length_le [DecidableEq Atom] {ls ms : List (Literal Atom)}
    (h : ∀ a, lastSign ms a = lastSign ls a) : (normalForm ls).length ≤ ms.length := by
  have hrec : record ms = record ls := PartialAssign.ext h
  calc (normalForm ls).length = (record ls).support.card :=
        normalForm_length_eq_card_support ls
    _ = (record ms).support.card := by rw [hrec]
    _ ≤ ms.length := card_support_le_length ms

/-! ## Counting revision behaviours -/

/-- Over a finite set of atoms every partial assignment is finitely supported. -/
noncomputable def partialAssignEquivFun [Finite Atom] :
    PartialAssign Atom ≃ (Atom → Option Bool) where
  toFun f := f.sign
  invFun g := ⟨g, Set.toFinite _⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **Counting.**  With `n` atoms there are exactly `3 ^ n` distinct revision behaviours:
each atom is left untouched, set positive, or set negative. -/
theorem card_partialAssign [Fintype Atom] [DecidableEq Atom] :
    Nat.card (PartialAssign Atom) = 3 ^ Fintype.card Atom := by
  rw [Nat.card_congr partialAssignEquivFun, Nat.card_eq_fintype_card, Fintype.card_fun]
  norm_num

/-! ## A complete presentation by two local rewrite rules

`revise_comm_of_ne_atom` and `revise_revise_of_eq_atom` are the two local rules governing
revision.  The theorems below show that they are not merely *sound* but **complete**: two
histories act identically on all belief states if and only if one can be transformed into
the other by finitely many applications of

* *swap*   : exchange two adjacent revisions of distinct atoms, and
* *absorb* : delete a revision immediately superseded by a revision of the same atom.

Equivalently, `RevisionMonoid Atom` is the monoid presented by the literals subject to
these two families of relations. -/

/-- The congruence generated by the two local rewrite rules on revision histories. -/
inductive HistEq {Atom : Type*} : List (Literal Atom) → List (Literal Atom) → Prop
  | swap (pre : List (Literal Atom)) (l k : Literal Atom) (post : List (Literal Atom)) :
      l.1 ≠ k.1 → HistEq (pre ++ l :: k :: post) (pre ++ k :: l :: post)
  | absorb (pre : List (Literal Atom)) (l k : Literal Atom) (post : List (Literal Atom)) :
      l.1 = k.1 → HistEq (pre ++ l :: k :: post) (pre ++ k :: post)
  | refl (ls : List (Literal Atom)) : HistEq ls ls
  | symm {ls ms : List (Literal Atom)} : HistEq ls ms → HistEq ms ls
  | trans {ls ms ns : List (Literal Atom)} : HistEq ls ms → HistEq ms ns → HistEq ls ns

namespace HistEq

/-- The rewriting congruence is compatible with prefixing a revision. -/
theorem cons {Atom : Type*} (l : Literal Atom) {t t' : List (Literal Atom)}
    (h : HistEq t t') : HistEq (l :: t) (l :: t') := by
  induction h with
  | swap pre a b post hab => simpa using HistEq.swap (l :: pre) a b post hab
  | absorb pre a b post hab => simpa using HistEq.absorb (l :: pre) a b post hab
  | refl _ => exact HistEq.refl _
  | symm _ ih => exact ih.symm
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- A revision whose atom is revised again later can be deleted outright. -/
theorem cons_of_mem_atom {Atom : Type*} {l : Literal Atom} :
    ∀ {t : List (Literal Atom)}, (∃ m ∈ t, m.1 = l.1) → HistEq (l :: t) t
  | [], h => by simp at h
  | k :: t', h => by
      by_cases hk : l.1 = k.1
      · simpa using HistEq.absorb [] l k t' hk
      · obtain ⟨m, hm, hml⟩ := h
        have hm' : m ∈ t' := by
          rcases List.mem_cons.1 hm with rfl | hm'
          · exact absurd hml.symm hk
          · exact hm'
        have h1 : HistEq (l :: k :: t') (k :: l :: t') := by
          simpa using HistEq.swap [] l k t' hk
        exact h1.trans (HistEq.cons k (cons_of_mem_atom ⟨m, hm', hml⟩))

end HistEq

/-- Unfolding of `lastSign` on a cons, in terms of `Option.or`. -/
theorem lastSign_cons' [DecidableEq Atom] (l : Literal Atom) (t : List (Literal Atom))
    (a : Atom) :
    lastSign (l :: t) a = (lastSign t a).or (if l.1 = a then some l.2 else none) := by
  simp only [lastSign]
  cases lastSign t a <;> simp

/-- **Soundness of the two local rules**: they preserve the last-occurrence record. -/
theorem HistEq.lastSign_eq [DecidableEq Atom] {ls ms : List (Literal Atom)}
    (h : HistEq ls ms) (a : Atom) : lastSign ls a = lastSign ms a := by
  induction h with
  | swap pre l k post hlk =>
      rw [lastSign_append, lastSign_append]
      congr 1
      rw [lastSign_cons', lastSign_cons', lastSign_cons', lastSign_cons']
      rcases eq_or_ne l.1 a with hl | hl
      · rcases eq_or_ne k.1 a with hk | hk
        · exact absurd (hl.trans hk.symm) hlk
        · simp [hk]
      · simp [hl]
  | absorb pre l k post hlk =>
      rw [lastSign_append, lastSign_append]
      congr 1
      rw [lastSign_cons', lastSign_cons']
      rcases eq_or_ne k.1 a with hk | hk
      · have hl : l.1 = a := hlk.trans hk
        cases hP : lastSign post a <;> simp [hk, hl]
      · have hl : l.1 ≠ a := fun h' => hk (hlk.symm.trans h')
        simp [hk, hl]
  | refl _ => rfl
  | symm _ ih => exact (ih).symm
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- Histories mentioning each atom at most once may be reordered arbitrarily by swaps. -/
theorem histEq_of_perm {Atom : Type*} {ls ms : List (Literal Atom)} (h : ls.Perm ms) :
    (ls.map Prod.fst).Nodup → HistEq ls ms := by
  induction h with
  | nil => intro _; exact HistEq.refl _
  | cons x _ ih =>
      intro hnd
      simp only [List.map_cons, List.nodup_cons] at hnd
      exact HistEq.cons x (ih hnd.2)
  | swap x y l =>
      intro hnd
      simp only [List.map_cons, List.nodup_cons, List.mem_cons] at hnd
      have hxy : y.1 ≠ x.1 := fun hy => hnd.1 (Or.inl hy)
      simpa using HistEq.swap [] y x l hxy
  | trans h₁ _ ih₁ ih₂ =>
      intro hnd
      exact (ih₁ hnd).trans (ih₂ ((h₁.map Prod.fst).nodup_iff.1 hnd))

/-- Every history rewrites to its normal form. -/
theorem histEq_normalForm [DecidableEq Atom] (ls : List (Literal Atom)) :
    HistEq ls (normalForm ls) := by
  induction ls with
  | nil => exact HistEq.refl _
  | cons l t ih =>
      simp only [normalForm]
      by_cases hany : t.any (fun m => m.1 = l.1)
      · rw [if_pos hany]
        obtain ⟨m, hm, hm2⟩ := List.any_eq_true.1 hany
        exact (HistEq.cons_of_mem_atom ⟨m, hm, by simpa using hm2⟩).trans ih
      · rw [if_neg hany]
        exact HistEq.cons l ih

/-- **Completeness of the two local rules.**  Two revision histories have the same
last-occurrence record if and only if they are connected by swaps of adjacent revisions of
distinct atoms and deletions of immediately superseded revisions.  Thus the local theory of
revision determines its global theory. -/
theorem histEq_iff_lastSign [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    HistEq ls ms ↔ ∀ a, lastSign ls a = lastSign ms a := by
  constructor
  · intro h a
    exact h.lastSign_eq a
  · intro h
    have h1 : HistEq ls (normalForm ls) := histEq_normalForm ls
    have h2 : HistEq ms (normalForm ms) := histEq_normalForm ms
    have hperm : (normalForm ms).Perm (normalForm ls) :=
      normalForm_unique (normalForm_nodup_atoms ms)
        (fun a => (lastSign_normalForm ms a).trans (h a).symm)
    have h3 : HistEq (normalForm ms) (normalForm ls) :=
      histEq_of_perm hperm (normalForm_nodup_atoms ms)
    exact h1.trans (h3.symm.trans h2.symm)

/-- The rewriting congruence, the equality of records, and the equality of actions on all
belief states are one and the same relation. -/
theorem histEq_iff_reviseSeq [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    HistEq ls ms ↔ ∀ B : Set (Literal Atom), reviseSeq B ls = reviseSeq B ms := by
  rw [histEq_iff_lastSign, ← reviseSeq_ext_iff]

/-! ## The band structure, back in the monoid of histories -/

namespace RevisionMonoid

variable [DecidableEq Atom]

/-- Repeating a history has no further effect. -/
theorem mul_self (x : RevisionMonoid Atom) : x * x = x :=
  equivPartialAssign.injective (by rw [map_mul, PartialAssign.mul_self])

/-- Concretely: performing a history twice in a row is extensionally the same as
performing it once. -/
theorem mk_append_self (ls : List (Literal Atom)) : mk (ls ++ ls) = mk ls := by
  simpa using mul_self (mk ls)

/-- **Right regular band law** for revision histories. -/
theorem mul_mul_self (x y : RevisionMonoid Atom) : x * y * x = y * x :=
  equivPartialAssign.injective (by
    rw [map_mul, map_mul, map_mul, PartialAssign.mul_mul_self])

/-- Only the empty history is invertible: no history can be undone by another. -/
theorem isUnit_iff (x : RevisionMonoid Atom) : IsUnit x ↔ x = 1 := by
  constructor
  · intro h
    have h1 : IsUnit (equivPartialAssign x) := h.map equivPartialAssign
    have h2 : equivPartialAssign x = 1 := (PartialAssign.isUnit_iff _).1 h1
    exact equivPartialAssign.injective (by rw [h2, map_one])
  · rintro rfl
    exact isUnit_one

end RevisionMonoid

/-! ## Fibres of the support map, decidability, and reachability -/

namespace PartialAssign

/-- Records touching the same atoms absorb one another: each fibre of `support` is a right
zero semigroup, so `PartialAssign Atom` is a semilattice of right zero bands indexed by the
finite sets of atoms. -/
theorem mul_eq_right_of_support_eq [DecidableEq Atom] {f g : PartialAssign Atom}
    (h : f.support = g.support) : f * g = g :=
  (mul_eq_right_iff f g).2 (le_of_eq h)

/-- Two records absorb each other exactly when they touch the same atoms. -/
theorem mul_eq_right_and_iff [DecidableEq Atom] (f g : PartialAssign Atom) :
    (f * g = g ∧ g * f = f) ↔ f.support = g.support := by
  constructor
  · rintro ⟨h₁, h₂⟩
    exact Finset.Subset.antisymm ((mul_eq_right_iff f g).1 h₁) ((mul_eq_right_iff g f).1 h₂)
  · intro h
    exact ⟨mul_eq_right_of_support_eq h, mul_eq_right_of_support_eq h.symm⟩

end PartialAssign

/-- **Decision procedure.**  Two histories are related by the local rewrite rules exactly
when their normal forms are permutations of one another; since normal forms are computable,
extensional equivalence of histories is decidable. -/
theorem histEq_iff_perm_normalForm [DecidableEq Atom] (ls ms : List (Literal Atom)) :
    HistEq ls ms ↔ (normalForm ls).Perm (normalForm ms) := by
  constructor
  · intro h
    exact normalForm_unique (normalForm_nodup_atoms ls)
      (fun a => (lastSign_normalForm ls a).trans (h.lastSign_eq a))
  · intro h
    exact ((histEq_normalForm ls).trans
      (histEq_of_perm h (normalForm_nodup_atoms ls))).trans (histEq_normalForm ms).symm

instance RevisionMonoid.instDecidableEq [DecidableEq Atom] :
    DecidableEq (RevisionMonoid Atom) := fun x y =>
  Quotient.recOnSubsingleton₂ x y fun ls ms =>
    decidable_of_iff ((normalForm ls).Perm (normalForm ms))
      (by
        rw [← histEq_iff_perm_normalForm, histEq_iff_lastSign]
        exact (RevisionMonoid.mk_eq_mk).symm)

/-- **Reachability is realized by records.**  A state is reachable from `B` by some
revision history exactly when it is the image of `B` under some finitely supported partial
assignment. -/
theorem reachable_iff_act [DecidableEq Atom] (B C : Set (Literal Atom)) :
    Reachable B C ↔ ∃ f : PartialAssign Atom, act f B = C := by
  constructor
  · rintro ⟨ls, rfl⟩
    exact ⟨record ls, act_record B ls⟩
  · rintro ⟨f, rfl⟩
    exact ⟨ofAssign f, by rw [← act_record B (ofAssign f), record_ofAssign]⟩

end DreamLogic