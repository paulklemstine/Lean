/-
# Erdős–Straus Conjecture: Core Definitions

This module defines the fundamental structures and predicates for studying
Egyptian fraction decompositions of 4/n, the central object of the
Erdős–Straus conjecture (1948).

The conjecture asserts that for every integer n ≥ 2, the fraction 4/n
can be written as a sum of three unit fractions:
  4/n = 1/x + 1/y + 1/z
with x, y, z positive integers.

We provide two equivalent formulations:
1. `ESDecomposition n` — a structure carrying rational-equation witnesses
2. `ESWitness n x y z` — a denominator-cleared integer predicate:
     4·x·y·z = n·(x·y + x·z + y·z)

The integer form is the affine cubic surface viewpoint: solutions are
positive lattice points on 4xyz = n(xy + xz + yz).
-/

import Mathlib

/-! ## Core structures and predicates -/

/-- A certified Egyptian-fraction decomposition of 4/n into three unit fractions. -/
structure ESDecomposition (n : ℕ) where
  x : ℕ
  y : ℕ
  z : ℕ
  hx : 1 ≤ x
  hy : 1 ≤ y
  hz : 1 ≤ z
  eqn : (4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z

/-- Denominator-cleared predicate: 4xyz = n(xy + xz + yz).
    This is the integer surface formulation of the Erdős–Straus equation. -/
def ESWitness (n x y z : ℕ) : Prop :=
  1 ≤ x ∧ 1 ≤ y ∧ 1 ≤ z ∧
  (4 * x * y * z : ℤ) = (n : ℤ) * ((x : ℤ) * y + (x : ℤ) * z + (y : ℤ) * z)

/-- Ordered witnesses: x ≤ y ≤ z. This normal form reduces the search space
    and connects to discrete geometry of the solution set. -/
def OrderedESWitness (n x y z : ℕ) : Prop :=
  ESWitness n x y z ∧ x ≤ y ∧ y ≤ z

/-- The solution surface for a given n, viewed as a set of lattice points. -/
def ESSurface (n : ℕ) : Set (ℕ × ℕ × ℕ) :=
  {p | ESWitness n p.1 p.2.1 p.2.2}

/-! ## The full conjecture and bounded verification -/

/-- The Erdős–Straus conjecture: every n ≥ 2 admits a 3-term Egyptian
    fraction decomposition of 4/n. -/
def ErdosStrausConjecture : Prop :=
  ∀ n : ℕ, 2 ≤ n → ∃ x y z : ℕ,
    1 ≤ x ∧ 1 ≤ y ∧ 1 ≤ z ∧
    (4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z

/-- Bounded verification: the conjecture holds for all n in [2, N]. -/
def VerifiedUpTo (N : ℕ) : Prop :=
  ∀ n : ℕ, 2 ≤ n → n ≤ N →
    ∃ x y z : ℕ, ESWitness n x y z

/-! ## Conjectures -/

/-- Conjecture: every n ≥ 2 has an ordered witness with x ≤ n. -/
def ESOrderedSmallFirstDenominatorConjecture : Prop :=
  ∀ n : ℕ, 2 ≤ n →
    ∃ x y z : ℕ,
      OrderedESWitness n x y z ∧ x ≤ n

/-! ## Equivalence between rational and integer formulations -/

/-
The rational formulation implies the integer (denominator-cleared) formulation.
-/
theorem ESDecomposition.toWitness {n : ℕ} (d : ESDecomposition n) (hn : 1 ≤ n) :
    ESWitness n d.x d.y d.z := by
  refine' ⟨ d.hx, d.hy, d.hz, _ ⟩;
  convert congr_arg ( fun x : ℚ => x * ( n * d.x * d.y * d.z ) ) d.eqn using 1 ; ring;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( zero_lt_one.trans_le hn ), ne_of_gt ( zero_lt_one.trans_le d.hx ), ne_of_gt ( zero_lt_one.trans_le d.hy ), ne_of_gt ( zero_lt_one.trans_le d.hz ) ];
  norm_cast ; ring

/-
The integer formulation implies the rational formulation (under positivity).
-/
noncomputable def ESWitness.toDecomposition {n x y z : ℕ} (h : ESWitness n x y z) (hn : 1 ≤ n) :
    ESDecomposition n where
  x := x
  y := y
  z := z
  hx := h.1
  hy := h.2.1
  hz := h.2.2.1
  eqn := by
    rcases h with ⟨ hx, hy, hz, h ⟩;
    rw [ div_add_div, div_add_div, div_eq_div_iff ] <;> first | positivity | norm_cast at * ; linarith