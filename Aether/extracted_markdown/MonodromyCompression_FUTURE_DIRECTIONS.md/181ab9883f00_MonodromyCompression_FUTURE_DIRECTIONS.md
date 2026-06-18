# Future Directions — Monodromy Compression Principle for Neural PDE Solvers

This research cycle established the **Monodromy Compression Principle** in
`Catalog/Physics/MonodromyCompression.lean`: the long-horizon amplification of a
linear neural PDE solver is compressed into a single monodromy (period-map)
operator `M = ∏ Tᵢ`, whose gain is controlled multiplicatively (`‖M‖ ≤ ∏‖Tᵢ‖`),
additively (`log‖M‖ ≤ Σ log‖Tᵢ‖`, the Lyapunov form), and spectrally
(`ρ(M) ≤ ‖M‖`, the Floquet-multiplier bound), yielding unconditional stability of
contractive solvers, an exponential horizon bound, and dissipativity (forgetting
of initial data) under uniform contraction. The theory was instantiated on the
operator algebra `E →L[𝕜] E` of a Banach field space, the genuine setting of a
linear neural solver.

The following conjectures are bold, precise, and testable in Lean for follow-up
cycles. Each is stated so that it can be falsified by a single counterexample or
proved by an explicit construction.

## Conjecture 1 — Gelfand-sharp Lyapunov exponent (asymptotic compression is tight)
For a single repeated period operator `a` in a unital Banach algebra, the
per-layer log-gain bound is asymptotically *tight*:
`lim_{n→∞} (1/n) log ‖aⁿ‖ = log ρ(a)`,
i.e. the finite-time Lyapunov exponent `monodromy_ftle` of a periodic solver
converges to the log spectral radius (the true Floquet exponent). This is the
operator Gelfand formula; the conjecture is that it upgrades the one-sided
`monodromy_ftle` inequality to an equality in the periodic limit. **Test:** prove
`Tendsto (fun n => Real.log ‖a^n‖ / n) atTop (𝓝 (Real.log (spectralRadius ℝ a).toReal))`
under suitable nonzero/spectral-radius-positive hypotheses, building on Mathlib's
`spectrum.spectralRadius_le_pow_nnnorm_pow_one_div`.

## Conjecture 2 — Sub-multiplicative defect controls non-normality (compression gap)
Define the *compression defect* `δ(T) = (∏‖Tᵢ‖) − ‖M‖ ≥ 0`. Conjecture: for
self-adjoint / normal commuting layers the defect vanishes (`δ = 0`, the bound is
an equality), and conversely a strictly positive defect certifies
non-commutativity / non-normality of the schedule. **Test:** prove
`δ(T) = 0` when all `Tᵢ` are scalar multiples of a fixed normal operator, and
exhibit a 2×2 nilpotent pair with `δ > 0`.

## Conjecture 3 — Averaged-contraction stability (beyond layerwise contraction)
`monodromy_stable` requires *every* layer to be a contraction. Conjecture the
weaker hypothesis suffices in the periodic limit: if the *average* log-gain is
negative, `(1/k) Σ log‖Tᵢ‖ < 0`, then the repeated-schedule monodromy decays,
`‖M^n‖ → 0`, even when some individual `‖Tᵢ‖ > 1`. **Test:** combine
`monodromy_lyapunov` with `monodromy_dissipative` to prove decay of
`‖monodromy (replicate n (join P))‖` whenever `(P.map (log ∘ norm)).sum < 0`.

## Conjecture 4 — Cocycle bridge to the smooth Lyapunov theory
The monodromy product is the operator-valued shadow of the derivative cocycle in
`Catalog/Physics/LyapunovChaos.lean` (`deriv_iterate_eq_prod`). Conjecture an
exact bridge: for a smooth map `f` the 1×1 monodromy of the linearized layers
`Tᵢ = f'(xᵢ)` reproduces the finite-time Lyapunov exponent `ftle f x n`, i.e.
`monodromy_ftle` specializes to `ftle_ge_log`. **Test:** prove
`Real.log ‖monodromy (map (fun i => f' (f^[i] x)) (range n))‖ = Real.log |deriv f^[n] x|`
and derive the chaos lower bound as a corollary of the compression principle.

## Conjecture 5 — Trotter / spectral-gap accelerated compression
For dissipative parabolic solvers the decay rate should be governed by a spectral
*gap*, not merely the norm: if `ρ(M) = r < 1` then `‖M^n‖ ≤ C·rⁿ·poly(n)` with the
polynomial degree bounded by the largest Jordan block of `M`. Conjecture this
Floquet decay estimate holds with explicit constants, strengthening
`monodromy_dissipative` (which uses `‖M‖ < 1`) to the strictly weaker
`ρ(M) < 1`. **Test:** prove `Tendsto (fun n => ‖a^n‖) atTop (𝓝 0)` from
`spectralRadius ℝ a < 1` for `a` in a finite-dimensional algebra, then quantify.
