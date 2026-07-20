# Computational Evidence

## Small-case calculations

For prime conductor `p`, cyclotomic reciprocity gives exactly `p - 1` one-dimensional complex Galois representations. Thus the proposed ten-thousand-edge condition becomes `10000 < p - 1`.

| prime conductor `p` | connection count `p - 1` | modeled phase |
|---:|---:|:---|
| 2 | 1 | inactive |
| 3 | 2 | inactive |
| 5 | 4 | inactive |
| 101 | 100 | inactive |
| 9973 | 9972 | inactive |
| 10009 | 10008 | active |
| 10037 | 10036 | active |

The boundary calculation is exact: activation is equivalent to `10001 < p`. Since `10001 = 73 × 137` is composite, no prime conductor occurs exactly at the first integer above the edge threshold; `10009` is the first active prime conductor.

## Sequence identification

Along prime conductors, the connection counts begin

`1, 2, 4, 6, 10, 12, 16, 18, 22, 28, ...`,

namely one less than each prime. No OEIS identifier is needed for the argument: the sequence is explicitly characterized by the prime sequence itself.

## Counterexample hunt

The universal prime-conductor claim was reduced algebraically to

`10000 < p - 1 ↔ 10001 < p`.

Potential corner cases include `p = 2`, the truncated natural subtraction in `p - 1`, and values near `10001`. Primality forces `p ≥ 2`, so subtraction is nondegenerate. The nearby values agree with the classification: `9973` is inactive, `10001` is not prime, and `10009` is active. The formal theorem covers all prime conductors, so these calculations are illustrations rather than the basis of the result.

## Shape of the order parameter

For coupling `κ > 0`, the modeled coherence is zero through `10000` connections and equals

`√κ · √(edges - 10000)`

above threshold. Consequently its square grows linearly in excess connections, while coherence itself has square-root onset. For prime conductor `p`, substitute `edges = p - 1`, obtaining excess `p - 10001`.
