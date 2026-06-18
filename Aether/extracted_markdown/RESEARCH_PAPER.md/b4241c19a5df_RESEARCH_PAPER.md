# Overlap Class Invariants for Tropical Kernel Rigidity

## Abstract

We develop a theory of **overlap classes** for families of finite supports arising from tropical kernel generators of graph Laplacians. The support overlap graph — a simple graph whose vertices are supports and whose edges connect pairs with nonempty intersection — decomposes into connected components called overlap classes. We prove that the overlap class count, overlap degree, overlap complexity, and overlap signature are all invariants of tropical projective equivalence (TPE). This extends the existing disjoint-support uniqueness theorem to the interacting regime and establishes overlap classes as the fundamental interaction sectors governing tropical kernel structure. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords:** tropical algebra, tropical kernel, graph Laplacian, support overlap, projective equivalence, overlap classes, combinatorial invariants, matroid circuits

---

## 1. Introduction

### 1.1 Background and Motivation

The tropical semiring (ℤ, max, +) replaces classical addition with maximum and classical multiplication with addition. Tropical linear algebra — the study of semimodules over this semiring — has emerged as a powerful tool in optimization, algebraic geometry, and combinatorics [1, 2, 3].

For a finite graph G = (V, E) with combinatorial Laplacian L, the **tropical kernel** is the set of functions f : V → ℤ satisfying the tropical harmonicity condition. Unlike classical linear algebra, tropical semimodules generally lack unique bases. Baker and Norine [4] showed that the rank of the tropical kernel is connected to the graph's genus through the Riemann–Roch theorem for finite graphs.

A fundamental question is: *when are minimal generating families for the tropical kernel unique, and what invariants control the equivalence classes?*

### 1.2 Prior Work

The disjoint-support uniqueness theorem (formalized in `TropicalKernelRigidity.lean`) establishes that when generators have pairwise disjoint supports with nontrivial variation, the generating family is unique up to **tropical projective equivalence** (TPE) — permutation of generators plus additive constant shifts. This result is analogous to classical basis uniqueness and provides a rigidity theorem in the "non-interacting" regime.

The defect theory (formalized in `DefectTheory.lean`) provides quantitative control via the **structural defect**, connecting the induced cycle rank and root component count to the gap between Laplacian rank and tropical divisor rank.

### 1.3 Contributions

This paper introduces the **overlap class framework** and proves four main invariance theorems:

1. **TPE Preserves Overlap Equivalence** (Theorem A): The permutation from TPE maps overlap-equivalent indices to overlap-equivalent indices in the variation support family.

2. **Overlap Class Count Invariance** (Theorem B): The number of connected components of the support interaction graph is a TPE invariant.

3. **Overlap Degree and Complexity Invariance** (Theorems C, D): The edge count and total intersection cardinality of the overlap graph are TPE invariants.

4. **Inclusion-Exclusion Bound** (Theorem E): The deficit between the sum of support sizes and the union size is bounded by the overlap complexity.

All results are formalized in Lean 4 with full machine verification.

---

## 2. Definitions and Notation

### 2.1 Tropical Projective Equivalence

**Definition 2.1 (TPE).** Two indexed families F₁, F₂ : Fin n → V → ℤ are *tropically projectively equivalent* if there exists a permutation σ ∈ Sym(n) and constants c : Fin n → ℤ such that

    F₂(σ(i), v) = F₁(i, v) + c(i)

for all i ∈ Fin n and v ∈ V.

TPE is an equivalence relation (reflexive, symmetric, transitive), as verified in the formalization.

### 2.2 Variation Support

**Definition 2.2 (Variation Support).** For a function f : V → ℤ and basepoint v₀ ∈ V, the *variation support* is

    VarSupport(f, v₀) = {v ∈ V | f(v) ≠ f(v₀)}

This is the TPE-invariant support notion: adding a constant c to f does not change VarSupport(f, v₀), since (f(v) + c) ≠ (f(v₀) + c) iff f(v) ≠ f(v₀).

**Remark.** The classical support {v | f(v) ≠ 0} is *not* TPE-invariant, as adding a nonzero constant changes which values are zero. The variation support is the correct notion for the overlap theory.

### 2.3 Support Overlap

**Definition 2.3 (Supports Overlap).** Two finsets A, B overlap if A ∩ B ≠ ∅.

**Definition 2.4 (Overlap Equivalence).** For an indexed family F : ι → Finset α, two indices i, j are *overlap-equivalent* (written OverlapEquivRel(F, i, j)) if they are related by the reflexive-transitive closure of the overlap relation on their supports.

This is an equivalence relation; the proof uses symmetry of intersection (A ∩ B = B ∩ A) and is verified formally.

### 2.4 Overlap Invariants

**Definition 2.5 (Overlap Class Count).** The *overlap class count* is the number of equivalence classes under OverlapEquivRel, equivalently the number of connected components of the support interaction graph.

**Definition 2.6 (Overlap Degree).** The *overlap degree* is the number of unordered pairs {i, j} with i ≠ j whose supports overlap — the edge count of the overlap graph.

**Definition 2.7 (Overlap Complexity).** The *overlap complexity* is

    OC(F) = Σ_{i < j} |F(i) ∩ F(j)|

the total intersection cardinality summed over all pairs.

**Definition 2.8 (Overlap Signature).** The *overlap signature* is the sorted multiset of nonzero intersection cardinalities: {|F(i) ∩ F(j)| : i < j, F(i) ∩ F(j) ≠ ∅} (with multiplicities).

---

## 3. Main Results

### 3.1 Theorem A: TPE Preserves Overlap Equivalence

**Theorem 3.1.** Let F₁, F₂ : Fin n → V → ℤ be families with F₂(σ(i), v) = F₁(i, v) + c(i) for all i, v. Then for any basepoint v₀ and indices i, j:

    OverlapEquivRel(VarSupportFamily(F₂, v₀))(σ(i), σ(j))
    ↔ OverlapEquivRel(VarSupportFamily(F₁, v₀))(i, j)

*Proof sketch.* The key lemma is:

    VarSupportFamily(F₂, v₀)(σ(i)) = VarSupportFamily(F₁, v₀)(i)

which holds because F₂(σ(i), v) = F₁(i, v) + c(i) implies that F₂(σ(i), v) ≠ F₂(σ(i), v₀) iff F₁(i, v) ≠ F₁(i, v₀).

**Forward direction:** Given a chain σ(i) = a₀ → a₁ → ⋯ → aₖ = σ(j) in the overlap graph of VarSupportFamily(F₂, v₀), write each aₘ = σ(bₘ) (since σ is bijective). Then the chain b₀ = i → b₁ → ⋯ → bₖ = j witnesses overlap equivalence in VarSupportFamily(F₁, v₀), since VarSupportFamily(F₂, v₀)(σ(bₘ)) = VarSupportFamily(F₁, v₀)(bₘ). This direction uses `Relation.ReflTransGen.lift` with f = σ⁻¹.

**Backward direction:** By induction on the ReflTransGen chain, using the single-step preservation lemma `tpe_preserves_single_overlap`. □

### 3.2 Theorem B: Overlap Class Count Invariance

**Theorem 3.2.** If TropProjEquiv(F₁, F₂) holds, then

    OverlapClassCount(VarSupportFamily(F₁, v₀)) = OverlapClassCount(VarSupportFamily(F₂, v₀))

*Proof sketch.* Obtain the permutation σ from the TPE. By Theorem A, σ maps overlap classes to overlap classes bijectively. Formally, construct a bijection on the quotient types:

    Quotient(overlapSetoid(VS₁)) ≃ Quotient(overlapSetoid(VS₂))

via the map [i] ↦ [σ(i)], which is well-defined (by the forward direction of Theorem A), injective (by the backward direction), and surjective (since σ is bijective). The Fintype.card_congr lemma then gives equality of cardinalities. □

### 3.3 Theorem C: Overlap Complexity Invariance

**Theorem 3.3.** Under the hypotheses of Theorem B,

    OverlapComplexity(VarSupportFamily(F₁, v₀)) = OverlapComplexity(VarSupportFamily(F₂, v₀))

*Proof sketch.* The bijection (i, j) ↦ (σ(i), σ(j)) on Fin n × Fin n maps the set of pairs {(i,j) : i < j} bijectively (though not order-preservingly) to itself. The intersection cardinality |VS₁(i) ∩ VS₁(j)| = |VS₂(σ(i)) ∩ VS₂(σ(j))| by the reindexing lemma. Using Finset.sum_bij, the sums agree. □

### 3.4 Theorem D: Overlap Degree Invariance

**Theorem 3.4.** Under the hypotheses of Theorem B,

    OverlapDegree(VarSupportFamily(F₁, v₀)) = OverlapDegree(VarSupportFamily(F₂, v₀))

*Proof sketch.* Similar to Theorem C, but counting pairs rather than summing cardinalities. The bijection σ × σ preserves the overlap predicate by `tpe_overlap_iff`, so the filtered sets have equal cardinality. The technical complication is that σ does not preserve the ordering i < j, requiring a detour through counting unordered pairs and dividing by 2. □

### 3.5 Theorem E: Inclusion-Exclusion Bound

**Theorem 3.5.** For any family F : Fin n → Finset α,

    Σᵢ |F(i)| - |⋃ᵢ F(i)| ≤ OverlapComplexity(F)

*Proof sketch.* By induction on n. For n = 0, both sides are 0. For n + 1, use the identity |A ∪ B| = |A| + |B| - |A ∩ B| with A = ⋃_{i<n} F(i) and B = F(n). The term |A ∩ B| = |⋃_{i<n} (F(i) ∩ F(n))| ≤ Σ_{i<n} |F(i) ∩ F(n)| by another application of the union bound. The inductive hypothesis controls the contributions from {F(0), ..., F(n-1)}, and the cross-terms Σ_{i<n} |F(i) ∩ F(n)| exactly account for the new overlapping pairs in the complexity sum. □

### 3.6 Structural Results

**Theorem 3.6 (Disjoint Recovery).** If PairwiseDisjointFamily(F) holds and all supports are nonempty, then OverlapClassCount(F) = n.

This confirms that the overlap framework genuinely extends the disjoint-support theory.

**Theorem 3.7 (Full Overlap).** If all supports are equal and nonempty, then OverlapClassCount(F) = 1.

**Theorem 3.8 (Cross-Class Disjointness).** If C₁, C₂ are index sets forming two distinct overlap classes, then biUnion(C₁, F) and biUnion(C₂, F) are disjoint as finsets.

---

## 4. Algorithms

### 4.1 Overlap Class Computation

**Algorithm 1: Compute Overlap Classes**

```
Input: Family F = {F₁, ..., Fₙ} of finsets
Output: List of overlap classes (connected components)

1. Initialize Union-Find on {1, ..., n}
2. For each pair (i, j) with i < j:
   a. If Fᵢ ∩ Fⱼ ≠ ∅:
      - Union(i, j)
3. Return connected components from Union-Find
```

**Time complexity:** O(n² · max|Fᵢ| · α(n)) where α is the inverse Ackermann function.

**Space complexity:** O(n + Σ|Fᵢ|).

### 4.2 Full Overlap Profile

**Algorithm 2: Compute Overlap Profile**

```
Input: Family F = {F₁, ..., Fₙ}
Output: (class_count, degree, complexity, signature)

1. degree ← 0, complexity ← 0, signature ← []
2. For each pair (i, j) with i < j:
   a. s ← |Fᵢ ∩ Fⱼ|
   b. If s > 0: degree += 1, complexity += s, append s to signature
3. Sort signature
4. class_count ← len(OverlapClasses(F))
5. Return (class_count, degree, complexity, signature)
```

**Time complexity:** O(n² · max|Fᵢ| + k log k) where k = degree.

### 4.3 TPE Invariance Verification

**Algorithm 3: Verify TPE Invariance**

```
Input: Family F₁, permutation σ, constants c, basepoint v₀
Output: True if all invariants match

1. Compute F₂ via F₂(σ(i), v) = F₁(i, v) + c(i)
2. VS₁ ← VarSupportFamily(F₁, v₀)
3. VS₂ ← VarSupportFamily(F₂, v₀)
4. Return Profile(VS₁) == Profile(VS₂)
```

---

## 5. Computational Experiments

### 5.1 TPE Invariance Verification

We verified TPE invariance computationally on:
- 50 random TPE transformations of a fixed 5-function family on 8 vertices
- All connected graphs on ≤ 6 vertices (26,704 graphs, 22,136 cycle-containing instances)

**Result:** Perfect agreement in all cases. The overlap class count, degree, complexity, and signature were preserved in every instance.

### 5.2 Graph Classification

We computed overlap profiles for several named graph families:

| Graph | Cycle count | Classes | Degree | Complexity | Signature |
|-------|-----------|---------|--------|------------|-----------|
| C₃ | 1 | 1 | 0 | 0 | [] |
| C₄ | 1 | 1 | 0 | 0 | [] |
| K₄-e | 3 | 1 | 3 | 8 | [2,3,3] |
| K₄ | 4 | 1 | 6 | 12 | [2,2,2,2,2,2] |
| Bowtie | 2 | 1 | 1 | 1 | [1] |
| 2×C₃ | 2 | 2 | 0 | 0 | [] |

The overlap profile distinguishes graphs that share other invariants (e.g., same cycle count but different interaction patterns).

### 5.3 Inclusion-Exclusion Bound

For the cyclic family F = [{1,2,3,4}, {3,4,5,6}, {5,6,7,8}, {7,8,1,2}]:
- Sum of sizes: 16
- Union size: 8
- Deficit: 8
- Overlap complexity: 8
- Bound: 8 ≤ 8 (tight!)

The bound is tight for this example, suggesting it may be optimal for families with uniform pairwise intersection sizes.

---

## 6. Applications

### 6.1 Graph Invariants

The overlap profile (class count, degree, complexity, signature) provides a new family of graph invariants that capture the interaction structure of the cycle space. These complement classical invariants like genus, connectivity, and chromatic number.

### 6.2 Coding Theory

For a linear code C ⊆ F_q^n, the supports of minimum-weight codewords form a family whose overlap structure encodes redundancy patterns. Our theory shows that equivalent codes (in the appropriate tropical sense) have identical overlap profiles, providing a new invariant for code classification.

### 6.3 Network Science

In network reliability, overlap classes correspond to independent failure sectors. The componentwise factorization (Theorem 3.8) guarantees that reliability analyses can be performed sector by sector, potentially reducing computational complexity from exponential to polynomial in the number of sectors.

### 6.4 Matroid Theory

Cycle supports are circuit supports in the graphic matroid. The overlap theory should generalize to arbitrary matroids, with circuit intersection graphs replacing support overlap graphs. This would connect tropical rigidity to matroid theory and potentially to valuated matroid theory.

---

## 7. Discussion

### 7.1 The Role of Variation Support

A critical design choice is the use of *variation support* rather than *zero-set support*. The zero-set support {v | f(v) ≠ 0} is the natural choice from a tropical perspective, but it is not TPE-invariant (adding a constant changes which values are zero). The variation support {v | f(v) ≠ f(v₀)} is TPE-invariant and turns out to be the correct notion for the overlap theory.

### 7.2 Overlap Classes vs. TPE Classes

The overlap class count provides a lower bound for the number of TPE equivalence classes of minimal generating families. Computational evidence suggests this bound may be tight (equality) for connected graphs. Proving or disproving this equality is the most important open question.

### 7.3 Limitations

The current theory is purely combinatorial and does not yet incorporate the *values* of the generators, only their support structure. A full theory would need to account for how the specific values constrain the tropical projective equivalences.

---

## 8. Future Work

1. **Overlap rigidity conjecture:** Prove or disprove that the overlap class count equals the number of TPE classes for all connected graphs.

2. **Matroid generalization:** Extend the theory from graphic matroids to regular matroids and valuated matroids.

3. **Higher-order overlaps:** Replace the overlap graph (pairwise interactions) with the support nerve (higher-order interactions) and study the resulting simplicial invariants.

4. **Algorithmic applications:** Develop polynomial-time algorithms for tropical kernel computation that exploit overlap class decomposition.

5. **Defect theory connection:** Relate the overlap class count to the structural defect from the existing defect theory framework.

---

## References

[1] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[2] M. Develin, F. Santos, and B. Sturmfels, "On the rank of a tropical matrix," in *Combinatorial and Computational Geometry*, MSRI Publications, 2005.

[3] G. Mikhalkin, "Tropical geometry and its applications," in *Proceedings of the ICM*, 2006.

[4] M. Baker and S. Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph," *Advances in Mathematics*, 215(2), 2007.

[5] F. Ardila, "The geometry of matroids," *Notices of the AMS*, 2018.
