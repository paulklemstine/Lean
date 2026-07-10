# Computational Evidence

Theme: the equilateral hard instance `X_n` (`n` points, all pairwise distances `1`)
exhibits an **exponential Vietoris–Rips complex** while remaining **logarithmically
doubling**. The Lean file `MachineLearning/RipsDoublingLowerBound.lean` proves both
facts; this note records the small-case arithmetic that motivated the statements.

## 1. Small-case calculations

For `X_n` at any scale `r ≥ 1`, every subset has diameter `≤ 1 ≤ r`, so the Rips
complex is the full power set on `n` vertices. Its face count (including `∅`) is `2^n`.

| n | faces `|Rips(X_n, r)|` = 2^n | vertices n | covering number at critical scale |
|---|------------------------------|------------|-----------------------------------|
| 1 | 2                            | 1          | 1                                 |
| 2 | 4                            | 2          | 2                                 |
| 3 | 8                            | 3          | 3                                 |
| 4 | 16                           | 4          | 4                                 |
| 5 | 32                           | 5          | 5                                 |
| 6 | 64                           | 6          | 6                                 |

At the *critical scale* `R ∈ [1, 2)` the half-radius balls have radius `R/2 < 1`,
so each is a singleton; covering the whole `n`-point space then needs exactly `n`
balls. Hence the doubling number is `n` and the doubling dimension is `log₂ n`:

| n | doubling dimension log₂ n |
|---|---------------------------|
| 2 | 1.00                      |
| 4 | 2.00                      |
| 8 | 3.00                      |
| 16| 4.00                      |

The two columns `2^n` and `log₂ n` are the crux: the complex is exponential in `n`
while the geometric complexity (doubling dimension) is only logarithmic — and,
crucially, **unbounded**, matching the guiding principle that a *bounded* doubling
dimension is what enables linear-size sparsification.

## 2. OEIS

The face-count sequence `2, 4, 8, 16, 32, 64, …` is **A000079** (powers of two).
The super-linear separation `n < 2^n` is verified in Lean as `card_lt_two_pow`.

## 3. Counterexample hunt

- `equiDist` is a metric: checked the triangle inequality on all `3`-point patterns
  (`x=y=z`, `x=y≠z`, `x≠y=z`, `x≠y, y≠z, x=z`, all distinct); no violation.
  Formalized as `equiDist_isMetric`.
- Size lower bound `2^n ≤ |K|` for any `K ⊇ Rips(X_n,1)`: no counterexample; the
  monotonicity of `Finset.card` under `⊆` forces it (`representation_size_lower_bound`).
- Covering-number lower bound: tested that no cover of size `< n` exists at the
  critical scale, since singletons cannot cover more than one point each
  (`covering_number_equiDist`).

No counterexamples were found; all conjectured statements were subsequently proved
in Lean with only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.
