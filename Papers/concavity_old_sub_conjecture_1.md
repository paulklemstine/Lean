# Computational Evidence — Concavity of the Lagrange exponent `σ`

All numbers below were produced by `#eval` inside the project's Lean toolchain, using
`Float` arithmetic, with

```lean
def cb (x : Float) : Float := if x ≥ 0 then x^(1.0/3.0) else -((-x)^(1.0/3.0))
def sg (t : Float) : Float := (1.0 + cb (27.0*t - 1.0))/3.0   -- σ
def h  (y : Float) : Float := y^3 - y^2 + y/3.0               -- critical cubic
```

These are exploratory floating-point computations; every claim that survived the
exploration is proved exactly in `Catalog/Novelty/LagrangeExponent*.lean`.
Nothing here is a substitute for those proofs.

## 1. Small-case calculations: `σ` inverts the critical cubic

| `t` | `σ t` | `h (σ t)` |
|---|---|---|
| 0.001 | 0.003027 | 0.001000 |
| 0.010 | 0.033196 | 0.010000 |
| 1/27 ≈ 0.037037 | **0.333333** | 0.037037 |
| 0.100 | 0.731161 | 0.100000 |
| 1/3 | **1.000000** | 0.333333 |
| 1.000 | 1.320832 | 1.000000 |
| 10.00 | 2.485105 | 10.000000 |
| 100.0 | 4.974349 | 100.000000 |

The round trip `h ∘ σ = id` holds to full float precision; the two boldface rows are the
exact values `σ(1/27) = 1/3` and `σ(1/3) = 1` proved as
`lagrangeExponent_critical` and `lagrangeExponent_one_third`.

## 2. Midpoint gap `Δ(s,t) = σ((s+t)/2) − (σ s + σ t)/2`

Concavity ⟺ `Δ ≥ 0`.

**Both endpoints above the critical mass `1/27`** — all gaps positive:

| `(s,t)` | `Δ` |
|---|---|
| (1/27, 1) | +0.290029 |
| (0.05, 0.5) | +0.115429 |
| (0.1, 10) | +0.436653 |
| (1, 100) | +0.881110 |
| (2, 3) | +0.006281 |

**Both endpoints below `1/27`** — all gaps *negative* (curvature reverses):

| `(s,t)` | `Δ` |
|---|---|
| (−1, 0) | −0.140068 |
| (0, 1/27) | −0.097900 |
| (−0.5, 0.02) | −0.116823 |
| (−10, −1) | −0.184484 |

**Straddling pairs** — sign depends on the pair, so no ray `[a,∞)` with `a < 1/27` can be
concave:

| `(s,t)` | `Δ` |
|---|---|
| (−1, 1) | −0.320985 |
| (0, 0.1) | +0.202663 |
| (−0.001, 0.05) | −0.181610 |
| (0.03, 0.04) | −0.102765 |

The last row is the decisive one: `0.03` and `0.04` are *both within 0.008 of the
threshold* and already give a violation, which is exactly the mechanism formalised in
`lagrangeExponent_not_concaveOn_Ici` (take the two test points `a` and `1/27`, both in the
convex region).

## 3. Counterexample hunt

Discrete second differences `σ(t+ε) − 2σ(t) + σ(t−ε)` with `ε = 0.05` on
`t = 0.05, 0.10, …, 0.40`:

```
-0.405326, -0.077340, -0.022770, -0.011848, -0.007469, -0.005218, -0.003888, -0.003029
```

All negative — no counterexample to concavity found above the threshold. (The first entry
is large because the stencil reaches down to `t = 0`, i.e. across the inflection.)
A sweep of pairs below the threshold produced only negative gaps, i.e. **the convex
behaviour there is systematic, not sporadic** — this is what motivated proving
`lagrangeExponent_strictConvexOn_Iic` rather than merely a single counterexample.

## 4. The cube-root sandwich

Gap `σ t − ∛t`:

| `t` | 1/27 | 0.1 | 1 | 10 | 1000 |
|---|---|---|---|---|---|
| `σ t − ∛t` | 0.000000 | 0.267002 | 0.320832 | 0.330670 | 0.333210 |

The gap starts at exactly `0` at the critical mass and increases monotonically towards
`1/3`. This numerical pattern is what suggested — and is now proved by —
`cbrt_le_lagrangeExponent`, `lagrangeExponent_le_cbrt_add_third`, and
`lagrangeExponent_sandwich_sharp_at_critical`. The constant `1/3` in the upper bound is
therefore optimal.

## 5. OEIS

No integer sequence arises: the objects here are real-analytic (a real algebraic function
of degree 3 and its inverse), so an OEIS lookup is not applicable. The only distinguished
rationals are the critical pair `(1/27, 1/3)` and the sample values `σ(1/3) = 1`,
`σ(28/27) = 4/3`, all of which are proved exactly in `LagrangeExponentCore.lean`.
