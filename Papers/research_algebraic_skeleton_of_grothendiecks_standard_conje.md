# The Algebraic Skeleton of Grothendieck's Standard Conjectures: Formal Proofs of Linear-Algebraic Consequences

## Abstract

We formalize and prove the linear-algebraic consequences of Grothendieck's standard conjectures on algebraic cycles. Our main contributions are: (1) a complete proof of rank additivity for orthogonal idempotent systems (modeling Künneth projectors), showing that the total Betti number equals the sum of graded Betti numbers; (2) the kernel filtration theorem for nilpotent Lefschetz operators, establishing the algebraic preconditions for primitive decomposition; (3) the Hodge index theorem for signed bilinear forms, proving that intersection forms with complementary positive/negative subspaces satisfy a dimension formula and disjointness property; (4) the weight purity theorem, characterizing pure motives via trivial weight filtrations; and (5) projector algebra for correspondence algebras, proving that complements and transposes of projectors remain projectors. All results are proved unconditionally — without geometric input — demonstrating that the algebraic skeleton of the standard conjectures is formally verifiable.

**Keywords**: Standard conjectures, algebraic cycles, Künneth projectors, Lefschetz operator, Hodge index theorem, weight filtration, pure motives, correspondence algebra

## 1. Introduction

Grothendieck's standard conjectures on algebraic cycles [Gro69] are among the most important open problems in algebraic geometry. They predict deep structural properties of the cohomology of smooth projective varieties over arbitrary fields, and their resolution would imply both the Hodge conjecture (in characteristic zero) and the Weil conjectures (now proved by Deligne via different methods).

The conjectures come in several forms:
- **Conjecture B (Lefschetz standard conjecture)**: The Lefschetz operator L on cohomology is algebraic — i.e., the inverse of the Hard Lefschetz isomorphism L^k: H^{n-k} → H^{n+k} is induced by an algebraic cycle.
- **Conjecture C (Künneth standard conjecture)**: The Künneth projectors π_i: H*(X) → H^i(X) are algebraic.
- **Conjecture D (Hodge standard conjecture)**: Numerical equivalence equals homological equivalence for algebraic cycles.

Kleiman [Kle94] established the implications B ⟹ C ⟹ D, showing that the Lefschetz conjecture is the strongest. André [And04] developed the theory of motives conditional on these conjectures.

Our contribution is to identify and prove the *unconditional* linear-algebraic content of these conjectures. We show that the key structural theorems — rank additivity, filtration properties, Hodge index, weight purity, and projector algebra — follow from finite-dimensional linear algebra alone, without any geometric hypotheses.

### 1.1 Overview of Results

| Theorem | Mathematical Content | Key Technique |
|---------|---------------------|---------------|
| Rank Additivity | dim(V) = Σ dim(range πᵢ) | Induction on idempotent system |
| Graded Piece Disjointness | range(πᵢ) ∩ range(πⱼ) = {0} for i ≠ j | Orthogonality + idempotency |
| Kernel Monotonicity | ker(L^k) ⊆ ker(L^{k+1}) | Functoriality |
| Kernel Stabilization | ker(L^{w+1}) = V | Nilpotency |
| Nullity-Rank Duality | dim(ker L^k) + dim(im L^k) = dim V | Rank-nullity theorem |
| Hodge Index Dimension | p + q = dim V | Complementary subspaces |
| Hodge Index Negativity | v ∈ negSpace ⟹ Q(v,v) ≤ 0 | Negative definiteness |
| Positive-Negative Disjointness | v ∈ posSpace ∩ negSpace ⟹ v = 0 | Contradiction |
| Weight Purity | Pure ⟹ trivial filtration | Monotonicity |
| Projector Complement | p² = p ⟹ (1-p)² = 1-p | Bilinearity of composition |
| Transpose Projector | p² = p ⟹ (pᵗ)² = pᵗ | Transpose reverses composition |
| Self-Adjoint Composition | (pᵗ∘p)ᵗ = pᵗ∘p | Transpose involution |

## 2. Definitions

### 2.1 Orthogonal Idempotent Systems

**Definition 2.1** (Orthogonal Idempotent System). Let V be a finite-dimensional vector space over a field F. An *orthogonal idempotent system* of rank n on V is a family of linear endomorphisms π₁, ..., πₙ: V → V satisfying:
1. (Idempotency) πᵢ ∘ πᵢ = πᵢ for all i
2. (Orthogonality) πᵢ ∘ πⱼ = 0 for all i ≠ j
3. (Completeness) Σᵢ πᵢ = id_V

The *graded piece* associated to πᵢ is Vᵢ := range(πᵢ).

**Remark.** In the geometric setting, V = H*(X, F) for a smooth projective variety X, and the πᵢ are the Künneth projectors splitting total cohomology into its degree-i component.

### 2.2 Lefschetz Operators

**Definition 2.2** (Lefschetz Operator). A *Lefschetz operator of weight w* on a finite-dimensional vector space V over F is a linear endomorphism L: V → V satisfying L^{w+1} = 0 (nilpotency).

The *primitive kernel at level k* is P_k := ker(L^{k+1}).

**Remark.** Geometrically, L is the action of cup product with the hyperplane class η ∈ H²(X), and w = dim(X).

### 2.3 Signed Bilinear Forms

**Definition 2.3** (Signed Bilinear Form). A *signed bilinear form* on a finite-dimensional real vector space V consists of:
1. A nondegenerate symmetric bilinear form Q: V × V → ℝ
2. Subspaces V⁺, V⁻ ⊆ V with V = V⁺ ⊕ V⁻
3. Q|_{V⁺} is positive definite
4. Q|_{V⁻} is negative definite

The *signature* of the form is (dim V⁺, dim V⁻).

### 2.4 Weight Filtrations

**Definition 2.4** (Weight Filtration). A *weight filtration* on a finite-dimensional vector space V over F is a monotone function W: ℤ → Sub(V) with W(0) = 0 and W(N) = V for some N.

A weight filtration is *pure of weight w* if W(w-1) = 0 and W(w) = V.

### 2.5 Correspondence Algebras

**Definition 2.5** (Correspondence Algebra). A *correspondence algebra* over a field F consists of an F-vector space Corr equipped with:
1. Bilinear composition ∘: Corr × Corr → Corr (associative, with identity)
2. Transpose t: Corr → Corr (involution reversing composition)

A *projector* is an element p with p∘p = p. A *self-adjoint projector* additionally satisfies pᵗ = p.

## 3. Main Results

### 3.1 Rank Additivity Theorem

**Theorem 3.1** (Rank Additivity). Let {π₁, ..., πₙ} be an orthogonal idempotent system on V. Then
$$\dim V = \sum_{i=1}^{n} \dim(\operatorname{range}(\pi_i))$$

*Proof sketch.* The completeness condition Σ πᵢ = id implies that every v ∈ V can be written as v = Σ πᵢ(v), so V = Σ range(πᵢ). The orthogonality condition πᵢ ∘ πⱼ = 0 for i ≠ j, combined with idempotency, implies that these ranges are pairwise disjoint: if v ∈ range(πᵢ) ∩ range(πⱼ), then v = πᵢ(a) = πⱼ(b), so πᵢ(v) = πᵢ(πⱼ(b)) = 0 and πᵢ(v) = πᵢ(πᵢ(a)) = πᵢ(a) = v, giving v = 0.

The formal proof uses induction on finite sets, proving that dim(⊔_{i∈S} range(πᵢ)) = Σ_{i∈S} dim(range(πᵢ)) for all finite subsets S, using the disjointness result at each inductive step.

**Corollary 3.2** (Idempotent Range Characterization). range(πᵢ) = ker(πᵢ - id), i.e., the range of an idempotent is its fixed-point set.

### 3.2 Lefschetz Kernel Filtration

**Theorem 3.3** (Kernel Filtration). For a Lefschetz operator L of weight w:
1. ker(L^k) ⊆ ker(L^{k+1}) for all k ≥ 0
2. ker(L^{w+1}) = V
3. dim(ker(L^k)) + dim(range(L^k)) = dim(V) for all k

*Proof sketch.* (1) If L^k(v) = 0, then L^{k+1}(v) = L(L^k(v)) = 0. (2) L^{w+1} = 0 by nilpotency, so ker(L^{w+1}) = V. (3) The rank-nullity theorem applied to L^k.

**Remark.** The successive quotients ker(L^{k+1})/ker(L^k) are the algebraic analogues of the primitive subspaces in Lefschetz theory.

### 3.3 Hodge Index Theorem

**Theorem 3.4** (Hodge Index). For a signed bilinear form (V, Q, V⁺, V⁻):
1. dim(V⁺) + dim(V⁻) = dim(V) (dimension formula)
2. For all v ∈ V⁻: Q(v,v) ≤ 0 (negativity)
3. V⁺ ∩ V⁻ = {0} (disjointness)

*Proof sketch.* (1) V = V⁺ ⊕ V⁻ (complementarity), so dimensions add. (2) If v ≠ 0 and v ∈ V⁻, then Q(v,v) < 0 by negative definiteness; if v = 0, Q(v,v) = 0 ≤ 0. (3) If v ∈ V⁺ ∩ V⁻ and v ≠ 0, then Q(v,v) > 0 (positive definiteness on V⁺) and Q(v,v) < 0 (negative definiteness on V⁻), contradiction.

**Remark.** In the geometric setting, V = H^{1,1}(X) for a projective surface X, Q is the intersection form, V⁺ is spanned by the hyperplane class, and V⁻ is the orthogonal complement. The Hodge index theorem classically states that the intersection form has signature (1, ρ-1).

### 3.4 Weight Purity Theorem

**Theorem 3.5** (Weight Purity). If a weight filtration W on V is pure of weight w (i.e., W(w-1) = 0 and W(w) = V), then for all k ∈ ℤ, either W(k) = 0 or W(k) = V.

*Proof sketch.* For k ≤ w-1: by monotonicity W(k) ≤ W(w-1) = 0. For k ≥ w: by monotonicity V = W(w) ≤ W(k).

**Remark.** This characterizes pure motives algebraically: a motive is pure iff its weight filtration is concentrated in a single degree.

### 3.5 Projector Algebra

**Theorem 3.6** (Projector Algebra). In a correspondence algebra:
1. If p is a projector, then 1-p is a projector.
2. If p is a projector, then pᵗ is a projector.
3. For any element p, the composition pᵗ∘p is self-adjoint: (pᵗ∘p)ᵗ = pᵗ∘p.

*Proof sketch.* (1) (1-p)²= 1 - 2p + p² = 1 - 2p + p = 1-p. (2) (pᵗ)² = (p²)ᵗ = pᵗ. (3) (pᵗ∘p)ᵗ = pᵗ∘(pᵗ)ᵗ = pᵗ∘p.

## 4. The Primitive Rank Bound Conjecture

We propose the following testable conjecture:

**Conjecture 4.1** (Primitive Rank Bound). For any Lefschetz operator L of weight w on a vector space V of dimension d:
$$\dim(\ker L) \cdot (w + 1) \geq d$$

**Motivation.** If the Hard Lefschetz theorem holds, V admits a primitive decomposition V = ⊕_{j≥0} L^j · P_{w-2j}, where each primitive piece P_i ⊆ ker(L^{w-i+1}). Since the pieces are disjoint and L is injective on them (up to appropriate bounds), the primitive subspace ker(L) ∩ P_w must be large enough to generate V through the action of L.

**Computational Test.** Generate random nilpotent matrices of various sizes and compute dim(ker L) and the nilpotency index. The conjecture predicts dim(ker L) ≥ ⌈d/(w+1)⌉.

## 5. Algorithms

### 5.1 Künneth Projector Computation

Given a system of n idempotent matrices π₁, ..., πₙ satisfying the orthogonality and completeness conditions, compute the graded Betti numbers:

```
Input: Matrices π₁, ..., πₙ
Output: Betti numbers b₁, ..., bₙ

for i = 1 to n:
    bᵢ = rank(πᵢ)
verify: Σ bᵢ = dim(V)
```

### 5.2 Lefschetz Filtration Computation

Given a nilpotent matrix L:

```
Input: Matrix L, nilpotency weight w
Output: Filtration dimensions d₀, d₁, ..., d_{w+1}

for k = 0 to w+1:
    dₖ = dim(ker(L^k))
verify: d₀ ≤ d₁ ≤ ... ≤ d_{w+1} = dim(V)
```

### 5.3 Hodge Signature Computation

Given a symmetric matrix Q:

```
Input: Symmetric matrix Q
Output: Signature (p, q)

Compute eigenvalues λ₁, ..., λₙ of Q
p = #{i : λᵢ > 0}
q = #{i : λᵢ < 0}
verify: p + q = n (if Q is nondegenerate)
```

## 6. Discussion

### 6.1 What the Algebra Proves

Our results demonstrate that the *structural consequences* of the standard conjectures — rank additivity, kernel filtrations, Hodge index, weight purity, projector algebra — are theorems of finite-dimensional linear algebra. They hold for any abstract objects satisfying the axioms, without reference to algebraic geometry.

### 6.2 What Remains Open

The hard part of the standard conjectures is *geometric*: showing that the cohomology of smooth projective varieties actually carries these structures. Specifically:
- Conjecture B requires showing that the Hard Lefschetz isomorphism L^k is algebraic (induced by a correspondence).
- Conjecture C requires showing that the Künneth projectors are algebraic.
- Conjecture D requires showing that numerical and homological equivalence coincide.

Our work clarifies the boundary: the algebra is settled; the geometry awaits.

### 6.3 Connections to Other Areas

The framework connects to several active research areas:
- **Tropical Hodge theory**: The signed bilinear form structure appears in tropical intersection theory, suggesting a combinatorial approach to the Hodge index theorem.
- **Motivic Galois groups**: The correspondence algebra is the morphism algebra of the Tannakian category of pure motives, connecting to the Langlands program.
- **Mixed Hodge structures**: The weight filtration formalism extends to mixed motives, relevant for the cohomology of open and singular varieties.

## 7. Future Work

1. **Hard Lefschetz decomposition**: Formalize the full primitive decomposition for abstract Lefschetz modules satisfying the Hard Lefschetz condition.
2. **Motivic Galois group**: Formalize the Tannakian structure of the category of pure motives using the correspondence algebra framework.
3. **Tropical bridge**: Connect the signed bilinear form theory to tropical intersection forms.
4. **Computational verification**: Systematically test the Primitive Rank Bound Conjecture for random nilpotent matrices.

## References

- [And04] Y. André, *Une introduction aux motifs*, Panoramas et Synthèses 17, SMF, 2004.
- [Gro69] A. Grothendieck, "Standard conjectures on algebraic cycles," in *Algebraic Geometry, Bombay 1968*, Oxford Univ. Press, 1969, pp. 193–199.
- [Kle68] S. L. Kleiman, "Algebraic cycles and the Weil conjectures," in *Dix exposés sur la cohomologie des schémas*, North-Holland, 1968.
- [Kle94] S. L. Kleiman, "The standard conjectures," in *Motives*, Proc. Symp. Pure Math. 55, AMS, 1994, pp. 3–20.
- [Del74] P. Deligne, "La conjecture de Weil. I," Publ. Math. IHÉS 43 (1974), 273–307.
