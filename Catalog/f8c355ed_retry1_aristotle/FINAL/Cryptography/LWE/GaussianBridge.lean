import Mathlib
import FINAL.Pythagorean.BrahmaguptaFib
import FINAL.NumberTheory.PrimeSplitting
import FINAL.Cryptography.LWE.SearchDecisionCore

/-!
# A Gaussian-integer bridge for ring-LWE

This module assembles the algebraic and number-theoretic ingredients needed to
state the **ring-LWE problem over the Gaussian integers `ℤ[i]`** and to formulate
its decryption-correctness guarantee.

The development is layered so that every result depends only on previously defined
components (no result is used in its own proof):

1.  the Gaussian integers `ℤ[i]` and their norm `N(a + b i) = a² + b²`
    (re-using Mathlib's `GaussianInt`);
2.  **multiplicativity of the norm**, `N(z·w) = N(z)·N(w)`, proved from the
    Brahmagupta–Fibonacci composition identity
    (`FINAL.Pythagorean.brahmagupta_fibonacci`);
3.  the **splitting / inertness dichotomy** for rational primes
    (`FINAL.NumberTheory`): `p ≡ 1 (mod 4)` splits, `p ≡ 3 (mod 4)` is inert;
4.  the **ring-LWE problem over `ℤ[i]`** together with a simple public-key
    encryption scheme;
5.  a clear **decryption-correctness** statement: decryption succeeds whenever the
    error vector `(eₓ, e_y)` satisfies `eₓ² + e_y² < (q/4)²`.

We deliberately stop short of the full Regev (quantum) worst-case to average-case
reduction; this file fixes the definitions and the correctness lemmas.
-/

open scoped GaussianInt

namespace FINAL.Cryptography.LWE.Gaussian

/-! ## 1. The Gaussian norm -/

/-- The norm of a Gaussian integer `z = a + b i`, namely `N(z) = a² + b²`. -/
def gaussNorm (z : GaussianInt) : ℤ := z.re ^ 2 + z.im ^ 2

/-- The explicit norm `a² + b²` agrees with Mathlib's `Zsqrtd.norm` on `ℤ[i]`. -/
theorem gaussNorm_eq_zsqrtdNorm (z : GaussianInt) : gaussNorm z = z.norm := by
  simp only [gaussNorm, Zsqrtd.norm]
  ring

/-- The Gaussian norm is non-negative. -/
theorem gaussNorm_nonneg (z : GaussianInt) : 0 ≤ gaussNorm z := by
  have : (0 : ℤ) ≤ z.re ^ 2 + z.im ^ 2 := by positivity
  simpa [gaussNorm] using this

/-! ## 2. Multiplicativity of the norm, via Brahmagupta–Fibonacci -/

/-- **Multiplicativity of the Gaussian norm.**

`N(z · w) = N(z) · N(w)`.  This is exactly the Brahmagupta–Fibonacci composition
identity applied to the real and imaginary parts of `z` and `w`. -/
theorem gaussNorm_mul (z w : GaussianInt) :
    gaussNorm (z * w) = gaussNorm z * gaussNorm w := by
  have hbf := FINAL.Pythagorean.brahmagupta_fibonacci z.re z.im w.re w.im
  have hre : (z * w).re = z.re * w.re - z.im * w.im := by
    simp [Zsqrtd.re_mul]; ring
  have him : (z * w).im = z.re * w.im + z.im * w.re := by
    simp [Zsqrtd.im_mul]
  simp only [gaussNorm, hre, him]
  linear_combination hbf

/-! ## 3. Splitting and inertness (re-exported) -/

/-- A prime `p ≡ 1 (mod 4)` splits in `ℤ[i]`: it is a sum of two squares. -/
theorem prime_split (p : ℕ) [Fact p.Prime] (h : p % 4 = 1) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) :=
  FINAL.NumberTheory.prime_one_mod_four_sum_two_squares p h

/-- A prime `p ≡ 1 (mod 4)` is not prime in `ℤ[i]` (it splits). -/
theorem prime_not_prime_in_gaussian (p : ℕ) [Fact p.Prime] (h : p % 4 = 1) :
    ¬ Prime (p : GaussianInt) :=
  FINAL.NumberTheory.gaussian_split p h

/-- A prime `p ≡ 3 (mod 4)` is inert: it remains prime in `ℤ[i]`. -/
theorem prime_inert (p : ℕ) [Fact p.Prime] (h : p % 4 = 3) :
    Prime (p : GaussianInt) :=
  FINAL.NumberTheory.gaussian_inert p h

/-- A prime `p ≡ 3 (mod 4)` is not a sum of two squares. -/
theorem prime_inert_not_sum_two_squares (p : ℕ) (h : p % 4 = 3) :
    ¬ ∃ a b : ℤ, a ^ 2 + b ^ 2 = (p : ℤ) :=
  FINAL.NumberTheory.prime_three_mod_four_not_sum_two_squares p h

/-! ## 4. The ring-LWE problem over `ℤ[i]`

A ring-LWE sample over `ℤ[i]` is a pair `(a, b)` with `b = a · s + e` for a small
Gaussian error `e`.  We instantiate the generic `SearchDecisionCore` scaffolding
at the coefficient ring `GaussianInt`. -/

/-- A ring-LWE sample over `ℤ[i]`. -/
abbrev RLWESample := FINAL.Cryptography.LWE.LWESample GaussianInt

/-- The honest ring-LWE sample `(a, a·s + e)` over `ℤ[i]`. -/
def rlweSample (s e a : GaussianInt) : RLWESample :=
  FINAL.Cryptography.LWE.lweSample s e a

/-- The error vector `(eₓ, e_y)` of a Gaussian integer `e` is *bounded by `r`*
when `eₓ² + e_y² < r²` (Euclidean ball of radius `r`). -/
def errorBounded (r : ℝ) (e : GaussianInt) : Prop :=
  (e.re : ℝ) ^ 2 + (e.im : ℝ) ^ 2 < r ^ 2

/-- The **search ring-LWE** problem over `ℤ[i]`: recover a secret consistent with
the observed samples, where "small" means the residual lies in the radius-`r`
Euclidean ball. -/
def SearchRLWE (r : ℝ) (samples : List RLWESample) : Prop :=
  FINAL.Cryptography.LWE.SearchLWE (errorBounded r) samples

/-! ## 5. A public-key scheme over `ℤ[i]` and decryption correctness

We use a modulus `q = 2·t`; a plaintext bit `m ∈ {0,1}` is encoded in a coordinate
as `m · t` (i.e. `0` or `q/2`).  A coordinate carrying `m · t + e` is decoded by
nearest-codeword rounding, which is correct precisely when `2·|e| < t`, i.e.
`|e| < q/4`.  In two dimensions the joint condition is the Euclidean ball
`eₓ² + e_y² < (q/4)²`. -/

/-- Nearest-codeword decoder for a single coordinate carrying `m · t + e`, where
`t = q/2` is the half-modulus.  Returns the recovered bit. -/
def decodeCoord (t v : ℤ) : ℤ := if 2 * v < t then 0 else 1

/-- **One-dimensional decoding correctness.**  If the bit `m ∈ {0,1}` is encoded as
`m · t` and the additive error `e` satisfies `2·|e| < t`, then the decoder recovers
`m`. -/
theorem decodeCoord_correct (t e m : ℤ) (hm : m = 0 ∨ m = 1) (he : 2 * |e| < t) :
    decodeCoord t (e + m * t) = m := by
  have hcases := abs_cases e
  rcases hm with rfl | rfl <;> simp only [decodeCoord] <;> rcases hcases with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
    rw [h1] at he <;> split <;> omega

/-- A ring-LWE ciphertext over `ℤ[i]`. -/
structure Ciphertext where
  /-- The public part (a uniform Gaussian integer). -/
  u : GaussianInt
  /-- The masked, message-carrying part. -/
  v : GaussianInt

/-- Encode a two-bit message `(mₓ, m_y)` at half-modulus `t` as the Gaussian
integer `mₓ·t + (m_y·t) i`. -/
def encodeMsg (t mre mim : ℤ) : GaussianInt := ⟨mre * t, mim * t⟩

/-- Encryption of the message bits `(mₓ, m_y)` with secret `s`, public coordinate
`a`, error coordinates `(eₓ, e_y)`, and half-modulus `t = q/2`. -/
def encrypt (t : ℤ) (s a : GaussianInt) (e_re e_im mre mim : ℤ) : Ciphertext :=
  ⟨a, a * s + (⟨e_re, e_im⟩ : GaussianInt) + encodeMsg t mre mim⟩

/-- Decryption: strip the mask `u · s` and round each coordinate. -/
def decrypt (t : ℤ) (s : GaussianInt) (c : Ciphertext) : ℤ × ℤ :=
  let phase := c.v - c.u * s
  (decodeCoord t phase.re, decodeCoord t phase.im)

/-- From the Euclidean error bound `eₓ² + e_y² < (q/4)²` (with `q = 2·t`) one
obtains the per-coordinate bound `2·|eₓ| < t`. -/
theorem coord_bound_re (t e_re e_im : ℤ) (ht : 0 < t)
    (h : (e_re : ℝ) ^ 2 + (e_im : ℝ) ^ 2 < (((2 * t : ℤ) : ℝ) / 4) ^ 2) :
    2 * |e_re| < t := by
  have hcast : (((2 * t : ℤ) : ℝ) / 4) ^ 2 = ((t : ℝ) / 2) ^ 2 := by push_cast; ring
  rw [hcast] at h
  have hnn : (0 : ℝ) ≤ (e_im : ℝ) ^ 2 := by positivity
  have hsq : (e_re : ℝ) ^ 2 < ((t : ℝ) / 2) ^ 2 := by linarith
  have htpos : (0 : ℝ) ≤ (t : ℝ) / 2 := by
    have : (0 : ℝ) < (t : ℝ) := by exact_mod_cast ht
    linarith
  have habs : |(e_re : ℝ)| < (t : ℝ) / 2 := abs_lt_of_sq_lt_sq hsq htpos
  have key : ((2 * |e_re| : ℤ) : ℝ) < ((t : ℤ) : ℝ) := by
    rw [Int.cast_mul, Int.cast_abs]; push_cast; linarith [habs]
  exact_mod_cast key

/-- From the Euclidean error bound one obtains the per-coordinate bound
`2·|e_y| < t`. -/
theorem coord_bound_im (t e_re e_im : ℤ) (ht : 0 < t)
    (h : (e_re : ℝ) ^ 2 + (e_im : ℝ) ^ 2 < (((2 * t : ℤ) : ℝ) / 4) ^ 2) :
    2 * |e_im| < t := by
  have h' : (e_im : ℝ) ^ 2 + (e_re : ℝ) ^ 2 < (((2 * t : ℤ) : ℝ) / 4) ^ 2 := by
    linarith
  exact coord_bound_re t e_im e_re ht h'

/-- **Decryption correctness for ring-LWE over `ℤ[i]`.**

Let `q = 2·t` be the modulus.  If the message bits `mₓ, m_y ∈ {0,1}` are encrypted
with error coordinates `(eₓ, e_y)` satisfying the Euclidean bound

`eₓ² + e_y² < (q/4)²`,

then decryption with the correct secret recovers the original message `(mₓ, m_y)`.
The bound `(q/4)²` is exactly the squared packing radius separating the two
codewords `0` and `q/2` in each coordinate. -/
theorem decryption_correct (t : ℤ) (ht : 0 < t)
    (s a : GaussianInt) (mre mim e_re e_im : ℤ)
    (hmre : mre = 0 ∨ mre = 1) (hmim : mim = 0 ∨ mim = 1)
    (herr : (e_re : ℝ) ^ 2 + (e_im : ℝ) ^ 2 < (((2 * t : ℤ) : ℝ) / 4) ^ 2) :
    decrypt t s (encrypt t s a e_re e_im mre mim) = (mre, mim) := by
  have hphase_re : (((encrypt t s a e_re e_im mre mim).v
      - (encrypt t s a e_re e_im mre mim).u * s).re) = e_re + mre * t := by
    simp [encrypt, encodeMsg, Zsqrtd.re_add, Zsqrtd.re_sub, Zsqrtd.re_mul]
    ring
  have hphase_im : (((encrypt t s a e_re e_im mre mim).v
      - (encrypt t s a e_re e_im mre mim).u * s).im) = e_im + mim * t := by
    simp [encrypt, encodeMsg, Zsqrtd.im_add, Zsqrtd.im_sub, Zsqrtd.im_mul]
    ring
  have hbre := coord_bound_re t e_re e_im ht herr
  have hbim := coord_bound_im t e_re e_im ht herr
  simp only [decrypt, hphase_re, hphase_im]
  rw [decodeCoord_correct t e_re mre hmre hbre, decodeCoord_correct t e_im mim hmim hbim]

end FINAL.Cryptography.LWE.Gaussian