# Computational Evidence — Gamma–Poisson duality for integer-shape descendant limits

This note collects small-case evidence for the identity proved in
`GammaPoissonDuality.lean`:

> For every integer shape `m + 1 ≥ 1`,
> `∫₀ᵗ e^{-x} x^m / m! dx = 1 − ∑_{k=0}^{m} e^{-t} t^k / k!`,
> i.e. `P(Gamma(m+1,1) ≤ t) = P(Poisson(t) ≥ m+1)`.

## 1. Small-case survival functions (exact symbolic form)

Writing `S_{m+1}(t) = ∑_{k=0}^{m} e^{-t} t^k / k!`:

| shape `m+1` | survival `S_{m+1}(t)` (Poisson tail form) |
|-------------|--------------------------------------------|
| 1           | `e^{-t}` |
| 2           | `e^{-t}(1 + t)` |
| 3           | `e^{-t}(1 + t + t²/2)` |
| 4           | `e^{-t}(1 + t + t²/2 + t³/6)` |

Each satisfies `S_{m+1}(0) = 1` and `S_{m+1}'(t) = −e^{-t} t^m/m!`, the negative
of the Gamma`(m+1,1)` density; this is the telescoping derivative that drives the proof.

## 2. Boundary checks

* At `t = 0`: the integral is `0` and `1 − S_{m+1}(0) = 1 − 1 = 0`. ✓
* As `t → ∞`: `S_{m+1}(t) → 0` (polynomial × `e^{-t}`), so the CDF → `1`; the density
  is a genuine probability density. ✓

## 3. Moment cross-check (target Gamma`(d,1)` law)

From `GammaLimitLaw.lean`, the integer moments are rising factorials
`m_k = ∏_{i<k}(d+i)`:

| `d` | `m₁` (mean) | `m₂` | `m₃` | variance `m₂ − m₁²` |
|-----|-------------|------|------|----------------------|
| 2   | 2           | 6    | 24   | 2 |
| 3   | 3           | 12   | 60   | 3 |
| 4   | 4           | 20   | 120  | 4 |

The mean and variance both equal `d`, matching the Gamma`(d,1)` limit target and the
`n^{1/d}` normalisation of `DescendantScaling.lean`.

## 4. Sequence note

For `d = 2` the moment sequence `2, 6, 24, 120, …` is `(k+1)!` (OEIS A000142 shifted),
consistent with Gamma`(2,1)` moments `m_k = (k+1)!`.

## 5. Counterexample hunt

No counterexample to the CDF identity was found: the derivative/FTC argument is exact and
holds for all real `t` and all integer shapes, so there is no parameter regime to falsify.
