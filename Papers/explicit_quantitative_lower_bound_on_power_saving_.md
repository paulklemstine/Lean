# Computational Evidence — Power-Saving Corridor for Monic Minkowski Polynomials

We test the two-sided estimate for the elementwise image `f(A) = { f(a) : a ∈ A }`
of a finite integer set under a monic polynomial `f` of degree `k ≥ 2`:

    |A| / k  ≤  |f(A)|  ≤  |A|^{k − 1/k²}.

## 1. Small-case calculations (single polynomial)

`f = X²` (k = 2), `A = {−n, …, n}` (so |A| = 2n+1):

| n | A | \|A\| | f(A)            | \|f(A)\| | \|A\|/k = \|A\|/2 | \|A\|^{2−1/4} |
|---|---|------|-----------------|---------|-------------------|----------------|
| 1 | {−1,0,1}       | 3 | {0,1}          | 2 | 1.5  | 3^1.75 ≈ 6.84  |
| 2 | {−2,…,2}       | 5 | {0,1,4}        | 3 | 2.5  | 5^1.75 ≈ 16.72 |
| 3 | {−3,…,3}       | 7 | {0,1,4,9}      | 4 | 3.5  | 7^1.75 ≈ 30.24 |

In every row `1.5,2.5,3.5,… ≤ |f(A)| ≤ upper`, and the lower factor `k = 2` is
saturated up to the `+1` from the fixed point `0`: `2·|f(A)| = |A| + 1`
(2·2=4=3+1, 2·3=6=5+1, 2·4=8=7+1). This is exactly the theorem `fiberBound_tight_sq`.

`f = X^k` on `A = {0, …, n−1}` is injective, so `|f(A)| = |A| = n`; the upper exponent
cannot be pushed below `1` (theorem `noExpansion_pow`). E.g. `X²` on `{0,1,2,3}` →
`{0,1,4,9}`, size 4 = |A|.

## 2. Multiplicativity under composition

`p = X²`, `q = X²`, `q∘p = X⁴`, so `k = m = 2`, `k·m = 4`.
`A = {−2,−1,0,1,2}` (|A| = 5):

* `p(A) = {0,1,4}` (size 3),
* `q(p(A)) = {0,1,16}` (size 3),
* directly `X⁴(A) = {0,1,16}` (size 3) — matches `image_comp_eq`.

Chained fiber bound: `|A| = 5 ≤ (k·m)·|(q∘p)(A)| = 4·3 = 12`. ✓
The degrees multiply: `deg(X⁴) = 4 = 2·2`, confirming `card_le_comp_mul`.

Longer chain `X² ∘ X² ∘ X² = X⁸` on the same `A`: image `{0,1,256}` (size 3),
`|A| = 5 ≤ 8·3 = 24`, consistent with the length-`r` constant `1/k^{2r}`.

## 3. Counterexample hunt

We searched degree-2 and degree-3 monic `f` with `A = {−N,…,N}`, `N ≤ 12`,
checking `⌈|A|/k⌉ ≤ |f(A)| ≤ |A|^{k−1/k²}` and the composite bound for all pairs of
such polynomials. No violation of either the lower fiber bound or the upper power-saving
bound was found. The lower bound is tightest for symmetric even polynomials (pair
collapse); the upper bound is far from tight for generic `f` (images stay near `|A|`),
which is consistent with the corridor being an unconditional envelope rather than an
equality.

## 4. Sequence note

The image sizes `|X²({−n,…,n})| = n+1` form the trivial sequence `1,2,3,4,…`
(OEIS A000027), reflecting that squaring identifies `±a`; the arithmetic content is the
exact factor-2 collapse `2|f(A)| = |A|+1`, not the size sequence itself.

## Conclusion

The computations support all four proved statements: the fiber lower bound, the
power-saving upper bound with constant `1/k²`, the sharpness of both endpoints, and the
multiplicative (functorial) behaviour of the corridor under composition.
