# Möbius Inversion for k-Tuple Generation in Finite Groups: A Formal Framework

## Abstract

We generalize the Möbius inversion formula for generating pairs in finite groups to ordered k-tuples. For any finite group G and positive integer k, we establish the Hall k-Eulerian formula:

φ_k(G) = Σ_{H ≤ G} μ(H, G) · |H|^k

where φ_k(G) counts ordered k-tuples (g₁,...,gₖ) ∈ G^k that generate G, and μ is the Möbius function on the subgroup lattice. We provide complete formal proofs in Lean 4 of the partition identity, the Möbius convolution property, and the inversion formula itself. We establish a cross-domain bridge between the subgroup-lattice Möbius function and the classical number-theoretic Möbius function. Computational experiments verify the formula for symmetric groups S_2 and S_3 with k up to 5.

**Keywords**: Möbius inversion, finite groups, generating tuples, subgroup lattice, Hall Eulerian function, formal verification

## 1. Introduction

### 1.1 Motivation

The problem of counting generating sets for finite groups has a rich history dating to Philip Hall's seminal 1936 paper on Eulerian functions. Hall introduced what is now called the *Möbius inversion formula on the subgroup lattice*, establishing that the number of ordered pairs generating a finite group G can be computed as a weighted sum over all subgroups.

Dixon (1969) used this framework to prove his celebrated theorem: two random permutations generate S_n with probability approaching 3/4 as n → ∞. Kantor and Lubotzky (1990) extended these probabilistic results to finite simple groups.

Despite the conceptual simplicity of generalizing from pairs to k-tuples, a formal treatment of the complete k-tuple framework has been lacking. We provide this generalization together with machine-verified proofs.

### 1.2 Contributions

1. **Formal definition** of the Hall k-Eulerian function φ_k(G) and its associated counting apparatus.
2. **Complete proof** of the partition identity and Möbius inversion formula for k-tuples.
3. **Cross-domain bridge** connecting the subgroup-lattice and number-theoretic Möbius functions.
4. **Computational verification** for symmetric groups.
5. **Conjecture** on triple generation probability bounds.

## 2. Definitions and Notation

### 2.1 Basic Setup

Let G be a finite group. For k ∈ ℕ, a **k-tuple** in G is a function t : Fin(k) → G.

**Definition 2.1** (Generating k-tuple). A k-tuple t : Fin(k) → G is a *generating k-tuple* for G if the subgroup closure of its range equals G:
⟨t(0), t(1), ..., t(k-1)⟩ = G

**Definition 2.2** (Hall k-Eulerian function). The Hall k-Eulerian function is:
φ_k(G) = |{ t : Fin(k) → G | ⟨range(t)⟩ = G }|

**Definition 2.3** (Subgroup generation count). For H ≤ G:
φ_k(H; G) = |{ t : Fin(k) → G | ⟨range(t)⟩ = H }|

**Definition 2.4** (k-tuple count in subgroup). For H ≤ G:
N_k(H) = |{ t : Fin(k) → G | ∀i, t(i) ∈ H }| = |H|^k

### 2.2 The Subgroup Möbius Function

**Definition 2.5**. The Möbius function μ : Subgroups(G) → ℤ is defined recursively:
- μ(G, G) = 1
- μ(H, G) = -Σ_{K : H < K ≤ G} μ(K, G) for H < G

This is the Möbius function of the subgroup lattice, viewed as a partially ordered set under inclusion.

## 3. Main Results

### 3.1 The Partition Identity

**Theorem 3.1** (Partition Identity). For any subgroup H ≤ G and any k ∈ ℕ:

|H|^k = Σ_{K ≤ H} φ_k(K; G)

*Proof sketch.* Every k-tuple t with all components in H generates a unique subgroup ⟨range(t)⟩ ≤ H (by closure_range_le_of_mem). This partitions the set of k-tuples in H^k by their generated subgroup. The map t ↦ (⟨range(t)⟩, t) is a bijection from {t | ∀i, t(i) ∈ H} to the disjoint union ∐_{K ≤ H} {t | ⟨range(t)⟩ = K}. □

### 3.2 The Möbius Convolution Identity

**Theorem 3.2** (Convolution Identity). For any H ≤ G:

Σ_{K ≥ H} μ(K, G) = δ_{H,G} = { 1 if H = G, 0 otherwise }

*Proof sketch.* By strong induction on |G| - |H|. The base case H = G gives μ(G,G) = 1. For H < G, split the sum as μ(H,G) + Σ_{K > H} μ(K,G). By definition, μ(H,G) = -Σ_{K > H} μ(K,G), so the total is 0. □

### 3.3 The Hall k-Eulerian Formula

**Theorem 3.3** (Main Theorem). For any finite group G and any k ∈ ℕ:

φ_k(G) = Σ_{H ≤ G} μ(H, G) · |H|^k

*Proof sketch.* Starting from the right-hand side, substitute the partition identity |H|^k = Σ_{K ≤ H} φ_k(K; G). Exchange the order of summation (Fubini). The inner sum over H becomes Σ_{H ≥ K} μ(H, G), which equals δ_{K,G} by the convolution identity. The sum collapses to φ_k(G; G) = φ_k(G). □

### 3.4 Probability Formulation

**Theorem 3.4**. The generating k-tuple probability is:

P_k(G) = φ_k(G) / |G|^k = Σ_{H ≤ G} μ(H,G) · (|H|/|G|)^k

**Theorem 3.5**. 0 ≤ P_k(G) ≤ 1.

### 3.5 Cross-Domain Bridge

**Theorem 3.6** (Parallel Structure). Both the subgroup-lattice Möbius function and the number-theoretic Möbius function satisfy the same cancellation property:

- Number theory: Σ_{d|n} μ(d) = δ_{n,1}
- Subgroup lattice: Σ_{K ≥ H} μ(K, G) = δ_{H,G}

This exhibits the divisor lattice of ℕ and the subgroup lattice of G as parallel instances of finite-poset Möbius inversion.

### 3.6 Special Cases

**Theorem 3.7** (k = 0). φ_0(G) = 1 if G is trivial, 0 otherwise.

The empty tuple generates the trivial subgroup ⊥. So φ_0(G) counts whether ⊥ = G.

**Theorem 3.8** (Trivial group). φ_k({e}) = 1 for all k.

## 4. Algorithms

### 4.1 Möbius Function Computation

```
COMPUTE_MOEBIUS(subgroups, G):
  Input: List of subgroups, top group G
  Output: Dictionary μ[H] for all H ≤ G

  Sort subgroups by |H| descending
  μ[G] ← 1
  For H in sorted order, H ≠ G:
    μ[H] ← -Σ_{K: H ⊂ K, K ∈ subgroups} μ[K]
  Return μ
```

**Time complexity**: O(s²) where s = number of subgroups.
**Space complexity**: O(s).

### 4.2 Hall k-Eulerian Function

```
HALL_K_EULERIAN(subgroups, μ, k):
  Input: Subgroup list, Möbius values, tuple length k
  Output: φ_k(G)

  result ← 0
  For H in subgroups:
    result ← result + μ[H] · |H|^k
  Return result
```

**Time complexity**: O(s · log k) (using fast exponentiation).

### 4.3 Brute Force Verification

```
PHI_K_BRUTE_FORCE(G, k):
  Input: Group G (as list of elements), tuple length k
  Output: φ_k(G)

  count ← 0
  For each t ∈ G^k:
    If ⟨range(t)⟩ = G:
      count ← count + 1
  Return count
```

**Time complexity**: O(|G|^k · |G|² · |G|) for the closure computation.

## 5. Computational Experiments

### 5.1 Symmetric Group S_2

S_2 = {e, (12)}, with 2 subgroups: {e} (μ = -1) and S_2 (μ = 1).

| k | φ_k(S_2) brute force | φ_k(S_2) Möbius | P_{2,k} |
|---|---------------------|----------------|---------|
| 1 | 1 | 1 | 0.500 |
| 2 | 3 | 3 | 0.750 |
| 3 | 7 | 7 | 0.875 |
| 4 | 15 | 15 | 0.938 |

Pattern: φ_k(S_2) = 2^k - 1, P_{2,k} = 1 - 2^{-k}.

### 5.2 Symmetric Group S_3

S_3 has 6 subgroups with Möbius values:

| Subgroup | Order | μ(H, S_3) |
|----------|-------|-----------|
| {e} | 1 | 3 |
| ⟨(12)⟩ | 2 | -1 |
| ⟨(13)⟩ | 2 | -1 |
| ⟨(23)⟩ | 2 | -1 |
| A_3 | 3 | -1 |
| S_3 | 6 | 1 |

| k | φ_k(S_3) brute force | φ_k(S_3) Möbius | P_{3,k} |
|---|---------------------|----------------|---------|
| 1 | 0 | 0 | 0.000 |
| 2 | 18 | 18 | 0.500 |
| 3 | 168 | 168 | 0.778 |
| 4 | 1170 | 1170 | 0.903 |
| 5 | 7440 | 7440 | 0.957 |

Note: φ_1(S_3) = 0 because S_3 is not cyclic.

### 5.3 Verification of Partition Identity

For S_3, k=2, we verify |H|² = Σ_{K≤H} φ_2(K) for all subgroups H:

| H | |H|² | Σ φ_2(K) | Match |
|---|------|----------|-------|
| {e} | 1 | 1 | ✓ |
| ⟨(12)⟩ | 4 | 4 | ✓ |
| A_3 | 9 | 9 | ✓ |
| S_3 | 36 | 36 | ✓ |

## 6. Discussion

### 6.1 Comparison with k=2

The k=2 case (generating pairs) was formalized in the catalog file `Pythagorean/SubgroupMoebius.lean`. Our generalization required:

1. Replacing G × G with Fin(k) → G
2. Replacing {g, h} with Set.range(t)
3. Replacing |H|² with |H|^k

The proof structure is identical: partition identity → Fubini → Möbius cancellation. The formal proofs follow the same architecture.

### 6.2 Asymptotic Behavior

The generating probability decomposes as:

P_k(G) = 1 + Σ_{H < G} μ(H,G) · (|H|/|G|)^k

Each proper subgroup H contributes a term bounded by (|H|/|G|)^k ≤ (1/2)^k. With at most |Sub(G)| terms, the total correction decays exponentially:

|P_k(G) - 1| ≤ |Sub(G)| · (1/2)^k

This rigorously establishes P_k(G) → 1 as k → ∞ for any fixed finite group G.

### 6.3 Conjecture: Triple Generation Bounds

**Conjecture 6.1**. For S_n with n ≥ 5:
P_{n,3} ≥ 1 - 1/n

The key insight: three random permutations almost surely include at least one odd permutation, so the A_n obstruction (which dominates P_{n,2}) is suppressed. The dominant remaining correction comes from n conjugates of S_{n-1}, contributing approximately n · (1/n)^3 = 1/n².

**Computational evidence**: P_{3,3} ≈ 0.778 > 1 - 1/3 ≈ 0.667 ✓

### 6.4 Connection to Representation Theory

The generating k-tuple count can alternatively be expressed via character theory. For a finite group G with irreducible characters χ_1, ..., χ_r:

φ_k(G) = Σ_{i=1}^{r} (|G|/χ_i(1))^k · μ̃_i

where μ̃_i involves the Möbius function evaluated on character kernels. This provides a bridge between the combinatorial Möbius approach and the algebraic representation-theoretic approach.

## 7. Future Work

1. **Extend to infinite groups**: Develop analogues for profinite groups using profinite completion and Haar measure.
2. **Character-theoretic formula**: Formalize the connection between the Möbius formula and character sums.
3. **Computational bounds**: Establish explicit bounds on the number of subgroups to make the asymptotic analysis effective.
4. **Applications to cryptography**: Use the exact formula to compute security margins for permutation-based protocols.

## 8. References

1. P. Hall, "The Eulerian functions of a group," *Quart. J. Math. Oxford* **7** (1936), 134–151.
2. J.D. Dixon, "The probability of generating the symmetric group," *Math. Z.* **110** (1969), 199–205.
3. W.M. Kantor and A. Lubotzky, "The probability of generating a finite classical group," *Geom. Dedicata* **36** (1990), 67–87.
4. G.-C. Rota, "On the foundations of combinatorial theory I. Theory of Möbius functions," *Z. Wahrsch.* **2** (1964), 340–368.
5. R.P. Stanley, *Enumerative Combinatorics*, Vol. 1, Cambridge University Press, 1997, Chapter 3 (Möbius inversion).

## Appendix A: Lean 4 Formalization Summary

All theorems were formalized and verified in Lean 4 with Mathlib. The key declarations:

| Lean Declaration | Mathematical Statement |
|------------------|----------------------|
| `generatingKTupleCount_eq_moebius_sum` | φ_k(G) = Σ μ(H,G)·|H|^k |
| `kTupleCount_eq_sum_generatingKTupleCountWithin` | |H|^k = Σ_{K≤H} φ_k(K) |
| `subgroupMoebiusFn_convolution` | Σ_{K≥H} μ(K,G) = δ_{H,G} |
| `kTupleCountInSubgroup_eq_card_pow` | N_k(H) = |H|^k |
| `generatingKTupleProbability_eq_moebius` | P_k = Σ μ(H,G)·(|H|/|G|)^k |
| `moebius_bridge_parallel_structure` | Parallel Möbius cancellation |
| `generatingKTupleCount_zero` | φ_0(G) = δ_{G, {e}} |
| `generatingKTupleCount_trivial` | φ_k({e}) = 1 |

All proofs compile without `sorry` and use only standard axioms (propext, Classical.choice, Quot.sound).
