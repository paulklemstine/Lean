# Computational Evidence

Concise numerical checks supporting the results in `ResolutionRestriction.lean`
and `SeparationBridge.lean`.

## 1. Pigeonhole instances `PHP n`

| n | pigeons | holes | pigeon clauses | hole clauses | total clauses |
|---|---------|-------|----------------|--------------|---------------|
| 1 | 2       | 1     | 2              | 2            | 4             |
| 2 | 3       | 2     | 3              | 12           | 15            |
| 3 | 4       | 3     | 4              | 36           | 40            |
| 4 | 5       | 4     | 5              | 80           | 85            |

(Pigeon clauses: `n+1`. Hole clauses: `n · (n+1) · n` ordered distinct pairs per
hole = `n²(n+1)`.) Each instance was confirmed unsatisfiable; this is the content
of `PHP_unsat`, re-derived through the cutting-planes counting argument in
`php_refuted_by_cutting_planes`.

## 2. Restriction preserves unsatisfiability — sampled check

For `PHP 2` (3 pigeons, 2 holes, 6 variables) we sampled partial restrictions
`ρ` that fix `k = 0,1,2,3` variables to arbitrary values. In every sampled case
the restricted formula `(PHP 2).restrict ρ` had **no** satisfying assignment over
its free variables, matching `PHP_restrict_unsat`. The single structural reason:
fixing a pigeon to a hole only deletes options; it never creates the extra hole
that would be needed for three pigeons. No counterexample was found, consistent
with the proved theorem `restrict_preserves_unsat`.

## 3. Counting refutation slack `(n+1) − n`

For any 0/1 placement satisfying the row lower bounds (`≥ 1` per pigeon) and the
column upper bounds (`≤ 1` per hole), summing all entries gives a value that is
simultaneously `≥ n+1` (rows) and `≤ n` (columns). The contradiction has slack
exactly `1` for every `n`, independent of the placement — the linear,
`O(n)`-step refutation captured by `php_cp_counting` and bridged from the CNF in
`php_refuted_by_cutting_planes`.

## 4. Counterexample hunt

- Searched for a clause derivable from the empty axiom set: none exists
  (`not_derivable_nil`), as expected since there is no base clause to start from.
- Searched for a restriction making `PHP n` satisfiable for `n ≤ 3`: none found,
  matching `restrict_preserves_unsat`.

No counterexamples to any stated theorem were found; all checks are consistent
with the machine-verified proofs.
