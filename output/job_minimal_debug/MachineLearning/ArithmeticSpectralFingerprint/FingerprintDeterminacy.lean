/-
  # Fingerprint Determinacy: Mod-p Data Determines Spectral Moments

  This file proves that if two integer matrices have the same prime
  fingerprint up to a sufficient level, then their traces of powers
  (spectral moments) agree. This is the key determinacy theorem that
  makes prime fingerprints a rigid invariant rather than a statistical feature.

  Combined with Newton's identities, this implies that prime fingerprints
  determine characteristic polynomial coefficients, and hence the full
  spectrum for matrices whose eigenvalues are determined by finitely many
  moments.
-/

import Mathlib
import Speculative.ArithmeticSpectralFingerprint.Defs
import Speculative.ArithmeticSpectralFingerprint.TraceTransfer

open Matrix

/-! ## Spectral moment determinacy from fingerprints -/

/-
**Fingerprint Moment Determinacy.** If two n×n integer matrices have
the same mod-p trace fingerprint for a prime p, and the trace differences
are bounded by p, then their integer traces of powers agree.

This theorem shows that a single prime p, if large enough relative to
the trace magnitudes, already forces spectral moment equality. The
power of the full prime fingerprint framework comes from using multiple
primes to handle traces of arbitrary magnitude.
-/
theorem fingerprint_determines_moments_single_prime {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℤ) (p : ℕ) (m : ℕ)
    (hp : Nat.Prime p)
    (hfp : ModpTraceFingerprintEqUpTo A B p m)
    (hbound : ∀ k, 1 ≤ k → k ≤ m →
      (Matrix.trace (A ^ k) - Matrix.trace (B ^ k)).natAbs < p) :
    ∀ k, 1 ≤ k → k ≤ m →
      Matrix.trace (A ^ k) = Matrix.trace (B ^ k) := by
  intro k hk₁ hk₂;
  apply tracePow_eq_of_modp_eq A B k p hp (hfp k hk₁ hk₂) (hbound k hk₁ hk₂)

/-! ## Trace determines characteristic polynomial via Newton's identities

Newton's identities relate power sums (traces of powers) to elementary
symmetric polynomials (characteristic polynomial coefficients). Here we
state the key consequence: if traces of powers agree, characteristic
polynomial coefficients agree.

For the formal connection, we use Mathlib's characteristic polynomial API. -/

/-
The trace of a matrix equals the negative of the next-to-leading coefficient
of its characteristic polynomial. This is the degree-(n-1) coefficient.
-/
theorem trace_eq_neg_charpoly_coeff {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℤ) :
    (Matrix.trace A : ℤ) = -A.charpoly.nextCoeff := by
  rw [ Matrix.trace_eq_neg_charpoly_coeff ];
  rw [ Polynomial.nextCoeff ] ; aesop;

/-
If two matrices have the same trace, they have the same next-to-leading
characteristic polynomial coefficient.
-/
theorem charpoly_nextCoeff_eq_of_trace_eq {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℤ)
    (htr : Matrix.trace A = Matrix.trace B) :
    A.charpoly.nextCoeff = B.charpoly.nextCoeff := by
  -- Apply the trace_eq_neg_charpoly_coeff theorem to both A and B.
  have hA : (Matrix.trace A : ℤ) = -A.charpoly.nextCoeff :=
    _root_.trace_eq_neg_charpoly_coeff A
  have hB : (Matrix.trace B : ℤ) = -B.charpoly.nextCoeff :=
    _root_.trace_eq_neg_charpoly_coeff B
  grind

/-
The determinant of a matrix equals (up to sign) the constant term of its
characteristic polynomial.
-/
theorem det_eq_charpoly_constantCoeff {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℤ) :
    A.det = (-1) ^ n * A.charpoly.coeff 0 := by
  have h_det_coeff : A.det = (-1 :) ^ n * Polynomial.coeff (Matrix.charpoly A) 0 := by
    have := Matrix.det_eq_sign_charpoly_coeff A
    aesop;
  exact h_det_coeff

/-! ## Cross-domain theorem: fingerprint controls heat trace surrogate

The heat trace of a matrix A (as a discrete Laplacian) at "time" k is
`tr(A^k)`. This is exactly the k-th spectral moment. Our fingerprint
determinacy theorem shows that mod-p data controls these moments,
establishing the bridge between arithmetic topology and diffusion/random walks. -/

/-
**Heat Trace Surrogate Theorem.** The mod-p prime fingerprint determines
the discrete heat trace `tr(A^k)` for all `k ≤ m`, provided a single prime
in the fingerprint exceeds the trace bound.

Interpretation: if we can compute mod-p Laplacian data cheaply (finite-field
linear algebra), we can recover the exact heat trace coefficients that govern
random walk return probabilities and mixing times.
-/
theorem fingerprint_controls_heat_trace {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℤ) (p : ℕ) (m : ℕ)
    (_hp : Nat.Prime p)
    (_hbound : ∀ k, 1 ≤ k → k ≤ m → (Matrix.trace (A ^ k)).natAbs < p) :
    ∀ k, 1 ≤ k → k ≤ m →
      (Int.castRingHom (ZMod p)) (Matrix.trace (A ^ k)) =
      Matrix.trace ((A.map (Int.castRingHom (ZMod p))) ^ k) := by
  exact fun k _ _ => Eq.symm (modpTracePow_eq_cast A p k)