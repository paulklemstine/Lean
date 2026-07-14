# Computational Evidence — Exact Coset Guesswork Exponent (symmetric source)

We study the ρ-th guesswork moment for the maximal-entropy Bernoulli(1/2) source,
realised as the exact average over equiprobable candidates:

    M(N) = (1/N) · Σ_{k=1}^{N} k^ρ .

* **Unconstrained** guessing uses `N = 2^m`.
* **Constrained** coset guessing over a rate-`R` code uses `N = 2^{k_m}` with `k_m ≈ R·m`.

The claim is that the exponential growth rate

    r(m) = (1/m) · log₂ M(N)

converges to `ρ` (unconstrained) and to `ρ·R` (constrained), i.e. the exponent drops
by exactly `ρ(1-R)`.

## Small-case calculations (ρ = 2)

Computed exactly over ℚ, then `log₂`, in Lean (`#eval`).

### Unconstrained, `N = 2^m`, target rate `ρ = 2`

| m  | r(m) = (1/m) log₂ M(2^m) |
|----|--------------------------|
| 1  | 1.3219 |
| 3  | 1.5575 |
| 5  | 1.6964 |
| 7  | 1.7760 |
| 9  | 1.8244 |
| 11 | 1.8560 |
| 12 | 1.8680 |

Monotonically increasing toward `2`, consistent with the proven limit `ρ = 2`.
(Convergence is `O((ρ+1)/m)`, matching the analytic sandwich
`ρ − (ρ+1)/m ≤ r(m) ≤ ρ`.)

### Constrained, coset dimension `k_m = ⌊m/2⌋` (rate `R = 1/2`), `ρ = 2`

| m (even) | r(m) = (1/m) log₂ M(2^{m/2}) |
|----------|------------------------------|
| 2  | 0.6610 |
| 6  | 0.7787 |
| 10 | 0.8482 |
| 14 | 0.8880 |
| 18 | 0.9122 |
| 22 | 0.9280 |
| 24 | 0.9340 |

Increasing toward `1 = ρ·R = 2·(1/2)`, i.e. the exponent is shifted down from `2`
to `1`, a drop of exactly `ρ(1-R) = 2·(1/2) = 1`.

## Counterexample hunt

The universal quantity being checked is the two-sided bound underlying the limit:

    (N/2)^{ρ+1} ≤ Σ_{k=1}^{N} k^ρ ≤ N^{ρ+1}     (ρ ≥ 0).

Tested for `ρ ∈ {0, 1, 2, 3}` and `N = 2^m`, `m = 1..12`: no violation found. Both
inequalities are elementary (top-half sub-sum for the lower bound; term-wise maximum for
the upper bound) and are the ones formalised as `powSum_lower` / `powSum_upper`.

## Conclusion

The numerics agree with the theorem to the expected `O(1/m)` accuracy. The formal proof
in `ExactUniformExponent.lean` upgrades this evidence to an exact limit statement,
`cosetMoment_rate : … → 𝓝 (ρ·R)`, and identifies `ρ = amExponent ρ (1/2)`, giving the
exact shift `ρ(1-R)` (`cosetMoment_rate_am`, `exact_exponent_shift`).
