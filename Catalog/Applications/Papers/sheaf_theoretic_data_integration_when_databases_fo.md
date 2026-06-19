# Theorem Trace — Sheaf-Theoretic Data Integration

Ground-truth Lean source: `Catalog/Computation/SheafDataIntegration.lean`.
Every result below is taken verbatim from that file. No theorem appears in
ARTICLE.md or RESEARCH_PAPER.md that is not listed here.

## Definitions

| Lean name | Mathematical meaning | Article | Paper |
|---|---|---|---|
| `DBPos nRows nCols` | grid position type `Fin nRows × Fin nCols` | yes | yes |
| `PartialDB nRows nCols V` | partial database `DBPos → Option V` | yes | yes |
| `PartialDB.dom` | set of filled positions `{p | db p ≠ none}` | yes | yes |
| `ConsistentPair` | two DBs agree wherever both defined | yes | yes |
| `SheafCondition` | every pair in a family is consistent | yes | yes |
| `GluingMap` | union preferring first DB | yes | yes |
| `IsGlobalSection` | DB with no missing entry | yes | yes |
| `PartialDB.restrict` | restrict DB to a position set | no | yes |
| `disagreementAt` | pointwise 0/1 disagreement indicator | yes | yes |
| `CoboundaryNorm` | total disagreements over all pairs/positions | yes | yes |
| `overlapConstraintCount` | `n*(n-1)/2 * (nRows*nCols)` | yes | yes |
| `consistencyProbability` | `(1-r)^constraintCount` | yes | yes |
| `SheafImputationObjective` | observed-vs-candidate disagreement count | yes | yes |
| `SheafFiltration` (structure) | monotone consistent sequence of DBs | yes | yes |
| `SheafFiltration.isComplete` | final level is global section | no | yes |
| `LocallyExtends` | extends + fills at least one more cell | no | yes |
| `conjecture_exponential_decay_testable` | testable decay Prop | yes | yes |

## Theorems

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `consistent_pair_symm` | ConsistentPair is symmetric | yes | yes |
| `consistent_with_empty` | empty DB consistent with all | no | yes |
| `consistent_pair_refl` | ConsistentPair is reflexive | no | yes |
| `gluing_extends_left` | glue agrees with db1 where defined | no | yes |
| `gluing_extends_right` | glue equals db2 where db1 undefined | no | yes |
| `gluing_extends_both` | glue of consistent pair extends both | yes | yes |
| `sheaf_condition_of_global_restriction` | restrictions of a global section satisfy sheaf condition | yes | yes |
| `coboundary_zero_iff_sheaf` | CoboundaryNorm = 0 ⟺ SheafCondition | yes | yes |
| `overlap_zero_of_lt_two` | constraint count = 0 when n < 2 | no | yes |
| `overlap_quadratic_growth` | constraint count ≤ n*n*(rows*cols) | yes | yes |
| `consistency_prob_mono_constraints` | decreasing in constraint count | yes | yes |
| `consistency_prob_mono_rate` | decreasing in rate r | yes | yes |
| `consistency_prob_zero_rate` | P = 1 at r = 0 | no | yes |
| `consistency_prob_one_rate` | P = 0 at r = 1 (c > 0) | no | yes |
| `imputation_zero_iff_extends` | objective = 0 ⟺ candidate extends observed | yes | yes |
| `sheaf_filtration_auto_consistent` | monotone ⇒ consistent | yes | yes |
| `gluing_increases_domain` | db1.dom ⊆ glue.dom | no | yes |
| `gluing_preserves_right_domain` | db2.dom ⊆ glue.dom | no | yes |
| `gluing_locally_extends_of_not_contained` | glue locally extends db1 | no | yes |
| `gluing_preserves_consistency` | glue(db1,db2) consistent with db3 | yes | yes |
| `sheaf_filtration_exists_singleton` | every DB is a depth-1 filtration | no | yes |
| `filtration_final_contains_all` | final level dom contains all | yes | yes |
| `consistency_prob_mul` | P(c1+c2) = P(c1)*P(c2) | yes | yes |
| `consistency_prob_double` | P(2c) = P(c)^2 | no | yes |
| `consistency_prob_le_one` | P ≤ 1 | no | yes |
| `consistency_prob_nonneg` | 0 ≤ P | no | yes |
