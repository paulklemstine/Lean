# Computational Evidence — EML Differential Algebra: Closure Properties

This note records the small-case checks that guided the formal development in
`EMLDifferentialAlgebra.lean` and `EMLDifferentialCorollaries.lean`.

The log-free **EML** class is the smallest set of functions `ℝ → ℝ` containing
`x` and the constants and closed under `+`, `×`, `exp` (the *exponential
polynomials*). A term is built from `var, const c, add, mul, expOf`.

## 1. Closure checks (small cases)

Syntactic derivative `D` (Leibniz on `×`, chain rule on `exp`):

| term `t`            | `t.eval`                | `D t`                                  | `(D t).eval`              |
|---------------------|-------------------------|----------------------------------------|---------------------------|
| `var`               | `x`                     | `const 1`                              | `1`                       |
| `const c`           | `c`                     | `const 0`                              | `0`                       |
| `mul var var`       | `x²`                    | `add (mul 1 x) (mul x 1)`              | `2x`                      |
| `expOf var`         | `eˣ`                    | `mul (expOf var) (const 1)`           | `eˣ`                      |
| `expOf (mul var var)` | `exp(x²)`             | `mul (expOf (x²)) (2x)`               | `2x·exp(x²)`              |

Each row was confirmed against `HasDerivAt` (the analytic derivative), giving the
theorem `EMLTerm.hasDerivAt_eval`. Composition was checked the same way via the
substitution operator `subst` (`eval_subst`).

## 2. Counterexample hunt

* **Field?** `x ↦ x⁻¹` (with `0⁻¹ = 0`). Evaluating near `0`: `(10⁻¹)⁻¹ = 10`,
  `(100⁻¹)⁻¹ = 100`, unbounded — discontinuous at `0`. Every EML function is
  continuous, so `x⁻¹ ∉ EML`. ⇒ EML is a **ring, not a field** (`not_isEML_inv`).
* **log?** `Real.log x → -∞` as `x → 0⁺` (`log(10⁻ⁿ) = -n·log 10`), discontinuous
  at `0`, hence `Real.log ∉ EML` (`not_isEML_log`).
* **Functional inverse?** `f(x) = x³` is EML and a bijection `ℝ → ℝ`. Its
  derivative `f'(0) = 3·0² = 0` vanishes. Any left inverse `g` (`g(x³)=x`) would
  need, by the chain rule at `0`, `g'(0)·0 = 1`, i.e. `0 = 1`. So no
  *differentiable* — hence no EML — left inverse exists (`no_eml_left_inverse_cube`).
  Numerically `g = ⋅^{1/3}` has a vertical tangent at `0` (`(10⁻⁶)^{1/3}=10⁻²`,
  slope `≈ (10⁻²)/(10⁻⁶) = 10⁴ → ∞`), confirming non-differentiability at `0`.

## 3. Integration

Partial closure (proved): `∫ c = c·x`, `∫ x = x²/2`, `∫ exp(a·x) = exp(a·x)/a`
(`a≠0`), and EML-integrability is a linear subspace (`HasEMLPrimitive_add/_smul`).

Full closure fails (conjectural, Liouville): `exp(x²) ∈ EML` but
`∫ exp(x²) dx = (√π/2)·erf(x)` is **non-elementary**, hence not EML. Numerically
the antiderivative grows like a non-rational, non-exponential profile; no finite
exp-polynomial matches its Taylor coefficients
`∑ x^{2k+1} / (k!(2k+1))` (= `x + x³/3 + x⁵/10 + x⁷/42 + …`), whose denominators
`1,3,10,42,216,…` (OEIS A007680, `(2n+1)·n!`) are not the eventual-constant /
exponential-type denominators produced by differentiating any fixed
exp-polynomial. This motivates the conjecture in `FUTURE_DIRECTIONS.md`.

## Scope note

This evidence stage is intentionally short: the closure claims are *constructive*
(a witnessing term is exhibited and checked against `HasDerivAt`), so the formal
proofs — not numerics — are the real verification. The numerics above only guided
target selection and the counterexample hunt.
