/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Mod-p Spectral Fingerprints: Definitions

## Overview

We define the mathematical framework for determining spectral properties of
bounded-degree arithmetic simplicial complexes from mod-p Laplacian data.

The key insight is that for integer-valued Laplacian matrices with bounded entries,
the characteristic polynomial has bounded integer coefficients. By computing
characteristic polynomials modulo sufficiently many primes (via CRT), we can
recover the exact real characteristic polynomial and hence the spectral gap.

## Main Definitions

- `BoundedInt`: An integer with bounded absolute value
- `PrimeFingerprint`: Collection of mod-p reductions over a set of primes
- `GraphLaplacianData`: Combinatorial Laplacian data for a finite graph
- `SpectralFingerprint`: The mod-p Laplacian data that determines expansion
- `asymptoticSpectralRecovery`: The main conjecture

## References

* Lubotzky, Phillips, Sarnak, "Ramanujan graphs", 1988
* Cheeger, "A lower bound for the smallest eigenvalue of the Laplacian", 1970
-/

open Finset BigOperators

namespace ModPSpectralFingerprint

/-! ## §1. Bounded Integer Vectors and CRT Recovery -/

/-- An integer whose absolute value is bounded by `B`. -/
structure BoundedInt (B : ℕ) where
  val : ℤ
  bound : val.natAbs ≤ B

/-- A collection of mod-p residues for a set of primes. -/
structure PrimeFingerprint where
  /-- The set of primes used. -/
  primes : Finset ℕ
  /-- All elements are prime. -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- The residue data: for each prime p, the residue mod p. -/
  residues : ℕ → ℤ

/-- The fingerprint of an integer z at a set of primes. -/
def intFingerprint (z : ℤ) (_ps : Finset ℕ) : ℕ → ℤ :=
  fun p => z % (p : ℤ)

/-- Two integers are congruent mod p. -/
def congMod (a b : ℤ) (p : ℕ) : Prop := (p : ℤ) ∣ (a - b)

/-- Two integers agree on all fingerprints in a prime set. -/
def agreeOnFingerprint (a b : ℤ) (ps : Finset ℕ) : Prop :=
  ∀ p ∈ ps, congMod a b p

/-! ## §2. Graph Laplacian Data -/

/-- Combinatorial data for a finite graph's Laplacian.
    We abstract the key properties needed: integer entries, bounded degree. -/
structure GraphLaplacianData (n : ℕ) where
  /-- The Laplacian matrix entries (as integers). -/
  entry : Fin n → Fin n → ℤ
  /-- Maximum absolute value of any entry. -/
  maxEntry : ℕ
  /-- Bound on entries. -/
  entries_bounded : ∀ i j, (entry i j).natAbs ≤ maxEntry
  /-- Symmetry of the Laplacian. -/
  symmetric : ∀ i j, entry i j = entry j i

/-- The mod-p reduction of a graph Laplacian. -/
def GraphLaplacianData.modP (L : GraphLaplacianData n) (p : ℕ) :
    Fin n → Fin n → ZMod p :=
  fun i j => (L.entry i j : ZMod p)

/-! ## §3. Spectral Fingerprint Structure -/

/-- A spectral fingerprint collects mod-p Laplacian data over multiple primes.
    This is the "arithmetic-topological" invariant that we conjecture determines
    the real spectral gap. -/
structure SpectralFingerprint (n : ℕ) where
  /-- The underlying Laplacian data. -/
  laplacian : GraphLaplacianData n
  /-- The set of primes used for fingerprinting. -/
  primes : Finset ℕ
  /-- All selected values are prime. -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- Upper bound on primes used (e.g., C · log N). -/
  prime_bound : ℕ
  /-- Primes are bounded. -/
  primes_le_bound : ∀ p ∈ primes, p ≤ prime_bound

/-- The mod-p matrix data extracted from a spectral fingerprint at prime p. -/
def SpectralFingerprint.modPMatrix (sf : SpectralFingerprint n) (p : ℕ) :
    Fin n → Fin n → ZMod p :=
  sf.laplacian.modP p

/-! ## §4. Expansion and Spectral Gap -/

/-- The spectral gap of a symmetric matrix, defined via the Rayleigh quotient.
    For a Laplacian L, this is the smallest nonzero eigenvalue. -/
noncomputable def rayleighQuotientBound (n : ℕ) (L : GraphLaplacianData n) : ℝ :=
  if _h : n = 0 then 0
  else
    let matR : Fin n → Fin n → ℝ := fun i j => (L.entry i j : ℝ)
    sSup {r : ℝ | r ≥ 0 ∧ ∀ (v : Fin n → ℝ),
      (∑ i, v i = 0) →
      (∑ i, v i ^ 2 = 1) →
      ∑ i, ∑ j, matR i j * v i * v j ≥ r}

/-! ## §5. The Recovery Condition -/

/-- The product of primes in a fingerprint is large enough to determine
    any coefficient of the characteristic polynomial.
    For an n×n matrix with entries bounded by D, coefficients are bounded
    by n! · D^n (Hadamard bound). -/
def sufficientPrimes (n : ℕ) (D : ℕ) (ps : Finset ℕ) : Prop :=
  (∏ p ∈ ps, p) > 2 * Nat.factorial n * D ^ n

/-- The conjecture that mod-p fingerprints asymptotically determine spectral gap.
    For a sequence of complexes X_N with N vertices and bounded degree D,
    the spectral gap can be recovered from mod-p data for primes up to C·log(N)
    with vanishing error as N → ∞. -/
def asymptoticSpectralRecovery : Prop :=
  ∀ D : ℕ, D > 0 →
  ∃ C : ℝ, C > 0 ∧
  ∀ ε : ℝ, ε > 0 →
  ∃ N₀ : ℕ,
  ∀ N : ℕ, N ≥ N₀ →
  ∀ (L₁ L₂ : GraphLaplacianData N),
    L₁.maxEntry ≤ D → L₂.maxEntry ≤ D →
    -- If they agree on all primes up to C·log(N)
    (∀ p : ℕ, Nat.Prime p → (p : ℝ) ≤ C * Real.log N →
      L₁.modP p = L₂.modP p) →
    -- Then their spectral gaps are close
    |rayleighQuotientBound N L₁ - rayleighQuotientBound N L₂| ≤ ε

end ModPSpectralFingerprint