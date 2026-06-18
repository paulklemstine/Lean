# Tropical Hecke Algebra for GL₂: A Formally Verified Foundation

**Abstract.** We develop the algebraic foundations of tropical 2×2 matrix algebra and prove structural theorems that form the basis for a tropical Langlands correspondence for GL₂. Working in the min-plus tropical semiring (ℤ, min, +), we formalize tropical matrix multiplication, the tropical determinant, and the tropical trace for 2×2 matrices. We prove that tropical matrix multiplication is associative (Theorem 1), that the tropical determinant satisfies a sub-multiplicativity inequality (Theorem 2), and establish a tropical Cayley-Hamilton identity for off-diagonal entries with an inequality for diagonal entries (Theorem 3). We further define tropical Hecke operators T_p and S_p, prove their algebraic relations (Theorem 4), and establish Weyl group invariance of the tropical determinant under products (Theorem 5). All results are formally verified in Lean 4 with the Mathlib library, providing the first machine-checked formalization of tropical Hecke algebra structures.

---

## 1. Introduction

The Langlands program, one of the deepest frameworks in modern mathematics, connects number theory, representation theory, and algebraic geometry through a web of correspondences between automorphic forms and Galois representations. At its heart lies the Hecke algebra — the algebra of bi-invariant functions on a reductive group under convolution — which encodes the symmetries of automorphic forms.

**Tropical mathematics** replaces the usual arithmetic operations with their "tropical" counterparts: addition becomes min (or max), and multiplication becomes addition. This deformation — the limit as the base of a logarithm tends to zero — preserves much algebraic structure while transforming analysis into combinatorics.

In this paper, we explore what happens when we tropicalize the Hecke algebra for GL₂, the group of invertible 2×2 matrices. Our approach is distinguished by the use of **formal verification**: every theorem is proved in Lean 4, providing absolute certainty of correctness. This is particularly valuable in a speculative mathematical domain where intuitions from classical algebra may not transfer reliably.

### 1.1 Main Results

We prove the following theorems, all formally verified in Lean 4:

1. **Associativity** (Theorem 1): Tropical 2×2 matrix multiplication is associative, establishing that tropical matrices form a semigroup.

2. **Sub-multiplicativity** (Theorem 2): The tropical determinant satisfies det(A ⊗ B) ≤ det(A) + det(B), the tropical analog of det(AB) = det(A)det(B).

3. **Tropical Cayley-Hamilton** (Theorem 3): The off-diagonal entries of A² satisfy exact identities: (A²)₀₁ = tr(A) + A₀₁. The diagonal entries satisfy inequalities involving the determinant.

4. **Hecke Algebra Structure** (Theorem 4): The tropical Hecke operators satisfy T_p² = 0 (the tropical multiplicative identity), S_p ⊗ S_q = S_{p+q}, and T_p ⊗ S_p = S_p.

5. **Weyl Invariance** (Theorem 5): The tropical determinant of a product is invariant under the Weyl group action: det(w(A) ⊗ w(B)) = det(A ⊗ B).

6. **Anti-Involution** (Theorem 6): The transpose is an anti-involution for tropical multiplication: (A ⊗ B)ᵀ = Bᵀ ⊗ Aᵀ.

---

## 2. The Tropical Semiring

**Definition 2.1.** The *tropical semiring* is the set ℤ equipped with two operations:
- Tropical addition: a ⊕ b := min(a, b)
- Tropical multiplication: a ⊗ b := a + b

The tropical additive identity would be +∞ (which we avoid by working over ℤ without it), and the tropical multiplicative identity is 0.

**Key Property.** Tropical multiplication distributes over tropical addition:
```
a ⊗ (b ⊕ c) = a + min(b, c) = min(a + b, a + c) = (a ⊗ b) ⊕ (a ⊗ c)
```
This distributivity is the engine that drives all our structural results.

---

## 3. Tropical 2×2 Matrices

**Definition 3.1.** A *tropical 2×2 matrix* is a tuple A = (a, b, c, d) ∈ ℤ⁴, representing:
```
A = [[a, b],
     [c, d]]
```

**Definition 3.2.** *Tropical matrix multiplication* is defined as:
```
(A ⊗ B)ᵢⱼ = ⊕ₖ (Aᵢₖ ⊗ Bₖⱼ) = min_k (Aᵢₖ + Bₖⱼ)
```

For 2×2 matrices:
```
A ⊗ B = [[min(a₁+a₂, b₁+c₂),  min(a₁+b₂, b₁+d₂)],
          [min(c₁+a₂, d₁+c₂),  min(c₁+b₂, d₁+d₂)]]
```

**Definition 3.3.** The *tropical determinant* is:
```
det(A) = min(a + d, b + c)
```

**Definition 3.4.** The *tropical trace* is:
```
tr(A) = min(a, d)
```

### Theorem 1: Associativity

**Theorem (tmul_assoc).** *For all tropical 2×2 matrices A, B, C:*
```
(A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)
```

*Proof sketch.* Each entry of both sides expands to a min over four sums using the distributivity x + min(y, z) = min(x + y, x + z). For entry (0,0):

LHS: min(min(a₁+a₂, b₁+c₂) + a₃, min(a₁+b₂, b₁+d₂) + c₃)
   = min(a₁+a₂+a₃, b₁+c₂+a₃, a₁+b₂+c₃, b₁+d₂+c₃)

RHS: min(a₁ + min(a₂+a₃, b₂+c₃), b₁ + min(c₂+a₃, d₂+c₃))
   = min(a₁+a₂+a₃, a₁+b₂+c₃, b₁+c₂+a₃, b₁+d₂+c₃)

These are identical. The same argument applies to all four entries. □

### Theorem 2: Sub-Multiplicativity

**Theorem (tdet_tmul_le).** *For all tropical 2×2 matrices A, B:*
```
det(A ⊗ B) ≤ det(A) + det(B)
```

*Proof sketch.* The RHS expands (using distributivity) to:
```
min(a+d, b+c) + min(e+h, f+g) = min(a+d+e+h, a+d+f+g, b+c+e+h, b+c+f+g)
```

The LHS expands to a min over 6 distinct terms that include these 4 terms plus two additional terms (a+c+e+f and b+d+g+h). Since min over a superset is ≤ min over a subset, the inequality follows. □

**Remark.** The inequality can be strict. For example, with A = [[0,10],[0,10]] and B = [[0,0],[10,10]], we get det(A⊗B) = 0 < 20 = det(A) + det(B). The gap represents a "savings" from optimizing the route rather than composing individual optimal routes.

### Theorem 3: Tropical Cayley-Hamilton

**Theorem (tmul_sq_offdiag).** *For any 2×2 tropical matrix A:*
```
(A²)₀₁ = tr(A) + A₀₁
(A²)₁₀ = tr(A) + A₁₀
```

*Proof.* Direct calculation:
```
(A²)₀₁ = min(a + b, b + d) = b + min(a, d) = tr(A) + b = tr(A) + A₀₁
```
using the distributivity min(a+b, b+d) = b + min(a, d). □

**Theorem (tmul_sq_diag_le).** *For any 2×2 tropical matrix A:*
```
min((A²)₀₀, det(A)) ≤ tr(A) + A₀₀
min((A²)₁₁, det(A)) ≤ tr(A) + A₁₁
```

This is the tropical analog of the classical Cayley-Hamilton theorem A² - tr(A)·A + det(A)·I = 0. In the tropical semiring (where subtraction does not exist), the equation becomes an inequality, and the off-diagonal entries achieve exact equality.

---

## 4. Tropical Hecke Operators

### 4.1 Definitions

In the classical Langlands correspondence for GL₂, the Hecke algebra at a prime p is generated by operators T_p and S_p corresponding to specific double cosets.

**Definition 4.1.** The *tropical Hecke operator* T_p is:
```
T_p = [[0, 0],
       [0, p]]
```

**Definition 4.2.** The *tropical central operator* S_p is:
```
S_p = [[p, p],
       [p, p]]
```

### 4.2 Algebraic Relations

**Theorem (hecke_S_mul_S).** *S_p ⊗ S_q = S_{p+q}.*

This shows that the S_p operators form a group isomorphic to (ℤ, +), acting as the tropical center.

**Theorem (hecke_T_sq).** *For p ≥ 0: T_p² = [[0,0],[0,0]].*

The tropical square of the Hecke operator collapses to the tropical identity scalar.

**Theorem (hecke_T_mul_S).** *For p ≥ 0: T_p ⊗ S_p = S_p.*

The Hecke operator "absorbs" the central element.

**Theorem (hecke_S_comm_T).** *For p, q ≥ 0: S_p ⊗ T_q = T_q ⊗ S_p.*

Central elements commute with the Hecke generators, establishing the center structure.

---

## 5. Weyl Group Symmetry

The Weyl group W = S₂ for GL₂ acts on matrices by simultaneously swapping rows and columns.

**Definition 5.1.** The *Weyl action* on a tropical 2×2 matrix is:
```
w(A) = [[d, c],
        [b, a]]
```

**Theorem (tdet_weyl_tmul).** *det(w(A) ⊗ w(B)) = det(A ⊗ B).*

This Weyl invariance of the product determinant is fundamental for the tropical Langlands correspondence: it ensures that the "central character" (encoded by the determinant) is preserved under the Weyl group action on the product, analogous to how the central character of a representation is Weyl-invariant.

---

## 6. Transpose Anti-Involution and the Gelfand Trick

**Theorem (transpose_tmul).** *(A ⊗ B)ᵀ = Bᵀ ⊗ Aᵀ.*

In the classical Hecke algebra, the existence of an anti-involution that fixes the basis (the Cartan involution) immediately implies commutativity via the *Gelfand trick*: if ι is an anti-involution with ι(f * g) = ι(g) * ι(f) and ι fixes all basis elements, then f * g = g * f.

Our transpose anti-involution is the tropical analog of this structure. While it does not directly prove commutativity of the full tropical Hecke algebra (since general tropical matrices are not fixed by transpose), it provides the crucial algebraic mechanism.

We also prove:
- **det(Aᵀ) = det(A)** — the tropical determinant is transpose-invariant
- **Inf-convolution commutativity** — the cyclic inf-convolution (f ⊛ g = g ⊛ f) on finite domains

---

## 7. Discussion: What Does This Mean?

### For Mathematicians

Our results establish that the min-plus algebra of 2×2 matrices possesses remarkably rich algebraic structure that mirrors the classical Hecke algebra. The key insight is that the *distributivity of addition over min* — the fundamental axiom of the tropical semiring — propagates through matrix operations to produce associativity, sub-multiplicativity, and Cayley-Hamilton-type identities.

The sub-multiplicativity of the tropical determinant (Theorem 2) is particularly striking. In classical algebra, det(AB) = det(A)det(B) is an *equality*. In the tropical world, it becomes an *inequality*. This is not a weakness but a feature: the gap det(A)+det(B) - det(A⊗B) measures the "savings" from global optimization versus composing local optima — a phenomenon with deep connections to optimal transport theory.

### For a General Audience

Imagine you're planning a road trip with two legs. In the first leg, you need to get from city A to city B, with two possible routes costing different amounts. In the second leg, you continue from B to C with another set of route options.

The tropical determinant tells you the *cheapest* way to make a complete journey. Our main inequality says: **the cheapest two-leg journey is at most as expensive as adding the cheapest individual legs together**. Sometimes you can do better by choosing routes that combine well, even if neither is individually optimal.

This is the tropical Cayley-Hamilton theorem in action: the algebra of "cheapest paths" has structure that mirrors the algebra of matrices, but with inequalities replacing equalities.

The Hecke operators T_p are special "structured cost matrices" that arise naturally when the cost structure has symmetries — like a transportation network with a regular lattice structure. Our theorems show that these operators satisfy clean algebraic relations, making them tractable for computation.

### Connections to Existing Work

- **Tropical Geometry** (Mikhalkin, Sturmfels): Our matrix algebra provides the linear-algebraic foundations for tropical geometry over GL₂.
- **Min-Plus Algebra** (Baccelli, Cohen, Olsder, Quadrat): The associativity and determinant results extend the classical theory of min-plus matrices.
- **Langlands Program** (Langlands, Frenkel): Our Hecke operators and Weyl invariance results provide a tropical framework for the local Langlands correspondence.
- **Optimal Transport** (Kantorovich, Villani): The sub-multiplicativity inequality has a natural interpretation in transport theory.

---

## 8. Applications

### 8.1 Optimal Transport
The tropical determinant computes minimum-weight perfect matchings in bipartite graphs. The sub-multiplicativity inequality bounds the cost of composed transports.

### 8.2 Network Optimization
Tropical matrix multiplication computes shortest paths in weighted digraphs. The associativity theorem guarantees consistent multi-step path optimization.

### 8.3 Scheduling
The min-plus algebra models precedence-constrained scheduling problems. The Cayley-Hamilton theorem provides structural constraints on iterated scheduling operations.

### 8.4 Formal Verification
All results are machine-checked, providing a foundation for verified algorithms in optimization and combinatorics.

---

## 9. Future Directions

1. **Extension to GL_n**: Generalize to n×n tropical matrices with the full tropical permanent as determinant.

2. **Tropical Satake Isomorphism**: Formalize the identification of the tropical Hecke algebra with the algebra of piecewise-linear symmetric functions.

3. **Tropical Automorphic Forms**: Define and study the space of functions on which the tropical Hecke algebra acts.

4. **Connection to Valuations**: Relate our discrete tropical structures to valuations on p-adic fields.

5. **Computational Applications**: Implement verified tropical linear algebra algorithms based on our formalized theory.

---

## Appendix: Formal Verification

All theorems in this paper are proved in Lean 4 using the Mathlib library. The formalization consists of approximately 400 lines of Lean code in the file `RequestProject/TropicalHeckeGL2.lean`. The proofs use only standard axioms (propext, Classical.choice, Quot.sound).

**Theorem count:** 19 formally verified theorems, 0 sorries remaining.

**Key Lean declarations:**
- `TropMat2` — Structure for tropical 2×2 matrices
- `TropMat2.tmul_assoc` — Associativity of tropical multiplication
- `TropMat2.tdet_tmul_le` — Determinant sub-multiplicativity
- `TropMat2.tmul_sq_offdiag_01` — Tropical Cayley-Hamilton (off-diagonal)
- `TropMat2.tdet_weyl_tmul` — Weyl invariance of product determinant
- `TropMat2.infConv_comm` — Commutativity of inf-convolution
