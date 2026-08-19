# Computational evidence (cycle 2)

All computations below were run inside Lean 4 with `#eval` on the exact definitions later used in
the formal proofs (`gaussBinom q n k = (∏_{i<k}(q^n - q^i)) / (∏_{i<k}(q^k - q^i))` in `ℕ`, with
truncated subtraction and truncated division).  Everything reported here was subsequently turned
into a machine-checked theorem, except where explicitly noted.

## 1. The `q`-Pascal recursion

Claim: `gaussBinom q (n+1) (k+1) = gaussBinom q n k + q^{k+1} * gaussBinom q n (k+1)`.

Tested for `q ∈ {2,3,4,5,6}` and all `0 ≤ n, k ≤ 5`: **no counterexample** (all 180 instances true).

The falsifiable instance announced by the previous cycle, `q = 4, n = 2, k = 1`:

| quantity | value |
|---|---|
| `gaussBinom 4 2 1` | 5 |
| `gaussBinom 4 1 0 + 4 * gaussBinom 4 1 1` | `1 + 4 = 5` |

Proved: `GaussPascal.gaussBinom_pascal`, `GaussPascal.gaussBinom_pascal_four`.

## 2. Symmetry at non-prime bases

Claim: `gaussBinom q n k = gaussBinom q n (n-k)` for `k ≤ n`.  Tested for `q ∈ {2,…,6}`,
`n, k ≤ 6`: no counterexample.  Note `q = 4` and `q = 6` are outside the range of the previous
cycle's proof, which went through the `(ZMod q)^n` subspace model and needed `q` prime.

Proved: `GaussPascal.gaussBinom_symm` (all `q ≥ 2`), example `gaussBinom_symm_six`.

## 3. Rows of the Gaussian triangle at `q = 2`

```
n = 0 : 1
n = 1 : 1 1
n = 2 : 1 3 1
n = 3 : 1 7 7 1
n = 4 : 1 15 35 15 1
```

Row sums (Galois numbers): `1, 2, 5, 16, 67, 374, 2825` — OEIS **A006116**.
At `q = 3`: `1, 2, 6, 28, 212, 2664, 56632` — OEIS **A006117**.
At `q = 4`, `n = 3`: `1 + 21 + 21 + 1 = 44`.

Proved: `GaussPascal.galoisNumber_two_values`, `galois_number_four_three`,
`galoisNumber_three_four`.

## 4. Recursions for the Galois numbers

With `G_q(n) = ∑_{k≤n} binom(n,k)_q` and `S_q(n) = ∑_{k≤n} q^k binom(n,k)_q`, the following three
identities were tested for `q ∈ {2,3,4,5}` and `n ≤ 5`, with no counterexample:

* `G_q(n+1) = G_q(n) + S_q(n)`;
* `S_q(n+1) = q^{n+1} G_q(n) + S_q(n)`;
* `G_q(n+2) + G_q(n) = 2 G_q(n+1) + q^{n+1} G_q(n)`.

Sample (`q = 2`): `G(4) + G(2) = 67 + 5 = 72 = 2·16 + 8·5`.

Proved: `GaussPascal.galoisNumber_succ`, `qWeightedSum_succ`, `galoisNumber_recursion`.

## 5. Subgroup counts of small abelian groups

| group | order | number of subgroups |
|---|---|---|
| `ℤ/4` | 4 | 3 (divisors of 4) |
| `(ℤ/2)²` | 4 | 5 (`= 2 + 3`) |
| `ℤ/9` | 9 | 3 |
| `(ℤ/3)²` | 9 | 6 (`= 3 + 3`) |
| `ℤ/12 ≃ ℤ/4 × ℤ/3` | 12 | 6 (`= 3 · 2 = d(12)`) |

These are the counts predicted by the three theorems proved in
`Catalog/Algebra/SubgroupCountFiniteAbelian.lean`: the divisor count for cyclic groups, the
`p + 3` count for elementary abelian groups of order `p²`, and multiplicativity over coprime
factors.  The first two rows are the falsifiable contrast announced by the previous cycle
(`3 ≠ 5` at order `4`) and are proved as `card_subgroup_zmod_four`, `card_subgroup_kleinFour`,
`card_subgroup_ne_of_order_four`.

## 6. Counterexample hunt

* Is the subgroup count a function of the group order?  **No** — order `4` already separates
  `ℤ/4` (3) from `(ℤ/2)²` (5).  Formalised as `card_subgroup_ne_of_order_four` and, for a general
  prime, `card_subgroup_cyclic_ne_elementary`.
* Is the subgroup count multiplicative over *arbitrary* direct products?  **No** —
  `#Subgroup((ℤ/2)²) = 5 ≠ 4 = 2 · 2 = #Subgroup(ℤ/2) · #Subgroup(ℤ/2)`.  This is why the
  coprimality hypothesis in `card_subgroup_prod_of_coprime` is not removable.  (Checked by the
  two proved counts; the inequality itself is immediate arithmetic.)
* Does the `q`-Pascal recursion hold at `q = 1`?  **No** — the definition divides by
  `∏_{i<k}(1 - 1) = 0`, so `gaussBinom 1 n k = 0` for `k ≥ 1` while the recursion would force
  `gaussBinom 1 (n+1) 1 = 1 + gaussBinom 1 n 1`.  This is why every theorem assumes `2 ≤ q`.

## 7. The mixed count at class number twelve (completion pass)

The abelian groups of order `12` are `ℤ/12 ≃ ℤ/4 × ℤ/3` and `(ℤ/2)² × ℤ/3`.  Their subgroup
counts, predicted by multiplicativity over the coprime primary factors together with the cyclic
and Galois-number counts:

| group | primary factors | subgroup count | prediction |
|---|---|---|---|
| `ℤ/12` | `ℤ/4 × ℤ/3` | 6 | `d(4) · d(3) = 3 · 2` |
| `(ℤ/2)² × ℤ/3` | `(ℤ/2)² × ℤ/3` | 10 | `G_2(2) · G_3(1) = 5 · 2` |

with `G_2(2) = 5` and `G_3(1) = 2` the Galois numbers of
`Catalog/Algebra/GaussianBinomialPascal.lean`.  Both rows are now theorems:
`SubgroupCount.card_subgroup_prod_four_three` and `MixedClassGroup.card_subgroup_mixed`
(specialised in `MixedClassGroup.card_subgroup_order_twelve_ne`), so the number of intermediate
fields of a Hilbert class field still separates the two abelian types at class number `12`
(`MixedClassGroup.card_intermediateField_klein_times_three`: exactly `10` intermediate fields).

Sanity check of the general formula `G_p(r) · G_q(s)` on further data:

| `p, r, q, s` | order of the class group | predicted count |
|---|---|---|
| `2, 1, 3, 1` | 6 | `2 · 2 = 4` |
| `2, 2, 3, 1` | 12 | `5 · 2 = 10` |
| `2, 3, 3, 1` | 24 | `16 · 2 = 32` |
| `2, 2, 3, 2` | 36 | `5 · 6 = 30` |

The values `G_2(1) = 2`, `G_2(2) = 5`, `G_2(3) = 16`, `G_3(1) = 2`, `G_3(2) = 6` are the ones
proved in `GaussPascal.galoisNumber_two_values` and `GaussPascal.galoisNumber_two`.
