# Computational evidence: cycle collapse under observation

The formal theorem is structural, but small finite cycles illustrate every possible outcome.
Let `C_m` be the map `i ↦ i+1 (mod m)`.

| hidden cycle | observation | observed dynamics | hidden period | observed period |
|---|---|---|---:|---:|
| `C₆` | `i ↦ i mod 3` | `C₃` | 6 | 3 |
| `C₆` | `i ↦ i mod 2` | `C₂` | 6 | 2 |
| `C₆` | constant | fixed point | 6 | 1 |
| `C₅` | identity | `C₅` | 5 | 5 |
| `C₅` | constant | fixed point | 5 | 1 |

These cases support the divisor law and the prime-period dichotomy.  Exhaustively,
the divisors available to periods `1` through `8` are:

`1:{1}, 2:{1,2}, 3:{1,3}, 4:{1,2,4}, 5:{1,5}, 6:{1,2,3,6}, 7:{1,7}, 8:{1,2,4,8}`.

No counterexample occurs among quotient observations `C_m → C_d` for `m ≤ 8` and
`d ∣ m`: the observed period is always `d`, hence divides `m`.  This is not an
OEIS investigation; the relevant finite sets are simply divisor sets, and no new
integer sequence is asserted.  The Lean proof establishes the universal result,
so this table is illustrative rather than relied upon for verification.
