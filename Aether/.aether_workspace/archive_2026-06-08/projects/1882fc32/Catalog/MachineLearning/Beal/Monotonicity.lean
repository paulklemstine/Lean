/-
Copyright (c) 2025. All rights reserved.

# Obstruction Monotonicity under Divisibility

## Main Results

- `primitiveResidueSolution_of_dvd`: If `M ∣ N` and there is a primitive
  residue solution mod N, then there is one mod M.
- `no_primitiveResidueSolution_of_dvd`: Contrapositive — an obstruction at
  M propagates to all multiples of M.

## Key Insight

The natural ring homomorphism `ZMod N →+* ZMod M` (for `M ∣ N`) sends
units to units and preserves the polynomial equation. This gives solution
inheritance from `N` to divisors `M`.
-/
import Mathlib
import Speculative.Beal.Defs

open ZMod

/-! ## Solution Inheritance -/

/-
Solutions descend from `N` to any divisor `M`: if `M ∣ N` and
`a^x + b^y = c^z` has unit solutions in `ZMod N`, then it has
unit solutions in `ZMod M`.
-/
theorem primitiveResidueSolution_of_dvd
    {M N x y z : ℕ}
    (hdvd : M ∣ N)
    (hsol : PrimitiveResidueSolution N x y z) :
    PrimitiveResidueSolution M x y z := by
  rcases hsol with ⟨ a, b, c, ha, hb, hc, h ⟩;
  -- Use the ring homomorphism `ZMod.castHom hdvd (ZMod M) : ZMod N →+* ZMod M`.
  set f : ZMod N →+* ZMod M := ZMod.castHom hdvd (ZMod M);
  exact ⟨ f a, f b, f c, ha.map f, hb.map f, hc.map f, by simpa using congr_arg f h ⟩

/-- **Obstruction Monotonicity**: if no primitive residue solution exists
mod M, then none exists mod any multiple of M. One obstructing modulus
annihilates all its multiples. -/
theorem no_primitiveResidueSolution_of_dvd
    {M N x y z : ℕ}
    (hdvd : M ∣ N)
    (hno : ¬ PrimitiveResidueSolution M x y z) :
    ¬ PrimitiveResidueSolution N x y z :=
  fun hsol => hno (primitiveResidueSolution_of_dvd hdvd hsol)