/-
  # Arithmetic Spectral Fingerprints: Definitions

  This file introduces the core definitions for the theory of mod-p spectral
  fingerprints of integer matrices. The key idea is that reducing a matrix
  modulo small primes and studying rank/nullity patterns yields arithmetic
  invariants that constrain real spectral data.
-/

import Mathlib

open Matrix Finset

/-! ## Core Definitions -/

/-- The mod-p trace of a power of an integer matrix. This is the fundamental
observable: for each prime p and exponent k, we record `tr(A^k) mod p`. -/
noncomputable def modpTracePow {n : ℕ} (A : Matrix (Fin n) (Fin n) ℤ) (p : ℕ) (k : ℕ) : ZMod p :=
  Matrix.trace ((A.map (Int.castRingHom (ZMod p))) ^ k)

/-- Two integer matrices have the same mod-p trace fingerprint up to degree m
if their traces of powers agree modulo p for all exponents 1 ≤ k ≤ m. -/
def ModpTraceFingerprintEqUpTo {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℤ) (p : ℕ) (m : ℕ) : Prop :=
  ∀ k, 1 ≤ k → k ≤ m → modpTracePow A p k = modpTracePow B p k

/-- Two integer matrices have the same prime fingerprint up to level m if
their mod-p trace fingerprints agree for all primes p ≤ m, up to degree m. -/
def PrimeFingerprintEqUpTo {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℤ) (m : ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ≤ m → ModpTraceFingerprintEqUpTo A B p m

/-- A prime spectral fingerprint bundles the mod-p trace data for all primes
up to a bound and all powers up to a bound. -/
structure PrimeFingerprint (n : ℕ) where
  /-- The underlying integer matrix -/
  matrix : Matrix (Fin n) (Fin n) ℤ
  /-- Prime bound -/
  primeBound : ℕ
  /-- Power/degree bound -/
  degreeBound : ℕ

/-- Extract the fingerprint data from a PrimeFingerprint. -/
noncomputable def PrimeFingerprint.data {n : ℕ} (fp : PrimeFingerprint n)
    (p : ℕ) (k : ℕ) : ZMod p :=
  modpTracePow fp.matrix p k

/-- Two prime fingerprints are equivalent if they agree on all (prime, degree) pairs
within bounds. -/
def PrimeFingerprint.equiv {n : ℕ} (fp1 fp2 : PrimeFingerprint n) : Prop :=
  ∀ p, Nat.Prime p → p ≤ min fp1.primeBound fp2.primeBound →
    ∀ k, 1 ≤ k → k ≤ min fp1.degreeBound fp2.degreeBound →
      fp1.data p k = fp2.data p k

/-- An expansion witness asserts that mod-p rank data provides a lower bound
on a spectral-gap surrogate measured by trace data. -/
structure ExpansionWitness (n : ℕ) where
  /-- The matrix being analyzed -/
  matrix : Matrix (Fin n) (Fin n) ℤ
  /-- The spectral gap lower bound (rational surrogate) -/
  gapBound : ℚ
  /-- The set of primes witnessing the expansion -/
  primeBound : ℕ
  /-- The witness condition: traces of low powers are controlled -/
  witness : ∀ p, Nat.Prime p → p ≤ primeBound →
    ∀ k, 1 ≤ k → k ≤ primeBound →
      modpTracePow matrix p k = modpTracePow matrix p 0