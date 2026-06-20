import Mathlib

/-!
# Random tensor network encoding threshold

This file provides the minimal interface used by the Fibonacci anyon chain bridge:
a *critical bond dimension* `critBond n` that a random tensor network must reach in
order to faithfully encode a length-`n` chain.

We model the critical bond dimension as growing linearly with the chain length `n`.
A chain of length `n` can be encoded by a network of bond dimension `D` exactly when
`critBond n < D`.
-/

namespace Physics.RandomTensorNetwork

/-- Critical bond dimension required to encode a length-`n` chain in a random tensor
network.  It increases linearly with the chain length. -/
noncomputable def critBond (n : ℕ) : ℝ := 1 + (n : ℝ) / 10

@[simp] lemma critBond_zero : critBond 0 = 1 := by simp [critBond]

lemma critBond_succ (n : ℕ) : critBond (n + 1) = critBond n + 1 / 10 := by
  simp only [critBond, Nat.cast_add, Nat.cast_one]; ring

lemma critBond_strictMono : StrictMono critBond := by
  intro a b hab
  simp only [critBond]
  have : (a : ℝ) < b := by exact_mod_cast hab
  linarith

end Physics.RandomTensorNetwork