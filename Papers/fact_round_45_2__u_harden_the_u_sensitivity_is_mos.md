# Computational evidence for the u-hardening resolution split (paper 168 / exp 501)

Exploratory numerics used to choose and sanity-check the formal statements in
`Catalog/Logic/UHardenResolutionSplit.lean`, `Catalog/Logic/UHardenSharpResolution.lean`
and `Catalog/Logic/UHardenOffsetAverage.lean`.

**Status of the numbers below.** Everything in this file is *exploratory*: it was computed
with floating point / exact rationals in a scratch script and is **not** a verification.
Every claim that the project actually asserts is a Lean theorem in the three files above,
proved with no `sorry` and with only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## 1. The paper-168 arithmetic (exact rationals)

With `Δ(240) = 0.1073`, `Δ(960) = 0.0636` and the `1/N` residual model `Δ(N) = I + c/N`:

| quantity | value |
|---|---|
| measured recovery `D/Δ(240)` | `0.40727` (the reported "41 %") |
| extrapolated intrinsic level `I = (4Δ(960) − Δ(240))/3` | `0.049033` |
| intrinsic share `I/Δ(240)` | `0.45697` |
| resolution share `1 − I/Δ(240)` | `0.54303` = `(4/3) × 0.40727` |
| intrinsic share over the reported CI box | `[0.36005, 0.59849]` |
| predicted third cell `Δ(3840) = (5Δ(960) − Δ(240))/4` | `0.052675`, CI box `[0.0459, 0.0607]` |

Formalised as `p168_intrinsic_share_le` / `p168_intrinsic_share_ge` (share pinned to
`[9/25, 3/5]`), `richardson_resolution_share` (the exact `4/3` inflation factor),
`p168_point_intrinsic_minority`, `third_window_prediction`, `p168_third_window_interval`.

## 2. Does the residual really scale like `1/N`? — per-cell versus offset-averaged

Model response `S(x) = exp(−4x)` (antitone, Lipschitz), gates in the strip `[0.20, 0.43]`,
grid `gridUp N θ = ⌈θN⌉/N`.

*Single fixed gate pair* `θ₁ = 0.2537`, `θ₂ = 0.3491`:

| `N` | measured `Δ(N)` | residual `Δ(N) − Δ(∞)` | `N ×` residual |
|---|---|---|---|
| 240 | 0.115202 | +0.000213 | +0.051 |
| 480 | 0.115202 | +0.000213 | +0.102 |
| 960 | 0.115202 | +0.000213 | +0.205 |
| 3840 | 0.114807 | −0.000181 | −0.697 |
| 15360 | 0.115026 | +0.000037 | +0.572 |

The per-cell residual is *not* `∝ 1/N`, and it even changes sign: for one fixed gate pair
the drop is piecewise constant in `N` and jumps only when a gate crosses a grid point.
This is exactly the content of `cellAvg_qResp` (the measured response carries no
information about where in its rank cell the gate sits).

*Averaged over 4000 random gate offsets in the strip:*

| `N` | mean residual | `N ×` mean |
|---|---|---|
| 240 | −0.001218 | −0.2923 |
| 480 | −0.000607 | −0.2914 |
| 960 | −0.000309 | −0.2967 |
| 3840 | −0.000077 | −0.2947 |

`N ×` mean is constant to three digits: the `1/N` law is an **ensemble** statement about
the offset distribution, not a per-run one. Moreover the constant `−0.2947` matches
`(L₂ − L₁)/2 = (|S′(0.38)| − |S′(0.25)|)/2 = (0.875 − 1.472)/2 = −0.298` to within the
Monte-Carlo error. That match is what `cellAvg_resid_locally_linear` and
`cellAvg_drop_bias` prove exactly, and it fixes the sign: with a *decreasing* local slope
across the strip the averaged model predicts `D < 0`, the opposite of the reported
`D = +0.0437` (`hard_gate_steeper_iff`).

## 3. How often does the `240 → 960` refinement move the gate?

100 000 uniform gates on `(0, 1]`: fraction with `gridUp 240 θ ≠ gridUp 960 θ` = **0.74767**,
against the predicted `1 − 1/c = 0.75`. Proved exactly as `grids_agree_iff` plus
`agreement_cell_volume` (agreement sub-cell of length `1/(Mc)` inside a coarse cell of
length `1/M`).

## 4. Counterexample hunt

The universal claim "a nonzero cross-window difference certifies an intrinsic effect" was
tested first and fails immediately: for the linear response `S x = −x` with gates `0` and
`1/4`, windows `2` and `4` report drops `1/2` and `1/4`. This is the witness formalised as
`resolution_alone_can_produce_cross_window` (and, at the design's own scale,
`cross_window_linear_witness`: `D = L/320` for `S x = −Lx`, gates `0` and `1/960`).

No counterexample was found to the two structural claims that were subsequently proved
(`resid_refine_le`, `cross_window_nested_abs_le`): over 3000 random antitone `1`-Lipschitz
piecewise-linear responses with nested windows `M, cM` (`c ∈ {2,3,4}`), the largest observed
value of `|D| · M / L` was `0.75`, consistent with the proved bound `|D| ≤ L/M` and with the
explicit `3/4` witness `cross_window_linear_witness`.

## 5. OEIS

No integer sequence arises: all objects here are real-valued responses on a rational rank
grid, so no OEIS lookup applies.
