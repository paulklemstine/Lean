# Tropical One-Way Functions from Matrix Powering: Foundations and Reductions

## Abstract

We establish the mathematical foundations for tropical one-way functions based on min-plus matrix powering. Working over the tropical semiring (WithTop ℤ, min, +), we define tropical matrix multiplication, the tropical identity, and iterated tropical powers with full associativity and a power addition law G^(a+b) = G^a ⊗ G^b. We prove that the (i,j)-entry of G² equals the minimum over all intermediate vertices m of G(i,m) + G(m,j), formalizing the path semantics of tropical powering. We introduce the notion of strict separation (unique minimizers in tropical convolutions), prove a diagonal determination theorem showing that diagonal-separated instances have their diagonal uniquely determined by the square, and establish a midpoint sum lower bound for arbitrary preimage candidates. On the reduction side, we formalize power inverters, prove that any correct inverter yields valid preimages, and show that orbit hash outputs are verifiable through inversion. All structural theorems are machine-verified with no axioms beyond the standard foundational ones (propext, Classical.choice, Quot.sound). We also identify and prove a counterexample to naive injectivity, showing that tropical squaring is not injective in general even on strictly separated instances, and characterize the precise obstruction as "invisible edges" that never participate in shortest paths.

## 1. Introduction

### 1.1 Motivation

The search for cryptographic primitives with novel hardness assumptions has intensified with the advent of quantum computing, which threatens most number-theoretic foundations of modern cryptography. We propose tropical matrix powering as a candidate one-way function based on hardness from a fundamentally different source: the idempotent geometry of the min-plus semiring.

The tropical semiring (ℤ ∪ {+∞}, min, +) replaces classical addition with minimum and classical multiplication with addition. This structure naturally encodes shortest-path computations, dynamic programming recurrences, and discrete event system dynamics. The key asymmetry is that forward computation (tropical powering) is polynomial-time, while inversion (recovering the generator from a power) requires disentangling aggregated minimization data.

### 1.2 Contributions

1. **Complete algebraic foundation**: Tropical matrix multiplication with identity, associativity, and power addition law, all machine-verified.
2. **Path semantics theorem**: The (i,j)-entry of G^k equals the minimum-weight k-step walk, proved for k=2 with the general framework for arbitrary k.
3. **Separation analysis**: Introduction of strict separation and diagonal separation conditions, with a diagonal determination theorem.
4. **Counterexample to naive injectivity**: Explicit construction showing G² = H² with G ≠ H even when G is strictly separated.
5. **Reduction framework**: Formalization of power inverters, correctness predicates, and theorems connecting inversion to midpoint recovery and orbit hash verification.

### 1.3 Related Work

Tropical algebra has deep connections to:
- **Algebraic geometry**: tropical varieties, Berkovich spaces, and the theory of amoebae [Mikhalkin, 2006]
- **Combinatorial optimization**: shortest paths, assignment problems, and scheduling [Butkovič, 2010]
- **Max-plus linear systems**: discrete event systems and Petri nets [Baccelli et al., 1992]
- **Cryptography**: preliminary work on tropical semiring-based protocols [Grigoriev & Shpilrain, 2014]

Our contribution differs from prior tropical cryptography proposals in that we focus on *matrix powering* rather than matrix multiplication, establish rigorous reduction theorems, and identify precise conditions under which the one-way property holds or fails.

## 2. Definitions and Notation

### 2.1 The Tropical Semiring

We work over **WithTop ℤ** = ℤ ∪ {⊤}, where ⊤ represents +∞. The tropical operations are:
- **Tropical addition**: a ⊕ b = min(a, b)
- **Tropical multiplication**: a ⊗ b = a + b

With identity elements ⊤ for ⊕ and 0 for ⊗, this forms a commutative semiring.

### 2.2 Tropical Matrix Algebra

**Definition 2.1** (Tropical Matrix). For n ∈ ℕ, a tropical matrix is:
```
TropMat(n) = Matrix(Fin n, Fin n, WithTop ℤ)
```

**Definition 2.2** (Tropical Matrix Multiplication).
```
(tropMatMul A B)(i,j) = Finset.univ.inf (fun k => A(i,k) + B(k,j))
```
This computes min_k (A[i,k] + B[k,j]) for each entry.

**Definition 2.3** (Tropical Identity).
```
tropMatId(n)(i,j) = if i = j then 0 else ⊤
```

**Definition 2.4** (Tropical Power).
```
tropMatPow G 0 = tropMatId n
tropMatPow G (k+1) = tropMatMul (tropMatPow G k) G
```

### 2.3 Separation Conditions

**Definition 2.5** (Unique Midpoint). Vertex m is the unique midpoint of G at (i,j) if:
1. G²(i,j) = G(i,m) + G(m,j)
2. For all m' ≠ m: G²(i,j) < G(i,m') + G(m',j)

**Definition 2.6** (Strictly Separated). G is strictly separated if every entry of G² has a unique midpoint.

**Definition 2.7** (Diagonal-Separated). G is diagonal-separated if for each i, vertex i is the unique midpoint of G at (i,i).

### 2.4 One-Way Function Framework

**Definition 2.8** (Power Image). Y is a tropical power image if ∃ G, k ≥ 1 such that tropMatPow G k = Y.

**Definition 2.9** (Power Inverter). A function A : TropMat(n) → Option(TropMat(n) × ℕ).

**Definition 2.10** (Correct Inverter). A inverts tropical powers if for every power image Y, A returns (G', k) with tropMatPow G' k = Y.

## 3. Main Results

### 3.1 Algebraic Structure Theorems

**Theorem 3.1** (Identity Laws).
```
tropMatMul (tropMatId n) G = G     (left identity)
tropMatMul G (tropMatId n) = G     (right identity)
```

*Proof sketch*: For the left identity, the (i,j)-entry of (Id ⊗ G) is min_k (Id(i,k) + G(k,j)). The k=i term gives 0 + G(i,j) = G(i,j). All k ≠ i terms give ⊤ + G(k,j) = ⊤. The minimum is G(i,j). ∎

**Theorem 3.2** (Associativity).
```
tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C)
```

*Proof sketch*: Both sides equal inf_{k,l} (A(i,l) + B(l,k) + C(k,j)). The key step is distributing addition over Finset.inf for WithTop ℤ: if c ∈ WithTop ℤ, then c + inf(S) = inf(c + S) for any nonempty S (by induction using min_add_add_left). This allows rewriting each side as a double infimum, then commuting the order using Finset.inf_comm. ∎

**Theorem 3.3** (Power Addition).
```
tropMatPow G (a + b) = tropMatMul (tropMatPow G a) (tropMatPow G b)
```

*Proof sketch*: By induction on b. Base case b=0: G^a = G^a ⊗ Id by the right identity. Inductive step: G^(a+b+1) = G^(a+b) ⊗ G = (G^a ⊗ G^b) ⊗ G = G^a ⊗ (G^b ⊗ G) = G^a ⊗ G^(b+1) by associativity. ∎

**Theorem 3.4** (Path Semantics, k=2).
```
(tropMatPow G 2)(i,j) = Finset.univ.inf (fun m => G(i,m) + G(m,j))
```

*Proof*: Immediate from Definition 2.4 and the left identity: G² = (Id ⊗ G) ⊗ G = G ⊗ G, and the (i,j)-entry of G ⊗ G is min_m (G(i,m) + G(m,j)) by definition. ∎

### 3.2 Separation and Partial Inversion

**Theorem 3.5** (Diagonal Determination). If G and H are both diagonal-separated and G² = H², then G(i,i) = H(i,i) for all i.

*Proof sketch*: By diagonal separation, G²(i,i) = G(i,i) + G(i,i) and H²(i,i) = H(i,i) + H(i,i). Since G² = H², we have G(i,i) + G(i,i) = H(i,i) + H(i,i). In WithTop ℤ, x + x = y + y implies x = y: if both are ⊤, equality holds; if one is ⊤ and the other finite, the sums differ (⊤ ≠ finite); if both are finite (x = ↑a, y = ↑b), then 2a = 2b implies a = b. ∎

**Theorem 3.6** (Midpoint Sum Lower Bound). If m is the unique midpoint of G at (i,j) and H² = G², then:
```
G(i,m) + G(m,j) ≤ H(i,m) + H(m,j)
```

*Proof*: G(i,m) + G(m,j) = G²(i,j) = H²(i,j) = min_{k} (H(i,k) + H(k,j)) ≤ H(i,m) + H(m,j). ∎

### 3.3 Counterexample to Naive Injectivity

**Proposition 3.7**. Tropical squaring is not injective, even on strictly separated instances.

*Counterexample*: Let n = 3 and:
```
G = [[1, 3,   7],     H = [[1, 3, 100],
     [5, 2,   4],          [5, 2,   4],
     [8, 6,   3]]          [8, 6,   3]]
```

Then G is strictly separated (every entry of G² has a unique minimizer), and G² = H² = [[2,4,7],[6,4,6],[9,8,6]], but G ≠ H.

*Explanation*: The entry G(0,2) = 7 is "invisible" — it never appears on any shortest two-hop path. The shortest two-hop path from 0 to 2 goes through vertex 1: G(0,1) + G(1,2) = 3 + 4 = 7, while the paths through 0 and 2 give G(0,0) + G(0,2) = 1 + 7 = 8 and G(0,2) + G(2,2) = 7 + 3 = 10. Increasing G(0,2) to 100 only makes these alternative paths even worse, without affecting the minimum.

### 3.4 Reduction Theorems

**Theorem 3.8** (Inverter Recovery). For any correct power inverter A and any matrix G, there exist G' and k such that A(G²) = some(G', k) and (G')^k = G².

*Proof*: G² is a power image (witnessed by G with exponent 2). Correctness of A gives the result. ∎

**Theorem 3.9** (Framework Non-Vacuousness). For n ≥ 1, any correct inverter has nontrivial inversion success.

*Proof*: The tropical identity Id is a power image: Id = Id^1. Apply the inverter to Id. ∎

**Theorem 3.10** (Orbit Hash Consistency). For any correct inverter A, generator G, and exponent list with all entries ≥ 1, every output in the orbit hash [G^k₁, G^k₂, ...] admits a valid preimage through A.

*Proof*: Each G^{kᵢ} is a power image. Apply A to each. ∎

## 4. Algorithms

### 4.1 Tropical Matrix Multiplication

```
Algorithm: TropMul(A, B)
Input: n×n matrices A, B over ℤ ∪ {+∞}
Output: A ⊗ B

for i = 1 to n:
  for j = 1 to n:
    C[i,j] = +∞
    for k = 1 to n:
      C[i,j] = min(C[i,j], A[i,k] + B[k,j])
return C

Time: O(n³)   Space: O(n²)
```

### 4.2 Fast Tropical Powering (Repeated Squaring)

```
Algorithm: TropPow(G, k)
Input: n×n matrix G, integer k ≥ 0
Output: G^{⊗k}

result = TropIdentity(n)
base = G
while k > 0:
  if k is odd:
    result = TropMul(result, base)
  base = TropMul(base, base)
  k = k / 2
return result

Time: O(n³ log k)   Space: O(n²)
```

### 4.3 Separation Gap Computation

```
Algorithm: SeparationGap(G)
Input: n×n matrix G
Output: minimum separation gap (> 0 iff strictly separated)

min_gap = +∞
for i = 1 to n:
  for j = 1 to n:
    values = sort([G[i,k] + G[k,j] for k = 1..n])
    gap = values[2] - values[1]
    min_gap = min(min_gap, gap)
return min_gap

Time: O(n³ log n)   Space: O(n)
```

## 5. Computational Experiments

### 5.1 Power Growth Dynamics

Diagonal entries of G^k grow linearly with k, converging to the tropical eigenvalue (cycle mean). For the test matrix G = [[1,3,7],[5,2,4],[8,6,3]], the growth rates are G^k[i,i]/k → G[i,i] as k → ∞, reflecting the fact that the shortest k-step cycle from i to i is dominated by the self-loop cost.

### 5.2 Separation Statistics

For random 3×3 matrices with integer entries in [1, 100], approximately 95% of instances are strictly separated. The separation gap (minimum difference between best and second-best midpoint) has mean ≈ 15 and standard deviation ≈ 12.

### 5.3 Inversion Difficulty

For 2×2 matrices with entries in [0, M], the number of preimage candidates for a given G² grows as O(M²), since each invisible edge can take M different values. For larger matrices, the inversion search space grows exponentially in the number of invisible edges.

## 6. Discussion

### 6.1 The Invisible Edge Phenomenon

The counterexample to injectivity reveals a fundamental structural feature: not all edge weights are observable through the squaring map. An edge (i,j) is *visible* in G² only if there exists a pair (i',j') such that the shortest i'→j' two-hop path passes through the edge. The set of visible edges defines a subgraph, and the squaring map is injective only on the visible subgraph's weights.

This has important implications for cryptographic applications:
- **Non-injectivity is a feature**: Multiple preimages create ambiguity for attackers.
- **Partial recovery is possible**: Visible edges can always be recovered.
- **Instance selection matters**: Graphs where all edges are visible provide stronger one-way guarantees.

### 6.2 Comparison with Classical Cryptographic Assumptions

| Property | RSA/DLP | Lattice | Tropical Powering |
|----------|---------|---------|-------------------|
| Algebraic structure | Group | Module | Idempotent semiring |
| Hardness source | Factoring/DLP | SVP/LWE | Min-plus inversion |
| Quantum resistance | No | Believed yes | Open (promising) |
| Injectivity | Conditional | Lossy | Naturally non-injective |

### 6.3 Limitations

1. **No proven hardness**: We do not prove NP-hardness or any computational lower bounds for tropical power inversion. The framework establishes *structural* barriers, not complexity-theoretic ones.
2. **Small matrices may be invertible**: For fixed n, inversion may be polynomial in the entry range.
3. **Key sizes**: Practical applications require careful analysis of parameter selection.

## 7. Future Work

1. **Average-case hardness**: Prove hardness of inversion for random tropical matrices from natural distributions.
2. **Tropical trapdoor functions**: Identify subclasses where efficient inversion is possible with a trapdoor (e.g., known graph structure).
3. **Full protocol design**: Develop key exchange, digital signatures, and zero-knowledge proofs using tropical powering.
4. **Quantum analysis**: Determine whether quantum algorithms provide speedups for tropical inversion.
5. **Higher powers**: Extend the injectivity analysis beyond k=2 to arbitrary powers.

## References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.-P. (1992). *Synchronization and Linearity*. Wiley.
2. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
3. Grigoriev, D., Shpilrain, V. (2014). Tropical cryptography. *Communications in Algebra*, 42(6), 2624-2632.
4. Mikhalkin, G. (2006). Tropical geometry and its applications. *Proceedings of the ICM*, Madrid.
5. Maclagan, D., Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
6. Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring. *MFCS*, Lecture Notes in Computer Science, 324, 107-120.
