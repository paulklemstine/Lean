# Holographic Code Towers: Gravity from Quantum Error Correction

## Abstract

We introduce the **HolographicCodeTower**, a novel mathematical structure formalizing the connection between quantum error-correcting codes and the radial foliation of anti-de Sitter spacetime. A code tower is a family of quantum codes indexed by radial depth, all encoding the same logical information but with strictly increasing code distance at deeper layers. We prove that for MDS (Maximum Distance Separable) towers, the discrete second derivative of the block length sequence — which we interpret as "curvature" — equals exactly twice the discrete second derivative of the distance sequence. This **Curvature-Distance Correspondence** is the coding-theoretic analogue of the Einstein equation. We further prove complementary recovery (the entanglement wedge reconstruction theorem), the Ryu-Takayanagi formula from Singleton saturation, and that uniform MDS towers have zero curvature (corresponding to pure AdS spacetime). All results are formally verified in Lean 4 with complete machine-checked proofs.

## 1. Introduction

The holographic principle, originating from work by 't Hooft and Susskind, asserts that the information content of a region of space is bounded by the area of its boundary rather than its volume. The AdS/CFT correspondence provides a concrete realization: a (d+1)-dimensional bulk gravitational theory is equivalent to a d-dimensional boundary conformal field theory.

The connection between holography and quantum error correction was made explicit by Almheiri, Dong, and Harlow (2015), who showed that the entanglement wedge reconstruction property of AdS/CFT can be understood through the lens of quantum error correction. Pastawski, Yoshida, Harlow, and Preskill (2015) constructed explicit holographic codes using tensor networks.

In this work, we formalize and extend this connection by introducing the **HolographicCodeTower** — a layered family of quantum codes that models the radial structure of AdS spacetime. Our main contributions are:

1. A novel mathematical structure capturing radial foliation through layered codes
2. The **Curvature-Distance Correspondence**: κ_n = 2κ_d for MDS towers
3. Complementary recovery and exclusion theorems from code parameters
4. The RT formula as Singleton saturation
5. All results formally verified in Lean 4

## 2. Definitions

### 2.1 Quantum Error-Correcting Codes

**Definition 2.1** (QECC). A quantum error-correcting code is a triple [[n, k, d]] where:
- n ∈ ℕ is the number of physical qubits (block length)
- k ∈ ℕ is the number of logical qubits, with k ≤ n
- d ∈ ℕ is the code distance, with d ≥ 1

subject to the **quantum Singleton bound**: k + 2d ≤ n + 2.

**Definition 2.2** (MDS Code). A code is *Maximum Distance Separable* if k + 2d = n + 2 (Singleton saturation). The [[5,1,3]] code is the prototypical example.

**Definition 2.3** (Entropy Defect). The defect of a code is δ = (n + 2) - (k + 2d) ≥ 0, measuring the gap from MDS optimality.

**Definition 2.4** (Singleton Entropy). The Singleton entropy is S = (n - k)/2, which for MDS codes equals d - 1.

### 2.2 Holographic Code Tower

**Definition 2.5** (HolographicCodeTower). A holographic code tower of height h ≥ 1 is a family of quantum codes {C_l}_{l=0}^{h-1} satisfying:
1. **Constant logical content**: k(C_l₁) = k(C_l₂) for all l₁, l₂
2. **Strict distance monotonicity**: l₁ < l₂ ⟹ d(C_{l₁}) < d(C_{l₂})
3. **Singleton at each layer**: Each C_l satisfies the quantum Singleton bound

**Definition 2.6** (Tower Curvature). For an interior layer l (0 < l < h-1), the discrete curvature is:

κ(l) = n(l+1) - 2n(l) + n(l-1) ∈ ℤ

**Definition 2.7** (Fully MDS Tower). A tower is fully MDS if every layer satisfies k + 2d = n + 2.

### 2.3 Boundary Regions and Recovery

**Definition 2.8** (Boundary Region). A boundary region of code C is a subset of size s ≤ n.

**Definition 2.9** (Reconstruction). A region of size s can reconstruct the logical information if s ≥ n - d + 1 (the complement has at most d - 1 qubits erased).

## 3. Main Results

### 3.1 Tower Monotonicity (PEGB-1)

**Theorem 3.1** (MDS Tower Block Length Monotonicity). For a fully MDS holographic code tower, l₁ < l₂ implies n(l₁) < n(l₂).

*Proof sketch*: MDS gives n = k + 2d - 2 at each layer. Since k is constant and d is strictly increasing, n is strictly increasing. □

**Example**: The tower [[5,1,3]] → [[7,1,4]] has n increasing from 5 to 7 as d increases from 3 to 4. Both codes are MDS (1 + 6 = 7 = 5 + 2 and 1 + 8 = 9 = 7 + 2).

**Generalization** (Theorem `general_tower_monotonicity_mds`): The same monotonicity holds for any sequence of ℕ-valued functions n, k, d satisfying the MDS condition and constant k.

**Boundary**: Without the MDS condition, the theorem fails. Counterexample: [[100, 1, 3]] → [[5, 1, 4]] has both codes satisfying Singleton but n decreasing.

### 3.2 Curvature-Distance Correspondence (PEGB-2)

**Theorem 3.2** (MDS Curvature Identity). For a fully MDS tower at interior layer l:

κ_n(l) = 2 · κ_d(l)

where κ_n(l) = n(l+1) - 2n(l) + n(l-1) and κ_d(l) = d(l+1) - 2d(l) + d(l-1).

*Proof sketch*: MDS gives n(l) = k + 2d(l) - 2 for constant k. Direct computation:
n(l+1) - 2n(l) + n(l-1) = [k + 2d(l+1) - 2] - 2[k + 2d(l) - 2] + [k + 2d(l-1) - 2] = 2[d(l+1) - 2d(l) + d(l-1)]. □

**Example**: Tower with d = [1, 3, 4], k = 1: n = [1, 5, 7]. κ_n(1) = 7 - 10 + 1 = -2. κ_d(1) = 4 - 6 + 1 = -1. Indeed κ_n = 2κ_d.

**Generalization** (Lemma `mds_curvature_identity`): The identity holds for any three MDS codes with the same k value, independent of the tower structure.

**Boundary**: For non-MDS codes, the defect contributes additional terms. The identity becomes κ_n = 2κ_d + (defect corrections).

### 3.3 Uniform Towers are Flat (PEGB-3)

**Theorem 3.3** (Uniform MDS Tower Flatness). If d(l+1) = d(l) + 1 for all consecutive layers, then κ(l) = 0 at every interior layer.

*Proof sketch*: By the curvature identity, κ_n = 2κ_d. With uniform d-spacing, κ_d = d(l+1) - 2d(l) + d(l-1) = (d(l)+1) - 2d(l) + (d(l)-1) = 0. □

**Example**: Tower with d = [2, 3, 4, 5], k = 1: n = [3, 5, 7, 9] (arithmetic progression). All interior curvatures are 0.

**Generalization**: Non-uniform d-spacing produces curvature κ ≠ 0, interpretable as "matter" in the bulk.

**Boundary**: For towers with height < 3, there are no interior layers and curvature is undefined.

### 3.4 RT Formula from Singleton Saturation (PEGB-4)

**Theorem 3.4** (RT = Singleton for MDS). For an MDS code: singletonEntropy = d - 1.

*Proof sketch*: MDS gives k + 2d = n + 2, so n - k = 2d - 2. Then (n-k)/2 = d - 1. □

**Example**: [[5,1,3]] has Singleton entropy (5-1)/2 = 2 = 3 - 1 = d - 1. ✓

**Generalization**: For non-MDS codes, singletonEntropy ≥ d - 1 (strict inequality).

**Boundary**: For k = 0, the Singleton entropy equals n/2, which is just the "area" bound with no logical content.

### 3.5 Complementary Recovery and Exclusion (PEGB-5)

**Theorem 3.5** (Complementary Recovery). For an MDS code, a region of size ≥ (n+k)/2 + 1 can reconstruct.

**Theorem 3.6** (Complementary Exclusion). For an MDS code with k > 0, if region A reconstructs and |A| < n, then Ā cannot reconstruct.

*Proof sketch*: For MDS, d = (n-k)/2 + 1. Recovery threshold: n - d + 1 = (n+k)/2. If |A| ≥ (n+k)/2 + 1 and |A| < n, then |Ā| = n - |A| ≤ (n-k)/2 - 1 < d - 1 ≤ n - d + 1 when k > 0. □

**Example**: [[5,1,3]]: recovery threshold = 5 - 3 + 1 = 3. Region of size 3 can reconstruct; complement of size 2 cannot.

**Boundary**: For k = 0 (trivial code), both A and Ā can "reconstruct" since there's no logical information.

## 4. The Bekenstein-Hawking Entropy as a Coding Theorem

**Theorem 4.1** (Bekenstein-Singleton Correspondence). For an MDS code:
S_BH(2(n-k)) = singletonEntropy(n, k) = d - 1

where S_BH(A) = A/4 is the Bekenstein-Hawking entropy with area A.

This identifies:
- Area A = 2(n - k) = 2 × redundancy
- S_BH = (n - k)/2 = d - 1

The holographic dictionary:
| Physics | Coding Theory |
|---------|---------------|
| Boundary area | Block length n |
| Bulk entropy | Logical qubits k |
| Geodesic depth | Code distance d |
| Bekenstein-Hawking S = A/4G | Singleton entropy (n-k)/2 |
| Einstein equation | Curvature identity κ_n = 2κ_d |
| Null energy condition | Convexity of tower block lengths |
| Pure AdS | Uniform MDS tower (κ = 0) |
| Matter content | Entropy defect δ > 0 |

## 5. Algorithms

### 5.1 Tower Construction Algorithm

Given k (logical qubits) and a distance sequence d₀ < d₁ < ... < d_{h-1}:

```python
def construct_mds_tower(k, distances):
    """Construct an MDS holographic code tower."""
    codes = []
    for d in distances:
        n = k + 2*d - 2  # MDS condition
        codes.append((n, k, d))
    return codes
```

### 5.2 Curvature Computation

```python
def tower_curvature(tower, l):
    """Compute discrete curvature at interior layer l."""
    n_prev, _, _ = tower[l-1]
    n_curr, _, _ = tower[l]
    n_next, _, _ = tower[l+1]
    return n_next - 2*n_curr + n_prev
```

## 6. Falsifiable Conjecture

**Conjecture 6.1** (Holographic Entropy Cone = MDS Singleton Cone). The set of entropy vectors realizable by families of MDS quantum codes is exactly the holographic entropy cone (characterized by strong subadditivity plus monogamy of mutual information).

**Computational Test**: For 3 parties with total boundary size n, partition into regions A, B, C. For each MDS code family, compute the entropy vector. Check if the resulting vectors fill exactly the holographic entropy cone.

## 7. Discussion

The HolographicCodeTower provides a bridge between quantum coding theory and gravitational physics that is both mathematically precise and physically suggestive. The key insight is that the Singleton bound — a purely information-theoretic constraint — has the exact algebraic structure of the Bekenstein-Hawking entropy formula when interpreted holographically.

The Curvature-Distance Correspondence (Theorem 3.2) is particularly striking: it shows that "spacetime curvature" (the second derivative of boundary area with respect to bulk depth) is determined entirely by the "geodesic curvature" (the second derivative of code distance), with a universal factor of 2. This factor comes from the quantum doubling in the Singleton bound (quantum codes need twice the redundancy of classical codes).

The uniform tower flatness theorem (Theorem 3.3) is the coding-theoretic analogue of the statement that pure AdS spacetime (with no matter) is described by zero curvature. Non-uniform distance growth — which we interpret as "matter" in the bulk — produces non-zero curvature.

## 8. References

1. Almheiri, A., Dong, X., & Harlow, D. (2015). Bulk locality and quantum error correction in AdS/CFT. JHEP, 2015(4), 163.
2. Pastawski, F., Yoshida, B., Harlow, D., & Preskill, J. (2015). Holographic quantum error-correcting codes: Toy models for the bulk/boundary correspondence. JHEP, 2015(6), 149.
3. Ryu, S., & Takayanagi, T. (2006). Holographic derivation of entanglement entropy from the AdS/CFT correspondence. Physical Review Letters, 96(18), 181602.
4. Bekenstein, J. D. (1973). Black holes and entropy. Physical Review D, 7(8), 2333.
5. Hawking, S. W. (1975). Particle creation by black holes. Communications in Mathematical Physics, 43(3), 199-220.
