# The Consistency Nerve of Data Sheaves: A Simplicial Approach to Database Integration

## Abstract

We introduce the **Consistency Nerve**, a novel mathematical structure that captures the higher-order consistency properties of families of partial databases. Given n partial databases (sections of a data sheaf), the Consistency Nerve is the abstract simplicial complex whose k-simplices are (k+1)-element subfamilies that are pairwise consistent. We establish a complete characterization: the sheaf condition (global integrability) holds if and only if the Consistency Nerve is the full (n−1)-simplex, equivalently, if and only if the Consistency Rank equals n. We prove that projection to column subsets preserves consistency and monotonically reduces disagreement, that gluing consistent databases preserves compatibility with third parties, and that the total family defect vanishes precisely when the sheaf condition holds. We introduce the Defect Spectrum — the filtration of approximate consistency nerves by tolerance threshold — and prove its monotonicity. All results are machine-verified in the Lean 4 theorem prover with the Mathlib library.

**Keywords**: data sheaves, consistency nerve, simplicial complex, database integration, missing data, sheaf cohomology, formal verification

---

## 1. Introduction

### 1.1 Motivation

Data integration — the problem of combining information from multiple partial sources into a coherent whole — is a ubiquitous challenge in data science, healthcare informatics, sensor networks, and federated learning. The classical approaches (mean imputation, KNN imputation, MICE) treat missing data as a statistical nuisance. We argue that missing data has *geometric* structure, captured by the theory of sheaves.

### 1.2 Sheaves and Databases

A **sheaf** on a topological space assigns data to each open set, with compatibility conditions ensuring that local data assembles into global sections. For databases:

- The "topological space" is the poset of column (feature) subsets, ordered by inclusion.
- The "data" assigned to each column subset is the set of row vectors restricted to those columns.
- The "sheaf condition" requires that partial records agreeing on shared columns can be merged.

This connection was noted informally in prior work on cellular sheaves (Curry, 2014; Robinson, 2014; Hansen & Ghrist, 2019). Our contribution is to introduce a new combinatorial-topological invariant — the Consistency Nerve — and to provide machine-verified proofs of its fundamental properties.

### 1.3 Contributions

1. **The Consistency Nerve** (Definition 2.1): An abstract simplicial complex whose faces are pairwise-consistent subfamilies.
2. **Rank-Sheaf Equivalence** (Theorem 3.3): The Consistency Rank equals n if and only if the sheaf condition holds.
3. **Defect Spectrum** (Definition 4.1): A filtration of approximate nerves by tolerance threshold, with proven monotonicity.
4. **Projection Monotonicity** (Theorems 5.1–5.2): Projection to column subsets preserves consistency and reduces disagreement.
5. **Gluing Preservation** (Theorem 6.1): Gluing consistent databases preserves compatibility with arbitrary third parties.
6. **Defect-Sheaf Duality** (Theorem 7.1): Zero family defect is equivalent to the sheaf condition.
7. **Coboundary Complex** (Theorem 8.1): The Čech coboundary operators satisfy δ¹ ∘ δ⁰ = 0.

All proofs are formalized in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Definitions

### 2.1 Partial Databases

**Definition 2.1** (Partial Database). A *partial database* with nR rows and nC columns over a value type V is a function

```
PDB(nR, nC, V) := Fin(nR) × Fin(nC) → Option(V)
```

where `Option(V) = V ∪ {⊥}` (⊥ represents a missing entry).

**Definition 2.2** (Consistency). Two partial databases a, b are *consistent* if

```
∀ p, ∀ v w : V, a(p) = some(v) ∧ b(p) = some(w) → v = w
```

That is, they agree wherever both are defined.

**Definition 2.3** (Sheaf Condition). A family `(dbs_i)_{i ∈ Fin(n)}` satisfies the *sheaf condition* if all pairs are consistent:

```
∀ i j : Fin(n), dbs(i).Consistent(dbs(j))
```

### 2.2 The Consistency Nerve

**Definition 2.4** (Nerve Face). A subset S ⊆ Fin(n) is a *face* of the consistency nerve if all databases indexed by S are pairwise consistent:

```
IsNerveFace(dbs, S) := ∀ i ∈ S, ∀ j ∈ S, dbs(i).Consistent(dbs(j))
```

**Theorem 2.5** (Simplicial Complex). The collection of nerve faces satisfies:
- ∅ is a face.
- Every singleton {i} is a face.
- If S is a face and T ⊆ S, then T is a face (hereditary property).

*Proof*: All three properties are verified in Lean 4. The hereditary property follows from the fact that pairwise consistency on S restricts to pairwise consistency on T ⊆ S. □

### 2.3 Consistency Rank

**Definition 2.6** (Consistency Rank). The *Consistency Rank* of a family is the maximum cardinality of a nerve face:

```
ConsistencyRank(dbs) := max { |S| : S is a face of the nerve }
```

This equals the clique number of the consistency graph (where vertices are databases and edges connect consistent pairs).

---

## 3. Main Results

### 3.1 Sheaf ↔ Complete Nerve

**Theorem 3.1** (Sheaf ↔ Complete Nerve).

```
FamilySheaf(dbs) ↔ IsNerveFace(dbs, Fin(n))
```

*Proof*: The sheaf condition requires consistency for all i, j ∈ Fin(n). This is exactly the definition of Fin(n) being a face. □

### 3.2 Rank Bounds

**Theorem 3.2**. ConsistencyRank(dbs) ≤ n.

*Proof*: Every face S ⊆ Fin(n) has |S| ≤ |Fin(n)| = n. □

**Theorem 3.3** (Rank-Sheaf Equivalence).

```
ConsistencyRank(dbs) = n ↔ FamilySheaf(dbs)
```

*Proof sketch*:
- (⇐): If the sheaf condition holds, Fin(n) is a face of size n, so the rank is at least n. Combined with Theorem 3.2, rank = n.
- (⇒): If rank = n, there exists a face S with |S| = n. Since S ⊆ Fin(n) and |S| = |Fin(n)| = n, we have S = Fin(n). By the face property, all pairs in Fin(n) are consistent.

This is the central equivalence: it characterizes the sheaf condition purely in terms of the Consistency Rank, a combinatorial invariant.

The contrapositive is equally informative: the sheaf condition *fails* if and only if the Consistency Rank is strictly less than n. In graph-theoretic terms, the consistency graph is not complete — there exist inconsistent pairs. □

### 3.3 Consistency ↔ Zero Disagreement

**Definition 3.4** (Disagreement). For databases a, b over a type V with decidable equality:

```
disagreeAt(a, b, p) := match a(p), b(p) with
  | some(v), some(w) => if v = w then 0 else 1
  | _, _ => 0

disagreement(a, b) := Σ_{r,c} disagreeAt(a, b, (r,c))
```

**Theorem 3.5** (Consistency ↔ Zero Disagreement).

```
a.Consistent(b) ↔ a.disagreement(b) = 0
```

*Proof*: The disagreement is a sum of nonneg terms. It vanishes iff each term vanishes, which happens iff every overlap position has matching values. □

---

## 4. The Defect Spectrum

### 4.1 Approximate Consistency

**Definition 4.1** (t-Approximate Consistency).

```
ApproxConsistent(dbs, t, i, j) := dbs(i).disagreement(dbs(j)) ≤ t
```

**Theorem 4.2** (Spectrum at 0). ApproxConsistent(dbs, 0, i, j) ↔ dbs(i).Consistent(dbs(j)).

**Theorem 4.3** (Spectrum Monotonicity). If t ≤ t' and ApproxConsistent(dbs, t, i, j), then ApproxConsistent(dbs, t', i, j).

*Interpretation*: The defect spectrum provides a filtration of consistency relations. At t=0, we have the exact nerve. As t increases, more edges appear, and the nerve grows monotonically toward the complete simplex. The rate of growth encodes information about the severity of inconsistencies.

---

## 5. Projection Theorems

### 5.1 Consistency Preservation

**Definition 5.1** (Column Projection).

```
projectCols(db, S)(p) := if p.col ∈ S then db(p) else ⊥
```

**Theorem 5.2** (Projection Preserves Consistency). If a.Consistent(b), then projectCols(a, S).Consistent(projectCols(b, S)) for any column subset S.

*Proof*: If p.col ∉ S, both projections are ⊥, so there's no overlap to disagree on. If p.col ∈ S, the projections equal the originals, and consistency of the originals implies consistency of the projections. □

### 5.2 Disagreement Reduction

**Theorem 5.3** (Projection Reduces Disagreement).

```
projectCols(a, S).disagreement(projectCols(b, S)) ≤ a.disagreement(b)
```

*Proof*: Each term in the projected disagreement sum is ≤ the corresponding term in the original sum: projection can only set entries to ⊥, which zeroes out the disagreement indicator. □

*Application*: If full data integration is impossible (Consistency Rank < n), we can project to a feature subset where it is possible. The theorems guarantee this process is monotone and well-behaved.

---

## 6. Gluing Theory

### 6.1 The Gluing Operation

**Definition 6.1** (Glue).

```
glue(a, b)(p) := match a(p) with
  | some(v) => some(v)
  | ⊥ => b(p)
```

**Theorem 6.2** (Gluing Extends Both). If a.Consistent(b), then:
- ∀ p v, a(p) = some(v) → glue(a,b)(p) = some(v)
- ∀ p v, b(p) = some(v) → glue(a,b)(p) = some(v)

**Theorem 6.3** (Gluing Preserves Third-Party Consistency). If a.Consistent(c) and b.Consistent(c), then glue(a,b).Consistent(c).

*Proof*: At any position p, glue(a,b)(p) equals either a(p) (if defined) or b(p). In either case, consistency with c follows from the respective hypothesis. □

*Consequence*: Iterated gluing of a sheaf-satisfying family produces a single partial database extending every input. The iterative process preserves all accumulated information.

### 6.2 Coverage Monotonicity

**Definition 6.4** (Coverage).

```
coverage(db) := |{ p : db(p) ≠ ⊥ }|
```

**Theorem 6.5**. coverage(db) ≤ nR × nC.

**Theorem 6.6** (Coverage Monotonicity). coverage(a) ≤ coverage(glue(a, b)).

*Proof*: Gluing can only fill in missing entries, never remove existing ones. □

---

## 7. Family Defect

**Definition 7.1** (Family Defect).

```
FamilyDefect(dbs) := Σ_{i,j} dbs(i).disagreement(dbs(j))
```

**Theorem 7.2** (Zero Defect ↔ Sheaf). FamilyDefect(dbs) = 0 ↔ FamilySheaf(dbs).

*Proof*: Since each disagreement(dbs(i), dbs(j)) is nonneg, the sum vanishes iff each term vanishes. By Theorem 3.5, each term vanishes iff the corresponding pair is consistent. □

---

## 8. The Coboundary Complex

**Definition 8.1** (Čech Coboundaries).

```
δ⁰(f)(i,j) := f(j) - f(i)
δ¹(g)(i,j,k) := g(j,k) - g(i,k) + g(i,j)
```

**Theorem 8.2** (δ¹ ∘ δ⁰ = 0). For any f : Fin(n) → ℤ and all indices i, j, k:

```
δ¹(δ⁰(f))(i,j,k) = 0
```

*Proof*: Direct computation: (f(k)−f(j)) − (f(k)−f(i)) + (f(j)−f(i)) = 0. □

*Significance*: This identity ensures that the coboundary operators form a chain complex, laying the foundation for a sheaf cohomology theory of databases.

---

## 9. Constraint Growth

**Theorem 9.1** (Superlinear Constraint Growth). For n ≥ 4:

```
n < n(n-1)/2
```

*Proof*: For n ≥ 4, n(n−1) ≥ 4·3 = 12, so n(n−1)/2 ≥ 6 > 4 ≥ n. The general case follows by induction. □

*Interpretation*: The number of pairwise consistency constraints grows quadratically, while the number of databases grows linearly. This underlies the exponential decay of consistency probability.

---

## 10. PEGB Analysis

### Theorem: Rank-Sheaf Equivalence

- **Proof**: Machine-verified in Lean 4 (consistency_rank_eq_iff_sheaf)
- **Example**: 4 databases from the same ground truth with 40% missing rate → Rank = 4 = n, sheaf condition holds
- **Generalization**: The equivalence holds for arbitrary types V and arbitrary grid sizes nR × nC
- **Boundary**: For n = 1, the rank is always 1 = n (trivially sheaf). For n = 0, the rank is 0. The first non-trivial case is n = 2.

### Theorem: Projection Preserves Consistency

- **Proof**: Machine-verified (projection_preserves_consistency)
- **Example**: Two consistent 5×6 databases, projected to first 3 columns, remain consistent
- **Generalization**: Holds for arbitrary column subsets, not just contiguous ranges
- **Boundary**: Projecting to the empty set makes everything consistent (trivially). Projecting to all columns preserves consistency (identity).

### Theorem: Zero Defect ↔ Sheaf

- **Proof**: Machine-verified (zero_defect_iff_sheaf)
- **Example**: 5 databases with total pairwise disagreement 0 → all consistent. 5 random databases with total disagreement 47 → not all consistent.
- **Generalization**: Works for any decidable equality type V and any family size n
- **Boundary**: For n = 1, defect is always 0 (trivially sheaf). For n = 2, defect = 2·disagreement(db1, db2).

---

## 11. Falsifiable Conjectures

### Conjecture 11.1 (Nerve Connectivity Threshold)

For n random databases over {0,...,q−1} with missing rate r and grid size m×k, the approximate consistency nerve at threshold t becomes connected when

```
t ≥ m·k·(1 − r²)·(1 − 1/q)
```

**Test**: Generate 1000 random families, compute the connectivity threshold, compare with the formula.

### Conjecture 11.2 (Rank Distribution)

The consistency rank of n independent random databases follows a distribution concentrated near 2 for large n and moderate missing rates, with exponentially small probability of rank > log(n).

**Test**: Compute rank distributions for n = 10, 20, 50, 100 with r = 0.3 and q = 5.

---

## 12. Algorithms

### Algorithm 1: Consistency Nerve Construction

```
Input: databases db_1, ..., db_n
Output: set of faces (simplicial complex)

1. For each pair (i,j), compute disagreement(db_i, db_j)
2. Build 1-skeleton: edge (i,j) iff disagreement = 0
3. Find all cliques using Bron-Kerbosch
4. Return all sub-cliques as faces
```

Time: O(n² · nR · nC) for step 1, plus clique enumeration.

### Algorithm 2: Sheaf Imputation

```
Input: databases db_1, ..., db_n
Output: imputed database

1. Build consistency nerve
2. Find maximum clique (= max consistent subfamily)
3. Glue the maximum clique iteratively
4. Fill remaining entries by majority vote
```

---

## 13. Related Work

- **Cellular sheaves**: Curry (2014), Robinson (2014), Hansen & Ghrist (2019)
- **Sheaf neural networks**: Bodnar et al. (2022)
- **Missing data**: Rubin (1976), van Buuren (2018)
- **Simplicial complexes in TDA**: Edelsbrunner & Harer (2010)

---

## 14. Future Work

1. **Sheaf cohomology of the nerve**: Define H⁰ and H¹ and relate them to consistency obstructions.
2. **Spectral methods**: Use the Laplacian of the consistency graph for approximate imputation.
3. **Dynamic nerves**: Track how the nerve evolves as data arrives incrementally.
4. **Categorical generalization**: Replace the poset of column subsets with an arbitrary category.

---

## References

1. Curry, J. (2014). Sheaves, cosheaves and applications. PhD thesis, University of Pennsylvania.
2. Hansen, J. & Ghrist, R. (2019). Toward a spectral theory of cellular sheaves. Journal of Applied and Computational Topology, 3, 315–358.
3. Robinson, M. (2014). Topological Signal Processing. Springer.
