# Computational Evidence

The connector concerns the diagonal "nuclear Hamiltonian"
`H n = diagonal(1, 2, …, n)` on `ℝ^n` and its spectral invariants.

## 1. Small-case calculations

| `n` | eigenvalues (spectrum) | trace `= Σ` | `n(n+1)/2` | det `= Π` | `n!` |
|-----|------------------------|-------------|------------|-----------|------|
| 1   | {1}                    | 1           | 1          | 1         | 1    |
| 2   | {1,2}                  | 3           | 3          | 2         | 2    |
| 3   | {1,2,3}                | 6           | 6          | 6         | 6    |
| 4   | {1,2,3,4}              | 10          | 10         | 24        | 24   |
| 5   | {1,2,3,4,5}            | 15          | 15         | 120       | 120  |

The trace column matches the triangular numbers and the det column matches the
factorials in every case — this is exactly what `trace_nuclearHamiltonian` and
`det_nuclearHamiltonian` prove for all `n`.

The characteristic polynomial for `n = 3` is
`(X-1)(X-2)(X-3) = X^3 - 6X^2 + 11X - 6`, whose roots `{1,2,3}` are the atomic
numbers, matching `charpoly_nuclearHamiltonian`.

## 2. OEIS

* Trace sequence `1, 3, 6, 10, 15, …` = triangular numbers, **A000217**.
* Determinant sequence `1, 2, 6, 24, 120, …` = factorials, **A000142**.

## 3. Counterexample hunt

The spectrum claim (`spectrum_eq_range`) was stress-tested by the two-sided proof
obligation: every diagonal entry is an eigenvalue (basis vectors are eigenstates),
and any eigenvalue `μ` must equal some entry (a nonzero eigenvector coordinate `x j`
forces `d j = μ` by cancellation). No eigenvalue outside `{1,…,n}` can occur; no
counterexample exists. The finite table above also exhibits no discrepancy in any
invariant.

## 4. Notes

All numerical rows are reproduced symbolically inside the Lean proofs (the general
`n` statements specialize to each row by `rfl`/`decide`-level evaluation), so the
table is a summary of, not a substitute for, the formal results.
