# Computational Evidence: Local-to-Global Influence on Partite Complexes

All figures below were computed directly from the definitions used in the formal
development (`Inf`, `InfSub`), so they exercise exactly the objects the theorems
constrain.

## 1. The bridge identity `Inf f i = ∑ b, InfSub f j b i`

**Example A — diagonal labelling, `n = 2`, `m = 3`.**
Facets are pairs `(x 0, x 1) ∈ Fin 3 × Fin 3`; label `f = 1` iff `x 0 = x 1`.

| quantity | value |
|---|---|
| global influences `(Inf f 0, Inf f 1)` | `(12, 12)` |
| link influences of colour `1` over the 3 links of colour `0` | `[4, 4, 4]` |
| `Inf f 1 == sum of link influences` | `true` |

The three links each contribute `4`, and `4 + 4 + 4 = 12 = Inf f 1`: the
self-averaging bridge holds exactly.

**Example B — parity labelling, `n = 3`, `m = 2` (classical Boolean cube).**
Label `f = 1` iff the sum of coordinates is odd.

| quantity | value |
|---|---|
| global influences `(Inf f 0, Inf f 1, Inf f 2)` | `(8, 8, 8)` |
| `Inf f 0 == sum over the 2 links of colour 2` | `true` |

Parity is fully influential in every direction, and the two-link decomposition
reproduces each global influence exactly — the `m = 2` shadow of the general result.

## 2. Local-to-global transfer, quantitatively

In Example A each of the `m = 3` links of colour `0` carries link-influence
`T = 4`. The flagship bound predicts some colour `i ≠ 0` with
`m·T ≤ (n-1)·Inf f i`, i.e. `12 ≤ 1·Inf f i`. Indeed `Inf f 1 = 12`, meeting the
bound with equality — a regular, extremal instance.

## 3. Degenerate boundary

**Example C — constant labelling, `n = 3`, `m = 4`.** For `f ≡ 1`,
`[Inf f 0, Inf f 1, Inf f 2] = [0, 0, 0]`: all influences vanish, matching
`zero_influence_constant` (constant ⟹ all influences zero, and conversely).

## 4. Counterexample hunt

We searched small alphabets and dimensions for any violation of the bridge identity
`Inf f i = ∑ b, InfSub f j b i` and found none — as expected, since the identity is
an exact set-fibering and is proved unconditionally. No counterexample exists.

## Notes

The alphabet size `m` visibly scales the total link contribution (`3 · 4 = 12`
versus the cube's `2`-fold split), which is the quantitative signature that the
`m`-ary complex propagates strictly more influence to the global level than the
Boolean cube — the phenomenon formalized by `total_via_links` and
`localToGlobal_KKL_partite`.
