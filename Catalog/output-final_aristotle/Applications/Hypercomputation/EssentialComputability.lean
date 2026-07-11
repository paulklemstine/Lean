/-
  Hypercomputation I: the halting oracle and the essential/hyper divide
  ====================================================================

  This file gives a rigorous model of a *hypercomputer* — a device equipped
  with a black-box **halting oracle** — and proves that it strictly exceeds the
  power of ordinary (Turing) computation.

  We work inside Mathlib's formalization of computability theory via partial
  recursive functions.  A program is a `Nat.Partrec.Code`, and `eval c n` is the
  partial function it computes.  "Essentially computable" is Mathlib's
  `Computable` / `ComputablePred`, which is exactly Turing computability.

  Main results:

  * `haltingOracle_correct` / `haltingOracle_decides` : the oracle is a *total*
    Boolean function that correctly decides, for every program `c` and input `n`,
    whether `c` halts on `n`.  This is the hypercomputer solving the halting
    problem by construction.
  * `no_computable_halting_decider` : no ordinary Turing machine (no `Computable`
    Boolean function) decides halting.  Hence the oracle is not itself
    computable.
  * `oracle_strictly_stronger` : the two facts together — the hypercomputer
    decides a predicate that no Turing machine decides.
  * `halting_re` / `halting_not_co_re` : the halting predicate is recursively
    enumerable but its complement is not, explaining *why* mere enumeration is
    insufficient and genuine (hyper-)decision is required.
-/
import Mathlib

open Nat.Partrec Nat.Partrec.Code
open scoped Classical

namespace Applications.Hypercomputation

/-- `Halts c n` holds when program (code) `c` halts on input `n`, i.e. the
partial function `eval c` is defined at `n`. -/
def Halts (c : Code) (n : ℕ) : Prop := (eval c n).Dom

/-- The **halting oracle**: the total Boolean function a hypercomputer consults.
Given a program `c` and input `n` it returns `true` exactly when `c` halts on
`n`.  It is defined by classical case analysis on the (undecidable) proposition
`Halts c n`, so it is `noncomputable`; this is the whole point — the oracle
carries information no algorithm can produce. -/
noncomputable def haltingOracle (c : Code) (n : ℕ) : Bool := decide (Halts c n)

/-- The oracle is correct: it answers `true` precisely for halting computations. -/
theorem haltingOracle_correct (c : Code) (n : ℕ) : haltingOracle c n = true ↔ Halts c n := by
  simp [haltingOracle]

/-- The hypercomputer **solves the halting problem**: for every program `c` and
input `n`, the oracle returns a definite Boolean verdict that matches whether the
computation halts. -/
theorem haltingOracle_decides (n : ℕ) (c : Code) :
    (haltingOracle c n = true ∧ Halts c n) ∨ (haltingOracle c n = false ∧ ¬ Halts c n) := by
  by_cases h : Halts c n
  · exact Or.inl ⟨(haltingOracle_correct c n).2 h, h⟩
  · refine Or.inr ⟨?_, h⟩
    simp [haltingOracle, h]

/-- No **Turing machine** decides the halting problem: for any fixed input `n`,
there is no `Computable` Boolean function `f` with `f c = true ↔ c` halts on `n`.
Consequently the halting oracle above is not computable. -/
theorem no_computable_halting_decider (n : ℕ) :
    ¬ ∃ f : Code → Bool, Computable f ∧ ∀ c, f c = true ↔ Halts c n := by
  rintro ⟨f, hf, hfc⟩
  refine ComputablePred.halting_problem n (ComputablePred.computable_iff.2 ⟨f, hf, ?_⟩)
  funext c; simp only [eq_iff_iff]; exact (hfc c).symm

/-- The hypercomputer is **strictly stronger** than any Turing machine: it decides
the halting predicate (left conjunct), while no computable function does (right
conjunct). -/
theorem oracle_strictly_stronger (n : ℕ) :
    (∀ c, haltingOracle c n = true ↔ Halts c n) ∧
      ¬ ∃ f : Code → Bool, Computable f ∧ ∀ c, f c = true ↔ Halts c n :=
  ⟨fun c => haltingOracle_correct c n, no_computable_halting_decider n⟩

/-- Halting is **recursively enumerable**: one can semi-decide it by simply running
the program and reporting success if it halts. -/
theorem halting_re (n : ℕ) : REPred (fun c => Halts c n) := ComputablePred.halting_problem_re n

/-- Non-halting is **not** recursively enumerable.  Together with `halting_re`
this is the fundamental asymmetry: halting can be confirmed by enumeration, but
non-halting cannot be — so no enumerative process suffices, and a genuine
(hyper-)decision procedure is required. -/
theorem halting_not_co_re (n : ℕ) : ¬ REPred (fun c => ¬ Halts c n) :=
  ComputablePred.halting_problem_not_re n

end Applications.Hypercomputation