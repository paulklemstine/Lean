/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Modular Collatz Inverse-Branch Theory: Definitions

This file introduces the core definitions for studying the accelerated Collatz map
modulo odd primes p ≠ 3 through its inverse-branch structure.

## Main definitions

* `branchAdmissible p x k` — whether exponent k gives an admissible inverse branch at x
* `branchMultiplicity p K x` — count of admissible branch exponents up to K
* `collatzSymGraph p K` — the symmetrized simple graph on ZMod p

## Key ideas

The accelerated Collatz map T(n) = (3n+1)/2^{v₂(3n+1)} has inverse branches
y ↦ (2^k y - 1)/3 for each k ≥ 1. Working modulo an odd prime p ≠ 3 (so 3 is
invertible), we study which exponents k produce valid preimages in (ZMod p)×.

The branch admissibility depends on k only through 2^k mod p, hence is periodic
with period ord_p(2). This arithmetic structure controls the entire filtration
and the topology of the resulting flag complexes.
-/

import Mathlib

open ZMod Finset

/-! ## Branch admissibility -/

/-- An exponent `k` is an admissible inverse branch at `x ∈ ZMod p` when
    there exists `y ≠ 0` with `3y + 1 = 2^k · x` in `ZMod p`.
    This encodes that `y` is a valid (nonzero) preimage under the accelerated
    Collatz map modulo `p`. -/
def branchAdmissible (p : ℕ) (x : ZMod p) (k : ℕ) : Prop :=
  ∃ y : ZMod p, y ≠ 0 ∧ (3 : ZMod p) * y + 1 = (2 : ZMod p) ^ k * x

/-- Decidability of `branchAdmissible` for prime `p`. -/
instance (p : ℕ) [Fact (Nat.Prime p)] (x : ZMod p) (k : ℕ) :
    Decidable (branchAdmissible p x k) := by
  unfold branchAdmissible
  infer_instance

/-! ## Branch multiplicity -/

/-- The branch multiplicity of `x` is the number of exponents `k ∈ {0, …, K}`
    that are admissible. -/
noncomputable def branchMultiplicity (p K : ℕ) (x : ZMod p) : ℕ :=
  Fintype.card {k : Fin (K + 1) // branchAdmissible p x k.val}

/-! ## Branch profile -/

/-- The branch profile of `x` at depth `K` is the set of admissible exponents. -/
def branchProfile (p K : ℕ) [Fact (Nat.Prime p)] (x : ZMod p) : Finset (Fin (K + 1)) :=
  Finset.univ.filter (fun k => branchAdmissible p x k.val)

/-! ## Symmetrized Collatz graph -/

/-- Symmetric adjacency: `x` and `y` are adjacent if they are distinct and
    some branch exponent witnesses a preimage relation in either direction. -/
def collatzSymAdj' (p K : ℕ) (x y : ZMod p) : Prop :=
  x ≠ y ∧
  (∃ k : Fin (K + 1),
    (3 : ZMod p) * y + 1 = (2 : ZMod p) ^ k.val * x ∨
    (3 : ZMod p) * x + 1 = (2 : ZMod p) ^ k.val * y)

/-- The symmetrized modular Collatz preimage graph on `ZMod p`. -/
noncomputable def collatzSymGraph (p K : ℕ) [Fact (Nat.Prime p)] :
    SimpleGraph (ZMod p) where
  Adj x y := collatzSymAdj' p K x y
  symm x y := by
    intro ⟨hne, k, hk⟩
    exact ⟨hne.symm, k, hk.symm⟩
  loopless := ⟨fun x ⟨hne, _⟩ => hne rfl⟩

/-! ## Graph cycle rank (Betti number surrogate) -/

/-- The cycle rank lower bound of a finite simple graph:
    `|E| - |V| + 1`, which is a lower bound on the first Betti number. -/
noncomputable def graphCycleRankLB {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-! ## Induced 4-cycle -/

/-- Four vertices form an induced 4-cycle in `G` if they are pairwise distinct,
    consecutive ones are adjacent, and non-consecutive ones are not adjacent. -/
def IsInducedCycle4 {V : Type*} (G : SimpleGraph V)
    (v₁ v₂ v₃ v₄ : V) : Prop :=
  v₁ ≠ v₂ ∧ v₁ ≠ v₃ ∧ v₁ ≠ v₄ ∧ v₂ ≠ v₃ ∧ v₂ ≠ v₄ ∧ v₃ ≠ v₄ ∧
  G.Adj v₁ v₂ ∧ G.Adj v₂ v₃ ∧ G.Adj v₃ v₄ ∧ G.Adj v₄ v₁ ∧
  ¬G.Adj v₁ v₃ ∧ ¬G.Adj v₂ v₄

/-! ## Explicit collision condition -/

/-- An explicit arithmetic collision condition that forces an induced 4-cycle:
    there exist four distinct nonzero elements and branch exponents creating
    a cycle of preimage relations with no chords. -/
def explicitCollisionCondition (p K : ℕ) : Prop :=
  ∃ (v₁ v₂ v₃ v₄ : ZMod p) (k₁ k₂ k₃ k₄ : Fin (K + 1)),
    v₁ ≠ v₂ ∧ v₁ ≠ v₃ ∧ v₁ ≠ v₄ ∧ v₂ ≠ v₃ ∧ v₂ ≠ v₄ ∧ v₃ ≠ v₄ ∧
    -- Four edges forming a cycle
    ((3 : ZMod p) * v₂ + 1 = (2 : ZMod p) ^ k₁.val * v₁ ∨
     (3 : ZMod p) * v₁ + 1 = (2 : ZMod p) ^ k₁.val * v₂) ∧
    ((3 : ZMod p) * v₃ + 1 = (2 : ZMod p) ^ k₂.val * v₂ ∨
     (3 : ZMod p) * v₂ + 1 = (2 : ZMod p) ^ k₂.val * v₃) ∧
    ((3 : ZMod p) * v₄ + 1 = (2 : ZMod p) ^ k₃.val * v₃ ∨
     (3 : ZMod p) * v₃ + 1 = (2 : ZMod p) ^ k₃.val * v₄) ∧
    ((3 : ZMod p) * v₁ + 1 = (2 : ZMod p) ^ k₄.val * v₄ ∨
     (3 : ZMod p) * v₄ + 1 = (2 : ZMod p) ^ k₄.val * v₁) ∧
    -- No diagonals
    (∀ j : Fin (K + 1),
      ¬((3 : ZMod p) * v₃ + 1 = (2 : ZMod p) ^ j.val * v₁) ∧
      ¬((3 : ZMod p) * v₁ + 1 = (2 : ZMod p) ^ j.val * v₃)) ∧
    (∀ j : Fin (K + 1),
      ¬((3 : ZMod p) * v₄ + 1 = (2 : ZMod p) ^ j.val * v₂) ∧
      ¬((3 : ZMod p) * v₂ + 1 = (2 : ZMod p) ^ j.val * v₄))