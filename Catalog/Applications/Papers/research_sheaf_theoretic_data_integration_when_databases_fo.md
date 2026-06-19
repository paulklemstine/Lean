# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Bridges (algebraic geometry ↔ data science)

## Abstract

We develop a discrete sheaf-theoretic model of database integration and
imputation. A database with missing entries is modeled as a *partial section*
of the sheaf of `V`-valued functions on a grid of `(row, column)` positions.
The sheaf condition — pairwise agreement of local views on their overlaps —
is shown to be exactly the consistency condition under which partial views can
be glued into a complete database, and we prove that gluing preserves all
observed data, is compatible with incremental (one-source-at-a-time)
integration, and only ever enlarges the set of observed cells. We introduce a
discrete coboundary norm counting overlap conflicts and prove it vanishes if
and only if the sheaf condition holds, the finite analogue of the statement
that the kernel of the Čech coboundary is the space of global sections. We
formalize sheaf imputation as the minimization of an observation-fidelity
objective and characterize its zero-cost solutions as exactly the completions
faithful to the data. On the probabilistic side, we model the chance that a
random noisy database is consistent as `(1-r)^C`, prove its multiplicativity,
monotonicity, and boundary behavior, and combine it with a quadratic lower
bound on the overlap-constraint count to obtain a testable exponential-decay
conjecture. Finally we introduce *sheaf filtrations* — monotone consistent
sequences modeling progressive imputation — and prove that monotonicity alone
forces consistency and that information accumulates to the final level. All
results are formalized and machine-checked.

## 1. Introduction

Imputation — filling in missing entries of a data table — is ubiquitous in
applied statistics and machine learning. The dominant methods (mean
imputation, k-nearest-neighbors, MICE) are *pointwise plausibility* heuristics:
they estimate a likely value for each blank in isolation or from local
similarity. None of them treats *global consistency* of the table as a
first-class constraint.

This paper takes the view that the natural consistency structure on a database
is that of a **sheaf**. Sheaves formalize the assembly of local data into
global data subject to agreement on overlaps; the *gluing axiom* (sheaf
condition) states precisely when local sections determine a unique global
section. We show that a database with missing entries is a partial section of
the function sheaf on its cell grid, that "consistent imputation" is the search
for a global section restricting to the observations, and that the resulting
theory delivers provable guarantees absent from the standard heuristics.

Our contributions, each formalized:

1. A discrete model (partial databases, consistency, gluing, global sections)
   with the basic gluing guarantees (§3).
2. An equivalence between a discrete coboundary norm and the sheaf condition
   (§4), the finite shadow of `ker δ⁰ = H⁰`.
3. A sheaf imputation objective whose zero set is exactly the faithful
   completions (§5).
4. A consistency-probability calculus `(1-r)^C` with its algebraic laws, and a
   quadratic lower bound on constraint count yielding a testable
   exponential-decay conjecture (§6).
5. *Sheaf filtrations*, a novel order-theoretic model of progressive
   imputation, with automatic consistency and information accumulation (§7).

## 2. Preliminaries and Definitions

Fix natural numbers `nRows`, `nCols` and a value type `V`.

**Definition 2.1 (Position, `DBPos`).** A *position* is a grid cell
`DBPos nRows nCols := Fin nRows × Fin nCols`.

**Definition 2.2 (Partial database, `PartialDB`).** A *partial database* is a
function `PartialDB nRows nCols V := DBPos nRows nCols → Option V`. The marker
`none` denotes a missing entry; `some v` an observed value `v`.

**Definition 2.3 (Domain, `PartialDB.dom`).** The *domain* of `db` is the set
of filled positions `db.dom := {p | db p ≠ none}`.

**Definition 2.4 (Global section, `IsGlobalSection`).** `db` is a *global
section* iff `∀ p, db p ≠ none`: a table with no missing entries.

**Definition 2.5 (Consistent pair, `ConsistentPair`).** Partial databases
`db₁, db₂` form a *consistent pair* iff
`∀ p v₁ v₂, db₁ p = some v₁ → db₂ p = some v₂ → v₁ = v₂`,
i.e. they agree at every position where both are defined.

**Definition 2.6 (Sheaf condition, `SheafCondition`).** A family
`dbs : ι → PartialDB nRows nCols V` satisfies the *sheaf condition* iff
`∀ i j, ConsistentPair (dbs i) (dbs j)` — every pair is consistent. This is the
Čech 0-cocycle (pairwise overlap-agreement) condition for the data sheaf.

**Definition 2.7 (Gluing, `GluingMap`).** The *gluing* of `db₁, db₂` is
```
GluingMap db₁ db₂ p = match db₁ p with | some v => some v | none => db₂ p,
```
the union preferring `db₁` where both are defined.

**Definition 2.8 (Restriction, `PartialDB.restrict`).** For a decidable set
`S` of positions, `db.restrict S p = if p ∈ S then db p else none`.

**Definition 2.9 (Disagreement indicator, `disagreementAt`).** For
`[DecidableEq V]`,
```
disagreementAt db₁ db₂ p = match db₁ p, db₂ p with
  | some v₁, some v₂ => if v₁ = v₂ then 0 else 1 | _,_ => 0,
```
the pointwise contribution to the Čech coboundary.

**Definition 2.10 (Coboundary norm, `CoboundaryNorm`).** For a finite family
`dbs : Fin n → PartialDB nRows nCols V`,
```
CoboundaryNorm dbs = ∑_{i,j} ∑_{r,c} disagreementAt (dbs i) (dbs j) (r,c),
```
the discrete analogue of the Čech coboundary `ℓ¹`-norm `‖δ⁰σ‖₁`.

**Definition 2.11 (Overlap constraint count, `overlapConstraintCount`).**
`overlapConstraintCount n nRows nCols = n*(n-1)/2 * (nRows*nCols)`: one overlap
comparison per unordered pair of `n` views, per grid cell.

**Definition 2.12 (Consistency probability, `consistencyProbability`).** For a
real conflict rate `r` and constraint count `c`,
`consistencyProbability r c = (1 - r)^c`.

**Definition 2.13 (Imputation objective, `SheafImputationObjective`).** For
observed `db` and a candidate complete table `g : DBPos → V`,
```
SheafImputationObjective db g
  = ∑_{r,c} match db (r,c) with | some v => if v = g (r,c) then 0 else 1 | none => 0,
```
the number of observed cells where `g` disagrees with the observation.

**Definition 2.14 (Local extension, `LocallyExtends`).** `db_ext`
*locally extends* `db` iff it agrees with `db` on all defined positions and
fills at least one position `db` left blank.

**Definition 2.15 (Sheaf filtration, `SheafFiltration`).** A *sheaf filtration*
of depth `depth` is a structure with: a family `level : Fin depth → PartialDB`;
a *monotonicity* law `∀ i ≤ j, ∀ p v, level i p = some v → level j p = some v`;
and a *consistency* law `SheafCondition level`. It is *complete*
(`SheafFiltration.isComplete`) when the final level is a global section.

## 3. Gluing and Consistency

We first record that consistency behaves like the equality it generalizes.

**Theorem 3.1 (`consistent_pair_symm`).** If `ConsistentPair db₁ db₂` then
`ConsistentPair db₂ db₁`.
*Proof.* Swap the two witnesses and apply symmetry of `=` in `V`. ∎

**Theorem 3.2 (`consistent_pair_refl`, `consistent_with_empty`).**
`ConsistentPair db db` for all `db`; and the empty database `λ_, none` is
consistent with every `db`.
*Proof.* Reflexivity: `db p = some v₁` and `db p = some v₂` force `v₁ = v₂` by
injectivity of `some`. Empty: the hypothesis `none = some v₁` is absurd. ∎

The gluing operator preserves observed data on each side.

**Lemma 3.3 (`gluing_extends_left`, `gluing_extends_right`).** If
`db₁ p = some v` then `GluingMap db₁ db₂ p = some v`; if `db₁ p = none` then
`GluingMap db₁ db₂ p = db₂ p`.
*Proof.* Unfold `GluingMap` and rewrite by the case hypothesis. ∎

**Theorem 3.4 (`gluing_extends_both`).** If `ConsistentPair db₁ db₂` then for
all `p, v`: `db₁ p = some v ⇒ GluingMap db₁ db₂ p = some v`, and
`db₂ p = some v ⇒ GluingMap db₁ db₂ p = some v`.
*Proof.* The left case is Lemma 3.3. For the right case, case on `db₁ p`: if
`db₁ p = some v₁`, consistency gives `v₁ = v`, so the glue returns `some v`; if
`db₁ p = none`, the glue returns `db₂ p = some v`. ∎

Thus gluing never corrupts data and is the carrier of the existence half of the
sheaf condition. It is also compatible with iterated integration.

**Theorem 3.5 (`gluing_preserves_consistency`).** If `db₁, db₂, db₃` are
pairwise consistent then `ConsistentPair (GluingMap db₁ db₂) db₃`.
*Proof.* Let `(GluingMap db₁ db₂) p = some v₁` and `db₃ p = some v₂`. Case on
`db₁ p`: if `db₁ p = some v`, then `v₁ = v` and consistency of `db₁, db₃` gives
`v = v₂`; if `db₁ p = none`, then `v₁ = db₂ p`'s value and consistency of
`db₂, db₃` gives `v₁ = v₂`. ∎

**Corollary 3.6 (incremental integration).** A pairwise-consistent finite
family may be glued in any order without introducing conflicts; consistency is
an invariant of the fold.

Gluing also grows the domain monotonically.

**Theorem 3.7 (`gluing_increases_domain`, `gluing_preserves_right_domain`).**
`db₁.dom ⊆ (GluingMap db₁ db₂).dom` and `db₂.dom ⊆ (GluingMap db₁ db₂).dom`.
*Proof.* For a position in `db₁.dom`, `db₁ p ≠ none`, so the glue returns
`db₁ p ≠ none`. For `db₂.dom`, case on `db₁ p`: defined ⇒ glue defined;
undefined ⇒ glue equals `db₂ p ≠ none`. ∎

**Theorem 3.8 (`gluing_locally_extends_of_not_contained`).** If `db₁, db₂` are
consistent and `db₂` fills some position `db₁` leaves blank, then
`GluingMap db₁ db₂` locally extends `db₁`.
*Proof.* Fidelity to `db₁` is Lemma 3.3; the extra filled cell is supplied by
the witness from `db₂`. ∎

**Theorem 3.9 (easy direction, `sheaf_condition_of_global_restriction`).** For
any `g` and family of sets `S : ι → Set (DBPos …)`, the restrictions
`λ i, g.restrict (S i)` satisfy the `SheafCondition`.
*Proof.* At a position where two restrictions are both defined, both equal
`g p`, hence equal each other. ∎

This is the discrete form of "global sections always glue locally"; the content
of the sheaf condition is the converse, which §4 packages via the coboundary.

## 4. The Coboundary–Sheaf Equivalence

**Theorem 4.1 (`coboundary_zero_iff_sheaf`).** For any finite family
`dbs : Fin n → PartialDB nRows nCols V` with `[DecidableEq V]`,
```
CoboundaryNorm dbs = 0  ↔  SheafCondition dbs.
```
*Proof sketch.* A finite sum of naturals is zero iff every summand is zero
(`Finset.sum_eq_zero_iff`). Peeling the four nested sums, the norm is zero iff
`disagreementAt (dbs i)(dbs j)(r,c) = 0` for all `i,j,r,c`. By definition of
`disagreementAt`, this term is `0` exactly when the two views do not both fill
`(r,c)` with distinct values — i.e. exactly the consistency condition at that
cell. Quantifying over all cells and pairs yields `SheafCondition dbs`.
Conversely, the sheaf condition kills each summand, so the total is zero. ∎

This is the finite analogue of `ker δ⁰ = H⁰`: the family of partial views glues
to a global section precisely when the conflict count vanishes. Standard
imputation heuristics never evaluate this functional, which is the structural
reason they "ignore constraints."

## 5. Sheaf Imputation as Optimization

The imputation objective (Definition 2.13) measures infidelity to the observed
data. Its global minimizers are characterized exactly.

**Theorem 5.1 (`imputation_zero_iff_extends`).** For observed `db` and
candidate `g`,
```
SheafImputationObjective db g = 0  ↔  ∀ p v, db p = some v → g p = v.
```
*Proof sketch.* Again the sum of naturals is zero iff each summand is zero.
At a position with `db (r,c) = some v`, the summand is `0` iff `v = g (r,c)`; at
a blank position the summand is `0` unconditionally. Hence the total is zero iff
`g` reproduces every observed value. ∎

Thus *sheaf imputation* — minimize the objective to `0` subject to producing a
complete table — returns exactly the global sections that extend the
observations. When a consistent completion exists, gluing (§3) constructs one;
Theorem 5.1 certifies its optimality. Mean and KNN imputation generically incur
positive objective value because they may overwrite observed cells.

## 6. The Consistency-Probability Calculus

We treat each potential overlap constraint as independently violated with
probability `r ∈ [0,1]`, giving `consistencyProbability r c = (1-r)^c`.

**Theorem 6.1 (multiplicativity, `consistency_prob_mul`).**
`consistencyProbability r (c₁+c₂) = consistencyProbability r c₁ ·
consistencyProbability r c₂`.
*Proof.* `(1-r)^{c₁+c₂} = (1-r)^{c₁}(1-r)^{c₂}` by `pow_add`. ∎

**Corollary 6.2 (`consistency_prob_double`).**
`consistencyProbability r (2c) = (consistencyProbability r c)^2`.

**Theorem 6.3 (monotonicity in constraints, `consistency_prob_mono_constraints`).**
For `0 ≤ r ≤ 1` and `c₁ ≤ c₂`,
`consistencyProbability r c₂ ≤ consistencyProbability r c₁`.
*Proof.* `1-r ∈ [0,1]`, and powers of a base in `[0,1]` are antitone in the
exponent (`pow_le_pow_of_le_one`). ∎

**Theorem 6.4 (monotonicity in rate, `consistency_prob_mono_rate`).** For
`r₂ ≤ 1` and `r₁ ≤ r₂`,
`consistencyProbability r₂ c ≤ consistencyProbability r₁ c`.
*Proof.* `0 ≤ 1-r₂ ≤ 1-r₁`; raise to the fixed power `c`
(`pow_le_pow_left₀`). ∎

**Theorem 6.5 (boundary values and range).**
`consistency_prob_zero_rate`: `(1-0)^c = 1`;
`consistency_prob_one_rate`: for `c > 0`, `(1-1)^c = 0^c = 0`;
`consistency_prob_le_one` and `consistency_prob_nonneg`: for `0 ≤ r ≤ 1`,
`0 ≤ (1-r)^c ≤ 1`.

The constraint count itself grows quadratically.

**Theorem 6.6 (quadratic growth, `overlap_quadratic_growth`).**
`overlapConstraintCount n nRows nCols ≤ n · n · (nRows · nCols)`.
*Proof.* `n(n-1)/2 ≤ n(n-1) ≤ n·n` by `Nat.div_le_self` and `Nat.sub_le`. ∎

**Theorem 6.7 (vanishing below two views, `overlap_zero_of_lt_two`).** For
`n < 2`, `overlapConstraintCount n nRows nCols = 0`.

Combining exponential decay (Theorem 6.3) with quadratic constraint growth
(Theorem 6.6) yields the headline phenomenon, stated as a falsifiable
proposition.

**Conjecture 6.8 (`conjecture_exponential_decay_testable`).** For all `n, k`
and `r` with `0 < r < 1`, `2 ≤ n`, `1 ≤ k`,
```
consistencyProbability r (overlapConstraintCount n k n)
  < consistencyProbability r (k · n).
```
That is, the consistency probability built from the *quadratic* overlap count
is strictly below the probability built from a merely *linear* count: the decay
is super-linear. *Testable prediction.* For `n = 10`, `k = 100`, `r = 0.3`, the
constraint count is `n(n-1)/2 · k = 4500`, so `P ≈ 0.7^{4500} ≈ 10^{-697}`:
large noisy databases are essentially never spontaneously consistent. *To
falsify:* sample `10^6` random `100×10` tables at `30%` conflict rate and count
the consistent ones; observing any would refute the magnitude estimate.

## 7. Sheaf Filtrations: Progressive Imputation

We model imputation as a process via `SheafFiltration` (Definition 2.15).

**Theorem 7.1 (monotone ⇒ consistent, `sheaf_filtration_auto_consistent`).** If
`levels : Fin depth → PartialDB` satisfies the monotonicity law
`∀ i ≤ j, ∀ p v, levels i p = some v → levels j p = some v`, then
`SheafCondition levels`.
*Proof.* Given `levels i p = some v₁` and `levels j p = some v₂`, compare `i, j`.
If `i ≤ j`, monotonicity sends `some v₁` forward to `levels j p`, forcing
`v₁ = v₂`; if `j < i`, send `some v₂` forward to `levels i p`. ∎

Hence the disciplined imputation rule — *only fill blanks, never overwrite* —
guarantees consistency for free; the sheaf condition reduces to an
order-theoretic monotonicity property.

**Theorem 7.2 (existence, `sheaf_filtration_exists_singleton`).** Every partial
database is the unique level of a depth-`1` sheaf filtration.
*Proof.* The constant family trivially satisfies monotonicity and consistency.
∎

**Theorem 7.3 (information accumulation, `filtration_final_contains_all`).** In
any sheaf filtration of positive depth, for every level `i`,
`(F.level i).dom ⊆ (F.level ⟨depth-1, …⟩).dom`.
*Proof.* For `p` filled at level `i` with value `v`, monotonicity from `i` to
the final index `depth-1` keeps it filled, so `p` lies in the final domain. ∎

Together, Theorems 7.1–7.3 say progressive imputation that never overwrites is
automatically conflict-free and monotonically completing.

## 7a. A Worked Example

To make the machinery concrete, consider a `2×2` grid with positions
`{(0,0),(0,1),(1,0),(1,1)}` and three local views drawn from two data sources
and one auxiliary feed:

- `A = {(0,0)↦7, (0,1)↦3}` (a record covering the top row's left/middle),
- `B = {(0,1)↦3, (1,0)↦5}` (an overlapping record sharing cell `(0,1)`),
- `C = {(1,0)↦5, (1,1)↦9}` (a record sharing cell `(1,0)` with `B`).

Each overlapping pair agrees: `A` and `B` both report `3` at `(0,1)`; `B` and
`C` both report `5` at `(1,0)`; `A` and `C` do not overlap. By Definition 2.10
the coboundary norm is `0`, so by Theorem 4.1 the family satisfies the sheaf
condition and a consistent global completion exists. Folding the views with
`GluingMap` (Theorem 3.5 licenses any order) yields the partial section
`{(0,0)↦7,(0,1)↦3,(1,0)↦5,(1,1)↦9}`, already a global section here. By
Theorem 3.4 every observed value of every view survives the merge, and by
Theorem 3.7 the merged domain contains each source's domain.

Now perturb `B` to report `99` at `(0,1)`. The pair `(A,B)` disagrees there, so
the disagreement indicator fires for the ordered pairs `(A,B)` and `(B,A)`,
giving coboundary norm `2 > 0`; Theorem 4.1 then certifies that *no* global
section extends all three views — the data are provably unmergeable until the
conflict at `(0,1)` is resolved. This single scalar (the conflict count) is the
entire decision procedure, and it is exactly the quantity mean and KNN
imputation never compute.

For the probabilistic side, scale up to `n = 10` columns and `k = 100` rows.
The overlap count `C(n,2)·k = 4500` combined with a `30%` conflict rate gives
consistency probability `(0.7)^{4500} ≈ 10^{-697}` (Definition 2.12,
Theorem 6.3): spontaneous consistency is astronomically unlikely, which is
precisely why an active consistency-enforcing method is needed rather than
passive estimation.

## 8. Applications

- **Multi-source record linkage.** Hospitals/sensors are local views;
  `gluing_preserves_consistency` licenses incremental merging, and
  `coboundary_zero_iff_sheaf` gives a single scalar (conflict count) certifying
  whether a global merge exists.
- **Constraint-aware imputation.** `imputation_zero_iff_extends` defines
  faithful completion; the sheaf method targets zero objective, unlike
  mean/KNN, which may violate observed values.
- **Feasibility triage.** The `(1-r)^C` calculus with quadratic constraint
  growth predicts that large noisy tables are essentially never spontaneously
  consistent, motivating active consistency enforcement rather than passive
  estimation.
- **Streaming/online imputation.** `SheafFiltration` models an append-only
  pipeline whose stages are automatically consistent
  (`sheaf_filtration_auto_consistent`) and lossless
  (`filtration_final_contains_all`).

## 9. Discussion and Limitations

The model uses the *function* sheaf, whose sections are honest functions, so
**pairwise** compatibility suffices for gluing — no higher cocycle conditions
arise (first cohomology vanishes). This is both the model's strength
(`coboundary_zero_iff_sheaf` is an exact, computable criterion) and its
boundary: richer data sheaves whose stalks are quotients or torsors can carry a
nontrivial `Ȟ¹`, where pairwise compatibility no longer guarantees a global
section. The independence assumption underlying `(1-r)^C` is a modeling choice;
real overlaps are correlated, so the formula is best read as a baseline decay
law, captured rigorously by its algebraic laws (Theorems 6.1–6.5) rather than as
an exact empirical frequency.

## 10. Future Directions

1. **Čech obstruction for value-quotient sheaves.** Replace the function sheaf
   by one with quotient stalks; conjecture pairwise compatibility no longer
   suffices, with the obstruction a nonzero `Ȟ¹` class of the nerve — a
   genuine non-gluing certificate complementing the load-bearing pairwise
   condition.
2. **Exact-imputability phase transition.** Under the independent-overlap
   model, a first/second-moment argument on `(1-r)^C · (#configs)` should
   locate a sharp threshold `r*(k)` separating "almost surely imputable" from
   "almost surely inconsistent," upgrading the decay laws to a threshold
   constant.
3. **Strict dominance of sheaf imputation when `H¹ = 0`.** On grids with
   vanishing first cohomology, the glued global section is the unique zero-error
   completion, while mean/KNN error is lower-bounded by the overlap variance — a
   provable separation for `r < 1/2`.
4. **Optimality of the quadratic constraint count.** Any restriction-closed
   local-consistency scheme should require `Ω(k²)` overlap checks, making the
   triangular `C(k,2)` order-optimal; no linear-constraint relaxation can
   certify global consistency.

## 11. Conclusion

Renaming "database with missing entries" as "partial section of the function
sheaf" converts a family of data-cleaning heuristics into a small rigorous
theory: gluing preserves and accumulates observations, conflict-count-zero is
exactly the sheaf condition, faithful imputation is exactly zero-cost
imputation, accidental consistency decays exponentially in a quadratically
growing constraint count, and monotone imputation is contradiction-free by
construction. The sheaf condition is the natural consistency constraint for
databases, and consistent imputation is the search for a global section.
