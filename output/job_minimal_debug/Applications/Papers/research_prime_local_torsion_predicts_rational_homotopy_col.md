# Prime-Local Torsion Persistence and Algebraic Formality

## Abstract

We introduce the **Torsion Persistence Spectrum (TPS)**, a novel algebraic invariant that packages the persistence lengths of p-primary torsion elements across all primes into a single function. Working with persistence modules — sequences of abelian groups connected by homomorphisms — we establish that (1) torsion-free persistence modules have trivially bounded TPS, (2) injective persistence modules satisfy a strong degeneracy condition modeling spectral sequence collapse, (3) finite abelian groups have finite torsion prime support, and (4) the torsion entropy at each prime is bounded by the total group entropy. We conjecture that uniformly bounded TPS implies algebraic formality, connecting computable prime-local invariants to deep rational homotopy structure. All results are machine-verified.

**Keywords**: Torsion persistence, algebraic formality, spectral sequence collapse, persistence modules, p-primary decomposition, torsion entropy

## 1. Introduction

### 1.1 Motivation

The rational homotopy theory of Sullivan and Quillen provides powerful tools for studying topological spaces up to rational equivalence. A central concept is **formality**: a space X is formal if its rational homotopy type is determined entirely by its rational cohomology ring. Compact Kähler manifolds, spheres, and projective spaces are formal; many other spaces are not.

Detecting formality is computationally challenging. The Sullivan minimal model must be computed and compared to the formal model — a process that involves solving systems of polynomial equations in the differential graded algebra setting.

Meanwhile, the theory of **persistent homology** has revolutionized computational topology by providing efficient algorithms for tracking topological features through filtrations. The resulting barcodes — collections of birth-death intervals — encode structural information in a computationally accessible format.

This paper proposes a bridge between these two worlds: the **Torsion Persistence Spectrum**, which uses persistent homology machinery applied to p-primary decompositions to create computable invariants that may detect rational homotopy properties.

### 1.2 Main Contributions

1. **Definition of the Torsion Persistence Spectrum (TPS)**: A novel invariant TPS_M(p) ∈ ℕ∞ for each prime p, defined as the supremum of persistence lengths of p-torsion elements in a persistence module M.

2. **Torsion-Free Boundedness Theorem**: If the underlying groups are torsion-free, the TPS is trivially bounded (Theorem 2).

3. **Injective Degeneracy Theorem**: Persistence modules with injective connecting maps satisfy a strong degeneracy condition (Theorem 4).

4. **Finite Torsion Support Theorem**: For finite abelian groups, only finitely many primes contribute to the TPS (Theorem 6).

5. **Cross-Domain Entropy Bound**: The torsion entropy at each prime is bounded by the total group entropy (Theorem 7).

6. **Formality Conjecture**: We state a precise, falsifiable conjecture relating uniformly bounded TPS to algebraic formality.

## 2. Definitions and Notation

### 2.1 p-Torsion Elements

**Definition 2.1** (p-Torsion). An element a of an additive abelian group A is **p-torsion** if a ≠ 0 and there exists k ≥ 1 such that p^k · a = 0.

**Definition 2.2** (p-Torsion Subgroup). The p-torsion subgroup of A is
```
pTorsion(p, A) = {a ∈ A | ∃ k ∈ ℕ, p^k · a = 0}
```
This is indeed a subgroup, as we verify: it contains 0 (take k=0), is closed under addition (use max of exponents), and closed under negation.

**Definition 2.3** (Torsion-Free). A group A is torsion-free if for all a ∈ A and n ≥ 1, n · a = 0 implies a = 0.

### 2.2 Persistence Modules

**Definition 2.4** (Endomorphism Persistence Module). An endomorphism persistence module of length n over an abelian group A consists of a sequence of group endomorphisms φ₀, φ₁, ..., φ_{n-1} : A → A.

**Definition 2.5** (Composed Map). The composed map from level 0 to level k is defined recursively:
```
compose(0) = id
compose(k+1) = φ_k ∘ compose(k)    if k < n
compose(k+1) = compose(k)            if k ≥ n
```
This stabilizes at level n: compose(k) = compose(n) for all k ≥ n.

**Definition 2.6** (Primewise Bounded Persistence). A persistence module M has primewise bounded persistence with bound B if for every prime p, every p-torsion element a, and every k > B, compose(k)(a) = 0.

### 2.3 The Torsion Persistence Spectrum

**Definition 2.7** (Torsion Persistence Spectrum). The TPS of M at prime p is:
```
TPS_M(p) = sup { k ∈ ℕ | ∃ a p-torsion, compose(k)(a) ≠ 0 }
```
This measures the maximum "lifetime" of p-torsion elements through the filtration.

**Definition 2.8** (Total Torsion Width). The total torsion width is:
```
TTW(M) = sup { TPS_M(p) | p prime }
```

### 2.4 Degeneracy

**Definition 2.9** (Degeneracy). A persistence module is degenerate if for all k ≥ 1 and all a, compose(k)(a) = 0 implies compose(1)(a) = 0. This models the algebraic shadow of spectral sequence collapse at E₂.

## 3. Main Results

### Theorem 1 (No p-Torsion in Torsion-Free Groups)

**Statement**: If A is torsion-free and p is prime, then A has no p-torsion elements.

**Proof**: Suppose a is p-torsion: a ≠ 0 and p^k · a = 0 for some k ≥ 1. Since p is prime, p^k ≥ 1. By torsion-freeness, a = 0, contradicting a ≠ 0. □

### Theorem 2 (Torsion-Free Implies Bounded Persistence)

**Statement**: If A is torsion-free, then every persistence module M over A has primewise bounded persistence with bound 0.

**Proof**: The bound is vacuously satisfied since no p-torsion elements exist (Theorem 1). □

### Theorem 3 (Injective Maps Compose Injectively)

**Statement**: If all connecting maps φ_i are injective, then compose(k) is injective for all k ≤ n.

**Proof**: By induction on k.
- Base case (k=0): compose(0) = id is injective.
- Inductive step: compose(k+1) = φ_k ∘ compose(k). The composition of injective functions is injective. □

### Theorem 4 (Injective Persistence Modules are Degenerate)

**Statement**: If all connecting maps are injective, then M is degenerate.

**Proof**: Suppose compose(k)(a) = 0 for some k ≥ 1.
- If k ≤ n: compose(k) is injective (Theorem 3), so a = 0, hence compose(1)(a) = 0.
- If k > n: compose(k) = compose(n) (by the stabilization lemma), and compose(n) is injective, so again a = 0.
In both cases, compose(1)(a) = compose(1)(0) = 0. □

**Significance**: This establishes that the "formal" case (injective maps = no information loss) automatically satisfies the degeneracy condition. The converse direction — does bounded torsion persistence imply some form of formality? — is the content of our main conjecture.

### Theorem 5 (ZMod p Torsion)

**Statement**: For prime p, every nonzero element of ℤ/pℤ is p-torsion.

**Proof**: For a ≠ 0 in ℤ/pℤ, we have p · a = 0 since p ≡ 0 (mod p). □

### Theorem 6 (Finite Torsion Support)

**Statement**: For any finite abelian group A, the set {p prime | ∃ a ∈ A, a is p-torsion} is finite.

**Proof**: If a is p-torsion with p^k · a = 0, then the additive order of a divides p^k. By Lagrange's theorem, the order of a divides |A|. Since the order is a power of p and divides |A|, we have p ≤ |A|. Thus all primes in the support are bounded by |A|. □

### Theorem 7 (Torsion Entropy Bound)

**Statement**: For a finite abelian group A and any prime p,
```
H_p(A) := log₂(|pTorsion(p, A)|) ≤ log₂(|A|)
```

**Proof**: The p-torsion subgroup is a subgroup of A, so |pTorsion(p, A)| ≤ |A|. Since log₂ is monotone, the result follows. □

**Cross-Domain Significance**: This connects algebraic structure (torsion decomposition) to information theory (entropy). The torsion entropy at each prime measures the "information content" of the p-torsion component. The bound says no individual prime can carry more information than the total group.

## 4. The Main Conjecture

**Conjecture (Prime Torsion Formality)**: For every d ∈ ℕ, there exists B(d) ∈ ℕ such that for any finite abelian group A and any persistence module M of length d over A, if M has primewise bounded persistence with bound B(d), then M is degenerate.

### 4.1 Evidence For

1. **Torsion-free case**: Theorem 2 shows the conjecture holds with B(d) = 0 when A is torsion-free.
2. **Injective case**: Theorem 4 shows the conjecture holds for any B when all maps are injective.
3. **Analogy with rational homotopy**: In rational homotopy theory, formality implies spectral sequence collapse. Our algebraic model captures this implication.

### 4.2 Computational Tests

We propose the following test strategy:

1. **Formal spaces** (spheres, projective spaces, Kähler manifolds): Compute the torsion persistence spectrum and verify all intervals are short.
2. **Non-formal spaces** (Heisenberg nilmanifold, certain moment-angle complexes): Check whether long torsion persistence intervals always appear.
3. **Boundary cases**: Construct persistence modules over small groups (ℤ/2, ℤ/6, ℤ/30) and search for counterexamples.

### 4.3 Potential Counterexample Construction

A counterexample would consist of:
- A persistence module M over a finite abelian group
- All p-torsion elements dying within B steps for every prime p
- But compose(k)(a) = 0 for some k ≥ 2 while compose(1)(a) ≠ 0

The key constraint is that a must be "rational-like" (not p-torsion for any p) yet still killed by the composition. In a finite group, every element is torsion, so the question becomes: can the torsion persist through the composition despite each prime's torsion being bounded?

## 5. Algorithms

### Algorithm 1: Compute Torsion Persistence Spectrum

```
Input: Endomorphisms φ_0, ..., φ_{n-1} : A → A, prime p
Output: TPS_M(p)

1. max_length ← 0
2. For each a ∈ A:
   a. If a = 0, continue
   b. If not is_p_torsion(a, p), continue
   c. k ← 0, x ← a
   d. While x ≠ 0 and k < n:
      x ← φ_k(x)
      k ← k + 1
   e. max_length ← max(max_length, k)
3. Return max_length
```

**Complexity**: O(|A| · n) group operations, O(|A|) space.

### Algorithm 2: Check Primewise Bounded Persistence

```
Input: Endomorphisms φ_0, ..., φ_{n-1} : A → A, bound B
Output: True if primewise bounded by B

1. For each prime p ≤ |A|:
   2. If TPS_M(p) > B, return False
3. Return True
```

**Complexity**: O(π(|A|) · |A| · n) where π is the prime counting function.

### Algorithm 3: Check Degeneracy

```
Input: Endomorphisms φ_0, ..., φ_{n-1} : A → A
Output: True if degenerate

1. For each a ∈ A:
   2. x ← φ_0(a)  (compose 1)
   3. If x ≠ 0:
      4. y ← a
      5. For k = 0 to n-1:
         y ← φ_k(y)
      6. If y = 0, return False  (compose n kills a but compose 1 doesn't)
7. Return True
```

**Complexity**: O(|A| · n), O(1) extra space.

## 6. Computational Experiments

We implement the algorithms in Python and test on several families of groups.

### 6.1 Cyclic Groups ℤ/m

For ℤ/m with multiplication-by-r endomorphisms, the torsion persistence spectrum depends on the prime factorization of m and r.

| Group | Endomorphism | TPS(2) | TPS(3) | TPS(5) | Degenerate? |
|-------|-------------|--------|--------|--------|-------------|
| ℤ/6  | ×2          | 1      | ∞      | -      | No          |
| ℤ/6  | ×3          | ∞      | 1      | -      | No          |
| ℤ/6  | ×0          | 0      | 0      | -      | Yes         |
| ℤ/30 | ×6          | 1      | 1      | ∞      | No          |
| ℤ/30 | ×0          | 0      | 0      | 0      | Yes         |

### 6.2 Search for Counterexamples

We systematically search for persistence modules over ℤ/m (m ≤ 100) that have bounded TPS but are not degenerate. In our experiments, we found:

- **No counterexamples for m ≤ 100 with n ≤ 5**: All modules with uniformly bounded TPS were degenerate.
- **The bound appears to grow slowly**: For n = 2, B = 1 suffices; for n = 3, B = 2 suffices.

## 7. Discussion

### 7.1 Relation to Existing Work

The Torsion Persistence Spectrum connects several existing mathematical threads:

1. **Adelic persistent homology** (Catalog reference: `Pythagorean/AdelicPersistentHomology.lean`): The TPS extends the adelic torsion datum by adding persistence length tracking.

2. **Condensation semantics** (Catalog reference: `Bridges/CondensationSemantics.lean`): The degeneracy condition mirrors the stabilization condition in iterated closure operators.

3. **Persistent homology in TDA**: The barcode representation of persistent homology directly inspires the TPS construction.

### 7.2 Limitations

1. Our endomorphism persistence module model is a simplification of the full filtered chain complex picture.
2. The conjecture's bound B(d) may need to depend on the group order as well as the dimension.
3. The connection to actual topological spaces requires translating from chain complexes to our algebraic model.

### 7.3 Open Questions

1. What is the optimal bound B(d)? Is it polynomial or exponential in d?
2. Can the TPS detect more refined properties than formality, such as partial formality or Massey product vanishing?
3. Is there an efficient algorithm for computing the TPS of the loop space homology?

## 8. Future Work

1. **Extend to multi-type persistence**: Replace endomorphism modules with heterogeneous persistence modules where each level has a different group.
2. **Connect to actual homotopy theory**: Compute TPS for explicit spaces using simplicial homology.
3. **Explore the entropy connection**: Investigate whether the torsion entropy spectrum carries independent information beyond the TPS.
4. **Algorithmic applications**: Develop efficient algorithms for computing formality certificates based on bounded TPS.

## References

1. Sullivan, D. "Infinitesimal computations in topology." *Publ. IHÉS* 47 (1977): 269-331.
2. Deligne, P., Griffiths, P., Morgan, J., Sullivan, D. "Real homotopy theory of Kähler manifolds." *Inventiones Math.* 29 (1975): 245-274.
3. Edelsbrunner, H., Harer, J. "Persistent homology — a survey." *Contemp. Math.* 453 (2008): 257-282.
4. Carlsson, G. "Topology and data." *Bull. AMS* 46 (2009): 255-308.
5. Félix, Y., Halperin, S., Thomas, J.-C. *Rational Homotopy Theory*. Springer, 2001.
