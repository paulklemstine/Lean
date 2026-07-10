import Mathlib

/-!
# The topology of argumentation, I: Dung semantics and the defense operator

An *argumentation framework* (AF) in the sense of Dung is a pair `(A, R)` where
`A` is a set of *arguments* and `R : A → A → Prop` is an *attack relation*
(`R a b` reads "argument `a` attacks argument `b`").  We model an AF by a fixed
relation `R` on an arbitrary type `A`.

This file develops the classical acceptability semantics entirely from scratch:

* `ConflictFree S` — no argument of `S` attacks another argument of `S`.
* `Defends S a`   — every attacker of `a` is counter-attacked by some member of `S`.
* `charF S`       — the *characteristic (defense) operator*, `{a | S defends a}`.
* `Admissible S`  — `S` is conflict-free and defends each of its members.

The main results are:

* `admissible_iff`      — `S` is admissible iff conflict-free and `S ⊆ charF S`.
* `charF_mono`          — the defense operator is monotone.
* `conflictFree_charF`  — the defense operator *preserves* conflict-freeness.
* `conflictFree_subset` — conflict-free sets are downward closed (this is what
  makes the conflict-free sets a *simplicial complex*, developed in
  `ArgumentationSimplicial`).
* `fundamental_lemma`   — **Dung's Fundamental Lemma**: if `S` is admissible and
  defends `a`, then `insert a S` is again admissible.

These are the load-bearing lemmas for the theory of preferred and grounded
extensions in `ArgumentationExtensions`.
-/

namespace ArgTop

variable {A : Type*} (R : A → A → Prop)

/-- `S` is *conflict-free*: no argument in `S` attacks another argument in `S`. -/
def ConflictFree (S : Set A) : Prop := ∀ a ∈ S, ∀ b ∈ S, ¬ R a b

/-- `S` *defends* `a`: every attacker `b` of `a` is itself attacked by some
member `c` of `S`. -/
def Defends (S : Set A) (a : A) : Prop := ∀ b, R b a → ∃ c ∈ S, R c b

/-- `S` is *admissible*: it is conflict-free and defends each of its members. -/
def Admissible (S : Set A) : Prop := ConflictFree R S ∧ ∀ a ∈ S, Defends R S a

/-- The *characteristic operator* (Dung's `F`): `charF S` is the set of all
arguments defended by `S`. -/
def charF (S : Set A) : Set A := {a | Defends R S a}

@[simp] theorem mem_charF {S : Set A} {a : A} : a ∈ charF R S ↔ Defends R S a := Iff.rfl

/-- Admissibility is equivalent to conflict-freeness together with `S ⊆ charF S`:
an admissible set is a conflict-free set that is contained in its own set of
defended arguments. -/
theorem admissible_iff {S : Set A} :
    Admissible R S ↔ ConflictFree R S ∧ S ⊆ charF R S := by
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨h1, fun a ha => h2 a ha⟩
  · rintro ⟨h1, h2⟩; exact ⟨h1, fun a ha => h2 ha⟩

/-- Defense is monotone in the defending set. -/
theorem defends_mono {S T : Set A} (h : S ⊆ T) {a : A} (ha : Defends R S a) :
    Defends R T a := by
  intro b hb
  obtain ⟨c, hc, hcb⟩ := ha b hb
  exact ⟨c, h hc, hcb⟩

/-- The characteristic operator is monotone: larger sets defend more arguments. -/
theorem charF_mono {S T : Set A} (h : S ⊆ T) : charF R S ⊆ charF R T :=
  fun _ ha => defends_mono R h ha

/-- The empty set is conflict-free. -/
theorem conflictFree_empty : ConflictFree R (∅ : Set A) :=
  fun a ha => absurd ha (Set.notMem_empty a)

/-- The empty set is admissible. -/
theorem admissible_empty : Admissible R (∅ : Set A) :=
  ⟨conflictFree_empty R, fun a ha => absurd ha (Set.notMem_empty a)⟩

/-- **Conflict-free sets are downward closed.**  A subset of a conflict-free set
is conflict-free.  This is exactly the axiom that makes the family of
conflict-free sets an abstract simplicial complex on the vertex set `A`. -/
theorem conflictFree_subset {S T : Set A} (h : S ⊆ T) (hT : ConflictFree R T) :
    ConflictFree R S :=
  fun a ha b hb => hT a (h ha) b (h hb)

/-- The characteristic operator computed at `∅` is the set of *unattacked*
arguments. -/
theorem charF_empty : charF R (∅ : Set A) = {a | ∀ b, ¬ R b a} := by
  ext a
  constructor
  · intro ha b hba; obtain ⟨c, hc, _⟩ := ha b hba; exact absurd hc (Set.notMem_empty c)
  · intro ha b hba; exact absurd hba (ha b)

/-- **The defense operator preserves conflict-freeness** (unconditionally).  If
`S` is conflict-free then so is `charF S`.  This is the engine behind the
conflict-freeness of the grounded extension. -/
theorem conflictFree_charF {S : Set A} (hS : ConflictFree R S) :
    ConflictFree R (charF R S) := by
  intro a ha b hb hab
  -- `b ∈ charF S` defends `b`; since `a` attacks `b`, some `c ∈ S` attacks `a`.
  obtain ⟨c, hc, hca⟩ := hb a hab
  -- `a ∈ charF S` defends `a`; since `c` attacks `a`, some `d ∈ S` attacks `c`.
  obtain ⟨d, hd, hdc⟩ := ha c hca
  exact hS d hd c hc hdc

/-- **Dung's Fundamental Lemma.**  If `S` is admissible and `S` defends the
argument `a`, then `insert a S` is again admissible.  Consequently an admissible
set may be greedily extended by any argument it defends. -/
theorem fundamental_lemma {S : Set A} (hS : Admissible R S) {a : A}
    (ha : Defends R S a) : Admissible R (insert a S) := by
  obtain ⟨hcf, hdef⟩ := hS
  -- No member of `S` attacks `a`.
  have H1 : ∀ c ∈ S, ¬ R c a := fun c hc hca => by
    obtain ⟨d, hd, hdc⟩ := ha c hca; exact hcf d hd c hc hdc
  -- `a` attacks no member of `S`.
  have H2 : ∀ c ∈ S, ¬ R a c := fun c hc hac => by
    obtain ⟨d, hd, hda⟩ := hdef c hc a hac; exact H1 d hd hda
  -- `a` does not attack itself.
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

/-- A convenient packaged form of the Fundamental Lemma: if `S` is admissible and
`a ∈ charF S`, then `insert a S` is admissible and still contained in `charF`
of the enlarged set. -/
theorem admissible_insert_of_mem_charF {S : Set A} (hS : Admissible R S) {a : A}
    (ha : a ∈ charF R S) : Admissible R (insert a S) :=
  fundamental_lemma R hS ha

end ArgTop