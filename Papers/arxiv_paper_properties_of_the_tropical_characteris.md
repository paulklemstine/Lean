# Computational Evidence

## Small-case calculations

Two integer profiles were selected to test the exact local inequality used by the coefficient theorem.

| coefficient profile | tested interior index | left side `2 c(k)` | right side `c(k-1)+c(k+1)` | result |
|---|---:|---:|---:|---|
| `c(k) = -k²` | arbitrary `k ≥ 1` | `-2k²` | `-2k²-2` | strict concavity by margin `2` |
| `c = (0,0,10,0,...)` | `k=1` | `0` | `10` | counterexample |

The first calculation is encoded as a parameterized example, not merely sampled at finitely many indices. The second is encoded as a proof that the spike profile is not discretely concave through degree four.

## OEIS search results

No OEIS identification is relevant: the investigated objects are coefficient vectors parametrized by matrix entries rather than a canonical one-variable integer sequence.

## Counterexample hunt

The universal claim that every integer coefficient vector could arise from a principal exchange system fails. The profile with values `c(0)=0`, `c(1)=0`, `c(2)=10`, and `c(3)=0` violates the midpoint inequality at index one. The obstruction theorem proves that any such single violation excludes a principal-exchange realization.

A second boundary was identified conceptually: without matrix symmetry, reversal of a directed cycle cover need not preserve weight, so the two-set exchange input may fail. This is recorded as a boundary rather than asserted as a computed classification.

## Table of affine perturbations

For any integers `a,b`, replacing `c(k)` by `c(k)+ak+b` leaves the midpoint defect unchanged:

| expression | midpoint defect |
|---|---|
| `c(k)` | `2c(k)-c(k-1)-c(k+1)` |
| `c(k)+ak+b` | `2c(k)-c(k-1)-c(k+1)` |

This identity is established generally by the affine-invariance theorem.
