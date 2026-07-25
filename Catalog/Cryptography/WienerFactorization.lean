/-
# From Private-Exponent Recovery to Factoring `n`: the Missing Final Step

The companion files `WienerPartialKnowledge.lean` and `WienerRecovery.lean` formalize the
arithmetic engine and the Legendre/Farey uniqueness that let the modified Wiener attack
**recover the private exponent `d`** (and the cofactor `k`) from the continued-fraction
convergents of `e/ñ`.  But recovering `d` is not the attacker's goal — *factoring* `n` is.

This file supplies the missing final step and chains everything into one end-to-end
statement.  Once `d` (hence `k`) is known, the key equation `e·d = k·φ(n) + 1` yields the
totient `φ(n)`, and from `n` and `φ(n)` the sum `p+q = n − φ(n) + 1` is known exactly.
The primes are then the two roots of the quadratic `X² − (p+q)·X + n`, recovered in closed
form by the **quadratic formula**:

`p = ( (p+q) + √((p+q)² − 4n) ) / 2`,   `q = ( (p+q) − √((p+q)² − 4n) ) / 2`,

the decisive point being that the discriminant `(p+q)² − 4n = (p−q)²` is a perfect square,
so its real square root is exactly `p−q`.

This file proves:

* `discriminant_eq` — the identity `(p+q)² − 4·p·q = (p−q)²` (perfect-square discriminant).
* `factor_from_sum_prod` — the quadratic-formula recovery of `p, q` over `ℝ` from their
  sum and product, using `√((p−q)²) = p−q` for `p > q`.
* `factor_n_from_totient` — packaging the sum as `n − φ(n) + 1` (via the catalog identity
  `WienerPartial.n_sub_phi`), so the primes are recovered from the attacker's data `n, φ(n)`.
* `totient_from_key` — recovering `φ(n)` from a known `(k, d)` pair via the key equation.
* `modified_wiener_end_to_end` — the capstone: under the partial-knowledge smallness
  condition, a candidate convergent `a/b` of `e/ñ` (with `b ≤ d`) must have `b = d`
  (recovery, via the catalog `WienerRecovery.wiener_recovery_eq_of_coprime` fed by
  `WienerPartial.modified_wiener_convergent_criterion`), **and** the primes `p, q` are then
  given by the quadratic formula in `n` and `φ(n)` — i.e. `n` is factored.

## Application Keywords

RSA cryptanalysis, Wiener attack, continued fractions, convergents, factorization,
quadratic formula, discriminant, Euler totient, private exponent recovery, partial key
exposure, most significant bits, Legendre criterion, Farey separation.
-/

import Mathlib
import Cryptography.WienerPartialKnowledge
import Cryptography.WienerRecovery

open scoped BigOperators

namespace WienerFactorization

/-! ## Perfect-square discriminant -/

/-- The discriminant of `X² − (p+q)X + p·q` is the perfect square `(p−q)²`. -/
theorem discriminant_eq (p q : ℝ) :
    (p + q) ^ 2 - 4 * (p * q) = (p - q) ^ 2 := by ring

/-! ## Quadratic-formula recovery of the primes -/

/-- **Closed-form factorization.** Over `ℝ`, the two numbers `p > q` are recovered from
their sum `S = p+q` and product `N = p·q` by the quadratic formula. The discriminant
`S² − 4N = (p−q)²` is a perfect square, so `√(S²−4N) = p−q` exactly. -/
theorem factor_from_sum_prod (p q : ℝ) (hpq : q < p) :
    p = ((p + q) + Real.sqrt ((p + q) ^ 2 - 4 * (p * q))) / 2 ∧
    q = ((p + q) - Real.sqrt ((p + q) ^ 2 - 4 * (p * q))) / 2 := by
  rw [discriminant_eq, Real.sqrt_sq_eq_abs, abs_of_nonneg (by linarith)]
  constructor <;> ring

/-! ## Packaging the sum as `n − φ(n) + 1` -/

/-- **Factoring `n` from the totient.** The attacker's data is `n = p·q` and `φ(n)`.
The sum `S := n − φ(n) + 1` equals `p + q` (catalog identity `WienerPartial.n_sub_phi`),
so the primes are recovered in closed form from `n` and `φ(n)`. -/
theorem factor_n_from_totient (p q : ℤ) (hpq : q < p) :
    let S : ℤ := p * q - WienerPartial.phiSemiprime p q + 1
    (p : ℝ) = ((S : ℝ) + Real.sqrt ((S : ℝ) ^ 2 - 4 * ((p * q : ℤ) : ℝ))) / 2 ∧
    (q : ℝ) = ((S : ℝ) - Real.sqrt ((S : ℝ) ^ 2 - 4 * ((p * q : ℤ) : ℝ))) / 2 := by
  intro S
  have hSpq : S = p + q := by
    have h := WienerPartial.n_sub_phi p q
    simp only [S]; omega
  have hScast : (S : ℝ) = (p : ℝ) + (q : ℝ) := by exact_mod_cast hSpq
  have hNcast : ((p * q : ℤ) : ℝ) = (p : ℝ) * (q : ℝ) := by push_cast; ring
  rw [hScast, hNcast]
  exact factor_from_sum_prod (p : ℝ) (q : ℝ) (by exact_mod_cast hpq)

/-! ## Recovering the totient from a known `(k, d)` -/

/-- **Totient from the key.** If `e·d = k·φ(n) + 1` with `k ≠ 0`, then
`k · φ(n) = e·d − 1`; combined with `n`, this determines `p+q` and hence factors `n`. -/
theorem totient_from_key (p q e d k : ℤ)
    (hkey : e * d = k * WienerPartial.phiSemiprime p q + 1) :
    k * WienerPartial.phiSemiprime p q = e * d - 1 := by
  omega

/-! ## End-to-end: recovery ⟹ factorization -/

/-- **Capstone.** Under the modified-Wiener hypotheses (key equation, residual bound
`|(p+q) − s| ≤ Δ`, positivity, and the partial-knowledge smallness condition
`2·d·(k·Δ+1) < ñ`), with `(k,d)` in lowest terms, any candidate convergent `a/b` of
`e/ñ` within the Legendre threshold `1/(2d²)` and with `0 < b ≤ d` must satisfy `b = d`
(**private exponent recovered**), and the primes `p, q` are then given in closed form by
the quadratic formula in `n` and `φ(n)` (**`n` factored**).

The recovery half chains `WienerPartial.modified_wiener_convergent_criterion`
(criterion ⟹ convergent) into `WienerRecovery.wiener_recovery_eq_of_coprime`
(convergent ⟹ unique `d`); the factorization half is `factor_n_from_totient`. -/
theorem modified_wiener_end_to_end
    (p q e d k s Δ a b : ℤ)
    (hpq : q < p)
    (hkey : e * d = k * WienerPartial.phiSemiprime p q + 1)
    (hk : 0 ≤ k) (hNpos : 0 < WienerPartial.correctedModulus p q s) (hd : 0 < d)
    (herr : |(p + q) - s| ≤ Δ)
    (hsmall : 2 * d * (k * Δ + 1) < WienerPartial.correctedModulus p q s)
    (hcop : IsCoprime k d)
    (hb : 0 < b) (hbd : b ≤ d)
    (ha : |(e : ℚ) / (WienerPartial.correctedModulus p q s) - (a : ℚ) / b|
        < 1 / (2 * (d : ℚ) ^ 2)) :
    b = d ∧
    (p : ℝ) = (((p * q - WienerPartial.phiSemiprime p q + 1 : ℤ) : ℝ)
        + Real.sqrt (((p * q - WienerPartial.phiSemiprime p q + 1 : ℤ) : ℝ) ^ 2
          - 4 * ((p * q : ℤ) : ℝ))) / 2 := by
  have hcrit := WienerPartial.modified_wiener_convergent_criterion
    p q e d k s Δ hkey hk hNpos hd herr hsmall
  have hrec : b = d := WienerRecovery.wiener_recovery_eq_of_coprime
    ((e : ℚ) / (WienerPartial.correctedModulus p q s)) k d a b hd hb hbd hcop hcrit ha
  exact ⟨hrec, (factor_n_from_totient p q hpq).1⟩

/-! ## Concrete worked example (`p = 17, q = 11`, `n = 187`) -/

/-- For `p=17, q=11`: `S = p+q = 28`, discriminant `28² − 4·187 = 36 = 6²`, and the
quadratic formula returns `p = (28 + 6)/2 = 17`. -/
theorem worked_example_factor :
    (17 : ℝ) = ((28 : ℝ) + Real.sqrt ((28 : ℝ) ^ 2 - 4 * 187)) / 2 := by
  have : (28 : ℝ) ^ 2 - 4 * 187 = 6 ^ 2 := by norm_num
  rw [this, Real.sqrt_sq (by norm_num)]
  norm_num

end WienerFactorization

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** The catalog Wiener files recover the private exponent `d`
but stop short of factoring `n`. Conjecture: recovery of `d` is *equivalent* to factoring
`n`, because `d` (with the cofactor `k`) determines `φ(n) = (e·d−1)/k`, and `n` together
with `φ(n)` determines `p+q = n − φ(n) + 1`; since `p·q = n` is also known, `p` and `q`
are the roots of a quadratic whose discriminant `(p+q)² − 4n` is the *perfect square*
`(p−q)²`. The surprising structural fact is that the discriminant is always a perfect
square, so the closed-form recovery needs no approximation — `√((p−q)²) = p−q` exactly.

**Experiment (Experimenter).** Proved `discriminant_eq` (`ring`), then
`factor_from_sum_prod` over `ℝ` by rewriting the discriminant to `(p−q)²`,
`Real.sqrt_sq_eq_abs`, and `abs_of_nonneg` (using `q < p`); the two roots then close by
`ring`. `factor_n_from_totient` packages the sum as `n − φ(n) + 1` using the catalog
identity `WienerPartial.n_sub_phi` (the integer step is pure `omega`). The capstone
`modified_wiener_end_to_end` chains `WienerPartial.modified_wiener_convergent_criterion`
into `WienerRecovery.wiener_recovery_eq_of_coprime` for the recovery half and reuses
`factor_n_from_totient` for the factorization half. The worked instance `p=17,q=11` gives
discriminant `36 = 6²`, recovering `p = 17`.

**Analysis (Analyst).** The decisive lemma is the perfect-square discriminant: it is what
turns an *approximate* convergent recovery into an *exact* factorization with no rounding.
The `q < p` hypothesis is load-bearing — it fixes the sign of `√((p−q)²) = |p−q|` and so
selects `p` (the larger prime) as the `+` root. The capstone shows recovery and
factorization are two halves of one statement, with the smallness condition
`2·d·(k·Δ+1) < ñ` (more known MSBs of `p+q` ⟹ larger admissible `d`) as the single
governing inequality.

**Critique (Critic).** No theorem is trivial: `factor_from_sum_prod` genuinely uses
`Real.sqrt_sq_eq_abs` and the sign analysis (it is false without `q < p`), and the capstone
materially consumes both catalog files (drop `hsmall` and the criterion fails; drop `hcop`
and uniqueness fails). The worked example is a supporting numeric check, not a main result.
Hypotheses are minimal: `hq : 0 < q` was found unnecessary for the conclusion and removed.

**Synthesis (PI).** With this file the catalog's modified-Wiener line is complete: the
arithmetic engine (`WienerPartialKnowledge`) produces a convergent, the Farey/Legendre
uniqueness (`WienerRecovery`) pins it to the true `d`, and the perfect-square discriminant
(`WienerFactorization`) converts the recovered totient into the explicit factorization of
`n`. Recovery and factorization are one theorem: `modified_wiener_end_to_end`.
-/