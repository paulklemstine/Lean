# Computational Evidence: Curie–Weiss Order Parameter

The formalized object is the mean-field self-consistency equation for the
spontaneous magnetization (order parameter) `m` at inverse coupling `β`:

    m = tanh(β · m).

We track the largest non-negative solution `m*(β)` obtained by fixed-point
iteration `m ← tanh(β m)` starting from `m = 0.5`.

## Small-case values of the order parameter

| β    | m*(β)     | phase            |
|------|-----------|------------------|
| 0.5  | 0.000000  | disordered       |
| 0.9  | 0.000000  | disordered       |
| 1.0  | 0 (†)     | critical point   |
| 1.01 | 0.173     | ordered          |
| 1.1  | 0.503     | ordered          |
| 1.5  | 0.859     | ordered          |
| 2.0  | 0.958     | ordered          |
| 3.0  | 0.995     | ordered          |

(†) At `β = 1` the true fixed point is `m* = 0`; naive iteration converges
only algebraically there (critical slowing down), so a short run reports a
small spurious value. The proof `curieWeiss_subcritical` (with `β = 1`)
establishes rigorously that `m* = 0` at criticality.

**Observation.** `m*(β) = 0` for `β ≤ 1` and `m*(β) > 0` for `β > 1`: a sharp
transition located exactly at the critical coupling `β_c = 1`. This is the
content of `curieWeiss_phase_transition`.

## Continuity / second-order character and critical exponent

Near `β_c = 1` the emergent branch is *continuous* (born at `0`), the signature
of a second-order transition, with the classical mean-field exponent `β_exp = 1/2`:

    m*(β) ≈ sqrt(3 (β − 1))   as β → 1⁺.

| β     | m*(β)   | m*(β) / sqrt(3(β−1)) |
|-------|---------|----------------------|
| 1.01  | 0.1731  | 0.999                |
| 1.05  | 0.3707  | 0.957                |

The ratio tends to `1` as `β → 1⁺`, confirming the square-root onset. The two
sharp inequalities proved in Lean, `tanh y < y` and `y − y³/3 < tanh y`, are
exactly the quantitative facts that force `m* = 0` below `β_c` and the
square-root emergence above it.

## Counterexample hunt

We searched for a second, *distinct* positive solution of `m = tanh(β m)` for
`β ∈ {1.1, 1.5, 2, 3, 5}` by scanning `m ∈ (0,1)` on a fine grid and looking for
sign changes of `tanh(β m) − m`. In every case exactly one positive solution was
found — consistent with the uniqueness theorem `curieWeiss_unique_positive`.

## OEIS

No integer sequence arises (the object is a real-analytic order parameter), so
no OEIS entry is relevant.
