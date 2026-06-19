# Sheaf-Theoretic Data Integration: The Information-Order and Colimit Layer of the Database Sheaf

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Computation

---

## Abstract

A database with missing entries is naturally modeled as a *partial section of a
sheaf* on the grid of its cells. We develop the order-theoretic skeleton beneath
this view and prove that the informal slogan "databases form a sheaf" is, made
precise, an *equalizer / colimit* statement in the partial order of partial
databases ordered by information (extension). Our central contribution is a sharp
biconditional characterization, `sheaf_iff_common_extension`: a family of partial
databases admits a single consistent merge **if and only if** it satisfies the
sheaf (pairwise overlap-agreement) condition. We strengthen the previously
known one-directional existence result into this two-way characterization and add
the universal property `glueFamily_is_lub`, which pins the merge down as a genuine
colimit (least common extension) rather than an arbitrary witness. Along the way
we establish that partial databases form a partial order under extension
(`extends_refl`, `extends_trans`, `extends_antisymm`), that the binary gluing is
the join (`gluing_is_lub`), and that the arbitrary-arity colimit `glueFamily`
extends every member (`glueFamily_extends`) and is the least such extension. We
connect this layer to progressive imputation: monotone filtrations are
automatically consistent (`sheaf_filtration_auto_consistent`), and the colimit of a
filtration equals its top level (`filtration_colimit_eq_top`). Finally we record a
quantitative consistency-probability model whose exponential decay `(1−r)^C` in the
number `C` of overlap constraints explains why exact global consistency becomes
rare for wide databases. All results are formally verified.

---

## 1. Introduction

### 1.1 Motivation

Missing data is ubiquitous. Sensors drop readings, survey respondents skip
questions, and instruments are interrupted. The standard response — *imputation* —
treats each missing cell as an isolated estimation problem: mean imputation
replaces a blank with a column average; k-nearest-neighbors borrows from similar
rows; model-based methods (e.g., MICE) regress each variable on the others. These
methods are effective but share an implicit assumption: that the missing entries
are independent subproblems.

This paper takes a different stance. A database with missing entries is a single
geometric object — a partial section of a *sheaf* on the grid of cells — and the
question "can the holes be filled consistently?" is exactly the gluing question of
sheaf theory. Sheaf theory was developed in the 1940s to study how local data on a
space assembles into global data, governed by the *gluing axiom* and obstructed by
*cohomology*. We show that the database setting realizes this apparatus faithfully
and, crucially, that the gluing question has a clean and complete answer.

### 1.2 Contributions

1. **A partial order on partial databases** (the *information order* `Extends`),
   proved reflexive, transitive, and antisymmetric.
2. **The binary gluing is the join** in this order (`gluing_is_lub`), with the
   free "separatedness" half `consistentPair_of_common_extension`.
3. **An arbitrary-arity colimit** `glueFamily`, with its boundary behavior
   (`glueFamily_eq_none_iff`), its gluing property (`glueFamily_extends`), and its
   universal property (`glueFamily_is_lub`).
4. **The main characterization** `sheaf_iff_common_extension`: existence of a
   consistent merge ⟺ the sheaf condition. This upgrades the prior
   existence-only result to a biconditional and adds the universal property.
5. **Connection to progressive imputation:** monotone filtrations are
   automatically consistent (`sheaf_filtration_auto_consistent`), and a
   filtration's colimit is its top level (`filtration_colimit_eq_top`).
6. **A quantitative consistency-probability model** with exponential decay
   `(1−r)^C`, together with its monotonicity and boundary properties.

---

## 2. Definitions

Fix natural numbers `nRows`, `nCols` and a value type `V`.

**Definition 2.1 (Cell grid).** A *position* is a pair `p ∈ DBPos := Fin nRows ×
Fin nCols`, indexing one cell of the grid.

**Definition 2.2 (Partial database).** A *partial database* is a function
`db : DBPos → Option V`. We write `db p = some v` when cell `p` holds value `v`,
and `db p = none` when the cell is missing. The *domain* of `db` is the set
`dom(db) = { p : db p ≠ none }` of filled cells.

**Definition 2.3 (Consistent pair).** Two partial databases `db₁, db₂` are a
*consistent pair*, written `ConsistentPair db₁ db₂`, when
```
∀ p, ∀ v₁ v₂,  db₁ p = some v₁  →  db₂ p = some v₂  →  v₁ = v₂.
```
Only two *filled* cells holding *different* values count as a conflict; blanks
conflict with nothing.

**Definition 2.4 (Sheaf condition).** A family `dbs : ι → PartialDB` indexed by a
type `ι` satisfies the *sheaf condition*, `SheafCondition dbs`, when every pair is
consistent: `∀ i j, ConsistentPair (dbs i) (dbs j)`.

**Definition 2.5 (Gluing map).** For `db₁, db₂`, the *gluing*
`GluingMap db₁ db₂ : PartialDB` is
```
(GluingMap db₁ db₂) p  =  match db₁ p with | some v => some v | none => db₂ p.
```
It prefers the first database where both are defined.

**Definition 2.6 (Information order / Extends).** A database `big` *extends*
`small`, written `Extends big small`, when
```
∀ p v,  small p = some v  →  big p = some v.
```
That is, `big` records every value `small` records, identically, while possibly
filling additional cells.

**Definition 2.7 (Family colimit / glueFamily).** For a family
`dbs : ι → PartialDB`, define
```
glueFamily dbs  p  =  if h : ∃ i, dbs i p ≠ none then dbs (choose h) p else none,
```
using a choice function to select, at each filled cell, a member that has a value
there. (Under the sheaf condition the choice is irrelevant.)

**Definition 2.8 (Global section).** `IsGlobalSection db` holds when `db p ≠ none`
for all `p` — a complete database with no missing values.

**Definition 2.9 (Sheaf filtration).** A `SheafFiltration` of depth `d` is a family
`level : Fin d → PartialDB` that is *monotone* in information (`i ≤ j` implies
`level i` extends to `level j` cellwise) and pairwise *consistent*.

**Definition 2.10 (Overlap constraint count).** For `n` databases on a `nRows ×
nCols` grid,
```
overlapConstraintCount n nRows nCols  =  n·(n−1)/2 · (nRows·nCols),
```
the number of (unordered pair × cell) consistency constraints.

**Definition 2.11 (Consistency probability).** For a per-constraint disagreement
rate `r ∈ ℝ` and a constraint count `C ∈ ℕ`,
```
consistencyProbability r C  =  (1 − r)^C.
```

---

## 3. The Information Order

**Theorem 3.1 (`extends_refl`).** `Extends db db` for every `db`.
*Proof.* Immediate: the implication `small p = some v → big p = some v` is the
identity when `big = small`. ∎

**Theorem 3.2 (`extends_trans`).** If `Extends a b` and `Extends b c` then
`Extends a c`.
*Proof.* Given `c p = some v`, apply the second hypothesis to get `b p = some v`,
then the first to get `a p = some v`. ∎

**Theorem 3.3 (`extends_antisymm`).** If `Extends a b` and `Extends b a` then
`a = b`.
*Proof.* By function extensionality, fix `p` and case on `a p` and `b p`. If
either is `some v`, the two extension hypotheses force the other to equal it; if
both are `none`, they agree. Hence `a p = b p` in all cases. ∎

Theorems 3.1–3.3 establish that `(PartialDB, Extends)` is a partial order:
imputation is upward movement in this order.

**Theorem 3.4 (`consistentPair_of_common_extension`).** If `Extends g a` and
`Extends g b`, then `ConsistentPair a b`.
*Proof (choice-free).* Suppose `a p = some v₁` and `b p = some v₂`. The two
extension hypotheses give `g p = some v₁` and `g p = some v₂`, whence `v₁ = v₂` by
injectivity of `some`. ∎

Theorem 3.4 is the *separatedness* half of the sheaf correspondence: the existence
of a common extension *forces* pairwise consistency, with no choices or extra
hypotheses. It is the "easy" but indispensable direction.

---

## 4. The Binary Gluing is the Join

**Lemma 4.1 (`extends_gluing_left`).** `Extends (GluingMap db₁ db₂) db₁`.
*Proof.* Where `db₁ p = some v`, the match in Definition 2.5 returns `some v`. ∎

**Lemma 4.2 (`extends_gluing_right`).** If `ConsistentPair db₁ db₂` then
`Extends (GluingMap db₁ db₂) db₂`.
*Proof.* Where `db₂ p = some v₂`, either `db₁ p = none` (the gluing returns `db₂
p`) or `db₁ p = some v₁`; consistency forces `v₁ = v₂`, so the gluing again returns
`some v₂`. ∎

**Theorem 4.3 (`gluing_is_lub`).** If `Extends g db₁` and `Extends g db₂`, then
`Extends g (GluingMap db₁ db₂)`.
*Proof.* Fix `p` with `(GluingMap db₁ db₂) p = some v`. Case on `db₁ p`. If
`db₁ p = some v` then `v` comes from `db₁`, and `Extends g db₁` gives `g p = some
v`. If `db₁ p = none` then the value came from `db₂`, and `Extends g db₂` gives
`g p = some v`. ∎

Lemmas 4.1–4.2 and Theorem 4.3 exhibit `GluingMap db₁ db₂` as the **least upper
bound (join)** of `{db₁, db₂}` in the information order: it extends both, and any
common extension extends it. Consistent databases therefore have joins.

---

## 5. The Arbitrary-Arity Colimit

**Theorem 5.1 (`glueFamily_eq_none_iff`).** For every position `p`,
`glueFamily dbs p = none ↔ ∀ i, dbs i p = none`.
*Proof.* If the cell is filled by some member, the `if`-guard in Definition 2.7 is
satisfied and the result is `some _ ≠ none`; contrapositively, `glueFamily dbs p =
none` forces every member to be `none`. Conversely if all members are `none` the
guard fails and the result is `none`. ∎

**Theorem 5.2 (`glueFamily_extends`).** If `SheafCondition dbs`, then for every
index `i`, `Extends (glueFamily dbs) (dbs i)`.
*Proof.* Suppose `dbs i p = some v`. Then the existence guard holds, so
`glueFamily dbs p = dbs (choose h) p` for some chosen index. Since the chosen
member has *some* value at `p` and the family is pairwise consistent, that value
equals `v`. Hence `glueFamily dbs p = some v`. (This direction uses the sheaf
condition and the axiom of choice.) ∎

**Theorem 5.3 (`glueFamily_is_lub`).** If `Extends g (dbs i)` for all `i`, then
`Extends g (glueFamily dbs)`.
*Proof (choice-free).* Suppose `glueFamily dbs p = some v`. By construction the
value `v` equals `dbs j p` for the chosen index `j`, i.e. `dbs j p = some v`. The
hypothesis `Extends g (dbs j)` then gives `g p = some v`. ∎

Theorems 5.2 and 5.3 jointly exhibit `glueFamily dbs` as the **colimit** (least
common extension) of the diagram `dbs`: it extends every member, and it is the
least object that does so. By antisymmetry (Theorem 3.3) this colimit is *unique*.

---

## 6. Main Theorem: Databases Form a Sheaf

**Theorem 6.1 (`sheaf_iff_common_extension`).**
```
SheafCondition dbs   ↔   ∃ g, ∀ i, Extends g (dbs i).
```

*Proof.*
- **(⟹) Gluing axiom.** Assume `SheafCondition dbs`. Take `g = glueFamily dbs`.
  By Theorem 5.2, `Extends g (dbs i)` for all `i`. Hence a common extension exists.
- **(⟸) Separatedness.** Assume `g` extends every member. For any indices `i, j`,
  both `dbs i` and `dbs j` are extended by `g`, so Theorem 3.4 gives
  `ConsistentPair (dbs i) (dbs j)`. As `i, j` were arbitrary, `SheafCondition dbs`
  holds. ∎

The two directions carry distinct meaning. The forward direction is the **gluing
axiom**: pairwise agreement is *sufficient* for a global merge, with the explicit
colimit witness `glueFamily`. The reverse direction is **separatedness**: pairwise
agreement is *necessary*, since any merge forces overlap-consistency. Together they
identify the sheaf condition as the *exact* criterion for consistent imputability —
there is no gap between local agreement and global gluability, and (by Theorem 5.3
and antisymmetry) the merge is the unique least common extension. This sharpens a
prior one-directional existence statement into a biconditional with a universal
property.

---

## 7. Progressive Imputation as a Colimit

**Theorem 7.1 (`sheaf_filtration_auto_consistent`).** If a family
`levels : Fin d → PartialDB` is monotone in information (`i ≤ j` implies `levels i`
cellwise extends into `levels j`), then `SheafCondition levels`.
*Proof.* For indices `i, j`, by trichotomy assume WLOG `i ≤ j`. Monotonicity sends
any filled cell of `levels i` to the same value in `levels j`; hence the two levels
agree wherever both are defined. The symmetric case is identical. ∎

Thus the only discipline progressive imputation needs is *monotonicity* (never
erase known data); consistency is then automatic.

**Theorem 7.2 (`filtration_colimit_eq_top`).** For a `SheafFiltration F` of
positive depth `d`, the colimit of the levels equals the top level:
`glueFamily F.level = F.level ⟨d−1⟩`.
*Proof sketch.* By monotonicity the top level extends every level
(`filtration_final_contains_all` shows domains accumulate into the top), so the top
level is itself a common extension and is extended by it; by the colimit universal
property (Theorem 5.3) and antisymmetry (Theorem 3.3), the colimit coincides with
the top level. ∎

Progressive imputation therefore *converges to its final stage*: taking the colimit
of a filtration is the same as reading off its most-complete level.

---

## 8. Quantitative Consistency Probability

Treating each of the `C` overlap constraints as independently satisfied with
probability `1−r`, the probability that *all* hold is
`consistencyProbability r C = (1−r)^C`.

**Theorem 8.1 (`consistency_prob_mono_constraints`).** For `0 ≤ r ≤ 1` and
`c₁ ≤ c₂`, `consistencyProbability r c₂ ≤ consistencyProbability r c₁`.
*Proof.* `(1−r) ∈ [0,1]`, and a base in `[0,1]` gives a decreasing power
sequence. ∎

**Theorem 8.2 (`consistency_prob_mono_rate`).** For fixed `c` and `r₁ ≤ r₂ ≤ 1`,
`consistencyProbability r₂ c ≤ consistencyProbability r₁ c`.
*Proof.* `1−r₂ ≤ 1−r₁` with nonnegative bases; raise to the `c`-th power. ∎

**Theorem 8.3 (`consistency_prob_mul`).** `consistencyProbability r (c₁+c₂) =
consistencyProbability r c₁ · consistencyProbability r c₂`.
*Proof.* `(1−r)^{c₁+c₂} = (1−r)^{c₁}(1−r)^{c₂}`. ∎

**Boundary cases.** `consistencyProbability 0 c = 1` (`consistency_prob_zero_rate`)
and, for `c > 0`, `consistencyProbability 1 c = 0` (`consistency_prob_one_rate`).
Also `0 ≤ consistencyProbability r c ≤ 1` on `r ∈ [0,1]`
(`consistency_prob_nonneg`, `consistency_prob_le_one`).

Because `overlapConstraintCount n nRows nCols = n(n−1)/2 · (nRows·nCols)` grows
quadratically in the number of views and linearly in the grid size
(`overlap_quadratic_growth`), the consistency probability `(1−r)^C` decays
*exponentially* as databases widen. This explains, quantitatively, why exact global
consistency is rare for wide tables and why a method that honors the exponentially
many overlap constraints exposes structure invisible to blank-by-blank imputation.

---

## 9. Algorithms

### 9.1 Pairwise consistency check

To test `ConsistentPair db₁ db₂`, scan all cells and report a conflict whenever
both databases hold differing values. Cost: `O(nRows·nCols)`.

### 9.2 Family gluing (colimit construction)

To compute `glueFamily dbs` over `k` views on an `nRows×nCols` grid: for each cell,
take the value of the first member that has one (or `none` if all are blank). Cost:
`O(k·nRows·nCols)`. By Theorem 5.2, when the family is consistent the result
extends every member and, by Theorem 5.3, is the least such extension.

### 9.3 Sheaf imputation by least common extension

Given observed partial data viewed as a family of partial databases (e.g., one per
overlapping feature subset), (i) verify the sheaf condition by pairwise checks
(§9.1); (ii) if it holds, return the colimit `glueFamily` (§9.2) as the canonical
imputation; (iii) if it fails, the failing pair localizes a genuine contradiction
that *no* consistent imputation can resolve. The cost is `O(k²·nRows·nCols)` for
the check and `O(k·nRows·nCols)` for the merge.

---

## 10. Applications

- **Pre-imputation diagnosis.** The sheaf condition is a tripwire: failing it
  certifies that no consistent fill exists, so any imputed values mask a real
  contradiction. This is actionable before modeling.
- **Canonical merges in data integration.** When several systems export
  overlapping partial views of the same entities, the colimit `glueFamily` is the
  uniquely-defined least common extension — the principled merge that adds only
  what the data forces.
- **Streaming / progressive imputation.** Monotone refinement pipelines are
  automatically consistent (Theorem 7.1) and converge to their final level
  (Theorem 7.2), justifying incremental fill-in strategies.
- **Difficulty estimation.** The exponential law `(1−r)^C` predicts how rare exact
  global consistency is as a function of width and noise, guiding when to expect
  contradictions and how aggressively to partition the feature space.

---

## 11. Discussion

The value of the order-theoretic layer is conceptual economy. By recasting "form a
sheaf" as "consistent families have colimits in the information order," the entire
content of data gluing reduces to three elementary order facts (Theorems 3.1–3.3),
one free necessity lemma (Theorem 3.4), and one choice-using sufficiency
construction (Theorem 5.2). The asymmetry is instructive: *separatedness is free,
gluing is the work.* All the genuinely nontrivial mathematical content of
"databases form a sheaf" lives in the forward direction of Theorem 6.1 — precisely
the equalizer that grid-agnostic imputation methods ignore.

The biconditional also clarifies what imputation *should* return. Because the
colimit is the unique least common extension (Theorems 5.3 and 3.3), there is a
distinguished correct answer whenever one exists; methods that introduce extra
structure overshoot it in the information order.

---

## 12. Future Directions

1. **`Extends` as a conditionally complete lattice.** The information order has a
   least element (the empty database) and arbitrary meets (cellwise agreement,
   else `none`); joins exist on the consistent sublattice via `glueFamily`.
   Conjecture: `(PartialDB, Extends)` is a complete meet-semilattice with bottom,
   conditionally complete as a lattice.
2. **Vanishing Čech `H¹`.** Define an alternating complex `C⁰→C¹→C²` valued in an
   abelian group with `δ⁰` the difference of restrictions; conjecture every
   1-cocycle is a coboundary (`H¹ = 0`), so the gluing obstruction is always
   trivial — explaining why pairwise consistency suffices.
3. **Nerve connectivity governs gluing complexity.** On the consistency (nerve)
   graph with edges for overlapping consistent pairs, conjecture that a family
   glues to a global section iff it is pairwise consistent and its domains cover the
   grid, with merge steps equal to `k −` (number of connected components),
   yielding an explicit `O(k·nRows·nCols)` spanning-forest algorithm.
4. **Restriction commutes with colimit.** Conjecture
   `(glueFamily F.level).restrict S = glueFamily (fun i ↦ (F.level i).restrict S)`
   for all covers, making `glueFamily` a natural transformation.
5. **Sharp consistency-probability threshold** from the order/colimit layer,
   combining the exponential law with the nerve-connectivity structure.

---

## 13. Conclusion

We have shown that the slogan "databases form a sheaf" is, precisely, the statement
that a family of partial databases admits a consistent merge if and only if it is
pairwise overlap-consistent (`sheaf_iff_common_extension`), and that this merge is
the unique colimit in the information order (`glueFamily_is_lub`, `extends_antisymm`).
Consistent databases have joins; consistent families have colimits; and progressive
imputation is the act of taking those colimits level by level. Missing-data
imputation is, in a literal and verified sense, a problem of gluing local sections
into a global one.
