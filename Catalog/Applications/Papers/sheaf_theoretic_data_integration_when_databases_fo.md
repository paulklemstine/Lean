# Theorem Trace (internal anti-hallucination record)

Source of truth: `Catalog/Computation/SheafDataIntegration.lean`.
Every claim in ARTICLE.md and RESEARCH_PAPER.md must map to one of these.

## Definitions

| Lean name | Statement (informal) | In ARTICLE | In PAPER |
|---|---|---|---|
| `DBPos nRows nCols` | grid position `Fin nRows × Fin nCols` | yes | yes (Def 1) |
| `PartialDB nRows nCols V` | `DBPos → Option V`; `none` = missing | yes | yes (Def 2) |
| `PartialDB.dom` | set of positions with a value | — | yes (Def 2) |
| `ConsistentPair db1 db2` | agree wherever both defined | yes | yes (Def 3) |
| `SheafCondition dbs` | all pairs consistent | yes | yes (Def 4) |
| `GluingMap db1 db2` | union preferring db1 | yes | yes (Def 5) |
| `IsGlobalSection db` | no missing entries | yes | yes (Def 6) |
| `PartialDB.restrict` | restrict to position set | — | yes (Def 6) |
| `disagreementAt` | pointwise 0/1 disagreement | yes | yes (Def 7) |
| `CoboundaryNorm dbs` | total disagreements over pairs/cells | yes | yes (Def 7) |
| `overlapConstraintCount n nRows nCols` | `n(n-1)/2·(nRows·nCols)` | yes | yes (Def 8) |
| `consistencyProbability r c` | `(1-r)^c` | yes | yes (Def 9) |
| `SheafImputationObjective` | observed-vs-candidate mismatch count | yes | yes (Def 10) |
| `SheafFiltration` | monotone consistent levels | yes | yes (Def 11) |
| `SheafFiltration.isComplete` | last level is global section | — | yes (Def 11) |
| `LocallyExtends` | extends and adds ≥1 cell | — | yes (Def 12) |
| `conjecture_exponential_decay_testable` | formalized conjecture Prop | yes | yes (§ conjecture) |

## Theorems

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `consistent_pair_symm` | consistency symmetric | — | yes |
| `consistent_with_empty` | empty consistent with all | — | yes |
| `consistent_pair_refl` | consistency reflexive | — | yes |
| `gluing_extends_left` | glue agrees with db1 on its domain | — | yes |
| `gluing_extends_right` | glue = db2 where db1 missing | — | yes |
| `gluing_extends_both` | consistent glue extends both | yes | yes (Thm A) |
| `sheaf_condition_of_global_restriction` | restrictions of a global section glue | yes | yes (Thm B) |
| `coboundary_zero_iff_sheaf` | `CoboundaryNorm = 0 ↔ SheafCondition` | yes | yes (Thm C) |
| `overlap_zero_of_lt_two` | <2 dbs ⇒ 0 constraints | — | yes |
| `overlap_quadratic_growth` | constraint count ≤ n²·cells | yes | yes |
| `consistency_prob_mono_constraints` | decreasing in c | yes | yes |
| `consistency_prob_mono_rate` | decreasing in r | yes | yes |
| `consistency_prob_zero_rate` | `(1-0)^c = 1` | — | yes |
| `consistency_prob_one_rate` | `0^c = 0` (c>0) | — | yes |
| `imputation_zero_iff_extends` | objective 0 ↔ candidate extends data | yes | yes (Thm D) |
| `sheaf_filtration_auto_consistent` | monotone ⇒ consistent | yes | yes (Thm E) |
| `gluing_increases_domain` | dom(db1) ⊆ dom(glue) | — | yes |
| `gluing_preserves_right_domain` | dom(db2) ⊆ dom(glue) | — | yes |
| `gluing_locally_extends_of_not_contained` | glue strictly extends db1 | — | yes |
| `gluing_preserves_consistency` | pairwise consistent ⇒ glue consistent with 3rd | yes | yes (Thm F) |
| `sheaf_filtration_exists_singleton` | depth-1 filtration exists | — | yes |
| `filtration_final_contains_all` | last level dominates all domains | yes | yes (Thm G) |
| `consistency_prob_mul` | `(1-r)^{c1+c2}=(1-r)^{c1}(1-r)^{c2}` | yes | yes (Thm H) |
| `consistency_prob_double` | `(1-r)^{2c}=((1-r)^c)^2` | — | yes |
| `consistency_prob_le_one` | prob ≤ 1 | — | yes |
| `consistency_prob_nonneg` | prob ≥ 0 | — | yes |

No theorem appears in prose that is not in this list.
