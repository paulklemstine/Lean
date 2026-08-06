# Computational evidence

Companion to `Catalog/Bridges/SubmultiplicativeSearchEntropy.lean`.

All quantities below refer to a nonnegative transition matrix `A` of a finite-state pruning
automaton over a search tree, with the **path count**

`P(n) = ∑_{i,j} (Aⁿ)_{ij}`  (total number of accepted length-`n` prefixes),

its **finite-scale rate** `rate(n) = log P(n) / n`, and its **dimension**
`dim(n) = log P(n) / (n · log b)` relative to an ambient `b`-ary tree.

## 1. Submultiplicativity `P(m+n) ≤ P(m)·P(n)`

Random search: 300 random nonnegative integer matrices of sizes `1×1 … 4×4` with entries in
`{0,1,2,3}`, all pairs `0 ≤ m,n ≤ 5` (10 800 instances).

**Violations found: 0.** (Now a theorem: `pathCount_submul`.)

## 2. The Fibonacci pruning automaton `A = !![1,1;1,0]`

Path counts `P(0..12)`:

```
2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610
```

These are the Fibonacci numbers `F(n+3)` — **OEIS A000045** (`1,1,2,3,5,8,13,21,34,55,89,…`).
This identity is proved in Lean as `pathCount_fibMatrix`.

Convergence of the rates towards `log φ = 0.481212…` (`φ` = golden ratio) and of the
dimensions towards `log φ / log 2 = 0.694242…`:

| n | rate(n) | dim(n), b = 2 |
|---|---------|---------------|
| 1 | 1.09861 | 1.58496 |
| 5 | 0.60890 | 0.87846 |
| 10 | 0.54510 | 0.78642 |
| 20 | 0.51316 | 0.74033 |
| 50 | 0.49399 | 0.71268 |
| 100 | 0.48760 | 0.70346 |
| 200 | 0.48441 | 0.69885 |
| 500 | 0.48249 | 0.69609 |
| ∞ | 0.481212 | 0.694242 |

The sequence decreases monotonically towards the limit, exactly as predicted by Fekete's lemma
(the limit is the *infimum* of the finite-scale rates).

Check of `φⁿ ≤ P(n)` for `0 ≤ n ≤ 29`: **holds in every case** (now the theorem
`gold_pow_le_fib`, i.e. `φⁿ ≤ F(n+3)`).

## 3. A three-state automaton `A = !![1,1,0; 0,0,1; 1,0,0]`

Path counts `P(0..11)`:

```
3, 4, 6, 9, 13, 19, 28, 41, 60, 88, 129, 189
```

satisfying `P(n) = P(n-1) + P(n-3)`, whose characteristic root is the supergolden ratio
`ρ = 1.46557123…` (root of `x³ = x² + 1`), so `log ρ = 0.382245…`.

| n | rate(n) |
|---|---------|
| 20 | 0.434101 |
| 50 | 0.402988 |
| 100 | 0.392616 |
| 200 | 0.387431 |
| 500 | 0.384319 |
| ∞ | 0.382245 |

Again the empirical rates decrease to `log ρ`, matching `tendsto_pathCount_rate`, and stay above
it, matching `pow_le_pathCount`.

## 4. Degenerate / boundary checks

* `A = !![s]` (uniform `s`-successful branching): `P(n) = sⁿ` exactly, `rate(n) = log s` for all
  `n ≥ 1`; the dimension is the classical similarity dimension `log s / log b`
  (`pathCount_scalar`, `uniform_searchDim`).
* `A = 0` (no successful path beyond the root): `P(n) = 0` for `n ≥ 1`; the hypothesis `P(n) ≥ 1`
  of the Fekete part genuinely excludes this case, as it must (`log 0` is meaningless as a rate).
* Reducible example `A = !![1,1;0,1]`: `Aⁿ = !![1,n;0,1]`, so `P(n) = n + 2` grows polynomially
  and `rate(n) = log(n+2)/n → 0`.  Here the Perron hypothesis fails (the only eigenvector is
  `(1,0)`, not strictly positive), so the bridge theorem does not apply; the Fekete part still
  does, since `P(n) ≥ 1`, and correctly yields growth rate `0`.  This shows the strict positivity
  of the eigenvector is what carries the identification with `log ρ`, not mere existence of an
  eigenvalue.

Note: the tables above come from exploratory scripting and are *evidence*, not verification.
The verified statements are exactly those in the Lean file, which compiles without `sorry` and
uses only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.
