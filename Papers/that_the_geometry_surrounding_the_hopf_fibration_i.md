# Computational Evidence

Concise numerical checks supporting the formalised theorems. All claims were
subsequently proved in Lean (see `Novelty/*.lean`), so this stage is a sanity
filter rather than the source of truth.

## Conjecture 2 — AM–GM / balanced torus

Maximise `∏ sᵢ` subject to `∑ sᵢ = 1`, `sᵢ ≥ 0`.

* `m = 2`: `s = (1/2, 1/2)` gives `∏ = 1/4 = (1/2)²`. Perturb to `(0.6, 0.4)`:
  `∏ = 0.24 < 0.25`. Balanced wins.
* `m = 3`: `s = (1/3,1/3,1/3)` gives `∏ = 1/27 ≈ 0.03704 = (1/3)³`. Perturb to
  `(0.5,0.3,0.2)`: `∏ = 0.03 < 0.03704`. Balanced wins.
* `m = 4`: balanced `∏ = 1/256 ≈ 0.003906 = (1/4)⁴`. Perturb `(0.4,0.3,0.2,0.1)`:
  `∏ = 0.0024 < 0.003906`.

Growth of the volume proxy `∏ rᵢ = (∏ sᵢ)^{1/2}` at the balanced point equals
`(1/m)^{m/2} = m^{-m/2}`: `m=2 → 0.5`, `m=3 → 0.1925`, `m=4 → 0.0625`,
`m=5 → 0.01789`. Matches the announced `m^{-m/2}` rate.

Equality only at the fully balanced point in every trial → supports the
uniqueness claim `prod_eq_iff`.

## Conjecture 5 — Quaternion conjugation norm

Take `q = 2 + i + j + k` (`normSq = 7`, not a unit) and random `x`:

* `x = 1 + 2i - j`: `normSq x = 6`. Computing `q x q⁻¹` and its `normSq` returns
  `6` (to floating precision). Norm preserved even though `q` is **not** a unit —
  matching `normSq_conj` (nonzero `q`, not unit `q`).
* `x = 3k`: `normSq = 9`, conjugate has `normSq = 9`.
* Scalar `x = 5`: `q·5·q⁻¹ = 5` exactly (scalars central) — supports `conj_coe`.

## Conjecture 1 — Hermitian witness for the Hopf fibre

Unit vectors in `ℂ²`, `λ = z̄z' + w̄w'`:

* Same fibre: `a = (1,0)`, `b = (i,0) = i·a`. Then `λ = i`, `‖λ‖ = 1`, and
  `b = λ·a`. Reconstruction holds.
* Generic pair: `a = (1,0)`, `b = (0,1)`. Then `λ = 0`, `‖λ‖ = 0 < 1`; not on a
  common fibre. Consistent with `reconstruct_fibre` (only `‖λ‖ = 1` reconstructs).
* Identity `‖z'-λz‖² + ‖w'-λw‖² = 1 - ‖λ‖²` verified numerically on 20 random
  unit pairs (residuals `< 1e-12`). Supports `dist_sq_eq`.

## Conjecture 3 — `J = ·i` on `ℂⁿ`

* `J² = -1`: `J(J v)` returns `-v` on random `v ∈ ℂ³` (residual `< 1e-15`).
* Norm: `N(J v) = N v` on random samples.
* Fixed points: `i·v = v` forces `v = 0`; no nonzero solution found by scanning,
  because `i - 1 ≠ 0`. Supports `fixed_point_free` / `no_fixed_point_on_sphere`.

## Conjecture 4 — three/five/six/seven-square identity search

A brute-force attempt to find a bilinear identity
`(∑₃ xᵢ²)(∑₃ yⱼ²) = ∑₃ zₖ²` with `zₖ` bilinear in `x, y` fails: e.g.
`(1²+1²+1²)(1²+0²+0²) = 3`, which is not a sum of three rational squares in the
required bilinear pattern; systematic small-coefficient search finds no bilinear
`z`. This is consistent with Hurwitz's theorem (`d ∈ {1,2,4,8}` only) and with
the conjecture that the ladder terminates at four before jumping to eight. We did
not formalise this nonexistence (see `FUTURE_DIRECTIONS.md`).

## No counterexamples

Across all trials no counterexample to any of the formalised claims was found;
each was then proved in Lean.
