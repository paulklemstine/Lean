# The Complete Berggren Tree: Machine-Verified Proofs and New Frontiers

## A Research Paper on the EML–Pythagorean Bridge, Version 8

---

### Abstract

We present a comprehensive machine-verified formalization of the Berggren tree — the unique ternary tree that generates all primitive Pythagorean triples from the root (3, 4, 5). Building on seven prior versions, this eighth installment contributes: (1) five new formalization files containing 85+ new machine-verified theorems with zero sorries; (2) correction of a subtle error regarding the nilpotency index of B₁ (it is 3, not 2); (3) a complete formalization of the Berggren–Stern-Brocot correspondence via the theta group; (4) the first formal verification of the B₁ power formula and A-branch triple family; (5) full Lorentz group analysis including all pairwise non-commutativity. All proofs are verified in Lean 4 with Mathlib, using only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**Keywords:** Pythagorean triples, Berggren tree, Lorentz group, formal verification, Lean 4, Pell equations, machine-checked proofs

---

### 1. Introduction

The Pythagorean equation a² + b² = c² is among the oldest in mathematics, yet its structure theory continues to reveal surprises. The **Berggren tree** (discovered by B. Berggren in 1934, rediscovered by Barning in 1963 and others since) provides the definitive structural answer: three 3×3 integer matrices B₁, B₂, B₃ acting on the root triple (3,4,5) generate every primitive Pythagorean triple (PPT) exactly once.

What makes this result remarkable is that the matrices belong to the integer Lorentz group O(2,1;ℤ) — the group of 3×3 integer matrices preserving the Lorentz form Q = a² + b² - c². The Berggren tree is thus a window into the arithmetic of hyperbolic geometry and special relativity, encoded in the most elementary number theory.

This paper reports on a systematic machine-verified formalization of the Berggren tree, contributing new theorems and correcting prior claims.

### 2. The Berggren Matrices

The three Berggren matrices are:

```
B₁ = ⎡ 1  -2   2 ⎤    B₂ = ⎡ 1   2   2 ⎤    B₃ = ⎡-1   2   2 ⎤
     ⎢ 2  -1   2 ⎥         ⎢ 2   1   2 ⎥         ⎢-2   1   2 ⎥
     ⎣ 2  -2   3 ⎦         ⎣ 2   2   3 ⎦         ⎣-2   2   3 ⎦
```

**Theorem 2.1** (Machine-verified). *All three matrices preserve the Lorentz form: BᵢᵀQBᵢ = Q where Q = diag(1,1,-1).*

**Theorem 2.2** (Machine-verified). *det(B₁) = det(B₃) = 1 and det(B₂) = -1. Thus B₁, B₃ ∈ SO(2,1;ℤ) while B₂ ∈ O(2,1;ℤ) \ SO(2,1;ℤ).*

### 3. Spectral Classification

| Matrix | Trace | Det | Char. Poly. | Eigenvalues | Type |
|--------|-------|-----|-------------|-------------|------|
| B₁     | 3     | 1   | (x-1)³      | {1,1,1}     | Parabolic |
| B₂     | 5     | -1  | x³-5x²-5x+1 | {-1, 3±2√2} | Hyperbolic |
| B₃     | 3     | 1   | (x-1)³      | {1,1,1}     | Parabolic |

**Theorem 3.1** (Cayley-Hamilton, machine-verified).
- B₁³ - 3B₁² + 3B₁ - I = 0
- B₂³ - 5B₂² - 5B₂ + I = 0

**Theorem 3.2** (Conjugacy). B₃ = S·B₁·S where S swaps legs. S² = I, det(S) = -1.

### 4. Nilpotent Structure (Corrected)

**Important Correction:** Prior analyses sometimes claimed (B₁-I)² = 0 (nilpotency index 2). Our machine verification reveals:

**Theorem 4.1** (Machine-verified).
- (B₁ - I)³ = 0 ✓
- (B₁ - I)² ≠ 0 ✓

The nilpotency index is **exactly 3**, not 2.

### 5. The Pell Connection (B₂ Branch)

The B₂ branch produces "almost-isosceles" right triangles where |a-b| = 1:

| n | (a, b, c) | |a-b| | cₙ₊₁/cₙ |
|---|-----------|-------|----------|
| 0 | (3, 4, 5) | 1 | — |
| 1 | (21, 20, 29) | 1 | 5.80 |
| 2 | (119, 120, 169) | 1 | 5.828 |
| 3 | (697, 696, 985) | 1 | 5.8284 |

**Theorem 5.1** (Machine-verified). *The hypotenuses satisfy cₙ₊₁ = 6cₙ - cₙ₋₁.*

**Theorem 5.2** (Machine-verified). *(1,-1,0)ᵀ is an eigenvector of B₂ with eigenvalue -1.*

### 6. The Stern-Brocot Correspondence

**Theorem 6.1** (Machine-verified). *M₃ = T² where T generates the parabolic subgroup of SL(2,ℤ).*

**Theorem 6.2** (Machine-verified). *M₃⁻¹·M₁ = S, the 90° rotation generator of SL(2,ℤ).*

**Corollary 6.3.** ⟨M₁, M₃⟩ contains the theta group Γ_θ, an index-3 subgroup of SL(2,ℤ).

### 7. Parent Existence and Completeness

**Theorem 7.1** (Machine-verified). *For any PPT (a,b,c) with a,b,c > 0:*
1. *The parent hypotenuse c' = 3c - 2(a+b) satisfies 0 < c' < c*
2. *The sign quantities σ₁ = a+2b-2c and σ₂ = 2a+b-2c cannot both be ≤ 0*
3. *When c = 5, the triple must be (3,4,5) or (4,3,5)*

### 8. Future Research Directions

See the companion document `FutureResearchDirections_v8.md` for detailed analysis of 15+ open research directions, including:

1. Full Berggren completeness (well-founded descent)
2. Free group problem for ⟨B₁, B₂, B₃⟩
3. Berggren zeta function
4. Quaternionic Berggren trees
5. Angle distribution and ergodic theory
6. Cryptographic applications
7. Categorical Berggren theory
8. K-theoretic interpretation
9. Quantum walks on the tree
10. Machine learning benchmarks

### 9. Conclusion

The v8 formalization adds 85+ machine-verified theorems across 5 new files with zero sorries. The key contribution is the correction of the nilpotency index and the new Stern-Brocot correspondence. All code is available in the project repository.

---

*EML–Pythagorean Bridge Research Program, v8*
*Machine-verified with Lean 4.28.0 + Mathlib*
