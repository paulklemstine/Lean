# Computational Evidence: cubic Rayleigh quotient of the path swap chain

We record the small-case data that motivated the two-sided `Θ(n^{-3})` estimate
for the length-`n` path swap chain with the linear position witness `f(i) = i`.

## Closed-form quantities

For the position witness on the length-`n` path the formalized identities give

* Dirichlet energy  `E(f) = 2(n − 1)`,
* pairwise variation `V(f) = n²(n² − 1)/6`,
* Rayleigh quotient  `RQ(f) = E(f)/V(f) = 12 / (n²(n + 1))`.

## Small cases

| n  | E = 2(n−1) | V = n²(n²−1)/6 | RQ = 12/(n²(n+1)) | n³·RQ  |
|----|-----------|----------------|-------------------|--------|
| 2  | 2         | 2              | 1.0000            | 8.000  |
| 3  | 4         | 12             | 0.3333            | 9.000  |
| 4  | 6         | 40             | 0.1500            | 9.600  |
| 5  | 8         | 100            | 0.0800            | 10.000 |
| 6  | 10        | 210            | 0.0476            | 10.286 |
| 10 | 18        | 1650           | 0.010909…         | 10.909 |
| 20 | 38        | 26600          | 0.0014285…        | 11.429 |

The scaled quantity `n³·RQ = 12 n /(n+1)` increases monotonically from `8`
toward `12`, confirming `RQ ∈ [6 n^{-3}, 12 n^{-3}]` and pinpointing the exponent
`3` (rather than `2` or `4`).

## Poincaré lower bound (all test functions)

The lower-bound mechanism predicts `RQ(f) ≥ 2 n^{-3}` for *every* non-constant
`f`, via `Var(f) ≤ n³ · E(f)` where `E(f)` is the edge energy and `Dir = 2·E`.
Spot check `n = 4` with a random-looking profile `f = (0, 3, 1, 2)`:

* edge energy `E = 3² + 2² + 1² = 14`, so `Dir = 28`;
* variance `V = Σ_{x,y}(f_x − f_y)² = 2(4·Σf² − (Σf)²) = 2(4·14 − 36) = 40`;
* bound check: `V = 40 ≤ n³·E = 64·14 = 896` ✓ (Poincaré holds with room);
* `RQ = 28/40 = 0.70 ≥ 2/64 = 0.03125` ✓.

Both the exact witness value and the universal lower bound are matched by the
formal theorems `path_RQ_eq`, `path_RQ_Theta`, `path_vr_le`, `path_RQ_lower`,
and `path_gap_Theta`.


# Computational Evidence: cubic Rayleigh quotient of the path swap chain

We record the small-case data that motivated the two-sided `Θ(n^{-3})` estimate
for the length-`n` path swap chain with the linear position witness `f(i) = i`.

## Closed-form quantities

For the position witness on the length-`n` path the formalized identities give

* Dirichlet energy  `E(f) = 2(n − 1)`,
* pairwise variation `V(f) = n²(n² − 1)/6`,
* Rayleigh quotient  `RQ(f) = E(f)/V(f) = 12 / (n²(n + 1))`.

## Small cases

| n  | E = 2(n−1) | V = n²(n²−1)/6 | RQ = 12/(n²(n+1)) | n³·RQ  |
|----|-----------|----------------|-------------------|--------|
| 2  | 2         | 2              | 1.0000            | 8.000  |
| 3  | 4         | 12             | 0.3333            | 9.000  |
| 4  | 6         | 40             | 0.1500            | 9.600  |
| 5  | 8         | 100            | 0.0800            | 10.000 |
| 6  | 10        | 210            | 0.0476            | 10.286 |
| 10 | 18        | 1650           | 0.010909…         | 10.909 |
| 20 | 38        | 26600          | 0.0014285…        | 11.429 |

The scaled quantity `n³·RQ = 12 n /(n+1)` increases monotonically from `8`
toward `12`, confirming `RQ ∈ [6 n^{-3}, 12 n^{-3}]` and pinpointing the exponent
`3` (rather than `2` or `4`).

## Poincaré lower bound (all test functions)

The lower-bound mechanism predicts `RQ(f) ≥ 2 n^{-3}` for *every* non-constant
`f`, via `Var(f) ≤ n³ · E(f)` where `E(f)` is the edge energy and `Dir = 2·E`.
Spot check `n = 4` with a random-looking profile `f = (0, 3, 1, 2)`:

* edge energy `E = 3² + 2² + 1² = 14`, so `Dir = 28`;
* variance `V = Σ_{x,y}(f_x − f_y)² = 2(4·Σf² − (Σf)²) = 2(4·14 − 36) = 40`;
* bound check: `V = 40 ≤ n³·E = 64·14 = 896` ✓ (Poincaré holds with room);
* `RQ = 28/40 = 0.70 ≥ 2/64 = 0.03125` ✓.

Both the exact witness value and the universal lower bound are matched by the
formal theorems `path_RQ_eq`, `path_RQ_Theta`, `path_vr_le`, `path_RQ_lower`,
and `path_gap_Theta`.
