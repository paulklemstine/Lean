# Computational Evidence — normalized `q`-series, pole orders, and `⋆`-roots

All computations below were run inside Lean 4 (`#eval`) with exact rational
arithmetic on truncated power series (coefficient lists over `ℚ`).  They are
*exploratory*: they guided which theorems to formalize.  Statements that are
machine-checked appear in the `.lean` files and are flagged **[proved]** below;
anything not so flagged is empirical only.

Convention.  A normalized `q`-series is `f = q⁻¹ + a₀ + a₁ q + a₂ q² + ⋯`.  Its
*power-series part* is `F = q·f = 1 + a₀X + a₁X² + ⋯`, so
`coeff n F = f.coeff (n-1)`.  The corrected product is `f ⋆ g = q f g`, whose
power-series part is `F·G`.

## 1. Small cases: pole order of finite products

| number of factors `m` | `orderTop (∏ fᵢ)` | `orderTop (q^{m} ∏ fᵢ)` | `q^{m-1} ∏ fᵢ` normalized? |
|---|---|---|---|
| 1 | −1 | 0 | yes |
| 2 | −2 | 0 | yes |
| 3 | −3 | 0 | yes |
| 194 (Monster) | −194 | 0 | yes |

**[proved]** `PoleOrderObstruction.orderTop_prod_normalized`,
`NormalizedQSeries.isNormalized_qPow_mul_prod_iff` (the exponent `m-1` is the
unique one restoring normalization).

## 2. Moonshine data used

* `J   = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + 20245856256 q⁴ + ⋯`
  (OEIS A000521 gives the `j`-function coefficients; the normalized
  `J = j - 744` has `a₀ = 0`).
* `T_2A = q⁻¹ + 4372 q + 96256 q² + 1240002 q³ + 10698752 q⁴ + ⋯`.

Power-series parts (index `n` ↔ Laurent degree `n-1`):

```
F_J    = [1, 0, 196884, 21493760, 864299970, 20245856256, 333202640600,
          4252023300096, 44656994071935, 401490886656000]
F_T2A  = [1, 0,   4372,    96256,   1240002,    10698752]
```

## 3. Corrected product `q · J · T_2A`

```
#eval mulT F_J F_T2A 5
-- [1, 0, 201256, 21590016, 1726316820, 133178540032]
```

The coefficient `201256 = 196884 + 4372` reproduces
**[proved]** `PoleOrderObstruction.coeff_zero_prod_J_mul_T2A` and the general
subleading formula `PoleOrderObstruction.coeff_prod_normalized_subleading`
(subleading coefficient of a product = sum of constant terms; here both are 0 at
the first step and the sum rule appears one degree later).

## 4. `⋆`-square root of `J`

```
#eval sqrtT F_J 9
-- [1, 0, 98442, 10746880, -4413263697, -1047821432832, 376869391313174,
--     150580578862513152, -35577391320709928685, -23497935558209789278208]
#eval (sqrtT F_J 9).map Rat.den
-- [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
```

* `98442 = 196884/2` and `10746880 = 21493760/2` match the proved formulas
  **[proved]** `NormalizedQSeries.coeff_star_sqrt`,
  `NormalizedQSeries.coeff_star_sqrt_third`, and the numeric instances
  `coeff_star_sqrt_J`, `coeff_star_sqrt_J_third`.
* **Empirical, not proved:** every computed coefficient of the `⋆`-square root
  of `J` is an *integer* through degree 9, even though the naive recursion
  divides by 2 at each step.  This is a nontrivial family of 2-adic congruences
  on the coefficients of `J`.  (See FUTURE_DIRECTIONS, direction 1.)
* Signs alternate irregularly (`-4413263697` at degree 4), so the square root is
  **not** a character-series-like object with non-negative coefficients: no
  positivity survives `⋆`-roots.

## 5. `⋆`-cube root of `J` — the pattern fails

```
#eval (cbrtT F_J 9).map Rat.den
-- [1, 1, 1, 3, 1, 1, 9, 1, 1, 81]
```

Denominators `3, 9, 81` appear, so the integrality observed for the square root
is specific to the prime 2 (at least for `J`).  This sharpens direction 1 into a
prime-specific conjecture rather than a general "roots are integral" claim.

## 6. `⋆`-inverse of `J`

```
#eval invT F_J 5
-- [1, 0, -196884, -21493760, 37899009486, 8443309031424]
#eval mulT F_J (invT F_J 5) 5
-- [1, 0, 0, 0, 0, 0]
```

The first two nontrivial coefficients `-196884`, `-21493760` match
**[proved]** `NormalizedQSeries.coeff_star_inv`
(`g.coeff 0 = -f.coeff 0`, `g.coeff 1 = (f.coeff 0)² - f.coeff 1`, here with
`f.coeff 0 = 0`).

## 7. Counterexample hunt

* *Is the ordinary product of two normalized series ever normalized?*  No: the
  order is `-2 ≠ -1` for every pair.  **[proved]**
  `PoleOrderObstruction.prod_isNormalized_iff` (normalized iff exactly one
  factor).
* *Is there a nontrivial `⋆`-root of unity?*  Searched over series
  `1 + cX + O(X²)` with `c ≠ 0`: `(1+cX)ⁿ` always has linear coefficient
  `nc ≠ 0`, so no.  **[proved]** in general:
  `NormalizedQSeries.eq_one_of_pow_eq_one_of_constantCoeff_one`.
* *Can two different normalized series have the same `⋆`-`n`-th power?*  No.
  **[proved]** `NormalizedQSeries.Normalized.pow_left_injective`.

## 8. Reproducing the evaluations

```lean
import Mathlib
def mulT (a b : List ℚ) (N : Nat) : List ℚ :=
  (List.range (N+1)).map (fun n =>
    (List.range (n+1)).foldl (fun acc i => acc + (a.getD i 0) * (b.getD (n-i) 0)) 0)
def sqrtT (a : List ℚ) (N : Nat) : List ℚ :=
  (List.range (N+1)).foldl (fun g n =>
    if n = 0 then [1] else g ++ [((a.getD n 0) - ((mulT g g N).getD n 0)) / 2]) []
def cbrtT (a : List ℚ) (N : Nat) : List ℚ :=
  (List.range (N+1)).foldl (fun g n =>
    if n = 0 then [1] else
      g ++ [((a.getD n 0) - ((mulT (mulT g g N) g N).getD n 0)) / 3]) []
def invT (a : List ℚ) (N : Nat) : List ℚ :=
  (List.range (N+1)).foldl (fun g n =>
    if n = 0 then [1] else g ++ [-((mulT g a N).getD n 0)]) []
```
