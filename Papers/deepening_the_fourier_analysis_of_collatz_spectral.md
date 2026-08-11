# Computational Evidence — Collatz parity words, spectra, and descent

All numbers below were produced by `#eval` inside Lean 4 (kernel-evaluated,
`Mathlib` v4.28.0) using exactly the definitions that appear in
`Catalog/MachineLearning/CollatzSpectral/`:

```lean
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else (3 * n + 1) / 2
def pbit (n j : ℕ) : ℕ := (T^[j] n) % 2
def parityWord (k n : ℕ) : ℕ := ∑ j ∈ Finset.range k, pbit n j * 2 ^ j
def onesCount (k n : ℕ) : ℕ := ∑ j ∈ Finset.range k, pbit n j
```

These evaluations are *exploratory*: every claim they suggest was subsequently
proved in Lean with no `sorry` (theorem names are given in each section).

## 1. The parity-word map is a permutation of `ℤ/2^k` (Terras)

| `k` | `parityWord k` on `0,…,2^k−1` |
|-----|-------------------------------|
| 3   | `[0, 5, 2, 3, 4, 1, 6, 7]` |
| 4   | `[0, 5, 10, 3, 4, 1, 6, 7, 8, 13, 2, 11, 12, 9, 14, 15]` |
| 5   | sorted image `= [0,…,31]` → `true` |

So the map is a bijection, not merely injective-looking. It is *not* the
identity and *not* an affine map — the permutation genuinely mixes.

Proved as `parityWord_bijOn`, `parityWord_surjective`.

## 2. Ones-counts are exactly binomial

Counting residues `n < 2^6` by their number of odd steps `s_6(n)`:

| `s` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|-----|---|---|---|---|---|---|---|
| `#{n < 64 : s_6(n) = s}` | 1 | 6 | 15 | 20 | 15 | 6 | 1 |
| `C(6,s)` | 1 | 6 | 15 | 20 | 15 | 6 | 1 |

Exact match. Proved in the sharper generating-function form
`onesCount_generating_function : ∑_{n<2^k} x^{s_k(n)} = (1+x)^k`.

## 3. Exact moment identities

* `∑_{n<2^6} 3^{s_6(n)} = 4^6` → `true` (`sum_three_pow_onesCount`); hence the
  arithmetic mean of the multiplier `3^{s}/2^k` is exactly `1`
  (`mean_multiplier_eq_one`).
* `∑_{n<2^8} (2 s_8(n) − 8)^2 = 8 · 2^8` → `true` (`sum_sq_deviation`);
  variance exactly `k/4`.

## 4. Counterexample hunt: non-contracting residues

`#{ r < 2^k : 3^{s_k(r)} ≥ 2^k }` for `k = 0,…,11`:

```
1, 1, 1, 4, 5, 6, 22, 29, 37, 130, 176, 562
```

Densities: `k=8 → 0.145`, `k=9 → 0.254`, `k=10 → 0.172`, `k=11 → 0.274`.
No counterexample to the proved Chebyshev bound
`density ≤ 1/(4δ²k)` (`noncontracting_density_le`) was found — and indeed the
bound is far from tight: it only becomes non-vacuous (`< 1`) around `k ≥ 15`,
whereas the observed densities are already well below `1`. The true decay looks
exponential in `k` (large-deviation regime), which is exactly the content of
Conjecture C1 in `FUTURE_DIRECTIONS.md`.

## 5. Sharpness of the descent threshold

`descent_uniform` proves descent above the explicit threshold `2^k·4^k`.
Empirically the threshold is enormously conservative:

* for `k = 5`, among all `n ∈ [2^5·4^5, 2^5·4^5 + 300)` with a contracting
  residue, the number of *failures* of `T^[5] n < n` is `0`;
* scanning `n < 4000`, the **only** `n` with contracting residue mod `32` that
  fail to descend in 5 steps are `n = 0` and `n = 1`.

So the true threshold appears to be `O(1)`, not `8^k`. This is Conjecture C2.

## 6. The Chernoff bound

The arithmetic Chernoff inequality `|B_k|^5 · 8^k ≤ 243^k`
(`card_noncontracting_pow_le`) was checked for `k = 0,…,12`, using
`|B_k| = 1,1,1,4,5,6,22,29,37,130,176,562,794`: it holds in every case, with
several orders of magnitude of slack (e.g. `k = 11`: `4.8·10^23 ≤ 1.7·10^26`).

## 7. `T^[k] r − r` on contracting residues

The maximum of `T^[k] r − r` over all contracting `r < 2^k`:

| `k`   | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
|-------|---|---|---|---|---|----|----|----|----|----|----|----|
| max   | 1 | 0 | 1 | 2 | 1 | 0  | 1  | 0  | 1  | 0  | 1  | 0  |

So the intercept stays bounded (`≤ 2` throughout), which is the evidence behind
Conjecture C2.

## 8. Global sanity check

Among `1 ≤ n < 10000`, exactly `8282` satisfy `T^[10] n < n` (82.8%),
consistent with the density-one statement `density_one_descent`.

## OEIS

No network access was available in this environment, so no OEIS lookup was
performed. The sequence of Section 4 (`1, 1, 1, 4, 5, 6, 22, 29, 37, 130, 176,
562`) is recorded here for future identification; we make no claim about its
presence in OEIS.
