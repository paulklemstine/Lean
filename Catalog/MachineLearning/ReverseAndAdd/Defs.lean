/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reverse-and-Add Dynamics: Definitions

This file establishes the formal framework for studying reverse-and-add dynamics
on natural numbers in arbitrary bases. The key objects are:

- `reverseDigits b n`: the number obtained by reversing the base-`b` digits of `n`
- `isPalindromeBase b n`: the proposition that `n` is a palindrome in base `b`
- `revAddStep b n`: one step of the reverse-and-add algorithm: `n + reverseDigits b n`
- `revAddIter b k n`: `k` iterations of reverse-and-add starting from `n`
- `LychrelCandidateBase b n`: the proposition that `n` never reaches a palindrome

These definitions use Mathlib's `Nat.digits` (least-significant-digit first) and
`Nat.ofDigits` as the underlying digit representation.
-/

import Mathlib

namespace ReverseAndAdd

/-! ## Core Definitions -/

/-- The digits of `n` in base `b`, least-significant first.
    This is simply `Nat.digits b n`. -/
def digitsBase (b n : Nat) : List Nat := Nat.digits b n

/-- Reconstruct a number from its base-`b` digit list (least-significant first). -/
def ofDigitsBase (b : Nat) (l : List Nat) : Nat := Nat.ofDigits b l

/-- The digit-reversal of `n` in base `b`: reverse the base-`b` digits of `n`
    and reinterpret as a number. -/
def reverseDigits (b n : Nat) : Nat :=
  ofDigitsBase b (digitsBase b n).reverse

/-- A number is a palindrome in base `b` if its digit sequence equals its reverse. -/
def isPalindromeBase (b n : Nat) : Prop :=
  digitsBase b n = (digitsBase b n).reverse

/-- One step of the reverse-and-add algorithm in base `b`. -/
def revAddStep (b n : Nat) : Nat := n + reverseDigits b n

/-- `k` iterations of reverse-and-add starting from `n` in base `b`. -/
def revAddIter (b : Nat) (k : Nat) (n : Nat) : Nat :=
  Nat.iterate (revAddStep b) k n

/-- A number `n` is a Lychrel candidate in base `b` if no iterate of
    reverse-and-add ever produces a palindrome. This is the formal statement
    of the conjecture that the orbit of `n` avoids palindromes forever. -/
def LychrelCandidateBase (b n : Nat) : Prop :=
  ∀ k : Nat, ¬ isPalindromeBase b (revAddIter b k n)

/-- The number of digits of `n` in base `b`. -/
noncomputable def numDigitsBase (b n : Nat) : Nat := (digitsBase b n).length

/-- The set of residues modulo `m` achieved by base-`b` palindromes
    with at most `L` digits. This is defined as the image of the set
    of palindromic numbers up to `b^L` under `· % m`. -/
instance isPalindromeBase_decidable (b n : Nat) : Decidable (isPalindromeBase b n) :=
  inferInstanceAs (Decidable (_ = _))

def palindromeResiduesUpToLength (b m L : Nat) : Finset Nat :=
  ((Finset.range (b ^ L)).filter (fun n => isPalindromeBase b n)).image (· % m)

/-! ## Basic Unfolding Lemmas -/

@[simp] theorem digitsBase_def (b n : Nat) : digitsBase b n = Nat.digits b n := rfl
@[simp] theorem ofDigitsBase_def (b : Nat) (l : List Nat) :
    ofDigitsBase b l = Nat.ofDigits b l := rfl

theorem reverseDigits_def (b n : Nat) :
    reverseDigits b n = Nat.ofDigits b (Nat.digits b n).reverse := rfl

theorem revAddStep_def (b n : Nat) :
    revAddStep b n = n + reverseDigits b n := rfl

theorem revAddIter_zero (b n : Nat) :
    revAddIter b 0 n = n := rfl

theorem revAddIter_succ (b k n : Nat) :
    revAddIter b (k + 1) n = revAddStep b (revAddIter b k n) := by
  simp [revAddIter, Function.iterate_succ_apply']

end ReverseAndAdd