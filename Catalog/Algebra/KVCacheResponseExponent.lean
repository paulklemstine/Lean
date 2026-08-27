/-
# The response exponent of a quantised cache, and the NET-94 exponent gap

Cycle 1 (`Algebra.KVCacheRoleSplit`, `Algebra.KVCacheCliffGeometry`) established:

* the value path is `1`-Lipschitz and its distortion **doubles** per lost bit;
* the key path is exponential and its distortion factor **squares** per lost bit;
* yet *neither* law can reproduce the measured NET-94 pair
  `(+0.142 % at 8 bits, +867.694 % at 5 bits)` — the observed 3-bit window is far too
  sharp (`net94_refutes_uniform_lipschitz_model`, `value_path_cannot_cliff`).

Cycle 2 asks the abductive question: *what response law survives the data?*  The answer
formalised here is model independent.  Write the distortion as a **power-law response**
to the quantiser step `η(b) = R · 2⁻ᵇ`,

`powerDist c γ R b = c · (R / 2ᵇ)^γ`,

with response exponent `γ`.  Then:

* `powerDist_ratio` — every power-law response is *multiplicative in bit width* with base
  `2^γ`; `γ = 1` recovers the value-side doubling law of `KVCacheCliffGeometry.valDist`.
* `net94_forces_superbinary_shrink` — **model-free**: any multiplicative-in-bits
  distortion law consistent with NET-94 has per-bit shrink base `K > 18`.  In particular
  `net94_refutes_uniform_step_law`: the physical base `K = 2` of a uniform quantiser is
  ruled out with no reference to softmax, Lipschitz constants, or the transformer at all.
* `net94_forces_quintic_key_response` — consequently the key-side response exponent
  satisfies `γ ≥ 5`: perplexity responds to key quantisation noise at least *quintically*.
* `role_response_exponent_gap` — the sharp form of the NET-94 role split: the key
  exponent is at least `5`, the value exponent is exactly `1`, so the two roles are
  separated by a response-exponent gap of at least `4`.  This is a falsifiable
  prediction: sweep `-ctk` over more widths and fit `log dPPL` against `log η`; the key
  slope must exceed `5`, the value slope must be `1`.
-/
import Mathlib
import Algebra.KVCacheCliffGeometry

namespace Catalog.Algebra.KVCache

/-- A power-law distortion response: quantiser step `R · 2⁻ᵇ` raised to the response
exponent `γ`, with prefactor `c`.  `γ = 1` is the linear (value-side) response,
`γ ≥ 2` is a superlinear response. -/
noncomputable def powerDist (c : ℝ) (γ : ℕ) (R : ℝ) (b : ℕ) : ℝ := c * (R / 2 ^ b) ^ γ

/-- The value-side distortion of `KVCacheCliffGeometry` is exactly the power-law response
with exponent `1`. -/
theorem valDist_eq_powerDist (R : ℝ) (b : ℕ) : valDist R b = powerDist 1 1 R b := by
  simp [valDist, powerDist]

/-- **Every power-law response is multiplicative in bit width**, with per-bit shrink base
`2^γ`.  For `γ = 1` this is the doubling law; the base is `2^γ`, never more, as long as
the physical step really is `R·2⁻ᵇ`. -/
theorem powerDist_ratio (c R : ℝ) (γ : ℕ) {b₀ b₁ : ℕ} (h : b₀ ≤ b₁) :
    powerDist c γ R b₀ = (2 ^ γ) ^ (b₁ - b₀) * powerDist c γ R b₁ := by
  obtain ⟨m, rfl⟩ : ∃ m, b₁ = b₀ + m := ⟨b₁ - b₀, by omega⟩
  simp only [Nat.add_sub_cancel_left, powerDist, pow_add, div_pow, mul_pow, ← pow_mul]
  field_simp
  ring

/-- **Model-free consequence of NET-94.**  Suppose the key-cache distortion obeys *any*
law that is multiplicative in bit width, `D b = c / K^b` — this covers uniform
quantisers (`K = 2`), power-law responses (`K = 2^γ`), and every geometric surrogate in
between.  Being quality free at 8 bits (`≤ 0.00142`) while broken at 5 bits (`≥ 8.67694`)
forces the per-bit shrink base to satisfy `K > 18`.

Numerically: the data demand `K³ ≥ 8.67694 / 0.00142 > 6110`, and `18³ = 5832`. -/
theorem net94_forces_superbinary_shrink {c K : ℝ} (hK : 0 < K)
    (h8 : c / K ^ 8 ≤ 0.00142) (h5 : 8.67694 ≤ c / K ^ 5) : 18 < K := by
  have e8 : (0:ℝ) < K ^ 8 := by positivity
  have e5 : (0:ℝ) < K ^ 5 := by positivity
  have hc8 : c ≤ 0.00142 * K ^ 8 := by rw [div_le_iff₀ e8] at h8; linarith
  have hc5 : 8.67694 * K ^ 5 ≤ c := by rw [le_div_iff₀ e5] at h5; linarith
  have hcube : 5832 * K ^ 5 < K ^ 8 := by nlinarith
  have h3 : (5832:ℝ) < K ^ 3 := by
    have hK8 : K ^ 8 = K ^ 3 * K ^ 5 := by ring
    nlinarith
  nlinarith [sq_nonneg (K - 18), sq_nonneg (K + 18), hK.le]

/-- **The uniform-quantiser step law is refuted, model-freely.**  No prefactor `c` makes
the physical law `D b = c · 2⁻ᵇ` (the honest error of a uniform quantiser, and the exact
value-side law) fit both NET-94 arms.  Unlike
`KVCacheCliffGeometry.net94_refutes_uniform_lipschitz_model`, this needs no softmax, no
logarithms, and no Lipschitz theory: it is pure geometry of the bit ladder. -/
theorem net94_refutes_uniform_step_law :
    ¬ ∃ c : ℝ, c / 2 ^ 8 ≤ 0.00142 ∧ 8.67694 ≤ c / 2 ^ 5 := by
  rintro ⟨c, h8, h5⟩
  have := net94_forces_superbinary_shrink (c := c) (K := 2) (by norm_num) h8 h5
  linarith

/-- **The key-side response is at least quintic.**  If the key distortion is a power-law
response `c · (R/2ᵇ)^γ` to the quantiser step, then NET-94 forces `γ ≥ 5`.

Proof: a power-law response is multiplicative with base `K = 2^γ`
(`powerDist_ratio`), `net94_forces_superbinary_shrink` gives `2^γ > 18`, and `2⁴ = 16`. -/
theorem net94_forces_quintic_key_response {c R : ℝ} {γ : ℕ}
    (h8 : powerDist c γ R 8 ≤ 0.00142) (h5 : 8.67694 ≤ powerDist c γ R 5) : 5 ≤ γ := by
  set K : ℝ := 2 ^ γ with hK
  have hKpos : (0:ℝ) < K := by positivity
  have hrewrite : ∀ b : ℕ, powerDist c γ R b = (c * R ^ γ) / K ^ b := by
    intro b
    unfold powerDist
    rw [div_pow, hK, ← pow_mul, mul_comm b γ, pow_mul]
    ring
  rw [hrewrite 8] at h8
  rw [hrewrite 5] at h5
  have hbig := net94_forces_superbinary_shrink (c := c * R ^ γ) (K := K) hKpos h8 h5
  by_contra hγ
  push_neg at hγ
  have : γ ≤ 4 := by omega
  have hle : (K:ℝ) ≤ 2 ^ 4 := by
    rw [hK]
    exact pow_le_pow_right₀ (by norm_num) this
  norm_num at hle
  linarith

/-- **The NET-94 role split, in its sharpest form: a response-exponent gap.**
Assume the key-side distortion is a power-law response with exponent `γ` fitting both
measured arms.  Then

* the key exponent obeys `γ ≥ 5` — perplexity is at least quintic in the key step, and
* the value exponent is exactly `1`: the value distortion is *exactly* the quantiser
  step, so it merely doubles per lost bit,

so the two cache roles are separated by a response-exponent gap of at least `4`.  This is
why `-ctk q8_0 -ctv q4_0` is quality free at the same memory as a uniform 6-bit cache. -/
theorem role_response_exponent_gap {c R : ℝ} {γ : ℕ}
    (h8 : powerDist c γ R 8 ≤ 0.00142) (h5 : 8.67694 ≤ powerDist c γ R 5) :
    5 ≤ γ ∧ (∀ Rv : ℝ, valDist Rv 5 = 8 * valDist Rv 8) ∧ 4 ≤ γ - 1 := by
  have hγ := net94_forces_quintic_key_response h8 h5
  refine ⟨hγ, fun Rv => ?_, by omega⟩
  have h := valDist_geom Rv (show (5:ℕ) ≤ 8 by norm_num)
  norm_num at h
  exact h

/-- **The quintic bound is sharp, and the hypotheses are satisfiable.**  With unit range
and exponent exactly `5` there is a prefactor reproducing both NET-94 arms: `γ = 5` is
attained, so `net94_forces_quintic_key_response` cannot be improved to `γ ≥ 6`.  This also
certifies that `role_response_exponent_gap` is not vacuous. -/
theorem quintic_response_is_attained :
    ∃ c : ℝ, 0 < c ∧ powerDist c 5 1 8 ≤ 0.00142 ∧ 8.67694 ≤ powerDist c 5 1 5 := by
  refine ⟨8.67694 * 2 ^ 25, by norm_num, ?_, ?_⟩ <;> norm_num [powerDist]

end Catalog.Algebra.KVCache