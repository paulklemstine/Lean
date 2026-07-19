# Computational evidence

The formal result is symbolic and applies to every finite nonempty real matrix admitting an eigenpair. Small cases nevertheless clarify the scaling law.

## Small-case calculations

For a one-by-one matrix `A = [d]`, min-plus multiplication adds entries. Its positive powers and eigenvalues are:

| Lean index `k` | conventional exponent | `positivePower A k` | eigenvalue |
|---:|---:|---:|---:|
| 0 | 1 | `[d]` | `d` |
| 1 | 2 | `[2d]` | `2d` |
| 2 | 3 | `[3d]` | `3d` |
| 3 | 4 | `[4d]` | `4d` |

For `d ≠ 0`, these powers cannot collide. For `d = 0`, all powers are `[0]`, demonstrating why the nonzero hypothesis is necessary.

A diagonal-dominant two-state example is

`A = [[2, 10], [10, 2]]`, with `v = (0,0)` and `λ = 2`.

The first powers have diagonal costs `2,4,6,8` and corresponding eigenvalues `2,4,6,8`, matching the theorem.

## OEIS search

No OEIS search is relevant: the sequence is the elementary arithmetic progression `(k+1)λ`, parameterized by a real eigenvalue rather than a distinguished integer combinatorial sequence.

## Counterexample hunt

The edge case `λ = 0` supplies immediate collisions, as the one-by-one example `A=[0]` shows. Thus deleting the theorem's `λ ≠ 0` assumption would be false. The formal theorem retains exactly this necessary condition.

No numerical sampling is needed to establish the universal claim: the Lean proof derives it from finite-minimum algebra and induction, without floating-point computation.
