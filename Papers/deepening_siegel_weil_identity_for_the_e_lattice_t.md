# Computational Evidence — Deepening the Siegel–Weil / E₈ identity

This note records the computational corroboration for the results formalized in
`SiegelWeilE8ThetaDeepening.lean`. All checks were run with Lean 4 / Mathlib
(`ArithmeticFunction.sigma`).

## 1. The E₈ vector counts `240·σ₃(n)`

`#eval [(sigma 3) 1, …, (sigma 3) 5].map (240 * ·)` gives

| n | 1 | 2 | 3 | 4 | 5 |
|---|----|-----|-----|------|------|
| 240·σ₃(n) | 240 | 2160 | 6720 | 17520 | 30240 |

These are exactly the numbers of vectors of squared length `2n` in the `E₈`
lattice (`240` roots, then `2160, 6720, 17520, 30240`), matching the Fourier
coefficients of `E₄`. Sequence: OEIS **A004009** (theta series of E₈ lattice,
`1, 240, 2160, 6720, 17520, 30240, …`) and its coefficient system **A008386**
(`240·σ₃`).

## 2. The generalized global Hecke identity

For **every** exponent `s`, we claim
`σ_s(m)·σ_s(n) = ∑_{d ∣ gcd(m,n)} d^s·σ_s(mn/d²)`.

Exhaustive check over `s ∈ {0,1,2,3,4,5}`, `m ∈ {1,2,3,4,6,12}`,
`n ∈ {1,2,3,4,6,12,18}`:

```
#eval ([0,1,2,3,4,5].all fun s => [1,2,3,4,6,12].all fun m =>
        [1,2,3,4,6,12,18].all fun n => lhs s m n == rhs s m n)
-- true
```

No counterexample found. (Note `s = 0` gives `σ₀ = τ`, the number-of-divisors
function; the identity holds there too, confirming it is not special to weight 4.)

## 3. The global Hecke `T_p` eigenvalue relation

`σ_s(p)·σ_s(n) = σ_s(pn) + [p ∣ n]·p^s·σ_s(n/p)` for prime `p` and all `n ≥ 1`:

```
#eval (do let s ← [1,3,5]; let p ← [2,3,5];
          let n ← [1,2,3,4,6,8,12,18]; pure (tpL s p n == tpR s p n)).all id
-- true
```

Worked example (`s = 3, p = 2, n = 6`): `σ₃(2)·σ₃(6) = 9·252 = 2268`, while
`σ₃(12) + 2³·σ₃(3) = 2044 + 8·28 = 2044 + 224 = 2268`. ✓

## 4. The cubic / power lower bound

`n^s ≤ σ_s(n)` (the divisor `n` contributes `n^s`):

```
#eval ([0,1,3].all fun s => [1,2,3,6,12].all fun n => n^s ≤ (sigma s) n)
-- true
```

## Counterexample hunt

No counterexample was found for any of the universal claims across the sampled
ranges. The `s = 0` case was included specifically to probe whether the Hecke
structure degenerates at low weight; it does not, which is consistent with the
theorem being a statement about divisor-power sums for all `s`.
