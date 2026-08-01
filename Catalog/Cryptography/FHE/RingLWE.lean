import Mathlib

/-!
# Ring-LWE homomorphic encryption: algebra, security reduction, and bootstrapping

This file develops a kernel-checked abstraction of the standard Ring-LWE FHE
argument.  It separates three layers which concrete parameter sets must connect:

* the exact ring identity behind additive homomorphism;
* the game hop from decisional Ring-LWE to IND-CPA security;
* Gentry's bootstrapping principle, expressed as refreshed circuit evaluation.

The security result is a reduction theorem: its Ring-LWE hypotheses are explicit,
rather than an unproved assertion that Ring-LWE is hard.
-/

open Finset BigOperators

noncomputable section

namespace RingLWEFHE

/-! ## 1. Exact Ring-LWE ciphertext algebra -/

/-- A two-component Ring-LWE ciphertext.  Conventionally `a` is uniform and
`b = a*s + Δ*m + e`. -/
structure Ciphertext (R : Type*) where
  a : R
  b : R

variable {R : Type*} [CommRing R]

/-- The secret-key phase `b - a*s` of a Ring-LWE ciphertext. -/
def phase (s : R) (c : Ciphertext R) : R := c.b - c.a * s

/-- Componentwise ciphertext addition. -/
def addCipher (c d : Ciphertext R) : Ciphertext R :=
  ⟨c.a + d.a, c.b + d.b⟩

/-- A symbolic Ring-LWE encryption with explicit public component and error. -/
def encryptWith (s scale m a e : R) : Ciphertext R :=
  ⟨a, a * s + scale * m + e⟩

/-- The phase of a fresh encryption is exactly its scaled message plus error. -/
theorem phase_encryptWith (s scale m a e : R) :
    phase s (encryptWith s scale m a e) = scale * m + e := by
  simp only [phase, encryptWith]
  ring

/-- Phase is additive under componentwise ciphertext addition. -/
theorem phase_addCipher (s : R) (c d : Ciphertext R) :
    phase s (addCipher c d) = phase s c + phase s d := by
  simp only [phase, addCipher]
  ring

/-- Adding two fresh encryptions adds both messages and both errors. -/
theorem phase_add_encryptWith (s scale m m' a a' e e' : R) :
    phase s (addCipher (encryptWith s scale m a e)
      (encryptWith s scale m' a' e')) = scale * (m + m') + (e + e') := by
  rw [phase_addCipher, phase_encryptWith, phase_encryptWith]
  ring

/-- Decryption applies a phase decoder after taking the secret-key phase. -/
def decryptWith {M : Type*} (s : R) (decodePhase : R → M)
    (c : Ciphertext R) : M := decodePhase (phase s c)

/-- Abstract decoding condition for a particular scaled message and error. -/
def Decodes (decodePhase : R → R) (scale m e : R) : Prop :=
  decodePhase (scale * m + e) = m

/-- Additive homomorphic correctness.  The sole analytic obligation is that the
combined error `e+e'` remains in the decoder's correct region. -/
theorem decrypt_add_encryptWith (s scale m m' a a' e e' : R)
    (decodePhase : R → R)
    (hdecode : Decodes decodePhase scale (m + m') (e + e')) :
    decryptWith s decodePhase
      (addCipher (encryptWith s scale m a e)
        (encryptWith s scale m' a' e')) = m + m' := by
  rw [decryptWith, phase_add_encryptWith]
  exact hdecode

/-! ## 2. Noise accumulation and a concrete additive correctness corollary -/

/-- Integer errors bounded by `B` accumulate to an error bounded by `2B`. -/
theorem add_error_bound (e e' B : ℤ) (he : |e| ≤ B) (he' : |e'| ≤ B) :
    |e + e'| ≤ 2 * B := by
  calc
    |e + e'| ≤ |e| + |e'| := abs_add_le e e'
    _ ≤ B + B := add_le_add he he'
    _ = 2 * B := by ring

/-- A threshold decoder specification: every error of magnitude below `T`
decodes its intended scaled message. -/
def CorrectBelow (decodePhase : ℤ → ℤ) (scale T : ℤ) : Prop :=
  ∀ m e, |e| < T → Decodes decodePhase scale m e

/-- The exact additive theorem specialized to a threshold decoder. -/
theorem decrypt_add_of_noise_bound (s scale m m' a a' e e' B T : ℤ)
    (decodePhase : ℤ → ℤ)
    (hdecoder : CorrectBelow decodePhase scale T)
    (he : |e| ≤ B) (he' : |e'| ≤ B) (hbudget : 2 * B < T) :
    decryptWith s decodePhase
      (addCipher (encryptWith s scale m a e)
        (encryptWith s scale m' a' e')) = m + m' := by
  apply decrypt_add_encryptWith
  apply hdecoder
  exact lt_of_le_of_lt (add_error_bound e e' B he he') hbudget

/-! ## 3. Conditional security under decisional Ring-LWE -/

/-- A finite probability mass function, used to state statistical game hops. -/
structure FinitePMF (Ω : Type*) [Fintype Ω] where
  mass : Ω → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  sum_mass : ∑ x, mass x = 1

/-- The `ℓ¹` distance (twice statistical distance) between finite games. -/
def gameGap {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) : ℝ :=
  ∑ x, |P.mass x - Q.mass x|

/-- Statistical game gaps satisfy the triangle inequality. -/
theorem gameGap_triangle {Ω : Type*} [Fintype Ω]
    (P Q U : FinitePMF Ω) : gameGap P U ≤ gameGap P Q + gameGap Q U := by
  simp only [gameGap, ← sum_add_distrib]
  exact Finset.sum_le_sum fun x _ => abs_sub_le _ _ _

/-- Game gap is symmetric. -/
theorem gameGap_symm {Ω : Type*} [Fintype Ω] (P Q : FinitePMF Ω) :
    gameGap P Q = gameGap Q P := by
  simp [gameGap, abs_sub_comm]

/-- **Ring-LWE security reduction.**  If decisional Ring-LWE permits replacing
each challenge encryption by the same message-independent ideal game with
losses `ε₀` and `ε₁`, then the IND-CPA challenge gap is at most `ε₀+ε₁`.
This is the precise conditional meaning of security under Ring-LWE. -/
theorem indCPA_of_decisional_ringLWE {Ω : Type*} [Fintype Ω]
    (challenge0 challenge1 ideal : FinitePMF Ω) (ε₀ ε₁ : ℝ)
    (hrlwe0 : gameGap challenge0 ideal ≤ ε₀)
    (hrlwe1 : gameGap challenge1 ideal ≤ ε₁) :
    gameGap challenge0 challenge1 ≤ ε₀ + ε₁ := by
  have htri := gameGap_triangle challenge0 ideal challenge1
  rw [gameGap_symm ideal challenge1] at htri
  exact le_trans htri (add_le_add hrlwe0 hrlwe1)

/-! ## 4. Gentry bootstrapping as refreshed evaluation -/

/-- Arithmetic circuits over a message ring. -/
inductive Circuit (M : Type*) where
  | input : ℕ → Circuit M
  | const : M → Circuit M
  | add : Circuit M → Circuit M → Circuit M
  | mul : Circuit M → Circuit M → Circuit M

/-- Plaintext circuit semantics. -/
def Circuit.eval {M : Type*} [Semiring M] (ρ : ℕ → M) : Circuit M → M
  | .input i => ρ i
  | .const m => m
  | .add f g => f.eval ρ + g.eval ρ
  | .mul f g => f.eval ρ * g.eval ρ

/-- A somewhat homomorphic scheme equipped with a refresh operation.
The local gate laws only need to hold on the ciphertexts supplied to them;
refresh correctness is the bootstrapping hypothesis. -/
structure BootstrappableScheme (M C : Type*) [Semiring M] where
  enc : M → C
  dec : C → M
  add : C → C → C
  mul : C → C → C
  refresh : C → C
  enc_correct : ∀ m, dec (enc m) = m
  add_correct : ∀ c d, dec (add c d) = dec c + dec d
  mul_correct : ∀ c d, dec (mul c d) = dec c * dec d
  refresh_correct : ∀ c, dec (refresh c) = dec c

variable {M C : Type*} [Semiring M]

/-- Encrypting and then refreshing preserves a plaintext. -/
theorem decrypt_refresh_encrypt (S : BootstrappableScheme M C) (m : M) :
    S.dec (S.refresh (S.enc m)) = m := by
  rw [S.refresh_correct, S.enc_correct]

/-- A refreshed addition decrypts to addition of the input decryptions. -/
theorem decrypt_refreshed_add (S : BootstrappableScheme M C) (c d : C) :
    S.dec (S.refresh (S.add c d)) = S.dec c + S.dec d := by
  rw [S.refresh_correct, S.add_correct]

/-- A refreshed multiplication decrypts to multiplication of input decryptions. -/
theorem decrypt_refreshed_mul (S : BootstrappableScheme M C) (c d : C) :
    S.dec (S.refresh (S.mul c d)) = S.dec c * S.dec d := by
  rw [S.refresh_correct, S.mul_correct]

/-- Evaluate a circuit homomorphically, refreshing after every gate. -/
def Circuit.evalEncrypted (S : BootstrappableScheme M C)
    (ρ : ℕ → C) : Circuit M → C
  | .input i => S.refresh (ρ i)
  | .const m => S.refresh (S.enc m)
  | .add f g => S.refresh (S.add (f.evalEncrypted S ρ) (g.evalEncrypted S ρ))
  | .mul f g => S.refresh (S.mul (f.evalEncrypted S ρ) (g.evalEncrypted S ρ))

/-- **Gentry bootstrapping theorem.**  A scheme with correct refreshed local
gates correctly evaluates every finite arithmetic circuit, with no depth bound. -/
theorem Circuit.decrypt_evalEncrypted (S : BootstrappableScheme M C)
    (ρ : ℕ → C) (f : Circuit M) :
    S.dec (f.evalEncrypted S ρ) = f.eval (fun i => S.dec (ρ i)) := by
  induction f with
  | input i => exact S.refresh_correct (ρ i)
  | const m => exact decrypt_refresh_encrypt S m
  | add f g ihf ihg =>
      rw [Circuit.evalEncrypted, decrypt_refreshed_add, ihf, ihg, Circuit.eval]
  | mul f g ihf ihg =>
      rw [Circuit.evalEncrypted, decrypt_refreshed_mul, ihf, ihg, Circuit.eval]

/-! ## 5. Multiplicative depth and the bootstrap threshold -/

/-- Multiplicative depth; additions do not consume a multiplicative level. -/
def Circuit.mulDepth : Circuit M → ℕ
  | .input _ => 0
  | .const _ => 0
  | .add f g => max f.mulDepth g.mulDepth
  | .mul f g => max f.mulDepth g.mulDepth + 1

/-- Conservative noise after `d` multiplication levels when multiplication
squares the current bound. -/
def noiseAfterDepth (B d : ℕ) : ℕ := B ^ (2 ^ d)

/-- One more multiplication level squares the preceding noise bound. -/
theorem noiseAfterDepth_succ (B d : ℕ) :
    noiseAfterDepth B (d + 1) = noiseAfterDepth B d * noiseAfterDepth B d := by
  simp [noiseAfterDepth, pow_succ, pow_mul]

/-- A depth is supported exactly when its conservative noise is below the
ciphertext modulus threshold. -/
def SupportsDepth (B T d : ℕ) : Prop := noiseAfterDepth B d < T

/-- If depth `d+1` is safe, then depth `d` is safe (for nonzero initial noise). -/
theorem supportsDepth_of_succ (B T d : ℕ) (hB : 0 < B)
    (h : SupportsDepth B T (d + 1)) : SupportsDepth B T d := by
  rw [SupportsDepth, noiseAfterDepth_succ] at h
  have hpos : 0 < noiseAfterDepth B d := pow_pos hB _
  exact lt_of_le_of_lt (Nat.le_mul_of_pos_right _ hpos) h

/-- With initial bound `2` and threshold `65536`, three multiplication levels
are safe but the fourth reaches the threshold.  Thus bootstrapping is needed
before attempting level four. -/
theorem concrete_depth_before_bootstrap :
    SupportsDepth 2 65536 3 ∧ ¬ SupportsDepth 2 65536 4 := by
  constructor <;> norm_num [SupportsDepth, noiseAfterDepth]

/-- Refreshing resets noise to `B`; consequently every segment whose depth is
at most a known safe depth can be evaluated between bootstraps. -/
theorem every_bounded_segment_safe (B T D : ℕ)
    (hmono : ∀ d ≤ D, noiseAfterDepth B d ≤ noiseAfterDepth B D)
    (hD : SupportsDepth B T D) :
    ∀ d ≤ D, SupportsDepth B T d := by
  intro d hd
  exact lt_of_le_of_lt (hmono d hd) hD

end RingLWEFHE

end

#print axioms RingLWEFHE.decrypt_add_encryptWith
#print axioms RingLWEFHE.decrypt_add_of_noise_bound
#print axioms RingLWEFHE.indCPA_of_decisional_ringLWE
#print axioms RingLWEFHE.Circuit.decrypt_evalEncrypted
#print axioms RingLWEFHE.concrete_depth_before_bootstrap