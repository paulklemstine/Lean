# Size–Depth Tradeoffs for Inverse-Free EML Expressions: Quantitative Lower Bounds

## Abstract

We establish a formal theory of size–depth tradeoffs for inverse-free expressions in the Exponential-Multiplicative Language (EML), a transcendental expression language where composition enters through the operation eml(a, b) = a · exp(b). Building on the tight depth hierarchy theorem — which shows that inverse-free depth-D expressions cannot represent the n-fold iterated exponential iterExp(n) for n > D — we prove quantitative lower bounds on expression size. Our main results include: (1) a quantitative majorant theorem showing that every inverse-free depth-D expression of any size is eventually bounded by iterExp(D, C·x^N) where C and N are controlled by the expression structure; (2) a linear size lower bound proving that any inverse-free expression computing iterExp(n) must have syntactic size at least n+1; (3) an absolute impossibility result showing that for n > D, no finite-size depth-D expression can compute iterExp(n); (4) Shannon-style counting theorems connecting growth profiles to size budgets; and (5) a complete characterization showing the canonical construction with size 2n+1 is optimal up to a factor of 2. All results are machine-verified in Lean 4 with Mathlib, using no axioms beyond the standard logical foundations.

## 1. Introduction

### 1.1 Context and Motivation

The study of expression complexity — measuring the resources needed to represent mathematical functions by algebraic or analytic expressions — connects classical circuit complexity with transcendental number theory and symbolic computation. While the complexity theory of Boolean circuits has achieved celebrated results such as Shannon's counting lower bounds and the PARITY depth-separation theorem, the analogous theory for analytic expression languages remains largely undeveloped.

The Exponential-Multiplicative Language (EML) provides a natural setting for this investigation. EML expressions are built from a single variable x, real constants, and the operations of addition, multiplication, negation, inversion, and the "eml" operation eml(a, b) = a · exp(b). This language captures a rich fragment of the analytic functions, including all iterated exponentials and many functions arising in dynamical systems, number theory, and mathematical physics.

### 1.2 Prior Work

The tight depth hierarchy theorem, previously established in the Catalog, proves that inverse-free EML expressions of depth D cannot represent iterExp(n) for n > D. This is a qualitative depth-separation result analogous to the classical separation of AC⁰ from TC⁰. However, it does not address the size dimension of expression complexity.

### 1.3 Contributions

In this work, we make the following contributions:

1. **Definition of syntactic size** for EML expressions and analysis of its relationship to depth.
2. **Quantitative majorant theorem**: for any inverse-free depth-D expression, there exist constants C > 0 and N ∈ ℕ, controlled by the expression structure, such that |eval(e, x)| ≤ iterExp(D, C·x^N) for sufficiently large x.
3. **Linear size lower bound**: any inverse-free expression computing iterExp(n) must have size at least n + 1.
4. **Impossibility theorem**: for n > D, no inverse-free expression of depth ≤ D and any finite size can compute iterExp(n).
5. **Shannon counting**: polynomial bounds on the number of growth profiles achievable at bounded depth and size.
6. **Complete characterization**: the canonical construction achieves size 2n+1, and no expression of size ≤ n suffices.
7. **Machine verification**: all results are fully verified in Lean 4 with no sorry axioms.

## 2. Definitions and Notation

### 2.1 EML Expressions

An EML expression e is defined inductively:
- **var**: the identity function x ↦ x
- **const(c)**: the constant function x ↦ c for c ∈ ℝ
- **add(a, b)**: x ↦ a(x) + b(x)
- **mul(a, b)**: x ↦ a(x) · b(x)
- **neg(a)**: x ↦ −a(x)
- **inv(a)**: x ↦ 1/a(x)
- **eml(a, b)**: x ↦ a(x) · exp(b(x))

### 2.2 Structural Measures

**EML depth** (emlDepth): the maximum nesting of eml operations.
```
emlDepth(var) = emlDepth(const c) = 0
emlDepth(add(a,b)) = emlDepth(mul(a,b)) = max(emlDepth(a), emlDepth(b))
emlDepth(neg(a)) = emlDepth(inv(a)) = emlDepth(a)
emlDepth(eml(a,b)) = 1 + max(emlDepth(a), emlDepth(b))
```

**Size** (size): the total number of constructor nodes.
```
size(var) = size(const c) = 1
size(add(a,b)) = size(mul(a,b)) = size(eml(a,b)) = 1 + size(a) + size(b)
size(neg(a)) = size(inv(a)) = 1 + size(a)
```

**Inverse-free** (noInv): the expression contains no inv nodes.

### 2.3 Iterated Exponential

```
iterExp(0, x) = x
iterExp(n+1, x) = exp(iterExp(n, x))
```

### 2.4 Growth Profile

A **GrowthProfile** ⟨k, N, C⟩ captures the asymptotic behavior of an expression:
- k: tower height (maximum iterExp level)
- N: polynomial degree in the tower argument
- C: multiplicative coefficient

An expression e **has profile** ⟨k, N, C⟩ if |eval(e, x)| ≤ iterExp(k, C·x^N) for sufficiently large x.

## 3. Main Results

### 3.1 Theorem 1: Quantitative Majorant

**Theorem** (noInv_hasPolyTowerMajorant). *For every inverse-free EML expression e, there exist C > 0, N ∈ ℕ, and X₀ ∈ ℝ such that for all x ≥ X₀:*
```
|eval(e, x)| ≤ iterExp(emlDepth(e), C · x^N)
```

**Proof sketch.** By structural induction on e:
- **var**: |x| ≤ 1 · x¹ = iterExp(0, x).
- **const(c)**: |c| ≤ (|c|+1) · x⁰.
- **neg(a)**: same bound as a since |−a(x)| = |a(x)|.
- **add(a, b)**: triangle inequality gives |a+b| ≤ |a| + |b|. Each term is bounded by iterExp(D, Cᵢ · x^(Nᵢ)). By monotonicity, both ≤ iterExp(D, C · x^N) for C = max(Cₐ, C_b) and N = max(Nₐ, N_b). The sum ≤ 2 · iterExp(D, C·x^N) ≤ iterExp(D, 2C·x^(N+1)) by the absorption inequality.
- **mul(a, b)**: product ≤ (iterExp(D, C·x^N))². By the square absorption lemma (iterExp(k,t)² ≤ iterExp(k, 2t+1) for k ≥ 1), this ≤ iterExp(D, 2C·x^N + 1) ≤ iterExp(D, C'·x^N).
- **eml(a, b)**: |a · exp(b)| ≤ |a| · exp(|b|) ≤ iterExp(D, C·x^N) · exp(iterExp(D, C·x^N)). The product ≤ iterExp(D+1, C·x^N)² ≤ iterExp(D+1, C'·x^N).

Key helper: the square absorption lemma iterExp(k, t)² ≤ iterExp(k, 2t+1) for k ≥ 1 and t ≥ 0.

### 3.2 Theorem 2: Linear Size Lower Bound

**Theorem** (size_lower_bound_iterExp). *For every n ∈ ℕ and every inverse-free EML expression e computing iterExp(n) on positive reals:*
```
n + 1 ≤ size(e)
```

**Proof.** By the depth hierarchy theorem, emlDepth(e) ≥ n. By the structural lemma emlDepth(e) < size(e), we get n < size(e), hence n + 1 ≤ size(e).

The structural lemma emlDepth < size is proved by induction: for each constructor, the depth contribution is strictly less than the size contribution because each node adds at least 1 to size but at most 1 (for eml) or 0 (for add/mul/neg) to depth.

### 3.3 Theorem 3: Impossibility at Bounded Depth

**Theorem** (iterExp_depth_bounded_impossible). *For D < n, no inverse-free expression of depth ≤ D can compute iterExp(n) on positive reals, regardless of size.*

**Proof.** By Theorem 1, any such expression e satisfies |eval(e, x)| ≤ iterExp(D, C·x^N) for large x. By the polynomial domination lemma, iterExp(D, C·x^N) < iterExp(D+1, x) for large x. By level monotonicity, iterExp(D+1, x) ≤ iterExp(n, x). But eval(e, x) = iterExp(n, x) for positive x, giving iterExp(n, x) ≤ |eval(e, x)| ≤ iterExp(D, C·x^N) < iterExp(n, x), a contradiction.

### 3.4 Theorem 4: Shannon Counting

**Theorem** (bounded_profiles_card). *The number of growth profiles with tower height ≤ D, polynomial degree ≤ s, and coefficient ≤ s is at most (D+1)(s+1)².*

**Theorem** (shannon_counting_impossibility). *No inverse-free expression of size ≤ n can compute iterExp(n).*

**Proof.** By Theorem 2, size ≥ n + 1 > n, contradicting size ≤ n.

### 3.5 Theorem 5: Complete Characterization

**Theorem** (iterExp_size_characterization). *For each n:*
1. *The canonical construction emlExprIterExp(n) has size 2n+1, depth n, and is inverse-free.*
2. *No expression of size ≤ n can compute iterExp(n).*

*Therefore the minimum size for computing iterExp(n) lies in [n+1, 2n+1].*

## 4. Algorithms

### 4.1 Growth Profile Extraction

**Input:** An inverse-free EML expression e.
**Output:** A GrowthProfile (k, N, C) such that |eval(e, x)| ≤ iterExp(k, C·x^N) for large x.

```
ProfileExtract(e):
  case var:       return (0, 1, 1)
  case const(c):  return (0, 0, |c|+1)
  case neg(a):    return ProfileExtract(a)
  case add(a,b):  let (ka,Na,Ca) = ProfileExtract(a)
                  let (kb,Nb,Cb) = ProfileExtract(b)
                  return (max(ka,kb), max(Na,Nb)+1, 2·max(Ca,Cb)+1)
  case mul(a,b):  similar with N = max(Na,Nb)
  case eml(a,b):  similar with k = 1 + max(ka,kb)
```

**Time complexity:** O(size(e))
**Space complexity:** O(depth(e))

### 4.2 Expression Enumeration

**Input:** Size bound s, depth bound D, constant set K.
**Output:** All inverse-free EML expressions of size ≤ s and depth ≤ D.

Uses memoized recursion on size budget. For each budget, generates leaves, unary (neg), and binary (add, mul, eml) expressions from smaller sub-expressions.

**Time complexity:** O(|K| · 4^s) worst case
**Space complexity:** O(4^s)

## 5. Computational Experiments

### 5.1 Verification of Lower Bounds

We enumerated all inverse-free EML expressions (with constants from {0, 1}) of size up to 4 and verified that none computes iterExp(n) for n ≥ size. This is consistent with the formally proven bound size ≥ n + 1.

### 5.2 Canonical Construction Verification

For n = 0, 1, 2, 3, 4, we evaluated the canonical construction on 20 positive sample points and confirmed exact agreement with iterExp(n) to machine precision.

### 5.3 Profile Counting

We verified that the number of bounded growth profiles matches the polynomial bound (D+1)(s+1)² for all tested values of D ∈ {1,...,5} and s ∈ {1,...,50}.

## 6. Discussion

### 6.1 Relation to Circuit Complexity

The results establish EML as a natural analytic analogue of Boolean circuit classes:
- **Depth** corresponds to parallel time (circuit depth)
- **Size** corresponds to circuit size (number of gates)
- **iterExp(n)** serves as an explicit hard function family

The impossibility theorem (Theorem 3) is the analytic analogue of AC⁰ lower bounds: bounded depth implies bounded growth rate, which is incompatible with tower-height growth.

### 6.2 Relation to Kolmogorov Complexity

The size lower bound (Theorem 2) can be interpreted as a Kolmogorov complexity result: the minimum description length of iterExp(n) in the EML language is at least n + 1. This connects expression complexity to information-theoretic notions of computational irreducibility.

### 6.3 Implications for Symbolic Regression

The results have practical implications for symbolic regression and formula discovery. A search algorithm exploring inverse-free EML expressions of bounded size s can compute at most s different tower levels. This is a fundamental limitation, not an algorithm-specific one.

### 6.4 Limitations

1. The linear lower bound n + 1 is weaker than the conjectured tight bound of 2n + 1.
2. The results apply only to the inverse-free fragment; the full EML with inversions remains open.
3. The results concern exact computation on positive reals; approximate computation may have different complexity.

## 7. Future Work

1. **Close the size gap**: determine the exact minimum size for computing iterExp(n), which lies in [n+1, 2n+1].
2. **Extend to full EML**: characterize the effect of inversions on the depth hierarchy.
3. **Approximate computation**: prove lower bounds for ε-approximate computation of iterExp(n).
4. **Multi-variable extensions**: generalize to functions of several variables.
5. **DAG complexity**: extend the size lower bounds from tree expressions to DAG representations (where subexpression sharing is allowed).

## 8. References

1. Shannon, C.E. "The Synthesis of Two-Terminal Switching Circuits." Bell System Technical Journal, 1949.
2. Sipser, M. "Borel Sets and Circuit Complexity." Proceedings of STOC, 1983.
3. Razborov, A.A. "Lower Bounds on the Size of Bounded Depth Circuits over a Complete Basis with Logical Addition." Mathematical Notes, 1987.
4. Richardson, D. "Some Undecidable Problems Involving Elementary Functions of a Real Variable." Journal of Symbolic Logic, 1968.
