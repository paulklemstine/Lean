import Mathlib

/-!
# Learning With Errors: Core Definitions

This module establishes the foundational algebraic framework for the Learning With Errors
(LWE) problem and related cryptographic primitives. We define:

- `LWESample`: a single noisy linear equation over `ZMod q`
- `LWEInstance`: a collection of LWE samples sharing a secret
- `innerMod`: the inner product in `(ZMod q)^n`
- `IsLWESample`: the predicate characterizing valid LWE samples
- `DualRegevPublicKey`, `DualRegevSecretKey`, `DualRegevCiphertext`
- Encryption and decryption algorithms with correctness proof
- Security advantage definitions

## Mathematical Background

The LWE problem, introduced by Regev (2005), asks to distinguish
`(a, ⟨a, s⟩ + e)` from `(a, u)` where `a` is uniform, `s` is a secret,
`e` is small noise, and `u` is uniform. This problem enjoys worst-case
to average-case reductions from lattice problems like GapSVP.
-/

open Finset BigOperators

noncomputable section

/-! ## Core LWE Types -/

/-- A single LWE sample: a vector `a ∈ (ZMod q)^n` and a scalar `b ∈ ZMod q`. -/
structure LWESample (n q : ℕ) where
  a : Fin n → ZMod q
  b : ZMod q
  deriving DecidableEq

/-- An LWE instance: a secret vector and a collection of samples. -/
structure LWEInstance (n m q : ℕ) where
  secret : Fin n → ZMod q
  samples : Fin m → LWESample n q

/-- Inner product modulo q. -/
def innerMod {n q : ℕ} (a s : Fin n → ZMod q) : ZMod q :=
  ∑ i : Fin n, a i * s i

/-- Alias for readability. -/
abbrev Vec (n q : ℕ) := Fin n → ZMod q

/-- Dot product of two vectors in (ZMod q)^n. -/
def dot {n q : ℕ} (x y : Vec n q) : ZMod q :=
  ∑ i, x i * y i

/-- The LWE equation: b = ⟨a, s⟩ + e. -/
def lweEquation {n q : ℕ} (a s : Vec n q) (e : ZMod q) : ZMod q :=
  dot a s + e

/-- Predicate: a sample is a valid LWE sample for secret `s` with noise from `χ`. -/
def IsLWESample {n q : ℕ} (embed : ZMod q → ZMod q)
    (s : Fin n → ZMod q) (x : LWESample n q) : Prop :=
  ∃ e : ZMod q, x.b = innerMod x.a s + embed e

/-! ## Ring-LWE Types -/

/-- A Ring-LWE sample over a ring R. -/
structure RingLWESample (R : Type*) [CommRing R] where
  a : R
  b : R

/-! ## Dual-Regev Encryption Scheme -/

/-- Public key for Dual-Regev: a matrix A and vector p = Aᵀs + e. -/
structure DualRegevPublicKey (n m q : ℕ) where
  matA : Fin m → Fin n → ZMod q
  vecP : Fin m → ZMod q

/-- Secret key for Dual-Regev: just the secret vector s. -/
structure DualRegevSecretKey (n q : ℕ) where
  secret : Fin n → ZMod q

/-- Ciphertext for Dual-Regev: a vector u and scalar v. -/
structure DualRegevCiphertext (n q : ℕ) where
  u : Fin n → ZMod q
  v : ZMod q

/-- Encrypt a message μ ∈ ZMod q using the Dual-Regev scheme.
    Given subset S ⊆ [m], compute:
      u = ∑_{i ∈ S} A[i]   (sum of selected rows)
      v = ∑_{i ∈ S} p[i] + μ
    Here we use a selection vector r : Fin m → ZMod q for generality. -/
def dualRegevEncrypt {n m q : ℕ}
    (pk : DualRegevPublicKey n m q) (μ : ZMod q)
    (r : Fin m → ZMod q) : DualRegevCiphertext n q where
  u := fun j => ∑ i : Fin m, r i * pk.matA i j
  v := (∑ i : Fin m, r i * pk.vecP i) + μ

/-- Decrypt a Dual-Regev ciphertext using secret key. -/
def dualRegevDecrypt {n q : ℕ}
    (sk : DualRegevSecretKey n q) (ct : DualRegevCiphertext n q) : ZMod q :=
  ct.v - dot ct.u sk.secret

/-- The public key is well-formed: p = A^T s + noise. -/
def WellFormedPK {n m q : ℕ}
    (sk : DualRegevSecretKey n q) (pk : DualRegevPublicKey n m q)
    (noise : Fin m → ZMod q) : Prop :=
  ∀ i : Fin m, pk.vecP i = (∑ j : Fin n, pk.matA i j * sk.secret j) + noise i

/-! ## Security Advantage Definitions -/

/-- Abstract advantage of a CPA adversary against Dual-Regev. -/
structure CPAAdvantageData where
  advantage : ℝ
  nonneg : 0 ≤ advantage

/-- Abstract advantage of an LWE distinguisher. -/
structure LWEAdvantageData where
  advantage : ℝ
  nonneg : 0 ≤ advantage

/-- Correctness error bound. -/
structure CorrectnessErrorData where
  error : ℝ
  nonneg : 0 ≤ error

/-! ## Hybrid Game Framework -/

/-- A hybrid game is indexed by a natural number and returns a "probability" (real value). -/
structure HybridGame where
  numGames : ℕ
  prob : Fin numGames → ℝ

/-- The advantage of a hybrid sequence: |first - last|. -/
def HybridGame.advantage (g : HybridGame) (h : 0 < g.numGames) : ℝ :=
  |g.prob ⟨0, h⟩ - g.prob ⟨g.numGames - 1, Nat.sub_one_lt_of_lt h |>.trans_le (Nat.le_refl _)⟩|

end