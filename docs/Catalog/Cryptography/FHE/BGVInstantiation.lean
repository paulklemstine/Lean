import Cryptography.FHE.NoiseParameters

/-!
# A non-vacuous instantiation: integer BGV with centered lifting

The correctness theorems of `NoiseGrowth` are stated for an abstract decoder
`dec` that recovers the plaintext class from any phase of gauge size below the
decoding radius `T`.  A sceptical reader should ask whether such a decoder
exists at all, or whether the hypotheses are silently vacuous.  This file
answers that: for integer BGV with ciphertext modulus `q` and plaintext modulus
`t`, the *real* decoder

`dec x = ((x mod q).valMinAbs : ZMod t)`

— reduce modulo the ciphertext modulus, lift to the centered representative,
then reduce modulo the plaintext modulus — satisfies the hypothesis with
`T = q/2`, and nothing else.

* `centered_lift` — the arithmetic heart: for `2|x| < q`, the centered
  representative of `x mod q` is `x` itself.
* `bgvDecode_eq_of_small` — the decoder hypothesis of `decrypt_evalEnc`.
* `bgv_int_correct` — the resulting fully concrete correctness statement for
  homomorphic circuit evaluation over `ℤ`.
-/

namespace FHENoise

open Polynomial

/-! ## 1. Centered lifting -/

/-- If `2|x| < q` then reducing `x` modulo `q` and taking the centered
representative returns `x` exactly.  This is the reason a decryption radius of
`q/2` is the right notion of "decodable noise". -/
theorem centered_lift (q : ℕ) [NeZero q] (x : ℤ) (h : 2 * |x| < q) :
    ((x : ZMod q).valMinAbs : ℤ) = x := by
  have h1 : (((x : ZMod q).valMinAbs : ℤ) : ZMod q) = (x : ZMod q) := ZMod.coe_valMinAbs _
  have h2 : (q : ℤ) ∣ ((x : ZMod q).valMinAbs - x) :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd _ q).mp (by push_cast [h1]; ring)
  have h3 := ZMod.valMinAbs_mem_Ioc (x := (x : ZMod q))
  simp only [Set.mem_Ioc] at h3
  obtain ⟨k, hk⟩ := h2
  have hq : (0 : ℤ) < q := by
    have hne : q ≠ 0 := NeZero.ne q
    positivity
  have hx1 : 2 * x < (q : ℤ) := lt_of_le_of_lt (by linarith [le_abs_self x]) h
  have hx2 : -(q : ℤ) < 2 * x := by linarith [neg_abs_le x, h]
  have hk0 : k = 0 := by
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · have hle : (q : ℤ) * k ≤ -(q : ℤ) := by nlinarith
      omega
    · have hge : (q : ℤ) ≤ (q : ℤ) * k := le_mul_of_one_le_right (le_of_lt hq) (by omega)
      omega
  rw [hk0, mul_zero] at hk
  omega

/-! ## 2. The BGV decoder over `ℤ` -/

variable (q t : ℕ) [NeZero q]

/-- Reduce modulo the ciphertext modulus, lift to the centered representative,
reduce modulo the plaintext modulus. -/
def bgvDecode (x : ℤ) : ZMod t := (((x : ZMod q).valMinAbs : ℤ) : ZMod t)

/-- Plaintext extraction: reduction modulo the plaintext modulus. -/
def bgvPi : ℤ →+* ZMod t := Int.castRingHom (ZMod t)

/-- **The decoder hypothesis holds with radius `q/2`.**  Every phase of absolute
value below `q/2` is decoded to its plaintext class. -/
theorem bgvDecode_eq_of_small (x : ℤ) (hx : intGauge.nu x < (q : ℝ) / 2) :
    bgvDecode q t x = bgvPi t x := by
  have hxq : 2 * |x| < (q : ℤ) := by
    have : |(x : ℝ)| < (q : ℝ) / 2 := hx
    have h2 : (2 : ℝ) * |(x : ℝ)| < (q : ℝ) := by linarith
    have hcast : ((2 * |x| : ℤ) : ℝ) < ((q : ℤ) : ℝ) := by push_cast; linarith
    exact_mod_cast hcast
  rw [bgvDecode, centered_lift q x hxq, bgvPi]
  simp

/-! ## 3. Concrete circuit correctness for integer BGV -/

/-- **Non-vacuity of the master correctness theorem.**  With the honest BGV
decoder above, an arbitrary arithmetic circuit evaluated homomorphically over
`ℤ` — additions free, multiplications followed by a relinearization of noise
cost `D` that preserves the plaintext class — decrypts to the plaintext circuit
value as soon as the syntactic noise bound stays below `q/2`. -/
theorem bgv_int_correct {D : ℝ} (s : ℤ)
    (relin : Cipher ℤ → Cipher ℤ)
    (hrelinN : ∀ c, intGauge.nu (phase s (relin c) - phase s c) ≤ D)
    (hrelinP : ∀ c, bgvPi t (phase s (relin c)) = bgvPi t (phase s c))
    (rho : ℕ → Cipher ℤ) (beta : ℕ → ℝ)
    (hleaf : ∀ i, noise intGauge s (rho i) ≤ beta i)
    (f : NoiseCkt) (hbudget : f.noiseBound 1 D beta < (q : ℝ) / 2) :
    bgvDecode q t (phase s (f.evalEnc relin rho))
      = f.evalPlain (fun i => bgvPi t (phase s (rho i))) := by
  refine NoiseCkt.decrypt_evalEnc intGauge s (bgvPi t) (bgvDecode q t)
    (bgvDecode_eq_of_small q t) relin hrelinN hrelinP rho beta hleaf f ?_
  simpa using hbudget

end FHENoise