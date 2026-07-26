/-
  Hypercomputation II: physical oracles, finite precision, and the
  accidentally/essentially computable distinction
  ================================================================

  A popular route to "hypercomputation" is a *physical oracle*: a piece of the
  physical world (a voltage, a length, a real number) whose exact value happens
  to encode the answers to uncomputable questions.  We model such an oracle as an
  infinite bit stream `b : ℕ → Bool` — think of the binary expansion of the
  physical quantity being measured.

  A **measurement of finite precision `p`** can extract only the first `p` bits of
  the stream; this is captured by `readBits b p`, a list of length exactly `p`.
  Any real apparatus then feeds those finitely many bits, together with its input,
  into an ordinary effective procedure `g`.

  Main results:

  * `readBits_length` : precision `p` yields exactly `p` bits.
  * `finitePrecision_computable` : **finite precision collapses to essential
    computability.**  Whatever a finite-precision device outputs is a
    `Computable` function — the finitely many oracle bits can be hard-wired into
    the program.  This is the precise sense in which "accidentally computable"
    (helped by a physical oracle, but only finitely) equals "essentially
    computable" (Turing computable).
  * `not_computable_needs_infinite_precision` : contrapositively, no
    finite-precision device can ever reproduce an uncomputable function.
  * `halting_needs_infinite_precision` : applied to the halting predicate, *any*
    physical oracle used to decide halting must be read to unbounded precision.
    Bounded precision (equivalently, bounded energy/resolution) is provably
    insufficient — hypercomputation demands infinite precision.
-/
import Mathlib

open Nat.Partrec Nat.Partrec.Code
open scoped Classical

namespace Applications.Hypercomputation

/-- A finite-precision measurement of the oracle stream `b`: the first `p` bits,
returned as a list of length `p`.  Increasing `p` models a more precise (more
energetic, higher-resolution) physical measurement. -/
def readBits (b : ℕ → Bool) (p : ℕ) : List Bool := (List.range p).map b

/-- Reading at precision `p` returns exactly `p` bits. -/
theorem readBits_length (b : ℕ → Bool) (p : ℕ) : (readBits b p).length = p := by
  simp [readBits]

variable {α : Type*} [Primcodable α]

/-- **Finite precision is essentially computable.**  A physical device that reads
only the first `p` bits of an oracle stream `b` and then runs an effective
procedure `g` on its input together with those bits computes a genuinely
`Computable` function.  Reason: `readBits b p` is a *fixed* finite list, so it can
be baked into the program as a constant.  This is the formal content of the slogan
"a physical oracle consulted with finite precision gives nothing a Turing machine
could not already do". -/
theorem finitePrecision_computable {g : α → List Bool → Bool} (hg : Computable₂ g)
    (b : ℕ → Bool) (p : ℕ) : Computable (fun a => g a (readBits b p)) :=
  hg.comp Computable.id (Computable.const _)

/-- **Uncomputable functions need infinite precision.**  If `s` is not
Turing-computable, then for every effective procedure `g`, every oracle stream
`b`, and every finite precision `p`, the finite-precision device output differs
from `s`.  No amount of *bounded* physical precision can realize an uncomputable
function. -/
theorem not_computable_needs_infinite_precision {s : α → Bool} (hs : ¬ Computable s)
    {g : α → List Bool → Bool} (hg : Computable₂ g) (b : ℕ → Bool) (p : ℕ) :
    (fun a => g a (readBits b p)) ≠ s := by
  intro h; exact hs (h ▸ finitePrecision_computable hg b p)

/-- **The halting problem requires infinite precision.**  For any fixed input `n`,
no finite-precision physical device — any effective procedure `g` reading finitely
many bits `readBits b p` of any oracle stream `b` — can decide halting.  A
hypercomputer built from a physical oracle must therefore extract unboundedly many
bits, i.e. measure with unbounded (infinite in the limit) precision. -/
theorem halting_needs_infinite_precision (n : ℕ) {g : Code → List Bool → Bool}
    (hg : Computable₂ g) (b : ℕ → Bool) (p : ℕ) :
    (fun c => g c (readBits b p)) ≠ fun c => decide ((eval c n).Dom) := by
  apply not_computable_needs_infinite_precision _ hg b p
  intro hcomp
  exact ComputablePred.halting_problem n
    (ComputablePred.computable_iff.2 ⟨_, hcomp, by funext c; simp⟩)

end Applications.Hypercomputation