# Computational Evidence — Cycle 3 (silent-error constants)

All numbers below were produced by evaluating Lean 4 expressions (`#eval`) over
exact rationals `ℚ`; they are *exploratory* checks that guided the conjectures.
The mathematical claims themselves are proved in
`Catalog/MachineLearning/AlmostLossless*.lean` (0 sorries) — the tables are not a
substitute for those proofs.

## 1. Is `(1 + √δ)²` really the frontier optimum?

The two-sided derandomization delivers, for any admissible threshold pair
`(c₁, c₂)` (silent constant `c₁`, failure constant `c₂`, admissible iff
`1/c₁ + 1/c₂ ≤ 1`), a total error `δ + (c₂ + c₁·δ)·L` with `L = |l|/M`.
A brute-force grid search over `c₁, c₂ ∈ {1 + k/20 : k = 1,…,400}` minimising
`c₂ + c₁·δ` subject to admissibility gives:

| δ | grid minimum of `c₂ + c₁δ` | closed form `(1+√δ)²` |
|---|---|---|
| 1        | 4            | 4            |
| 1/4      | 9/4 = 2.25   | 9/4 = 2.25   |
| 1/100    | 121/100      | 121/100      |
| 1/10000  | 10521/10000  | 10201/10000  |

The first three rows are exact hits (for these `δ` the optimiser
`c₁ = 1 + 1/√δ`, `c₂ = 1 + √δ` lies on the grid). The last row is a near miss
because the optimal `c₁ = 101` lies outside the grid range (`c₁ ≤ 21`); the grid
value is above the closed form, as the theorem requires.

Proved as `AlmostLossless.frontier_total_constant_ge` (Cauchy–Schwarz, `≥`) and
`AlmostLossless.frontier_total_constant_balanced` (equality at the balanced
point).

Note the cycle-2 point `c₁ = c₂ = 2` gives `2 + 2δ`, which at `δ = 10⁻⁴` is
`2.0002` against the optimum `1.0201`: a factor-2 loss in total error that the
√δ-balanced key removes.

## 2. Counterexample hunt for the covering converse

For the sharpness statement we need, whenever `1/c₁ + 1/c₂ > 1`, two blocks of
keys of sizes below the Markov thresholds that still cover `Fin K`. The
construction splits at `n = ⌈K/c₁⌉ − 1`. Evaluating
`(n, K−n, n·c₁ < K, (K−n)·c₂ < K, K(1/c₁+1/c₂−1))`:

| K | c₁ | c₂ | n | K−n | `n·c₁ < K` | `(K−n)·c₂ < K` | excess `K(1/c₁+1/c₂−1)` |
|---|----|----|---|-----|------------|----------------|--------------------------|
| 40  | 19/10 | 19/10 | 21  | 19 | true | true  | 40/19 ≈ 2.11 |
| 10  | 19/10 | 19/10 | 5   | 5  | true | true  | 10/19 ≈ 0.53 |
| 100 | 3/2   | 5/2   | 66  | 34 | true | true  | 20/3 ≈ 6.67  |
| 100 | 2     | 2     | 49  | 51 | true | **false** | 0        |
| 1000| 99/100| 100   | 1010| 0  | true | true  | 1990/99 ≈ 20.1 |

The row `c₁ = c₂ = 2` sits exactly on the admissible boundary
`1/c₁ + 1/c₂ = 1`, and the construction provably *fails* there — consistent with
`exists_tunable_good_key`, which guarantees a surviving key in precisely that
regime. The `K = 10` row shows the sufficient hypothesis
`1 < K(1/c₁+1/c₂−1)` used in `exists_covering_of_density_gt_one` is not
necessary: coverings can already exist for smaller key spaces. No counterexample
to any proved statement was found.

## 3. Sanity check of the balanced constants

`η = 1/√δ` in the tunable scheme gives failure constant `1 + 1/η = 1 + √δ` and
silent constant `(1 + η)δ = δ + √δ`. Spot values: `δ = 1/4 → (1.5, 0.75)`;
`δ = 1/100 → (1.1, 0.11)`; `δ = 10⁻⁴ → (1.01, 0.0101)`. The failure constant
approaches the first-moment optimum `1` and the silent constant approaches `0`,
which is the qualitative content of
`balanced_failure_constant_tendsto_one` and
`balanced_silent_constant_tendsto_zero`.

## 4. OEIS

No integer sequence arises in this cycle (all objects are real-valued
constants and probability bounds), so no OEIS lookup applies.
