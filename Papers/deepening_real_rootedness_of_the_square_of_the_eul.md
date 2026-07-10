# Computational Evidence: real-rootedness of the square of the Eulerian triangle

The object studied is the **square of the Eulerian triangle**.  With `A(n,k)` the Eulerian
number (permutations of `[n]` with `k` descents), the squared-triangle entry is
`C(n,k) = ∑_j A(n,j)·A(j,k)` and the row polynomial is `B_n(x) = ∑_k C(n,k) x^k`.

## 1. Small-case rows `C(n,·)` (computed in Lean via `#eval`)

```
n=0  : []
n=1  : [1]
n=2  : [2, 0]
n=3  : [6, 1, 0]
n=4  : [24, 15, 1, 0]
n=5  : [120, 181, 37, 1, 0]
n=6  : [720, 2163, 995, 83, 1, 0]
n=7  : [5040, 27133, 23739, 4613, 177, 1, 0]
n=8  : [40320, 364395, 546551, 204247, 19563, 367, 1, 0]
n=9  : [362880, 5272861, 12643559, 8090341, 1534391, 79141, 749, 1, 0]
n=10 : [3628800, 82289163, 300161291, 304339263, 100211975, 10633035, 312659, 1515, 1, 0]
n=11 : [39916800, 1383131773, 7397448115, 11247242917, 5898501451, 1110382093, 70101907, 1222549, 3049, 1, 0]
```

Structural observations, all reflected in the formal file:

* The leading column is `C(n,0) = n!` (so the constant term of `B_n` is `n!`).  In the Lean
  file we only need the weaker `1 ≤ C(n,0)` (`sqCoeff_zero_pos`).
* Each `B_n` (for `n ≥ 2`) is **monic of degree `n-2`** with **all coefficients positive**.
* Positivity of the coefficients gives `B_n(x) > 0` for all `x ≥ 0`, hence every real root
  is negative — proved for *all* `n` as `sqPoly_root_neg`.

## 2. Numerical roots (Lean `Float` bisection)

All roots found are real, simple, and negative:

```
n=8  : -305.044, -49.193, -9.120, -2.718, -0.788, -0.138
n=9  : -626.567, -99.255, -15.942, -4.955, -1.682, -0.5146, -0.0853
n=10 : -1276.55, -198.81, -26.733, -8.378, -3.002, -1.1196, -0.3501, -0.05426
```

The row `n=8` has **two** roots in `(-1,0)` (`-0.788` and `-0.138`), which is exactly why
consecutive-integer brackets fail there.  Finer rational brackets `(-1,-1/2)` and `(-1/2,0)`
separate them; this is what the formal proof `realRooted8` uses.  Rows `n=9,10` likewise use
rational brackets near `0` (`(-1,-1/2),(-1/2,0)` for `n=9`; `(-1/2,-1/4),(-1/4,0)` for `n=10`).

## 3. Counterexample hunt

No counterexample to real-rootedness was found for `0 ≤ n ≤ 11`: in every case the row
polynomial has `deg B_n` distinct real (negative) roots.  This is consistent with the
conjecture that `B_n` is real-rooted for all `n`.

## 4. The structural identity

`#eval` confirms (and the file proves) the identity
`B_n(x) = ∑_j A(n,j)·A_j(x)`, where `A_j(x) = ∑_k A(j,k) x^k` is the `j`-th Eulerian
polynomial.  E.g. for `n=4`: `A_4 = x^3+11x^2+11x+1`, and
`24·A_0 + 15·A_1 + 1·A_2 + 0·A_3 + 0·A_4 = x^2+15x+24 = B_4`.
This realizes `B_n` as a nonnegative combination of the Eulerian polynomials.
