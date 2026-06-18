# Future Directions: Tropical Rank-One Theory and Beyond

## Overview

The tropical rank-1 equivalence theorem establishes a formal foundation connecting min-plus factorization, additive separability, and 2×2 minor vanishing. This document outlines five breakthrough research directions that build directly on this foundation.

---

## Direction 1: Approximate Rank-1 from Bounded Minor Defects

### Hypothesis
If all 2×2 tropical minor defects |δ₂(A)(i,i',j,j')| ≤ ε, then A is ε-close (in L∞ norm) to a rank-1 matrix, with explicit constant bounds.

### Proof Strategy
1. Define the basepoint reconstruction p(i) = A(i, j₀), q(j) = A(i₀, j) - A(i₀, j₀) as before.
2. Show that |A(i,j) - p(i) - q(j)| = |δ₂(A)(i, i₀, j, j₀)| ≤ ε by direct computation.
3. This gives an *immediate* L∞ bound: dist(A, rank-1) ≤ ε.
4. Prove optimality: there exist matrices with all minor defects = ε but dist(A, rank-1) = ε exactly.

### Formal Target
```
theorem approx_rank_one_of_bounded_defect {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (hA : ∀ i i' j j', |delta₂ A i i' j j'| ≤ ε) :
    ∃ p : Fin n → ℝ, ∃ q : Fin m → ℝ, ∀ i j, |A i j - p i - q j| ≤ ε
```

### Cross-Domain Connections
- **Robust optimization**: Quantitative stability for near-separable cost functions.
- **Machine learning**: Certificates for approximate low-rank tropical structure in weight matrices.
- **Differential geometry**: Approximate flatness ↔ bounded curvature, the discrete Cheeger-Gromov philosophy.

### Impact
This would be the first formal quantitative stability result for tropical rank, enabling error-tolerant algorithms for practical applications where data is noisy.

---

## Direction 2: Tropical Rank Stratification via Higher Minors

### Hypothesis
A matrix has tropical rank ≤ k if and only if certain (k+1)×(k+1) tropical minors satisfy specific identities, generalizing the 2×2 condition to arbitrary rank.

### Proof Strategy
1. Define tropical rank ≤ k using the MinPlusFactorRankLE definition.
2. Define tropical (k+1)×(k+1) permanents (tropical determinants): tperm(B) = min_σ Σ B(i, σ(i)).
3. Conjecture: rank ≤ k iff for all (k+1)×(k+1) submatrices, the tropical permanent is attained by at least two permutations.
4. For k = 1, verify this reduces to our 2×2 minor condition.
5. For k = 2, attempt to prove the 3×3 case, which would be a significant new result.

### Formal Target
```
def TropicalPermanent {k : ℕ} (B : Fin k → Fin k → ℝ) : ℝ :=
  Finset.univ.inf' (by simp) (fun σ : Equiv.Perm (Fin k) =>
    Finset.univ.sum (fun i => B i (σ i)))

def TropicalRankKMinorCondition (k : ℕ) {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∀ (rows : Fin (k+1) → Fin n) (cols : Fin (k+1) → Fin m),
    ∃ σ₁ σ₂ : Equiv.Perm (Fin (k+1)), σ₁ ≠ σ₂ ∧
    (Finset.univ.sum (fun i => A (rows i) (cols (σ₁ i)))) =
    (Finset.univ.sum (fun i => A (rows i) (cols (σ₂ i))))
```

### Cross-Domain Connections
- **Algebraic geometry**: Tropical Grassmannians and Dressians parameterize the space of tropical rank-k matrices.
- **Combinatorial optimization**: Monge sequences generalize to higher-rank anti-Monge structure.
- **Representation theory**: Tropical rank connects to Newton polytopes and crystal bases.

### Impact
This would establish the foundations for a complete tropical matrix rank theory, analogous to the classical theory built on minors and determinants.

---

## Direction 3: Extension to WithTop ℝ (Complete Tropical Semiring)

### Hypothesis
All main theorems extend to A : Fin n → Fin m → WithTop ℝ, where ⊤ represents +∞ (infinite/forbidden cost), with the convention min(a, ⊤) = a and a + ⊤ = ⊤.

### Proof Strategy
1. Define AdditivelySeparable for WithTop ℝ, handling the ⊤ + ⊤ = ⊤ case.
2. The minor condition needs careful treatment: A(i,j) + A(i',j') = A(i,j') + A(i',j) when some terms are ⊤.
3. Prove: if A has any finite entry, the minor condition forces the ⊤ entries to form a "rectangular" pattern (an antichain in the product order).
4. Reconstruct potentials in WithTop ℝ from the basepoint, with p(i) = ⊤ when row i is all-∞.

### Formal Target
```
def AdditivelySeparableTop {n m : ℕ} (A : Fin n → Fin m → WithTop ℝ) : Prop :=
  ∃ p : Fin n → WithTop ℝ, ∃ q : Fin m → WithTop ℝ, ∀ i j, A i j = p i + q j

theorem separable_iff_minorCondition_top {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → WithTop ℝ) :
    AdditivelySeparableTop A ↔ TropicalRankOneMinorConditionTop A
```

### Cross-Domain Connections
- **Tropical geometry**: The "true" tropical semiring is (ℝ ∪ {∞}, min, +) with ∞ as the additive identity.
- **Shortest paths**: Infinite entries represent absent edges; rank-1 means star-metric structure.
- **Algebraic completion**: WithTop ℝ is the one-point compactification needed for tropical projective geometry.

### Impact
This brings the formalization into contact with the full tropical semiring used in algebraic geometry and theoretical computer science, enabling formal tropical intersection theory.

---

## Direction 4: Algorithmic Extraction and Certification Procedures

### Hypothesis
The basepoint reconstruction algorithm can be formalized as a certified decision procedure: given A, it either produces a proof that A is rank-1 (with explicit witnesses) or a proof that A is not rank-1 (with an explicit minor violation).

### Proof Strategy
1. Implement the O(nm) algorithm as a Lean function: `rankOneDecompose : (Fin n → Fin m → ℝ) → Option ((Fin n → ℝ) × (Fin m → ℝ))`.
2. Prove completeness: if A is rank-1, the algorithm returns Some (p, q).
3. Prove soundness: if the algorithm returns Some (p, q), then A(i,j) = p(i) + q(j).
4. For the failure case, extract the first violating rectangle as a certificate.

### Formal Target
```
noncomputable def rankOneDecompose {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → ℝ) : Option ((Fin n → ℝ) × (Fin m → ℝ)) :=
  let p := fun i => A i 0
  let q := fun j => A 0 j - A 0 0
  if ∀ i j, A i j = p i + q j then some (p, q) else none

theorem rankOneDecompose_correct {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → ℝ) :
    (rankOneDecompose A).isSome ↔ AdditivelySeparable A
```

### Cross-Domain Connections
- **Certified computation**: Proof-carrying algorithms that guarantee correctness by construction.
- **Complexity theory**: Formal proof that rank-1 recognition is in linear time.
- **Verified optimization**: Certified preprocessing for transportation problems.

### Impact
This would demonstrate that tropical rank theory is not just mathematical elegance but computationally effective, with formal guarantees for every step.

---

## Direction 5: Tropical Convex Geometry of Rank-k Factorizations

### Hypothesis
The set of n×m matrices with tropical rank ≤ k forms a tropically convex set, and the rank-1 matrices are the extreme generators of this set for k = 1.

### Proof Strategy
1. Define tropical convex combinations: tropConv(A, B, λ) = min(A + λ, B + (−λ)) (or a suitable adaptation for matrix entries).
2. Show that rank-1 matrices are closed under tropical scaling: if A is rank-1, so is A + c for any constant c.
3. For tropical segments between rank-1 matrices, analyze the rank of the result.
4. Prove or disprove: the tropical convex hull of rank-1 matrices is exactly the set of rank ≤ k matrices for appropriate k.

### Formal Target
```
def TropicalConvexCombination {n m : ℕ} (A B : Fin n → Fin m → ℝ) (λ : ℝ) :
    Fin n → Fin m → ℝ :=
  fun i j => min (A i j + λ) (B i j - λ)

theorem tropConv_rank_bound {n m : ℕ}
    (A B : Fin n → Fin m → ℝ)
    (hA : MinPlusFactorRankLE 1 A) (hB : MinPlusFactorRankLE 1 B) (λ : ℝ) :
    MinPlusFactorRankLE 2 (TropicalConvexCombination A B λ)
```

### Cross-Domain Connections
- **Tropical geometry**: Tropical convex sets and tropical polytopes.
- **Optimization**: Tropical analogue of the nuclear norm ball.
- **Category theory**: The monoidal structure of tropical matrix spaces.

### Impact
This would establish the geometric foundations for tropical matrix approximation, connecting to tropical polytope theory and enabling optimization-based approaches to low-rank tropical factorization.

---

## Implementation Priority

| Priority | Direction | Estimated Effort | Dependencies |
|----------|-----------|-----------------|--------------|
| 1 | Approximate rank-1 (Dir. 1) | Low | Current theorems only |
| 2 | WithTop ℝ extension (Dir. 3) | Medium | Mathlib WithTop API |
| 3 | Algorithmic certification (Dir. 4) | Medium | Current theorems only |
| 4 | Higher rank stratification (Dir. 2) | High | Tropical permanents |
| 5 | Tropical convex geometry (Dir. 5) | High | Tropical convexity defs |

Direction 1 should be pursued immediately as it requires minimal new infrastructure and has the highest ratio of mathematical value to formal effort.
