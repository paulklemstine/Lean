# Sheaf-Theoretic Data Integration: Deepening the Gluing-Consistency Correspondence

## Abstract

We extend the sheaf-theoretic framework for database consistency and missing data imputation, building on the catalog's foundational `SheafDataIntegration` formalization. Our main contributions are: (1) a proof that gluing of pairwise-consistent partial databases is **associative**, establishing well-definedness of multi-source data integration independent of combination order; (2) a **coverage-completeness theorem** showing that consistent families covering all positions assemble into global sections via fold-gluing; (3) formalization of the **feature-subset sheaf** with constructive gluing on column subsets; (4) a **coboundary-Čech bridge** connecting discrete database disagreement to cohomological obstruction; and (5) **strengthened consistency probability bounds** including strict monotonicity, log-linearity, and exponential decay to zero. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

The observation that databases with missing entries form partial sections of a sheaf connects two apparently disparate fields: relational database theory and algebraic topology. The catalog's `SheafDataIntegration.lean` (Computation) establishes the basic framework: partial databases as functions to `Option V`, consistency as overlap agreement, gluing as preferential union, and the coboundary norm as the algebraic measure of inconsistency.

This work deepens the correspondence in five directions:

1. **Algebraic structure of gluing** (§3–4): We prove gluing is associative for consistent triples, and that iterated fold-gluing preserves consistency with all list elements.

2. **Constructive global section assembly** (§5): The coverage-completeness theorem provides a constructive algorithm for assembling global sections.

3. **Feature-subset sheaf** (§6): We formalize the concrete sheaf on the poset of feature (column) subsets, proving presheaf functoriality and the gluing axiom.

4. **Coboundary bridge** (§7): We connect database coboundary norms to the Čech cohomological framework.

5. **Quantitative refinements** (§8): Strict monotonicity, log-linearity, and asymptotic decay of consistency probability.

### 1.1 Catalog References

This work builds directly on:
- `Catalog/Computation/SheafDataIntegration.lean`: foundational definitions and `sheaf_condition_of_global_restriction`
- `Catalog/Bridges/SheafObstruction.lean`: `overlap_pair_count_bound`, `constant_presheaf_is_sheaf_on_finite_locale`
- `Catalog/MachineLearning/Coboundary.lean`: `locally_consistent_has_global_section`, `coboundary_composition_zero`

## 2. Definitions

**Definition 2.1** (Partial Database). For natural numbers `nRows, nCols` and a type `V`, a *partial database* is a function `PartialDB' nRows nCols V := Fin nRows × Fin nCols → Option V`.

**Definition 2.2** (Consistency). Two partial databases `db1, db2` are *consistent* (`ConsistentPair'`) if for every position `p` and values `v1, v2`, `db1 p = some v1 ∧ db2 p = some v2 → v1 = v2`.

**Definition 2.3** (Gluing Map). The *gluing* `GluingMap' db1 db2` returns `db1 p` when defined, `db2 p` otherwise.

**Definition 2.4** (Global Section). A partial database is a *global section* (`IsGlobalSection'`) if `db p ≠ none` for all `p`.

**Definition 2.5** (Fold-Glue). For a list of partial databases, `foldGlue dbs := dbs.foldl GluingMap' (emptyDB ...)`.

**Definition 2.6** (Feature Database). `FeatureDB nRows S V := Fin nRows → S → V` where `S : Finset (Fin nCols)`. Restriction: `db.restrict hTS r t := db r ⟨t.val, hTS t.property⟩`.

**Definition 2.7** (Coboundary Norm). `CoboundaryNorm' dbs := Σ_{i,j,r,c} disagreementAt'(dbs_i, dbs_j, (r,c))`.

**Definition 2.8** (Consistency Probability). `consistencyProb r c := (1-r)^c`.

## 3. Gluing Associativity

**Theorem 3.1** (Gluing Associativity). *For three pairwise-consistent partial databases a, b, c:*
```
GluingMap' (GluingMap' a b) c = GluingMap' a (GluingMap' b c)
```

*Proof sketch.* By function extensionality, we verify equality at each position `p`. Case-split on `a p` and `b p`:
- If `a p = some va`: both sides equal `some va` (left side: `GluingMap'` of `some va` with `c` gives `some va`; right side: `GluingMap' a _` returns `a p = some va`).
- If `a p = none, b p = some vb`: left side = `GluingMap' (some vb) c` = `some vb`; right side = `GluingMap' none (GluingMap' b c)` = `GluingMap' (some vb) c` via `b p = some vb` dominating in `GluingMap' b c`.
- If `a p = none, b p = none`: both sides reduce to `c p`. □

**Remark.** Without the consistency hypotheses, associativity can fail when `a` and `b` disagree at a position where `c` provides a "tiebreaker." The consistency condition is *necessary*, not merely sufficient.

### PEGB for Theorem 3.1

- **Proof**: Complete Lean 4 proof by case analysis on `a p` and `b p`. Machine-verified.
- **Example**: Three patient databases: A has (blood pressure, cholesterol), B has (cholesterol, glucose), C has (glucose, BMI). Pairwise consistent on overlaps. Associativity ensures the final merged record is independent of merge order.
- **Generalization**: Extends to n-fold gluing via fold. The natural next level is commutativity: does `GluingMap' a b = GluingMap' b a` hold for consistent pairs? No — the gluing operation is *not* commutative (it prefers the first argument). However, the *domains* of the gluings are the same, and the *values* agree on the union of domains.
- **Boundary**: Breaks when consistency fails. Also, GluingMap' is not commutative — `GluingMap' a b ≠ GluingMap' b a` in general, even for consistent pairs (they differ where both are defined with the same value, preferring different sources).

## 4. Fold-Gluing Consistency

**Theorem 4.1** (Fold-Gluing Consistency). *If `dbs` is a list of pairwise-consistent partial databases, then `foldGlue dbs` is consistent with every element `dbs[k]`.*

*Proof sketch.* By induction on the list using `List.reverseRecOn`. The base case is trivial (empty fold is the empty DB). The inductive step uses `gluing_preserves_consistency'`: if the accumulated fold is consistent with all previous elements, and the next element is consistent with all previous elements, then their gluing is consistent with everything. □

This theorem is the inductive engine that powers the coverage-completeness result.

## 5. Coverage-Completeness

**Theorem 5.1** (Coverage-Completeness). *If `dbs` is pairwise consistent and covers all positions, then `foldGlue dbs` is a global section.*

*Proof sketch.* Suppose for contradiction that `foldGlue dbs` is not defined at some position `p`. By the coverage hypothesis, some `dbs[k]` is defined at `p`. But the fold-glue process progressively accumulates all entries: `foldl GluingMap' acc rest` at position `p` is defined whenever `acc p ≠ none` or any element of `rest` defines `p`. Since `dbs[k]` appears somewhere in the fold, `p` must be defined in the result — contradiction. □

### PEGB for Theorem 5.1

- **Proof**: By contradiction and inner induction on the fold. Machine-verified.
- **Example**: Three databases covering a 2×3 grid: d1 covers row 0, d2 covers the middle, d3 covers row 1 and column 2. Their fold-glue fills all 6 cells.
- **Generalization**: Extends to infinite families via directed colimits. The natural next level: replace lists with arbitrary directed systems of consistent partial databases.
- **Boundary**: Fails without the covering hypothesis (trivially — uncovered positions remain missing). Also fails without pairwise consistency (fold-glue may produce values that disagree with some source).

## 6. Feature-Subset Sheaf

**Theorem 6.1** (Presheaf Functoriality). *Feature restriction is functorial: for U ⊆ T ⊆ S,*
```
(db.restrict hTS).restrict hUT = db.restrict (hUT.trans hTS)
```
*and*
```
db.restrict (refl S) = db
```

**Theorem 6.2** (Feature Gluing). *If `dbS : FeatureDB nRows S V` and `dbT : FeatureDB nRows T V` are feature-consistent (agree on S ∩ T), there exists `dbST : FeatureDB nRows (S ∪ T) V` that restricts to `dbS` and `dbT`.*

*Proof sketch.* Construct `dbST` by: if `f ∈ S`, use `dbS r ⟨f, _⟩`; otherwise `f ∈ T \ S`, use `dbT r ⟨f, _⟩`. The restriction to S is immediate. The restriction to T requires the consistency hypothesis for features in S ∩ T. □

**Theorem 6.3** (Global Restriction Consistency). *Restricting a global feature database to any two subsets always produces feature-consistent restrictions.*

### PEGB for Theorem 6.2

- **Proof**: Constructive — explicitly builds the glued database. Machine-verified.
- **Example**: Two clinical studies: Study A records {age, weight, cholesterol}, Study B records {cholesterol, glucose, HbA1c}. If cholesterol values agree across studies, the studies can be merged into a single dataset with all 5 features.
- **Generalization**: The sheaf on the poset of feature subsets is a special case of a sheaf on a finite lattice. The general theory of sheaves on finite posets (via nerve constructions) provides a categorical generalization.
- **Boundary**: Breaks when there are more than two overlapping subsets with circular disagreements: A agrees with B on columns {1,2}, B agrees with C on {2,3}, but A and C disagree on {1,3}. The pairwise condition is necessary for each pair.

## 7. Coboundary-Čech Bridge

**Theorem 7.1** (Coboundary-Sheaf Equivalence). *`CoboundaryNorm' dbs = 0 ↔ SheafCondition' dbs`.*

This connects the algebraic (sum-of-disagreements = 0) and geometric (pairwise consistency) characterizations.

**Theorem 7.2** (Coboundary Symmetry). *`disagreementAt' db1 db2 p = disagreementAt' db2 db1 p`.*

**Theorem 7.3** (Coboundary Vanishing on Global Restrictions). *Restricting a total function to any family of position masks gives coboundary norm zero.*

The coboundary bridge imports the full machinery of Čech cohomology:
- **H⁰** = global sections = consistent completions
- **δ⁰** = coboundary operator = disagreement counter
- **ker(δ⁰)** = consistent families (sheaf condition)
- **H¹** = obstruction to global completion

The catalog's `coboundary_composition_zero` (from Coboundary.lean) shows δ¹ ∘ δ⁰ = 0, establishing the cochain complex structure. Our results provide the data-integration interpretation of this algebraic identity.

## 8. Quantitative Refinements

**Theorem 8.1** (Strict Monotonicity). *For 0 < r < 1 and c₁ < c₂:*
```
consistencyProb r c₂ < consistencyProb r c₁
```

This strengthens the catalog's weak monotonicity (≤) to strict (<).

**Theorem 8.2** (Log-Linearity). *For 0 < r < 1:*
```
log(consistencyProb r c) = c · log(1 - r)
```

**Theorem 8.3** (Exponential Decay). *For 0 < r < 1:*
```
lim_{c→∞} consistencyProb r c = 0
```

**Theorem 8.4** (Product Rule). *`consistencyProb r (c₁ + c₂) = consistencyProb r c₁ · consistencyProb r c₂`.*

### PEGB for Theorem 8.3

- **Proof**: Direct application of `tendsto_pow_atTop_nhds_zero_of_lt_one`. Machine-verified.
- **Example**: For r=0.3 and c=4500 (a 10-column, 100-row database), P ≈ 10^{-697}.
- **Generalization**: The decay rate log(1-r) could be replaced by any quantity in (-∞, 0), yielding a parametric family of decay models.
- **Boundary**: At r=0, P=1 always (no decay). At r=1, P=0 immediately for c≥1. The interesting regime is 0 < r < 1 where the decay is geometric.

## 9. Cross-Domain Bridge: Čech Cochain Complex ↔ Database Coboundary

The deepest structural insight connects two independently formalized constructions:

1. **Database coboundary** (SheafDataIntegration): counts disagreements between partial databases
2. **Čech cochain complex** (Coboundary.lean): the sequence δ⁰ : C⁰ → C¹ → C² with δ¹ ∘ δ⁰ = 0

The bridge: for each position `(r,c)`, assign a real-valued 0-cochain by `f(i) = val(dbs_i(r,c))` where `val : V → ℝ` is any valuation. Then the Čech coboundary `(δ⁰f)(i,j) = f(j) - f(i)` measures the valuation difference, while the database disagreement indicator `disagreementAt'` measures the binary difference.

The key relation: `|δ⁰f|₁ ≤ max_val_diff · CoboundaryNorm`. This imports the full Čech cohomological machinery into data integration: spectral sequences for computing obstruction groups, Mayer-Vietoris sequences for decomposing consistency problems, and derived functor cohomology for abstract sheaf-theoretic reasoning.

## 10. Discussion and Future Work

### 10.1 Practical Implications

The sheaf framework provides a principled foundation for data integration:

1. **Validation**: The coboundary norm gives a single number measuring total inconsistency across all data sources.
2. **Integration order**: Gluing associativity ensures distributed integration is well-defined.
3. **Completeness certification**: The coverage theorem certifies when full imputation is achievable.
4. **Complexity estimation**: The exponential decay theorem quantifies the difficulty of consistency.

### 10.2 Limitations

- The current framework treats all positions uniformly; real databases have typed columns.
- The binary consistency model (agree/disagree) doesn't capture "approximate" agreement.
- The exponential decay model assumes independent constraints, which is rarely true in practice.

### 10.3 Future Directions

See FUTURE_DIRECTIONS.md for detailed research directions, including:
- Approximate sheaves with tolerance parameters
- Weighted coboundary norms for soft constraints
- Directed sheaves for temporal databases
- Higher cohomology groups for multi-way inconsistencies

## References

1. Leray, J. (1945). Sur la forme des espaces topologiques et sur les points fixes des représentations. *J. Math. Pures Appl.* 24, 95–167.
2. Grothendieck, A. (1957). Sur quelques points d'algèbre homologique. *Tôhoku Math. J.* 9(2), 119–221.
3. Robinson, M. (2014). *Topological Signal Processing.* Springer.
4. Curry, J. (2014). Sheaves, cosheaves and applications. *arXiv:1303.3255*.
5. Ghrist, R. (2014). *Elementary Applied Topology.* Createspace.
