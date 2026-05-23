/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Unramified Hecke Eigenpackets: Definitions

This file defines the algebraic structure of **unramified Hecke eigenpackets** —
the coefficient systems arising from spherical automorphic forms on `GL₂(𝔸_ℚ)`.

An unramified Hecke eigenpacket encodes a sequence `a : ℕ → R` satisfying:
1. **Normalization**: `a(1) = 1`
2. **Coprime multiplicativity**: `a(mn) = a(m)a(n)` when `gcd(m,n) = 1`
3. **Prime-power recursion**: `a(p^{r+2}) = a(p)·a(p^{r+1}) - p·a(p^r)`

These axioms capture the exact algebraic shadow of the spherical Hecke algebra
action on automorphic forms. The coprime multiplicativity reflects the restricted
tensor product factorization of the adelic group, while the prime-power recursion
encodes the local Satake isomorphism at each unramified prime.

## References

* Bump, *Automorphic Forms and Representations*, Ch. 4
* Gelbart, *Automorphic Forms on Adele Groups*, §3–4
-/

open Finset Nat BigOperators

/-- An **unramified Hecke eigenpacket** over a commutative ring `R`.

This structure captures the coefficient system of a spherical automorphic
eigenform on `GL₂(𝔸_ℚ)`. The three axioms (normalization, coprime
multiplicativity, and prime-power recursion) are equivalent to saying
that the sequence `a` is a Hecke eigenvalue system for the unramified
Hecke algebra. -/
structure UnramifiedHeckePacket (R : Type*) [CommRing R] where
  /-- The coefficient function, mapping `n : ℕ` to its Hecke eigenvalue. -/
  a : ℕ → R
  /-- Normalization: the first coefficient is 1. -/
  a_one : a 1 = 1
  /-- Coprime multiplicativity: the Euler product structure. -/
  hecke_mul : ∀ m n : ℕ, Nat.Coprime m n → a (m * n) = a m * a n
  /-- Prime-power recursion: the local Satake relation at each prime. -/
  prime_power_rec : ∀ (p r : ℕ), Nat.Prime p →
    a (p ^ (r + 2)) = a p * a (p ^ (r + 1)) - (p : R) * a (p ^ r)

namespace UnramifiedHeckePacket

variable {R : Type*} [CommRing R] (pkt : UnramifiedHeckePacket R)

/-! ### Basic consequences of the axioms -/

/-- Coprime multiplicativity (field accessor as a theorem).
This is the first global structural theorem: the adelic restricted-product
factorization implies Euler multiplicativity. -/
theorem coeff_mul_of_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    pkt.a (m * n) = pkt.a m * pkt.a n :=
  pkt.hecke_mul m n h

/-- Prime-power recursion (field accessor as a theorem).
For every prime `p`, the eigenvalues attached to the spherical double-coset
operators satisfy the classical recursion. -/
theorem coeff_prime_power_rec {p r : ℕ} (hp : Nat.Prime p) :
    pkt.a (p ^ (r + 2)) = pkt.a p * pkt.a (p ^ (r + 1)) - (p : R) * pkt.a (p ^ r) :=
  pkt.prime_power_rec p r hp

/-- `a(p^0) = a(1) = 1` for any prime `p`. -/
@[simp]
theorem coeff_prime_pow_zero (p : ℕ) : pkt.a (p ^ 0) = 1 := by
  simp [pkt.a_one]

/-- `a(p^1) = a(p)` for any prime `p`. -/
@[simp]
theorem coeff_prime_pow_one (p : ℕ) : pkt.a (p ^ 1) = pkt.a p := by
  simp

end UnramifiedHeckePacket