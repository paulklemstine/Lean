# Computational Evidence

## Small cases

For a Boolean triangle there are `2^3 = 8` vertex assignments. Consistency requires all three values to agree. The two consistent assignments are `000` and `111`, so the consistent fraction is `2/8 = 1/4`.

| schema | raw assignments | consistent assignments | fraction |
|---|---:|---:|---:|
| one Boolean vertex | 2 | 2 | 1 |
| two Boolean vertices, one equality | 4 | 2 | 1/2 |
| three Boolean vertices, triangle equalities | 8 | 2 | 1/4 |

Treating the three triangle edges as independent conditions would instead predict `(1/2)^3 = 1/8`. The discrepancy is caused by the third equality being implied by the first two. The count `2` is kernel-checked in `boolean_triangle_consistent_count`; the logical redundancy is proved in `triangle_constraint_redundant`.

For a single-valued partial database, exhaustive completion behaves differently: every pattern of missing cells is completable by assigning arbitrary values to missing positions. This is proved uniformly, rather than sampled, by `every_partial_database_completes`.

## Counterexample hunt

The proposed formula predicts `(1-r)^C`. At `r = 1/2` and `C = 1`, this is `1/2`; mere completability of a partial function has probability `1`. The numerical inequality is formalized by `missing_rate_formula_counterexample`, while the event-level reason is `every_partial_database_completes`.

A second counterexample targets independence of overlap constraints: on a triangle, the equality on the closing edge is redundant. More generally, `pairwise_constraints_iff_anchor` proves that all pairwise equalities are equivalent to equalities against one root.

## OEIS search

No OEIS search is relevant here. The finite count used is the elementary constant count of globally equal Boolean assignments, not a newly observed integer sequence.

## Scope of the evidence

No synthetic performance benchmark is claimed. Mean, KNN, MICE, and constrained imputation require a specified data distribution, metric, hyperparameters, and tie-breaking rules. The formal result only rules out a distribution-free claim of strict superiority and proves existence of a finite constrained optimum.
