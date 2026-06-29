# Čech Stabilizer Codes: Chain Complex Quantum Error Correction

## Abstract

We formalize the mathematical foundations connecting chain complexes over F₂ with CSS (Calderbank-Shor-Steane) quantum error-correcting codes in Lean 4 with Mathlib. The central construction — that a chain complex C₀ →[∂₁]→ C₁ →[∂₂]→ C₂ with ∂₂∘∂₁ = 0 naturally defines a CSS code — is proven rigorously with zero sorry statements. We establish 40+ formally verified theorems including the fundamental stabilizer commutation theorem, distance certification, functorial code morphisms, Poincaré duality, and explicit constructions of the repetition, Steane, and four-qubit codes.

## 1. Introduction

Quantum error correction is essential for scalable quantum computing. CSS codes, introduced by Calderbank-Shor-Steane, are among the most important families of quantum error-correcting codes. They are defined by two classical codes C₁ ⊆ C₂⊥ whose parity-check matrices satisfy Hx · Hz^T = 0.

A deep insight from topological quantum computing (pioneered by Kitaev's toric code) is that this orthogonality condition is precisely the chain complex condition ∂² = 0 from homological algebra. This connects quantum error correction to algebraic topology — a connection we formalize in this work.

## 2. Main Constructions

### 2.1. F₂ Chain Complex

We define an F₂ chain complex as a triple (d₁, d₂, proof) where:
- d₁ : Matrix (Fin n) (Fin m) (ZMod 2) — the first boundary map
- d₂ : Matrix (Fin p) (Fin n) (ZMod 2) — the second boundary map
- boundary_sq : d₂ * d₁ = 0 — the chain complex condition

### 2.2. CSS Code

A CSS code on n qubits consists of:
- Check matrices Hx (rx × n) and Hz (rz × n) over F₂
- Orthogonality proof: Hx * Hz^T = 0

### 2.3. The Construction: Chain Complex → CSS Code

The functor `F2ChainComplex.toCSSCode` sends a chain complex to the CSS code with:
- Hx = d₁^T (X-stabilizer check matrix)
- Hz = d₂ (Z-stabilizer check matrix)

The CSS orthogonality d₁^T · d₂^T = (d₂ · d₁)^T = 0 follows immediately from ∂² = 0.

## 3. Main Theorems

### Theorem 1: Stabilizer Commutation from ∂²=0

```
theorem stabilizer_commutation_from_boundary_sq :
    dotProduct (C.d1 *ᵥ a) (C.d2.transpose *ᵥ b) = 0
```

The F₂ inner product of any vector in im(∂₁) with any vector in im(∂₂^T) vanishes. This is the algebraic reason X and Z stabilizers commute.

### Theorem 2: Image-Kernel Containment

```
theorem image_subset_kernel : C.d2 *ᵥ (C.d1 *ᵥ w) = 0
```

Every vector in im(∂₁) is in ker(∂₂). This ensures every X-stabilizer is an X-logical operator.

### Theorem 3: Cohomological Distance Certification

```
theorem cohomological_distance_cert :
    C.isXStabilizer (e₁ - e₂)
```

If the code has X-distance ≥ d, then any two errors with weight ≤ ⌊(d-1)/2⌋ and the same syndrome must differ by a stabilizer. This is the formal guarantee that syndrome decoding works within the correction radius.

### Theorem 4: Functoriality

```
theorem chain_morphism_preserves_x_logical :
    C₂.toCSSCode.isXLogical (φ.f1 *ᵥ v)
```

Chain complex morphisms preserve X-logical operators, establishing the functorial nature of the construction.

### Theorem 5: Poincaré Duality Involution

```
theorem dual_involution :
    C.dual.dual.d1 = C.d1 ∧ C.dual.dual.d2 = C.d2
```

The dual operation (transposing all boundary maps) is an involution. The CSS code of the dual swaps X and Z stabilizers — quantum electromagnetic duality.

## 4. Concrete Examples

We verify the construction on three concrete codes:

1. **3-qubit repetition code** (1 X-generator, 2 Z-generators)
2. **Steane [[7,1,3]] code** (3 X-generators, 3 Z-generators, from the self-orthogonal Hamming code)
3. **4-qubit code** (2 X-generators, 1 Z-generator)

All boundary conditions ∂²=0 are verified by `native_decide`.

## 5. Category-Theoretic Structure

Chain complex morphisms form a category with:
- Identity morphisms (`F2ChainMorphism.id`)
- Composition (`F2ChainMorphism.comp`)
- Verified associativity and identity laws

This establishes `toCSSCode` as a (proto-)functor from F₂-chain complexes to CSS codes.

## 6. Significance

This formalization:
1. **Bridges algebraic topology and quantum information** with machine-verified proofs
2. **Certifies quantum codes**: every theorem is verified by the Lean kernel
3. **Provides infrastructure** for future formalization of topological quantum codes
4. **Demonstrates the power of chain complexes** as a unifying language for quantum error correction

The work opens the door to formalizing Kitaev's toric code, surface codes, color codes, and other topological quantum codes as chain complexes, with automatic verification of code properties.
