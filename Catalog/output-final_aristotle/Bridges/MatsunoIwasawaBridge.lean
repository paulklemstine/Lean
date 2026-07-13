import Mathlib

/-!
# A bridge between `p`-adic content valuations and polynomial trailing degrees:
  additivity of Iwasawa `μ`- and `λ`-invariants, and a Matsuno-type twist formula

## Overview

This file builds an elementary but faithful *algebraic model* of the two classical
**Iwasawa invariants** attached to a nonzero element of the Iwasawa algebra
`Λ = ℤ_p[[T]]`, working with the polynomial ring `ℤ[X]` as a computable stand-in.
For a distinguished-polynomial / power-series characteristic element `f`, the
Weierstrass preparation theorem writes `f = p^μ · U · P` with `U` a unit and `P`
distinguished of degree `λ`.  Equivalently, writing `f = Σ aᵢ Xⁱ`:

* the **μ-invariant** is `μ_p(f) = minᵢ v_p(aᵢ)`, the smallest `p`-adic valuation
  occurring among the coefficients;
* the **λ-invariant** is `λ_p(f) = min { i : v_p(aᵢ) = μ_p(f) }`, the first index at
  which that minimal valuation is attained (the `T`-adic order of the mod-`p`
  reduction of `f / p^μ`).

We realise these two invariants through **two genuinely different pieces of
mathematics**, and the main results connect them:

* `μ` is read off from the **content** `f.content` (the gcd of the coefficients, a
  purely `ℤ`-arithmetic / commutative-algebra object) via the `p`-adic valuation
  `padicValInt`;
* `λ` is read off from the **trailing degree** of the reduction of the *primitive
  part* `f.primPart` modulo `p` (a purely `𝔽_p[X]` combinatorial object).

The bridge theorems `muInv_mul` and `lambdaInv_mul` say both invariants are
**additive under multiplication**.  The `μ`-additivity is Gauss's lemma
(multiplicativity of content) combined with additivity of the `p`-adic valuation;
the `λ`-additivity is additivity of the trailing degree in the domain `𝔽_p[X]`.
These are exactly the facts that make the characteristic-element factorisations
underlying **Matsuno's formula** for `λ`-invariants under quadratic twist behave
additively.

## The Matsuno-type twist formula

In the supersingular Iwasawa theory of Pollack and Sprung one attaches to `E/ℚ`
two `p`-adic `L`-functions, giving *sharp* and *flat* (`♯`/`♭`, or `±`) invariants.
Matsuno's formula compares `λ`-invariants under a quadratic twist by `D`, and the
mission concept is that the sharp/flat `λ`-difference should contain a term
**proportional to the μ-invariant** whenever `μ ≠ 0`.

We model a twist that multiplies the characteristic element by the factor
`twistFactor c k = C (p^k) · X^(c·k)`.  Here `μ_p(twistFactor c k) = k`, and
`λ_p(twistFactor c k) = c · k = c · μ`, so the twist shifts the `λ`-invariant by

  `λ_p(f · twist) − λ_p(f) = c · μ_p(twist)`,

a term literally proportional to the μ-invariant of the twist, which vanishes
exactly when `μ = 0` and is non-zero as soon as `μ ≠ 0` and `c ≠ 0`
(`matsuno_twist_formula`, `matsuno_nonvanishing_mu`).

All statements are self-contained and depend only on Mathlib.
-/

namespace IwasawaMatsuno

open Polynomial

variable (p : ℕ) [Fact p.Prime]

/-- Reduction of an integer polynomial modulo the prime `p`. -/
noncomputable def reduce (f : Polynomial ℤ) : Polynomial (ZMod p) :=
  f.map (Int.castRingHom (ZMod p))

/-- The **Iwasawa μ-invariant** of `f`: the `p`-adic valuation of its content,
i.e. `minᵢ v_p(aᵢ)` where `f = Σ aᵢ Xⁱ`. -/
noncomputable def muInv (f : Polynomial ℤ) : ℕ :=
  padicValInt p f.content

/-- The **Iwasawa λ-invariant** of `f`: the trailing degree of the mod-`p`
reduction of the primitive part of `f`, i.e. the first index `i` at which
`v_p(aᵢ)` attains its minimum `μ_p(f)`. -/
noncomputable def lambdaInv (f : Polynomial ℤ) : ℕ :=
  (reduce p f.primPart).natTrailingDegree

/-- Reduction is a ring homomorphism, hence multiplicative. -/
theorem reduce_mul (a b : Polynomial ℤ) : reduce p (a * b) = reduce p a * reduce p b :=
  Polynomial.map_mul _

/-- The reduction of a primitive polynomial modulo `p` is nonzero: a primitive
polynomial cannot have all coefficients divisible by `p`. -/
theorem reduce_primPart_ne_zero (f : Polynomial ℤ) :
    reduce p f.primPart ≠ 0 := by
  intro h
  have hprim : f.primPart.IsPrimitive := isPrimitive_primPart f
  have hall : ∀ i, (p : ℤ) ∣ f.primPart.coeff i := by
    intro i
    have hz : ((f.primPart.coeff i : ℤ) : ZMod p) = 0 := by
      have := congrArg (fun q => Polynomial.coeff q i) h
      simpa [reduce, Polynomial.coeff_map] using this
    rwa [ZMod.intCast_zmod_eq_zero_iff_dvd] at hz
  have hCd : C (p : ℤ) ∣ f.primPart := (C_dvd_iff_dvd_coeff _ _).2 hall
  have hu := hprim (p : ℤ) hCd
  have hp := (Fact.out : p.Prime)
  have hp2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
  rw [Int.isUnit_iff] at hu
  rcases hu with h1 | h1 <;> omega

/-- **μ is additive** (Gauss's lemma + additivity of the `p`-adic valuation). -/
theorem muInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    muInv p (f * g) = muInv p f + muInv p g := by
  have hcf : f.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  have hcg : g.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  unfold muInv
  rw [content_mul, padicValInt.mul hcf hcg]

/-- **λ is additive** (additivity of the trailing degree in the domain `𝔽_p[X]`,
combined with multiplicativity of the primitive part). -/
theorem lambdaInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    lambdaInv p (f * g) = lambdaInv p f + lambdaInv p g := by
  have hfg : f * g ≠ 0 := mul_ne_zero hf hg
  unfold lambdaInv
  rw [primPart_mul hfg, reduce_mul,
    natTrailingDegree_mul (reduce_primPart_ne_zero p f) (reduce_primPart_ne_zero p g)]

/-! ### Invariants of the elementary building blocks -/

/-- The `μ`-invariant of the constant `p^k` is `k`. -/
theorem muInv_C_pow (k : ℕ) : muInv p (C ((p : ℤ) ^ k)) = k := by
  unfold muInv
  rw [content_C, Int.normalize_of_nonneg (by positivity)]
  unfold padicValInt
  simp [padicValNat.prime_pow]

/-- A nonzero constant has `λ`-invariant `0`. -/
theorem lambdaInv_C_pow (k : ℕ) : lambdaInv p (C ((p : ℤ) ^ k)) = 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  have hm : ((p : ℤ) ^ k) ≠ 0 := pow_ne_zero k hp0
  have hprim : (C ((p : ℤ) ^ k)).primPart = 1 := by
    have h := eq_C_content_mul_primPart (C ((p : ℤ) ^ k))
    rw [content_C, Int.normalize_of_nonneg (by positivity)] at h
    have hCm : C ((p : ℤ) ^ k) ≠ 0 := by simpa using hm
    have h' : C ((p : ℤ) ^ k) * 1 = C ((p : ℤ) ^ k) * (C ((p : ℤ) ^ k)).primPart := by
      rw [mul_one]; exact h
    exact (mul_left_cancel₀ hCm h').symm
  unfold lambdaInv reduce
  rw [hprim]
  simp

omit [Fact p.Prime] in
/-- The `μ`-invariant of `X^n` is `0`. -/
theorem muInv_X_pow (n : ℕ) : muInv p ((X : Polynomial ℤ) ^ n) = 0 := by
  unfold muInv
  rw [content_X_pow]
  simp [padicValInt]

/-- The `λ`-invariant of `X^n` is `n`. -/
theorem lambdaInv_X_pow (n : ℕ) : lambdaInv p ((X : Polynomial ℤ) ^ n) = n := by
  have hprim : ((X : Polynomial ℤ) ^ n).primPart = X ^ n :=
    ((Polynomial.monic_X_pow n).isPrimitive).primPart_eq
  unfold lambdaInv reduce
  rw [hprim, Polynomial.map_pow, Polynomial.map_X]
  exact Polynomial.natTrailingDegree_X_pow n

/-! ### The Matsuno-type twist factor -/

/-- The modelled quadratic-twist factor: multiplication of the characteristic
element by `p^k · X^(c·k)`.  Its `μ`-invariant is `k` and its `λ`-invariant is
`c · k = c · μ`. -/
noncomputable def twistFactor (c k : ℕ) : Polynomial ℤ :=
  C ((p : ℤ) ^ k) * X ^ (c * k)

theorem twistFactor_ne_zero (c k : ℕ) : twistFactor p c k ≠ 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  apply mul_ne_zero
  · simpa using pow_ne_zero k hp0
  · exact pow_ne_zero _ X_ne_zero

/-- The twist factor has `μ`-invariant `k`. -/
theorem muInv_twistFactor (c k : ℕ) : muInv p (twistFactor p c k) = k := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ (c * k) ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [muInv_mul p hC hX, muInv_C_pow, muInv_X_pow, add_zero]

/-- The twist factor has `λ`-invariant `c · k`. -/
theorem lambdaInv_twistFactor (c k : ℕ) : lambdaInv p (twistFactor p c k) = c * k := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold twistFactor
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ (c * k) ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [lambdaInv_mul p hC hX, lambdaInv_C_pow, lambdaInv_X_pow, zero_add]

/-- **The λ-invariant of the twist factor is proportional to its μ-invariant**,
with proportionality constant `c`.  This is the model of the phenomenon that the
`λ`-invariant carries a contribution proportional to `μ`. -/
theorem lambdaInv_twistFactor_eq_const_mul_muInv (c k : ℕ) :
    lambdaInv p (twistFactor p c k) = c * muInv p (twistFactor p c k) := by
  rw [lambdaInv_twistFactor, muInv_twistFactor]

/-! ### The Matsuno formula in the model -/

/-- **Matsuno-type twist formula.**  Twisting the characteristic element `f` by
`twistFactor c k` shifts the `λ`-invariant by a term *proportional to the
μ-invariant of the twist*:

`λ_p(f · twist) = λ_p(f) + c · μ_p(twist)`. -/
theorem matsuno_twist_formula {f : Polynomial ℤ} (hf : f ≠ 0) (c k : ℕ) :
    lambdaInv p (f * twistFactor p c k)
      = lambdaInv p f + c * muInv p (twistFactor p c k) := by
  rw [lambdaInv_mul p hf (twistFactor_ne_zero p c k), lambdaInv_twistFactor,
    muInv_twistFactor]

/-- The companion `μ`-shift: `μ_p(f · twist) = μ_p(f) + μ_p(twist) = μ_p(f) + k`. -/
theorem matsuno_twist_mu {f : Polynomial ℤ} (hf : f ≠ 0) (c k : ℕ) :
    muInv p (f * twistFactor p c k) = muInv p f + k := by
  rw [muInv_mul p hf (twistFactor_ne_zero p c k), muInv_twistFactor]

/-- **Non-vanishing of the μ-contribution.**  When the twist has non-zero
μ-invariant (`k ≥ 1`) and the proportionality constant is non-zero (`c ≥ 1`),
the `λ`-invariant of the characteristic element *strictly increases* under the
twist, by an amount equal to `c` times the (non-zero) μ-invariant of the twist.
This is the model of Matsuno's non-vanishing `μ` correction term. -/
theorem matsuno_nonvanishing_mu {f : Polynomial ℤ} (hf : f ≠ 0) {c k : ℕ}
    (hc : 1 ≤ c) (hk : 1 ≤ k) :
    muInv p (twistFactor p c k) ≠ 0 ∧
      lambdaInv p f < lambdaInv p (f * twistFactor p c k) := by
  refine ⟨?_, ?_⟩
  · rw [muInv_twistFactor]; omega
  · rw [matsuno_twist_formula p hf, muInv_twistFactor]
    have : 1 ≤ c * k := Nat.one_le_iff_ne_zero.2 (by positivity)
    omega

/-! ### Worked numerical instances (machine-checked)

For the prime `p = 2`, proportionality constant `c = 2`, and twist exponent
`k = 3`, the twist factor is `C 8 · X⁶`, with `μ = 3` and `λ = 6 = 2·μ`. -/

example : lambdaInv 2 (twistFactor 2 2 3) = 6 := by rw [lambdaInv_twistFactor]

example : muInv 2 (twistFactor 2 2 3) = 3 := by rw [muInv_twistFactor]

example : lambdaInv 2 (twistFactor 2 2 3) = 2 * muInv 2 (twistFactor 2 2 3) :=
  lambdaInv_twistFactor_eq_const_mul_muInv 2 2 3

/-- With `μ ≠ 0` the twist strictly raises `λ`: here `λ` jumps by `6`. -/
example {f : Polynomial ℤ} (hf : f ≠ 0) :
    lambdaInv 2 (f * twistFactor 2 2 3) = lambdaInv 2 f + 6 := by
  rw [matsuno_twist_formula 2 hf, muInv_twistFactor]

end IwasawaMatsuno