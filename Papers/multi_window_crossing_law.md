# Computational evidence — multi-window crossing law

Exploration was done with exact rational arithmetic (`#eval` over `ℚ`, brute force over all
`M!` search orders). These runs are exploratory; the instances marked **(formal)** are also
proved as Lean theorems in `Catalog/Combinatorics/MultiWindowCrossingExamples.lean`.

## 1. Small cases: Bayes cost vs committed cost vs block formula

Block formula: committed cost = \( \sum_i (A_{i+1}-A_i)\,\frac{B_i+B_{i+1}+1}{2} \)
(sum includes the complement block, \(A_n = 1\)).

| boundaries `B` | cumulative `A` | densities | min over all orders | committed | formula |
|---|---|---|---|---|---|
| 0,1,3,6 | 0, 1/2, 5/6, 1 | 1/2, 1/6, 1/18 (calibrated) | 13/6 | 13/6 | 13/6 **(formal)** |
| 0,2,3,5,7 | 0, 2/5, 3/5, 4/5, 1 | 1/5, 1/5, 1/10, 1/10 | 17/5 | 17/5 | 17/5 |
| 0,1,2,4,6 | 0, 3/10, 1/2, 3/4, 1 | 3/10, 1/5, 1/8, 1/8 | 59/20 | 59/20 | 59/20 |
| 0,1,4,7 | 0, 1/7, 4/7, 1 | uniform | 4 | 4 | 4 |
| 0,3,6 | 0, 1/10, 1 | 1/30, 3/10 (**anti-calibrated**) | **23/10** | 47/10 | 47/10 **(formal)** |

Observations: in every calibrated case Bayes = committed = block formula; in the
anti-calibrated case the formula still gives the committed cost, but Bayes is strictly cheaper
(`calibration_needed`).

## 2. Counterexample hunt: the gate as literally stated

The prompt's sum over the `k` named windows only (without the complement block) is **not**
the correct gate. For one window, `w = 1/2`, `α = 1/2`: windows-only sum `= 1/8 ≤ 1/6 = 1/(3·2)`,
but the true priced speedup is `2/3 < 2` (`naive_gate_fails`, formal). The correct gate adds the
complement block `(1 - α_k) · (1 + w_k)/2`; with it, `n = 2` reproduces `crossing_law`
exactly (`single_window_crossing_law`, formal).

## 3. OEIS

No integer sequence arises naturally (the quantities are rational functionals of the
reliability profile); no OEIS search was relevant.
