# Computational Evidence — `L(x,y)` sieve lower bound

All computations were run in Lean (`#eval`) against the *definitions actually
formalized* in `Catalog/Novelty/SmoothNumberLowerBound.lean`, so the evidence and
the proved statements use identical objects.

Definitions:
- `IsSmooth y n := ∀ p ∈ n.primeFactors, p ≤ y`
- `L x y := #{ n ∈ Ioc 0 x | IsSmooth y n }`
- `primeContribution x y := ∑_{p ∈ (Ioc y x).filter Prime} x / p`

## 1. Small-case smooth counts `L 10 y`
`[L 10 2, L 10 3, L 10 5, L 10 10] = [4, 7, 9, 10]`
(2-smooth ≤10: 1,2,4,8; 3-smooth: +3,6,9; 5-smooth: +5,10; 10-smooth: +7 ... all 10.)

## 2. Sieve lower bound vs. truth (turned out EXACT in these ranges)
| (x, y)    | `L x y` | `x - primeContribution x y` |
|-----------|---------|------------------------------|
| (20, 5)   | 14      | 14                           |
| (30, 4)   | 12      | 12                           |
| (100, 10) | 46      | 46                           |

Equality here is explained and **proved**: in each case the two smallest primes
`> y` already multiply to `> x` (e.g. `5·7 = 35 > 30`), so no integer `≤ x` is
double-counted — exactly the hypothesis of `L_eq_sieve_of_no_double_large_factor`.

## 3. Saturation characterisation (counterexample hunt: none found)
For all `x ∈ [0, 30)`, the boolean
`(L x 4 == x)  ==  (#primes in (4, x] == 0)`
evaluated to `true` everywhere — consistent with the proved
`L_eq_iff_no_prime_between`. The first deficiency is at `x = 5` (prime `5`).

## 4. `x ≤ y ⇒ L x y = x`
For all `x ∈ [0, 15)`, `L x 20 == x` returned `true` — consistent with
`L_eq_self_of_le`.

## 5. OEIS note
For fixed `y = 2`, `L x 2` counts powers of two `≤ x`, giving `⌊log₂ x⌋ + 1`
(1,1,2,2,3,3,3,3,4,...), the 2-adic "number of powers of 2 ≤ n" sequence. The
general two-variable table `L(x,y)` is the partial-sum table of the friable
(smooth) number indicator; no single OEIS id captures the full bivariate array,
but row `y → ∞` is the identity `L x y = x` and is the trigger for §3.

No counterexample to any formalized statement was found; all checks corroborate
the theorems, which are themselves machine-verified (axioms:
`propext, Classical.choice, Quot.sound` only).
