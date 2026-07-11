/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Oracle's Burden, Part II: The abstract Turing-jump hierarchy

Building on Mathlib's `TuringDegree`, we axiomatize the **Turing jump** operator `J` by its two
defining order-theoretic properties and prove that iterating *any* such operator produces a
strictly increasing `ω`-chain of Turing degrees

  `A  <ᵀ  J A  <ᵀ  J² A  <ᵀ  J³ A  <ᵀ  ...`

which is the computability-theoretic incarnation of the theory tower

  `PA  <  PA^H  <  PA^{H^H}  <  ...`.

This isolates the *combinatorial skeleton* of the hierarchy from the (much heavier) construction
of a concrete jump via a relativized universal machine.  The canonical model of `IsJump` is the
Turing jump `A ↦ A'`, whose two axioms — `A ≤ᵀ A'` and `¬ A' ≤ᵀ A` — are Post's relativized
halting theorem; the base instance `0 <ᵀ 0'` is proved unconditionally in
`Computation.OracleHierarchy` (`exists_degree_gt_zero`).

The mission's slogan — *proves its own consistency but cannot decide its own soundness* — is
exactly `A <ᵀ J A`: the jump `J A` decides the halting behaviour of every `A`-machine
("consistency of the level below"), yet `A` cannot decide membership in `J A`
("its own soundness").  Non-idempotence of the jump (`jump_not_idempotent`) says this burden
strictly recurs at every level: no amount of oracle knowledge ever makes the next jump free.

## Main results

* `IsJump` — the two axioms of an abstract jump operator.
* `IsJump.lt` — one jump strictly increases the degree: `A <ᵀ J A`.
* `IsJump.hierarchy_strictMono` — the iterated hierarchy is strictly increasing.
* `IsJump.hierarchy_lt` — `Jᵐ A <ᵀ Jⁿ A` whenever `m < n`.
* `IsJump.hierarchyEmbedding` — the hierarchy is an **order embedding** `(ℕ, <) ↪o TuringDegree`,
  i.e. the oracle hierarchy is order-isomorphic to the standard `ω`-indexed Turing-jump hierarchy.
* `IsJump.hierarchy_injective` — all levels are pairwise distinct degrees.
* `jump_not_idempotent` — a **disproof** of "the jump is idempotent": `J (J A) ≢ᵀ J A`.
* `not_isJump_id`, `not_isJump_const` — the `IsJump` axioms are **discriminating**: no trivial
  operator (identity or constant) is a jump.

## Contrarian log

* CONJECTURE: the jump stabilizes, i.e. `J (J A) ≡ᵀ J A` for some/all `A`.
  **DISPROVED** by `jump_not_idempotent`.
* CONJECTURE: the hierarchy `A, J A, J² A, ...` eventually repeats a degree.
  **DISPROVED** by `IsJump.hierarchy_injective`.
* CONJECTURE: the identity / a constant map could serve as a jump operator.
  **DISPROVED** by `not_isJump_id` and `not_isJump_const`.
-/

import Mathlib

open scoped Computability
open Primrec Nat.Partrec Part

namespace TuringJumpHierarchy

/-- The Turing degree of a partial function. -/
noncomputable def tdeg (f : ℕ →. ℕ) : TuringDegree := Quotient.mk _ f

theorem tdeg_lt {f g : ℕ →. ℕ} (h1 : f ≤ᵀ g) (h2 : ¬ g ≤ᵀ f) : tdeg f < tdeg g :=
  ⟨h1, h2⟩

/-- An **abstract Turing jump**: an operator `J` on partial functions such that
* every function is computable from its jump (`le`), and
* no function computes its own jump (`not_ge`).

The canonical instance is the Turing jump `A ↦ A'`; these two axioms are precisely the content of
the relativized halting theorem. -/
structure IsJump (J : (ℕ →. ℕ) → (ℕ →. ℕ)) : Prop where
  /-- The oracle is recursive in its own jump. -/
  le : ∀ A, A ≤ᵀ J A
  /-- The jump is *not* recursive in the oracle: it is a genuine increase in power. -/
  not_ge : ∀ A, ¬ (J A ≤ᵀ A)

variable {J : (ℕ →. ℕ) → (ℕ →. ℕ)}

/-- **One jump strictly increases the degree.**  `A <ᵀ J A`: the jump proves the "consistency"
of the level below (it computes `A`) but the level below cannot decide its "soundness"
(it cannot compute `J A`). -/
theorem IsJump.lt (hJ : IsJump J) (A : ℕ →. ℕ) : tdeg A < tdeg (J A) :=
  tdeg_lt (hJ.le A) (hJ.not_ge A)

/-- **The iterated jump hierarchy is strictly increasing.**  Each application of the jump yields a
strictly larger Turing degree, so `A, J A, J² A, …` is a strictly ascending `ω`-chain. -/
theorem IsJump.hierarchy_strictMono (hJ : IsJump J) (A : ℕ →. ℕ) :
    StrictMono (fun n => tdeg (J^[n] A)) := by
  apply strictMono_nat_of_lt_succ
  intro n
  have hstep : J^[n + 1] A = J (J^[n] A) := by
    rw [Function.iterate_succ']; rfl
  rw [hstep]
  exact hJ.lt (J^[n] A)

/-- Every earlier level is strictly below every later level:
`Jᵐ A <ᵀ Jⁿ A` whenever `m < n`. -/
theorem IsJump.hierarchy_lt (hJ : IsJump J) (A : ℕ →. ℕ) {m n : ℕ} (h : m < n) :
    tdeg (J^[m] A) < tdeg (J^[n] A) :=
  hJ.hierarchy_strictMono A h

/-- **The oracle hierarchy is order-isomorphic to the Turing-jump hierarchy.**  The level map
`n ↦ deg (Jⁿ A)` is an order embedding of `(ℕ, <)` into the Turing degrees: it faithfully
reproduces the standard `ω`-indexed jump hierarchy `0 <ᵀ 0' <ᵀ 0'' <ᵀ …` inside the degree order.
-/
noncomputable def IsJump.hierarchyEmbedding (hJ : IsJump J) (A : ℕ →. ℕ) :
    ℕ ↪o TuringDegree :=
  OrderEmbedding.ofStrictMono (fun n => tdeg (J^[n] A)) (hJ.hierarchy_strictMono A)

/-- **All levels of the hierarchy are distinct degrees**: the tower never collapses or repeats. -/
theorem IsJump.hierarchy_injective (hJ : IsJump J) (A : ℕ →. ℕ) :
    Function.Injective (fun n => tdeg (J^[n] A)) :=
  (hJ.hierarchy_strictMono A).injective

/-- **DISPROOF of jump idempotence.**  The jump is never idempotent: `J (J A)` is strictly above
`J A`, hence not Turing-equivalent to it.  The "oracle's burden" strictly recurs at every level —
knowing the halting problem of the level below never trivializes the next jump. -/
theorem jump_not_idempotent (hJ : IsJump J) (A : ℕ →. ℕ) :
    ¬ (J (J A) ≡ᵀ J A) := by
  intro h
  exact hJ.not_ge (J A) h.1

/-- The jump of the jump is strictly above the jump: `J A <ᵀ J (J A)`. -/
theorem IsJump.jump_jump_gt (hJ : IsJump J) (A : ℕ →. ℕ) :
    tdeg (J A) < tdeg (J (J A)) :=
  hJ.lt (J A)

/-! ## The axiomatization has content: trivial operators are never jumps

The results above are stated for an arbitrary operator satisfying `IsJump`.  To show this is a
*discriminating* hypothesis — and not one satisfied by degenerate operators — we record that no
operator which fixes some oracle up to Turing equivalence can be a jump.  In particular the
identity and every constant operator fail to be jumps: a genuine jump must strictly increase power
at every oracle. -/

/-- **No jump fixes an oracle.**  For any abstract jump `J`, the jump `J A` is never Turing
equivalent to `A`: the increase in power is strict at every level. -/
theorem IsJump.not_equiv (hJ : IsJump J) (A : ℕ →. ℕ) : ¬ (J A ≡ᵀ A) := by
  intro h
  exact hJ.not_ge A h.1

/-- **The identity operator is not a jump.**  If it were, some oracle would compute its own jump,
contradicting `not_ge`.  This shows the `IsJump` axioms genuinely rule out the trivial operator. -/
theorem not_isJump_id : ¬ IsJump (fun A => A) := by
  intro hJ
  exact hJ.not_ge (fun _ => Part.some 0) TuringReducible.rfl

/-- **No constant operator is a jump.**  A jump must respond to its input; a constant `A ↦ C`
fails `not_ge` at `A = C`. -/
theorem not_isJump_const (C : ℕ →. ℕ) : ¬ IsJump (fun _ => C) := by
  intro hJ
  exact hJ.not_ge C TuringReducible.rfl

end TuringJumpHierarchy