# Future Directions: Derived Functor Theory in Lean 4

## Overview

This document outlines five concrete next-step theorems that build directly on the machine-verified derived functor infrastructure established in this project. Each direction includes a precise theorem statement, proposed Lean type signature, proof strategy sketches, and cross-domain connections.

---

## Direction 1: Ext and Tor over Principal Ideal Domains via Smith Normal Form

### Theorem Statement

For a principal ideal domain R, a finitely generated R-module M with invariant factors (d₁, ..., dₖ) (where d₁ | d₂ | ... | dₖ), and any R-module N:

Ext¹_R(M, N) ≅ ⊕ᵢ N/dᵢN

Tor₁^R(M, N) ≅ ⊕ᵢ dᵢ-torsion(N)

### Proposed Lean Type Signature

```lean
theorem Ext1_fg_PID {R : Type*} [CommRing R] [IsPrincipalIdealRing R]
    (M : ModuleCat R) [Module.Finite R M]
    (N : ModuleCat R)
    (invFactors : List R) (hM : InvariantFactorDecomposition M invFactors) :
    Nonempty (Ext1 M N ≃ₗ[R] ⨁ (d : invFactors), N ⧸ nImage N d) := sorry
```

### Proof Strategy 1: Direct Smith Normal Form

Construct the projective resolution of M by:
1. Present M as R^n / im(A) for an integer matrix A
2. Compute Smith normal form of A to get diagonal matrix D = diag(d₁,...,dₖ)
3. The resolution is R^k →D→ R^n → M → 0
4. Apply Hom(−, N) or (−⊗N) and compute cohomology/homology

### Proof Strategy 2: Induction on Invariant Factors

Decompose M ≅ R/d₁ ⊕ ··· ⊕ R/dₖ and use:
1. Ext¹ commutes with finite direct sums in the first variable
2. Each summand reduces to the cyclic case already proved
3. Assemble via the direct sum isomorphism

### Cross-Domain Connection

**Algebraic Number Theory**: The class group of a number field is a finitely generated abelian group. Ext computations over ℤ classify extensions of the class group, which encode information about ideal factorization and Galois cohomology.

---

## Direction 2: Classification of Extensions by Ext¹

### Theorem Statement

For R-modules M and N, there is a natural bijection between:
- Equivalence classes of short exact sequences 0 → N → E → M → 0
- Elements of Ext¹_R(M, N)

Under this bijection, the trivial extension (direct sum) corresponds to 0 ∈ Ext¹.

### Proposed Lean Type Signature

```lean
structure ModuleExtension (R : Type*) [Ring R] (M N : ModuleCat R) where
  E : ModuleCat R
  i : N ⟶ E
  p : E ⟶ M
  mono_i : Mono i
  epi_p : Epi p
  exact : CategoryTheory.ShortComplex.Exact (CategoryTheory.ShortComplex.mk i p (by sorry))

def ExtensionEquiv (R : Type*) [Ring R] (M N : ModuleCat R) :=
  Quotient (ModuleExtension.Setoid R M N)

theorem Ext1_classifies_extensions {R : Type*} [Ring R]
    (M N : ModuleCat R) [CategoryTheory.EnoughProjectives (ModuleCat R)] :
    Nonempty (ExtensionEquiv R M N ≃ Abelian.Ext N M 1) := sorry
```

### Proof Strategy 1: Yoneda Extension Construction

Given an extension 0 → N → E → M → 0 and a projective resolution P• → M:
1. Lift the identity on M to a chain map P• → E → M
2. The resulting map P₁ → N (modulo boundaries) gives the Ext class
3. Show this is well-defined modulo chain homotopy

### Proof Strategy 2: Baer Sum Direct Construction

1. Define the Baer sum on extensions directly
2. Show it gives a group structure on extension classes
3. Construct an explicit isomorphism to Ext¹ via the long exact sequence

### Cross-Domain Connection

**Representation Theory**: Extensions of representations correspond to deformation theory. Ext¹ between simple modules classifies non-split extensions, which appear in the Jordan-Hölder filtration and block decomposition of module categories.

---

## Direction 3: Künneth Formula for Chain Complexes

### Theorem Statement

For chain complexes C and D of free abelian groups, there is a natural short exact sequence:

0 → ⊕_{p+q=n} H_p(C) ⊗ H_q(D) → H_n(C ⊗ D) → ⊕_{p+q=n-1} Tor₁(H_p(C), H_q(D)) → 0

and this sequence splits (non-naturally).

### Proposed Lean Type Signature

```lean
theorem kuenneth_formula
    (C D : ChainComplex (ModuleCat ℤ) ℕ)
    (hC : ∀ n, Module.Free ℤ (C.X n))
    (hD : ∀ n, Module.Free ℤ (D.X n))
    (n : ℕ) :
    ∃ (tensor_part : ⨁ (p : Fin (n+1)),
         ModuleCat.of ℤ (homology C p ⊗[ℤ] homology D (n - p)))
      (tor_part : ⨁ (p : Fin n),
         Tor1_ZMod_general (homology C p) (homology D (n - 1 - p)))
      (i : tensor_part ⟶ homology (tensorComplex C D) n)
      (p : homology (tensorComplex C D) n ⟶ tor_part),
      Function.Injective i ∧ Function.Surjective p ∧
      Function.Exact i p := sorry
```

### Proof Strategy 1: Spectral Sequence Approach

Use the double complex C ⊗ D with its two filtrations:
1. The E² page of one filtration gives H_p(C) ⊗ H_q(D)
2. Convergence gives the Künneth exact sequence
3. Splitting follows from freeness of the tensor part

### Proof Strategy 2: Direct Algebraic Argument

1. Define the cross product map H_p(C) ⊗ H_q(D) → H_{p+q}(C ⊗ D)
2. Show exactness using the acyclic models theorem
3. Identify the cokernel with Tor using the resolution

### Cross-Domain Connection

**Algebraic Topology**: The Künneth formula computes the homology of product spaces X × Y from the homology of X and Y individually. This is essential for computing homology of tori, product manifolds, and configuration spaces.

---

## Direction 4: Group Cohomology via Derived Functors

### Theorem Statement

For a finite group G and a G-module A, define:

H^n(G, A) := Ext^n_{ℤ[G]}(ℤ, A)

where ℤ is the trivial G-module. Then:
- H⁰(G, A) = A^G (the fixed points)
- H¹(G, A) classifies crossed homomorphisms modulo principal ones
- H²(G, A) classifies central extensions of G by A

For G = ℤ/nℤ (cyclic), H^q(G, A) is periodic with period 2.

### Proposed Lean Type Signature

```lean
noncomputable def GroupCohomology (G : Type*) [Group G] [Fintype G]
    (A : Type*) [AddCommGroup A] [DistribMulAction G A] (n : ℕ) :=
  Ext1_over_group_ring n (ModuleCat.of (MonoidAlgebra ℤ G) ℤ)
    (ModuleCat.of (MonoidAlgebra ℤ G) A)

theorem group_cohomology_H0 (G : Type*) [Group G] [Fintype G]
    (A : Type*) [AddCommGroup A] [DistribMulAction G A] :
    GroupCohomology G A 0 ≅ FixedPoints G A := sorry

theorem cyclic_group_cohomology_periodic (n : ℕ) (hn : 0 < n)
    (A : Type*) [AddCommGroup A] [Module (ZMod n) A] (q : ℕ) :
    GroupCohomology (ZMod n) A (q + 2) ≅ GroupCohomology (ZMod n) A q := sorry
```

### Proof Strategy 1: Bar Resolution

Construct the bar resolution of ℤ over ℤ[G]:
1. B_n = ℤ[G^{n+1}] (free ℤ[G]-module)
2. Differentials via alternating face maps
3. Apply Hom_{ℤ[G]}(−, A) and compute cohomology

### Proof Strategy 2: Periodic Resolution for Cyclic Groups

For G = ℤ/nℤ, use the periodic resolution:
1. ··· → ℤ[G] →N→ ℤ[G] →(σ-1)→ ℤ[G] →N→ ℤ[G] →ε→ ℤ → 0
2. Where N = 1 + σ + σ² + ··· + σ^{n-1} (norm element)
3. Periodicity follows from the 2-periodic nature of the resolution

### Cross-Domain Connection

**Number Theory**: Group cohomology of Galois groups computes Brauer groups, class field theory invariants, and étale cohomology of schemes. Tate cohomology of cyclic groups underlies local class field theory.

---

## Direction 5: Full Universal Coefficient Theorem as a Splitting Short Exact Sequence

### Theorem Statement

For a chain complex C of free abelian groups and an abelian group A, there is a natural short exact sequence:

0 → H_n(C) ⊗ A → H_n(C; A) → Tor₁(H_{n-1}(C), A) → 0

This sequence splits (non-naturally), so H_n(C; A) ≅ (H_n(C) ⊗ A) ⊕ Tor₁(H_{n-1}(C), A).

### Proposed Lean Type Signature

```lean
theorem universal_coefficient_theorem
    (C : ChainComplex (ModuleCat ℤ) ℕ)
    (A : ModuleCat ℤ)
    (hfree : ∀ n, Module.Free ℤ (C.X n))
    (n : ℕ) :
    ∃ (i : ModuleCat.of ℤ (homology C n ⊗[ℤ] A) ⟶
           homology (tensorChainComplex C A) n)
      (p : homology (tensorChainComplex C A) n ⟶
           Tor1_general (homology C (n-1)) A),
      Mono i ∧ Epi p ∧
      CategoryTheory.ShortComplex.Exact
        (CategoryTheory.ShortComplex.mk i p sorry) ∧
      -- Splitting:
      ∃ s : Tor1_general (homology C (n-1)) A ⟶
            homology (tensorChainComplex C A) n,
        p.comp s = 𝟙 _ := sorry
```

### Proof Strategy 1: Direct Construction via Freeness

1. Since C_n is free, the sequence 0 → Z_n → C_n → B_{n-1} → 0 splits
2. Apply (−⊗A) and use the splitting to construct the UCT sequence
3. The Tor term arises from the non-splitting of 0 → B_n → Z_n → H_n → 0 after tensoring

### Proof Strategy 2: Derived Category Approach

1. Use the distinguished triangle Z_n → C_n → B_{n-1} → Z_n[1]
2. Apply the functor −⊗^L A (derived tensor product)
3. The resulting long exact sequence gives the UCT
4. Splitting follows from Ext¹(H_n, −) = 0 when H_n is free

### Cross-Domain Connection

**Topological Data Analysis**: The UCT enables coefficient changes in persistent homology. Detecting torsion in integral homology via mod-p coefficients is computationally more efficient, and the UCT provides the rigorous framework for translating between coefficient systems.

---

## Implementation Priorities

1. **Direction 2** (Extension classification) has the highest formalization feasibility, building directly on existing Ext infrastructure.
2. **Direction 1** (PID generalization) requires Smith normal form, which has partial Mathlib support.
3. **Direction 5** (Full UCT) requires defining tensor products of chain complexes, which needs significant infrastructure.
4. **Direction 3** (Künneth) and **Direction 4** (Group cohomology) are longer-term goals requiring new algebraic machinery.

## Team Directives

Each direction should be pursued with:
- **Hypothesis**: A clear conjecture about the Lean formalization strategy
- **Validation**: Computational experiments in Python verifying instances
- **Iteration**: Progressive refinement of definitions based on what Mathlib supports
- **Integration**: Regular checks that new definitions compose correctly with existing infrastructure
