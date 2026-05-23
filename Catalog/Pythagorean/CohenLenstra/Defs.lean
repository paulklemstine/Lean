/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Cohen-Lenstra Heuristics: Definitions

This file introduces the core definitions for formalizing the Cohen-Lenstra heuristics
via the Haar-cokernel bridge. The key insight is that class groups of number fields
follow statistical laws that arise naturally from Haar measure on p-adic integers.

## Main Definitions

* `CohenLenstra.geomProb` — The geometric distribution on ℕ with parameter 1/p,
  representing the pushforward of Haar measure under the p-adic valuation.
* `CohenLenstra.etaPartialProduct` — Finite approximation to the Dedekind-type
  product ∏_{k=1}^{n} (1 - p^{-k}).
* `CohenLenstra.cyclicWeight` — The Cohen-Lenstra weight for cyclic p-groups.
* `CohenLenstra.VirtualClassGroup` — A virtual class group: a function from
  prime indices to nonneg integers that is cofinitely zero.

## Mathematical Context

The Cohen-Lenstra heuristics predict that for imaginary quadratic fields K,
the p-part of Cl(K) is distributed with probability proportional to 1/|Aut(G)|.
For cyclic groups Z/p^k Z, the Cohen-Lenstra probability becomes:

  Prob(Cl_p ≅ Z/p^k Z) = (1 - 1/p) · p^{-k}

This is exactly the geometric distribution — and it arises as the pushforward
of the normalized Haar measure on Z_p under the p-adic valuation map.
-/

open Finset BigOperators

noncomputable section

namespace CohenLenstra

/-! ### The Geometric Distribution from Haar Measure -/

/-- The geometric probability mass function: Prob(v_p = k) = (1 - 1/p) · (1/p)^k.
This is the pushforward of Haar measure on Z_p under the p-adic valuation map. -/
def geomProb (p : ℕ) (k : ℕ) : ℝ :=
  (1 - (p : ℝ)⁻¹) * ((p : ℝ)⁻¹) ^ k

/-- Alternative form: geomProb p k = (p - 1) / p^{k+1}. -/
def geomProbAlt (p : ℕ) (k : ℕ) : ℝ :=
  ((p : ℝ) - 1) / (p : ℝ) ^ (k + 1)

/-! ### The Dedekind Eta-type Product -/

/-- The partial Dedekind-type product ∏_{j=1}^{n} (1 - p^{-j}).
This converges to the inverse of the Cohen-Lenstra normalization constant η_p. -/
def etaPartialProduct (p : ℕ) (n : ℕ) : ℝ :=
  ∏ j ∈ Finset.range n, (1 - ((p : ℝ)⁻¹) ^ (j + 1))

/-- The inverse eta partial product ∏_{j=1}^{n} (1 - p^{-j})⁻¹.
This is the partial product of the Cohen-Lenstra normalizer / partition function. -/
def etaPartialProductInv (p : ℕ) (n : ℕ) : ℝ :=
  ∏ j ∈ Finset.range n, (1 - ((p : ℝ)⁻¹) ^ (j + 1))⁻¹

/-! ### Cohen-Lenstra Weights for Cyclic Groups -/

/-- The Cohen-Lenstra weight for the cyclic p-group Z/p^k Z (k ≥ 1).
Weight = 1 / |Aut(Z/p^k Z)| = 1 / (p^{k-1}(p-1)).
For k = 0 (trivial group), |Aut| = 1, so weight = 1. -/
def cyclicWeight (p : ℕ) (k : ℕ) : ℝ :=
  if k = 0 then 1
  else ((p : ℝ)⁻¹) ^ (k - 1) * ((p : ℝ) - 1)⁻¹

/-! ### Virtual Class Group -/

/-- A virtual class group element: assigns to each prime index a nonneg integer
(representing the p-adic valuation / exponent of the cyclic p-part),
with all but finitely many being zero.

This is the arithmetic analogue of a divisor in algebraic geometry:
a formal sum ∑ a_p · [Z/p^{a_p}Z] where all but finitely many a_p = 0. -/
structure VirtualClassGroup where
  /-- The p-part exponent for each prime index -/
  exponent : ℕ → ℕ
  /-- All but finitely many exponents are zero -/
  cofinite : Set.Finite {i | exponent i ≠ 0}

/-- The trivial virtual class group (all exponents zero). -/
def VirtualClassGroup.trivial : VirtualClassGroup where
  exponent := fun _ => 0
  cofinite := by simp

/-- The order of the finite abelian group represented by a virtual class group,
as a function of the primes. For the i-th prime p_i, contributes p_i^{e_i}. -/
def VirtualClassGroup.order (G : VirtualClassGroup) (primeAt : ℕ → ℕ) : ℕ :=
  ∏ i ∈ G.cofinite.toFinset, primeAt i ^ G.exponent i

/-! ### Bosonic Partition Function Connection -/

/-- The bosonic partition function at inverse temperature β = log(p):
Z(p) = ∏_{k=1}^{∞} (1 - p^{-k})^{-1}.
The finite approximation truncated at level n. -/
def bosonicPartitionPartial (p : ℕ) (n : ℕ) : ℝ :=
  etaPartialProductInv p n

/-! ### Shannon Entropy of the Valuation Distribution -/

/-- The Shannon entropy contribution from the k-th term of the geometric distribution. -/
def entropyTerm (p : ℕ) (k : ℕ) : ℝ :=
  let q := geomProb p k
  if q = 0 then 0 else -q * Real.log q

/-- The target entropy value: H(p) = -log(1-1/p) + log(p)/(p-1).
This is the Shannon entropy of the geometric distribution on p-adic valuations.
For p=2, H ≈ 1.386; for p=3, H ≈ 0.955. -/
def targetEntropy (p : ℕ) : ℝ :=
  -Real.log (1 - (p : ℝ)⁻¹) + Real.log p / ((p : ℝ) - 1)

end CohenLenstra