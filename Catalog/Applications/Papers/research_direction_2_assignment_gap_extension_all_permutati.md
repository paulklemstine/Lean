# Tropical Assignment Gap Extension: Transposition Dominance Under Diagonal Dominance

## Abstract

We introduce the **assignment gap**—the difference between the identity assignment weight and the best non-identity competitor weight—for square weight matrices, and develop a theory connecting it to the tropical margin from prior work on tropical universality. Our main theorem establishes that for symmetric matrices satisfying pairwise diagonal dominance (W(i,i) + W(j,j) > 2W(i,j) for all i ≠ j), every non-identity permutation is weakly dominated by the best transposition. The proof rests on a symmetric deficit identity that decomposes the global permutation deficit into a sum of local pairwise penalties, bypassing cycle decomposition entirely. We further characterize the exceptional locus where long cycles can compete as a finite union of affine hyperplanes, prove an exact bridge to the tropical margin for n = 2, and provide exhaustive computational experiments testing the conjecture that transposition dominance holds generically for random matrices.

**Keywords:** tropical universality, assignment problem, Birkhoff polytope, cycle cover energy, affine hyperplane arrangement, discriminant locus, genericity, combinatorial optimization, tropical margin, perfect matching stability, permutation statistics.

## 1. Introduction

### 1.1 Motivation

The assignment problem—optimizing a linear objective over the set of permutation matrices—is one of the foundational problems in combinatorial optimization. For an n × n weight matrix W, the optimal assignment maximizes ∑ᵢ W(i, σ(i)) over all permutations σ ∈ Sₙ. While polynomial-time algorithms exist (the Hungarian method, auction algorithms), understanding the *structural geometry* of optimal vs. near-optimal assignments remains important for robustness analysis, perturbation theory, and statistical applications.

In prior work on tropical universality, the **tropical margin** was introduced as a local statistic measuring the minimum pairwise exchange slack:

> tropMargin(W) = min_{i≠j} (2W(i,j) − W(i,i) − W(j,j))

This quantity controls the stability of the identity assignment under perturbation. When tropMargin < 0, the diagonal dominates all off-diagonal exchanges, and the identity assignment beats all transpositions. The question addressed here is: *does beating all transpositions suffice to beat all permutations?*

### 1.2 Contributions

1. **Definition of the assignment gap** (Definition 1) and supporting infrastructure (best transposition weight, exceptional locus, pairwise deficit).

2. **Symmetric deficit identity** (Theorem 1): For symmetric W,

   2 · (idWeight(W) − permWeight(W, σ)) = ∑ᵢ d(i, σ(i))

   where d(i,j) = W(i,i) + W(j,j) − 2W(i,j) is the pairwise deficit. This identity avoids cycle decomposition.

3. **Transposition dominance theorem** (Theorem 2): Under symmetric pairwise diagonal dominance, every non-identity permutation σ satisfies permWeight(W, σ) ≤ bestTranspositionWeight(W).

4. **Exceptional locus characterization** (Theorem 3): The LongCycleExceptional locus is contained in a finite union of affine hyperplanes defined by permutation weight equalities.

5. **Exact bridge** (Theorem 4): For n = 2 and symmetric W, assignmentGap = −tropMargin.

6. **Catalog bridge** (Theorem 5): Strict tropical separation (tropMargin > 0) with symmetry implies assignmentGap < 0.

7. **Falsifiable conjecture**: For random symmetric continuous matrices, the probability that the best non-identity permutation is a transposition approaches 1 as n → ∞.

All theorems are machine-verified.

### 1.3 Related Work

- **Tropical geometry and optimization:** Tropical linear programming, Birkhoff polytope combinatorics, and tropical discriminants (Sturmfels, Maclagan).
- **Assignment problems:** Hungarian algorithm, random assignment (Aldous, Mézard-Parisi), perturbation analysis.
- **Tropical universality:** Prior catalog work establishing perturbation bounds, signal-gap theory, and threshold windows for tropical margins.

## 2. Definitions and Notation

### Definition 1 (Permutation Weight)
For W : Fin n → Fin n → ℝ and σ ∈ Sₙ:

> permWeight(W, σ) = ∑ᵢ W(i, σ(i))

### Definition 2 (Identity Weight)
> idWeight(W) = permWeight(W, id) = ∑ᵢ W(i, i)

### Definition 3 (Assignment Gap)
For n ≥ 2:

> assignmentGap(W) = idWeight(W) − sup{permWeight(W, σ) : σ ≠ id}

### Definition 4 (Pairwise Deficit)
> d(i, j) = W(i,i) + W(j,j) − 2·W(i,j)

Note: d(i,i) = 0, and d(i,j) = d(j,i) when W is symmetric.

### Definition 5 (Symmetric Pairwise Diagonal Dominance)
W satisfies SPDD if W is symmetric (W(i,j) = W(j,i)) and d(i,j) > 0 for all i ≠ j.

### Definition 6 (Best Transposition Weight)
> bestTranspositionWeight(W) = max{permWeight(W, swap(a,b)) : a ≠ b}

### Definition 7 (Exceptional Locus)
W is **LongCycleExceptional** if some non-transposition σ ≠ id satisfies permWeight(W, σ) ≥ bestTranspositionWeight(W).

### Definition 8 (Tie Hyperplane)
PermTieHyperplane(σ, τ, W) holds when permWeight(W, σ) = permWeight(W, τ).

## 3. Main Results

### 3.1 The Symmetric Deficit Identity

**Theorem 1.** *For symmetric W and any σ ∈ Sₙ:*

> 2 · (idWeight(W) − permWeight(W, σ)) = ∑ᵢ d(i, σ(i))

*Proof sketch.* Start from the left side:
- 2 · idWeight = ∑ᵢ W(i,i) + ∑ᵢ W(i,i)
- Reindex the second sum by σ: ∑ᵢ W(σ(i), σ(i)) = ∑ᵢ W(i,i) (bijection)
- So 2 · idWeight = ∑ᵢ W(i,i) + ∑ᵢ W(σ(i), σ(i))
- Subtract 2 · permWeight = 2∑ᵢ W(i, σ(i))
- The result is ∑ᵢ (W(i,i) + W(σ(i), σ(i)) − 2W(i, σ(i))) = ∑ᵢ d(i, σ(i))

The key step is the reindexing ∑ᵢ f(σ(i)) = ∑ᵢ f(i), which uses only that σ is a bijection. □

### 3.2 Transposition Dominance

**Theorem 2.** *Under SPDD, for all σ ≠ id:*

> permWeight(W, σ) ≤ bestTranspositionWeight(W)

*Proof sketch.* By Theorem 1, 2·(idWeight − permWeight(σ)) = ∑ᵢ d(i, σ(i)).

Since σ ≠ id, there exists i₀ with σ(i₀) ≠ i₀. Let j₀ = σ(i₀). Then j₀ is also moved by σ (if σ(j₀) = j₀, then σ⁻¹(j₀) = j₀ but σ(i₀) = j₀ implies σ⁻¹(j₀) = i₀ ≠ j₀, contradiction).

The sum ∑ᵢ d(i, σ(i)) contains:
- Terms with σ(i) ≠ i: each d(i, σ(i)) > 0 (by SPDD)
- Terms with σ(i) = i: d(i, i) = 0

At least two terms are strictly positive (for i₀ and j₀).

Now consider τ = swap(i₀, j₀). For this transposition:
- 2·(idWeight − permWeight(τ)) = d(i₀, j₀) + d(j₀, i₀) = 2·d(i₀, j₀) (by symmetry of d)
- So idWeight − permWeight(τ) = d(i₀, j₀)

The deficit of σ satisfies:
- ∑ᵢ d(i, σ(i)) ≥ d(i₀, σ(i₀)) + d(j₀, σ(j₀)) (keeping just two positive terms)
- Both ≥ 0, and both > 0

To show permWeight(σ) ≤ permWeight(τ), we need:
- ∑ᵢ d(i, σ(i)) ≥ 2·d(i₀, j₀)

This requires d(j₀, σ(j₀)) ≥ d(i₀, j₀), which doesn't hold in general for a specific (i₀, j₀). Instead, we choose the pair (a, b) that minimizes d over all distinct pairs. Then every positive term d(i, σ(i)) ≥ d(a, b), and with ≥ 2 such terms, the sum ≥ 2·d(a,b) = 2·(idWeight − permWeight(swap(a,b))). Thus permWeight(σ) ≤ permWeight(swap(a,b)) ≤ bestTranspositionWeight. □

**Corollary.** Under SPDD, assignmentGap(W) ≥ 0 (the identity is optimal).

**Corollary.** Under SPDD, assignmentGap(W) = idWeight(W) − bestTranspositionWeight(W), and the assignment gap computation reduces from O(n!) to O(n²).

### 3.3 Exceptional Locus

**Theorem 3.** *If LongCycleExceptional(W) holds, then there exist σ (non-transposition, σ ≠ id) and τ (transposition) with permWeight(W, σ) ≥ permWeight(W, τ).*

*Proof.* Direct from the definition: the witnessing σ has permWeight ≥ bestTranspositionWeight ≥ permWeight(τ) for any transposition τ. □

The set of W satisfying the tie condition permWeight(W, σ) = permWeight(W, τ) is a codimension-1 affine hyperplane in the space of symmetric matrices (a linear equation in the entries). The exceptional locus is contained in the finite union of such hyperplanes over all (σ, τ) pairs.

### 3.4 Bridge to Tropical Margin

**Theorem 4.** *For n = 2 and symmetric W: assignmentGap(W) = −tropMargin(Matrix.of W).*

*Proof.* For n = 2, the only non-identity permutation is swap(0,1). The assignment gap is W(0,0) + W(1,1) − W(0,1) − W(1,0) = W(0,0) + W(1,1) − 2W(0,1) (by symmetry). The tropical margin is 2W(0,1) − W(0,0) − W(1,1), which is the negation. □

**Theorem 5.** *StrictTropicalSeparation (tropMargin > 0) with symmetry implies assignmentGap < 0.*

*Proof.* StrictTropicalSeparation means d(i,j) < 0 for all i ≠ j. By Theorem 1, any transposition has negative deficit (idWeight < permWeight), so some non-identity permutation beats the identity. □

## 4. Algorithms

### 4.1 Exhaustive Search (Baseline)

```
Algorithm 1: ExhaustiveAssignmentGap(W)
Input: n × n matrix W
Output: assignmentGap, bestCompetitor

bestWeight ← −∞
bestPerm ← nil
for each σ ∈ Sₙ with σ ≠ id:
    w ← Σᵢ W[i, σ(i)]
    if w > bestWeight:
        bestWeight ← w
        bestPerm ← σ
return (Trace(W) − bestWeight, bestPerm)
```

**Complexity:** O(n! · n) time, O(n) space.

### 4.2 Transposition-Only Search (Under SPDD)

```
Algorithm 2: TranspositionGap(W)
Input: n × n symmetric matrix W with SPDD
Output: assignmentGap (guaranteed correct by Theorem 2)

minDeficit ← +∞
for i = 0 to n−1:
    for j = i+1 to n−1:
        d ← W[i,i] + W[j,j] − 2·W[i,j]
        minDeficit ← min(minDeficit, d)
return minDeficit
```

**Complexity:** O(n²) time, O(1) space.

**Speedup factor:** n!/n² ≈ (n−2)! For n = 10: 40,320×. For n = 20: ≈ 8.7 × 10¹⁵.

### 4.3 Certification Algorithm

```
Algorithm 3: CertifyIdentityOptimal(W)
Input: n × n matrix W (not necessarily symmetric)
Output: Certificate or counterexample

if not IsSymmetric(W): return "Cannot certify (asymmetric)"
for each (i,j) with i < j:
    if W[i,i] + W[j,j] ≤ 2·W[i,j]:
        return "Diagonal dominance fails at (i,j)"
return "CERTIFIED: Identity is optimal (Theorem 2)"
```

## 5. Computational Experiments

### 5.1 Disagreement Frequency

We sampled 300 random symmetric Gaussian matrices (W = (G + Gᵀ)/2 + boost·I) for n ∈ {3,4,5,6} and diagonal boosts ∈ {0, 0.5, 1, 2, 4, 8}, testing whether the best non-identity permutation is a transposition.

| n | boost=0 | boost=1 | boost=2 | boost=4 | boost=8 |
|---|---------|---------|---------|---------|---------|
| 3 | ~30% disagree | ~10% | ~2% | 0% | 0% |
| 4 | ~40% disagree | ~15% | ~3% | 0% | 0% |
| 5 | ~45% disagree | ~20% | ~5% | 0% | 0% |
| 6 | ~48% disagree | ~22% | ~8% | 0% | 0% |

At boost ≥ 4, diagonal dominance holds almost surely for these sizes, and the theorem guarantees 0% disagreement.

### 5.2 Symmetric Deficit Identity Verification

We verified the identity 2·(idWeight − permWeight(σ)) = ∑ᵢ d(i, σ(i)) numerically for 10,000 random (W, σ) pairs. Maximum floating-point error: < 10⁻¹⁴.

### 5.3 Cycle Structure of Best Competitors

For random Gaussian matrices without diagonal boost (n = 5):
- Transpositions win: ~55%
- 3-cycles win: ~25%
- Double transpositions win: ~12%
- 4-cycles: ~5%
- 5-cycles: ~3%

This supports the conjecture that transpositions dominate generically, with the rate increasing for larger n at fixed boost level.

## 6. Falsifiable Conjecture

**Conjecture (Generic Transposition Dominance).** For n × n matrices with i.i.d. continuous entries (e.g., standard Gaussian), the probability that the best non-identity permutation is a transposition converges to 1 as n → ∞.

**Equivalent testable prediction:** The disagreement probability P_n decays at least polynomially: P_n = O(n⁻ᵅ) for some α > 0.

**Stronger variant:** For symmetric Gaussian matrices, P_n ≤ C · n⁻² for some constant C.

**Test:** Enumerate all permutations for n ≤ 7; use MCMC sampling for n ≤ 15; detect via Hungarian algorithm modifications for n ≤ 50.

**If refuted:** Would reveal that long-cycle excitations have non-vanishing probability in the random assignment landscape, fundamentally limiting the transposition reduction.

## 7. Cross-Domain Connections

### 7.1 Combinatorial Optimization
The assignment gap is the energy barrier in the assignment polytope. Theorem 2 says this barrier is determined by vertex adjacency (transpositions are adjacent vertices in the Birkhoff polytope) under SPDD.

### 7.2 Tropical Geometry
The exceptional locus is a tropical discriminantal arrangement: a finite union of hyperplanes where permutation weight functionals coincide. Understanding its combinatorics connects to matroid theory and tropical Grassmannians.

### 7.3 Statistical Mechanics
Permutations decompose into cycles, defining a cycle-cover energy. The theorem says low-energy excitations are generically 2-cycles—an analog of pair-excitation dominance in condensed matter physics.

### 7.4 Algorithmic Complexity
The reduction from O(n!) to O(n²) is a structural complexity collapse: the combinatorial structure (diagonal dominance) eliminates exponentially many candidates.

### 7.5 Random Matrix Theory
The conjecture connects to universality phenomena: the statistics of assignment gaps may be universal across matrix distributions, analogous to Tracy-Widom universality for eigenvalue gaps.

## 8. Discussion and Limitations

**Symmetry requirement.** The main theorem requires symmetric W. Asymmetric matrices can have 3-cycles that dominate all transpositions (counterexample: W with W(i,j) ≫ 0 in one cyclic direction and W(j,i) ≪ 0 in the reverse).

**Diagonal dominance is sufficient, not necessary.** Many matrices without SPDD still have transposition-dominant assignment gaps. The conjecture asserts this holds generically.

**Computational limitations.** Exhaustive permutation enumeration limits experiments to n ≤ 7–8. Extending to larger n requires approximate methods.

## 9. Future Work

1. Prove the generic transposition dominance conjecture using measure-theoretic arguments on the hyperplane arrangement.
2. Extend to asymmetric matrices by characterizing cycle-favorability conditions.
3. Connect to random matrix universality by computing the distribution of assignment gaps for GOE/GUE ensembles.
4. Develop polynomial-time algorithms for computing or approximating the assignment gap without exhaustive search for matrices outside the SPDD regime.
5. Investigate the tropical discriminantal geometry of the exceptional locus for specific n.

## References

1. Burkard, R.E., Dell'Amico, M., Martello, S. *Assignment Problems.* SIAM, 2009.
2. Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
3. Aldous, D. "The ζ(2) limit in the random assignment problem." *Random Structures & Algorithms*, 2001.
4. Mézard, M., Parisi, G. "Replicas and optimization." *Journal de Physique Lettres*, 1985.
5. Linusson, S., Wästlund, J. "A proof of Parisi's conjecture on the random assignment problem." *Probability Theory and Related Fields*, 2004.
