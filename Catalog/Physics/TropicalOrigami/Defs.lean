/-
# Tropical Origami: Min-Plus Fold Structures and Rigid Origami Classification

This module defines the foundational objects of tropical origami mechanics:
crease matrices, row-balanced constraints, valid fold spaces, tropical stress
equilibrium, tropical energy, gauge equivalence, and Miura/Monge matrices.

## Mathematical Overview

A crease pattern is encoded by a real matrix `C : Matrix (Fin m) (Fin n) ℝ`
whose rows represent local vertex constraints and columns represent creases.
A folding state is a weight vector `w : Fin n → ℝ`. The tropical evaluation
`C i j + w j` gives the contribution of crease `j` to constraint `i`.

The key condition is **row balancing**: the minimum of `C i j + w j` over `j`
must be attained at least twice. This is the finite tropical hyperplane
condition and serves as the combinatorial proxy for rigid fold compatibility.
-/
import Mathlib

open Finset Matrix

noncomputable section

/-! ## MinAttainedTwice: the fundamental tropical balancing predicate -/

/-- A function on a finite type has its minimum attained at least twice. -/
def MinAttainedTwice {α : Type*} [Fintype α] (f : α → ℝ) : Prop :=
  ∃ a b : α, a ≠ b ∧ f a = f b ∧ ∀ c : α, f a ≤ f c

/-! ## Core origami definitions -/

/-- Row `i` of crease matrix `C` is balanced at weight `w` if the minimum
of `C i j + w j` over `j` is attained at least two distinct creases. -/
def RowBalanced {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ)
    (i : Fin m) : Prop :=
  MinAttainedTwice (fun j => C i j + w j)

/-- A weight vector `w` is tropically valid for crease matrix `C` if every
row is balanced: each constraint has its minimum attained at least twice. -/
def IsTropicallyValid {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (w : Fin n → ℝ) : Prop :=
  ∀ i : Fin m, RowBalanced C w i

/-- The tropical hyperplane associated to row `i` of `C`: the set of weights
where row `i` is balanced. -/
def RowHyperplane {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (i : Fin m) :
    Set (Fin n → ℝ) :=
  {w | RowBalanced C w i}

/-- Crease matrix `C` is rigidly foldable if there exists a valid fold state. -/
def RigidlyFoldable {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, IsTropicallyValid C w

/-! ## Tropical stress equilibrium -/

/-- Tropical stress equilibrium for matrix `C` with stress vector `σ`:
for each column `j`, the minimum of `C i j + σ i` over rows `i` is attained
at least twice. This is the column-wise dual of row balancing. -/
def TropicalStressEquilibrium {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ) (σ : Fin m → ℝ) : Prop :=
  ∀ j : Fin n,
    MinAttainedTwice (fun i => C i j + σ i)

/-! ## Tropical energy -/

/-- The smallest value of `C i j + w j` over `j` for row `i`. -/
def rowMin {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ)
    (i : Fin m) (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) : ℝ :=
  Finset.univ.inf' hn (fun j => C i j + w j)

/-- The second smallest value of `C i j + w j` over `j` for row `i`:
the infimum over `j` where `C i j + w j` is strictly above the minimum.
If all values equal the min (balanced case), returns the min. -/
def rowSecondMin {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ)
    (i : Fin m) (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) : ℝ :=
  let minVal := rowMin C w i hn
  if h : (Finset.univ.filter (fun j => C i j + w j > minVal)).Nonempty then
    (Finset.univ.filter (fun j => C i j + w j > minVal)).inf' h
      (fun j => C i j + w j)
  else minVal

/-- The tropical energy gap for row `i`. -/
def rowGap {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) (w : Fin n → ℝ)
    (i : Fin m) (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) : ℝ :=
  rowSecondMin C w i hn - rowMin C w i hn

/-- The tropical energy of a fold state `w` for crease matrix `C`:
the sum over rows of the gap between the second-smallest and smallest values.
Measures how far `w` is from being a valid fold. Energy ≥ 0 always, and
energy = 0 iff every row is balanced. -/
def TropicalEnergy {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (w : Fin n → ℝ) (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) : ℝ :=
  ∑ i : Fin m, rowGap C w i hn

/-! ## Gauge equivalence and classification -/

/-- Two weight vectors are gauge equivalent if they differ by a global constant. -/
def GaugeEquivalent {n : ℕ} (w v : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ j : Fin n, v j = w j + c

/-- Two crease matrices have the same rigid basis class if they have
exactly the same valid fold space. -/
def SameRigidBasisClass {m n : ℕ}
    (C D : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∀ w : Fin n → ℝ, IsTropicallyValid C w ↔ IsTropicallyValid D w

/-- Two crease matrices are tropical row-shift equivalent if `D` is obtained
from `C` by adding a constant to each row. -/
def TropicalRowShiftEquivalent {m n : ℕ}
    (C D : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ a : Fin m → ℝ, ∀ i j, D i j = C i j + a i

/-- Two crease matrices are tropical gauge equivalent if `D` is obtained
from `C` by adding row constants and column constants. -/
def TropicalGaugeEquivalent {m n : ℕ}
    (C D : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∃ a : Fin m → ℝ, ∃ b : Fin n → ℝ,
    ∀ i j, D i j = C i j + a i + b j

/-! ## Miura/Monge matrices -/

/-- A crease matrix satisfies the Monge equality (is a Miura matrix) if
`C i₁ j₁ + C i₂ j₂ = C i₁ j₂ + C i₂ j₁` for all `i₁ < i₂`, `j₁ < j₂`.
This is equivalent to `C` being additively decomposable: `C i j = f i + g j`. -/
def IsMiuraMatrix {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ) : Prop :=
  ∀ i₁ i₂ : Fin m, ∀ j₁ j₂ : Fin n,
    i₁.val < i₂.val → j₁.val < j₂.val →
    C i₁ j₁ + C i₂ j₂ = C i₁ j₂ + C i₂ j₁

/-- A Miura matrix admits an additive decomposition: there exist row function `f`
and column function `g` such that `C i j = f i + g j` for all `i, j`. -/
def HasAdditiveDecomposition {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (f : Fin m → ℝ) (g : Fin n → ℝ) : Prop :=
  ∀ i j, C i j = f i + g j

end