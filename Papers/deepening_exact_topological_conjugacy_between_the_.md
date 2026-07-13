# Computational Evidence: the logistic iterate is a Chebyshev polynomial

**Claim.** For every `n` and every real `x`,
`fⁿ(x) = (1 - T_{2ⁿ}(1 - 2x)) / 2`,
where `f(x) = 4x(1-x)` is the logistic map and `T_m` is the degree-`m` Chebyshev
polynomial of the first kind (`T_m(cos θ) = cos(m θ)`).

## 1. Small-case exact calculations (over ℚ)

Chebyshev polynomials used:
`T_2(y) = 2y² - 1`, `T_4(y) = 8y⁴ - 8y² + 1` (so `T_{2¹}`, `T_{2²}`).

| `n` | seed `x` | `fⁿ(x)` (iterated) | `(1 - T_{2ⁿ}(1-2x))/2` | match |
|-----|----------|--------------------|------------------------|-------|
| 1   | 3/10     | 21/25              | 21/25                  | ✅ |
| 2   | 3/10     | 336/625            | 336/625                | ✅ |
| 2   | 7/13     | 672/28561          | 672/28561              | ✅ |

These are *exact* rational computations (no floating point), reproduced in Lean:

```lean
def logistic (x : ℚ) : ℚ := 4*x*(1-x)
def T2 (y : ℚ) : ℚ := 2*y^2 - 1
def T4 (y : ℚ) : ℚ := 8*y^4 - 8*y^2 + 1
#eval (logistic (3/10),               (1 - T2 (1 - 2*(3/10)))/2)  -- (21/25, 21/25)
#eval (logistic (logistic (3/10)),    (1 - T4 (1 - 2*(3/10)))/2)  -- (336/625, 336/625)
#eval (logistic (logistic (7/13)),    (1 - T4 (1 - 2*(7/13)))/2)  -- (672/28561, 672/28561)
```

## 2. Degree check

`deg T_{2ⁿ} = 2ⁿ` and `1 - 2X` is linear, so `T_{2ⁿ}(1-2X)` has degree `2ⁿ`;
the rescaling `(1 - •)/2` preserves degree. This matches the classical fact that
the `n`-th logistic iterate is a polynomial of degree `2ⁿ`, verified for
`n = 0,1,2,3` by direct expansion (`1, 2, 4, 8`).

## 3. Why no counterexample hunt is needed for the universal claim

The identity is an equality of polynomials. Both sides are polynomial functions of
`x`; they agree on the entire interval `[0,1]` (an infinite set) because there the
substitution `x = sin²φ` turns `fⁿ` into angle `2ⁿ`-doubling and `T_{2ⁿ}(cos 2φ)`
into `cos(2ⁿ⁺¹φ)`. Two polynomials agreeing on an infinite set are identically
equal, so the identity holds for *all* real `x`. The numeric samples above (chosen
both inside and independent of any special structure) are consistent with this.

## 4. Periodic points: exact factorisation for `n = 2`

The fixed points of `f²` (points of period dividing `2`) come from the exact
factorisation, verified over ℚ:

`f²(x) - x = -4·x·(x - 3/4)·(16x² - 20x + 5)`.

```lean
def f (x : ℚ) : ℚ := 4*x*(1-x)
-- agrees on a sample of rational points (exact arithmetic):
#eval ([(0:ℚ),1,2,3,1/2,1/3,2/5,7/9]).all
  (fun x => f (f x) - x == -4*x*(x-3/4)*(16*x^2-20*x+5))  -- true
```

The factor `x` gives `0`, the factor `x - 3/4` gives the other fixed point `3/4`,
and `16x² - 20x + 5 = 0` gives the genuine period-`2` orbit `x = (5 ± √5)/8`
(numerically `≈ 0.3455` and `≈ 0.9045`). All four are distinct, so `f²` has exactly
`4 = 2²` fixed points, matching the conjectured `2ⁿ` count for `n = 2`. This is
formalised as `logistic_iterate2_fixedPoints_card`.

## 5. OEIS

The degree sequence `1, 2, 4, 8, 16, …` of the iterates is `A000079` (powers of
two); the number of period-`n` points of the tent/logistic map is `2ⁿ` = `A000079`
as well. No new sequence is introduced.


# Computational Evidence: the logistic iterate is a Chebyshev polynomial

**Claim.** For every `n` and every real `x`,
`fⁿ(x) = (1 - T_{2ⁿ}(1 - 2x)) / 2`,
where `f(x) = 4x(1-x)` is the logistic map and `T_m` is the degree-`m` Chebyshev
polynomial of the first kind (`T_m(cos θ) = cos(m θ)`).

## 1. Small-case exact calculations (over ℚ)

Chebyshev polynomials used:
`T_2(y) = 2y² - 1`, `T_4(y) = 8y⁴ - 8y² + 1` (so `T_{2¹}`, `T_{2²}`).

| `n` | seed `x` | `fⁿ(x)` (iterated) | `(1 - T_{2ⁿ}(1-2x))/2` | match |
|-----|----------|--------------------|------------------------|-------|
| 1   | 3/10     | 21/25              | 21/25                  | ✅ |
| 2   | 3/10     | 336/625            | 336/625                | ✅ |
| 2   | 7/13     | 672/28561          | 672/28561              | ✅ |

These are *exact* rational computations (no floating point), reproduced in Lean:

```lean
def logistic (x : ℚ) : ℚ := 4*x*(1-x)
def T2 (y : ℚ) : ℚ := 2*y^2 - 1
def T4 (y : ℚ) : ℚ := 8*y^4 - 8*y^2 + 1
#eval (logistic (3/10),               (1 - T2 (1 - 2*(3/10)))/2)  -- (21/25, 21/25)
#eval (logistic (logistic (3/10)),    (1 - T4 (1 - 2*(3/10)))/2)  -- (336/625, 336/625)
#eval (logistic (logistic (7/13)),    (1 - T4 (1 - 2*(7/13)))/2)  -- (672/28561, 672/28561)
```

## 2. Degree check

`deg T_{2ⁿ} = 2ⁿ` and `1 - 2X` is linear, so `T_{2ⁿ}(1-2X)` has degree `2ⁿ`;
the rescaling `(1 - •)/2` preserves degree. This matches the classical fact that
the `n`-th logistic iterate is a polynomial of degree `2ⁿ`, verified for
`n = 0,1,2,3` by direct expansion (`1, 2, 4, 8`).

## 3. Why no counterexample hunt is needed for the universal claim

The identity is an equality of polynomials. Both sides are polynomial functions of
`x`; they agree on the entire interval `[0,1]` (an infinite set) because there the
substitution `x = sin²φ` turns `fⁿ` into angle `2ⁿ`-doubling and `T_{2ⁿ}(cos 2φ)`
into `cos(2ⁿ⁺¹φ)`. Two polynomials agreeing on an infinite set are identically
equal, so the identity holds for *all* real `x`. The numeric samples above (chosen
both inside and independent of any special structure) are consistent with this.

## 4. Periodic points: exact factorisation for `n = 2`

The fixed points of `f²` (points of period dividing `2`) come from the exact
factorisation, verified over ℚ:

`f²(x) - x = -4·x·(x - 3/4)·(16x² - 20x + 5)`.

```lean
def f (x : ℚ) : ℚ := 4*x*(1-x)
-- agrees on a sample of rational points (exact arithmetic):
#eval ([(0:ℚ),1,2,3,1/2,1/3,2/5,7/9]).all
  (fun x => f (f x) - x == -4*x*(x-3/4)*(16*x^2-20*x+5))  -- true
```

The factor `x` gives `0`, the factor `x - 3/4` gives the other fixed point `3/4`,
and `16x² - 20x + 5 = 0` gives the genuine period-`2` orbit `x = (5 ± √5)/8`
(numerically `≈ 0.3455` and `≈ 0.9045`). All four are distinct, so `f²` has exactly
`4 = 2²` fixed points, matching the conjectured `2ⁿ` count for `n = 2`. This is
formalised as `logistic_iterate2_fixedPoints_card`.

## 5. OEIS

The degree sequence `1, 2, 4, 8, 16, …` of the iterates is `A000079` (powers of
two); the number of period-`n` points of the tent/logistic map is `2ⁿ` = `A000079`
as well. No new sequence is introduced.
