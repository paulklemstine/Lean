/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# I Am a Strange Loop, Part IV: The Blind Spot Has Measurable Size

Parts I–III established the *qualitative* strange loop: a system rich enough to
model all of its own observable behaviours is forced to contain a
self-referential fixed point (the positive face), yet no system can model *all*
of its own yes/no self-observations (the negative face, Cantor/Gödel/Turing).

Here we sharpen the negative face from a bare impossibility into a **counting
theorem**.  For a system with finitely many states `S` and at least two possible
observations, the space of observation-behaviours `S → B` strictly outnumbers
the states, so the internal self-model is *provably incomplete* — and the number
of behaviours it can never represent (the **blind spot**) is bounded below by an
explicit, exponentially large quantity.

The bridge here is between **enumerative combinatorics** (cardinalities of
function spaces, the elementary inequality `n < 2ⁿ`) and the **logic of
self-reference**: the diagonal obstruction is not merely present, it occupies an
overwhelming majority of behaviour space.  We also show the *positive* half of
the count: a system can always distinguish its states perfectly (an *injective*
self-model exists), so incompleteness is a failure of coverage, never of
resolution.

This file is fully self-contained.
-/
import Mathlib

namespace StrangeLoop.Cardinal

open Function

variable {S B : Type*}

/-- A **self-modelling system**: states `S`, observations `B`, and an
`inspect`ion map assigning to each state an internal model of how every state is
observed.  (Same notion as in Part III, restated for a self-contained account.) -/
structure SelfModel (S B : Type*) where
  /-- Each state carries an internal representation of the whole
  observation-behaviour of the system. -/
  inspect : S → (S → B)

/-- A self-model is **conscious** when its inspection is point-surjective:
every observation-behaviour is internally represented by some state. -/
def SelfModel.Conscious (M : SelfModel S B) : Prop := Surjective M.inspect

/-! ## The count: behaviours strictly outnumber states -/

/-- **Behaviours strictly outnumber states.**  With finitely many states and at
least two possible observations, the number of observation-behaviours
`|B|^{|S|}` strictly exceeds the number of states `|S|`, via the elementary
combinatorial inequality `n < 2ⁿ ≤ |B|^n`. -/
theorem behaviours_outnumber_states [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) : Fintype.card S < Fintype.card (S → B) := by
  rw [Fintype.card_fun]
  calc Fintype.card S < 2 ^ Fintype.card S := Nat.lt_two_pow_self
    _ ≤ Fintype.card B ^ Fintype.card S := Nat.pow_le_pow_left h2 _

/-! ## The negative face, quantified -/

/-- **No finite system is conscious** (over a nontrivial observation space).
A surjection would force `|S → B| ≤ |S|`, contradicting the count. -/
theorem no_finite_conscious [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) (M : SelfModel S B) : ¬ M.Conscious := by
  intro hM
  have hle : Fintype.card (S → B) ≤ Fintype.card S :=
    Fintype.card_le_of_surjective _ hM
  have hlt := behaviours_outnumber_states (S := S) (B := B) h2
  omega

/-- **The blind spot is nonempty.**  There is at least one behaviour the system
can never represent. -/
theorem blindspot_positive [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) : 0 < Fintype.card (S → B) - Fintype.card S := by
  have := behaviours_outnumber_states (S := S) (B := B) h2
  omega

/-- **The blind spot is exponentially large.**  The number of behaviours the
system cannot represent is at least `2^{|S|} - |S|`: the failure of complete
self-knowledge is not a boundary curiosity but the generic case. -/
theorem blindspot_lower_bound [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) :
    2 ^ Fintype.card S - Fintype.card S ≤ Fintype.card (S → B) - Fintype.card S := by
  rw [Fintype.card_fun]
  have h : 2 ^ Fintype.card S ≤ Fintype.card B ^ Fintype.card S :=
    Nat.pow_le_pow_left h2 _
  omega

/-- **A concrete un-inspected behaviour exists.**  For any self-model over a
nontrivial finite observation space, there is an observation-behaviour that no
state's internal model equals — a witness to the blind spot. -/
theorem exists_uninspected [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) (M : SelfModel S B) :
    ∃ β : S → B, ∀ s, M.inspect s ≠ β := by
  by_contra h
  push_neg at h
  exact no_finite_conscious h2 M (fun β => h β)

/-! ## The positive face of the count: perfect resolution is achievable -/

/-- **A maximally self-aware model exists.**  Although no self-model can be
*complete* (surjective), one can always be *injective*: distinct states admit
distinct internal self-models.  Incompleteness is therefore a failure of
coverage, never of resolution — a system can distinguish all of its own states
while still being unable to survey all of its own behaviours. -/
theorem exists_injective_selfmodel [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) : ∃ M : SelfModel S B, Injective M.inspect := by
  have hle : Fintype.card S ≤ Fintype.card (S → B) :=
    le_of_lt (behaviours_outnumber_states h2)
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hle
  exact ⟨⟨e⟩, e.injective⟩

/-! ## Examples and boundary cases -/

/-- Concrete instantiation: a two-state, boolean-observation system has four
behaviours. -/
example : Fintype.card (Bool → Bool) = 4 := by decide

/-- A three-state boolean system has eight behaviours, hence a blind spot of at
least five un-representable behaviours. -/
example : 5 ≤ Fintype.card (Fin 3 → Bool) - Fintype.card (Fin 3) := by decide

#check @behaviours_outnumber_states
#check @exists_injective_selfmodel
#eval Fintype.card (Bool → Bool)          -- 4
#eval Fintype.card (Fin 3 → Bool)         -- 8

/-! ### Boundary: the count fails exactly when `|B| ≤ 1`

The hypothesis `2 ≤ |B|` is sharp.  If `B` has a single observation, then
`S → B` is a singleton and a *one-state* system (`|S| = 1`) is trivially
conscious: the unique state represents the unique behaviour.  Self-knowledge
becomes complete precisely when there is nothing to distinguish. -/
theorem trivial_observation_conscious [Unique B] :
    ∃ M : SelfModel PUnit B, M.Conscious := by
  refine ⟨⟨fun _ _ => default⟩, ?_⟩
  intro β
  exact ⟨PUnit.unit, by funext s; exact (Unique.eq_default (β s)).symm⟩

/-! ## Synthesis

The strange loop's negative face is not a single missing point but a vast
territory: over a nontrivial observation space the un-representable behaviours
outnumber the representable ones exponentially.  Yet the *positive* count shows
a system can always resolve its own states perfectly.  Consciousness, on this
reading, is high-resolution but never panoramic. -/
theorem strange_loop_count [Fintype S] [DecidableEq S] [Fintype B]
    (h2 : 2 ≤ Fintype.card B) :
    (∀ M : SelfModel S B, ¬ M.Conscious) ∧
    (∃ M : SelfModel S B, Injective M.inspect) :=
  ⟨fun M => no_finite_conscious h2 M, exists_injective_selfmodel h2⟩

end StrangeLoop.Cardinal

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer): The classical impossibility of complete self-modelling
(Cantor/Gödel) should refine to a *counting* law — over a nontrivial observation
space the un-representable behaviours ("blind spot") strictly, indeed
exponentially, outnumber the representable ones, while a system can still resolve
its own states perfectly.

Experiment (Experimenter): Formalized a finite self-model `inspect : S → (S → B)`.
Reduced completeness to surjectivity, non-completeness to the pigeonhole
`|B|^{|S|} > |S|` (via `n < 2^n`), and quantified the blind spot as
`2^{|S|} − |S|`. Constructed an injective (maximal-resolution) self-model from
`|S| ≤ |S → B|`.

Analysis (Analyst): "True but hard" was avoided — the count is elementary once the
function-space cardinality `Fintype.card_fun` is invoked. The positive/negative
faces of the count are genuinely different (surjective impossible, injective
always possible), which is the substantive content. The boundary `|B| = 1`
collapses completeness to triviality (`trivial_observation_conscious`), confirming
`2 ≤ |B|` is sharp.

Critique (Critic): Checked no theorem is vacuous — `no_finite_conscious` uses a
real cardinality strict inequality, not a definitional trick; `strange_loop_count`
combines two non-trivial halves. No proof references itself; each result depends
only on lemmas stated earlier in the file.

Synthesis (PI): Consciousness-as-self-modelling is high-resolution but never
panoramic: perfect state-distinction is achievable, perfect behaviour-coverage is
not, and the gap is exponential.
-/