# Computational Evidence

All numbers below were produced by `#eval` inside the Lean project, in
`Catalog/Shared/CriticalGeometryEvidence.lean` (built with `lake build
Shared.CriticalGeometryEvidence`).  They are exploratory checks: the formal
content is in the theorems of `Catalog/Shared/RecodingCriticalGeometry.lean`,
`Catalog/Shared/ProofSpaceDimensionSpectrum.lean` and
`Catalog/Shared/ProofRegimeMixturePowerLaw.lean`, each proved without `sorry`.

## 1. Ambient counts and the radial-shift identity

`ProofSpace.S k n = ∑_{i ≤ n} k^i` for `n = 0..4`:

| n | S 2 n | S 3 n |
|---|-------|-------|
| 0 | 1     | 1     |
| 1 | 3     | 4     |
| 2 | 7     | 13    |
| 3 | 15    | 40    |
| 4 | 31    | 121   |

(`S 2 n = 2^{n+1} - 1`, OEIS A000225; `S 3 n = (3^{n+1}-1)/2`, OEIS A003462.)

* Identity `S k (n+b) = (∑_{i<b} k^i) + k^b · S k n` checked for `k = 2`,
  `n, b ≤ 3`: **all true**.  (Proved as `RecodingGeometry.S_add`.)
* Bound `S k (n+b) ≤ 2 k^b · S k n` checked for `k = 3`, `n ≤ 5`, `b ≤ 3`:
  **all true**.  (Proved as `RecodingGeometry.S_add_le`.)

This is the source of the *multiplicative* factor `2 k^b` in the density
comparison across a recoding of overhead `b`.

## 2. Transition windows for a family of exact exponential order

Take the binary language (`k = 2`) and the derivable family
`N n = ⌈(3/2)^n⌉`, so `c = 1`, `C = 2`, `a = 3/2`.  Densities
`d n = N n / S 2 n`:

| n | N n | d n |
|---|-----|-----------|
| 0 | 1   | 1.000000 |
| 1 | 2   | 0.666667 |
| 2 | 3   | 0.428571 |
| 3 | 4   | 0.266667 |
| 4 | 6   | 0.193548 |
| 5 | 8   | 0.126984 |
| 6 | 12  | 0.094488 |

Last cutoff at level `ε` versus first cutoff below `ε` (search over `n < 60`):

| ε | last n with d n ≥ ε | first n with d n < ε |
|---|---|---|
| 1/2 | 1 | 2 |
| 1/4 | 3 | 4 |
| 1/10 | 5 | 6 |
| 1/100 | 13 | 14 |
| 1/1000 | 21 | 22 |
| 1/10^6 | 45 | 46 |

The window width stays `1` as `ε` ranges over six orders of magnitude, and it
never exceeds the proved bound `log(2C/c)/log(k/a) = log 4 / log(4/3) ≈ 4.82`
(`RecodingGeometry.transition_window_width`).  The point of the theorem is that
the bound does **not** depend on `ε`.

## 3. Counterexample hunt: same-level critical indices under recoding

Profiles `p n = 1/(n+1)` and `q n = 1/(2n+2)` satisfy the distortion
inequalities of a `b = 1` binary recoding (`p n ≤ 4 q(n+1)` and
`q n ≤ 4 p(n+1)`): checked for `n < 50`, **all true**.

Critical indices at level `ε = 1/(2D+2)`:

| D | c_p | c_q | gap |
|---|-----|-----|-----|
| 0 | 1   | 0   | 1 |
| 1 | 3   | 1   | 2 |
| 2 | 5   | 2   | 3 |
| 5 | 11  | 5   | 6 |
| 10| 21  | 10  | 11 |
| 50| 101 | 50  | 51 |

The gap `c_p - c_q = D + 1` grows without bound although the recoding overhead
is `b = 1`.  This is the counterexample that refutes the naive same-level
quasi-invariance conjecture; it is formalized as
`RecodingGeometry.criticalIndex_gap_unbounded` (`c_p = 2D+1`, `c_q = D`,
matching the table exactly).

## 4. Mixture of geometric proof regimes

`mixedTail x = ∫_0^1 e^{-xs} ds = (1 - e^{-x})/x`:

| x | mixedTail x | x · mixedTail x |
|---|-------------|------------------|
| 1 | 0.632121 | 0.632121 |
| 2 | 0.432332 | 0.864665 |
| 3 | 0.316738 | 0.950213 |
| 5 | 0.198652 | 0.993262 |
| 10 | 0.099995 | 0.999955 |
| 20 | 0.050000 | 1.000000 |
| 50 | 0.020000 | 1.000000 |

So `x · mixedTail x → 1`: regular variation of index `-1`
(`ProofRegimeMixture.mixedTail_regularly_varying`).

Successive ratios `mixedTail(n+1)/mixedTail(n)`:

| n | 1 | 2 | 5 | 10 | 50 | 200 |
|---|---|---|---|----|----|-----|
| ratio | 0.6839 | 0.7326 | 0.8369 | 0.9091 | 0.9804 | 0.9950 |

They increase towards `1`, in contrast with the constant ratio `e^{-s}` of a
single regime (`ProofRegimeMixture.regimeTail_ratio`).  This is the
falsifiable prediction of the mixture model, and it is what
`ProofRegimeMixture.mixedTail_ratio_tendsto_one` and
`ProofRegimeMixture.mixedTail_not_geometric` prove.

## 5. What the evidence did *not* support

The first hypothesis of the cycle — "level-`ε` critical indices of two
encodings differ by at most the recoding overhead `b`" — failed already at
`D = 2` in the table of §3.  The evidence redirected the formalization towards
the two observables that *are* stable: count radii (exactly `b`-stable) and
the exponential growth rate (exactly invariant).
