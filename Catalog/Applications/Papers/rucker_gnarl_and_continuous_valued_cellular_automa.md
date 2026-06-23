# Computational Evidence — Continuous-Valued Cellular Automata

Object of study: the symmetric three-point **continuous-valued** CA on `c : ℤ → ℝ`

```
step a c x = a·c(x-1) + (1 - 2a)·c(x) + a·c(x+1)        (stencil weights sum to 1)
```

with real diffusion coefficient `a`. Formalized in `ContinuousValuedCA.lean`.

## 1. Eigenvalues of the geometric modes `geom r x = r^x`

A one-step calculation gives the dispersion relation

```
step a (geom r) = λ(a,r) · geom r ,   λ(a,r) = (1 - 2a) + a·(r + 1/r).
```

Small cases (verified symbolically inside Lean — see `step_geom`,
`eigenvalue_one`, `eigenvalue_negOne`):

| mode            | r    | eigenvalue λ(a,r) |
|-----------------|------|-------------------|
| constant (DC)   |  1   | `1`               |
| checkerboard    | -1   | `1 - 4a`          |
| generic         |  r   | `(1-2a) + a(r+1/r)` |

The checkerboard `(-1)^x` is the Nyquist (highest-frequency) mode and carries the
**largest-modulus** eigenvalue among bounded real modes (|r| = 1), so it controls
sup-norm stability.

## 2. Stability threshold (counterexample / phase-boundary hunt)

We test `|λ(a,-1)| = |1 - 4a|` against the marginal value `1`:

| a      | 1 - 4a | |1-4a| | regime                         |
|--------|--------|-------|--------------------------------|
| -0.25  |  2.0   | 2.0   | unstable (anti-diffusive)      |
|  0.0   |  1.0   | 1.0   | marginal (boundary)            |
|  0.25  |  0.0   | 0.0   | maximally damping (stable)     |
|  0.5   | -1.0   | 1.0   | marginal (boundary)            |
|  0.75  | -2.0   | 2.0   | unstable (gnarl onset)         |

So `|1-4a| ≤ 1  ⇔  0 ≤ a ≤ 1/2`. The convex window `[0, 1/2]` is exactly the
sup-norm-contracting (laminar) regime; outside it the checkerboard amplitude
`(1-4a)^n` diverges. This is the content of `abs_iter_le` (inside) and
`unbounded_outside` (outside), packaged in `stability_dichotomy`.

## 3. Iterated amplitude check

`iter a n alt 0 = (1-4a)^n` (proved as `iter_alt_apply`). Sample for `a = 0.75`
(`1-4a = -2`): amplitudes `1, -2, 4, -8, 16, …` → modulus `2^n → ∞`, confirming
unbounded growth from a sup-norm-1 initial pattern.

For `a = 0.25` (`1-4a = 0`): amplitudes `1, 0, 0, …` — the checkerboard is killed
in a single step (perfect high-frequency damping), consistent with the maximum
principle.

## 4. OEIS

No integer sequence is central here; the dynamics is parametrized by a real
diffusion coefficient. The marginal amplitudes at the boundary `a ∈ {0, 1/2}` are
`±1` (period-2 / fixed under modulus), and at `a = 1/2` the orbit of the
checkerboard is the alternating sign sequence `1, -1, 1, -1, …` (A033999-like
`(-1)^n`), but this is incidental rather than the object of study.

## Conclusion

All numerical observations match the formal theorems; the experiments pinpoint the
linear-stability threshold `a = 1/2` (and `a = 0`) as the laminar boundary of the
gnarly zone, which is then proved rigorously in Lean.
