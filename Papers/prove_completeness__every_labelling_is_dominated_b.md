# Computational Evidence — DP completeness

## The test instance

Three states `S = Fin 3`, integer weights, initial weights `init s = s`, and a
stage-independent transition matrix

```
        t=0   t=1   t=2
 s=0     2    -1     3
 s=1     1     0    -2
 s=2    -3     4     1
```

This is `exA` / `exD` in `Catalog/Logic/DPCompletenessApplications.lean`.

## Small-case calculations

Forward value function `val n t` (best score of a labelling of stages `0…n` ending in `t`):

| n | val n 0 | val n 1 | val n 2 |
|---|---------|---------|---------|
| 0 | 0       | 1       | 2       |
| 1 | 2       | 6       | 3       |
| 2 | 7       | 7       | 5       |
| 3 | 9       | 9       | 10      |
| 4 | 11      | 14      | 12      |

Two-step walk matrix `walk 0 2 s t` (best weight of three transitions — recall the `+1`
indexing convention):

```
        t=0   t=1   t=2
 s=0     8     9     7
 s=1     5     8     6
 s=2     7     6     8
```

## Counterexample hunt (brute force over all labellings)

`exBrute n t` enumerates **all** `3^(n+1)` labellings of stages `0…n`, filters those ending
in `t`, and takes the maximum score. The universal claim under test is

> `exBrute n t = exD.val n t` for every `n` and every `t`,

which is the concrete instance of the exactness/completeness theorem
(`DPSpec.isGreatest_val`). No counterexample was found. For `n ≤ 3` (81 labellings at `n = 3`)
this is **verified inside Lean's kernel** by the theorem

```lean
theorem exBrute_eq_val : ∀ n ∈ [0, 1, 2, 3], ∀ t : Fin 3, exBrute n t = exD.val n t := by decide
```

in `Catalog/Logic/DPCompletenessApplications.lean`. The `n = 4` row of the table above was
additionally cross-checked against brute force during exploration (243 labellings); that check
is exploratory only and is not part of the verified artifact.

Similarly, the transfer identity `val (k+m+1) = val k ⊗ walk k m` (max-plus product) of
`Catalog/Logic/DPCompletenessWalks.lean` is kernel-checked at `k = 1, m = 2` by
`exD_val_add`.

## OEIS

The value sequence at endpoint `1` for this arbitrary hand-picked matrix is
`1, 6, 7, 9, 14, …`; it is an artifact of the chosen weights and carries no arithmetic
significance, so no OEIS identification is claimed.

## What the evidence supports

* Completeness/exactness is *tight*: brute force never beats the DP, and the DP value is always
  achieved by an actual labelling (a backtrace).
* Bellman's prefix-optimality is visible in the data: the optimal labelling ending at `t` at
  stage `n` always extends an optimal labelling at stage `n-1`. This is the content of
  `isDPRun_of_score_eq_val`, and its proof genuinely needs cancellativity of the weight monoid;
  a non-cancellative weight monoid (e.g. adjoining an absorbing `⊥`) breaks the argument, which
  is why the hypothesis `IsOrderedCancelAddMonoid` appears in that theorem and not in the
  domination bound `score_le_val`.

## Constrained instance: maximum-weight independent set on a path

Weights `3, 7, 2, 8, 1` on the path `0—1—2—3—4`; state = "is this vertex selected?", and
selecting two adjacent vertices carries the absorbing weight `⊥` of `WithBot ℤ`.

| independent set | weight |
|-----------------|--------|
| {1, 3}          | **15** |
| {0, 3}          | 11     |
| {0, 2, 4}       | 6      |
| {1, 4}          | 8      |
| {0, 3} ∪ …      | —      |

The DP optimum `max (val 4 true) (val 4 false) = 15` is kernel-checked by `misD_optimum`
in `Catalog/Logic/DPCompletenessConstrained.lean`, and `misD_adjacent_infeasible` proves that
every labelling selecting two consecutive vertices really does score `⊥`.

This instance is the reason for the second cycle of work: `WithBot ℤ` is **not** a cancellative
monoid, so the first version of the completeness theorem did not apply to it. Replacing the
semantic notion of a DP run by the structural backtrace notion removes the hypothesis
(`dp_complete_general`), and the two notions are proved equivalent in general
(`isBacktrace_iff_isDPRun`).
