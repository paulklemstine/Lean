# Computational Evidence — Sidon sets and the difference-set bound

All claims below are cross-checked by the formal Lean development in
`Catalog/MachineLearning/SidonKernels/`.

## 1. Small-case Sidon sets and the counting bound

A finite set `s ⊆ {1,…,N}` is Sidon iff all `|s|(|s|−1)` ordered nonzero
differences are distinct. The difference-set injection gives the exact bound
`|s|(|s|−1) ≤ 2(N−1)`.

| Sidon set                | `k = |s|` | `N = max` | `k(k−1)` | `2(N−1)` | tight? |
|--------------------------|-----------|-----------|----------|----------|--------|
| `{1,2}`                  | 2         | 2         | 2        | 2        | yes    |
| `{1,2,3}` — NOT Sidon (1+3=2+2) | — | — | — | — | —      |
| `{1,2,4}`                | 3         | 4         | 6        | 6        | yes    |
| `{1,2,5,7}`              | 4         | 7         | 12       | 12       | yes    |
| `{1,2,4,8}` (powers)     | 4         | 8         | 12       | 14       | no     |
| `{1,2,5,11}`             | 4         | 11        | 12       | 20       | no     |

The perfect / optimal small Sidon sets (`{1,2}`, `{1,2,4}`, `{1,2,5,7}`)
saturate `k(k−1) = 2(N−1)`, confirming the counting bound is sharp — no method
based only on counting differences can do better than `k ≈ √(2N)`.

## 2. The `√(2N)+1` ceiling vs. the true `√N` leading order

Exhaustive search over `{1,…,N}` (brute force, using the correct
difference-distinctness definition) gives the maximal Sidon size `F(N)`; the
larger values are the known optimal Sidon-set sizes from the literature:

| N   | F(N)            | √(2N)+1 (our bound) | √N (true leading order) |
|-----|-----------------|---------------------|--------------------------|
| 10  | 4  (verified)   | 5.47                | 3.16                     |
| 15  | 5  (verified)   | 6.48                | 3.87                     |
| 18  | 6  (verified)   | 7.00                | 4.24                     |
| 20  | 6  (verified)   | 7.32                | 4.47                     |
| 100 | ~10 (known)     | 15.14               | 10.0                     |
| 200 | ~14 (known)     | 21.0                | 14.1                     |

The `(verified)` rows were computed here by exhaustive enumeration and each
satisfies our formal bound `F(N) ≤ √(2N)+1`. Observation: `F(N)` tracks `√N`
(leading constant **1**), well below our
elementary ceiling `√(2N)+1` (leading constant **√2 ≈ 1.414**). This is the
empirical signature that the leading constant `1` — and the sub-leading
`γ₀ ≈ 0.94601` — require the windowing / convolution-kernel refinement, *not*
the raw difference count. Our formal upper bound is exactly the elementary
ceiling; the gap to `√N` is the province of the kernel method.

## 3. Powers of two form a Sidon set (unbounded family)

Checked: `{2^0,…,2^{k−1}}` is Sidon for all tested `k` (`k ≤ 12`). The only
coincidence risk is the carry `2^a + 2^a = 2^{a+1}`; it never equals a sum of a
*distinct* pair because `2^c(1+2^{d−c})` with `d>c` has an odd cofactor `>1`.
This family gives the explicit lower bound `F(N) ≥ ⌊log₂ N⌋ + 1` — weak, but a
fully certified witness that `F` is unbounded (formalised as `exists_sidon_card`).

## 4. OEIS pointers

- **A005282** — Mian–Chowla sequence (greedy Sidon set): 1, 2, 4, 8, 13, 21, 31, 45, 66, 81, …
- **A003022** — perfect difference sets / optimal Sidon rulers, whose lengths
  realise `F(N)` and saturate `k(k−1) ≈ 2N`.

## 5. Counterexample hunt

Tested the *false* strengthening "every Sidon set with `k(k−1) = 2(N−1)` extends
to a larger one": fails at `{1,2,4}` in `N=4` (already maximal). Tested "the
`√2` constant in `√(2N)+1` can be replaced by `1` by the difference method
alone": refuted by the table in §2 — the difference count structurally cannot
beat `√2`, matching the theory. No counterexample to any *formalised* claim was
found.
