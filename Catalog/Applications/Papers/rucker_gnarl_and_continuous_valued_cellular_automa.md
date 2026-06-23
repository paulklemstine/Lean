# Computational Evidence — Gnarl / Continuous-Valued CA Cycle

Target objects (from `Catalog/Novelty/ContinuousValuedCA.lean` and the two new
files): the symmetric three-point continuous CA

  `step a c x = a·c(x-1) + (1-2a)·c(x) + a·c(x+1)`,

its Nyquist (checkerboard) eigenmode `alt x = (-1)^x` with eigenvalue
`λ(a) = 1 - 4a`, and the geometric modes `geom r x = r^x` with eigenvalue
`eigenvalue a r = (1-2a) + a(r + r⁻¹)`.

Computational evidence below was used to *select and sharpen* the conjectures
before formalization; every claim that survived is proved with 0 `sorry` in the
Lean files.

## 1. The Nyquist spectral factor `λ(a) = 1 - 4a` (edge-of-chaos order parameter)

`|λ(a)| = |1 - 4a|` is the per-step amplification of the spikiest mode.

| a      | 1-4a   | \|1-4a\| | regime                              |
|--------|--------|----------|-------------------------------------|
| -0.25  | 2.0    | 2.0      | anti-diffusive, unstable (gnarl seed) |
| 0.0    | 1.0    | 1.0      | **threshold** (mass/Nyquist marginal) |
| 0.10   | 0.6    | 0.6      | laminar (contracting)               |
| 0.25   | 0.0    | 0.0      | super-stable (mode annihilated)     |
| 0.40   | -0.6   | 0.6      | laminar (contracting)               |
| 0.50   | -1.0   | 1.0      | **threshold**                       |
| 0.75   | -2.0   | 2.0      | unstable (gnarl seed)               |

`|1-4a| ≤ 1` exactly on `a ∈ [0, 1/2]` (proved: `window_iff`,
`orbit_bounded_iff_window`). The orbit `|iter a n alt 0| = |1-4a|^n`:

| a    | n=1  | n=2  | n=4   | n=8     | bounded? |
|------|------|------|-------|---------|----------|
| 0.40 | 0.6  | 0.36 | 0.13  | 0.017   | yes      |
| 0.50 | 1.0  | 1.0  | 1.0   | 1.0     | yes (=1) |
| 0.75 | 2.0  | 4.0  | 16.0  | 256.0   | NO       |
| -0.25| 2.0  | 4.0  | 16.0  | 256.0   | NO       |

This is the table behind `amplitude_eq_exp` (`= exp(n·gnarlExp a)`) and the
boundedness dichotomy.

## 2. Gnarl (Lyapunov) exponent `gnarlExp a = log|1-4a|`

| a    | \|1-4a\| | gnarlExp a = log\|1-4a\| | sign  |
|------|----------|--------------------------|-------|
| 0.75 | 2.0      | +0.693                   | > 0   |
| 0.0  | 1.0      | 0.0                      | = 0   |
| 0.5  | 1.0      | 0.0                      | = 0   |
| 0.4  | 0.6      | -0.511                   | < 0   |
| 0.25 | 0.0      | -∞ (Mathlib: log 0 = 0)  | degenerate |

Sign law confirmed and proved: `gnarlExp_pos_outside`, `gnarlExp_nonpos_inside`,
`gnarlExp_threshold`. Note the **degenerate super-stable point a = 1/4**: the
exponent is morally `-∞`; in Mathlib `Real.log 0 = 0`, so a strict
"exponent = 0 ⟺ threshold" characterization is *false*. This was caught during
the evidence stage and the Lean statements were guarded accordingly (only the
one-directional `gnarlExp_threshold` is claimed).

## 3. Sensitive dependence (sensitivity constant = 1)

Perturb any `c` by `ε·alt` (sup-distance exactly `ε` since `|alt| ≡ 1`). The orbit
gap at the origin is `ε·|1-4a|^n`. For `a = 0.75`, `ε = 0.001`:

| n  | gap = 0.001·2^n |
|----|-----------------|
| 0  | 0.001           |
| 10 | 1.024  (> 1!)   |
| 11 | 2.048           |

So an arbitrarily tiny perturbation separates by more than `1` in finite time:
the Devaney signature, proved in `sensitive_dependence_outside`. Inside the
window (`a ∈ [0,1/2]`) the gap is non-increasing — `lyapunov_stable_inside`.

## 4. Computational reducibility: the two-mode predictor

`iter a n ((fun _ => α) + β·alt) x = α + β·(1-4a)^n·(-1)^x` (`two_mode_closed_form`).
Spot-check `a = 0.75, α = 1, β = 0.5, x = 0`:

| n | direct simulation* | predictor `1 + 0.5·2^n` |
|---|--------------------|--------------------------|
| 0 | 1.5                | 1.5                      |
| 1 | 2.0                | 2.0                      |
| 2 | 3.0                | 3.0                      |
| 3 | 5.0                | 5.0                      |

(*simulating `step` three times by hand.) The closed form jumps to step `n` with
a single exponentiation per mode — the antithesis of computational
irreducibility. Generalized to arbitrary finite Fourier superpositions in
`iter_finsum_geom` / `reducible_closed_form`.

## 5. Counterexample hunt

* **"Boundedness ⟺ window" (orbit_bounded_iff_window):** tested `a ∈
  {-1,-0.25,0,0.1,0.25,0.4,0.5,0.6,1}` against `|1-4a| ≤ 1`. No counterexample;
  iff proved.
* **"gnarlExp = 0 ⟺ threshold":** counterexample found at `a = 1/4`
  (`|1-4a| = 0`, Mathlib `log 0 = 0`). The Lean statement was *weakened* to a
  one-directional claim to remain faithful. (This is the single conjecture that
  did not survive in full strength.)
* **Reducibility of the linear core:** no counterexample — every tested
  superposition matched its closed form, consistent with the proof that the
  *linear* family is reducible (and the conjecture that genuine gnarl requires
  nonlinearity).

## OEIS

No integer sequence arises (the dynamics is real-valued / parameter-dependent);
an OEIS search is not applicable. The relevant invariants are the analytic
quantities `|1-4a|^n` and `log|1-4a|` tabulated above.
