# Computational Evidence

## Object under study

For natural numbers `m, n`, a `ℤ₂`-map `Sᵐ → Sⁿ` in the cross-polytope model is a simplicial,
antipodally-equivariant vertex map between boundary complexes of cross-polytopes. By equivariance
it is determined by positive-vertex data `g : Fin (m+1) → Fin (n+1) × Bool`, and simpliciality is
equivalent to injectivity of the coordinate part `σ : Fin (m+1) → Fin (n+1)`.

The claim to be verified: **`Nonempty (Z2Map m n) ↔ m ≤ n`**, hence `coind(Sⁿ) = n`, and every
level of the suspension tower is Borsuk–Ulam sharp: `IsEmpty (Z2Map (n+1) n)`.

## Small-case enumeration (existence of a ℤ₂-map)

Existence reduces to: does there exist an injection `Fin (m+1) → Fin (n+1)`? That is a pure
pigeonhole count, `(m+1) ≤ (n+1) ⇔ m ≤ n`.

| m \ n | 0 | 1 | 2 | 3 |
|-------|---|---|---|---|
| 0     | ✓ | ✓ | ✓ | ✓ |
| 1     | ✗ | ✓ | ✓ | ✓ |
| 2     | ✗ | ✗ | ✓ | ✓ |
| 3     | ✗ | ✗ | ✗ | ✓ |

The diagonal (`m = n`, identity) and lower triangle (`m < n`, equatorial inclusions) are ✓; the
strict upper triangle (`m > n`) is ✗. The two base ✗ entries `(1,0)` and `(2,1)` were previously
confirmed independently by exhaustive `decide` over the finite positive-vertex data, matching the
general criterion proved here.

## Base-case cross-check (finite `decide`)

The prior development verified, by brute-force finite search over all `g : Fin (m+1) → SVert n`:

* `IsEmpty (Z2Map 1 0)` — no `ℤ₂`-map `S¹ → S⁰`.
* `IsEmpty (Z2Map 2 1)` — no `ℤ₂`-map `S² → S¹`.

Both agree with `borsuk_ulam_general` at `n = 0, 1`.

## Counterexample hunt

The universal statement `IsEmpty (Z2Map (n+1) n)` was tested against the injection criterion for
`n = 0,…,10`: an injection `Fin (n+2) → Fin (n+1)` would violate pigeonhole, so none exists — no
counterexample. The criterion `Nonempty (Z2Map m n) ↔ m ≤ n` was likewise checked to be consistent
with the small table above; no counterexample found.

## Conclusion

The computational picture (a pigeonhole table plus two exhaustive `decide` checks) exactly matches
the theorem proved formally: existence of a `ℤ₂`-map is governed solely by `m ≤ n`.
