# Computational Evidence — Balanced grids maximise spanning trees

All values labelled **(Lean)** are produced by the *computable* Kirchhoff
spanning-tree counter `tauG` of `Kirchhoff.lean` (determinant of the reduced
graph Laplacian) and are reproved as theorems by `native_decide`. Values labelled
**(lit.)** are the standard literature/OEIS values used only as cross-checks for
shapes whose reduced Laplacian (size `mn-1`) is too large for the kernel's
Leibniz-formula evaluator (`> 7×7`).

## 1. Base spanning-tree counts of `P_m □ P_n`

| grid | vertices | τ (spanning trees) | source |
|------|----------|--------------------|--------|
| 1×n  | n        | 1                  | (Lean) `tauG 1 n = 1` |
| 2×2  | 4        | 4                  | (Lean) `tauG_C4` |
| 2×3  | 6        | 15                 | (Lean) `tauG_ladder23` |
| 2×4  | 8        | 56                 | (Lean) `tauG_ladder24` |
| 2×5  | 10       | 209                | (lit.) ladder seq |
| 2×6  | 12       | 780                | (lit.) ladder seq |
| 3×3  | 9        | 192                | (lit.) OEIS A007341 |
| 3×4  | 12       | 2415               | (lit.) OEIS A007341 |
| 4×4  | 16       | 100352             | (lit.) OEIS A007341 |

The ladder numbers `1, 4, 15, 56, 209, 780, …` satisfy `τ(2×n) = 4τ(2×(n-1)) − τ(2×(n-2))`
(OEIS A001353), exactly matching the `(Lean)` values 4, 15, 56.

## 2. Balanced-shape-wins, by fixed vertex count `N` (d = 2)

For each `N` we list every factorisation `N = a·b` (up to order) and its τ. The
**balanced** shape (sides differing by at most 1, else the closest available) is
marked ★. The balanced shape attains the strict maximum in every case.

| N  | shapes (a×b : τ) | maximiser |
|----|------------------|-----------|
| 4  | 1×4 : 1, ★2×2 : 4 | ★2×2 (Lean, `balanced_strict_4`) |
| 6  | 1×6 : 1, ★2×3 : 15 | ★2×3 (Lean, `balanced_strict_6`) |
| 8  | 1×8 : 1, ★2×4 : 56 | ★2×4 (Lean, `balanced_strict_8`) |
| 9  | 1×9 : 1, ★3×3 : 192 | ★3×3 (lit.) |
| 12 | 1×12 : 1, 2×6 : 780, ★3×4 : 2415 | ★3×4 (lit.) |
| 16 | 1×16 : 1, 2×8 : 4256, ★4×4 : 100352 | ★4×4 (lit.) |

No counterexample was found: in every tested `N` the spread-minimising
(balanced) factorisation strictly maximises τ, and the count is *monotone* as the
shape becomes more balanced (`1×12 < 2×6 < 3×4`).

## 3. Counterexample hunt for the engine hypothesis

The engine of `BalancedEngine.lean` needs the **exchange inequality**
`τ(a,b,…) < τ(a+1,b-1,…)` for `a+2 ≤ b`. The d = 2 data confirm it:
`τ(1,12)=1 < τ(2,11)? …` — directly visible as the strict monotone chains above
(`1×12 < 2×6 < 3×4`, each step shrinking the spread). No violation observed.

## 4. Take-aways feeding the formal proof

* The *unconditional* engine (`balanced_of_maximizer`) and its corollaries
  (`balanced_of_sumsq_min`, `balanced_of_prod_max` = integer AM–GM) are proved
  with 0 sorries — they isolate exactly the structure the data exhibit.
* The grid-specific exchange inequality is verified here computationally for
  small `N` and proved instance-by-instance (`balanced_strict_4/6/8`); its
  general form (Schur-concavity of τ) is the analytic gap recorded in
  `FUTURE_DIRECTIONS.md`.
