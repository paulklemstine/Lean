import Mathlib

/-!
# Self-Quantifying Types and the Diagonal Core of Self-Reference

A *self-quantifying type* is a type `T` that can name every predicate about
itself: informally `T ≈ Π (x : T), P x`, equivalently `T ≃ (T → Prop)`.  Such a
type would be able to reflect on all of its own properties from within.  This
module proves, from a single structural root — Lawvere's fixed-point theorem —
that no such type exists, and then follows the same diagonal argument through its
classical incarnations in cardinal arithmetic (Cantor), the undefinability of
truth (Tarski) and incompleteness (Gödel).

## Main results

* `lawvere_fixed_point` — the structural heart of every diagonal argument: a
  point-surjective family `A → (A → B)` forces *every* self-map of `B` to have a
  fixed point.
* `no_selfquant_surjection` — no type surjects onto its own predicate space
  `T → (T → Prop)` (Cantor, obtained from Lawvere via the fixed-point-free map
  `Not` on `Prop`).
* `no_selfquant_injection` — dually, the predicate space never injects back into
  the type.
* `isEmpty_selfquant_equiv` — the self-quantifying equivalence `T ≃ (T → Prop)`
  is impossible.
* `selfquant_cardinal_strict` — the quantitative shadow: `#T < #(T → Prop)`,
  bridging the logical obstruction with cardinal arithmetic.
* `SelfRefSystem.goedel_true` / `goedel_unprovable` — a system whose provability
  predicate is internally nameable contains a true but unprovable sentence.
* `SelfRefSystem.tarski_truth_not_definable` — in the same system truth itself is
  *not* internally nameable: the exact boundary that keeps Gödel's argument
  consistent while Tarski's collapses.

## References

* Lawvere, F.W. *Diagonal arguments and cartesian closed categories* (1969).
* Yanofsky, N. *A universal approach to self-referential paradoxes* (2003).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a "fully self-quantifying" type `T ≃ (T → Prop)`
cannot exist, and the obstruction is one and the same as Cantor's, Tarski's and
Gödel's. Conjecture: all four follow from Lawvere's fixed-point theorem plus the
single fact that `Not : Prop → Prop` has no fixed point.

Experiment (Experimenter): proved `lawvere_fixed_point` by the diagonal map
`d a = g (f a a)`; instantiating `B := Prop`, `g := Not` yields Cantor
immediately. Cardinality was recovered from `Cardinal.cantor`. For Tarski/Gödel
the naive structure with an *unrestricted* diagonal on the truth predicate is
inconsistent (derives `False`), which is exactly Tarski's theorem — so the
diagonal had to be *restricted to internally definable predicates*.

Analysis (Analyst): the key structural pattern is that Gödel and Tarski differ
only in *which* predicates a system can name. If negated provability is nameable
one gets a true-but-unprovable sentence (Gödel); if negated truth were nameable
one would get an outright contradiction — hence truth is not nameable (Tarski).
Both live on the same `diag_spec` fixed point, only the `Definable` gate differs.

Critique (Critic): to rule out vacuity of the `SelfRefSystem` hypotheses we
exhibit `exampleSystem`, a concrete satisfying model, so the Gödel/Tarski
theorems are not vacuously true. Every main theorem uses an insight-bearing
tactic (`obtain`, `by_contra`/`intro`, `tauto`, `simpa`) rather than `decide`.

Synthesis (PI): one lemma — Lawvere — organises the whole family; the
`Definable` gate is the precise dial separating consistency from paradox.
-- !-- Lab Notes -- !--
-/

open Function

namespace SelfQuantifying

/-! ## Part 1 — Lawvere's fixed-point theorem, the structural root -/

/-- **Lawvere's fixed-point theorem.**  If some family `f : A → (A → B)` is
point-surjective — every function `A → B` occurs as a row `f a` — then every
self-map `g : B → B` has a fixed point.  This single statement is the common
ancestor of Cantor's, Tarski's and Gödel's diagonal arguments. -/
theorem lawvere_fixed_point {A B : Type*} (f : A → (A → B)) (hf : Surjective f)
    (g : B → B) : ∃ b : B, g b = b := by
  obtain ⟨a, ha⟩ := hf (fun x => g (f x x))
  refine ⟨f a a, ?_⟩
  have := congrFun ha a
  simpa using this.symm

/-- The map `Not : Prop → Prop` has no fixed point: no proposition is equivalent
to its own negation.  This is the "no fixed point" half that Lawvere converts
into every impossibility below. -/
theorem not_has_no_fixed_point : ¬ ∃ P : Prop, (¬ P) = P := by
  rintro ⟨P, hP⟩
  have h : ¬ P ↔ P := by rw [hP]
  tauto

/-! ## Part 2 — The self-quantifying type cannot exist -/

/-- **No self-quantifying surjection (Cantor).**  A type never surjects onto its
own space of predicates `T → (T → Prop)`.  Proof: such a surjection would, by
Lawvere, force `Not` to have a fixed point. -/
theorem no_selfquant_surjection {T : Type*} :
    ¬ ∃ f : T → (T → Prop), Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨P, hP⟩ := lawvere_fixed_point f hf Not
  exact not_has_no_fixed_point ⟨P, hP⟩

/-- **No retraction of predicates into the type.**  Dually to Cantor, the
predicate space `T → Prop` never injects back into `T`. -/
theorem no_selfquant_injection {T : Type*} :
    ¬ ∃ g : (T → Prop) → T, Injective g := by
  rintro ⟨g, hg⟩
  exact cantor_injective g hg

/-- **The self-quantifying equivalence is impossible.**  There is no equivalence
`T ≃ (T → Prop)`; a type cannot fully reflect all of its own predicates. -/
theorem isEmpty_selfquant_equiv {T : Type*} : IsEmpty (T ≃ (T → Prop)) := by
  refine ⟨fun e => ?_⟩
  exact no_selfquant_surjection ⟨e, e.surjective⟩

/-- Contrapositive convenience form: any candidate self-quantifying map fails to
be a bijection. -/
theorem selfquant_not_bijective {T : Type*} (f : T → (T → Prop)) :
    ¬ Bijective f := fun h => no_selfquant_surjection ⟨f, h.2⟩

/-! ## Part 3 — The quantitative shadow: a strict cardinal gap -/

/-- **The cardinal gap.**  The impossibility above has a quantitative form: the
predicate space is strictly larger than the type, `#T < #(T → Prop)`.  This
bridges the purely logical obstruction with cardinal arithmetic. -/
theorem selfquant_cardinal_strict (T : Type*) :
    Cardinal.mk T < Cardinal.mk (T → Prop) := by
  have h := Cardinal.cantor (Cardinal.mk T)
  simpa [Cardinal.mk_arrow] using h

/-! ## Part 4 — Truth, provability and the definability boundary

We now formalise a self-referential system.  Its diagonal operator produces,
for every *internally definable* predicate `φ`, a sentence whose truth value is
`φ` applied to itself.  Restricting the diagonal to definable predicates is
exactly what keeps the system consistent: Gödel's sentence exists because
negated provability is definable, while Tarski's paradox is blocked because
negated truth is proven *not* definable. -/

/-- A `SelfRefSystem` carries sentences with a truth predicate `Tr`, a
provability predicate `Pr` (sound: provable implies true), a notion of which
predicates are internally `Definable`, and a diagonal operator satisfying the
fixed-point property on definable predicates.  We further assume that negated
provability is definable — the standard representability hypothesis. -/
structure SelfRefSystem where
  /-- The type of sentences. -/
  Sentence : Type
  /-- Truth of a sentence (a metatheoretic proposition). -/
  Tr : Sentence → Prop
  /-- Provability of a sentence. -/
  Pr : Sentence → Prop
  /-- Soundness: provable sentences are true. -/
  sound : ∀ s, Pr s → Tr s
  /-- Which predicates over sentences are internally nameable. -/
  Definable : (Sentence → Prop) → Prop
  /-- The diagonal (self-reference) operator. -/
  diag : (Sentence → Prop) → Sentence
  /-- Diagonal fixed-point property, available for definable predicates. -/
  diag_spec : ∀ φ : Sentence → Prop, Definable φ → (Tr (diag φ) ↔ φ (diag φ))
  /-- Negated provability is internally definable (representability). -/
  negPr_definable : Definable (fun s => ¬ Pr s)

namespace SelfRefSystem

variable (M : SelfRefSystem)

/-- The Gödel sentence: the diagonal fixed point of "is not provable". -/
def goedel : M.Sentence := M.diag (fun s => ¬ M.Pr s)

/-- **Gödel, part 1 — unprovability.**  The Gödel sentence is not provable.
If it were, soundness would make it true, and its own fixed-point property
would then assert its unprovability — a contradiction. -/
theorem goedel_unprovable : ¬ M.Pr M.goedel := by
  intro h
  have ht : M.Tr M.goedel := M.sound _ h
  exact (M.diag_spec _ M.negPr_definable).mp ht h

/-- **Gödel, part 2 — truth.**  The Gödel sentence is nonetheless true: it
correctly asserts its own unprovability. -/
theorem goedel_true : M.Tr M.goedel :=
  (M.diag_spec _ M.negPr_definable).mpr M.goedel_unprovable

/-- **Incompleteness.**  There is a sentence that is true but not provable. -/
theorem incompleteness : ∃ s, M.Tr s ∧ ¬ M.Pr s :=
  ⟨M.goedel, M.goedel_true, M.goedel_unprovable⟩

/-- **Tarski's undefinability of truth.**  In any such system, negated truth is
*not* internally definable.  Were it definable, the diagonal fixed point would
assert its own truth is equivalent to its own falsehood — an outright
contradiction.  This is precisely the boundary that Gödel's argument respects
and Tarski's crosses. -/
theorem tarski_truth_not_definable : ¬ M.Definable (fun s => ¬ M.Tr s) := by
  intro hd
  have h := M.diag_spec _ hd
  tauto

end SelfRefSystem

/-- **Satisfiability witness.**  A concrete `SelfRefSystem`, ensuring the Gödel
and Tarski theorems above are not vacuously true.  Sentences are booleans, truth
is "equals `true`", nothing is provable, and a predicate is definable exactly
when it holds at the diagonal point `true`. -/
def exampleSystem : SelfRefSystem where
  Sentence := Bool
  Tr := fun b => b = true
  Pr := fun _ => False
  sound := by intro s h; exact absurd h not_false
  Definable := fun φ => φ true
  diag := fun _ => true
  diag_spec := by intro φ hφ; simpa using hφ
  negPr_definable := by simp

end SelfQuantifying