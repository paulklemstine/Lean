/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import FINAL.Novelty.Basic

/-!
# Algorithmic computation of the surrogate Φ

Building on `FINAL/Novelty/Basic.lean`, this file supplies the **algorithmic**
content of the surrogate integrated information `Φ`:

* a **computable implementation** `PhiQ` that computes `Φ` for an *arbitrary
  binary distribution* given by explicit rational weights on the
  configurations `Fin n → Bool`;
* the **direct formula** for the maximally-integrated (complete co-activation)
  system: `Φ = ⌊n²/4⌋`, established for every system with `≤ 4` variables
  (Theorem (c)), via the fact that every cross bipartition of the complete
  co-activation contributes exactly `|A| · |B|` co-active pairs.

Because `Φ` is a `ℕ`-valued maximum over the (finite) family of bipartitions of
`Fin n`, it is `native_decide`/`decide`-evaluable: the enumeration ranges over
subsets of an `n`-element set, giving the `O(2ⁿ)` character of the algorithm.
-/

open Finset

namespace IITSurrogate

/-! ## The complete co-activation and its cross-scores -/

/-- The **complete co-activation** relation on `α`: every pair of *distinct*
variables is co-active.  This models a maximally integrated system. -/
def completeCoact (α : Type*) [DecidableEq α] : α → α → Bool :=
  fun i j => decide (i ≠ j)

/-
For the complete co-activation, every cross pair of a bipartition is
co-active, so the cross-score of a bipartition `(A, B)` (with `A`, `B` disjoint)
is exactly `|A| · |B|`.
-/
theorem crossScore_completeCoact {α : Type*} [Fintype α] [DecidableEq α]
    {A B : Finset α} (h : Disjoint A B) :
    crossScore (completeCoact α) A B = A.card * B.card := by
  convert Finset.card_product A B using 2;
  refine' congr_arg Finset.card ( Finset.filter_true_of_mem _ );
  simp +contextual [completeCoact]
  exact fun a b ha hb hab => Finset.disjoint_left.mp h ha (hab ▸ hb)

/-! ## Theorem (c): the direct `⌊n²/4⌋` formula for `≤ 4` variables

`Φ` of a maximally integrated system on `n ≤ 4` variables is `⌊n²/4⌋`, computed
by enumerating the co-active bipartitions. -/

/-- **Theorem (c) — direct formula.**  For every system with at most four
variables, the surrogate integrated information of the complete co-activation is
given by the closed form `⌊n²/4⌋`, obtained by the `O(2ⁿ)` enumeration of
co-active bipartitions. -/
theorem Phi_complete_formula (n : ℕ) (hn : n ≤ 4) :
    Phi (completeCoact (Fin n)) = n ^ 2 / 4 := by
  interval_cases n <;> native_decide

/-! ## Computable Φ for an arbitrary binary distribution

An arbitrary binary distribution on `Fin n` variables is given by explicit
rational weights `w : (Fin n → Bool) → ℚ` on the configurations.  From these we
compute marginals, joint activations, the co-activation matrix, and hence `Φ` —
all fully executable. -/

variable {n : ℕ}

/-- Computable marginal: the total weight of configurations in which variable `i`
is active. -/
def margQ (w : (Fin n → Bool) → ℚ) (i : Fin n) : ℚ :=
  ∑ c, if c i = true then w c else 0

/-- Computable joint activation weight of variables `i` and `j`. -/
def jointQ (w : (Fin n → Bool) → ℚ) (i j : Fin n) : ℚ :=
  ∑ c, if c i = true ∧ c j = true then w c else 0

/-- The **computable co-activation matrix** of a rational binary distribution:
`i` and `j` are co-active when they are positively correlated. -/
def coactBoolQ (w : (Fin n → Bool) → ℚ) : Fin n → Fin n → Bool :=
  fun i j => decide (margQ w i * margQ w j < jointQ w i j)

/-- **Computable surrogate integrated information** of an arbitrary binary
distribution given by rational weights. -/
def PhiQ (w : (Fin n → Bool) → ℚ) : ℕ :=
  Phi (coactBoolQ w)

/-! ## Worked examples

A concrete distribution on three variables that are perfectly correlated (all
mass on the all-active and all-inactive configurations).  All three pairs are
co-active, so this is the complete co-activation on `Fin 3`, and its Φ is the
balanced-bipartition value `⌊3²/4⌋ = 2`. -/

/-- Perfectly correlated three-variable distribution: mass `1/2` on the
all-active and all-inactive configurations. -/
def correlatedTriple : (Fin 3 → Bool) → ℚ :=
  fun c => if (c 0 = c 1 ∧ c 1 = c 2) then 1 / 2 else 0

/-- The perfectly correlated triple is maximally integrated: `Φ = 2`. -/
theorem PhiQ_correlatedTriple : PhiQ correlatedTriple = 2 := by native_decide

/-- A product (independent) distribution on two variables carries no
integration: `Φ = 0`.  Here each variable is active with probability `1/2`
independently. -/
def independentPair : (Fin 2 → Bool) → ℚ := fun _ => 1 / 4

theorem PhiQ_independentPair : PhiQ independentPair = 0 := by native_decide

end IITSurrogate