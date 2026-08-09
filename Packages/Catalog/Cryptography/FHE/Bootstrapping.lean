import Cryptography.FHE.NoiseDichotomy

/-!
# Quantitative bootstrapping: unbounded depth at bounded noise

`Cryptography.FHE.RingLWE` states Gentry's bootstrapping principle in an
idealized form: a refresh operation that is *always* correct yields unbounded
depth.  Real bootstrapping is not unconditional — the refresh procedure is
itself a homomorphic evaluation of the decryption circuit, so it only works when
its input is still decryptable, i.e. when the input noise is below the decoding
radius `T`.  This file formalizes exactly that conditional statement and derives
the two quantities a parameter designer actually needs:

* how many multiplication levels `L` fit between two bootstraps
  (`levels_between_bootstraps`, a logarithmic formula), and
* the fact that the *bootstrapped* evaluation of an arbitrarily deep squaring
  chain keeps noise `≤ B_ref` at every stage and decrypts correctly
  (`bootIter_decrypt`).

We also record how modulus switching moves the stability threshold of the
dichotomy of `NoiseDichotomy` (`modSwitch_dichotomy`): dividing the noise by `p`
at each level multiplies the tolerable key-switching noise by `p`.
-/

namespace FHENoise

open Polynomial

noncomputable section

variable {R : Type*} [CommRing R]

/-! ## 1. Blocks of squarings between refreshes -/

/-- One multiplication level: square, then relinearize. -/
def sqStep (relin : Cipher R → Cipher R) (c : Cipher R) : Cipher R := relin (c * c)

/-- `L` consecutive multiplication levels. -/
def sqBlock (relin : Cipher R → Cipher R) : ℕ → Cipher R → Cipher R
  | 0, c => c
  | (n + 1), c => sqStep relin (sqBlock relin n c)

lemma iterD_mono_input {gamma D : ℝ} (hg : 0 ≤ gamma) (hD : 0 ≤ D) {x y : ℝ}
    (hx : 0 ≤ x) (hxy : x ≤ y) : ∀ d, iterD gamma D d x ≤ iterD gamma D d y
  | 0 => hxy
  | (d + 1) => by
      have ih := iterD_mono_input hg hD hx hxy d
      have h0 := iterD_nonneg hg hD hx d
      have hsq := mul_self_le_mul_self h0 ih
      simp only [iterD_succ, noiseStep]
      nlinarith [hsq, hg]

/-- Noise after `n` levels is bounded by the `n`-th iterate of the noise map. -/
theorem noise_sqBlock_le {D x : ℝ} (G : NoiseGauge R) (s : R)
    (relin : Cipher R → Cipher R)
    (hrelin : ∀ c, G.nu (phase s (relin c) - phase s c) ≤ D) (hD : 0 ≤ D)
    (c : Cipher R) (hc : noise G s c ≤ x) (hx : 0 ≤ x) :
    ∀ n, noise G s (sqBlock relin n c) ≤ iterD G.gamma D n x
  | 0 => hc
  | (n + 1) => by
      have ih := noise_sqBlock_le G s relin hrelin hD c hc hx n
      have h0 := noise_nonneg G s (sqBlock relin n c)
      have hmul := noise_mul_le G s (sqBlock relin n c) (sqBlock relin n c)
      have hrel := noise_relin_le G s relin hrelin (sqBlock relin n c * sqBlock relin n c)
      have hsq := mul_self_le_mul_self h0 ih
      have hg := G.gamma_nonneg
      simp only [sqBlock, sqStep, iterD_succ, noiseStep]
      nlinarith [hsq, hg, hmul, hrel]

/-- Blocks of levels raise the plaintext to the power `2^n`. -/
theorem plain_sqBlock {M : Type*} [CommRing M] (s : R) (pi : R →+* M)
    (relin : Cipher R → Cipher R)
    (hrelinP : ∀ c, pi (phase s (relin c)) = pi (phase s c)) (c : Cipher R) :
    ∀ n, pi (phase s (sqBlock relin n c)) = (pi (phase s c)) ^ (2 ^ n)
  | 0 => by simp [sqBlock]
  | (n + 1) => by
      have ih := plain_sqBlock s pi relin hrelinP c n
      have hstep : pi (phase s (sqStep relin (sqBlock relin n c)))
          = pi (phase s (sqBlock relin n c)) * pi (phase s (sqBlock relin n c)) := by
        rw [sqStep, hrelinP, phase_mul, map_mul]
      rw [sqBlock, hstep, ih, ← pow_add, pow_succ]
      ring_nf

/-! ## 2. How many levels fit between two bootstraps -/

/-- **Levels between bootstraps.**  In the relinearization-free regime, starting
from a refreshed noise level `B` with `γB > 1`, exactly the levels
`L < log(log(γT)/log(γB))/log 2` are safe: if `2^L · log(γB) < log(γT)` then the
noise after `L` levels is still below the decoding radius `T`.  This is the
logarithm-of-a-logarithm law characteristic of levelled FHE. -/
theorem levels_between_bootstraps {gamma B T : ℝ} (hgB : 1 < gamma * B)
    (hT : 0 < gamma * T) (L : ℕ)
    (hL : (2 ^ L : ℝ) * Real.log (gamma * B) < Real.log (gamma * T)) :
    gamma * iterNoise gamma L B < gamma * T := by
  have hpow : gamma * iterNoise gamma L B = (gamma * B) ^ (2 ^ L) := gamma_iterNoise gamma B L
  have hpos : 0 < (gamma * B) ^ (2 ^ L) := pow_pos (by linarith) _
  have hlog : Real.log ((gamma * B) ^ (2 ^ L)) = (2 ^ L : ℝ) * Real.log (gamma * B) := by
    rw [Real.log_pow]
    norm_num
  rw [hpow]
  refine (Real.log_lt_log_iff hpos hT).mp ?_
  rw [hlog]
  exact hL

/-! ## 3. Bootstrapped evaluation of unboundedly deep chains -/

/-- Alternating blocks of `L` multiplication levels with a refresh (bootstrap)
after each block. -/
def bootIter (relin refresh : Cipher R → Cipher R) (L : ℕ) : ℕ → Cipher R → Cipher R
  | 0, c => c
  | (k + 1), c => refresh (sqBlock relin L (bootIter relin refresh L k c))

/-- **Noise invariant of bootstrapped evaluation.**  If a refresh resets the
noise to `Bref` whenever its input is still decryptable, and `L` levels applied
to noise `Bref` stay below the decoding radius `T`, then after every completed
block the noise is at most `Bref` — for arbitrarily many blocks. -/
theorem bootIter_noise_le {D T Bref : ℝ} (G : NoiseGauge R) (s : R)
    (relin refresh : Cipher R → Cipher R)
    (hrelin : ∀ c, G.nu (phase s (relin c) - phase s c) ≤ D) (hD : 0 ≤ D)
    (hrefN : ∀ c, noise G s c < T → noise G s (refresh c) ≤ Bref)
    (hBref : 0 ≤ Bref) (L : ℕ) (hsafe : iterD G.gamma D L Bref < T)
    (c : Cipher R) (hc : noise G s c ≤ Bref) :
    ∀ k, noise G s (bootIter relin refresh L k c) ≤ Bref
  | 0 => hc
  | (k + 1) => by
      have ih := bootIter_noise_le G s relin refresh hrelin hD hrefN hBref L hsafe c hc k
      have hblock := noise_sqBlock_le G s relin hrelin hD
        (bootIter relin refresh L k c) ih hBref L
      exact hrefN _ (lt_of_le_of_lt hblock hsafe)

/-- Plaintext evolution of bootstrapped evaluation: after `k` blocks the
plaintext has been raised to the power `2^(L·k)`. -/
theorem bootIter_plain {M : Type*} [CommRing M] {D T Bref : ℝ} (G : NoiseGauge R) (s : R)
    (pi : R →+* M) (relin refresh : Cipher R → Cipher R)
    (hrelin : ∀ c, G.nu (phase s (relin c) - phase s c) ≤ D) (hD : 0 ≤ D)
    (hrelinP : ∀ c, pi (phase s (relin c)) = pi (phase s c))
    (hrefN : ∀ c, noise G s c < T → noise G s (refresh c) ≤ Bref)
    (hrefP : ∀ c, noise G s c < T → pi (phase s (refresh c)) = pi (phase s c))
    (hBref : 0 ≤ Bref) (L : ℕ) (hsafe : iterD G.gamma D L Bref < T)
    (c : Cipher R) (hc : noise G s c ≤ Bref) :
    ∀ k, pi (phase s (bootIter relin refresh L k c)) = (pi (phase s c)) ^ (2 ^ (L * k))
  | 0 => by simp [bootIter]
  | (k + 1) => by
      have ih := bootIter_plain G s pi relin refresh hrelin hD hrelinP hrefN hrefP hBref
        L hsafe c hc k
      have hnk := bootIter_noise_le G s relin refresh hrelin hD hrefN hBref L hsafe c hc k
      have hblock := noise_sqBlock_le G s relin hrelin hD
        (bootIter relin refresh L k c) hnk hBref L
      have hlt : noise G s (sqBlock relin L (bootIter relin refresh L k c)) < T :=
        lt_of_le_of_lt hblock hsafe
      have hplain := plain_sqBlock s pi relin hrelinP (bootIter relin refresh L k c) L
      have hexp : 2 ^ (L * k) * 2 ^ L = 2 ^ (L * (k + 1)) := by
        rw [← pow_add]
        ring_nf
      rw [bootIter, hrefP _ hlt, hplain, ih, ← pow_mul, hexp]

/-- **Bootstrapped correctness at unbounded depth.**  Under a conditional
refresh (correct only below the decoding radius `T`), the bootstrapped squaring
chain decrypts to `m^(2^(L·k))` for *every* number of blocks `k`, while the
noise never exceeds `Bref`.  Unbounded multiplicative depth is achieved at
bounded noise, with `⌈d/L⌉` bootstraps for depth `d`. -/
theorem bootIter_decrypt {M : Type*} [CommRing M] {D T Bref : ℝ} (G : NoiseGauge R) (s : R)
    (pi : R →+* M) (dec : R → M) (hdec : ∀ x, G.nu x < T → dec x = pi x)
    (relin refresh : Cipher R → Cipher R)
    (hrelin : ∀ c, G.nu (phase s (relin c) - phase s c) ≤ D) (hD : 0 ≤ D)
    (hrelinP : ∀ c, pi (phase s (relin c)) = pi (phase s c))
    (hrefN : ∀ c, noise G s c < T → noise G s (refresh c) ≤ Bref)
    (hrefP : ∀ c, noise G s c < T → pi (phase s (refresh c)) = pi (phase s c))
    (hBref : 0 ≤ Bref) (L : ℕ) (hsafe : iterD G.gamma D L Bref < T)
    (hBrefT : Bref < T) (c : Cipher R) (hc : noise G s c ≤ Bref) (k : ℕ) :
    dec (phase s (bootIter relin refresh L k c)) = (pi (phase s c)) ^ (2 ^ (L * k)) := by
  have hnk := bootIter_noise_le G s relin refresh hrelin hD hrefN hBref L hsafe c hc k
  have hlt : G.nu (phase s (bootIter relin refresh L k c)) < T :=
    lt_of_le_of_lt hnk hBrefT
  rw [hdec _ hlt]
  exact bootIter_plain G s pi relin refresh hrelin hD hrelinP hrefN hrefP hBref L hsafe c hc k

/-! ## 4. Modulus switching shifts the stability threshold -/

/-- **Modulus switching enlarges the stable regime.**  If each level also
divides the noise by a modulus-switching factor `p > 0`, the effective noise map
is `x ↦ (γ/p)·x² + D`, so by the dichotomy an invariant noise budget exists iff
`4γD ≤ p`: the tolerable key-switching noise scales linearly with the
switching factor. -/
theorem modSwitch_dichotomy {gamma D p : ℝ} (hg : 0 < gamma) (hp : 0 < p) (hD : 0 ≤ D) :
    (∃ Q, InvariantBudget (gamma / p) D Q) ↔ 4 * gamma * D ≤ p := by
  rw [noiseStep_dichotomy (by positivity) hD]
  rw [show 4 * (gamma / p) * D = (4 * gamma * D) / p by field_simp, div_le_one hp]

end

end FHENoise