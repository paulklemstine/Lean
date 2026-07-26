import Mathlib

/-!
# Substrate-independent uncomputability and the oracle (hypercomputation) barrier

**Research theme: Computational Complexity of Alien Civilizations.**

This file formalizes the claim that the *undecidability of self-reference* is a
theorem about the structure of computation itself, not about any particular
machine model, biology, or physics.  We model an arbitrary notion of computation
abstractly and prove that the diagonal argument bites in **every** such model —
and, crucially, that it continues to bite even when the model is granted an
**arbitrary oracle**, i.e. an unrestricted (possibly hyper-computational)
resource.  Thus even a civilization with hypercomputers faces an *analogous*
barrier: the jump of a class is never internal to the class.

## Design

A `ComputationModel` is *any* type `Pgm` of "programs" together with a Boolean
acceptance relation `accepts : Pgm → Pgm → Bool` (`accepts p q =` "program `p`
accepts the code of program `q`").  No computability, finiteness, or structure is
assumed on `Pgm`; the results below are therefore forced on any civilization
whose programs can be coded by the same objects they act on.

## Main results

* `AlienComputation.ComputationModel.diagonal_not_realized` : the diagonal
  behaviour is realized by no program (abstract halting-problem undecidability).
* `AlienComputation.ComputationModel.exists_undecidable` : every model has a
  decision behaviour outside the range of its programs.
* `AlienComputation.substrate_independent` : the previous statement holds for
  *every* model, with no hypotheses — the obstruction is model-independent.
* `AlienComputation.OracleModel.jump_not_internal` : even a model equipped with
  an arbitrary oracle cannot internally decide its own jump.
* `AlienComputation.hypercomputation_barrier` : the relativized barrier holds for
  every oracle whatsoever.
-/

namespace AlienComputation

universe u

/-- Boolean negation has no fixed point: no `b : Bool` equals `!b`. -/
theorem bool_ne_not (b : Bool) : b ≠ !b := by cases b <;> decide

/-- An **abstract model of computation**: a type of programs together with a
Boolean acceptance relation on (program, program-code) pairs.  Deliberately
free of any Turing/λ/physical structure, so that theorems about it are
substrate-independent. -/
structure ComputationModel where
  /-- The type of programs / codes of the model. -/
  Pgm : Type u
  /-- `accepts p q` : program `p` halts-and-accepts on the code of program `q`. -/
  accepts : Pgm → Pgm → Bool

namespace ComputationModel

variable (M : ComputationModel)

/-- The **diagonal behaviour** of a model: the decision procedure that, on input
`q`, returns the opposite of what `q` does to its own code. -/
def diagonal : M.Pgm → Bool := fun q => !(M.accepts q q)

/-- **Abstract undecidability / halting theorem.**  No program of the model
realizes the diagonal behaviour: for every program `p`, `M.accepts p ≠ diagonal`.
Instantiating with the halting-decider gives the classical undecidability of the
halting problem, but the statement is model-free. -/
theorem diagonal_not_realized : ∀ p : M.Pgm, M.accepts p ≠ M.diagonal := by
  intro p hp
  have h : M.accepts p p = !(M.accepts p p) := congrFun hp p
  exact bool_ne_not _ h

/-- Every computation model has a decision behaviour that lies **outside the
range** of its programs — a "problem" no program in the model solves. -/
theorem exists_undecidable : ∃ g : M.Pgm → Bool, g ∉ Set.range M.accepts := by
  refine ⟨M.diagonal, ?_⟩
  rintro ⟨p, hp⟩
  exact M.diagonal_not_realized p hp

end ComputationModel

/-- **Substrate independence.**  For *every* computation model, whatever its
program type, there is a decision behaviour no program realizes.  The absence of
any hypothesis is the point: the obstruction depends only on the shape of
"programs acting on programs", not on the substrate. -/
theorem substrate_independent (M : ComputationModel) :
    ∃ g : M.Pgm → Bool, ∀ p : M.Pgm, M.accepts p ≠ g :=
  ⟨M.diagonal, M.diagonal_not_realized⟩

/-!
## The hypercomputation barrier

We now give the model an *arbitrary* oracle `oracle : Pgm → Bool`.  The field is
completely unconstrained: it may be any function, including one that is not
computable by any conventional machine.  This is the mathematical stand-in for a
"hypercomputational resource".  The programs' acceptance relation may consult the
oracle in any way whatsoever — this is already subsumed by allowing `accepts` to
be arbitrary.  We show the diagonal obstruction is *invariant* under this
enrichment: the jump of the class is never internal to the class.
-/

/-- A computation model enriched with an **arbitrary oracle** — a stand-in for an
unrestricted hyper-computational resource. -/
structure OracleModel where
  /-- The type of (oracle-)programs. -/
  Pgm : Type u
  /-- An arbitrary, possibly non-computable oracle available to every program. -/
  oracle : Pgm → Bool
  /-- Oracle-relative acceptance. -/
  accepts : Pgm → Pgm → Bool

namespace OracleModel

variable (M : OracleModel)

/-- The relativized jump: the diagonal behaviour of the oracle-model. -/
def jump : M.Pgm → Bool := fun q => !(M.accepts q q)

/-- **The oracle barrier.**  Even with an arbitrary oracle in hand, no program of
the model decides the model's own jump.  Adding hypercomputational power does not
dissolve the diagonal: it only relocates it one level up. -/
theorem jump_not_internal : ∀ p : M.Pgm, M.accepts p ≠ M.jump := by
  intro p hp
  have h : M.accepts p p = !(M.accepts p p) := congrFun hp p
  exact bool_ne_not _ h

end OracleModel

/-- **Hypercomputation barrier (universal form).**  For every program type and
every oracle whatsoever, and every oracle-relative acceptance relation, there is
a decision behaviour no oracle-program realizes.  Hence *any* civilization —
including one wielding hypercomputers — meets an analogous obstruction. -/
theorem hypercomputation_barrier
    (Pgm : Type u) (oracle : Pgm → Bool) (accepts : Pgm → Pgm → Bool) :
    ∃ g : Pgm → Bool, ∀ p : Pgm, accepts p ≠ g :=
  let M : OracleModel := ⟨Pgm, oracle, accepts⟩
  ⟨M.jump, M.jump_not_internal⟩

/-- Non-vacuity check: the barrier applies to a concrete model
(`Pgm = ℕ`, an arbitrary acceptance relation), so the universal theorems above
are not vacuously true. -/
example : ∃ g : ℕ → Bool, ∀ p : ℕ, (fun a b => decide (a ≤ b)) p ≠ g :=
  substrate_independent ⟨ℕ, fun a b => decide (a ≤ b)⟩

end AlienComputation