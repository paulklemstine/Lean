import Mathlib
import EML.EMLDifferentialGalois

/-!
# The Logarithmic Derivative as an Exponential–Logarithmic Homomorphism

This file isolates the *algebraic engine* behind ODEs with exponential–logarithmic
coefficients, working in an arbitrary differential field `K` (Mathlib's
`Differential` typeclass, derivation `·′`).  It complements the Riccati/Wronskian
identities of `EML.EMLRiccatiTransform` and the differential-Galois layer of
`EML.EMLDifferentialGalois` by exposing the structural fact that makes "exp–log"
ODEs special:

> The logarithmic derivative `L(y) = y′/y` is a group homomorphism from the
> multiplicative group `K^×` to the additive group `(K, +)`.

This is precisely the abstract shadow of the identity `log(yz) = log y + log z`
together with `(log y)′ = y′/y`.  Multiplicative structure on solutions becomes
*additive* structure on coefficients, which is why first-order linear equations
`y′ = a·y` "exponentiate": the product of a solution of `y′ = a·y` and a solution
of `z′ = b·z` solves `w′ = (a+b)·w`.

## Main results

* `logDeriv_mul` — `(y·z)′/(y·z) = y′/y + z′/z` (homomorphism property).
* `logDeriv_div` — `(y/z)′/(y/z) = y′/y − z′/z`.
* `logDeriv_inv` — `(y⁻¹)′/(y⁻¹) = −(y′/y)`.
* `logDeriv_zpow` — `(y^n)′/(y^n) = n·(y′/y)` for `n : ℤ`.
* `firstOrder_mul` — **superposition**: `y′ = a·y`, `z′ = b·z ⇒ (y·z)′ = (a+b)·(y·z)`.
* `firstOrder_inv` — `y′ = a·y ⇒ (y⁻¹)′ = (−a)·y⁻¹`.
* `firstOrder_div` — `y′ = a·y`, `z′ = b·z ⇒ (y/z)′ = (a−b)·(y/z)`.
* `firstOrder_zpow` — `y′ = a·y ⇒ (y^n)′ = (n·a)·y^n`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the reason "exp–log" ODEs are tractable is a single
homomorphism `L : K^× → (K,+)`, `L(y) = y′/y`, intertwining the multiplicative
structure of solutions with the additive structure of coefficients. If so, the
whole first-order solution calculus (products, quotients, integer powers) is just
this homomorphism applied to the equation `y′ = a·y ⇔ L(y) = a`.

Experiment (Experimenter): every claim reduces to `Derivation.leibniz` (resp.
`leibniz_div`, `leibniz_inv`) followed by `field_simp` / `ring`. The `zpow` cases
go by `Int` induction (`zpow_natCast`/`Int.induction_on`) reusing `firstOrder_mul`
and `firstOrder_inv`. No characteristic, algebraic-closure, or analytic hypotheses
are used: only `Field K` and `Differential K`.

Analysis (Analyst): the homomorphism law `L(yz) = L(y) + L(z)` is *the* mechanism
turning the multiplicative Galois group of a first-order equation into an additive
datum (the coefficient). It explains, abstractly, why `exp(∫a)` solves `y′ = a·y`
and why the catalog's `firstOrder_ratio_isConstant` holds: ratios have `L = 0`,
i.e. land in the kernel = constants.

Critique (Critic): non-vacuous and load-bearing — every `logDeriv_*` statement
needs the nonvanishing hypotheses to form the quotients, and the proofs use genuine
Leibniz cancellation (`field_simp; ring`), never `rfl`/`decide`. The `zpow` law is
the first place the homomorphism is iterated, validating the "homomorphism" framing.

Synthesis (PI): together with `EMLDifferentialGalois` (kernel = constants) this
packages first-order EML ODEs as the homomorphism `L : K^× → (K,+)`: solutions of
`y′ = a·y` are the `L`-preimage of `a`, a coset of the constants, recovering
existence-up-to-constant purely algebraically. The concrete analytic realizations
live in `EML.EMLCoefficientODE`.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLLogDerivHom

variable {K : Type*} [Field K] [Differential K]

/-! ### The logarithmic derivative is a homomorphism `K^× → (K, +)` -/

/-- **Homomorphism property of the logarithmic derivative.** For nonzero `y, z`,
`(y·z)′/(y·z) = y′/y + z′/z`.  This is the abstract `log(yz) = log y + log z`. -/
theorem logDeriv_mul (y z : K) (hy : y ≠ 0) (hz : z ≠ 0) :
    (y * z)′ / (y * z) = y′ / y + z′ / z := by
  rw [Derivation.leibniz]; simp only [smul_eq_mul]; field_simp; ring

/-- **Quotient law.** For nonzero `y, z`, `(y/z)′/(y/z) = y′/y − z′/z`. -/
theorem logDeriv_div (y z : K) (hy : y ≠ 0) (hz : z ≠ 0) :
    (y / z)′ / (y / z) = y′ / y - z′ / z := by
  rw [Derivation.leibniz_div]; simp only [smul_eq_mul]; field_simp

/-- **Inverse law.** For nonzero `y`, `(y⁻¹)′/(y⁻¹) = −(y′/y)`. -/
theorem logDeriv_inv (y : K) (hy : y ≠ 0) :
    (y⁻¹)′ / y⁻¹ = - (y′ / y) := by
  rw [Derivation.leibniz_inv]; simp only [smul_eq_mul]; field_simp

/-! ### First-order solution calculus (superposition) -/

/-- **Superposition / exponentiation of solutions.** If `y′ = a·y` and `z′ = b·z`,
then the product `y·z` solves `w′ = (a+b)·w`.  Multiplicative structure on solutions
becomes additive structure on coefficients — the abstract content of
`exp(A)·exp(B) = exp(A+B)`. -/
theorem firstOrder_mul (a b y z : K) (hy : y′ = a * y) (hz : z′ = b * z) :
    (y * z)′ = (a + b) * (y * z) := by
  rw [Derivation.leibniz]; simp only [smul_eq_mul, hy, hz]; ring

/-- **Inverse solution.** If `y′ = a·y` and `y ≠ 0`, then `y⁻¹` solves
`w′ = (−a)·w`. -/
theorem firstOrder_inv (a y : K) (hy : y ≠ 0) (h : y′ = a * y) :
    (y⁻¹)′ = (-a) * y⁻¹ := by
  rw [Derivation.leibniz_inv]; simp only [smul_eq_mul, h]; field_simp

/-- **Quotient solution.** If `y′ = a·y`, `z′ = b·z` and `z ≠ 0`, then `y/z`
solves `w′ = (a−b)·w`. -/
theorem firstOrder_div (a b y z : K) (hz : z ≠ 0) (hy : y′ = a * y) (hzz : z′ = b * z) :
    (y / z)′ = (a - b) * (y / z) := by
  rw [Derivation.leibniz_div]; simp only [smul_eq_mul, hy, hzz]; field_simp

/-- **Integer-power solution.** If `y′ = a·y` and `y ≠ 0`, then `y^n` solves
`w′ = (n·a)·w` for every integer `n`.  This is the homomorphism `L` iterated. -/
theorem firstOrder_zpow (a y : K) (hy : y ≠ 0) (h : y′ = a * y) (n : ℤ) :
    (y ^ n)′ = ((n : K) * a) * y ^ n := by
  induction n using Int.induction_on with
  | zero => simp
  | succ k ih =>
      rw [zpow_add₀ hy, zpow_one, Derivation.leibniz]
      simp only [smul_eq_mul, ih, h]; push_cast; ring
  | pred k ih =>
      have e : y ^ (-(k : ℤ) - 1) = y ^ (-(k : ℤ)) * y⁻¹ := by
        rw [← zpow_neg_one, ← zpow_add₀ hy]; congr 1
      rw [e, Derivation.leibniz]
      simp only [smul_eq_mul, ih, firstOrder_inv a y hy h]
      push_cast; ring_nf

/-- **Logarithmic derivative of an integer power.** `(y^n)′/(y^n) = n·(y′/y)`. -/
theorem logDeriv_zpow (y : K) (hy : y ≠ 0) (n : ℤ) :
    (y ^ n)′ / (y ^ n) = (n : K) * (y′ / y) := by
  have hyn : y ^ n ≠ 0 := zpow_ne_zero _ hy
  have h := firstOrder_zpow (y′ / y) y hy (by field_simp) n
  rw [h]
  field_simp

end EMLLogDerivHom