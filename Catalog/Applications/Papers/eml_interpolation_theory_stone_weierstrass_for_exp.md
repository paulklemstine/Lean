# Computational Evidence — EML Interpolation Theory

Concise numerical evidence for the two formalized claims. All exact arithmetic;
the formal Lean proofs in `IntervalSeparation.lean` and `SquareApproximation.lean`
supersede this informal check.

## 1. Separation property — `g(t) = exp a · log(b t + c)` is strictly monotone

Take `a = b = c = 1`, so `g(t) = e · log(t + 1)`.

| t   | t+1  | log(t+1) | g(t) = e·log(t+1) |
|-----|------|----------|-------------------|
| 0.0 | 1.0  | 0.00000  | 0.00000           |
| 0.25| 1.25 | 0.22314  | 0.60662           |
| 0.50| 1.50 | 0.40546  | 1.10227           |
| 0.75| 1.75 | 0.55962  | 1.52127           |
| 1.0 | 2.0  | 0.69315  | 1.88416           |

Strictly increasing ⇒ injective ⇒ separates every pair of distinct points of
`[0,1]`. Matches `emlSep_strictMono` / `emlSepCM_injective`.

## 2. Explicit `x²` network — `emlSquare d (x) = exp(2 log(x+d)) = (x+d)²`

Error `E(d) = sup_{x∈[0,1]} |(x+d)² − x²| = 2d + d²` (attained at `x = 1`).
The formal bound `3d` is a clean upper bound (valid for `0 < d ≤ 1`).

| d = 1/n | true sup error 2d+d² | formal bound 3d |
|---------|----------------------|-----------------|
| 1/1     | 3.000000             | 3.000000        |
| 1/2     | 1.250000             | 1.500000        |
| 1/4     | 0.562500             | 0.750000        |
| 1/10    | 0.210000             | 0.300000        |
| 1/100   | 0.020100             | 0.030000        |

Rate `O(1/n)` confirmed (matches `emlSquare_rate`: error `≤ 3/n`).

## 3. Counterexample hunt
- Dropping `c > 0`: at `t = 0`, `log(b·0 + c) = log c`; for `c ≤ 0` the `log`
  argument is non-positive on part of `[0,1]`, breaking continuity/monotonicity.
  Confirms the positivity hypotheses are load-bearing (Lab Notes, Analysis).
- Dropping `d ≤ 1` in the `3d` bound: at `d = 2`, `2d+d² = 8 > 6 = 3d`, so the
  clean bound `3d` genuinely needs `d ≤ 1`. Reflected in `emlSquare_error`.

No counterexample to the stated (guarded) theorems was found.
