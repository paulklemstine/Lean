# Computational Evidence: RH for the Ihara zeta function ⇔ Ramanujan

We study the local factor `p_λ(u) = q u² − λ u + 1` attached to each adjacency
eigenvalue `λ` of a `(q+1)`-regular graph. The Riemann Hypothesis for the Ihara
zeta function asks that every non-trivial root lie on the circle `|u| = 1/√q`.

## Small-case root computations

For a real eigenvalue `λ` and `q > 0`, the two roots of `q u² − λ u + 1` are
`u± = (λ ± √(λ² − 4q)) / (2q)`, with product `u₊·u₋ = 1/q`.

| graph            | q | non-trivial λ | λ² vs 4q      | roots on |u|=1/√q? |
|------------------|---|---------------|---------------|--------------------|
| cycle Cₙ         | 1 | 2 (Perron)    | 4 = 4         | yes (double root 1)|
| Petersen         | 2 | 1, −2         | 1<8, 4<8      | yes                |
| complete K₅      | 3 | −1            | 1 < 12        | yes                |
| Paley(13)        | 3 | (−1±√13)/2    | ≈ 5.3 < 12    | yes                |
| complete Kₙ      | n−2 | −1          | 1 < 4(n−2)    | yes (n ≥ 3)        |

In every Ramanujan case `λ² ≤ 4q`, the discriminant is `≤ 0`, the two roots are
complex conjugates, and

    |u|² = (λ² + (4q − λ²)) / (4q²) = 4q / (4q²) = 1/q,

so both roots land exactly on the circle of radius `1/√q`. This is the numerical
signature of the Riemann Hypothesis.

## Counterexample hunt (the non-Ramanujan boundary)

When `λ² > 4q` the roots become **real and distinct** with product `1/q > 0`
(hence equal sign). Their moduli multiply to `1/q` but cannot both equal `1/√q`
without coinciding — so at least one leaves the circle. Example: `q = 1`,
`λ = 3` gives roots `(3 ± √5)/2 ≈ 2.618, 0.382`, moduli `≈ 2.618 ≠ 1` and
`0.382 ≠ 1`. This is exactly a non-Ramanujan eigenvalue breaking RH.

## The trivial eigenvalue

For the Perron eigenvalue `λ = q + 1` the factor splits as `(qu − 1)(u − 1)`
with roots `u = 1` and `u = 1/q`. For `q > 1` neither lies on `|u| = 1/√q`. This
is why RH is imposed only on the *non-trivial* spectrum; the trivial pole is
always off the circle and is excluded by convention.

## Conclusion

The finite sample of Ramanujan graphs above shows perfect agreement with the
criterion `λ² ≤ 4q`. The formal development promotes this evidence to a proof of
the exact equivalence at the level of a single spectral local factor.
