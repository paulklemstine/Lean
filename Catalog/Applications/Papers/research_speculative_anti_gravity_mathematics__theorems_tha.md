# Sheaf-Theoretic Data Integration: A Verified Discrete Sheaf Model of Database Consistency, Gluing, and Imputation

**Author:** Aristotle

**Date:** 2026-06-19

## Abstract

We develop a discrete, finite, and fully formalized model in which a database
with missing entries is a *partial section* of the sheaf of `V`-valued functions
on a grid of cells, and the classical problem of *consistent imputation* — filling
in missing data without contradicting what is observed — is exactly the
sheaf-theoretic problem of *gluing* compatible local sections into a global one.
We make four contributions. First, we give precise definitions of partial
databases, pairwise consistency (the discrete sheaf overlap condition), gluing,
and global sections. Second, we prove the central structural theorem that the
gluing of two consistent partial databases faithfully extends *both* of them
(`gluing_extends_both`), together with the closure property that gluing preserves
consistency with third parties (`gluing_preserves_consistency`), which together
license incremental, source-by-source integration. Third, we introduce a discrete
**coboundary norm** that counts pairwise overlap disagreements and prove the
keystone equivalence that it vanishes *if and only if* the family satisfies the
sheaf condition (`coboundary_zero_iff_sheaf`) — a finite analogue of
`ker(δ⁰) = H⁰`. Fourth, we recast imputation as an optimization problem whose
optimum is characterized exactly (`imputation_zero_iff_extends`), analyze the
exponential decay of consistency probability under independent noise, and
introduce a novel **sheaf filtration** structure modelling progressive
imputation, for which we prove that monotonicity (information-only growth)
*automatically* implies global consistency (`sheaf_filtration_auto_consistent`).
All results are machine-verified.

**Keywords:** sheaf condition, gluing, partial database, data imputation, Čech
coboundary, consistency, filtration, missing data, cross-domain bridge.

---

## 1. Introduction

Missing data is ubiquitous. In practice it is handled by *imputation* — mean
substitution, k-nearest-neighbor copying, model-based prediction, multiple
imputation. These methods operate **locally**: they fill each hole using nearby
information, without first verifying that the partial views being combined are
mutually consistent. This is a structural blind spot. When data arrives as
overlapping fragments (different exports, sensors, joins), the prior question is
not "what value goes in this hole?" but "do the fragments even agree where they
overlap?" That prior question is precisely the question a *sheaf* is designed to
answer.

A sheaf, in its classical form, assigns data to open sets of a space and specifies
when locally-defined data can be glued into globally-defined data. The **sheaf
condition** (gluing axiom) states that a family of local sections agreeing on
overlaps determines a unique global section. We show that the function sheaf model
of a database makes this axiom *concrete and finite*: overlaps are shared cells,
agreement is value equality, and gluing is an explicit merge. The payoff is a
rigorous vocabulary in which "consistent imputation exists" becomes a theorem
rather than a hope, and "how inconsistent is this data?" becomes a number rather
than a feeling.

### Contributions

1. A discrete sheaf model of databases (Section 3): partial databases,
   consistency, gluing, global sections, restriction.
2. Structural gluing theory (Section 4): `gluing_extends_both`,
   `gluing_preserves_consistency`, and local-extension results.
3. A homological measure of inconsistency (Section 5): the coboundary norm and
   the equivalence `coboundary_zero_iff_sheaf`.
4. Imputation as optimization (Section 6) with the exact optimality
   characterization `imputation_zero_iff_extends`.
5. A probabilistic theory of consistency decay (Section 7).
6. A novel **sheaf filtration** for progressive imputation (Section 8) with the
   structural result `sheaf_filtration_auto_consistent`.

All statements below are formalized and verified; proof sketches convey the
mathematical content.

---

## 2. Related Frameworks and Positioning

The use of sheaves and cellular cohomology to model networked and relational data
has emerged as "topological data analysis" and "cellular sheaf theory." Our
contribution is deliberately elementary and constructive: rather than building the
full cohomological apparatus, we isolate the *0-th level* — sections, overlaps,
gluing, and the degree-0 coboundary — in a finite setting where every claim is
decidable and machine-checkable. This makes the database/sheaf dictionary
*literal*: each definition is a function on a finite grid, and each theorem is an
exact statement about merges and disagreements that an engineer can compute.

---

## 3. The Discrete Sheaf Model of a Database

Fix natural numbers `nRows, nCols` and a value type `V`.

**Definition 3.1 (Grid position).** A position is a pair
`DBPos nRows nCols := Fin nRows × Fin nCols`.

**Definition 3.2 (Partial database).** A partial database is a function
`db : DBPos nRows nCols → Option V`. A position `p` is *observed* if
`db p ≠ none` and *missing* otherwise. The **domain** is
`db.dom := { p | db p ≠ none }`.

**Definition 3.3 (Global section).** `db` is a global section, written
`IsGlobalSection db`, if `db p ≠ none` for every `p`. Equivalently, the domain is
the whole grid.

**Definition 3.4 (Restriction).** For a set `S` of positions (with decidable
membership), `db.restrict S` equals `db` on `S` and `none` off `S`. This is the
sheaf restriction map to the "open set" `S`.

**Definition 3.5 (Consistent pair).** Two partial databases `db1, db2` are
*consistent*, written `ConsistentPair db1 db2`, if for every position `p` and all
values `v1, v2`, `db1 p = some v1` and `db2 p = some v2` imply `v1 = v2`. This is
the discrete overlap-agreement (Čech 0-cocycle) condition.

**Definition 3.6 (Sheaf condition).** A family `dbs : ι → PartialDB nRows nCols V`
satisfies the **sheaf condition**, `SheafCondition dbs`, if `ConsistentPair (dbs i)
(dbs j)` for all `i, j`.

**Definition 3.7 (Gluing).** The gluing `GluingMap db1 db2` is defined pointwise:
return `db1 p` if it is `some _`, else return `db2 p`.

These definitions form the dictionary:

| Sheaf theory | Database |
|---|---|
| base space / site | grid of cells |
| open set `U` | set of positions `S` |
| section over `U` | partial database with domain in `S` |
| restriction map | `PartialDB.restrict` |
| overlap agreement | `ConsistentPair` |
| gluing axiom | `gluing_extends_both` |
| global section | complete table (`IsGlobalSection`) |
| degree-0 coboundary | `CoboundaryNorm` |

---

## 4. Structural Theory of Consistency and Gluing

**Proposition 4.1 (`consistent_pair_symm`).** If `ConsistentPair db1 db2` then
`ConsistentPair db2 db1`.
*Proof sketch.* Swap the roles of the two values in the hypothesis and apply
symmetry of equality. ∎

**Proposition 4.2 (`consistent_pair_refl`).** `ConsistentPair db db` for all `db`.
*Proof sketch.* If `db p = some v1` and `db p = some v2`, then `some v1 = some v2`,
hence `v1 = v2` by injectivity of `some`. ∎

**Proposition 4.3 (`consistent_with_empty`).** The empty database `fun _ => none`
is consistent with every `db`.
*Proof sketch.* The hypothesis `(fun _ => none) p = some v1` is impossible, so the
implication holds vacuously. ∎

**Lemma 4.4 (`gluing_extends_left`).** If `db1 p = some v` then
`GluingMap db1 db2 p = some v`.
*Proof sketch.* Unfold `GluingMap` and rewrite by `db1 p = some v`; the first
branch fires. ∎

**Lemma 4.5 (`gluing_extends_right`).** If `db1 p = none` then
`GluingMap db1 db2 p = db2 p`.
*Proof sketch.* Unfold and rewrite; the fallback branch fires. ∎

**Theorem 4.6 (Gluing extends both, `gluing_extends_both`).** If
`ConsistentPair db1 db2`, then (i) every value of `db1` is preserved in the
gluing, and (ii) every value of `db2` is preserved in the gluing.
*Proof sketch.* Part (i) is Lemma 4.4. For (ii), suppose `db2 p = some v`. Case on
`db1 p`. If `db1 p = some v1`, consistency gives `v1 = v`, so the gluing returns
`some v1 = some v`. If `db1 p = none`, the gluing returns `db2 p = some v` by
Lemma 4.5. ∎

This is the finite gluing axiom: *compatible local sections assemble into a section
faithful to all of them.* The asymmetric construction is symmetric in effect
precisely because consistency forbids the only way it could differ.

**Theorem 4.7 (Gluing preserves consistency, `gluing_preserves_consistency`).** If
`db1, db2, db3` are pairwise consistent, then
`ConsistentPair (GluingMap db1 db2) db3`.
*Proof sketch.* Take `p` with `(GluingMap db1 db2) p = some v1` and
`db3 p = some v2`. Case on `db1 p`. If `db1 p = some v`, then `v1 = v` and
consistency of `db1, db3` gives `v = v2`. If `db1 p = none`, the gluing value came
from `db2`, and consistency of `db2, db3` gives `v1 = v2`. ∎

**Consequence (incremental integration).** Theorems 4.6 and 4.7 together justify
folding a family of pairwise-consistent sources one at a time: each absorption
preserves both faithfulness (4.6) and future compatibility (4.7), so an
`n`-source integration is a linear sequence of binary merges.

**Theorem 4.8 (Easy direction of the correspondence,
`sheaf_condition_of_global_restriction`).** For any single database `g` and any
family of position-sets `S : ι → Set (DBPos …)`, the restrictions
`fun i => g.restrict (S i)` satisfy the sheaf condition.
*Proof sketch.* Two restrictions of one `g` can only output values that equal
`g`'s value at the shared position, so they cannot disagree. ∎ This is the
statement that *global sections always glue locally* — restriction lands in the
equalizer.

**Definition 4.9 (Local extension, `LocallyExtends`).** `db_ext` locally extends
`db` if it agrees with `db` on every observed position and observes at least one
position `db` left missing.

**Theorem 4.10 (`gluing_locally_extends_of_not_contained`).** If `db1, db2` are
consistent and `db2` observes some cell `db1` does not, then `GluingMap db1 db2`
locally extends `db1`.
*Proof sketch.* Faithfulness on `db1`'s domain is Lemma 4.4; the witnessing extra
cell comes from `db2` via Lemma 4.5. ∎

---

## 5. Homological Measurement of Inconsistency

**Definition 5.1 (Disagreement indicator, `disagreementAt`).** For `[DecidableEq
V]`, define `disagreementAt db1 db2 p = 1` if both `db1 p` and `db2 p` are observed
and unequal, and `0` otherwise.

**Definition 5.2 (Coboundary norm, `CoboundaryNorm`).** For a finite family
`dbs : Fin n → PartialDB nRows nCols V`,
`CoboundaryNorm dbs := Σ_{i,j} Σ_{r,c} disagreementAt (dbs i) (dbs j) (r,c)`.
This is the `ℓ¹`-norm of the discrete degree-0 Čech coboundary.

**Theorem 5.3 (Keystone: `coboundary_zero_iff_sheaf`).**
`CoboundaryNorm dbs = 0 ↔ SheafCondition dbs`.
*Proof sketch.* A finite sum of natural numbers is zero iff every summand is zero.
Forward: zero norm forces every `disagreementAt (dbs i)(dbs j)(r,c) = 0`; at any
position where both are observed this indicator can only be `0` if the values are
equal, giving `ConsistentPair`. Backward: the sheaf condition makes every
both-observed pair equal, so each indicator is `0`, hence the sum is `0`. ∎

Theorem 5.3 is the bridge's spine: the *algebraic* event "a single number is zero"
coincides with the *geometric* event "all local pieces glue." It is the finite,
decidable analogue of the classical identity that the kernel of the degree-0
coboundary is the space of global sections, `ker(δ⁰) = H⁰`.

---

## 6. Imputation as Optimization

**Definition 6.1 (Imputation objective, `SheafImputationObjective`).** Given an
observed partial database and a *candidate* complete assignment
`candidate : DBPos → V`, define the cost as the number of observed positions where
`candidate` disagrees with the observation:
`Σ_{r,c} [observed (r,c) = some v ∧ v ≠ candidate (r,c)]`.

**Theorem 6.2 (Optimality characterization, `imputation_zero_iff_extends`).** The
objective equals `0` iff for every observed position `p` with value `v`,
`candidate p = v`.
*Proof sketch.* The objective is a sum of nonnegative terms; it is zero iff each
term is zero, and the term at `(r,c)` is zero exactly when there is no observed
value there or the candidate matches it. ∎

Thus the global minimizers of the imputation objective are exactly the *faithful
extensions* of the observed data — global sections restricting to the observed
partial section. This reframes imputation as: among all completions, find one of
cost `0` (a faithful extension) and then choose among them by a secondary
criterion (smoothness, likelihood, sparsity). The theorem also explains a known
failure mode: column-mean and KNN imputation do not optimize this objective and
can overwrite observed values implied by overlaps.

---

## 7. The Probability of Consistency

**Definition 7.1 (Overlap constraint count, `overlapConstraintCount`).** For `n`
sources on an `nRows × nCols` grid, `overlapConstraintCount n nRows nCols :=
(n(n-1)/2)·(nRows·nCols)`: one agreement constraint per unordered pair of sources,
across all cells.

**Proposition 7.2 (`overlap_zero_of_lt_two`).** With fewer than two sources the
constraint count is `0` (no pairs to compare).

**Proposition 7.3 (Quadratic growth, `overlap_quadratic_growth`).**
`overlapConstraintCount n nRows nCols ≤ n²·(nRows·nCols)`.
*Proof sketch.* `n(n-1)/2 ≤ n(n-1) ≤ n²`, then multiply through. ∎

**Definition 7.4 (Consistency probability, `consistencyProbability`).** With
per-constraint independent disagreement rate `r` and `C` constraints,
`consistencyProbability r C := (1 - r)^C`.

The following are all verified:

- **Monotone in constraints (`consistency_prob_mono_constraints`).** For
  `0 ≤ r ≤ 1` and `c1 ≤ c2`, `(1-r)^{c2} ≤ (1-r)^{c1}`.
- **Monotone in rate (`consistency_prob_mono_rate`).** For `r1 ≤ r2 ≤ 1`,
  `(1-r2)^c ≤ (1-r1)^c`.
- **Boundary values.** `consistencyProbability 0 c = 1`
  (`consistency_prob_zero_rate`) and, for `c > 0`,
  `consistencyProbability 1 c = 0` (`consistency_prob_one_rate`).
- **Range.** `0 ≤ (1-r)^c ≤ 1` for `0 ≤ r ≤ 1` (`consistency_prob_nonneg`,
  `consistency_prob_le_one`).
- **Multiplicative composition (`consistency_prob_mul`).**
  `(1-r)^{c1+c2} = (1-r)^{c1}·(1-r)^{c2}`; doubling squares
  (`consistency_prob_double`).

**Interpretation.** Composition (the law `(1-r)^{c1+c2} = (1-r)^{c1}(1-r)^{c2}`)
is the mathematical reason consistency decays *exponentially* in the constraint
count: independent constraints multiply. Combined with the quadratic growth of the
constraint count (7.3), spontaneous consistency of large, noisy, multi-source data
is astronomically unlikely — e.g. for `n=10`, `k=100`, `r=0.3` the constraint
count is in the thousands and `(0.7)^{thousands} ≈ 10^{-700}`. The practical
corollary is that consistency must be *engineered* via gluing, not hoped for.

**Conjecture 7.5 (Exponential consistency decay, `conjecture_exponential_decay_testable`).**
For all `n ≥ 2`, `k ≥ 1`, and `0 < r < 1`, the all-pairs overlap model is strictly
harder to satisfy than the single-column-pass model:
`consistencyProbability r (overlapConstraintCount n k n) <
consistencyProbability r (k·n)`. This is stated as a falsifiable predicate: it
asserts the all-pairs constraint count strictly exceeds `k·n` in the regime of
interest, making consistency strictly less probable.

---

## 8. Progressive Imputation: The Sheaf Filtration

Real imputation is iterative. We model it with a structure borrowed from
homological algebra.

**Definition 8.1 (Sheaf filtration, `SheafFiltration`).** A sheaf filtration of
depth `d` consists of:
- a sequence `level : Fin d → PartialDB nRows nCols V`;
- **monotonicity**: for `i ≤ j`, every value observed at level `i` is observed
  (with the same value) at level `j` — information is never erased or altered;
- **consistency**: `SheafCondition level` holds.

**Definition 8.2 (Completeness, `SheafFiltration.isComplete`).** A filtration is
complete (given `0 < d`) if its final level is a global section.

**Theorem 8.3 (Monotone ⇒ consistent, `sheaf_filtration_auto_consistent`).** Any
sequence of partial databases in which each level extends the previous one
automatically satisfies the sheaf condition.
*Proof sketch.* Given indices `i, j`, assume WLOG `i ≤ j` (else swap). At any
position both observe, monotonicity forces `level j`'s value to equal `level i`'s,
so they cannot disagree. ∎

Theorem 8.3 is the design principle of safe imputation pipelines: **if a pipeline
only ever adds values and never overwrites, it can never create a contradiction.**
The expensive global sheaf check reduces to a local, per-step discipline.

**Theorem 8.4 (Information accumulates, `filtration_final_contains_all`).** In any
filtration of positive depth, the domain of every level is contained in the domain
of the final level.
*Proof sketch.* Apply monotonicity from index `i` up to the last index `d-1`. ∎

**Proposition 8.5 (Base case, `sheaf_filtration_exists_singleton`).** Every single
partial database is the unique level of a depth-1 filtration.
*Proof sketch.* Constant sequence; monotonicity and consistency are trivial. ∎

Together these show filtrations form a well-behaved category of imputation
processes: they start from any fragment (8.5), grow monotonically without losing
information (8.4), and are consistent by construction (8.3).

---

## 9. Algorithms

**Algorithm A — Pairwise consistency check.** Iterate over all cells; for each
shared observed cell across each source pair, compare values; report the first
disagreement or `consistent`. Cost `O(n² · nRows · nCols)`. Correctness is exactly
Definition 3.5 / 3.6; a `0` result certifies `SheafCondition` by Theorem 5.3.

**Algorithm B — Sequential gluing (data integration).** Fold the gluing operator
across pairwise-consistent sources. By Theorems 4.6 and 4.7 the running merge stays
faithful and consistent, so an `n`-source merge costs `O(n · nRows · nCols)` after
the consistency check.

**Algorithm C — Coboundary norm.** Sum `disagreementAt` over all pairs and cells;
the result is `0` iff the data glues (Theorem 5.3), and otherwise quantifies the
amount of repair needed. Cost `O(n² · nRows · nCols)`.

**Algorithm D — Monotone (filtration) imputation.** Maintain a current partial
database; at each step add new values without overwriting existing ones. By
Theorem 8.3 the resulting sequence is automatically a sheaf filtration, so no
consistency check is needed between steps; by Theorem 8.4 no information is lost.

---

## 10. Applications

- **Database/record merging.** The gluing theorems give a correctness guarantee
  for entity resolution merges: consistent records combine without loss.
- **Sensor fusion.** Overlapping sensor coverage is exactly an overlap of local
  sections; the coboundary norm is a principled fusion-discrepancy metric.
- **Federated and multi-source ETL.** Sequential gluing (Algorithm B) is a
  verified incremental integration strategy.
- **Imputation quality auditing.** Theorem 6.2 gives a crisp acceptance test:
  an imputation is *admissible* iff its cost is `0` (it preserves observations).
- **Pipeline design.** Theorem 8.3 turns global consistency into a local "never
  overwrite" coding discipline.

---

## 11. Discussion and Limitations

Our model captures *degree-0* sheaf phenomena exactly: sections, overlaps, gluing,
and the degree-0 coboundary. It deliberately stops short of higher cohomology;
genuine `H¹` obstructions (where pairwise consistency holds but no global section
exists) require open covers more intricate than the function sheaf's, whose
sections are honest total functions and thus need only pairwise compatibility.
This is a feature for databases — pairwise checks suffice — but a limitation as a
model of general sheaf cohomology. Extending to cellular sheaves with nontrivial
restriction maps (e.g. unit conversions, schema transformations between sources)
is the natural next step and would make `H¹` genuinely appear.

---

## 12. Future Work

- **Higher cohomology and genuine obstructions.** Move from the function sheaf to
  cellular sheaves with nontrivial restriction maps so that pairwise-but-not-global
  consistency (`H¹ ≠ 0`) can occur and be measured.
- **Weighted / probabilistic coboundary.** Replace the `0/1` disagreement
  indicator with a metric on `V` to obtain a quantitative inconsistency norm and a
  least-squares sheaf imputation.
- **Sharpening Conjecture 7.5** into a tight comparison and connecting the
  consistency-probability law to phase transitions in random constraint
  satisfaction.
- **Optimal repair.** Given a nonzero coboundary norm, compute the minimum number
  of cell edits restoring the sheaf condition (a verified minimal-`H¹` repair).

---

## 13. Conclusion

We have shown — with fully machine-verified proofs — that the everyday problem of
merging and completing data with missing entries is, in a precise and literal
sense, the sheaf-theoretic problem of gluing compatible local sections. The
dictionary is exact: overlaps are shared cells, compatibility is value agreement,
gluing is merging, inconsistency is a coboundary, and progressive imputation is a
filtration. The keystone equivalence `coboundary_zero_iff_sheaf` ties the
algebraic and geometric pictures together, the gluing theorems license correct
incremental integration, and the filtration result reduces global consistency to a
local discipline. A structure invented to understand the topology of spaces turns
out to be the right language for the integrity of data.
