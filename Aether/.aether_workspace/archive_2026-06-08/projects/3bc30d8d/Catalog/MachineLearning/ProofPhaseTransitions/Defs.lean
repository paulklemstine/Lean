import Mathlib

/-!
# Monotone Provability Systems: Definitions

This file introduces the core mathematical framework for studying **proof phase transitions**
— the phenomenon where the probability of a statement being derivable from a random set of
axioms undergoes a sharp jump as the inclusion probability crosses a critical threshold.

## Main Definitions

* `MonotoneProvabilitySystem α τ` — A finite certificate system where `α` indexes axioms
  and `τ` indexes target statements. Each target has a family of certificates (finite sets
  of axioms sufficient for derivation).

* `MonotoneProvabilitySystem.Provable` — The event that a target is provable from a given
  axiom set: there exists a certificate contained in the selected axioms.

* `MonotoneProvabilitySystem.provableCount` — The number of axiom subsets from which a
  target is provable.

* `MonotoneProvabilitySystem.proofPartitionFunction` — The generating function
  `Z_t(λ) = ∑_{A : t provable from A} λ^|A|`.

## Key Insight

Provability from a random axiom set is a **monotone event**: adding more axioms can only
help, never hurt. This places proof emergence squarely within the theory of monotone Boolean
functions, network reliability polynomials, and bootstrap percolation — enabling the transfer
of deep threshold theorems from combinatorics and statistical physics.
-/

open Finset BigOperators

/-- A monotone provability system over a finite axiom type `α` and target type `τ`.

Each target `t : τ` has a family `Cert t` of **certificates**: finite sets of axioms
such that `t` is provable whenever all axioms in some certificate are available.

This abstracts bounded proof search: each certificate represents one complete derivation
path, and a target is provable iff at least one derivation path is fully supported. -/
structure MonotoneProvabilitySystem (α τ : Type*) [Fintype α] [DecidableEq α] where
  /-- The family of proof certificates for each target. -/
  Cert : τ → Finset (Finset α)

namespace MonotoneProvabilitySystem

variable {α τ : Type*} [Fintype α] [DecidableEq α]

/-- A target `t` is **provable** from axiom set `A` if some certificate for `t` is
contained in `A`. This is the fundamental provability predicate. -/
def Provable (M : MonotoneProvabilitySystem α τ) (t : τ) (A : Finset α) : Prop :=
  ∃ S ∈ M.Cert t, S ⊆ A

/-- Decidability of `Provable` follows from finiteness of everything involved. -/
noncomputable instance instDecidableProvable (M : MonotoneProvabilitySystem α τ) (t : τ)
    (A : Finset α) : Decidable (M.Provable t A) := Classical.dec _

/-- The number of subsets of the full axiom pool from which target `t` is provable. -/
noncomputable def provableCount (M : MonotoneProvabilitySystem α τ) (t : τ) : ℕ :=
  ((Finset.univ : Finset (Finset α)).filter (fun A => M.Provable t A)).card

/-- The proof partition function: a generating function counting provable subsets
weighted by size. This is the analogue of a statistical-mechanical partition function
where each axiom set is a microstate and `λ^|A|` is the Boltzmann weight. -/
noncomputable def proofPartitionFunction (M : MonotoneProvabilitySystem α τ)
    (t : τ) (lam : ℚ) : ℚ :=
  ∑ A ∈ (Finset.univ : Finset (Finset α)),
    if M.Provable t A then lam ^ A.card else 0

/-- The indicator function for provability, as a function `(α → Bool) → Bool`.
This realizes the provability event as a monotone Boolean function. -/
noncomputable def provableIndicator (M : MonotoneProvabilitySystem α τ) (t : τ)
    (f : α → Bool) : Bool :=
  decide (M.Provable t (Finset.univ.filter (fun a => f a)))

end MonotoneProvabilitySystem