/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reverse-and-Add Dynamics: Definitions

This file establishes the foundational definitions for studying Lychrel-type
dynamics in base 10. We formalize the reverse-and-add map, palindrome predicates,
symmetry defects, and digit signatures — the building blocks of an obstruction
theory for palindrome formation.

## Main Definitions

* `digits10`, `ofDigits10` — base-10 digit extraction and reconstruction
* `reverseNat` — digit reversal of a natural number
* `revAdd` — the reverse-and-add map T(n) = n + rev(n)
* `IsPalindromeNat` — palindromicity predicate for naturals
* `revAddIter` — iterated reverse-and-add
* `IsLychrelCandidate` — a number that never reaches a palindrome
* `symmetryDefect` — quantitative measure of non-palindromicity
* `DigitSignature` — reduced state for automata-style analysis
* `PalindromeObstruction` — modular obstruction certificate

## References

* The 196 problem (Lychrel conjecture) is a famous open problem in recreational
  number theory: does the reverse-and-add sequence starting at 196 ever produce
  a palindrome?
-/

import Mathlib

namespace Lychrel

/-! ## Basic Definitions -/

/-- Base-10 digits of a natural number (little-endian: least significant first). -/
def digits10 (n : ℕ) : List ℕ := Nat.digits 10 n

/-- Reconstruct a natural number from its base-10 digit list (little-endian). -/
def ofDigits10 (L : List ℕ) : ℕ := Nat.ofDigits 10 L

/-- Digit reversal: reverse the base-10 digits and reconstruct. -/
def reverseNat (n : ℕ) : ℕ := ofDigits10 (digits10 n).reverse

/-- The reverse-and-add map: T(n) = n + rev(n). -/
def revAdd (n : ℕ) : ℕ := n + reverseNat n

/-- A natural number is a base-10 palindrome if its digits read the same forwards
and backwards. Since `digits10` is little-endian, this means the digit list
equals its own reversal. -/
def IsPalindromeNat (n : ℕ) : Prop :=
  digits10 n = (digits10 n).reverse

/-- Iterated reverse-and-add: apply the map k times starting from n. -/
def revAddIter : ℕ → ℕ → ℕ
  | 0, n => n
  | k + 1, n => revAdd (revAddIter k n)

/-- A Lychrel candidate is a number whose reverse-and-add orbit never reaches a palindrome. -/
def IsLychrelCandidate (n : ℕ) : Prop :=
  ∀ k : ℕ, ¬ IsPalindromeNat (revAddIter k n)

/-! ## Novel Definitions: Symmetry Defect -/

/-- The symmetry defect of a list measures how far it is from being a palindrome.
It sums the absolute differences between mirror-symmetric positions.
A list is a palindrome if and only if its symmetry defect is zero.

This serves as a discrete Lyapunov-like observable for reverse-and-add dynamics. -/
noncomputable def symmetryDefect (L : List ℕ) : ℕ :=
  (List.range (L.length / 2)).map
    (fun i =>
      let j := L.length - 1 - i
      if h₁ : i < L.length then
        if h₂ : j < L.length then
          let a := L.get ⟨i, h₁⟩
          let b := L.get ⟨j, h₂⟩
          if a ≥ b then a - b else b - a
        else 0
      else 0)
  |>.sum

/-! ## Novel Definitions: Digit Signature -/

/-- A `DigitSignature` captures a reduced fingerprint of a number's digit structure,
sufficient for tracking automata-style state transitions under reverse-and-add.

The signature includes digit length, residues modulo 9 and 11 (capturing digit-sum
and alternating-sum invariants), and endpoint digits. -/
structure DigitSignature where
  /-- Number of base-10 digits -/
  len : ℕ
  /-- Residue modulo 9 (digit sum invariant) -/
  mod9 : Fin 9
  /-- Residue modulo 11 (alternating sum invariant) -/
  mod11 : Fin 11
  /-- Least significant digit -/
  lastDigit : Fin 10
  /-- Most significant digit -/
  firstDigit : Fin 10
  deriving Repr, DecidableEq

/-- Compute the digit signature of a natural number. -/
noncomputable def signature (n : ℕ) : DigitSignature where
  len := (digits10 n).length
  mod9 := ⟨n % 9, Nat.mod_lt n (by omega)⟩
  mod11 := ⟨n % 11, Nat.mod_lt n (by omega)⟩
  lastDigit := ⟨n % 10, Nat.mod_lt n (by omega)⟩
  firstDigit :=
    let d := digits10 n
    if h : d = [] then ⟨0, by omega⟩
    else ⟨d.getLast h % 10, Nat.mod_lt _ (by omega)⟩

/-! ## Novel Definitions: Palindrome Obstruction Certificate -/

/-- A `PalindromeObstruction` is a modular certificate proving that all numbers
in a certain residue class modulo `witnessMod` cannot be palindromes.

This encodes a congruence-dynamical sieve: if we can show that the orbit
of 196 remains in an obstructed residue class, we obtain a non-termination
certificate. -/
structure PalindromeObstruction where
  /-- The modulus for the obstruction -/
  witnessMod : ℕ
  /-- The residue class that is obstructed -/
  witnessResid : Fin witnessMod
  /-- Proof that no palindrome lies in this residue class -/
  excludes : ∀ n, n % witnessMod = witnessResid.val → ¬ IsPalindromeNat n

/-! ## Conjectures -/

/-- **The 196 Conjecture (Lychrel Conjecture for 196):**
The reverse-and-add sequence starting at 196 never produces a palindrome.
This is one of the most famous unsolved problems in recreational number theory.

Computationally verified through billions of iterations without finding a palindrome.
A formal proof would require either:
- A carry-dynamical invariant showing the orbit remains in a palindrome-forbidden region, or
- A modular obstruction certificate covering all possible digit configurations. -/
def lychrel196Conjecture : Prop := IsLychrelCandidate 196

/-- **Eventual positive symmetry defect conjecture:**
The symmetry defect of iterates starting at 196 remains strictly positive forever.
This is a strengthening of the Lychrel conjecture that provides a quantitative
observable to track. -/
def eventualPositiveDefect196 : Prop :=
  ∀ k : ℕ, 0 < symmetryDefect (digits10 (revAddIter k 196))

end Lychrel