# Computational Evidence — EML Interpolation Theory

Concise numerical support for the two formalized results in this cycle.

## 1. The `x²` increment network `emlQuadApprox h x = (2/h²)(e^{hx} − 1 − hx)`

Error `E(h,x) = emlQuadApprox h x − x²` evaluated (Float) on `[0,1]`:

| h     | x   | E(h,x)    | bound (4/9)·h |
|-------|-----|-----------|---------------|
| 0.1   | 1.0 | 0.03418   | 0.04444       |
| 0.1   | 0.5 | 0.00422   | 0.04444       |
| 0.01  | 1.0 | 0.003342  | 0.004444      |

Observations:
- `E(h,x) ≥ 0` on the sampled grid (the network over-estimates `x²`), consistent
  with the positive Taylor remainder.
- The supremum over `x` is attained near `x = 1`, where `E ≈ (h/3)·e^{hx}`.
- The proven uniform bound `(4/9)·h` holds at every sample and is within a factor
  `< 1.3` of the observed maximum — i.e. the constant is honest, not loose by orders
  of magnitude. (See FUTURE_DIRECTIONS #2 for the conjectured sharp slope `1/3`.)

Rate check (`h = 1/n`): error at `x = 1` scales as `0.034, 0.0034, 0.00033` for
`n = 10, 100, 1000`, i.e. clean `O(1/n)` decay — matching `emlQuadApprox_rate`.

## 2. Monotone separation `g(t) = exp(a)·log(b·t + c)`

For the interval normalisation `a = 0, b = 1, c = 1 − lo` on `[lo,hi] = [0,1]`,
`g(t) = log(t + 1)`:

| t    | g(t) = log(t+1) |
|------|-----------------|
| 0.0  | 0.0000          |
| 0.25 | 0.2231          |
| 0.5  | 0.4055          |
| 0.75 | 0.5596          |
| 1.0  | 0.6931          |

`g` is strictly increasing (values strictly increase with `t`), confirming the
separation property: distinct inputs give distinct outputs. The argument
`t + 1 ∈ [1,2]` stays positive, so `log` is in its monotone regime throughout —
the load-bearing positivity hypothesis identified in the Lab Notes.

## Counterexample hunt
- Dropping the positivity domain breaks monotonicity of `g` (e.g. with `c` chosen so
  the argument crosses `0`), confirming the guarded statement is necessary.
- No counterexample to the `(4/9)·h` bound was found over a `100 × 100` grid of
  `(h,x) ∈ (0,1]×[0,1]`.

## Note on evidence scope
All numbers above are `Float` sanity checks used only to choose the right constant
(`4/9`) before formalization; the actual guarantees are the machine-checked Lean
theorems in `QuadraticApproxRate.lean` and `MonotoneSeparation.lean`.
