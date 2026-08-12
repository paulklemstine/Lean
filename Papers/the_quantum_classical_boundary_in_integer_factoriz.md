# Computational Evidence — QBOUND (quantum–classical boundary in period finding)

All numbers below were produced by exhaustive/direct computation *before* the Lean
formalisation, and every number that a theorem depends on is re-derived
symbolically inside Lean (no `native_decide`, no floating point in any proof).

## 1. Barrier 2: is the fundamental bin the dominant non-DC peak?

For a base `a` of multiplicative order exactly `4` modulo `N`, the value signal
`v = (1, a, a², a³ mod N)` has an exactly computable 4-point spectrum
(`ζ₄ = i`):

```
|V̂(1)|² = (v₀ - v₂)² + (v₁ - v₃)²      (fundamental — encodes r = 4)
|V̂(2)|² = (v₀ - v₁ + v₂ - v₃)²          (second harmonic — encodes r = 2)
|V̂(3)|² = |V̂(1)|²
```

Exhaustive scan over all `(N, a)` with `5 ≤ N < 500`, `gcd(a,N) = 1`,
`ord_N(a) = 4`:

| quantity | value |
|---|---|
| instances with `ord_N(a) = 4` | 1870 |
| instances where `|V̂(2)| > |V̂(1)|` (fundamental dominated) | 684 |
| fraction | 0.366 |

Smallest witnesses:

| N | a | signal `(v₀,v₁,v₂,v₃)` | `|V̂(1)|²` | `|V̂(2)|²` |
|---|---|---|---|---|
| 15 | 7  | (1, 7, 4, 13)   | 45  | 225  |
| 15 | 13 | (1, 13, 4, 7)   | 45  | 225  |
| 20 | 13 | (1, 13, 9, 17)  | 80  | 400  |
| 20 | 17 | (1, 17, 9, 13)  | 80  | 400  |
| 30 | 17 | (1, 17, 19, 23) | 360 | 400  |
| 39 | 31 | (1, 31, 25, 34) | 585 | 1521 |

The smallest witness is exactly the textbook Shor instance `N = 15, a = 7`.
This is the instance formalised in `SpectralHiding.lean`
(`modExpSignal_bins`, `fundamental_dominated_by_harmonic`): the Lean proof
computes the four bins `25, -3-6i, -15, -3+6i` symbolically from `ζ₄ = i`, hence
`‖V̂(1)‖ = √45 < 15 = ‖V̂(2)‖`.

Because `7² ≡ 4 ≢ 1 (mod 15)`, reading the period off the dominant non-DC peak
returns `4/2 = 2`, which is **not** the order — the classical peak-picking
heuristic fails outright, not merely imprecisely
(`peak_picking_returns_wrong_period`).

## 2. Rank of the fundamental for larger semiprimes

Full-period sampling (`n = r`, so the frequency resolution barrier is already
saturated), rank of the fundamental bin `k = 1` among the `n - 1` non-DC bins,
ordered by decreasing modulus:

| N | a | r = ord_N(a) | rank of fundamental | out of | top-4 bins |
|---|---|---|---|---|---|
| 143  | 2  | 60  | 5   | 59  | 4, 56, 58, 2 |
| 2047 | 5  | 44  | 15  | 43  | 3, 41, 6, 38 |
| 391  | 3  | 176 | 50  | 175 | 173, 3, 17, 159 |
| 3599 | 11 | 116 | 86  | 115 | 106, 10, 58, 6 |
| 1961 | 7  | 234 | 169 | 233 | 54, 180, 15, 219 |

The fundamental is essentially never the top bin, and its rank degrades as `r`
grows: the period is spread over the harmonics. (These floating-point spectra
are *evidence only*; no theorem depends on them. The theorem in the repository
is the exactly computed `N = 15` instance.)

## 3. Barrier 1: how large is the order?

Elementary count (formalised as `card_small_order_le`): in a cyclic group of
order `n`, at most `B²` elements have order `≤ B`, because
`{a : ord a ≤ B} ⊆ ⋃_{1 ≤ d ≤ B} {a : a^d = 1}` and each root set has size `≤ d`.

Sanity check modulo primes (counting units of order `≤ B = ⌊√(p-2)⌋`):

| p | p−1 | B = ⌊√(p−2)⌋ | #{ord ≤ B} | bound B² |
|---|---|---|---|---|
| 101 | 100 | 9  | 8  | 81  |
| 1009 | 1008 | 31 | 80 | 961 |
| 10007 | 10006 | 100 | 2 | 10000 |

The bound is loose but sufficient: it already forces a base of order `> √p`, so
any Fourier-sampling scheme needs `> √p` samples — exponential in `log p`.

## 4. Saturation of the uncertainty principle by the comb

For the coherent comb on a register of size `n = m·r` (teeth spaced `r`):
`#supp = m`, `#supp(DFT) = r`, product `= n`. This is proved in general (for all
`m, r ≥ 1`) in `Boundary.lean` (`comb_saturates_uncertainty`), together with the general
inequality `#supp · #supp(DFT) ≥ n` (`dft_support_uncertainty`).

## 5. No OEIS sequence

No integer sequence of independent interest arose (the counts above depend on
the scan range), so no OEIS identification is claimed.
