# Computational Evidence: Emergent Fixed Point as Limit of Finite Stages

This note records the small-case evidence that guided the formal development in
`EmergentFixedPointKleene.lean`.

## 1. Reachability operator on subsets of ℕ

Operator: `reach S = {0} ∪ (succ '' S)`, starting from `∅`.

| stage n | value               |
|---------|---------------------|
| 0       | ∅                   |
| 1       | {0}                 |
| 2       | {0,1}               |
| 3       | {0,1,2}             |
| n       | {0,1,…,n-1}         |
| limit   | {0,1,2,…} = ℕ (univ)|

The stages are exactly the initial segments, so the supremum is all of `ℕ`.
This matches the theorem `emergent reach = Set.univ`, and `reach` is continuous,
so by the Kleene theorem the emergent state is the least fixed point (indeed the
only fixed point of a reachability closure).

## 2. Identity operator

`id S = S` from `⊥ = ∅` gives every stage `∅`; emergent state `∅ = ⊥`, the least
fixed point. Confirms the degenerate case.

## 3. Discontinuity boundary on `WithTop (WithTop ℕ)`

Levels: `0 < 1 < 2 < ⋯ < ω < ω+1`, with `ω = some ⊤`, `ω+1 = ⊤ = none`.

Operator `gapMap`: finite `n ↦ n+1`, `ω ↦ ω+1`, `ω+1 ↦ ω+1`.

| stage n | value |
|---------|-------|
| 0       | 0     |
| 1       | 1     |
| n       | n     |
| limit   | ω     |

- Emergent state `⨆ n, n = ω`.
- Fixed points: only `ω+1` (checked by cases: `gapMap ω = ω+1 ≠ ω`, `gapMap n =
  n+1 ≠ n`).
- Least fixed point `= ω+1`.

Hence `emergent = ω < ω+1 = lfp`: a **strict gap**. The gap is precisely the
failure of continuity — `gapMap (⨆ n) = gapMap ω = ω+1`, while `⨆ gapMap n = ⨆
(n+1) = ω`. This counterexample hunt confirmed that the continuity hypothesis in
the Kleene approximation theorem cannot be dropped.

## 4. OEIS / external signals

The finite stages of the reachability operator are the initial segments
`{0,…,n-1}` of cardinality `n` (A000027-indexed), a purely structural sequence;
no nontrivial integer sequence is involved, so no OEIS match was pursued. The
domain-theoretic Kleene approximation (least fixed point as supremum of
`fⁿ(⊥)`) is a classical target of synthetic/effective domain theory, motivating
the choice of a monotone-but-discontinuous witness on stacked limit levels.
