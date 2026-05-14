# Circuit Lower Bounds from Tropical Spectral Theory

## Abstract

We develop a formally verified framework connecting tropical (min-plus) linear algebra to circuit depth lower bounds. Working over the semiring (ℕ, min, +), we define tropical matrix multiplication, tropical powers, the tropical permanent, and layered circuit decompositions. We prove three families of theorems: (A) path-cost semantics showing that tropical matrix powers encode minimum-cost walks, yielding depth lower bounds from budget obstruction arguments; (B) tropical permanent bounds showing that layered realizations with bounded weight caps force the permanent to grow at most linearly in depth, yielding quantitative depth lower bounds; and (C) spectral gap bounds showing that large minimum edge weights force linear cost growth in the number of edges, giving certified depth obstructions. All 30+ theorems are machine-verified with zero uses of sorry. We also exhibit a concrete counterexample disproving the natural conjecture that minDiag of tropical powers is subadditive, identifying a subtle failure mode that prior work had not addressed.

## 1. Introduction

### 1.1 Motivation

Proving computational lower bounds—showing that certain problems *require* a minimum number of operations—is one of the central challenges in theoretical computer science. Despite decades of effort, super-polynomial lower bounds for general circuit models remain elusive. Progress has been made in restricted models: monotone circuits [Razborov 1985, Alon-Boppana 1987], bounded-depth circuits [Håstad 1987, Smolensky 1987], and algebraic circuits [Baur-Strassen 1983].

We introduce a new approach: **tropical spectral lower bounds**. The key observation is that layered circuits performing min-plus computation are naturally modeled by tropical matrix products. Algebraic invariants of the resulting matrices—the tropical permanent, minimum entry, and diagonal structure—provide certified obstructions to shallow realization.

### 1.2 Contributions

1. **Definitions.** We formalize tropical matrix multiplication, iterated powers, the tropical permanent, layered decompositions, walk costs, and circuit depth predicates.

2. **Path Semantics (Theorem A).** We prove that entries of tropical matrix powers equal minimum-cost walks of prescribed length, establishing a bridge between algebraic and combinatorial representations.

3. **Permanent-Depth Bounds (Theorem B).** We prove that the tropical permanent of a matrix is bounded by n × (d+1) × W for any layered realization of depth d with weight cap W. The contrapositive gives depth lower bounds from permanent values.

4. **Spectral Gap Bounds (Theorem C).** We prove that minimum edge weight forces linear cost growth: every entry of tropPow M k is at least (k+1) × minEntry M. This yields depth bounds from budget arguments.

5. **Counterexample.** We disprove the conjecture that minDiag(tropPow M (k+l+1)) ≤ minDiag(tropPow M k) + minDiag(tropPow M l), exhibiting a 4×4 matrix where this fails.

6. **Machine Verification.** All theorems are verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

**Tropical algebra** has been studied extensively in optimization [Butkovič 2010], algebraic geometry [Maclagan-Sturmfels 2015], and discrete event systems [Baccelli et al. 1992]. The tropical permanent connects to the assignment problem and the Hungarian algorithm [Kuhn 1955].

**Circuit complexity** lower bounds via algebraic methods include the rank method [Razborov 1990], the partial derivatives method [Nisan-Wigderson 1996], and geometric complexity theory [Mulmuley-Sohoni 2001].

The novelty of our approach is the direct bridge: tropical matrix invariants → circuit depth bounds, with machine-verified proofs.

## 2. Definitions and Notation

### 2.1 Tropical Matrix Algebra

Let M(n) denote the set of n×n matrices over ℕ.

**Definition 2.1** (Tropical multiplication). For A, B ∈ M(n):
```
(A ⊗ B)(i,j) = min_k (A(i,k) + B(k,j))
```

**Definition 2.2** (Tropical power). tropPow M 0 = M; tropPow M (k+1) = tropMul (tropPow M k) M.

Note our convention: tropPow M k represents the (k+1)-fold tropical product M ⊗ M ⊗ ... ⊗ M with k+1 copies.

**Definition 2.3** (Chain product). For a sequence of matrices layers(0), ..., layers(d):
```
tropChainProd 0 layers = layers(0)
tropChainProd (d+1) layers = tropMul (tropChainProd d layers) (layers(d+1))
```

### 2.2 Matrix Invariants

**Definition 2.4** (Max/min entry).
```
maxEntry M = max_{i,j} M(i,j)
minEntry M = min_{i,j} M(i,j)
```

**Definition 2.5** (Tropical permanent).
```
tropPerm M = min_σ ∑_i M(i, σ(i))
```
where σ ranges over all permutations of {0, ..., n-1}.

**Definition 2.6** (MinDiag).
```
minDiag M = min_i M(i,i)
```

### 2.3 Circuit Model

**Definition 2.7** (Layered realization). M has a layered realization of depth d with weight cap W if there exist matrices layers(0), ..., layers(d) with maxEntry(layers(l)) ≤ W for all l, such that M = tropChainProd d layers.

**Definition 2.8** (Circuit depth lower bound). circuitDepthLB M S t B d states that for all k < d and all s ∈ S, we have B < tropPow M k s t.

### 2.4 Walk Cost

**Definition 2.9** (Walk cost). For a walk w : Fin(k+1) → Fin(n):
```
walkCost M k w = ∑_{l=0}^{k-1} M(w(l), w(l+1))
```

## 3. Main Results

### 3.1 Associativity and Power Concatenation

**Theorem 3.1** (Associativity). tropMul (tropMul A B) C = tropMul A (tropMul B C).

*Proof sketch.* Both sides equal min_{k,m} (A(i,k) + B(k,m) + C(m,j)). The key step is showing that min distributes over addition in ℕ: a + min_S f = min_S (a + f). This allows rebracketing the nested minimizations. □

**Theorem 3.2** (Power concatenation). tropPow M (k+l+1) = tropMul (tropPow M k) (tropPow M l).

*Proof sketch.* By induction on l, using associativity. □

### 3.2 Entry Bounds (Theorem Family A)

**Theorem 3.3** (Upper entry bound). For all i, j: tropPow M k i j ≤ (k+1) × maxEntry M.

*Proof.* By induction on k. Base case: tropPow M 0 = M, and M(i,j) ≤ maxEntry M = 1 × maxEntry M. Inductive step: tropPow M (k+1) i j = min_m (tropPow M k i m + M m j) ≤ tropPow M k i m₀ + M m₀ j ≤ (k+1)·W + W = (k+2)·W for any m₀. □

**Theorem 3.4** (Lower entry bound). For all i, j: (k+1) × minEntry M ≤ tropPow M k i j.

*Proof.* By induction on k. Each term in the inf' is at least minEntry(tropPow M k) + minEntry M ≥ (k+1)·w + w = (k+2)·w by the inductive hypothesis and the fact that minEntry M ≤ M(m,j) for all m, j. Since this holds for every term, it holds for the infimum. □

### 3.3 Path Semantics

**Theorem 3.5** (Walk cost upper bound). For any walk w of k+1 edges from i to j:
```
tropPow M k i j ≤ walkCost M (k+1) w
```

*Proof.* By induction on k. Base case k=0: tropPow M 0 i j = M i j = M(w(0), w(1)) = walkCost M 1 w when w(0) = i and w(1) = j. Inductive step: decompose the walk into its first k+1 edges (from i to w(k+1)) and the last edge. Apply tropMul_le to bound the tropical product by the sum of prefix and last-edge costs. □

### 3.4 Permanent and Depth (Theorem Family B)

**Theorem 3.6** (Permanent ≤ trace). tropPerm M ≤ tropTrace M = ∑_i M(i,i).

*Proof.* The identity permutation achieves cost ∑_i M(i,i), and the permanent is the minimum over all permutations. □

**Theorem 3.7** (Permanent ≤ n × maxEntry). tropPerm M ≤ n × maxEntry M.

*Proof.* By Theorem 3.6, tropPerm M ≤ ∑_i M(i,i) ≤ ∑_i maxEntry M = n × maxEntry M. □

**Theorem 3.8** (Chain product entry bound). If maxEntry(layers(l)) ≤ W for all l ≤ d, then:
```
tropChainProd d layers i j ≤ (d+1) × W
```

*Proof.* By induction on d, similar to Theorem 3.3 but with heterogeneous layers. □

**Theorem 3.9** (Permanent-depth inequality). If M has a layered realization of depth d with weight cap W, then:
```
tropPerm M ≤ n × (d+1) × W
```

*Proof.* Every entry of M is at most (d+1)·W by Theorem 3.8. Then tropPerm M ≤ ∑_i M(i,i) ≤ n × (d+1) × W. □

**Corollary 3.10** (Depth lower bound). Under the same hypotheses with W > 0:
```
d + 1 ≥ tropPerm M / (n × W)
```

### 3.5 Spectral Gap (Theorem Family C)

**Theorem 3.11** (Spectral gap depth bound). If w ≤ minEntry M, then for all d, i, j:
```
(d+1) × w ≤ tropPow M d i j
```

*Proof.* Immediate from Theorem 3.4 and w ≤ minEntry M. □

**Corollary 3.12** (Budget-constrained depth). If tropPow M d i j ≤ B and 0 < w ≤ minEntry M, then d + 1 ≤ B/w + 1.

### 3.6 Monotonicity

**Theorem 3.13** (Permanent monotonicity). If A(i,j) ≤ B(i,j) for all i,j, then tropPerm A ≤ tropPerm B.

**Theorem 3.14** (Multiplication monotonicity). If A ≤ B entrywise, then tropMul A C ≤ tropMul B C and tropMul C A ≤ tropMul C B entrywise.

### 3.7 Counterexample: MinDiag Subadditivity Fails

**Proposition 3.15.** There exists M ∈ M(4) such that:
```
minDiag(tropPow M 2) > minDiag(tropPow M 0) + minDiag(tropPow M 1)
```

*Proof.* Let M = diag(2, 1000, 1000, 1000) with M(1,2) = M(2,1) = 1 and all other off-diagonal entries 1000.

- minDiag(M) = 2 (vertex 0's self-loop).
- minDiag(tropPow M 1) = 2 (2-edge cycle 1→2→1 has cost 1+1=2).
- minDiag(tropPow M 2) = 6 (cheapest 3-edge cycle is 0→0→0→0 at cost 2+2+2=6).

Then 6 > 2 + 2 = 4. The failure occurs because vertex 0 minimizes the 1-edge diagonal but vertices 1,2 minimize the 2-edge diagonal, and combining them at a single vertex is suboptimal. □

## 4. Concrete Example

**Example 4.1.** Let M = [[5, 3], [4, 6]].

- tropPerm M = 7 (swap permutation: 3 + 4 = 7).
- maxEntry M = 6.
- n = 2.

By Theorem 3.9: any layered realization with weight cap W satisfies tropPerm M ≤ 2 × (d+1) × W.

With W = 1: 7 ≤ 2(d+1), so d + 1 ≥ 4, hence d ≥ 3. Any circuit using unit-weight layers needs at least 4 layers (depth 3).

This is verified computationally and formally (theorem `depth_bound_example2`).

## 5. Algorithms

### 5.1 Tropical Matrix Multiplication

```
Algorithm: TropicalMul(A, B)
Input: n×n matrices A, B over ℕ
Output: n×n matrix C = A ⊗ B

for i = 0 to n-1:
  for j = 0 to n-1:
    C[i,j] = ∞
    for k = 0 to n-1:
      C[i,j] = min(C[i,j], A[i,k] + B[k,j])
return C
```

Time: O(n³). Space: O(n²). Same as standard matrix multiplication with min replacing + and + replacing ×.

### 5.2 Tropical Permanent (Brute Force)

```
Algorithm: TropicalPerm(M)
Input: n×n matrix M
Output: tropPerm(M)

best = ∞
for each permutation σ of {0,...,n-1}:
  cost = Σ_i M[i, σ(i)]
  best = min(best, cost)
return best
```

Time: O(n! × n). For practical use with n > 10, use the Hungarian algorithm: O(n³).

### 5.3 Depth Lower Bound

```
Algorithm: DepthLowerBound(M, W)
Input: n×n matrix M, weight cap W > 0
Output: lower bound on circuit depth

p = TropicalPerm(M)
return ⌈p / (n × W)⌉ - 1
```

Time: dominated by TropicalPerm. Space: O(n²).

## 6. Computational Experiments

We verified all theorems computationally for matrices up to 7×7.

### 6.1 Entry Bounds

For M = [[5,3,7],[4,6,3],[7,4,5]] with maxEntry = 7, minEntry = 3:

| k | Edges | Max entry | Upper bound | Min entry | Lower bound |
|---|-------|-----------|-------------|-----------|-------------|
| 0 | 1     | 7         | 7           | 3         | 3           |
| 1 | 2     | 9         | 14          | 6         | 6           |
| 2 | 3     | 13        | 21          | 10        | 9           |
| 3 | 4     | 16        | 28          | 13        | 12          |
| 4 | 5     | 20        | 35          | 17        | 15          |

All bounds verified ✓.

### 6.2 Counterexample Verification

For M = diag(2,1000,1000,1000) + edges 1↔2 at weight 1:

| k | minDiag | Subadditive env. | Holds? |
|---|---------|------------------|--------|
| 0 | 2       | 2                | ✓      |
| 1 | 2       | 4                | ✓      |
| 2 | 6       | 4                | ✗      |
| 3 | 4       | 6                | ✓      |

The failure at k=2 is genuine and reproducible.

## 7. Discussion

### 7.1 Strengths

- **Computable certificates**: the depth lower bound is a function of the tropical permanent and weight cap, both computable quantities.
- **Compositional**: associativity of tropical multiplication enables modular circuit analysis.
- **Machine-verified**: all results carry the highest possible certainty.

### 7.2 Limitations

- The current bounds are polynomial in n and linear in depth. Superpolynomial lower bounds would require either larger permanents or stronger structural constraints.
- The model assumes min-plus circuits. Extensions to more general gate types (max, threshold) require additional machinery.
- The counterexample to minDiag subadditivity shows that naive spectral arguments can fail; more sophisticated cycle analysis is needed.

### 7.3 Comparison with Existing Methods

| Method | Model | Best bound | Computable? |
|--------|-------|------------|-------------|
| Rank method | linear circuits | Ω(n²/log n) | Yes |
| Partial derivatives | algebraic circuits | Ω(n) | Partially |
| Tropical permanent (this work) | min-plus layered | Ω(perm/nW) | Yes |
| Tropical spectral gap (this work) | min-plus general | Ω(B/w) | Yes |

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key directions:

1. **Tropical rank and depth**: define tropical matrix rank and prove depth ≥ rank/n.
2. **Min-plus communication complexity**: tropical lower bounds for two-party protocols.
3. **Spectral gap for branching programs**: extend the framework beyond layered circuits.
4. **Concrete separations**: exhibit explicit families with tropPerm = Ω(n²).
5. **Connection to assignment problems**: leverage Hungarian algorithm structure for tighter bounds.

## References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.P. (1992). *Synchronization and Linearity*. Wiley.
2. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
3. Maclagan, D., Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
4. Razborov, A.A. (1985). Lower bounds on the monotone complexity of some boolean functions. *Doklady AN SSSR*, 281(4):798–801.
5. Håstad, J. (1987). *Computational Limitations of Small-Depth Circuits*. MIT Press.
6. Kuhn, H.W. (1955). The Hungarian method for the assignment problem. *Naval Research Logistics Quarterly*, 2:83–97.
7. Mulmuley, K., Sohoni, M. (2001). Geometric complexity theory I. *SIAM J. Comput.*, 31(2):496–526.
8. Nisan, N., Wigderson, A. (1996). Lower bounds on arithmetic circuits via partial derivatives. *Computational Complexity*, 6:217–234.
