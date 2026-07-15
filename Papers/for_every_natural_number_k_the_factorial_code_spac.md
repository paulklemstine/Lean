# Computational evidence: factorial CRT obstruction

## Small cases

For the proposed residue product `ZMod 2 × ... × ZMod k`:

| `k` | `k!` | nontrivial radices | product size | additive exponent (LCM) | outcome |
|---:|---:|---|---:|---:|---|
| 1 | 1 | none | 1 | 1 | trivial singleton |
| 2 | 2 | 2 | 2 | 2 | identical to `ZMod 2` |
| 3 | 6 | 2, 3 | 6 | 6 | CRT equivalence |
| 4 | 24 | 2, 3, 4 | 24 | 12 | no additive equivalence |
| 5 | 120 | 2, 3, 4, 5 | 120 | 60 | same exponent obstruction |
| 6 | 720 | 2, 3, 4, 5, 6 | 720 | 60 | same exponent obstruction |

At `k = 4`, `12` is zero in every target coordinate but is nonzero modulo
`24`.  This is the first counterexample to the universal CRT-coordinate claim.

## OEIS search

The source moduli are factorials `1, 2, 6, 24, 120, 720, ...` (OEIS A000142).
The target additive exponents are `lcm(1, ..., k) = 1, 2, 6, 12, 60, 60, ...`
(OEIS A003418).  Their first strict discrepancy occurs at `k = 4`.

## Counterexample hunt

The representative stages `k = 1` through `6` were compared by cardinality
and additive exponent.  No counterexample occurs through `k = 3`; `k = 4` is a
counterexample, and the same invariant continues to obstruct the next stages.
The Lean development formally proves the positive `k = 3` equivalence and the
negative `k = 4` result, without relying on this table.
