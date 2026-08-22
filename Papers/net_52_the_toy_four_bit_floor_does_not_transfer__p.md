# Computational Evidence — NET-52 formal shadow (round-to-nearest meshes)

The empirical round (per-channel RTN quantization of Qwen2.5-0.5B) is reported in the
mission brief.  What follows is the *arithmetic* evidence for the statements that are
formalized in `Catalog/NumberTheory/QuantMeshSharpness.lean` and
`Catalog/NumberTheory/QuantSawtoothBias.lean`.  It is deliberately short.

## 1. The worst case of round-to-nearest is attained, not approached

`rtn Δ x = Δ * round (x/Δ)`.  For `Δ = 1`:

| x | round x | error `rtn x - x` |
|---|---|---|
| 0.10 | 0 | −0.10 |
| 0.49 | 0 | −0.49 |
| 0.50 | 1 | **+0.50** |
| 0.51 | 1 | +0.49 |
| 0.99 | 1 | +0.01 |

So `|rtn Δ x − x| ≤ Δ/2` with equality at `x = Δ/2` (Mathlib's `round` rounds ties up).
Consequently a bound of the form `defect ≤ K · n · Δ/2` is *sharp*: the linear functional
`f(u) = Σ u i` on the vector `w i = Δ/2` realizes it exactly.  This is the formal content of
barrier (P4) "monotone in mesh, constant sharp".

## 2. Why a bits-only floor cannot transfer

The mesh of a `b`-bit absmax quantizer is proportional to the **amplitude** `A` of the tensor:
`Δ = A / 2^b`.  Hence the worst-case defect is `K n A / 2^(b+1)`: for fixed `b` it is unbounded
in `A` and in the width `n`.  Numerically, with `b = 4`, `K = n = 1`:

| A | worst-case defect |
|---|---|
| 0.05 | 0.0016 |
| 1.0 | 0.031 |
| 16.0 | 0.5 |

A "4-bit floor" calibrated on a toy of small amplitude/width therefore carries no information
about a pretrained tensor: the toy budget can be exceeded by any prescribed factor.  Formalized
as `toy_floor_does_not_transfer`.

## 3. Grouping strictly helps, and by exactly the amplitude ratio

With per-group steps `Δ i` the aggregate bound is `Σ Δ i / 2` instead of `n · (max Δ) / 2`; the
inequality is strict as soon as one group has smaller amplitude.  For a two-group toy with
amplitudes `(1, 1/4)` and `n = 2` each: global bound `4 · 1/2^{b+1}`, grouped bound
`(2 + 2·(1/4)) / 2^{b+1} = 2.5 / 2^{b+1}` — a 37.5 % repair, the same qualitative shape as the
measured 60 % repair of the 4-bit damage by group-128.

## 4. Rounding bias over a rational mesh: an exact parity law

Sum of the signed rounding errors of the arithmetic progression `j/q`, `j = 0,…,q−1`:

| q | Σ_j (round(j/q) − j/q) |
|---|---|
| 2 | 1/2 |
| 3 | 0 |
| 4 | 1/2 |
| 5 | 0 |
| 6 | 1/2 |
| 7 | 0 |

The pattern is exact: the sum equals `⌊q/2⌋ − (q−1)/2`, i.e. **0 for odd `q` and 1/2 for even
`q`** — the tie at `j = q/2` (which exists only for even `q`) is the entire bias.  Since
`k ↦ k·p mod q` is a bijection of `ZMod q` for `gcd(p,q)=1`, the same holds for any arithmetic
progression `k·p/q`.  This is the number-theoretic core proved in
`Catalog/NumberTheory/QuantSawtoothBias.lean`: RTN is unbiased on odd-denominator meshes and
carries a half-step bias on even (dyadic, i.e. *actual hardware*) meshes.
