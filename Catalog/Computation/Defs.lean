/-
# Tropical Low-Rank Approximation: Core Definitions

This file establishes the foundational definitions for certified algorithmic
extraction of tropical (max-plus) low-rank approximants. We define:

- `MaxPlusTerm`: a separable max-plus tensor term c + a(x) + b(y)
- `evalTerms`: evaluation of the sup of a family of terms
- `anchoredTerm`: the canonical localized term for finite exact representation
- `RealizesWithin`: the predicate that n terms approximate f within ε
- `tropicalRankEps`: the tropical ε-rank complexity invariant
-/
import Mathlib

open Finset

namespace TropicalApprox

/-! ## Max-Plus Terms -/

/-- A single separable max-plus tensor term, representing
    the function (x, y) ↦ c + a(x) + b(y). -/
structure MaxPlusTerm (X Y : Type*) where
  c : ℝ
  a : X → ℝ
  b : Y → ℝ

/-- Evaluation of a single separable max-plus tensor term. -/
def MaxPlusTerm.eval {X Y : Type*} (t : MaxPlusTerm X Y) (x : X) (y : Y) : ℝ :=
  t.c + t.a x + t.b y

/-! ## Evaluation of Term Families -/

/-- The supremum of a nonempty family of max-plus term evaluations at a point.
    Uses `Finset.sup'` to avoid requiring a bottom element on ℝ. -/
noncomputable def evalTerms {X Y : Type*} {n : ℕ}
    (ts : Fin (n + 1) → MaxPlusTerm X Y) (x : X) (y : Y) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => (ts i).eval x y)

/-! ## Anchored Terms for Finite Exact Representation -/

/-- An anchored term localized at (x₀, y₀): equals f(x₀, y₀) at (x₀, y₀)
    and is suppressed by D elsewhere. -/
noncomputable def anchoredTerm {X Y : Type*} [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (D : ℝ) (x₀ : X) (y₀ : Y) : MaxPlusTerm X Y where
  c := f x₀ y₀
  a := fun x => if x = x₀ then 0 else -D
  b := fun y => if y = y₀ then 0 else -D

/-! ## RealizesWithin: Approximation Predicate -/

/-- `RealizesWithin f ε n` asserts that `f` can be approximated within `ε`
    (in sup-norm) by the pointwise maximum of `n` separable max-plus terms.

    Formulated without `Finset.sup` to avoid OrderBot issues on ℝ:
    - Every term is bounded above by f + ε (upper envelope condition)
    - Some term achieves at least f - ε at each point (lower envelope condition) -/
def RealizesWithin {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) (n : ℕ) : Prop :=
  ∃ ts : Fin n → MaxPlusTerm X Y,
    ∀ x y,
      (∀ i, (ts i).eval x y ≤ f x y + ε) ∧
      (∃ i, f x y - ε ≤ (ts i).eval x y)

/-- The set of natural numbers `n` for which `f` can be approximated
    within `ε` by `n` max-plus separable terms. -/
def tropicalRankEpsSet {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : Set ℕ :=
  {n | RealizesWithin f ε n}

/-- The tropical ε-rank: the minimum number of separable max-plus terms
    needed to approximate `f` within `ε` in sup-norm on a finite grid. -/
noncomputable def tropicalRankEps {X Y : Type*} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : ℕ :=
  sInf (tropicalRankEpsSet f ε)

end TropicalApprox