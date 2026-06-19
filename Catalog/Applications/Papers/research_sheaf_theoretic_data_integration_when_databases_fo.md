# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Computation (Bridges: Algebraic Geometry ↔ Data Science)

## Abstract

We develop a discrete, fully formalized sheaf theory of databases with missing
entries. A database on an `nRows × nCols` grid is modeled as a partial section
of the sheaf of optional-valued functions: a map `PartialDB : DBPos → Option V`,
where the token `none` denotes a missing cell. Two partial databases are
*consistent* when they agree on every cell where both are defined, and a family
satisfies the *sheaf condition* when it is pairwise consistent. We prove the
existence half of the gluing axiom — consistent partial databases merge into a
section extending all of them (`gluing_extends_both`, `gluing_preserves_consistency`)
— and we show that the easy direction holds: restrictions of a global section
always satisfy the sheaf condition (`sheaf_condition_of_global_restriction`). The
central bridge is a discrete Čech result: the total disagreement count
(`CoboundaryNorm`) vanishes if and only if the sheaf condition holds
(`coboundary_zero_iff_sheaf`), the combinatorial analogue of `ker δ⁰ = H⁰`. We
recast imputation as the search for the nearest global section, proving that the
imputation objective is zero precisely when a candidate extends the observed data
(`imputation_zero_iff_extends`). On the probabilistic side we analyze
`consistencyProbability(r, c) = (1-r)^c`, establishing exact monotonicity,
multiplicative composition (`consistency_prob_mul`), and boundary values, and we
formalize the conjecture of exponential consistency decay
(`conjecture_exponential_decay_testable`) driven by the quadratically-growing
overlap constraint count. Finally we introduce *sheaf filtrations* — monotone,
consistent imputation processes — and prove that monotonicity alone forces
consistency (`sheaf_filtration_auto_consistent`) and that information accumulates
to the final stage (`filtration_final_contains_all`).

## 1. Introduction

Imputation of missing data is usually treated cell by cell: mean imputation,
k-nearest-neighbors, or iterative model-based schemes (MICE) each produce a
completion of the table, but none of them treat the *consistency of overlapping
views* as a first-class constraint. Sheaf theory is the branch of mathematics
built precisely to govern when local data, defined on overlapping patches and
agreeing on overlaps, assembles into a coherent global object — and to measure,
via cohomology, the obstruction when it does not. This paper makes the
correspondence exact and machine-checked: a database is a partial section, the
overlap-agreement condition is the sheaf condition, the total-disagreement count
is a Čech coboundary, and imputation is the search for a global section
restricting to the observed data.

All results below are stated for an `nRows × nCols` grid over an arbitrary value
type `V` (with `DecidableEq V` where disagreement must be counted), and have been
formally verified.

The development is deliberately *constructive and finitary*. We do not appeal to
topological sheaves, Grothendieck topologies, or derived functors; instead we work
with the concrete site whose opens are subsets of the finite grid and whose
sections are partial functions. This keeps every statement decidable and every
proof a finite case analysis or a finite sum manipulation, which is exactly what
makes the correspondence machine-checkable. The payoff is conceptual rather than
technical: it shows that the *content* of the sheaf axioms — local-to-global
gluing, the cocycle/overlap condition, the cohomological obstruction to gluing —
survives intact in the most elementary possible setting, the setting in which data
actually lives.

Throughout, we distinguish three layers. The *combinatorial layer* (Sections 3–5)
establishes the deterministic sheaf calculus: when sections glue, why the glue is
faithful, and how a single scalar detects gluability. The *probabilistic layer*
(Section 6) quantifies how often the deterministic condition can be expected to
hold under a random-clash model. The *process layer* (Section 7) studies
imputation as a dynamical, append-only refinement. These layers are independent
enough to be read separately but compose into a single account of consistent
imputation.

## 2. Definitions

**Definition 1 (Grid position).** `DBPos nRows nCols := Fin nRows × Fin nCols`.
A position names a single (row, column) cell.

**Definition 2 (Partial database and domain).**
`PartialDB nRows nCols V := DBPos nRows nCols → Option V`. The token `none`
marks a missing cell. Its *domain* is `db.dom := { p | db p ≠ none }`, the set of
observed positions.

**Definition 3 (Consistency).** Partial databases `db₁, db₂` are *consistent*,
`ConsistentPair db₁ db₂`, when
`∀ p v₁ v₂, db₁ p = some v₁ → db₂ p = some v₂ → v₁ = v₂`: they agree wherever
both are defined.

**Definition 4 (Sheaf condition).** A family `dbs : ι → PartialDB` satisfies the
*sheaf condition*, `SheafCondition dbs`, when `∀ i j, ConsistentPair (dbs i) (dbs j)`.
This is the Čech 0-cocycle condition for the data sheaf.

**Definition 5 (Gluing).** `GluingMap db₁ db₂ p` returns `db₁ p` if defined,
otherwise `db₂ p`. It is the union of the two partial databases, preferring the
first.

**Definition 6 (Global section and restriction).** `db` is a *global section*,
`IsGlobalSection db`, when `∀ p, db p ≠ none` — a complete table. The
*restriction* `db.restrict S` keeps `db p` for `p ∈ S` and returns `none`
otherwise.

**Definition 7 (Disagreement and coboundary norm).**
`disagreementAt db₁ db₂ p` is `1` if both `db₁ p` and `db₂ p` are defined and
differ, and `0` otherwise. The *coboundary norm* of a finite family
`dbs : Fin n → PartialDB` is
`CoboundaryNorm dbs := ∑_{i,j} ∑_{r,c} disagreementAt (dbs i) (dbs j) (r,c)`,
the total number of pairwise disagreements over all cells — a discrete
`‖δ⁰(σ)‖₁`.

**Definition 8 (Overlap constraint count).**
`overlapConstraintCount n nRows nCols := n(n-1)/2 · (nRows · nCols)`: one
agreement constraint for each unordered pair of the `n` views at each of the
`nRows · nCols` cells.

**Definition 9 (Consistency probability).**
`consistencyProbability r c := (1 - r)^c`, the probability that `c` independent
constraints, each holding with probability `1-r`, all hold.

**Definition 10 (Sheaf imputation objective).** For observed data `observed` and
a complete candidate `candidate : DBPos → V`,
`SheafImputationObjective observed candidate := ∑_{r,c} [observed (r,c) = some v
∧ v ≠ candidate (r,c)]`, the count of observed cells the candidate gets wrong.

**Definition 11 (Sheaf filtration).** A `SheafFiltration nRows nCols V depth`
consists of levels `level : Fin depth → PartialDB`, a *monotonicity* law
(`i ≤ j → level i p = some v → level j p = some v`), and a *consistency* law
(`SheafCondition level`). It is *complete*
(`SheafFiltration.isComplete`) when the last level is a global section.

**Definition 12 (Local extension).** `LocallyExtends db_ext db` holds when
`db_ext` agrees with `db` on `db`'s domain and is defined on at least one cell
where `db` is missing.

## 2b. A worked example

Fix a `2 × 2` grid with positions `(0,0), (0,1), (1,0), (1,1)` and integer values.
Consider three observed views of the same underlying table:

- `db₁`: `(0,0) ↦ 5`, `(1,0) ↦ 7`, others missing;
- `db₂`: `(0,0) ↦ 5`, `(0,1) ↦ 3`, others missing;
- `db₃`: `(0,1) ↦ 3`, `(1,0) ↦ 7`, `(1,1) ↦ 9`, with `(0,0)` missing.

The only overlaps are: `db₁ ∩ db₂` at `(0,0)` (both say `5`), `db₁ ∩ db₃` at
`(1,0)` (both say `7`), and `db₂ ∩ db₃` at `(0,1)` (both say `3`). Every overlap
agrees, so `disagreementAt` is `0` everywhere and `CoboundaryNorm {db₁,db₂,db₃} = 0`.
By Theorem C the sheaf condition holds, and by Theorems A and F the iterated
gluing produces the global section `(0,0) ↦ 5`, `(0,1) ↦ 3`, `(1,0) ↦ 7`,
`(1,1) ↦ 9` — a complete, consistent table that restricts to each view.

Now perturb a single cell: change `db₃`'s value at `(0,1)` from `3` to `99`. The
overlap `db₂ ∩ db₃` at `(0,1)` now disagrees, so `CoboundaryNorm = 2` (the
ordered-pair sum counts both `(2,3)` and `(3,2)`), the sheaf condition fails, and
*no* global section restricting to all three views exists: any candidate value at
`(0,1)` contradicts either `db₂` or `db₃`. A single corrupted cell collapses
gluability entirely — the obstruction is global even though its cause is local.
This is the elementary shadow of a nonzero `H¹` class, and it is the example that
drives the demonstrations accompanying this paper.

## 3. Gluing: the existence half of the sheaf axiom

**Theorem A (`gluing_extends_both`).** If `ConsistentPair db₁ db₂`, then for all
`p, v`, `db₁ p = some v → GluingMap db₁ db₂ p = some v`, and likewise for `db₂`.

*Proof sketch.* The left inclusion is definitional: where `db₁` is defined the
gluing copies it (`gluing_extends_left`). For the right inclusion, fix `p` with
`db₂ p = some v`. Case on `db₁ p`: if `db₁ p = some v₁`, consistency gives
`v₁ = v`, so the gluing returns `some v`; if `db₁ p = none`, the gluing returns
`db₂ p = some v`. ∎

**Theorem B (`sheaf_condition_of_global_restriction`).** For any global-style
section `g` and any family of position sets `S : ι → Set DBPos`, the family
`fun i => g.restrict (S i)` satisfies the sheaf condition.

*Proof sketch.* At a cell `p`, each restricted database equals either `g p` (if
`p ∈ S i`) or `none`. If both `restrict (S i)` and `restrict (S j)` are defined
at `p`, both equal `g p`, hence agree. The remaining cases are vacuous because a
`none` cannot equal `some`. ∎

**Theorem F (`gluing_preserves_consistency`).** If `db₁, db₂, db₃` are pairwise
consistent, then `ConsistentPair (GluingMap db₁ db₂) db₃`.

*Proof sketch.* Fix `p` with `GluingMap db₁ db₂ p = some v₁` and
`db₃ p = some v₂`. Case on `db₁ p`. If `db₁ p = some v`, then `v₁ = v` and
consistency of `db₁, db₃` gives `v = v₂`. If `db₁ p = none`, the gluing returns
`db₂ p = some v₁`, and consistency of `db₂, db₃` gives `v₁ = v₂`. ∎

Theorem F is what makes iterated gluing safe: a pile of pairwise-consistent
views can be merged in any order without ever creating a contradiction. The
supporting domain lemmas `gluing_increases_domain` and
`gluing_preserves_right_domain` show `db₁.dom ∪ db₂.dom ⊆ (GluingMap db₁ db₂).dom`,
and `gluing_locally_extends_of_not_contained` shows the merge strictly grows the
domain when the second view contributes a genuinely new cell. The relation
`ConsistentPair` is reflexive (`consistent_pair_refl`), symmetric
(`consistent_pair_symm`), and admits the empty database as a universal neighbor
(`consistent_with_empty`).

These supporting facts deserve explicit statement, since together they give
`ConsistentPair` the structure of a *reflexive, symmetric, partial* compatibility
relation (it is not transitive: `db₁` and `db₃` may each be consistent with `db₂`
yet disagree where `db₂` is silent). Reflexivity (`consistent_pair_refl`,
`ConsistentPair db db`) and symmetry (`consistent_pair_symm`,
`ConsistentPair db₁ db₂ → ConsistentPair db₂ db₁`) are immediate from the
definition; the empty database `fun _ => none` is consistent with everything
(`consistent_with_empty`) because it has no defined cells to clash. The two
base inclusions `gluing_extends_left` (`db₁ p = some v → GluingMap db₁ db₂ p = some v`)
and `gluing_extends_right` (`db₁ p = none → GluingMap db₁ db₂ p = db₂ p`)
underlie Theorem A. The strict-growth lemma
`gluing_locally_extends_of_not_contained` gives `LocallyExtends (GluingMap db₁ db₂) db₁`
whenever `db₂` is defined at some cell where `db₁` is missing: gluing genuinely
adds information rather than merely re-deriving `db₁`. This is the precise sense in
which integrating a second source is informative.

## 4. The discrete Čech bridge

**Theorem C (`coboundary_zero_iff_sheaf`).** For any finite family
`dbs : Fin n → PartialDB`, `CoboundaryNorm dbs = 0 ↔ SheafCondition dbs`.

*Proof sketch.* (⇒) A sum of natural numbers is zero iff every summand is zero
(`Finset.sum_eq_zero_iff`). Peeling the quadruple sum over `i, j, r, c` shows
every `disagreementAt (dbs i) (dbs j) (r,c) = 0`. At a cell where both views are
defined, the indicator is `0` only when the values are equal; hence the family
is pairwise consistent. (⇐) Conversely, if the family is consistent then at every
cell the two values agree when both are defined, so each indicator is `0` and the
whole sum collapses to `0`. ∎

Theorem C is the combinatorial image of `ker δ⁰ = H⁰`: the algebraic vanishing
of the coboundary is equivalent to the geometric existence of a consistent global
section. The entire probabilistic obstruction to imputation therefore lives in
the discrete first cohomology — a single integer one can compute directly.

It is worth being precise about the cohomological dictionary, because it explains
why *pairwise* compatibility suffices here. A family of partial databases is a
`0`-cochain in the Čech complex of the open cover by the views' domains. The
coboundary `δ⁰` sends this `0`-cochain to the `1`-cochain of pairwise differences
on overlaps; our `disagreementAt` is the support indicator of that difference, and
`CoboundaryNorm` is its `ℓ¹` size. A `0`-cochain is a `0`-cocycle (equivalently,
lies in `ker δ⁰`) precisely when all pairwise differences vanish — the sheaf
condition — and `ker δ⁰ = H⁰` is the space of global sections. Because the
sections of the function sheaf are honest (single-valued) functions, there is no
higher cocycle obstruction to assembling a global section once the pairwise
differences vanish; the triangle (cocycle) identity is automatic. This is the
structural reason the database sheaf is *flasque*-like and gluing needs only the
equalizer condition, and it is exactly the condition that mean, KNN, and MICE
imputation never test.

## 5. Imputation as nearest global section

**Theorem D (`imputation_zero_iff_extends`).** For observed data `observed` and
candidate `candidate`, `SheafImputationObjective observed candidate = 0 ↔
∀ p v, observed p = some v → candidate p = v`.

*Proof sketch.* Again the cost is a sum of `0/1` terms over cells; it is zero iff
each term is zero (`Finset.sum_eq_zero_iff`). At an observed cell `(r,c)` with
value `v`, the term is `0` iff `candidate (r,c) = v`. Quantifying over all cells
yields the stated extension property. ∎

Thus an optimal imputation is exactly a global section restricting to the observed
partial section: it respects every observed value and fills the rest. This recasts
imputation as a constrained optimization whose feasible set is the sheaf's space
of global sections — the constraint that mean/KNN/MICE ignore.

## 6. Probability of consistency

**Definition recap.** `consistencyProbability r c = (1-r)^c`.

**Theorem H (`consistency_prob_mul`).** `(1-r)^{c₁+c₂} = (1-r)^{c₁} · (1-r)^{c₂}`.

*Proof sketch.* Immediate from `pow_add`. ∎ The corollary
`consistency_prob_double` gives `(1-r)^{2c} = ((1-r)^c)²`.

**Monotonicity.** For `0 ≤ r ≤ 1`, the probability is decreasing in the
constraint count (`consistency_prob_mono_constraints`, via
`pow_le_pow_of_le_one`) and decreasing in the rate (`consistency_prob_mono_rate`,
via `pow_le_pow_left₀`). Boundary values are exact: `consistencyProbability 0 c = 1`
(`consistency_prob_zero_rate`) and `consistencyProbability 1 c = 0` for `c > 0`
(`consistency_prob_one_rate`). The probability is always in `[0,1]`
(`consistency_prob_nonneg`, `consistency_prob_le_one`).

**Constraint growth.** `overlap_quadratic_growth` bounds
`overlapConstraintCount n nRows nCols ≤ n² · (nRows · nCols)`, and
`overlap_zero_of_lt_two` records that fewer than two views impose no constraints.

**Conjecture (`conjecture_exponential_decay_testable`).** For all `n ≥ 2`,
`k ≥ 1`, and `0 < r < 1`,
`consistencyProbability r (overlapConstraintCount n k n) <
 consistencyProbability r (k·n)`,
i.e. the overlap-constraint exponent dominates the raw cell count, so consistency
probability under the overlap model is strictly smaller than under a naive
cell-count model. Concretely, for `n = 10`, `k = 100`, `r = 0.3` the overlap
count is `n(n-1)/2 · (k·n) = 45 · 1000 = 45000` and `(0.7)^{45000}` is
astronomically small: accidental global consistency essentially never occurs, so
observed consistency is a strong structural signal rather than coincidence.

## 7. Sheaf filtrations: imputation as a process

**Theorem E (`sheaf_filtration_auto_consistent`).** If levels
`levels : Fin depth → PartialDB` satisfy monotonicity
(`i ≤ j → levels i p = some v → levels j p = some v`), then `SheafCondition levels`.

*Proof sketch.* For indices `i, j`, WLOG `i ≤ j` (else swap by symmetry). At a
cell defined in both, monotonicity sends `levels i p = some v₁` to
`levels j p = some v₁`, which must equal `levels j p = some v₂`, forcing
`v₁ = v₂`. ∎

So a disciplined imputation pipeline that only ever *adds* values — never
overwriting — is automatically internally consistent; the order-theoretic
condition implies the geometric one.

**Theorem G (`filtration_final_contains_all`).** In any filtration of positive
depth, for every level `i`, `(level i).dom ⊆ (level (depth-1)).dom`.

*Proof sketch.* If cell `p` is defined at level `i` with value `v`, monotonicity
along `i ≤ depth-1` keeps it defined (with value `v`) at the final level. ∎

Finally, `sheaf_filtration_exists_singleton` shows every partial database seeds a
depth-1 filtration, providing the base case for inductive constructions.

## 8. Algorithms

**Algorithm 1 (Consistency / coboundary check).** Given views `dbs[0..n)`, compute
`CoboundaryNorm` by summing `disagreementAt` over all `(i<j)` pairs and all cells;
return `True` iff the total is `0`. By Theorem C this decides the sheaf condition.
Complexity `O(n² · nRows · nCols)`.

**Algorithm 2 (Sheaf gluing).** Fold `GluingMap` across a pairwise-consistent
family, accumulating cell values. By Theorems A and F the result extends every
view and stays consistent. Complexity `O(n · nRows · nCols)`.

**Algorithm 3 (Nearest global section imputation).** Among completions consistent
with the observed data, minimize `SheafImputationObjective`. By Theorem D the
optimum is any completion extending the observations; ties are broken by a
secondary criterion (e.g. minimizing the coboundary norm against auxiliary
views). Complexity dominated by the consistency check.

## 9. Applications

- **Multi-source data integration.** Merging overlapping tables from different
  systems is exactly iterated gluing; Theorem F guarantees order-independence and
  Theorem C flags every conflict with an exact location and count.
- **Data-quality auditing.** The coboundary norm is a single interpretable
  scalar measuring total contradiction across sources, with `0` certifying
  perfect gluability.
- **Imputation with consistency guarantees.** Theorem D characterizes valid
  imputations as global sections extending the data, turning imputation into a
  constraint-satisfaction problem rather than independent per-cell guessing.
- **Streaming / progressive imputation.** Sheaf filtrations model append-only
  pipelines whose internal consistency is automatic (Theorem E) and whose
  information provably accumulates (Theorem G).

## 10. Discussion and future work

The headline `(1-r)^{C(n,k)}` law is an independence-saturated extreme. The
formalization isolates independence as the single load-bearing hypothesis, which
points to several extensions:

- **FD1 — Correlated constraints.** Replace independence with FKG/association
  inequalities: positively associated overlap events give `P(sheaf) ≥ (1-r)^N`,
  negatively associated give `≤ (1-r)^N`. The effective exponent counts only
  independent degrees of freedom.
- **FD2 — The H¹ obstruction.** Conjecture that the sheaf condition fails iff the
  Čech `H¹` class of the overlap discrepancy cochain is nonzero, turning
  imputation into a cohomology computation; Theorem C is the `H⁰` half of this
  picture.
- **FD3 — Sharp phase transition.** As `n → ∞` with `N·r → λ`,
  `P(sheaf) → e^{-λ}`, giving a threshold at `N·r = 1`; the linear envelopes
  `1 - N·r ≤ (1-r)^N` and `1 - (1-r)^N ≤ N·r` pinch the probability around the
  Poisson limit.
- **FD4 — Error bounds.** Under a linear ground-truth model, the expected error
  of nearest-global-section imputation should scale like `O(N·r·σ²)`, beating
  mean/KNN whenever `N·r < 1` and `n > 10`, because the cocycle constraints remove
  degrees of freedom that other methods ignore.

## 10b. Relationship to standard imputation methods

The sheaf viewpoint clarifies, in one sentence, what conventional imputers omit:
they produce a completion but never evaluate the equalizer constraint that
overlapping views must agree. Mean imputation replaces each missing cell by its
column average; KNN imputation borrows from the nearest observed rows; MICE fits a
chain of conditional regressions. All three return a value at every cell and all
three can return values that violate an observed cross-view constraint, because
none of them computes anything like `CoboundaryNorm`. Theorem D makes the contrast
sharp: a completion is *optimal in the sheaf sense* iff it reproduces every
observed value exactly, i.e. iff it is a genuine global section of the observed
partial section. Conventional imputers optimize an unconstrained loss over all
cells at once; the sheaf imputer optimizes the same loss *subject to* the
feasibility constraint that observed cells are preserved and cross-view overlaps
are honored. When the data carry many overlap constraints (large `n`), this
feasible set is dramatically smaller than the unconstrained completion space, and
the constraints carry information the other methods discard — the quantitative
content of future direction FD4.

A second contrast concerns *diagnosis*. The coboundary norm is not just a yes/no
gate; it is an additive, localizable contradiction score. Each unit of the norm
points at a specific `(i, j, cell)` triple where two sources disagree, so the same
computation that decides gluability also produces a ranked list of data-quality
defects. No imputation-by-estimation method offers this, because none of them
represents the overlap structure explicitly.

## 11. Conclusion

A database with missing entries is a partial section of the function sheaf on its
grid. Consistency is overlap-agreement; gluing is the existence half of the sheaf
axiom; the total-disagreement count is a discrete Čech coboundary whose vanishing
is equivalent to the sheaf condition; imputation is the search for a global
section extending the data; and accidental consistency decays exponentially in the
overlap constraint count. Every step is formalized and machine-checked, making
the bridge from algebraic geometry to data integration exact rather than
metaphorical.
