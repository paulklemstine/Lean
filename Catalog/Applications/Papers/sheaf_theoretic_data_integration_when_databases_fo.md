# Computational Evidence — Sheaf-Theoretic Data Integration (Colimit Layer)

Evidence gathered before/while formalizing `Computation/SheafDatabaseColimit.lean`.
All claims below are now machine-checked Lean theorems; this file records the
small-case sanity checks that motivated and validated them.

## 1. Gluing is order-dependent exactly when the pair is inconsistent

Model partial DBs over a 2-cell grid (`Bool` positions), values in `ℕ`,
`GluingMap` = first-wins merge.

* **Inconsistent pair** `a = {true ↦ 1}`, `b = {true ↦ 2}` (disagree on cell `true`):

  `(GluingMap a b) true = some 1`  vs  `(GluingMap b a) true = some 2`
  → `#eval` yields `(some 1, some 2)`. Order matters.

  This witnesses that the consistency hypothesis in
  `gluing_comm_of_consistent` is **load-bearing**, not decorative.

* **Consistent pair** `c = {true ↦ 5}`, `d = {true ↦ 5, false ↦ 9}` (agree on overlap `true`):

  `GluingMap c d` and `GluingMap d c` agree on both cells
  (`true ↦ some 5`, `false ↦ some 9`) → `#eval` of `(... false, ... false)`
  yields `(some 9, some 9)`. Order-independent, as `gluing_comm_of_consistent` predicts.

## 2. Idempotence

`GluingMap a a = a` checked pointwise (`#eval (gl a a true, a true) = (some 1, some 1)`),
matching `gluing_idem`.

## 3. Order-theoretic structure (no counterexamples found)

The `Extends` relation was tested for the partial-order laws on small random
2×2 `Option`-databases:
* reflexivity / transitivity hold trivially;
* antisymmetry: two databases extending each other always coincided cell-by-cell
  (no counterexample among the enumerated small cases) — formalized as
  `extends_antisymm`.

## 4. Colimit = least common extension

For families `dbs : Fin k → PartialDB` with `k ≤ 3` and ≤4 cells, the cell-wise
"some member that has a value" construction `glueFamily`:
* extends every member whenever the family is pairwise consistent;
* is dominated by every other common extension (it never invents a cell that no
  member fills) — `glueFamily_eq_none_iff`, `glueFamily_is_lub`.

Sampling pairwise-consistent families produced a common extension every time;
sampling families with a single overlap disagreement produced **no** common
extension — consistent with the headline iff `sheaf_iff_common_extension`.

## OEIS

No integer sequence is central to this colimit/order layer (the objects are
order-theoretic rather than enumerative). The companion catalog file
`Bridges/SheafImputationProbability.lean` already isolates the relevant counting
exponent `C(k,2)` (OEIS A000217, triangular numbers, shifted), so no new
sequence search was warranted here.
