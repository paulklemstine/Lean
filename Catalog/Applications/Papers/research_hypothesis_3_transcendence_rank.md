# Structural Transcendence Rank: A Bridge Invariant for Tropical, Proof-Theoretic, and Computational Complexity

## Abstract

We introduce **transcendence rank**, a numerical invariant for structured compositional systems that measures the maximum number of structurally independent generators. We prove five main theorems: (1) invariance under structural congruence, (2) monotonicity under closure extension, (3) multiplicative subadditivity under tropical composition, (4) preservation under proof-theoretic structural rules, and (5) stability under finite perturbation. All results are machine-verified. We provide a complete computational algorithm for rank determination with verified soundness and completeness, together with experimental demonstrations on tropical matrices, closure systems, and proof trees. The invariant creates a formal bridge between tropical algebra, proof theory, and computational architecture theory.

## 1. Introduction

### 1.1 Motivation

Complexity measures abound in mathematics and computer science: circuit depth, proof length, description complexity, tropical rank, spectral dimension, and many others. Each captures an aspect of "how complicated" a mathematical object is, but they exist in largely disjoint theoretical frameworks. This fragmentation means that powerful results in one domain—say, a lower bound on tropical matrix rank—cannot be transferred to another domain—say, a bound on proof complexity.

We address this fragmentation by constructing a **bridge invariant**: a single quantity that can be defined, computed, and bounded across multiple domains while satisfying the same structural properties in each. Our invariant, the **transcendence rank**, generalizes the classical notion of transcendence degree from field theory to arbitrary compositional structures with congruence relations.

### 1.2 Prior Work

The algebraic concept of transcendence degree dates to Steinitz (1910) and measures the maximum number of algebraically independent elements in a field extension. Matroid theory (Whitney 1935, Oxley 1992) axiomatizes independence abstractly. Tropical geometry (Maclagan–Sturmfels 2015) studies algebraic geometry over the max-plus semiring. Proof complexity (Cook–Reckhow 1979, Krajíček 2019) measures the size of proofs. The Myhill–Nerode theorem connects language complexity to equivalence class counting.

Our contribution synthesizes these threads: we define independence relative to a closure operator, prove the resulting rank invariant behaves well under tropical, proof-theoretic, and algebraic operations, and provide a verified computational implementation.

### 1.3 Contributions

1. **Definitions.** We introduce `ArchExpr` (operadic architecture expressions), `StructuralCongr` (structural congruence), `transcendenceRank` (generator count), `ClosureOp` (finite closure operators), `Independent` (closure-based independence), `finTranscendenceRank` (maximum independent set cardinality), `TropMat`/`tropMul`/`tropComplexity` (tropical matrix complexity), and `ProofTree`/`proofRank` (proof-theoretic rank).

2. **Theorems.** Five main results (see §3), each machine-verified with no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`.

3. **Algorithms.** A verified exhaustive search algorithm with proven soundness and completeness (§5).

4. **Experiments.** Computational demonstrations on concrete instances (§6).

## 2. Definitions and Notation

### 2.1 Architecture Expressions

An **architecture expression** is an element of the free operad on one generator:

```
ArchExpr ::= generator | identity | compose(e₁, e₂) | parallel(e₁, e₂)
```

The **generator count** `generatorCount(e)` counts leaf generators:
- `generatorCount(generator) = 1`
- `generatorCount(identity) = 0`
- `generatorCount(compose(e₁, e₂)) = generatorCount(e₁) + generatorCount(e₂)`
- `generatorCount(parallel(e₁, e₂)) = generatorCount(e₁) + generatorCount(e₂)`

The **transcendence rank** of an expression is `transcendenceRank(e) = generatorCount(e)`.

### 2.2 Structural Congruence

**Structural congruence** `≡` is the smallest equivalence relation on `ArchExpr` closed under:
- Associativity of `compose` and `parallel`
- Left/right identity laws for `compose` and `parallel`
- Commutativity of `parallel`
- Congruence: if `e₁ ≡ e₁'` and `e₂ ≡ e₂'` then `compose(e₁, e₂) ≡ compose(e₁', e₂')` and `parallel(e₁, e₂) ≡ parallel(e₁', e₂')`

### 2.3 Closure Operators and Independence

A **closure operator** on a type α is a function `cl : Finset α → Finset α` that is extensive (`S ⊆ cl(S)`) and monotone (`S ⊆ T ⟹ cl(S) ⊆ cl(T)`).

A finite set `S` is **independent** w.r.t. `cl` if for all `s ∈ S`, `s ∉ cl(S \ {s})`.

The **finite transcendence rank** of `A` w.r.t. `cl` is:
```
finTranscendenceRank(cl, A) = max { |S| : S ⊆ A, S independent }
```

### 2.4 Tropical Matrix Complexity

A **tropical matrix** `A ∈ TropMat(n)` is a function `Fin n → Fin n → ℤ`. Tropical multiplication is:
```
(A ⊗ B)ᵢⱼ = max_k (Aᵢₖ + Bₖⱼ)
```

The **tropical complexity** of `A` is the number of distinct entry values:
```
tropComplexity(A) = |{Aᵢⱼ : i, j ∈ Fin n}|
```

### 2.5 Proof Trees and Proof Rank

A **proof tree** has constructors: axiom, weakL, weakR, contrL, contrR, cut. The **proof rank** (axiom count) counts axiom leaves. The **cut count** counts cut applications.

## 3. Main Results

### Theorem 1: Structural Congruence Invariance

**Statement.** If `e₁ ≡ e₂` (structurally congruent), then `transcendenceRank(e₁) = transcendenceRank(e₂)`.

**Proof sketch.** By induction on the derivation of `e₁ ≡ e₂`. The key observation is that `generatorCount` distributes additively over both `compose` and `parallel`, and all structural congruence rules preserve this additive structure:
- Associativity: `(a + b) + c = a + (b + c)` ✓
- Identity: `0 + a = a` and `a + 0 = a` ✓
- Commutativity of parallel: `a + b = b + a` ✓
- Congruence: if `gc(e₁) = gc(e₁')` and `gc(e₂) = gc(e₂')`, then `gc(e₁) + gc(e₂) = gc(e₁') + gc(e₂')` ✓

**Significance.** This establishes that transcendence rank is a semantic invariant, well-defined on the quotient by structural congruence. It is not an artifact of syntactic presentation.

### Theorem 2: Closure Monotonicity

**Statement.** If `A ⊆ B`, then `finTranscendenceRank(cl, A) ≤ finTranscendenceRank(cl, B)`.

**Proof sketch.** Any independent subset `S ⊆ A` is also a subset of `B`. The independence condition (`∀ s ∈ S, s ∉ cl(S \ {s})`) depends only on `cl` and `S`, not on the ambient set. Therefore `S` contributes to the supremum defining `finTranscendenceRank(cl, B)`, giving the inequality.

**Significance.** Monotonicity is essential for any reasonable complexity measure. It ensures that extending a system can only increase (or maintain) its irreducible complexity.

### Theorem 3: Tropical Composition Bound

**Statement.** `tropComplexity(A ⊗ B) ≤ tropComplexity(A) · tropComplexity(B)`.

**Proof sketch.** Each entry `(A ⊗ B)ᵢⱼ = max_k(Aᵢₖ + Bₖⱼ)`. Since the maximum of a finite set of integers belongs to that set, `(A ⊗ B)ᵢⱼ = Aᵢₖ₀ + Bₖ₀ⱼ` for some witness `k₀`. Therefore:
```
{(A ⊗ B)ᵢⱼ : i,j} ⊆ {a + b : a ∈ vals(A), b ∈ vals(B)}
```
The sumset has cardinality `≤ |vals(A)| · |vals(B)|`, giving the result.

**Significance.** This is the algebraic engine: tropical multiplication creates at most multiplicatively many new complexity signatures. It bounds the "complexity explosion" under composition.

### Theorem 4: Proof Rank Structural Invariance

**Statement.** For any proof tree `pt`:
- `proofRank(weakL(pt)) = proofRank(pt)`
- `proofRank(weakR(pt)) = proofRank(pt)`
- `proofRank(contrL(pt)) = proofRank(pt)`
- `proofRank(contrR(pt)) = proofRank(pt)`

**Proof.** Each structural rule preserves axiom count by definition (the axiomCount function recurses through structural rules without changing the count).

**Significance.** This is the cross-domain bridge theorem. It says that proof-theoretic structural transformations—the logical analogue of operadic rewriting—preserve the rank invariant. Combined with Theorem 1, this establishes that "structural transformation preserves rank" holds in both the algebraic and logical settings.

### Theorem 5: Perturbation Stability

**Statement.** `finTranscendenceRank(cl, A) ≤ finTranscendenceRank(cl_P, A) + |P|`, where `cl_P(S) = cl(S) ∪ P`.

**Proof sketch.** Let `S ⊆ A` be independent w.r.t. `cl`. Then `S \ P` is independent w.r.t. `cl_P`: for `s ∈ S \ P`, we have `s ∉ P` and `s ∉ cl((S\P) \ {s})` (since `cl((S\P) \ {s}) ⊆ cl(S \ {s})` by monotonicity, and `s ∉ cl(S \ {s})` by independence of `S`). Therefore `s ∉ cl_P((S\P) \ {s}) = cl((S\P) \ {s}) ∪ P`. Also `|S| ≤ |S \ P| + |P|`, so:
```
|S| ≤ |S \ P| + |P| ≤ finTranscendenceRank(cl_P, A) + |P|
```
Taking the supremum over all independent `S` gives the result.

**Significance.** Stability under perturbation is essential for practical applications. It guarantees that the rank invariant is robust to noise, measurement error, and approximate computation.

## 4. Additional Results

### Depth-Width-Rank Tradeoff
`transcendenceRank(e) ≤ depth(e) · maxWidth(e)` for all architecture expressions `e`. Proved by structural induction.

### Hereditary Independence
If `S ⊆ T` and `T` is independent, then `S` is independent. This is the hereditary property familiar from matroid theory.

### Proof Rank Bounds
- `proofRank(pt) ≤ size(pt)` (rank is at most total proof size)
- `0 < proofRank(pt)` (rank is always positive)
- `cutCount(pt) ≤ size(pt) - proofRank(pt)` (cut count bounded by "slack")

### Union Bound
`finTranscendenceRank(cl, A ∪ B) ≤ finTranscendenceRank(cl, A) + finTranscendenceRank(cl, B) + |A ∩ B|`

## 5. Algorithms

### 5.1 Exhaustive Rank Search

```
Algorithm: searchTranscendenceRank(cl, A)
Input: Closure operator cl, finite set A
Output: finTranscendenceRank(cl, A)

1. Enumerate all subsets S ⊆ A (powerset of A)
2. For each S, test independence:
   For each s ∈ S, check s ∉ cl(S \ {s})
3. Return max { |S| : S passes independence test }
```

**Correctness:** Proved formally—`searchTranscendenceRank = finTranscendenceRank` by definitional equality.

**Complexity:** O(2^|A| · |A| · T_cl), where T_cl is the cost of evaluating the closure operator. This is exponential but exact.

### 5.2 Tropical Complexity Computation

```
Algorithm: computeTropComplexity(A)
Input: n × n tropical matrix A
Output: tropComplexity(A)

1. Collect all entry values into a set
2. Return the cardinality of that set
```

**Complexity:** O(n²) time, O(n²) space.

## 6. Computational Experiments

### 6.1 Architecture Expression Examples

| Expression | generatorCount | depth | maxWidth | rank ≤ d·w? |
|---|---|---|---|---|
| generator | 1 | 1 | 1 | 1 ≤ 1 ✓ |
| compose(g, g) | 2 | 2 | 1 | 2 ≤ 2 ✓ |
| parallel(g, g) | 2 | 1 | 2 | 2 ≤ 2 ✓ |
| compose(parallel(g,g), g) | 3 | 2 | 2 | 3 ≤ 4 ✓ |

### 6.2 Closure System Examples

For the "discrete" closure operator `cl(S) = S`:
- Every set is independent (each element is not in the closure of the rest)
- `finTranscendenceRank = |A|`

For the "total" closure operator `cl(S) = A` for all nonempty S:
- Only singletons (and ∅) are independent
- `finTranscendenceRank = 1` (for nonempty A)

### 6.3 Tropical Matrix Multiplication

For 2×2 tropical matrices with entries in {0, 1}:
- Each factor has tropComplexity ≤ 2
- Product has tropComplexity ≤ 4 (by Theorem 3)
- Experimentally observed maximum: 3

## 7. Discussion

### 7.1 Relationship to Matroid Theory

The independence axioms we use (hereditary property, empty set independence) partially overlap with matroid axioms. However, we do not assume the augmentation property. Our independence is defined relative to a closure operator, which provides a concrete computational handle. Whether every instance of our closure-based independence arises from a matroid is an open question.

### 7.2 Computational Complexity

The exhaustive search algorithm is inherently exponential. For practical applications with large sets, approximation algorithms or structural restrictions would be needed. The monotonicity theorem guarantees that any lower bound found by partial search is valid, enabling an anytime algorithm.

### 7.3 Extensions

The framework extends naturally to:
- **Weighted independence**: assign weights to elements and maximize total weight of independent sets
- **Graded rank**: track rank at each "depth level" of a compositional hierarchy
- **Quantum closure**: replace set-valued closure with density-matrix-valued closure for quantum computing applications

## 8. Conclusion

We have introduced transcendence rank as a bridge invariant connecting tropical algebra, proof theory, and computational architecture. The five main theorems establish it as a well-behaved complexity measure: structurally invariant, monotone, compositionally bounded, cross-domain, and perturbation-stable. All results are machine-verified with no unresolved proof obligations.

The most exciting aspect of this work is not any single theorem, but the demonstrated possibility of a unified complexity theory for structured mathematical objects. The transcendence rank is a first step toward a common language for measuring irreducible complexity across algebraic, logical, and computational domains.

## References

1. Steinitz, E. (1910). Algebraische Theorie der Körper. *J. Reine Angew. Math.* 137, 167–309.
2. Whitney, H. (1935). On the abstract properties of linear dependence. *Amer. J. Math.* 57, 509–533.
3. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
4. Oxley, J. (1992). *Matroid Theory*. Oxford University Press.
5. Cook, S. and Reckhow, R. (1979). The relative efficiency of propositional proof systems. *J. Symbolic Logic* 44(1), 36–50.
6. Loday, J.-L. and Vallette, B. (2012). *Algebraic Operads*. Springer.
7. Cohen, G., Gaubert, S., and Quadrat, J.-P. (1999). Max-plus algebra and system theory. *Proceedings of the 38th IEEE CDC*.
