# Computational Evidence — Tropical EML learning theory

All numbers below were checked *inside Lean* (kernel-evaluated `example`s in the
corresponding files), not in an external script, so each item is machine-verified.

## 1. Tropical evaluation and its ReLU realization

`tpEval (1,0) [(-1,0)] x = max (x, -x) = |x|` (a tropical polynomial with two monomials).

| x   | `tpEval (1,0) [(-1,0)] x` | `(tpExpr (1,0) [(-1,0)]).eval x` (ReLU network) |
|-----|---------------------------|--------------------------------------------------|
| 2   | 2                         | 2                                                |
| −3  | 3                         | 3                                                |

Checked in `TropicalPWL.lean`; the general identity is `tpExpr_eval`, and each extra
tropical monomial costs exactly one ReLU unit (`max u v = v + relu (u − v)`).

## 2. Tropical loss landscape on the three-point sample `y = (0, 1, 2)`

`tropL1Loss y 3 x = |x| + |x − 1| + |x − 2|`.

| x | loss |
|---|------|
| 0 | 3    |
| 1 | 2    |
| 2 | 3    |

The minimum is at the median `x = 1`, matching `median_minimizes_tropL1`; the sharpness
prediction `L(x) ≥ L(1) + |x − 1|` is met with equality at `x = 0, 2` (`3 = 2 + 1`),
which shows the growth constant `μ = 1` in `tropL1_sharp_growth` is **optimal**, not an
artefact of the proof.

## 3. Fixed-step iterates: oscillation and divergence

Subgradient `tropL1Sub y 3 x = #{i : yᵢ ≤ x} − #{i : yᵢ > x}`.

| x  | subgradient |
|----|-------------|
| 0  | −1          |
| 1  | +1          |
| 3  | +3          |
| −6 | −3          |

* step `η = 1`, `x₀ = 0`: iterates `0, 1, 0, …` (period 2; verified for `n = 1, 2`).
* step `η = 3`, `x₀ = 3`: iterates `3, −6, 3, −6, …` — proved for **all** `n` in
  `fixedStep_two_cycle`, with `|xₙ − 1| ≥ 2` forever (`fixedStep_never_converges`).

This counterexample hunt is what rules out any theorem of the form "fixed-step tropical
descent converges"; the surviving statements are the best-iterate `O(1/√n)` bound with a
tuned step and the Polyak rule.

## 4. Polyak steps

With the same data and `x₀ = 0`, the loss gap is `1` and the subgradient is `−1`, so the
Polyak step size is `1` and one iteration lands exactly on the median:
`polyakIter … 0 1 = 1` (kernel-checked). The general contraction factor
`1 − 1/N² = 8/9` for `N = 3` is therefore not tight on this instance — consistent with,
and strictly weaker than, the observed finite termination.

## 5. Dequantization error

The bound `|lse T b l − tmax b l| ≤ T · log(k)` (with `k` terms) is exact at `T → 0` and
degenerates to the classical `log 2` gap at `T = 1`, `b = l = 0`: `lse 1 0 [] = 0` and
`largeWeight 1 0 [] = 0` are kernel-checked base cases.

No sequence in this project matched an OEIS entry (the objects are real-analytic /
piecewise-linear rather than integer sequences), so no OEIS identifiers are reported.
