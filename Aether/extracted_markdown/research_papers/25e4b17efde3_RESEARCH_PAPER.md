# CSS Codes as Cohomology: Homological Quantum Error Correction

## Abstract

We establish a precise mathematical correspondence between Calderbank-Shor-Steane (CSS) quantum error-correcting codes and the first cohomology of chain complexes over F₂. We formalize the definitions of CSS codes, F₂-chain complexes, and their connection, proving that the CSS code construction from a chain complex yields a code whose logical qubit count equals the dimension of the first homology group. We introduce the notion of a Homological Quantum Error-Correcting Code (HQECC) and analyze its parameters for several families of graphs and simplicial complexes. We computationally test and falsify the conjecture that hypercube graphs yield single-qubit codes achieving the quantum Singleton bound, finding instead that β₁(Qₙ) = n·2ⁿ⁻¹ - 2ⁿ + 1 grows exponentially. All core theorems are formally verified in Lean 4 with Mathlib.

**Keywords**: Quantum error correction, CSS codes, homological algebra, chain complexes, Betti numbers, topological codes

## 1. Introduction

The Calderbank-Shor-Steane (CSS) construction [1,2] is one of the foundational methods for building quantum error-correcting codes from pairs of classical linear codes. Given classical codes C₁ and C₂ over F₂ with C₂⊥ ⊆ C₁, the CSS code encodes k = dim(C₁) - dim(C₂⊥) logical qubits into n physical qubits.

The observation that this dimension formula is equivalent to a cohomological computation has been noted in the literature [3,4], but a complete formalization of the correspondence—including formal proofs of the key structural theorems—has not previously been carried out.

In this work, we:

1. Define CSS codes, F₂-chain complexes, and the HQECC construction as formal mathematical structures.
2. Prove that the chain condition ∂₁ ∘ ∂₂ = 0 implies the CSS containment condition B₁ ⊆ Z₁.
3. Establish the rank-nullity theorem for graph boundary maps over F₂.
4. Prove monotonicity of logical qubit count under code refinement.
5. Computationally test the hypercube HQECC conjecture and show it is false for n ≥ 3.
6. Verify all theorems in the Lean 4 proof assistant with the Mathlib library.

## 2. Definitions

### 2.1 Linear Codes over F₂

**Definition 2.1** (Linear Code). A *linear code* of length n over F₂ is a submodule C ⊆ F₂ⁿ. Its *dimension* is dim(C) = dim_F₂(C).

**Definition 2.2** (Hamming Weight). The *Hamming weight* of v ∈ F₂ⁿ is wt(v) = |{i : vᵢ ≠ 0}|.

### 2.2 CSS Codes

**Definition 2.3** (CSS Code). A *CSS code* of block length n consists of two linear codes codeX ≤ codeZ ⊆ F₂ⁿ. The number of *logical qubits* is k = dim(codeZ) - dim(codeX).

The logical qubit space is the quotient module codeZ/codeX, which has dimension k over F₂.

### 2.3 Chain Complexes

**Definition 2.4** (F₂-Chain Complex). A *3-term chain complex over F₂* consists of:
- Vector spaces C₂ = F₂^{d₂}, C₁ = F₂^{d₁}, C₀ = F₂^{d₀}
- Linear maps ∂₂ : C₂ → C₁ and ∂₁ : C₁ → C₀
- The *chain condition*: ∂₁ ∘ ∂₂ = 0

**Definition 2.5** (Cycles, Boundaries, Homology).
- Z₁ = ker(∂₁) ⊆ C₁ (the 1-cycles)
- B₁ = im(∂₂) ⊆ C₁ (the 1-boundaries)
- H₁ = Z₁/B₁ (the first homology group)

### 2.4 Graph Chain Data

**Definition 2.6** (Graph Chain Data). A *graph chain data* structure consists of:
- numVert, numEdge ∈ ℕ
- edgeSrc, edgeTgt : Fin(numEdge) → Fin(numVert)
- no_loops : ∀ e, edgeSrc(e) ≠ edgeTgt(e)

The *boundary map* ∂₁ : F₂^E → F₂^V sends the indicator vector of edge e to the sum of the indicators of its two endpoints.

### 2.5 HQECC

**Definition 2.7** (HQECC). A *Homological Quantum Error-Correcting Code* is a CSS code together with parameters [[n, k, d]] where n is the block length, k = logicalQubits(code), and d is the code distance.

## 3. Main Results

### 3.1 Boundaries are Cycles

**Theorem 3.1** (boundaries_le_cycles). *For any F₂-chain complex K with chain condition ∂₁ ∘ ∂₂ = 0, we have im(∂₂) ⊆ ker(∂₁).*

*Proof.* Let v ∈ im(∂₂), so v = ∂₂(w) for some w. Then ∂₁(v) = ∂₁(∂₂(w)) = (∂₁ ∘ ∂₂)(w) = 0 by the chain condition. Hence v ∈ ker(∂₁). □

This is the fundamental theorem that makes the CSS construction from a chain complex valid: it establishes the containment condition codeX = B₁ ≤ Z₁ = codeZ.

### 3.2 CSS Code from Chain Complex

**Corollary 3.2**. *Every 3-term chain complex K over F₂ yields a CSS code where:*
- *codeX = B₁ = im(∂₂)*
- *codeZ = Z₁ = ker(∂₁)*
- *logicalQubits = dim(Z₁) - dim(B₁) = dim(H₁)*

### 3.3 Dimension Bounds

**Theorem 3.3** (code_dim_le_ambient). *For any linear code C ⊆ F₂ⁿ, we have dim(C) ≤ n.*

*Proof.* dim(C) ≤ dim(F₂ⁿ) = n by the submodule dimension bound. □

**Theorem 3.4** (css_logicalQubits_le). *For any CSS code C of block length n, logicalQubits(C) ≤ n.*

*Proof.* logicalQubits = dim(codeZ) - dim(codeX) ≤ dim(codeZ) ≤ n. □

### 3.4 Hamming Weight Positivity

**Theorem 3.5** (hammingWeight_pos). *For any nonzero vector v ∈ F₂ⁿ, wt(v) > 0.*

*Proof.* If wt(v) = 0, then v_i = 0 for all i, so v = 0, contradicting v ≠ 0. □

### 3.5 Rank-Nullity for Graphs

**Theorem 3.6** (graph_cycle_rank_formula). *For any graph G with boundary map ∂₁ : F₂^E → F₂^V:*
$$\dim(\ker ∂₁) + \dim(\text{im}\, ∂₁) = |E|$$

*Proof.* This is the rank-nullity theorem (dim ker + dim im = dim domain) applied to the boundary map ∂₁, using the fact that dim(F₂^E) = |E|. □

**Corollary 3.7.** *For a connected graph G: dim(ker ∂₁) = |E| - |V| + 1 (the cycle rank).*

### 3.6 Monotonicity

**Theorem 3.8** (subcode_dim_le). *If C₁ ≤ C₂ as submodules of F₂ⁿ, then dim(C₁) ≤ dim(C₂).*

**Theorem 3.9** (css_logicalQubits_mono_codeX). *If C₁ and C₂ are CSS codes with the same codeZ and C₂.codeX ≤ C₁.codeX, then logicalQubits(C₁) ≤ logicalQubits(C₂).*

*Proof.* Since C₂.codeX ≤ C₁.codeX implies dim(C₂.codeX) ≤ dim(C₁.codeX), and both have the same codeZ, we get dim(codeZ) - dim(C₁.codeX) ≤ dim(codeZ) - dim(C₂.codeX). □

### 3.7 F₂ Orthogonality

**Theorem 3.10** (f2_orthogonal_comm). *F₂-orthogonality is symmetric: ⟨u, v⟩ = 0 iff ⟨v, u⟩ = 0.*

**Theorem 3.11** (f2_orthogonal_zero). *The zero vector is orthogonal to every vector.*

### 3.8 Trivial CSS Code

**Theorem 3.12** (css_trivial_zero_qubits). *A CSS code with codeX = codeZ encodes 0 logical qubits.*

## 4. Computational Results

### 4.1 Graph-Based HQECC Parameters

| Graph | |V| | |E| | β₁ | CSS Code |
|-------|-----|-----|------|----------|
| C₄ (square) | 4 | 4 | 1 | [[4, 1]] |
| C₅ (pentagon) | 5 | 5 | 1 | [[5, 1]] |
| K₄ (complete) | 4 | 6 | 3 | [[6, 3]] |
| K₅ (complete) | 5 | 10 | 6 | [[10, 6]] |
| Petersen | 10 | 15 | 6 | [[15, 6]] |
| Q₂ (square) | 4 | 4 | 1 | [[4, 1]] |
| Q₃ (cube) | 8 | 12 | 5 | [[12, 5]] |
| Q₄ (tesseract) | 16 | 32 | 17 | [[32, 17]] |

### 4.2 Simplicial Complex HQECC Parameters

| Complex | |V| | |E| | |T| | β₁ | CSS Code |
|---------|-----|-----|-----|------|----------|
| Torus T² | 9 | 27 | 18 | 2 | [[27, 2]] |

### 4.3 Hypercube Conjecture

**Conjecture** (Falsified). For even n ≥ 2, the HQECC from Q_n has k = 1 and d = 2^(n/2).

**Computational Test Results:**

| n | |V| | |E| | Actual k = β₁ | Predicted k | Match? |
|---|------|------|---------------|-------------|--------|
| 2 | 4 | 4 | 1 | 1 | ✓ |
| 3 | 8 | 12 | 5 | 1 | ✗ |
| 4 | 16 | 32 | 17 | 1 | ✗ |
| 5 | 32 | 80 | 49 | 1 | ✗ |
| 6 | 64 | 192 | 129 | 1 | ✗ |

The actual formula is β₁(Qₙ) = n·2ⁿ⁻¹ - 2ⁿ + 1, which grows exponentially. The conjecture fails for all n ≥ 3 because hypercubes have far more independent cycles than expected.

**Rate analysis.** The code rate k/|E| = (n·2ⁿ⁻¹ - 2ⁿ + 1)/(n·2ⁿ⁻¹) approaches 1 - 2/n as n → ∞, so hypercube HQECCs are asymptotically high-rate codes.

## 5. Algorithms

### 5.1 CSS Code Construction from Chain Complex

**Input:** Matrices ∂₂ (dim₁ × dim₂) and ∂₁ (dim₀ × dim₁) over F₂.

**Algorithm:**
1. Verify chain condition: ∂₁ · ∂₂ ≡ 0 (mod 2).
2. Compute Z₁ = ker(∂₁) via GF(2) row reduction.
3. Compute B₁ = im(∂₂) via GF(2) row reduction.
4. Return CSS code with codeX = B₁, codeZ = Z₁.
5. k = dim(Z₁) - dim(B₁).

**Complexity:** O(n³) for the GF(2) row reductions, where n = dim₁.

### 5.2 HQECC from Graph

**Input:** Graph G = (V, E) with adjacency data.

**Algorithm:**
1. Construct boundary matrix ∂₁ (|V| × |E|) over F₂.
2. Set codeZ = ker(∂₁), codeX = {0}.
3. k = |E| - rank(∂₁).
4. For connected G: k = |E| - |V| + 1.

## 6. Discussion

### 6.1 The CSS-Cohomology Dictionary

The central insight of this work is a precise dictionary:

| CSS Code Concept | Homological Concept |
|-------------------|---------------------|
| Block length n | dim(C₁) |
| X-stabilizer code | Boundaries B₁ = im(∂₂) |
| Z-stabilizer code | Cycles Z₁ = ker(∂₁) |
| Containment condition | Chain condition ∂₁∂₂ = 0 |
| Logical qubit space | Homology H₁ = Z₁/B₁ |
| # Logical qubits k | First Betti number β₁ |
| Code distance | Systole (shortest non-contractible cycle) |

### 6.2 Significance of the Formalization

All ten theorems in this work have been formally verified in Lean 4 with zero remaining sorries. The formalization covers:

1. The structural theorem that boundaries ⊆ cycles (Theorem 3.1)
2. Dimension bounds and rank-nullity (Theorems 3.3-3.6)
3. Monotonicity under code refinement (Theorems 3.8-3.9)
4. Properties of F₂ inner products (Theorems 3.10-3.11)

### 6.3 Limitations

Our formalization covers the algebraic structure but does not yet include:
- Formal proofs about code distance and systoles
- The relationship between dual codes and coboundaries
- Explicit HQECC constructions from specific simplicial complexes
- The quantum Gilbert-Varshamov bound

## 7. Future Work

1. **Distance bounds from topology.** The code distance of an HQECC equals the systole of the underlying complex. Formalizing this connection would link quantum coding theory to systolic geometry.

2. **Higher-dimensional codes.** Using H₂ instead of H₁ gives codes from 3-complexes. The parameters of such codes are largely unexplored.

3. **Hyperbolic codes.** Surfaces of constant negative curvature can have systole growing logarithmically with area, suggesting families of codes with growing distance.

4. **Cup product gates.** The cup product on cohomology may implement logical gates on the encoded qubits, connecting code structure to computation.

## 8. References

[1] A.R. Calderbank and P.W. Shor. "Good quantum error-correcting codes exist." *Physical Review A*, 54(2):1098, 1996.

[2] A.M. Steane. "Error correcting codes in quantum theory." *Physical Review Letters*, 77(5):793, 1996.

[3] M.H. Freedman, D.A. Meyer, and F. Luo. "Z₂-systolic freedom and quantum codes." *Mathematics of Quantum Computation*, 287-320, 2002.

[4] S.B. Bravyi and A.Yu. Kitaev. "Quantum codes on a lattice with boundary." *arXiv:quant-ph/9811052*, 1998.

[5] A. Kitaev. "Fault-tolerant quantum computation by anyons." *Annals of Physics*, 303(1):2-30, 2003.

[6] H. Bombin and M.A. Martin-Delgado. "Homological error correction: Classical and quantum codes." *Journal of Mathematical Physics*, 48(5):052105, 2007.
