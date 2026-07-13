# Computational Evidence: Topological Structure of Proof DAGs

We model a proof dependency network as a relation `R` on a finite vertex type,
where `R a b` means "statement `a` is directly used to prove statement `b`".
Acyclicity ("no circular argument") is `IsAcyclic R := ∀ v, ¬ TransGen R v v`.

## 1. Rank = number of strict ancestors

The topological numbering uses `f v = |{u : TransGen R u v}|` (the predecessor
count). Small cases confirm monotonicity along edges:

- **Path** `1 → 2 → 3`: predecessor sets are `∅, {1}, {1,2}`, so ranks `0,1,2`.
  Every edge strictly increases rank. ✓
- **Diamond** `1→2, 1→3, 2→4, 3→4`: ranks `0,1,1,3`. Every edge increases rank. ✓
- **2-cycle** `1→2, 2→1`: `TransGen R 1 1` holds, so `IsAcyclic` fails — correctly
  excluded. ✓

## 2. Source / sink existence

Minimizing `f` yields a source (no incoming edge); maximizing yields a sink.
Checked on the path and diamond above: source `= 1`, sink `= 3` (path) / `= 4`
(diamond). ✓

## 3. Edge-count bound `2|E| ≤ n(n-1)`

The bound is the number of ordered pairs with distinct ranks split in half.

| n | max acyclic edges = C(n,2) | 2·C(n,2) | n(n-1) |
|---|---|---|---|
| 2 | 1 | 2 | 2 |
| 3 | 3 | 6 | 6 |
| 4 | 6 | 12 | 12 |
| 5 | 10 | 20 | 20 |

The transitive tournament (total order `f a < f b`) attains the bound, confirming
it is tight. No acyclic relation on `n` vertices was found exceeding `C(n,2)`
edges (a counterexample would require a directed cycle, contradicting acyclicity).

## 4. OEIS

The maximal edge counts `1, 3, 6, 10, 15, …` are the triangular numbers
`C(n,2)` = OEIS A000217 (offset). No new sequence arises; the evidence simply
confirms the closed form used in `IsAcyclic.two_mul_edgeCount_le`.

All claims above are proved formally in `TopologicalOrder.lean`.
