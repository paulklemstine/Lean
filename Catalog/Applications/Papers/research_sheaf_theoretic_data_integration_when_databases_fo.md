# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Cryptography / Data Integration / Applied Sheaf Theory

## Abstract

We develop a discrete, elementary theory of data integration in which a
database with missing entries is modeled as a *partial section* of a sheaf over
a grid of (row, column) positions. The sheaf condition — that partial sections
agreeing on their overlaps can be glued into a global section — becomes the
exact condition for consistent imputation of missing data. We give precise
definitions of partial databases, pairwise consistency, gluing, and a discrete
*coboundary norm* that measures total inconsistency across overlapping pairs. Our
central bridge theorem establishes that the coboundary norm vanishes if and only
if the sheaf condition holds, the discrete analogue of `ker(δ⁰) = H⁰`. We
characterize optimal imputation as the vanishing of an imputation objective
(zero cost iff faithful extension), prove that gluing extends both consistent
inputs and preserves consistency with third parties, and introduce a novel
**sheaf filtration** structure modeling progressive imputation, for which
monotonicity automatically implies consistency. Finally, we formulate a
quantitative *consistency probability* model `P = (1 − r)^C` and prove its
monotonicity, multiplicativity, and boundary behavior, leading to a falsifiable
conjecture of exponential consistency decay in the number of overlap
constraints. All results have been formally verified.

---

## 1. Introduction

Missing data is ubiquitous. Classical imputation methods — mean imputation,
k-nearest-neighbors (KNN), and multivariate imputation by chained equations
(MICE) — treat the completion of an incomplete table as a statistical
prediction problem, filling each gap with a plausible value. What these methods
systematically ignore is the *consistency structure* of the data: when several
overlapping sources, or several feature subsets, jointly constrain the same
cells, there are global compatibility conditions that any honest completion must
respect.

Sheaf theory is the branch of mathematics built precisely to manage the passage
from local data to global data. A sheaf assigns to each open set a collection of
"sections" (local data) together with restriction maps, subject to the *gluing
axiom*: a family of local sections that agree on overlaps determines a unique
global section. This is exactly the structure latent in data integration. A
partial database is local data; two sources are compatible when they agree on
the cells they share; and a complete, consistent database is a global section.

This paper makes that correspondence rigorous in an elementary, fully
constructive setting that avoids the heavy categorical machinery of abstract
sheaf theory while retaining its conceptual content. We work over a finite grid,
model missing entries with an option type, and prove a self-contained suite of
theorems. The contributions are:

1. A precise discrete model of partial databases, consistency, and gluing
   (Section 3), with the basic algebraic properties of consistency.
2. A discrete coboundary norm and the bridge theorem
   `coboundary_zero_iff_sheaf` connecting algebraic inconsistency to the sheaf
   condition (Section 5).
3. A characterization of optimal imputation, `imputation_zero_iff_extends`
   (Section 7).
4. A novel sheaf-filtration structure modeling progressive imputation, with
   `sheaf_filtration_auto_consistent` (Section 8).
5. A quantitative consistency-probability model with proved monotonicity and
   multiplicativity, and a falsifiable exponential-decay conjecture
   (Section 6, Section 9).

---

## 2. Preliminaries and Notation

We fix natural numbers `nRows`, `nCols` and a value type `V`. A **position** is
a pair `p = (r, c)` with `r : Fin nRows`, `c : Fin nCols`; the set of positions
is `DBPos nRows nCols := Fin nRows × Fin nCols`.

We use the option type `Option V`, whose elements are `none` (no value) and
`some v` for `v : V`. Missing entries are `none`.

---

## 3. Partial Databases, Consistency, and Gluing

**Definition 3.1 (Partial database).** A *partial database* is a function
```
PartialDB nRows nCols V := DBPos nRows nCols → Option V.
```
Its **domain** is the set of filled positions,
`db.dom := { p | db p ≠ none }`.

**Definition 3.2 (Global section).** A partial database `db` is a *global
section* if it has no missing entries: `IsGlobalSection db := ∀ p, db p ≠ none`.

**Definition 3.3 (Restriction).** For a decidable subset `S` of positions, the
*restriction* `db.restrict S` sends `p` to `db p` if `p ∈ S` and to `none`
otherwise.

**Definition 3.4 (Consistency).** Two partial databases `db1`, `db2` are
*consistent*, written `ConsistentPair db1 db2`, if they agree wherever both are
defined:
```
∀ p, ∀ v1 v2, db1 p = some v1 → db2 p = some v2 → v1 = v2.
```

**Definition 3.5 (Sheaf condition).** A family `dbs : ι → PartialDB nRows nCols V`
satisfies the *sheaf condition* `SheafCondition dbs` if every pair is
consistent: `∀ i j, ConsistentPair (dbs i) (dbs j)`. This is the Čech
0-cocycle condition for the data sheaf.

**Definition 3.6 (Gluing).** The *gluing* of `db1` and `db2` prefers the first
where both are defined:
```
GluingMap db1 db2 p := match db1 p with | some v => some v | none => db2 p.
```

### 3.1 Basic algebraic properties of consistency

**Proposition 3.7 (`consistent_pair_refl`).** Every `db` is consistent with
itself.
*Proof.* If `db p = some v1` and `db p = some v2`, then `some v1 = some v2`, so
`v1 = v2` by injectivity of `some`. ∎

**Proposition 3.8 (`consistent_pair_symm`).** If `ConsistentPair db1 db2` then
`ConsistentPair db2 db1`.
*Proof.* Immediate by swapping the roles of the two values and applying the
hypothesis. ∎

**Proposition 3.9 (`consistent_with_empty`).** The everywhere-`none` database is
consistent with every `db`.
*Proof.* The hypothesis `(fun _ => none) p = some v1` is impossible, so the
implication holds vacuously. ∎

These three facts certify that consistency is the reflexive, symmetric overlap
relation expected of a sheaf, with the empty database as a universal unit.

---

## 4. Gluing Theorems

**Lemma 4.1 (`gluing_extends_left`).** If `db1 p = some v` then
`GluingMap db1 db2 p = some v`.
*Proof.* Unfold the gluing and rewrite by `db1 p = some v`. ∎

**Lemma 4.2 (`gluing_extends_right`).** If `db1 p = none` then
`GluingMap db1 db2 p = db2 p`.
*Proof.* Unfold and rewrite by `db1 p = none`. ∎

**Theorem 4.3 (`gluing_extends_both`).** If `ConsistentPair db1 db2`, then the
gluing extends both inputs:
```
(∀ p v, db1 p = some v → GluingMap db1 db2 p = some v) ∧
(∀ p v, db2 p = some v → GluingMap db1 db2 p = some v).
```
*Proof.* The first conjunct is Lemma 4.1. For the second, fix `p`, `v` with
`db2 p = some v`. Case on `db1 p`: if `db1 p = some v1`, consistency gives
`v1 = v`, so the gluing returns `some v1 = some v`; if `db1 p = none`, the
gluing returns `db2 p = some v`. ∎

This is the operational core of sheaf-based integration: consistent local data
assembles into a larger section that loses nothing.

**Theorem 4.4 (`gluing_increases_domain`, `gluing_preserves_right_domain`).**
For all `db1, db2`:
```
db1.dom ⊆ (GluingMap db1 db2).dom   and   db2.dom ⊆ (GluingMap db1 db2).dom.
```
*Proof.* For a position filled in `db1`, the gluing returns that value, hence is
defined. For a position filled in `db2`, either `db1` is also defined there (so
the gluing is defined), or `db1` is `none` there and the gluing equals
`db2 p ≠ none`. ∎

**Theorem 4.5 (`gluing_preserves_consistency`).** If `db1, db2, db3` are
pairwise consistent (with hypotheses `ConsistentPair db1 db3` and
`ConsistentPair db2 db3`), then `ConsistentPair (GluingMap db1 db2) db3`.
*Proof.* Fix `p` with `GluingMap db1 db2 p = some v1` and `db3 p = some v2`.
Case on `db1 p`: if `db1 p = some v`, then `v1 = v` and consistency of `db1`
with `db3` gives `v = v2`; if `db1 p = none`, then `GluingMap db1 db2 p = db2 p
= some v1`, and consistency of `db2` with `db3` gives `v1 = v2`. ∎

Theorem 4.5 is what makes *iterated* gluing safe: sources may be folded together
one at a time while preserving compatibility with all remaining sources.

**Definition 4.6 (Local extension).** `LocallyExtends db_ext db` holds when
`db_ext` agrees with `db` on all defined positions and fills at least one
additional position:
```
(∀ p v, db p = some v → db_ext p = some v) ∧ (∃ p, db p = none ∧ db_ext p ≠ none).
```

**Theorem 4.7 (`gluing_locally_extends_of_not_contained`).** If `db1, db2` are
consistent and `db2` has information `db1` lacks (`∃ p, db1 p = none ∧
db2 p ≠ none`), then `LocallyExtends (GluingMap db1 db2) db1`.
*Proof.* Agreement on `db1`'s domain is Lemma 4.1. The extra-information witness
`p` has `db1 p = none`, so `GluingMap db1 db2 p = db2 p ≠ none`. ∎

---

## 5. The Coboundary Norm and the Bridge Theorem

**Definition 5.1 (Disagreement indicator).** For `V` with decidable equality,
```
disagreementAt db1 db2 p := match db1 p, db2 p with
  | some v1, some v2 => if v1 = v2 then 0 else 1 | _, _ => 0.
```
This is the pointwise contribution to the Čech coboundary: it is `1` exactly
when both sources are defined at `p` and disagree.

**Definition 5.2 (Coboundary norm).** For a finite family
`dbs : Fin n → PartialDB nRows nCols V`,
```
CoboundaryNorm dbs := ∑_{i,j} ∑_{r,c} disagreementAt (dbs i) (dbs j) (r, c).
```
It counts all disagreements across all pairs and all positions — the discrete
`ℓ¹` norm of the coboundary operator `δ⁰`.

**Theorem 5.3 (`coboundary_zero_iff_sheaf`).**
```
CoboundaryNorm dbs = 0  ↔  SheafCondition dbs.
```
*Proof sketch.* A finite sum of nonnegative naturals is zero iff every summand
is zero. ( ⇒ ) From `CoboundaryNorm dbs = 0`, repeatedly applying
`Finset.sum_eq_zero_iff` over `i`, `j`, the row index, and the column index
yields `disagreementAt (dbs i) (dbs j) p = 0` for all `i, j, p`; unfolding the
indicator at a position where `dbs i p = some v1` and `dbs j p = some v2` forces
`v1 = v2`, i.e. consistency. ( ⇐ ) Conversely, the sheaf condition makes every
indicator zero, so the entire sum is zero by `Finset.sum_eq_zero`. ∎

This is the discrete instance of the cohomological dictionary `ker(δ⁰) = H⁰ =`
global sections: total inconsistency vanishes precisely when local sections glue.

**Theorem 5.4 (`sheaf_condition_of_global_restriction`).** For any global-style
database `g`, any index family `S : ι → Set (DBPos nRows nCols)` of
position-subsets, the restricted family `fun i => g.restrict (S i)` satisfies
the sheaf condition.
*Proof.* For indices `i, j` and a position `p` defined in both restrictions, the
membership tests `p ∈ S i` and `p ∈ S j` both succeed, so both restricted values
equal `g p`; hence they are equal. ∎

Theorem 5.4 is the "easy direction" of the sheaf correspondence: restrictions of
a single global database are always mutually consistent. Equivalently,
inconsistency among sources is positive evidence that no single underlying table
explains them all.

---

## 6. Overlap Constraint Counting

**Definition 6.1 (Overlap constraint count).**
```
overlapConstraintCount n nRows nCols := n*(n-1)/2 * (nRows*nCols).
```
This is the number of pair comparisons `C(n,2)` times the number of positions
per pair.

**Proposition 6.2 (`overlap_zero_of_lt_two`).** If `n < 2` then
`overlapConstraintCount n nRows nCols = 0`.
*Proof.* For `n = 0` and `n = 1`, `n*(n-1)/2 = 0`. ∎

**Proposition 6.3 (`overlap_quadratic_growth`).**
`overlapConstraintCount n nRows nCols ≤ n*n*(nRows*nCols)`.
*Proof.* `n*(n-1)/2 ≤ n*(n-1) ≤ n*n`, and multiply by `nRows*nCols`. ∎

Thus the number of consistency constraints grows quadratically in the number of
sources and linearly in the grid size.

---

## 7. The Sheaf Imputation Problem

**Definition 7.1 (Imputation objective).** For observed partial data `observed`
and a candidate complete assignment `candidate : DBPos nRows nCols → V`,
```
SheafImputationObjective observed candidate :=
  ∑_{r,c} match observed (r,c) with
    | some v => if v = candidate (r,c) then 0 else 1 | none => 0.
```
This counts observed cells where the candidate disagrees with the observation.

**Theorem 7.2 (`imputation_zero_iff_extends`).**
```
SheafImputationObjective observed candidate = 0
  ↔  ∀ p v, observed p = some v → candidate p = v.
```
*Proof sketch.* Apply `Finset.sum_eq_zero_iff` across rows and columns. The
summand at `(r,c)` is zero iff either `observed (r,c) = none` or the candidate
matches the observed value; collecting these conditions over all positions is
exactly the extension property. ∎

Theorem 7.2 makes "find the closest complete database" a genuine optimization
statement: cost zero characterizes faithful completions. **Sheaf imputation** is
then the program of selecting, among faithful completions, one that minimizes the
coboundary norm across feature subsets — i.e. one that maximally respects the
overlap constraints, which mean and KNN imputation discard.

---

## 8. Sheaf Filtrations: Progressive Imputation

**Definition 8.1 (Sheaf filtration).** A `SheafFiltration nRows nCols V depth`
consists of:
- `level : Fin depth → PartialDB nRows nCols V`;
- *monotonicity*: `∀ i j, i ≤ j → ∀ p v, level i p = some v → level j p = some
  v` (information only grows);
- *consistency*: `SheafCondition level`.

It is **complete** (`SheafFiltration.isComplete`, given `0 < depth`) when the
final level `level ⟨depth-1, _⟩` is a global section.

This is the data-science analogue of a filtered complex: a study object is
approached through a rising chain of approximations.

**Theorem 8.2 (`sheaf_filtration_auto_consistent`).** If a family `levels`
satisfies monotonicity, then it satisfies the sheaf condition.
*Proof.* For indices `i, j` and a position `p` with `levels i p = some v1`,
`levels j p = some v2`: if `i ≤ j`, monotonicity gives `levels j p = some v1`,
so `v1 = v2`; if `j < i`, symmetrically `v1 = v2`. ∎

This reduces the global sheaf condition to a local order-theoretic property:
*an imputation pipeline that never overwrites a committed value is automatically
consistent.* Consequently the `consistent` field of a filtration is derivable
from `monotone`; it is kept for emphasis.

**Theorem 8.3 (`sheaf_filtration_exists_singleton`).** Any `db` is a depth-1
filtration with `level 0 = db`.
*Proof.* Take all levels equal to `db`; monotonicity and consistency are
immediate. ∎

**Theorem 8.4 (`filtration_final_contains_all`).** In any filtration of positive
depth, for every level `i`, `(level i).dom ⊆ (level ⟨depth-1, _⟩).dom`.
*Proof.* If `p` is filled at level `i`, say `level i p = some v`, monotonicity
applied to `i ≤ depth-1` gives `level ⟨depth-1⟩ p = some v ≠ none`. ∎

Information accumulates monotonically; the final level dominates all earlier
levels, and a complete filtration culminates in a global section.

---

## 9. The Consistency Probability Model

**Definition 9.1 (Consistency probability).** For a real disagreement rate `r`
and a constraint count `c`,
```
consistencyProbability r c := (1 - r) ^ c.
```
If each constraint is independently violated with probability `r`, this is the
probability that all `c` constraints hold.

The following properties confirm that `consistencyProbability` is a coherent
probability model and exhibits exponential decay.

**Proposition 9.2 (`consistency_prob_nonneg`, `consistency_prob_le_one`).** For
`0 ≤ r ≤ 1` and any `c`, `0 ≤ consistencyProbability r c ≤ 1`.
*Proof.* `0 ≤ 1 - r ≤ 1`; apply `pow_nonneg` and `pow_le_one₀`. ∎

**Proposition 9.3 (`consistency_prob_mono_constraints`).** For `0 ≤ r ≤ 1` and
`c1 ≤ c2`, `consistencyProbability r c2 ≤ consistencyProbability r c1`.
*Proof.* With base in `[0,1]`, the power is antitone in the exponent
(`pow_le_pow_of_le_one`). ∎

**Proposition 9.4 (`consistency_prob_mono_rate`).** For `r2 ≤ 1` and `r1 ≤ r2`,
`consistencyProbability r2 c ≤ consistencyProbability r1 c`.
*Proof.* `1 - r2 ≤ 1 - r1` and both are nonnegative; apply
`pow_le_pow_left₀`. ∎

**Proposition 9.5 (`consistency_prob_zero_rate`, `consistency_prob_one_rate`).**
`consistencyProbability 0 c = 1`, and for `c > 0`,
`consistencyProbability 1 c = 0`.
*Proof.* `(1-0)^c = 1`; `(1-1)^c = 0^c = 0` for `c ≠ 0`. ∎

**Proposition 9.6 (`consistency_prob_mul`, `consistency_prob_double`).**
`consistencyProbability r (c1+c2) = consistencyProbability r c1 *
consistencyProbability r c2`, and `consistencyProbability r (2*c) =
(consistencyProbability r c)^2`.
*Proof.* `(1-r)^(c1+c2) = (1-r)^{c1} (1-r)^{c2}` by `pow_add`; the doubling case
follows by `ring`. ∎

### 9.1 The exponential-decay conjecture

Combining Section 6 with the multiplicativity above, the consistency probability
of a full database is `(1-r)^{C}` with `C = overlapConstraintCount n k n`, which
is quadratic in the number of columns. We formalize a falsifiable comparison.

**Conjecture 9.7 (`conjecture_exponential_decay_testable`).**
```
∀ n k (r : ℝ), 0 < r → r < 1 → 2 ≤ n → 1 ≤ k →
  consistencyProbability r (overlapConstraintCount n k n)
    < consistencyProbability r (k * n).
```
The right-hand side `(1-r)^{kn}` is a coarse "one constraint per cell" baseline;
the left-hand side carries the full quadratic constraint count. The conjecture
asserts that the full sheaf constraint count makes consistency *strictly* less
likely than the naive baseline, for every nondegenerate regime.

**Numerical illustration.** With `n = 10`, `k = 100`, `r = 0.3`, the constraint
count is `10·9/2 · 1000 = 45000`, and `(0.7)^{45000} ≈ 10^{-6968}` — operationally
zero. Even the coarse baseline `(0.7)^{1000} ≈ 10^{-155}` is negligible. Random
tables are essentially never globally consistent; the consistency one observes in
real data is therefore a signature of genuine structure.

**Falsification protocol.** Generate `10^6` random `100×10` tables at 30% missing
rate, impose the overlap constraints, and count how many satisfy the sheaf
condition. The model predicts zero. Any spontaneously consistent table would
indicate the model is too pessimistic for that data-generating process.

---

## 10. Algorithms

The constructive content yields directly executable procedures.

**Algorithm A (Pairwise gluing).** Given consistent `db1, db2`, compute
`GluingMap db1 db2` cellwise. By Theorem 4.3 the result extends both inputs.
Complexity `O(nRows · nCols)`.

**Algorithm B (Iterated integration).** Given `m` pairwise-consistent sources,
fold them with `GluingMap`. By Theorem 4.5, consistency with the remaining
sources is preserved at each step, so the fold is well-defined regardless of
order. Complexity `O(m · nRows · nCols)`.

**Algorithm C (Coboundary norm / inconsistency audit).** For `n` sources,
compute `CoboundaryNorm`. By Theorem 5.3 the result is zero iff the family is
gluable. Complexity `O(n² · nRows · nCols)`.

**Algorithm D (Sheaf imputation).** Among complete assignments with zero
imputation objective (Theorem 7.2 guarantees these are exactly the faithful
extensions of the observed data), select one minimizing the coboundary norm over
the chosen family of feature subsets. This is a constrained discrete
optimization whose feasibility is certified by the sheaf condition.

---

## 11. Applications

- **Data integration.** Merging overlapping data sources is iterated gluing
  (Algorithm B); Theorem 4.5 guarantees order-independence and safety.
- **Inconsistency auditing.** The coboundary norm (Algorithm C) is a single
  scalar diagnosing whether a multi-source dataset can be coherently merged, with
  Theorem 5.3 certifying the zero case.
- **Missing-value imputation.** Theorem 7.2 turns imputation into optimization
  with a verifiable optimum; sheaf imputation additionally exploits overlap
  constraints ignored by mean/KNN/MICE.
- **Cryptographic / secure record linkage.** Consistency across partial views
  held by distinct parties is exactly the sheaf condition; the coboundary norm
  quantifies the obstruction to a consistent joint record without revealing the
  values themselves beyond agreement.
- **Streaming / progressive imputation.** Sheaf filtrations (Section 8) model
  pipelines that fill cells incrementally; Theorem 8.2 guarantees automatic
  consistency provided values are never overwritten.

---

## 12. Discussion

The theory's value is *leverage through re-description*. By recognizing
data-integration consistency as the sheaf condition, we obtain a precise
optimum (Theorem 7.2), a precise failure measure (the coboundary norm), a
precise bridge between the algebraic and combinatorial views (Theorem 5.3), and
a precise quantitative law (Section 9). Inconsistency is reframed not as noise
but as a measurable *obstruction* — a cocycle that fails to be a coboundary.

A central qualitative consequence is the exponential consistency cliff: random
data is almost never globally consistent, so observed consistency is a
fingerprint of structure. This reframes imputation: rather than predicting
likely values, sheaf imputation seeks completions that *respect* the abundant
overlap constraints, which is precisely the information other methods discard.

---

## 13. Future Directions

The most immediate extension is to upgrade partial sections from a flat index
set to a genuine presheaf on a poset or topological space, so that restriction
is functorial and the gluing theorem proved here becomes the sheaf condition for
an honest site; the support of a partial section already behaves like an open
set and `restrict` like a sheaf restriction map.

A second direction is quantitative: replace boolean present/absent with graded
or weighted information (confidence, timestamp, lattice element), so that gluing
*reconciles* rather than merely *selects*; our `GluingMap` is the join in a
simple information order, and relaxing compatibility to "agree up to tolerance"
should generalize the extension lemmas to a monotone merge on a semilattice.

A third direction targets effectiveness: produce an executable, verified gluing
for a family of sources (currently choice-based selection at each index can be
made deterministic since pairwise compatibility renders the choice irrelevant —
first-source, majority, or most-recent rules all coincide).

A fourth direction studies the *obstruction* to gluing when compatibility fails:
develop the first cohomology of this discrete sheaf. `coboundary_zero_iff_sheaf`
is a vanishing statement — a global section exists precisely when a local
obstruction is trivial — so measuring how badly a family fails pairwise
compatibility should recover a Čech-style invariant counting irreconcilable
conflicts, enabling conflict *explanation*, not just detection.

---

## 14. Conclusion

We have given a self-contained, formally verified theory in which databases form
a (discrete) sheaf, missing-data integration is gluing, optimal imputation is the
vanishing of an objective, and inconsistency is a coboundary. The bridge theorem
`coboundary_zero_iff_sheaf` realizes "data imputation is a sheaf-cohomology
problem" at the level of an exact equivalence, and the consistency-probability
model supplies a falsifiable quantitative law. The sheaf condition is, we argue,
the natural consistency constraint for databases.
