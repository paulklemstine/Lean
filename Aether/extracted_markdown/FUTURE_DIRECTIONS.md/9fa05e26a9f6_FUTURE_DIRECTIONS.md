# Future Directions: Jacobian Conjecture Formal Development

## Overview

This document outlines 5 concrete next steps for extending the formal infrastructure for the Jacobian Conjecture. Each direction includes an exact theorem statement, a Lean type signature sketch, two proof strategies, breakthrough potential, and cross-domain connections.

---

## Direction 1: Complete General Quadratic Jacobian Conjecture (All Dimensions)

### Theorem Statement

For any field $K$ of characteristic zero, any dimension $n$, and any polynomial map $F = I + H : K^n \to K^n$ with $H$ homogeneous of degree 2 and $\det(JF) = 1$, the map $F$ is a polynomial automorphism with inverse $G = I - H$.

### Lean Type Signature

```lean
theorem quadratic_jacobian_conjecture
    (K : Type*) [Field K] [CharZero K]
    (n : ℕ)
    (H : Fin n → MvPolynomial (Fin n) K)
    (h_hom : ∀ i, (H i).IsHomogeneous 2)
    (hjac : jacobianDet (fun i => X i + H i) = 1) :
    isPolynomialInverse (fun i => X i + H i) (fun i => X i - H i) := by
  sorry
```

### Proof Strategy A: Evaluation + Nilpotence

1. Prove that the Jacobian condition implies JH(v) is nilpotent for every evaluation point v (using `isNilpotent_of_det_one_add_smul`).
2. Show that for quadratic H with nilpotent JH(v), the identity H(v - H(v)) = H(v) holds pointwise via the Euler homogeneity relation and JH·H = 0.
3. Use `MvPolynomial.funext` to lift pointwise equality to polynomial equality.

### Proof Strategy B: Parametric Coefficient Decomposition

1. Decompose H into explicit monomial form using the basis of degree-2 monomials.
2. Extract linear constraints (trace = 0) and quadratic constraints (det JH = 0) on coefficients.
3. Show that all solutions have rank-1 structure H_i = r_i · ℓ(x)² for some linear form ℓ.
4. Verify the inverse formula G = I - H for rank-1 maps directly.

### Breakthrough Potential

A complete formal proof of the quadratic case in all dimensions would be the first machine-verified case of the Jacobian Conjecture beyond trivial instances. It would validate the nilpotence-based proof strategy and establish the template for attacking the cubic case.

### Cross-Domain Connection

**Algebraic complexity theory**: The inverse $G = I - H$ has the same degree as $F$, implying the algebraic circuit complexity of the inverse is bounded by that of the forward map. This connects to questions about circuit rigidity and polynomial identity testing.

---

## Direction 2: Formal Bass–Connell–Wright Degree Reduction

### Theorem Statement

The Jacobian Conjecture for polynomial maps of arbitrary degree reduces to the cubic homogeneous case. Specifically, for every polynomial map $F : K^n \to K^n$ with $\det(JF) \in K^*$, there exist $N \geq n$ and a cubic homogeneous map $\tilde{H} : K^N \to K^N$ such that: (1) $\det(J(I + \tilde{H})) = 1$, and (2) $I + \tilde{H}$ is an automorphism implies $F$ is an automorphism.

### Lean Type Signature

```lean
theorem BCW_reduction
    (K : Type*) [Field K] [CharZero K]
    (n : ℕ) (F : Fin n → MvPolynomial (Fin n) K)
    (hjac : jacobianCondition F) :
    ∃ (N : ℕ) (H : Fin N → MvPolynomial (Fin N) K),
      (∀ i, (H i).IsHomogeneous 3) ∧
      jacobianDet (fun i => X i + H i) = 1 ∧
      (isPolynomialAutomorphism (fun i => X i + H i) →
       isPolynomialAutomorphism F) := by
  sorry
```

### Proof Strategy A: Direct Construction via Homogenization

1. Normalize $F$ to identity linear part using the invertibility of the constant Jacobian matrix.
2. Write $F = I + H_2 + H_3 + \cdots + H_d$ with $H_k$ homogeneous of degree $k$.
3. Introduce auxiliary variables $y_{ij}$ and construct the "cubification" map that replaces each degree-$k$ term with a product of linear and quadratic terms using new variables.
4. Show the extended map is cubic homogeneous and preserves the Jacobian condition.
5. Show that invertibility of the extension implies invertibility of the original.

### Proof Strategy B: Stable Equivalence Framework

1. Formalize the notion of stable equivalence: two maps are stably equivalent if they become conjugate after adding identity coordinates.
2. Prove that stable equivalence preserves polynomial automorphism.
3. Show that every polynomial map is stably equivalent to a cubic homogeneous one via explicit constructions.

### Breakthrough Potential

A formal BCW reduction would be a landmark in verified mathematics — it would reduce the entire Jacobian Conjecture to a single special case, and the formal proof could serve as a template for analogous reductions in other conjectures.

### Cross-Domain Connection

**Tensor decomposition**: The cubification step in BCW reduction is closely related to tensor decomposition of symmetric tensors. Connections to tensor rank and Waring rank problems in algebraic complexity could yield new insights.

---

## Direction 3: Inverse Degree Bounds from Nilpotence Index

### Theorem Statement

For $F = I + H$ with $H$ homogeneous of degree $d$ and $JH$ nilpotent of index $k$, the polynomial inverse $G$ has total degree at most $d^{k-1}$.

### Lean Type Signature

```lean
theorem inverse_degree_bound
    (K : Type*) [Field K] [CharZero K]
    (n d k : ℕ) (H : Fin n → MvPolynomial (Fin n) K)
    (h_hom : ∀ i, (H i).IsHomogeneous d)
    (h_nil : ∀ (v : Fin n → K),
      (jacobianMatrix (fun i => X i + H i) |>.map (MvPolynomial.eval v) - 1) ^ k = 0)
    (G : Fin n → MvPolynomial (Fin n) K)
    (h_inv : isPolynomialInverse (fun i => X i + H i) G) :
    ∀ i, (G i).totalDegree ≤ d ^ (k - 1) := by
  sorry
```

### Proof Strategy A: Iterative Degree Tracking

1. Define the iterative inverse construction: $G_0 = I$, $G_{m+1} = I - H \circ G_m$.
2. Track the degree of $G_m$ at each step: $\deg(G_m) \leq d \cdot \deg(G_{m-1})$.
3. Show convergence after $k-1$ steps using the nilpotence of JH.
4. The final degree is $\deg(G_{k-1}) \leq d^{k-1}$.

### Proof Strategy B: Formal Power Series + Truncation

1. Define the formal inverse as a power series using the geometric series $(I + N)^{-1} = I - N + N^2 - \cdots$
2. Show that nilpotence of index $k$ implies the series truncates after $k$ terms.
3. Bound the degree of each term using homogeneity: the $m$-th term has degree $m \cdot (d-1) + 1$.
4. The maximum degree is $(k-1)(d-1) + 1 \leq d^{k-1}$.

### Breakthrough Potential

Explicit degree bounds are essential for algorithmic applications. They tell us exactly how large the inverse polynomial can be, enabling efficient computation and storage estimation. For the quadratic case ($d=2, k=2$), the bound gives degree $\leq 2$, which is sharp.

### Cross-Domain Connection

**Arithmetic circuit complexity**: The degree bound implies a bound on the algebraic circuit complexity of the inverse map. If $F$ can be computed by a circuit of size $s$, the inverse has circuit size at most $s^{O(d^k)}$. This connects to the VP vs VNP question in algebraic complexity.

---

## Direction 4: Weyl Algebra Infrastructure and Dixmier Bridge

### Theorem Statement

Define the Weyl algebra $A_n(K)$ with generators $x_1, \ldots, x_n, \partial_1, \ldots, \partial_n$ satisfying $[\partial_i, x_j] = \delta_{ij}$, and prove that the Jacobian Conjecture implies: every algebra endomorphism of $A_n(K)$ is an automorphism.

### Lean Type Signature

```lean
-- Weyl algebra definition
def WeylAlgebra (K : Type*) [Field K] (n : ℕ) :=
  FreeAlgebra K (Fin n ⊕ Fin n) ⧸ weylRelations K n

-- Dixmier Conjecture
theorem jacobian_implies_dixmier_full
    (K : Type*) [Field K] [CharZero K]
    (hJC : ∀ n, jacobianConjectureHolds K n) :
    ∀ (n : ℕ) (φ : WeylAlgebra K n →ₐ[K] WeylAlgebra K n),
      Function.Surjective φ := by
  sorry
```

### Proof Strategy A: Reduction to Characteristic p

1. Define the Weyl algebra using free algebras modulo canonical commutation relations.
2. Formalize the Frobenius endomorphism in characteristic $p$.
3. Show that in characteristic $p$, the Weyl algebra becomes isomorphic to $M_{p^n}(Z_p)$ where $Z_p$ is the center.
4. Prove that endomorphisms of this matrix algebra are conjugations (Skolem-Noether).
5. Lift to characteristic zero using approximation arguments.

### Proof Strategy B: Poisson Algebra Approach

1. Define the associated graded algebra of $A_n(K)$, which is the polynomial ring with Poisson bracket.
2. Show that endomorphisms of $A_n(K)$ induce polynomial automorphisms of the associated graded.
3. Use the Jacobian Conjecture to show these automorphisms are invertible.
4. Lift invertibility back to the Weyl algebra.

### Breakthrough Potential

Building a formal Weyl algebra would open a vast territory for formalization: quantum mechanics, D-modules, microlocal analysis. The Jacobian-Dixmier bridge is a rare example of a proven reduction between two major open conjectures.

### Cross-Domain Connection

**Quantum mechanics**: The Weyl algebra encodes the canonical commutation relations. Endomorphisms correspond to changes of quantum observables. The Dixmier Conjecture says every such change is reversible — a deep statement about the rigidity of quantum phase space.

---

## Direction 5: Tame vs Wild Automorphisms and the Nagata Conjecture

### Theorem Statement

Formalize the distinction between tame automorphisms (compositions of elementary and linear automorphisms) and wild automorphisms. Prove the Jung–van der Kulk theorem: in dimension 2, all polynomial automorphisms are tame.

### Lean Type Signature

```lean
-- Elementary automorphisms
inductive ElementaryAut (K : Type*) [Field K] (n : ℕ)
  | linear : (A : Matrix (Fin n) (Fin n) K) → IsUnit A.det → ElementaryAut K n
  | shear : (i : Fin n) → (p : MvPolynomial (Fin n) K) →
            (hp : ∀ j, j ≠ i → (pderiv j) p = 0) → ElementaryAut K n

-- Tame automorphism: finite composition of elementary ones
def IsTame (F : Fin n → MvPolynomial (Fin n) K) : Prop :=
  ∃ (elems : List (ElementaryAut K n)),
    F = compose_list elems

-- Jung–van der Kulk
theorem jung_van_der_kulk
    (K : Type*) [Field K]
    (F : Fin 2 → MvPolynomial (Fin 2) K)
    (haut : isPolynomialAutomorphism F) :
    IsTame F := by
  sorry
```

### Proof Strategy A: Degree Reduction

1. Define the degree of a polynomial automorphism as the maximum total degree of its components.
2. Show that if $F$ has degree $> 1$, there exists an elementary automorphism $E$ such that $F \circ E^{-1}$ has strictly lower degree.
3. Iterate until the degree reaches 1 (linear case).
4. The composition of elementary inverses gives the tame decomposition.

### Proof Strategy B: Newton Polygon Analysis

1. Use the Newton polygon of the polynomial automorphism to guide the degree reduction.
2. Show that the leading homogeneous part determines the structure of the reducing elementary automorphism.
3. Apply induction on the Newton polygon area.

### Breakthrough Potential

The Jung–van der Kulk theorem is the definitive structure theorem for 2D polynomial automorphisms. Its formalization would complete the picture for dimension 2 and set the stage for studying the Nagata automorphism in dimension 3 (proved wild by Shestakov–Umirbaev in 2004).

### Cross-Domain Connection

**Algebraic K-theory**: The structure of the polynomial automorphism group $\text{GA}_n(K)$ connects to K-theoretic invariants. The tame/wild dichotomy is analogous to the distinction between inner and outer automorphisms in group theory, with implications for algebraic K-groups.

---

## Research Team Directive

Each direction should be pursued by a subteam with:
- **Hypothesis**: Clearly stated conjecture or theorem to prove
- **Proof strategy**: At least two independent approaches
- **Formal skeleton**: Lean file with definitions and sorry'd lemmas
- **Validation criteria**: Specific `#print axioms` checks and `lean_build` verification
- **Iteration protocol**: Weekly review of sorry count and proof progress

Priority ordering: Direction 1 (most immediately provable) → Direction 3 (standalone result) → Direction 5 (structural theorem) → Direction 2 (deep reduction) → Direction 4 (infrastructure-heavy).
