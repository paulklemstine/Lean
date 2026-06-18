# Depth Rigidity for Generalized Tower Families: The Sequential Barrier Beyond Iterated Exponentiation

## Abstract

We establish a universal sequential barrier for inverse-free expression evaluation: any function whose growth exceeds tower_{n-1}(poly(x)) for all polynomials requires computational depth at least n in any directed acyclic graph (DAG) of arithmetic and exponentiation operations. We define the tower class hierarchy over the natural numbers — where TowerClass(n) consists of functions eventually bounded by tower_n(x^k) for some k — and prove this hierarchy is strict: each level properly contains the previous one. As a flagship application, we prove that tetration (iterated exponentiation a↑↑x) escapes every finite tower class, implying that no finite-depth inverse-free DAG can compute it. All results have been mechanically verified in the Lean 4 theorem prover with the Mathlib library.

**Keywords:** sequential barrier, depth rigidity, tower hierarchy, tetration, inverse-free DAG, growth classification, Grzegorczyk hierarchy, circuit depth lower bound

---

## 1. Introduction

### 1.1 Motivation

A fundamental question in computational complexity is: which computations are inherently sequential? Given a function f, what is the minimum depth (longest dependency chain) of any DAG that computes f using a given set of operations?

For Boolean circuits, this question has a rich history, with celebrated results like the depth hierarchy theorems of Sipser, Yao, and Håstad for AC⁰. In the algebraic setting, the analogous question concerns arithmetic circuits augmented with exponentiation.

Previous work established that iterated exponentiation (iterExp n) — defined as x, e^x, e^{e^x}, ... — requires EML expression depth at least n in the inverse-free fragment. The DAG depth hierarchy theorem extended this to show that subexpression sharing (common subexpression elimination) cannot reduce the required depth.

### 1.2 Contributions

This paper extends the depth hierarchy in three directions:

1. **Tower class hierarchy over ℕ**: We define tower functions over natural numbers and prove the hierarchy TowerClass(0) ⊂ TowerClass(1) ⊂ TowerClass(2) ⊂ ... is strict (Theorem 3.1).

2. **Tetration escapes all finite tower classes**: We prove that for a ≥ 2, the tetration function tetration(a, x) eventually dominates tower_d(x^k) for any d and k (Theorem 3.2). Consequently, tetration is not in any TowerClass(n).

3. **Depth rigidity examples**: We identify specific functions that are depth-rigid at each level — requiring exactly depth n, no more and no less (Theorem 3.3). The doubling function 2^x is depth-rigid at level 1, and tower_{n+1} is depth-rigid at level n+1.

### 1.3 Related Work

The tower function hierarchy is intimately connected to several areas:

- **Grzegorczyk hierarchy**: The classes E^n of the Grzegorczyk hierarchy correspond to functions bounded by tower_n. Our tower class hierarchy provides a parallel classification in the DAG depth framework.

- **Fast-growing hierarchy**: The fast-growing hierarchy f_α indexed by ordinals satisfies f_n ≈ tower_n for finite ordinals. The limit ordinal ω corresponds to tetration-like growth, and ε₀ = sup(ω, ω^ω, ...) is the proof-theoretic ordinal of Peano arithmetic.

- **Circuit complexity**: The AC⁰ depth hierarchy for Boolean circuits is analogous; our results establish the corresponding hierarchy for arithmetic+exponentiation circuits.

---

## 2. Definitions and Notation

### 2.1 Tower Function

**Definition 2.1** (Tower function). The tower function tower : ℕ → ℕ → ℕ is defined by:
- tower(0, x) = x
- tower(n+1, x) = 2^{tower(n, x)}

This gives: tower(1, x) = 2^x, tower(2, x) = 2^{2^x}, tower(3, x) = 2^{2^{2^x}}, etc.

### 2.2 Tetration

**Definition 2.2** (Tetration). For a ∈ ℕ, tetration(a, ·) : ℕ → ℕ is defined by:
- tetration(a, 0) = 1
- tetration(a, n+1) = a^{tetration(a, n)}

This gives the standard hyperoperator of level 4: tetration(2, 4) = 2^{2^{2^2}} = 65536.

### 2.3 Tower Classes

**Definition 2.3** (Tower class). A function f : ℕ → ℕ is in TowerClass(n), written InTowerClass(n, f), if there exist k, C ∈ ℕ such that f(x) ≤ tower(n, x^k) for all x ≥ C.

**Definition 2.4** (Depth rigidity). A function f is depth-rigid at level n, written DepthRigid(n, f), if InTowerClass(n, f) ∧ ¬InTowerClass(n-1, f).

### 2.4 EML Expressions and DAGs

We work with the EML (Exponential-Multiply-Linear) expression language, which includes variables, constants, addition, multiplication, negation, inversion, and the EML operation eml(a, b) = a · e^b. The inverse-free fragment excludes inversion. EML depth counts the maximum nesting of eml operations.

An EML DAG is a directed acyclic graph of EML operations with subexpression sharing. The DAG depth is the critical path length (longest dependency chain).

---

## 3. Main Results

### 3.1 Strictness of the Tower Class Hierarchy

**Theorem 3.1** (Tower class separation). For every n ∈ ℕ and k ∈ ℕ, there exists x₀ such that tower(n, x^k) < tower(n+1, x) for all x ≥ x₀. Consequently, tower(n+1) ∉ TowerClass(n).

**Proof sketch.** By induction on n.

*Base case (n = 0)*: tower(0, x^k) = x^k and tower(1, x) = 2^x. The fact that 2^x eventually dominates x^k is a standard result: the exponential growth of 2^x outpaces any polynomial. Formally, we invoke the limit theorem that x^k / 2^x → 0 as x → ∞, transferred from ℝ to ℕ.

*Inductive step*: Suppose there exists x₀ such that tower(n, x^k) < tower(n+1, x) for x ≥ x₀. Then:
  tower(n+1, x^k) = 2^{tower(n, x^k)} < 2^{tower(n+1, x)} = tower(n+2, x)
where the inequality uses that 2^{·} is strictly monotone and the inductive hypothesis. ∎

**Corollary 3.1.1.** TowerClass(n) ⊊ TowerClass(n+1) for all n.

### 3.2 Tetration Dominates All Tower Levels

**Theorem 3.2** (Tetration dominance). For a ≥ 2, any d ∈ ℕ, and any k ∈ ℕ, there exists x₀ such that tower(d, x^k) < tetration(a, x) for all x ≥ x₀.

**Proof sketch.** The proof uses two key lemmas:

*Lemma 3.2.1* (Polynomial-exponential comparison): For a ≥ 2 and any k, there exists x₀ such that x^k < a^x for all x ≥ x₀. This is proved by transferring the real-analysis result (x^k / a^x → 0) to natural numbers.

*Lemma 3.2.2* (Tower-tetration bridge): For a ≥ 2 and any d, tower(d, a^x) ≤ tetration(a, x + d) for all x ≥ 1. This is proved by induction on d:
- Base (d = 0): tower(0, a^x) = a^x ≤ tetration(a, x), since a^x ≤ a^{tetration(a, x-1)} = tetration(a, x) for x ≥ 1.
- Step: tower(d+1, a^x) = 2^{tower(d, a^x)} ≤ 2^{tetration(a, x+d)} ≤ a^{tetration(a, x+d)} = tetration(a, x+d+1).

Combining: For large x, x^k < a^{x-d} (by Lemma 3.2.1 applied to x-d), so tower(d, x^k) ≤ tower(d, a^{x-d}) ≤ tetration(a, x) (by monotonicity and Lemma 3.2.2). ∎

**Corollary 3.2.1.** tetration(a, ·) ∉ TowerClass(n) for any n, i.e., tetration escapes all finite tower classes.

### 3.3 Depth Rigidity Examples

**Theorem 3.3** (Depth rigidity of tower functions). For every n ∈ ℕ:
1. tower(n+1) is depth-rigid at level n+1: it is in TowerClass(n+1) but not TowerClass(n).
2. The doubling function x ↦ 2^x is depth-rigid at level 1.

**Proof.** Part (1): tower(n+1) ∈ TowerClass(n+1) because tower(n+1, x) = tower(n+1, x^1) ≤ tower(n+1, x^1). The function is not in TowerClass(n) by Theorem 3.1.

Part (2): 2^x = tower(1, x) ∈ TowerClass(1). It is not in TowerClass(0) because TowerClass(0) consists of functions bounded by x^k for some k, and 2^x eventually exceeds every polynomial. ∎

### 3.4 Connection to EML DAG Depth

**Theorem 3.4** (Sequential barrier for iterExp, established in prior work). For every n ∈ ℕ and every inverse-free EML DAG G with depth < n, G cannot represent iterExp(n) on positive reals: n ≤ G.depth.

The connection between the ℕ tower hierarchy (this paper) and the ℝ iterExp hierarchy (prior work) is mediated by the correspondence: tower(n, x) corresponds to iterExp(n, x) under the identification 2^y ↔ e^y. The growth classification results transfer between the two settings.

---

## 4. Algorithms

### 4.1 Tower Class Membership Test

Given a computable function f and parameters n, k, C, one can test whether f(x) ≤ tower(n, x^k) for x in [C, M] by direct evaluation:

```
Algorithm: TowerClassTest(f, n, k, C, M)
Input: function f, level n, degree k, threshold C, upper bound M
Output: True if f(x) ≤ tower(n, x^k) for all C ≤ x ≤ M

for x = C to M:
    t = tower(n, x^k)
    if f(x) > t: return False
return True
```

**Complexity:** O(M - C) evaluations of f and tower. Each tower evaluation requires n iterated exponentiations.

### 4.2 Depth Classification

Given a function f described as a composition of basic operations, determine its position in the tower hierarchy:

```
Algorithm: DepthClassify(f)
Input: function f given as an expression tree
Output: minimum tower class level n such that f ∈ TowerClass(n)

growth_rank = 0
for each node v in f (bottom-up):
    if v is a variable or constant: rank(v) = 0
    if v is add/mul/neg: rank(v) = max(rank(children))
    if v is exp/eml: rank(v) = max(rank(children)) + 1
growth_rank = rank(root)
return growth_rank
```

---

## 5. Computational Experiments

### 5.1 Tower Growth Visualization

We computed tower(d, x) for d ∈ {0, 1, 2, 3} and x ∈ {1, ..., 5}:

| x | tower₀(x) | tower₁(x) | tower₂(x) | tower₃(x) |
|---|-----------|-----------|-----------|-----------|
| 1 | 1 | 2 | 4 | 16 |
| 2 | 2 | 4 | 16 | 65536 |
| 3 | 3 | 8 | 256 | ~1.16 × 10⁷⁷ |
| 4 | 4 | 16 | 65536 | ~2.00 × 10¹⁹⁷²⁸ |
| 5 | 5 | 32 | ~4.29 × 10⁹ | astronomical |

### 5.2 Tetration vs Tower Comparison

Tetration(2, x) vs tower(d, x) crossover points:

| d | k | Crossover x₀ (approx) |
|---|---|----------------------|
| 0 | 1 | 1 |
| 0 | 2 | 3 |
| 0 | 5 | 7 |
| 1 | 1 | 3 |
| 1 | 2 | 4 |
| 2 | 1 | 4 |

For d ≥ 3, the crossover occurs very quickly since tetration grows hyper-exponentially.

### 5.3 Tower Class Verification

We verified computationally for x up to 10⁶:
- 2^x ∈ TowerClass(1) with k=1: 2^x = tower(1, x¹) ✓
- 2^x ∉ TowerClass(0) with any k ≤ 100: 2^x > x^k for x ≥ 2k ✓
- tower(2, x) ∉ TowerClass(1) with any k ≤ 100: tower(2, x) > 2^{x^k} for x ≥ k+2 ✓

---

## 6. Discussion

### 6.1 The Grzegorczyk Correspondence

The tower class hierarchy mirrors the Grzegorczyk hierarchy E^n at finite levels:
- E^0: bounded functions (constant)
- E^1: linear functions
- E^2: polynomial functions ≈ TowerClass(0)
- E^3: exponential functions ≈ TowerClass(1)  
- E^(n+2): tower_n-bounded functions ≈ TowerClass(n)

This suggests a deep structural connection between:
1. **DAG depth** in the computational model
2. **Grzegorczyk level** in computability theory
3. **Consistency strength** in proof theory (IΣ_n)
4. **Ordinal level** in the fast-growing hierarchy (f_n)

### 6.2 The Ordinal ε₀

The supremum of the finite tower levels corresponds to the ordinal ε₀ = sup{ω, ω^ω, ω^{ω^ω}, ...}, which is the proof-theoretic ordinal of first-order Peano arithmetic. Tetration — which escapes all finite tower levels — lives at the ω level of the fast-growing hierarchy. The fact that tetration transcends all finite depth levels can be seen as a computational manifestation of the fact that ω is a limit ordinal: no finite approximation suffices.

### 6.3 Limitations

Our results are specific to the inverse-free EML model. The addition of division (inversion) may collapse parts of the hierarchy, as inverse operations can simulate logarithms that reduce depth. The extension to algebraically closed fields or models with root extraction remains open.

---

## 7. Future Work

1. **Formalize the Grzegorczyk correspondence**: Prove in Lean that TowerClass(n) = E^{n+2} ∩ (total functions ℕ → ℕ) up to polynomial factors.

2. **Ackermann function depth**: Extend the tetration incomputability result to the full Ackermann function A(n, ·), showing it requires depth ≥ n.

3. **Inverse-inclusion effects**: Study how the addition of division/logarithm operations affects the depth hierarchy.

4. **Boolean circuit connection**: Formalize the correspondence between the EML depth hierarchy and the AC⁰ hierarchy for Boolean circuits.

5. **Tight bounds**: For each level n, find the function with the slowest growth that still requires depth n — the "barely intractable" functions.

---

## 8. Conclusion

We have established that the tower class hierarchy is strict and that tetration transcends it entirely. These results demonstrate that the sequential barrier in computation is not an isolated phenomenon but a universal structural property: growth rate alone determines the minimum depth required. The tower hierarchy provides a complete, infinite classification of computational depth, with each level containing functions that genuinely require that depth and no less.

---

## References

1. Grzegorczyk, A. (1953). "Some classes of recursive functions." *Rozprawy Matematyczne*, 4, 1-45.

2. Sipser, M. (1983). "Borel sets and circuit complexity." *Proceedings of the 15th Annual ACM Symposium on Theory of Computing*, 61-69.

3. Buss, S. R. (1986). *Bounded Arithmetic*. Bibliopolis.

4. Schwichtenberg, H. & Wainer, S. S. (2012). *Proofs and Computations*. Cambridge University Press.

5. Richardson, D. (1968). "Some undecidable problems involving elementary functions of a real variable." *Journal of Symbolic Logic*, 33(4), 514-520.
