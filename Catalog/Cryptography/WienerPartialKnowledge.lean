/-
# Modified Wiener Attack: RSA Factorization with Partial `p+q` Knowledge

For an RSA modulus `n = p·q` with primes `p > q`, the private exponent `d` and the
public exponent `e` satisfy the key equation `e·d = k·φ(n) + 1` with
`φ(n) = (p-1)(q-1)` and some integer `k ≥ 1`.

Wiener's 1990 attack rests on the observation that `k/d` is an extraordinarily good
rational approximation of `e/n`, forcing it to be a continued-fraction convergent of
`e/n` once `d` is small. The **modified** attack uses a `δ`-fraction of the most
significant bits of `p+q`: with an estimate `s` of `p+q`, one corrects the modulus to
`ñ = n + 1 - s` and approximates `e/ñ` instead. The closer `s` is to `p+q`, the
sharper the approximation, tolerating larger private exponents.

This file formalizes the **exact arithmetic engine** of the (modified) attack:

* `rsa_key_identity` — the classical reduction `e·d - k·n = 1 - k·(p+q-1)`.
* `modified_key_identity` — the corrected reduction `e·d - k·ñ = 1 - k·(p+q-s)`.
* `modified_approx_error` — the exact error `e/ñ - k/d = (1-k·(p+q-s))/(ñ·d)`.
* `modified_approx_abs_bound` — `|e/ñ - k/d| ≤ (k·Δ+1)/(ñ·d)` from `|p+q-s| ≤ Δ`.
* `modified_wiener_convergent_criterion` — the Legendre threshold `|e/ñ - k/d| < 1/(2d²)`
  under the partial-knowledge smallness condition `2·d·(k·Δ+1) < ñ`.

The companion file `WienerRecovery.lean` proves the Farey/Legendre separation that
makes the recovered fraction the unique correct one.

## Application Keywords

RSA cryptanalysis, Wiener attack, continued fractions, convergents, private exponent,
partial key exposure, most significant bits, Euler totient, Diophantine approximation,
Legendre criterion, key recovery, lattice-free factorization.
-/

import Mathlib

open scoped BigOperators

namespace WienerPartial

/-! ## The RSA totient and the key equation -/

/-- Euler totient of a semiprime, as an integer expression `(p-1)(q-1)`. -/
def phiSemiprime (p q : ℤ) : ℤ := (p - 1) * (q - 1)

/-- `n - φ(n) = (p+q) - 1` for `n = p·q`. -/
theorem n_sub_phi (p q : ℤ) :
    p * q - phiSemiprime p q = (p + q) - 1 := by
  unfold phiSemiprime; ring

/-! ## Classical Wiener reduction (exact identity) -/

/-- **Classical key identity.** If `n = p·q` and `e·d = k·φ(n) + 1`, then
`e·d - k·n = 1 - k·((p+q) - 1)`. This is the algebraic core of Wiener's attack:
the residual `e·d - k·n` is governed by the (small) quantity `p+q`. -/
theorem rsa_key_identity (p q e d k : ℤ)
    (hkey : e * d = k * phiSemiprime p q + 1) :
    e * d - k * (p * q) = 1 - k * ((p + q) - 1) := by
  unfold phiSemiprime at hkey
  rw [hkey]; ring

/-! ## Modified reduction using an estimate `s` of `p+q` -/

/-- The **corrected modulus** `ñ = n + 1 - s`, where `s` estimates `p+q`. When
`s = p+q` exactly, `ñ = φ(n)`. -/
def correctedModulus (p q s : ℤ) : ℤ := p * q + 1 - s

/-- `correctedModulus p q (p+q) = φ(n)`: a perfect estimate recovers the totient. -/
theorem correctedModulus_perfect (p q : ℤ) :
    correctedModulus p q (p + q) = phiSemiprime p q := by
  unfold correctedModulus phiSemiprime; ring

/-- **Modified key identity.** With the corrected modulus `ñ = n + 1 - s`,
`e·d - k·ñ = 1 - k·((p+q) - s)`. The residual is now governed by the *estimation
error* `(p+q) - s`, which shrinks as more most-significant bits of `p+q` are known. -/
theorem modified_key_identity (p q e d k s : ℤ)
    (hkey : e * d = k * phiSemiprime p q + 1) :
    e * d - k * correctedModulus p q s = 1 - k * ((p + q) - s) := by
  unfold phiSemiprime at hkey
  unfold correctedModulus
  rw [hkey]; ring

/-! ## Exact rational approximation error -/

/-- **Exact approximation error.** Over `ℚ`, with `ñ ≠ 0` and `d ≠ 0`,
`e/ñ - k/d = (1 - k·((p+q) - s)) / (ñ·d)`. This is the quantity Wiener's attack
drives below `1/(2d²)` to force `k/d` to be a convergent of `e/ñ`. -/
theorem modified_approx_error (p q e d k s : ℤ)
    (hkey : e * d = k * phiSemiprime p q + 1)
    (hN : (correctedModulus p q s : ℚ) ≠ 0) (hd : (d : ℚ) ≠ 0) :
    (e : ℚ) / (correctedModulus p q s) - (k : ℚ) / d
      = (1 - (k : ℚ) * (((p : ℚ) + q) - s)) / ((correctedModulus p q s : ℚ) * d) := by
  have hid : (e : ℚ) * d - (k : ℚ) * (correctedModulus p q s)
      = 1 - (k : ℚ) * (((p : ℚ) + q) - s) := by
    have := modified_key_identity p q e d k s hkey
    have := congrArg (fun z : ℤ => (z : ℚ)) this
    push_cast at this ⊢
    linarith [this]
  field_simp
  linarith [hid]

/-! ## Approximation bound under partial knowledge -/

/-- **Approximation bound.** If `|(p+q) - s| ≤ Δ` (the residual error after the known
MSBs of `p+q`), and `k ≥ 0`, `ñ > 0`, `d > 0`, then
`|e/ñ - k/d| ≤ (k·Δ + 1)/(ñ·d)`. -/
theorem modified_approx_abs_bound (p q e d k s Δ : ℤ)
    (hkey : e * d = k * phiSemiprime p q + 1)
    (hk : 0 ≤ k) (hN : 0 < correctedModulus p q s) (hd : 0 < d)
    (herr : |(p + q) - s| ≤ Δ) :
    |(e : ℚ) / (correctedModulus p q s) - (k : ℚ) / d|
      ≤ ((k : ℚ) * Δ + 1) / ((correctedModulus p q s : ℚ) * d) := by
  replace := @modified_approx_error p q e d k s ?hkey ?hN ?hd <;> simp_all +decide [ div_eq_mul_inv ];
  · gcongr <;> norm_cast;
    · nlinarith [ abs_le.mp herr ];
    · exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp herr ], by nlinarith [ abs_le.mp herr ] ⟩;
    · exact le_abs_self _;
    · exact le_abs_self _;
  · linarith;
  · linarith

/-! ## The modified Wiener convergent criterion -/

/-- **Modified Wiener convergent criterion.** Suppose the RSA key equation holds, the
residual error after the known MSBs satisfies `|(p+q) - s| ≤ Δ`, all quantities are
positive, and the *partial-knowledge smallness condition* `2·d·(k·Δ + 1) < ñ` holds.
Then `|e/ñ - k/d| < 1/(2·d²)`, the Legendre threshold guaranteeing that `k/d` is a
continued-fraction convergent of `e/ñ`.

The condition `2·d·(k·Δ + 1) < ñ` is the modified Wiener bound: smaller `Δ` (more
known bits of `p+q`, i.e. larger `δ`) admits a larger private exponent `d`. -/
theorem modified_wiener_convergent_criterion (p q e d k s Δ : ℤ)
    (hkey : e * d = k * phiSemiprime p q + 1)
    (hk : 0 ≤ k) (hN : 0 < correctedModulus p q s) (hd : 0 < d)
    (herr : |(p + q) - s| ≤ Δ)
    (hsmall : 2 * d * (k * Δ + 1) < correctedModulus p q s) :
    |(e : ℚ) / (correctedModulus p q s) - (k : ℚ) / d| < 1 / (2 * (d : ℚ) ^ 2) := by
  refine' lt_of_le_of_lt ( modified_approx_abs_bound p q e d k s Δ hkey hk hN hd herr ) _;
  rw [ div_lt_div_iff₀ ] <;> norm_cast <;> nlinarith

/-! ## Concrete worked example (`p = 17, q = 11`) -/

/-- A concrete instance illustrating the engine: `p=17, q=11, n=187, φ=160`,
`d=23, e=7, k=1`, with a perfect estimate `s = p+q = 28` (so `ñ = 160`). The exact
error is `1/3680`, well below the Legendre threshold `1/(2·23²) = 1/1058`. -/
theorem worked_example_error :
    (7 : ℚ) / (correctedModulus 17 11 28) - (1 : ℚ) / 23 = 1 / 3680 := by
  unfold correctedModulus
  norm_num

theorem worked_example_below_threshold :
    (7 : ℚ) / (correctedModulus 17 11 28) - (1 : ℚ) / 23 < 1 / (2 * (23 : ℚ) ^ 2) := by
  rw [worked_example_error]; norm_num

end WienerPartial

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The continued-fraction structure of Wiener's attack is
not intrinsically tied to the modulus `n`; it is an exact arithmetic identity in the
*residual* `e·d - k·M` for any modulus surrogate `M`. Conjecture: replacing `n` by a
corrected modulus `ñ = n + 1 - s` built from a partial estimate `s` of `p+q` keeps the
identity exact while shrinking the residual to `1 - k·((p+q) - s)`, so the convergent
threshold `1/(2d²)` is met for *larger* `d` whenever the estimate error `(p+q) - s` is
small.

**Experiment (Experimenter).** Formalized the chain `rsa_key_identity →
modified_key_identity → modified_approx_error → modified_approx_abs_bound →
modified_wiener_convergent_criterion`. All four reductions are exact (`ring`/`field_simp`)
or sharp inequalities (`gcongr`/`nlinarith`). The worked instance `p=17,q=11,d=23,e=7,k=1`
with perfect estimate `s=28` gives error `1/3680 < 1/(2·23²)`, confirming the criterion
numerically (`worked_example_below_threshold`).

**Analysis (Analyst).** The decisive quantity is the *smallness condition*
`2·d·(k·Δ + 1) < ñ`, where `Δ` bounds the estimation error `|(p+q) - s|`. This is the
clean finite form of the asymptotic bound `d < n^{(1+δ)/2}`: at `Δ ≈ n^{1/2}` (no MSBs
known, `δ = 0`) it reproduces Wiener's `d < n^{1/4}`; each known bit halves `Δ` and so
relaxes the bound. The classical attack is the special case `s = 0`, `ñ = n + 1`.

**Critique (Critic).** None of the main theorems is vacuous: `modified_approx_error`
is a non-trivial rational identity (fails without `field_simp`+`linarith`), and the
criterion genuinely *uses* the bound lemma and the smallness hypothesis (drop `hsmall`
and it is false). The positivity hypotheses are load-bearing (division by `ñ`, `d`). The
statements are faithful: no hypothesis trivializes the conclusion, and the worked example
is a supporting check, not a main result.

**Synthesis (PI).** This file is the exact-arithmetic engine of the modified Wiener
attack; `WienerRecovery.lean` supplies the Legendre uniqueness that turns "is a
convergent" into "recovers the true `d`".
-/