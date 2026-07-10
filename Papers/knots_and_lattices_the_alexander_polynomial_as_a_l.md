# Computational Evidence: Alexander polynomials vs. lattice-path generating functions

## 1. The claim under test

The mission conjecture states that the Alexander polynomial of a knot is a
*generating function of lattice paths*:
`Δ_K(t) = Σ_p t^{area(p)}`, one non-negative term per path.

A generating function of this form has **non-negative integer coefficients**.
So a single decisive test is: *do reduced Alexander polynomials have negative
coefficients?*

## 2. Small-case calculations

Reduced (symmetric, Conway-normalized) Alexander polynomials of the smallest
knots, written in the symmetric variable so that `Δ_K(t) = Δ_K(t^{-1})`:

| Knot | Crossings | Δ_K(t) | Has a negative coefficient? |
|------|-----------|--------|------------------------------|
| unknot | 0 | `1` | no |
| trefoil `3_1` | 3 | `t − 1 + t^{-1}` | **yes** (constant term −1) |
| figure-eight `4_1` | 4 | `−t + 3 − t^{-1}` | **yes** |
| `5_1` | 5 | `t^2 − t + 1 − t^{-1} + t^{-2}` | **yes** |
| `5_2` | 5 | `2t − 3 + 2t^{-1}` | **yes** |
| `6_1` | 6 | `2t − 5 + 2t^{-1}` | **yes** |
| `6_2` | 6 | `−t^2 + 3t − 3 + 3t^{-1} − t^{-2}` | **yes** |

Every non-trivial knot in this list has at least one strictly negative
coefficient. This is not accidental: `Δ_K(1) = ±1` for every knot, while the sum
of the (non-negative) coefficients of a genuine generating function equals the
number of paths, which is `≥ 1` and typically large; forcing the alternating
cancellation down to `±1` requires negative coefficients.

**Conclusion of the counterexample hunt:** the literal conjecture is *false*.
The trefoil already refutes it. This is captured formally by
`trefoil_not_areaGF`, which shows the trefoil polynomial is not an unsigned
lattice-path generating function for **any** state set and **any** area
statistic.

## 3. What survives — the signed state sum

The genuine state-sum formula carries a sign `(-1)^{w(s)}`:
`Δ_K(t) = Σ_s (-1)^{w(s)} t^{a(s)}`.
With signs, the trefoil polynomial is reproduced exactly by three states of
areas `1, 0, -1` and signs `+, -, +`:

```
(+1)·t^1 + (-1)·t^0 + (+1)·t^{-1} = t - 1 + t^{-1}.
```

This is `trefoil_is_signedGF`. The sign is precisely what the naive conjecture
drops.

## 4. The symmetry, explained combinatorially

Every reduced Alexander polynomial above is palindromic: `Δ_K(t) = Δ_K(t^{-1})`.
Computationally, the coefficient sequence reads the same forwards and backwards.
The structural cause is an **area-negating, sign-preserving involution** of the
state set: pairing each state `s` of area `k` with a partner of area `-k` and
equal sign makes the signed sum symmetric. This mechanism is proved in general
as `signedGF_palindromic`, and the trefoil's involution (`swap` the area `±1`
states, fix the area `0` state) is an instance.

## 5. Lattice-path combinatorics (the substrate)

Monotone paths from `(0,0)` to `(n,n)` are the `n`-subsets of the `2n` step
slots; hence there are `C(2n,n)` of them (`card_latticePaths`). The family is
`n`-uniform, so Kruskal–Katona applies: any dense sub-family of paths forces a
dense shadow of `(n-1)`-step sub-paths (`latticePaths_shadow_lower_bound`).

| n | C(2n, n) |
|---|----------|
| 0 | 1 |
| 1 | 2 |
| 2 | 6 |
| 3 | 20 |
| 4 | 70 |
| 5 | 252 |

(Central binomial coefficients, OEIS A000984.)

## 6. Summary

- The **positive** lattice-path enumeration conjecture is refuted (negative
  coefficients are ubiquitous, already at the trefoil).
- The **signed** state sum survives and reproduces the polynomial.
- The signature symmetry of Alexander polynomials is explained by a combinatorial
  involution, not by positivity.
