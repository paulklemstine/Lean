/-
Copyright (c) 2025. All rights reserved.

# Beal Obstruction Theory: Core Definitions

This file provides the foundational definitions for the residue-based
obstruction theory for Beal-type Diophantine equations.

## Main Definitions

- `PrimitiveResidueSolution N x y z` — existence of unit-valued residue
  solutions to `a^x + b^y ≡ c^z (mod N)`

## Design

`PrimitiveResidueSolution` uses `ZMod N` and the `IsUnit` predicate,
which captures coprimality to the modulus. This interfaces cleanly
with Mathlib's CRT infrastructure (`ZMod.chineseRemainder`).
-/
import Mathlib

open Finset Nat

/-! ## Primitive Residue Solutions -/

/-- **Primitive Residue Solution**: there exist units `a, b, c` in `ZMod N`
satisfying `a^x + b^y = c^z`.

"Primitive" means all three residues are required to be units (coprime to N).
This captures the essential structure: if a pairwise coprime solution to
`A^x + B^y = C^z` exists over ℤ with `gcd(ABC, N) = 1`, it projects to
a primitive residue solution mod N. -/
def PrimitiveResidueSolution (N x y z : ℕ) : Prop :=
  ∃ a b c : ZMod N, IsUnit a ∧ IsUnit b ∧ IsUnit c ∧ a ^ x + b ^ y = c ^ z

/-- In the trivial ring `ZMod 1`, every equation holds, so primitive residue
solutions always exist. -/
theorem primitiveResidueSolution_mod_one (x y z : ℕ) :
    PrimitiveResidueSolution 1 x y z :=
  ⟨0, 0, 0, isUnit_of_subsingleton _, isUnit_of_subsingleton _,
   isUnit_of_subsingleton _, Subsingleton.elim _ _⟩