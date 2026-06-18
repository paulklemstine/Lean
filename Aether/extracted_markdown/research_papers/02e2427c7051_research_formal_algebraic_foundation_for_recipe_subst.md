# Hamming Substitution Algebras: Formal Algebraic Foundations for Recipe Substitution Spaces

## Abstract

We develop a formal algebraic framework for substitution spaces modeled as Hamming graphs H(n,m), where n is the number of ingredient slots and m is the number of options per slot. We establish six structural theorems with machine-verified proofs: (1) the binary triangle-free theorem, showing that H(n,2) contains no distance-1 triangle; (2) the nonbinary triangle existence theorem, showing that H(n,m) for m ≥ 3 always contains distance-1 triangles; (3) the substitution path length bound, establishing that any sequence of single-position changes between two words requires at least Hamming-distance-many steps; (4) translation invariance of Hamming distance; (5) the Singleton bound on code size; and (6) the slot independence theorem for additive flavor maps. We also prove that fiber connectivity fails in general for additive maps, providing an explicit counterexample.

**Keywords**: Hamming distance, substitution graph, error-correcting codes, Singleton bound, combinatorial optimization, additive decomposition

---

## 1. Introduction

The Hamming space H(n,m) = {0, 1, ..., m-1}^n, equipped with the Hamming distance, is a foundational object in coding theory [Hamming 1950], combinatorics, and information theory. We formalize this space in the context of *substitution algebras* — algebraic structures that capture the process of iteratively modifying entries of a word.

Our primary contributions are:

1. **Novel definitions**: `SubstitutionPath` (a sequence of single-position modifications forming a walk in the Hamming graph), `AdditiveFlavorMap` (a function on the Hamming space decomposing as a sum of per-coordinate contributions), and `HammingCode` (a finite set of codewords with minimum distance guarantee).

2. **The triangle dichotomy**: A sharp structural distinction between binary (m = 2) and nonbinary (m ≥ 3) Hamming graphs. The binary Hamming graph is triangle-free, while nonbinary graphs always contain triangles. This reveals a topological phase transition at m = 3.

3. **The Singleton bound**: A formal proof that any code with minimum distance d in H(n,m) has at most m^(n-d+1) codewords, via projection-based injectivity.

4. **The slot independence theorem**: For additive functions on the Hamming space, global optimization decomposes into independent per-slot optimization, reducing exponential-time search to linear-time computation.

5. **Fiber disconnectivity**: A constructive proof that fibers of additive maps can be disconnected in the Hamming graph, refuting the naive conjecture that equal-value words are always connected by value-preserving substitution paths.

---

## 2. Definitions

### 2.1. Hamming Space

**Definition 1** (HWord). A *word* in H(n,m) is a function `w : Fin n → Fin m`, assigning one of m options to each of n positions.

**Definition 2** (Hamming Distance). The Hamming distance between words u and v is `d(u,v) = |{i : u(i) ≠ v(i)}|`, the number of positions where they differ. This is a metric on H(n,m): it satisfies non-negativity, identity of indiscernibles, symmetry, and the triangle inequality (all provided by Mathlib).

### 2.2. Substitution Path

**Definition 3** (SubstitutionPath). A *substitution path* of length k is a sequence of words `w₀, w₁, ..., wₖ` such that consecutive words have Hamming distance exactly 1. This models the process of incrementally modifying a recipe one ingredient at a time.

### 2.3. Additive Flavor Map

**Definition 4** (AdditiveFlavorMap). An *additive flavor map* over a commutative monoid M is specified by a family of functions `f_i : Fin m → M` for each position i ∈ Fin n. Its evaluation on a word w is:

```
F(w) = Σᵢ fᵢ(wᵢ)
```

This models scoring functions where the total value is the sum of independent per-position contributions.

### 2.4. Hamming Code

**Definition 5** (HammingCode). A *Hamming code* is a finite set C ⊆ H(n,m) together with a minimum distance d such that `∀ u,v ∈ C, u ≠ v → d(u,v) ≥ d`.

---

## 3. Main Results

### 3.1. Triangle Dichotomy

**Theorem 1** (Binary Triangle-Free). For any n, the Hamming graph H(n,2) contains no triangle at distance 1. That is, there exist no three words u, v, w ∈ H(n,2) with d(u,v) = d(v,w) = d(u,w) = 1.

*Proof sketch*. If d(u,v) = 1, there exists a unique position i₀ where u and v differ, and they agree elsewhere. Similarly, d(v,w) = 1 gives a unique position j₀ where v and w differ.

- If i₀ = j₀: Since Fin 2 has exactly two elements, u(i₀) ≠ v(i₀) and v(i₀) ≠ w(i₀) forces u(i₀) = w(i₀). Combined with agreement at all other positions, u = w, so d(u,w) = 0 ≠ 1.
- If i₀ ≠ j₀: Then u and w differ at both positions i₀ and j₀ (and agree elsewhere), so d(u,w) = 2 ≠ 1.

In both cases we reach a contradiction. □

**Theorem 2** (Nonbinary Triangle Existence). For m ≥ 3 and n ≥ 1, the Hamming graph H(n,m) contains a distance-1 triangle.

*Proof*. Take u, v, w that agree at all positions except position 0, where they take the three distinct values 0, 1, 2 ∈ Fin m. Then d(u,v) = d(v,w) = d(u,w) = 1. □

**Corollary**. The transition from triangle-free to triangle-containing behavior is a sharp dichotomy at m = 3: H(n,2) has no triangles, and H(n,m) for m ≥ 3 always has triangles.

### 3.2. Geodesic Lower Bound

**Theorem 3** (Substitution Path Length Bound). For any substitution path p from u to v with k steps, d(u,v) ≤ k.

*Proof*. By induction on k. The base case k = 0 is immediate. For the inductive step, let w be the second-to-last node. By the triangle inequality, d(u,v) ≤ d(u,w) + d(w,v). The inductive hypothesis gives d(u,w) ≤ k-1, and d(w,v) = 1 by the adjacency condition. □

### 3.3. Translation Invariance

**Theorem 4** (Translation Preserves Hamming Distance). For any words u, v, t ∈ H(n,m):

```
d(u + t, v + t) = d(u, v)
```

where addition is coordinate-wise in Fin m (cyclic group of order m).

*Proof*. At each position i, `(u(i) + t(i) ≠ v(i) + t(i)) ↔ (u(i) ≠ v(i))` by cancellation in Fin m. Hence the set of differing positions is identical. □

### 3.4. The Singleton Bound

**Lemma** (Projection Injectivity). Let π : H(n,m) → H(n-d+1, m) be the projection onto the first n-d+1 coordinates. If C ⊆ H(n,m) has minimum distance d, then π is injective on C.

*Proof*. If π(u) = π(v) for u ≠ v ∈ C, then u and v agree on the first n-d+1 positions, so they differ in at most d-1 positions. This contradicts d(u,v) ≥ d. □

**Theorem 5** (Singleton Bound). Any code C ⊆ H(n,m) with minimum distance d satisfies |C| ≤ m^(n-d+1).

*Proof*. By projection injectivity, |C| = |π(C)| ≤ |H(n-d+1, m)| = m^(n-d+1). □

### 3.5. Additive Optimization Decomposition

**Theorem 6** (Slot Independence). For any additive flavor map F : H(n,m) → ℤ, there exists an optimal word w* such that:
- For each slot i, w*(i) maximizes fᵢ over Fin m.
- F(w*) ≥ F(w) for all w ∈ H(n,m).

*Proof*. At each slot i, choose w*(i) to maximize fᵢ (possible since Fin m is finite and nonempty). Then F(w) = Σᵢ fᵢ(wᵢ) ≤ Σᵢ fᵢ(w*(i)) = F(w*) by summing the per-slot inequalities. □

### 3.6. Fiber Disconnectivity

**Theorem 7** (Fiber Connectivity Counterexample). There exists an additive flavor map F : H(2,2) → ℤ and words u, v with F(u) = F(v), d(u,v) = 2, and no other word w satisfying F(w) = F(u). Hence the fiber F⁻¹(F(u)) = {u, v} is disconnected in the Hamming graph.

*Proof*. Take F(w) = w(0) + w(1) (casting Fin 2 values to ℤ). Set u = (0,1) and v = (1,0). Then F(u) = F(v) = 1, d(u,v) = 2, and F takes value 0 on (0,0) and value 2 on (1,1). □

---

## 4. Algorithms

### 4.1. Additive Optimization Algorithm

```
Input: Flavor functions f₁, ..., fₙ, each mapping {0, ..., m-1} → ℤ
Output: Optimal word w* maximizing Σᵢ fᵢ(wᵢ)

For i = 1 to n:
    w*(i) ← argmax_{j ∈ {0,...,m-1}} fᵢ(j)
Return w*
```

**Time complexity**: O(n·m), versus O(mⁿ) for brute-force search.

### 4.2. Minimum Distance Computation

```
Input: Code C ⊆ H(n,m)
Output: Minimum distance d(C)

d ← n
For each pair (u,v) ∈ C × C with u ≠ v:
    d ← min(d, hammingDist(u, v))
Return d
```

**Time complexity**: O(|C|²·n).

---

## 5. Discussion

### 5.1. The Coding Theory Interpretation

Our results establish a formal bridge between recipe substitution and error-correcting codes. A "cuisine" (a curated set of recipes) is precisely a code in H(n,m), and:

- **Minimum distance** ↔ how different recipes must be to count as distinct dishes
- **Code size** ↔ how many distinct dishes the cuisine contains
- **Singleton bound** ↔ the fundamental tradeoff between distinctiveness and variety
- **MDS codes** ↔ cuisines that achieve the optimal variety-distinctiveness tradeoff

### 5.2. The Additive Decomposition Principle

The slot independence theorem provides a computational algorithm for optimization under additivity. The key insight is that additivity *decouples* the optimization, reducing an exponential problem to a linear one. Deviations from additivity — ingredient interactions — can be quantified as the gap between the additive optimum and the true optimum.

### 5.3. The Triangle Dichotomy and Local Topology

The triangle-free property of binary Hamming graphs has deep consequences for local topology. The neighborhood of any word in H(n,2) forms an independent set, meaning the local structure is tree-like. This makes binary substitution spaces amenable to techniques from spectral graph theory and random walk analysis.

For m ≥ 3, the presence of triangles makes the local structure richer. The clique number, chromatic number, and independence number of the Hamming graph all depend sensitively on m, and the transition at m = 3 is the simplest case of this dependence.

---

## 6. Future Work

1. **Fiber connectivity characterization**: Determine necessary and sufficient conditions on an additive map for its fibers to be connected in the Hamming graph.

2. **Non-additive extensions**: Develop optimization theory for flavor maps with bounded interaction terms (e.g., pairwise interactions).

3. **Association scheme structure**: Exploit the Hamming association scheme to derive spectral bounds on code size.

4. **Geodesic counting**: Count the number of shortest substitution paths between two words (this is n!/∏kᵢ! where kᵢ is the number of positions differing in each "type" of change).

5. **Tropical optimization**: Connect to tropical semiring optimization, where the "sum" operation is replaced by "min" or "max."

---

## 7. References

1. R.W. Hamming. Error detecting and error correcting codes. *Bell System Technical Journal*, 29(2):147–160, 1950.

2. R.C. Singleton. Maximum distance q-nary codes. *IEEE Transactions on Information Theory*, 10(2):116–118, 1964.

3. P. Delsarte. An algebraic approach to the association schemes of coding theory. *Philips Research Reports Supplements*, 10, 1973.

4. F.J. MacWilliams and N.J.A. Sloane. *The Theory of Error-Correcting Codes*. North-Holland, 1977.

5. J.H. van Lint. *Introduction to Coding Theory*. Springer, 3rd edition, 1999.
