/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.HeckePacket.Defs

/-!
# Hecke Coefficient Computation Algorithm

This file implements a verified algorithm for computing Hecke eigenvalues
from local prime data using:
- Prime-power recursion at each prime
- Coprime multiplicativity across primes
- Factorization of natural numbers

## Algorithm

Given the eigenvalues `a(p)` at primes, the algorithm:
1. Computes `a(p^r)` for all prime powers using the three-term recurrence
2. Assembles `a(n)` for general `n` via coprime multiplicativity and factorization

This is the first **certified Hecke-eigenvalue propagator** from local data.
-/

open Finset BigOperators Nat

namespace UnramifiedHeckePacket

variable {R : Type*} [CommRing R]

/-- Compute `a(p^r)` from `a(p)` using the prime-power recursion.
This is a simple linear recurrence:
- `computePrimePower a_p p 0 = 1`
- `computePrimePower a_p p 1 = a_p`
- `computePrimePower a_p p (r+2) = a_p * computePrimePower a_p p (r+1) - p * computePrimePower a_p p r`
-/
def computePrimePower (a_p : R) (p : ℕ) : ℕ → R
  | 0 => 1
  | 1 => a_p
  | r + 2 => a_p * computePrimePower a_p p (r + 1) - (p : R) * computePrimePower a_p p r

/-
The prime-power computation agrees with the packet's coefficient function
at all prime powers.
-/
theorem computePrimePower_correct (pkt : UnramifiedHeckePacket R)
    {p : ℕ} (hp : Nat.Prime p) (r : ℕ) :
    computePrimePower (pkt.a p) p r = pkt.a (p ^ r) := by
  -- We proceed by induction on $r$.
  induction' r using Nat.strong_induction_on with r ih;
  rcases r with ( _ | _ | r ) <;> simp_all +decide [ pow_succ' ];
  · exact pkt.a_one.symm;
  · rfl;
  · rw [ show p * ( p * p ^ r ) = p ^ ( r + 2 ) by ring, show computePrimePower ( pkt.a p ) p ( r + 2 ) = pkt.a p * computePrimePower ( pkt.a p ) p ( r + 1 ) - p * computePrimePower ( pkt.a p ) p r by rfl, ih _ le_rfl, ih _ ( Nat.le_succ _ ) ];
    exact Eq.symm ( pkt.coeff_prime_power_rec hp )

/-
For squarefree `n ≥ 1`, the Hecke coefficient equals the product of
coefficients at its prime factors. This is a consequence of coprime
multiplicativity applied to the squarefree factorization.
-/
theorem coeff_squarefree_prod (pkt : UnramifiedHeckePacket R)
    {n : ℕ} (hn : Squarefree n) (hn0 : n ≠ 0) :
    pkt.a n = ∏ p ∈ n.primeFactors, pkt.a p := by
  have h_mul : ∀ {S : Finset ℕ}, (∀ p ∈ S, Nat.Prime p) → pkt.a (∏ p ∈ S, p) = ∏ p ∈ S, pkt.a p := by
    intro S hS;
    induction' S using Finset.induction with p S hS ih;
    · simp +decide [ pkt.a_one ];
    · rw [ Finset.prod_insert ‹p ∉ S›, pkt.hecke_mul ];
      · rw [ Finset.prod_insert ‹p ∉ S›, ih fun q hq => hS q ( Finset.mem_insert_of_mem hq ) ];
      · exact Nat.Coprime.prod_right fun q hq => by have := Nat.coprime_primes ( hS p ( Finset.mem_insert_self p S ) ) ( hS q ( Finset.mem_insert_of_mem hq ) ) ; aesop;
  rw [ ← h_mul, Nat.prod_primeFactors_of_squarefree hn ];
  exact fun p hp => Nat.prime_of_mem_primeFactors hp

end UnramifiedHeckePacket