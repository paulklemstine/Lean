# Computational Evidence — Strange Attractors as Inverse Limits of Finite Digraphs

All numbers below were produced by `#eval` inside the Lean project (Lean 4.28.0 / Mathlib),
using the *same definitions* that the formal theorems are stated about
(`LorenzLimit.FinPath`, `LorenzLimit.ClosedWalk`, `LorenzLimit.adjMatrix`).  They are
evidence gathered *before* the proofs were written; every pattern reported here is now
backed by a machine-checked theorem in `Catalog/Novelty/StrangeAttractor*.lean`.

## 1. The two templates

| name | vertices | forbidden transitions | meaning |
|---|---|---|---|
| `lorenzTemplate` | `{false, true}` (branches `L`, `R`) | none | first-return graph of the geometric Lorenz template |
| `prunedTemplate` | `{false, true}` | `R → R` | Lorenz-type template with one branch return removed by kneading data |

## 2. Sizes of the finite approximants `N_n = #FinPath E n` (paths with `n` edges)

```
n                       0   1   2   3    4    5    6    7    8
lorenzTemplate          2   4   8  16   32   64  128  256  512
prunedTemplate          2   3   5   8   13   21   34   55   89
```

* Lorenz row `= 2^(n+1)` — OEIS **A000079** (powers of two).  Proved: `card_finPath_lorenz`.
* Pruned row `= fib (n+3)` — OEIS **A000045** (Fibonacci).  Proved: `card_finPath_pruned`
  (stated as `#FinPath prunedTemplate (n+1) = fib (n+4)`).

## 3. Closed walks `#ClosedWalk E n` and transfer-matrix traces `tr(A^n)`

```
n                       0   1   2   3    4    5    6    7    8
#ClosedWalk lorenz      2   2   4   8   16   32   64  128  256
tr(A_lorenz^n)          2   2   4   8   16   32   64  128  256
#ClosedWalk pruned      2   1   3   4    7   11   18   29   47
tr(A_pruned^n)          2   1   3   4    7   11   18   29   47
```

* The two pairs of rows agree exactly: evidence for the trace formula, proved as
  `card_closedWalk_eq_trace` (for *arbitrary* finite digraphs, not just these two).
* Lorenz traces for `n ≥ 1` are `2^n`.  Proved: `trace_adjMatrix_lorenz`.
* Pruned traces are `2, 1, 3, 4, 7, 11, 18, 29, 47` — OEIS **A000032** (Lucas numbers),
  i.e. `fib(n+1) + fib(n-1)`.  Proved in the shifted form
  `tr(A_pruned^(n+1)) = fib (n+2) + fib n` (`trace_adjMatrix_pruned`).

## 4. Counterexample hunt for the main conjecture

The conjecture tested was: *the orbit space of the symbolic model is the inverse limit of
the finite path sets under edge deletion.*  Attempts to break it:

* **Dead ends.**  If some vertex has no outgoing edge the bonding maps `truncPath` are not
  surjective; the inverse limit is still correct as a set, but levels can carry paths that
  extend to nothing.  The statement survives (`invLimitEquiv` needs no hypothesis), and the
  non-degeneracy of the tower is isolated as `truncPath_surjective` under `NoDeadEnds`.
* **Empty graph / empty levels.**  With `V` empty every level is empty and the limit is
  empty: `invLimitEquiv` still holds (both sides empty).  No counterexample.
* **Periodic-point count at `n = 0`.**  `#ClosedWalk E 0 = #V` while the shift fixes *every*
  point; so the bijection `PeriodicPoints ≃ ClosedWalk` genuinely needs `n ≥ 1`.  This is a
  real corner case found by the table above (`2` versus infinitely many) and is why
  `periodicEquivClosedWalk` carries the hypothesis `0 < n`.
* **Separating the two attractors.**  `tr(A^2)` is `4` for the Lorenz template and `3` for
  the pruned one; the tables show no `n` where the two sequences agree beyond `n = 0`.  The
  separation is proved at `n = 2` (`lorenz_not_conjugate_pruned`).

## 5. Growth rates (entropy)

(Unlike the integer tables above, the decimals in this table are ordinary numerical
evaluations of `log N_n / n` from the exact counts of section 2; they are illustrative and
are *not* themselves machine-checked.  The limits, however, are proved.)

```
n                        1      2      3      4      5      8
log N_n / n (lorenz)   1.386  1.040  0.924  0.866  0.832  0.780   →  log 2  ≈ 0.6931
log N_n / n (pruned)   1.099  0.805  0.693  0.641  0.609  0.561   →  log φ  ≈ 0.4812
```

(The convergence is slow — `log N_n / n = (n+1) log 2 / n` for the Lorenz template — which is
why the limits were proved by Fekete's subadditivity lemma plus exact formulas rather than
read off numerically: `entropy_lorenzTemplate = log 2`, `entropy_prunedTemplate = log φ`.)

## Addendum: the Cayley–Hamilton recurrence for periodic-orbit counts

The trace sequences recorded above were re-examined for a linear recurrence before the
general theorem was attempted.

| n | `tr(A_L^n)` (Lorenz) | `tr(A_P^n)` (pruned) |
|---|----------------------|----------------------|
| 1 | 2                    | 1                    |
| 2 | 4                    | 3                    |
| 3 | 8                    | 4                    |
| 4 | 16                   | 7                    |
| 5 | 32                   | 11                   |
| 6 | 64                   | 18                   |

The Lorenz column satisfies `a(n+2) = 2·a(n+1)` (characteristic polynomial `x² − 2x`,
since `det A_L = 0`), and the pruned column satisfies `a(n+2) = a(n+1) + a(n)`
(characteristic polynomial `x² − x − 1`, `tr A_P = 1`, `det A_P = −1`): the Lucas numbers,
OEIS A000032.  Both patterns are instances of one algebraic fact — the trace sequence of a
matrix is annihilated by its characteristic polynomial — and that is what is proved in
`Catalog/Novelty/StrangeAttractorRationality.lean` as `trace_charpoly_recurrence`, for an
arbitrary square matrix over a commutative ring, with the two templates recovered as
corollaries.

---

## 6. Evidence for the spectral cycle (`StrangeAttractorSpectral`, `StrangeAttractorPeriodicGrowth`)

All numbers below were again produced by `#eval` on the project's own definitions
(`LorenzLimit.adjMatrix`, `Matrix.trace`).

### 6.1 Transfer-matrix traces

```
n                    0  1  2  3   4   5   6    7    8    9    10    11    12
tr(A_lorenz^n)       2  2  4  8  16  32  64  128  256  512  1024  2048  4096
tr(A_pruned^n)       2  1  3  4   7  11  18   29   47   76   123   199   322
```

The pruned row is the Lucas sequence **A000032**; the Lorenz row is `2^n` for `n ≥ 1`
(**A000079**).

### 6.2 Empirical periodic-orbit growth rate `log tr(A^n) / n`

```
n                1        2        3        4        6        8        10       12
pruned      0.549306 0.462098 0.486478 0.479579 0.481042 0.481193 0.481210 0.481213
lorenz      0.693147 0.693147 0.693147 0.693147 0.693147 0.693147 0.693147 0.693147
```

with `log φ = 0.481212…` and `log 2 = 0.693147…`.  The convergence visible in the pruned
row is exactly the content of `tendsto_log_card_closedWalk_pruned`, and the constant Lorenz
row that of `tendsto_log_card_closedWalk_lorenz`; the general statement
`tendsto_log_card_closedWalk` (periodic-orbit growth rate = entropy for every primitive
graph carrying a Perron datum) is proved in `Catalog/Novelty/StrangeAttractorPeriodicGrowth.lean`.

### 6.3 The Perron data used

* Lorenz template: `A = [[1,1],[1,1]]`, eigenvector `(1,1)`, eigenvalue `2 = exp(entropy)`.
* Pruned template: `A = [[1,1],[1,0]]`, eigenvector `(φ,1)`, eigenvalue `φ`, since
  `φ·φ = φ + 1`.  Both are formalised as `perronLorenz` and `perronPruned`, and
  `perron_value_lorenz` / `perron_value_pruned` show that no other positive eigenvalue
  exists for these graphs.

---

## 7. Evidence for the Perron–Frobenius cycle (`StrangeAttractorPerronFrobenius`)

The new file constructs the Perron datum of a primitive graph as a maximiser of the
Collatz–Wielandt functional

`cw(x) = min_i (A x)_i / x_i`   over the standard simplex,

and proves that the maximum equals the Perron value.  The table below is the exact rational
output of power iteration `x ↦ A x` from `x₀ = (1,1)` on the **pruned template**
`A = [[1,1],[1,0]]`, produced by `#eval` (rational arithmetic, no floating point):

```
n     cw lower = min_i (Ax)_i/x_i      cw upper = max_i (Ax)_i/x_i     decimal
0     1                                2                               1.000000  2.000000
1     3/2                              2                               1.500000  2.000000
2     3/2                              5/3                             1.500000  1.666667
3     8/5                              5/3                             1.600000  1.666667
4     8/5                              13/8                            1.600000  1.625000
5     21/13                            13/8                            1.615385  1.625000
6     21/13                            34/21                           1.615385  1.619048
7     55/34                            34/21                           1.617647  1.619048
8     55/34                            89/55                           1.617647  1.618182
```

Both columns are ratios of consecutive Fibonacci numbers (**A000045**) and pinch
`φ = 1.6180339…` from below and above; the lower column is non-decreasing, which is the
finite-dimensional shadow of the variational characterisation that
`mulVec_eq_of_isMaxOn` turns into a proof.  On the **Lorenz template** `A = [[1,1],[1,1]]`
the functional is already constant, `cw ≡ 2` for every iterate — the eigenvector `(1,1)` is
reached immediately, matching `perronValue_lorenzTemplate = 2`.

*Counterexample hunt.*  The primitivity hypothesis is not decorative.  For the 2-cycle
`A = [[0,1],[1,0]]` (strongly connected but **not** primitive) power iteration from `(1,2)`
merely swaps the coordinates, and the Collatz–Wielandt sandwich never closes: `#eval` gives
`(min, max) = (1/2, 2)` at *every* iterate, so the iteration produces no eigenvector.  The
Perron datum it nevertheless possesses is `(1,1)` with eigenvalue `1`, while `tr(A^n)`
alternates `0, 2` — the failure mode already recorded for `tendsto_log_card_closedWalk`.
Its entropy is `0`, consistent with `entropy_pos_of_primitive`, whose hypothesis
`Primitive E` this graph fails.
