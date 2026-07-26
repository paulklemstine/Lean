/-
# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

A *tangled hierarchy* (Hofstadter's "strange loop") arises whenever a formal
system contains, inside itself, a predicate describing its own semantic status —
its **truth** or **soundness**.  This file constructs the order-free semantic core
of that phenomenon and proves, in a self-contained chain, that such tangles are
*unavoidable*: the moment a self-referential system can name its own soundness, a
contradiction (the Liar) is forced.

The results are built as a chain, each using the previous one:

* **`not_iff_not_self`** — the logical seed: no proposition equals its own negation.
* **`no_self_negation`, `no_liar_via_negation`** — a two-valued semantics with an
  internal negation has no Liar sentence.
* **`no_semantic_fixed_points`** — hence *full* semantic self-reference (a diagonal
  for every function) is impossible; unrestricted tangling is inconsistent.
* **`tarski_undefinability`** — Tarski's theorem: a self-referential language cannot
  contain a truth/soundness predicate satisfying the disquotation schema.  A
  companion lemma exhibits the remaining hypotheses as *satisfiable*, so the
  impossibility pins the blame precisely on the internal soundness predicate.
* **`ProofSystem`** — a system carrying external truth, internal derivability
  `Prov`, an internal provability predicate `box`, soundness, and a Gödel fixed
  point.  `exampleSystem` inhabits it, so nothing below is vacuous.
* **`godel_true_unprovable`, `godel_incompleteness`** — the Gödel sentence, which
  references its own unprovability, is *true but unprovable*; soundness is exactly
  what forces its truth.  A sound self-referential system is incomplete.
* **`soundness_predicate_not_internal`** — the capstone: in *any* proof system, an
  internal soundness predicate obeying the disquotation schema, together with the
  diagonal lemma, is contradictory.  The soundness predicate cannot consistently
  live inside the system it validates: the tangle is unavoidable.
-/

import Mathlib

namespace TangledSoundness

/-! ## Part 0 — The logical seed -/

/-- No proposition is equivalent to its own negation.  This is the pure-logic core
of every self-reference paradox below. -/
theorem not_iff_not_self {P : Prop} : ¬ (P ↔ ¬ P) := by tauto

/-! ## Part 1 — Languages and the Liar -/

/-- A **language**: a type of sentences with a semantic truth predicate `Truth` and
an internal `neg` that acts as negation on truth values. -/
structure Language where
  /-- The sentences of the language. -/
  Sent : Type
  /-- The external (meta-level) semantics: which sentences are true. -/
  Truth : Sent → Prop
  /-- Internal negation. -/
  neg : Sent → Sent
  /-- `neg` behaves like negation on truth values. -/
  neg_truth : ∀ s, Truth (neg s) ↔ ¬ Truth s

variable (L : Language)

/-- No sentence is true exactly when its own negation is: the local Liar is barred. -/
theorem no_self_negation (s : L.Sent) : ¬ (L.Truth s ↔ L.Truth (L.neg s)) := by
  rw [L.neg_truth]; exact not_iff_not_self

/-- **No Liar sentence.**  A two-valued semantics with internal negation contains no
sentence equivalent to the truth of its own negation. -/
theorem no_liar_via_negation : ¬ ∃ d, L.Truth d ↔ L.Truth (L.neg d) := by
  rintro ⟨d, hd⟩
  exact no_self_negation L d hd

/-- **Full self-reference is impossible.**  No language has a semantic diagonal
for *every* function `f`: applying it to `neg` would manufacture the Liar.  This is
the precise sense in which an *unrestricted* tangled hierarchy is inconsistent. -/
theorem no_semantic_fixed_points :
    ¬ (∀ f : L.Sent → L.Sent, ∃ d, L.Truth d ↔ L.Truth (f d)) := by
  intro hfix
  exact no_liar_via_negation L (hfix L.neg)

/-! ## Part 2 — Tarski: the soundness predicate is not internal -/

/-- **Tarski's undefinability of truth/soundness.**  A language with internal
negation cannot contain a predicate `T` (read: "… is true", i.e. the internal
*soundness* reflection) satisfying the disquotation schema `Truth (T s) ↔ Truth s`
*and* provide the diagonal lemma applied to `neg ∘ T`.  The three ingredients — a
two-valued negation, an internal soundness predicate, and self-reference — cannot
coexist.

The `diag` hypothesis is exactly the instance of the diagonal lemma that a genuinely
self-referential system provides (a sentence asserting its own `¬T`). -/
theorem tarski_undefinability
    {S : Type} (Truth : S → Prop) (neg T : S → S)
    (neg_truth : ∀ s, Truth (neg s) ↔ ¬ Truth s)
    (T_truth : ∀ s, Truth (T s) ↔ Truth s)
    (diag : ∃ L, Truth L ↔ Truth (neg (T L))) : False := by
  obtain ⟨Lw, hL⟩ := diag
  rw [neg_truth, T_truth] at hL
  exact not_iff_not_self hL

/-- **Non-vacuity of Tarski.**  Every hypothesis of `tarski_undefinability` *except*
the disquotation schema `T_truth` is jointly satisfiable.  Thus the impossibility is
genuinely caused by internalizing soundness, not by an unsatisfiable side condition:
here `Bool` with `T` the constant `false` satisfies `neg_truth` and the diagonal, yet
fails `T_truth`. -/
theorem tarski_hypotheses_satisfiable_without_truth_predicate :
    ∃ (S : Type) (Truth : S → Prop) (neg T : S → S),
      (∀ s, Truth (neg s) ↔ ¬ Truth s) ∧
      (∃ L, Truth L ↔ Truth (neg (T L))) := by
  refine ⟨Bool, fun b => b = true, fun b => !b, fun _ => false, ?_, ?_⟩
  · intro s; cases s <;> simp
  · exact ⟨true, by simp⟩

/-! ## Part 3 — A proof system with an internal provability predicate -/

/-- A **proof system**: sentences with external truth semantics, an internal
derivability predicate `Prov`, negation, an internal provability predicate `box`
(`box s` is the sentence "s is provable"), the assumption that the system is
**sound**, and a **Gödel fixed point** — a sentence asserting its own unprovability. -/
structure ProofSystem where
  /-- The sentences. -/
  Sent : Type
  /-- External semantics. -/
  Truth : Sent → Prop
  /-- Internal derivability. -/
  Prov : Sent → Prop
  /-- Internal negation. -/
  neg : Sent → Sent
  /-- Internal provability predicate: `box s` is the sentence "s is provable". -/
  box : Sent → Sent
  /-- `neg` negates truth values. -/
  neg_truth : ∀ s, Truth (neg s) ↔ ¬ Truth s
  /-- `box` correctly internalizes provability (provability *is* representable). -/
  box_truth : ∀ s, Truth (box s) ↔ Prov s
  /-- The system is sound: everything provable is true. -/
  sound : ∀ s, Prov s → Truth s
  /-- The Gödel diagonal: a sentence true exactly when it is not provable. -/
  godel : ∃ G, Truth G ↔ ¬ Prov G

/-- The trivial system in which nothing is provable inhabits `ProofSystem`, so the
results about `ProofSystem` are not vacuous. -/
def exampleSystem : ProofSystem where
  Sent := Prop
  Truth := id
  Prov := fun _ => False
  neg := Not
  box := fun _ => False
  neg_truth := fun _ => Iff.rfl
  box_truth := fun _ => Iff.rfl
  sound := fun _ h => h.elim
  godel := ⟨True, by simp⟩

/-- **The Gödel sentence is true but unprovable.**  It references its own
unprovability, and soundness is exactly what forces its truth. -/
theorem godel_true_unprovable (P : ProofSystem) :
    ∃ G, P.Truth G ∧ ¬ P.Prov G := by
  obtain ⟨G, hG⟩ := P.godel
  have hnp : ¬ P.Prov G := fun hp => (hG.mp (P.sound G hp)) hp
  exact ⟨G, hG.mpr hnp, hnp⟩

/-- **Incompleteness.**  A sound, self-referential proof system is not complete:
some true sentence is unprovable. -/
theorem godel_incompleteness (P : ProofSystem) :
    ¬ (∀ s, P.Truth s → P.Prov s) := by
  intro hcomplete
  obtain ⟨G, hT, hnp⟩ := godel_true_unprovable P
  exact hnp (hcomplete G hT)

/-! ## Part 4 — Capstone: the soundness predicate cannot be internal -/

/-- **The tangle is unavoidable.**  In *any* proof system, an internal soundness
predicate `T` obeying the disquotation schema `Truth (T s) ↔ Truth s`, together with
the diagonal lemma applied to `neg ∘ T`, is contradictory.  A system that can
reference its own soundness inside itself, while remaining self-referential, is
inconsistent: the soundness predicate cannot live inside the system it validates.

This is `tarski_undefinability` specialized to the truth/negation of a `ProofSystem`,
tying the abstract undefinability theorem to the concrete self-referential setting. -/
theorem soundness_predicate_not_internal (P : ProofSystem)
    (T : P.Sent → P.Sent)
    (T_sound : ∀ s, P.Truth (T s) ↔ P.Truth s)
    (diag : ∃ L, P.Truth L ↔ P.Truth (P.neg (T L))) : False :=
  tarski_undefinability P.Truth P.neg T P.neg_truth T_sound diag

end TangledSoundness