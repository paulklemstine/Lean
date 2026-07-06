# Computational Evidence — Sunflower‑free families and the base `3 / 2^(2/3)`

All claims below are reflected by fully verified theorems in
`Catalog/Applications/NaslundSawinSunflowerFree.lean`.

## 1. The exponential base `r = 3 / 2^(2/3)`

Numerically `r ≈ 1.889881575`.

| quantity | value | verified statement |
|---|---|---|
| `r^3` | `27/4 = 6.75` | `nsBase_cube` |
| `r` vs `1` | `1 < r` | `one_lt_nsBase` |
| `r` vs `2` | `r < 2`  (⇔ `27 < 32`) | `nsBase_lt_two` |
| `log₂ r` | `log₂ 3 − 2/3 ≈ 0.9183` | `logb_two_nsBase` |

The cubing check reduces the transcendental comparison `r < 2` to the integer fact `27 < 32`,
because `r < 2 ⇔ 3 < 2^{5/3} ⇔ 27 < 32`. Likewise `r^3 = 27/(2^{2/3})^3 = 27/2^2 = 27/4`.

## 2. Entropy link

The binary entropy `H(p) = −p·log₂p − (1−p)·log₂(1−p)` satisfies
`H(1/3) = (1/3)log₂3 + (2/3)log₂(3/2) = log₂3 − 2/3 ≈ 0.9183`.
This equals `log₂ r` exactly, so `r = 2^{H(1/3)}`. This is why the partial binomial sum
`∑_{k ≤ n/3} C(n,k) ≈ c · r^n / √n` and hence why `r` is the natural exponential base of the
Naslund–Sawin bound.

## 3. Structural sanity checks on 3‑sunflowers

Definition: `A, B, C` (distinct) form a sunflower when `A∩B = A∩C = B∩C`.

* **Chains.** For `∅ ⊂ {0} ⊂ {0,1}`: pairwise intersections are `∅, ∅, {0}` — not all equal.
  For any chain `A ⊆ B ⊆ C`, `A∩C = A` and `B∩C = B`, so equality would force `A = B`.
  → chains are sunflower‑free (`chain_sunflowerFree`).
* **Disjoint triples.** For `{0}, {1}, {2}`: all pairwise intersections are `∅`, so these three
  singletons DO form a sunflower (empty core). Hence "all singletons" is *not* sunflower‑free
  once `n ≥ 3` (`disjoint_triple_isSunflower`, `no_disjoint_triple_of_sunflowerFree`).

## 4. Extremal function, small cases (lower bound)

The maximal chain `chainFamily n = {∅, {0}, …, {0,…,n−1}}` has exactly `n+1` members and is
sunflower‑free:

| n | `|chainFamily n|` | `2^n` (trivial upper bd) | `r^n` |
|---|---|---|---|
| 1 | 2 | 2 | 1.89 |
| 2 | 3 | 4 | 3.57 |
| 3 | 4 | 8 | 6.75 |
| 4 | 5 | 16 | 12.75 |
| 6 | 7 | 64 | 45.6 |

So `n+1 ≤ M(n) ≤ K·n^{1/6}·r^n` where `M(n)` is the extremal size (`exists_large_sunflowerFree`).
The gap between the polynomial lower bound `n+1` and the (conjecturally sharp) exponential upper
bound is where the research frontier lies.

## 5. Counterexample hunt

No counterexamples were found to the verified statements. The natural naive constructions that
*look* large — all singletons, all pairwise‑disjoint families — are ruled out precisely by the
sunflower condition (Section 3), consistent with the exponential ceiling `r^n < 2^n`
(`nsBase_pow_lt_two_pow`).
