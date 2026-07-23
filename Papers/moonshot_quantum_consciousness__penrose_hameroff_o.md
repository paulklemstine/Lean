# Computational Evidence — Penrose–Hameroff Orch OR

## 1. The Penrose objective-reduction (OR) time

Penrose's collapse principle: a superposition of two mass distributions with
gravitational self-energy difference `E` reduces after

    τ ≈ ħ / E,        ħ = 1.0546×10⁻³⁴ J·s.

For a coherent superposition spread over `N` tubulins the mission's threshold
form is `E = ħ / (t·√N)`, i.e. the predicted coherence/reduction time is

    t(E, N) = ħ / (E · √N).

## 2. Small-case table of `t(E, N)` at the thermal energy scale

Thermal energy at body temperature `T = 310 K`:
`E = k_B·T = 1.380649×10⁻²³ · 310 ≈ 4.28×10⁻²¹ J`.

| N (tubulins) | √N        | E·√N (J)     | t = ħ/(E·√N) (s) |
|--------------|-----------|--------------|------------------|
| 1            | 1         | 4.28e-21     | 2.46e-14         |
| 10⁴          | 100       | 4.28e-19     | 2.46e-16         |
| 10⁸          | 1.0e4     | 4.28e-17     | 2.46e-18         |
| 10¹¹         | 3.16e5    | 1.35e-15     | 7.8e-20          |
| 10¹⁴         | 1.0e7     | 4.28e-14     | 2.46e-21         |

Observations, all reflected in the Lean theorems:

* `t(E, N)` is **strictly decreasing in N** (`cohTime_strictAnti_N`).
* `t(E, N) → 0` as `N → ∞` (`cohTime_tendsto_zero`).
* At the biologically-relevant `N = 10¹¹`, `t ≈ 8×10⁻²⁰ s`, i.e. **below
  `10⁻¹⁸ s`** — the exact rational bound proved in `orchOR_too_short`.

## 3. Comparison with the "conscious moment" timescale

Gamma synchrony / a conscious moment sits at `t_γ ≈ 25 ms … 500 ms`, i.e.
`t_γ ≈ 0.5 s`. The ratio at `N = 10¹¹` is

    t_γ / t ≈ 0.5 / 8×10⁻²⁰ ≈ 6×10¹⁸,

more than eighteen orders of magnitude. A microtubule superposition at body
temperature cannot survive anywhere near long enough to "orchestrate" a conscious
event. This is the quantitative content of the standard (Tegmark) objection and
is captured by `orchOR_shorter_than_gamma` (`t < 0.5 s`).

> Note on the description's "10⁻³³ s": that figure follows from a *different*
> choice of the collapse energy (e.g. a full gravitational self-energy of the
> displaced tubulin mass rather than the thermal scale used above). The exact
> exponent is model-dependent; the robust, model-independent conclusion — proved
> here — is that the coherence time is astronomically shorter than the conscious
> timescale and vanishes as `N` grows.

## 4. Non-computability (the Penrose "understanding is non-algorithmic" side)

* There are only **countably many** algorithms — Mathlib's `Nat.Partrec.Code` is
  a countable type.
* There are **uncountably many** boolean behaviours `ℕ → Bool` (Cantor diagonal).
* Therefore some behaviour is **not computable** by any Turing machine
  (`exists_noncomputable_behavior`).

Small diagonal check: for any finite listing of behaviours `b₀, b₁, …`, the
behaviour `d(n) = ¬ bₙ(n)` differs from every `bₙ` at input `n`, so it is never
listed. This is the finite shadow of `no_surj_nat_behaviors`.

## 5. Counterexample hunt

* Monotonicity `cohTime_strictAnti_N`: tested over the table above — strictly
  decreasing, no counterexample.
* Inverse identities `cohTime_thresholdEnergy` / `thresholdEnergy_cohTime`:
  verified symbolically (each is an exact field identity for positive inputs).
* No counterexample to the diagonal claim exists — it is a theorem.
