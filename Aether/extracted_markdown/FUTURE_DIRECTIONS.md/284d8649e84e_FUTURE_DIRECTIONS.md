# Future Directions: Weyl Algebra Infrastructure and Jacobian–Dixmier Bridge

## Synthesis

The formalization of the first Weyl algebra A₁(K) and its filtration theory opens a verified corridor between quantum operator algebras and classical polynomial dynamics. The five directions below form a coherent research program: Direction 1 (Higher Weyl Algebras) and Direction 2 (PBW Theorem) extend the algebraic foundation; Direction 3 (Full Symbol Map) and Direction 4 (Poisson Geometry) build the bridge superstructure; Direction 5 (Computational Automorphism Search) provides the experimental engine that could produce counterexamples or confirm conjectures. Together, they aim to transform the Jacobian–Dixmier equivalence from a theoretical curiosity into a practical tool for attacking both conjectures.

---

## Direction 1: Higher Weyl Algebras Aₙ and Multi-Pair Systems

**Conjecture:** The power commutation formula and filtration degree drop generalize to Aₙ(K) with n canonical pairs (x₁,d₁),...,(xₙ,dₙ), where [dᵢ, xⱼ] = δᵢⱼ. Specifically, the commutator of two elements of filtration degrees i and j lies in filtration degree i+j−1, and the associated graded gr(Aₙ) ≅ K[x₁,...,xₙ,ξ₁,...,ξₙ].

**Test:** Formalize `IsWeylSystem K A n` with n pairs and prove the multi-index power commutation formula dᵢ · xⱼ^m = xⱼ^m · dᵢ + δᵢⱼ · m · xⱼ^{m-1}. Verify computationally for n ≤ 4 that the commutator degree drop holds for all monomials up to total degree 8. A failure would indicate either a formalization error or an unexpected algebraic phenomenon.

**Impact:** Extends the Jacobian–Dixmier bridge from dimension 2 (A₁ → K²) to dimension 2n (Aₙ → K²ⁿ), covering the full strength of both conjectures.

**Catalog References:** `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (IsWeylPair, deriv_comm_pow), `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` (jacobian_implies_dixmier_abstract)

**Proof Strategy:** Generalize the induction in `deriv_comm_pow` to multi-index induction. The key step is that [dᵢ, xⱼ] = 0 for i ≠ j, so different coordinate pairs commute. Use `Finset.prod` over coordinate indices.

**Domain Bridges:** Algebra ↔ Quantum Field Theory (n-particle systems), Algebra ↔ Symplectic Geometry (T*Aⁿ)

**Lineage:** Builds directly on IsWeylPair and deriv_comm_pow from this cycle.

**Ambition:** Extension — solid next step building on established infrastructure.

---

## Direction 2: PBW Theorem for A₁ via Ore Extension

**Conjecture:** The first Weyl algebra A₁(K) is isomorphic (as a K-algebra) to the Ore extension K[x][d; d/dx], and the PBW monomials {x^i d^j : i,j ∈ ℕ} form a K-basis. Equivalently, every element of A₁ has a unique normal form ∑ cᵢⱼ x^i d^j.

**Test:** Define A₁ as a quotient of the free algebra K⟨X, D⟩ / (DX − XD − 1) and construct an explicit K-linear isomorphism to (ℕ × ℕ) →₀ K. The isomorphism must preserve multiplication (when the target is equipped with the Weyl product). Verify computationally that the isomorphism is correct on all monomials up to total degree 10.

**Impact:** Establishes normal forms as a theorem rather than a definition, enabling the filtration theory to be applied to arbitrary Weyl algebra constructions (not just those already in normal form).

**Catalog References:** `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (WeylElement, normalOrderWord)

**Proof Strategy:** Define the Ore extension K[x][d; δ] where δ = d/dx. The multiplication rule d · p = p · d + δ(p) for p ∈ K[x] gives exactly the Weyl relation when p = x. Use `Polynomial.derivative` as the derivation δ. Prove that the resulting algebra is isomorphic to A₁ via the universal property.

**Domain Bridges:** Algebra ↔ Homological Algebra (Ore extensions appear in skew polynomial ring theory), Algebra ↔ Differential Algebra (D-modules)

**Lineage:** Completes the theoretical foundation started in this cycle with WeylElement.

**Ambition:** Extension — fills a critical gap in the current architecture.

---

## Direction 3: Full Symbol Map Theorem (Every Weyl Endomorphism is Keller)

**Conjecture (Grand Challenge):** Every algebra endomorphism of A₁(K) that preserves the standard order filtration induces a polynomial map on gr(A₁) ≅ K[x, ξ] with constant nonzero Jacobian determinant.

**Test:** For filtered endomorphisms of degree ≤ 3 (images of generators have total degree ≤ 3), verify computationally that the induced Jacobian determinant is constant. Specifically, parameterize all degree-3 endomorphisms satisfying the Weyl relation [φ(d), φ(x)] = 1, compute the induced polynomial map, and check the Jacobian. A non-constant Jacobian would disprove the conjecture for degree-3 endomorphisms.

**Impact:** This is the heart of the Tsuchimoto/BKK theorem. Proving it formally would complete half of the Jacobian–Dixmier equivalence.

**Catalog References:** `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (deg1_weyl_end_jacobian, dixmier_of_jacobian_A1_abstract), `Catalog/Speculative/AutoResearch/Algebra/Jacobian/DixmierBridge.lean` (dixmier_of_jacobian)

**Proof Strategy:** The key insight is that the Weyl relation [φ(d), φ(x)] = 1 forces σ(φ(d)) and σ(φ(x)) (the principal symbols) to have Poisson bracket 1 in gr(A₁). The Poisson bracket condition on polynomial functions forces the Jacobian to be constant. Formalize this by:
1. Defining the Poisson bracket on K[x, ξ]
2. Proving that {σ(a), σ(b)} = σ([a,b]) modulo lower terms
3. Showing that {f, g} = 1 implies Jac(f, g) = const

**Domain Bridges:** Algebra ↔ Poisson Geometry (Poisson bracket formalization), Algebra ↔ Symplectic Geometry (symplectic condition from bracket)

**Lineage:** Directly extends deg1_weyl_end_jacobian from degree 1 to all degrees.

**Ambition:** Grand Challenge — this is a deep theorem requiring substantial new infrastructure.

---

## Direction 4: Poisson Bracket Formalization and Semiclassical Limit

**Conjecture:** The principal symbol map σ : A₁ → gr(A₁) ≅ K[x, ξ] satisfies σ([a, b]) = {σ(a), σ(b)} where {f, g} = ∂f/∂x · ∂g/∂ξ − ∂f/∂ξ · ∂g/∂x is the Poisson bracket, whenever deg([a,b]) = deg(a) + deg(b) − 1 (the "generic" case where the commutator achieves its maximum possible degree).

**Test:** Verify computationally for all monomial pairs (x^a d^b, x^c d^e) with a+b, c+e ≤ 6 that the principal symbol of [x^a d^b, x^c d^e] equals {x^a ξ^b, x^c ξ^e}. The Poisson bracket of monomials has a closed form: {x^a ξ^b, x^c ξ^e} = (bc − ae) · x^{a+c−1} · ξ^{b+e−1}. Compare with the leading coefficient of the commutator. A mismatch would indicate an error in either the commutator computation or the Poisson bracket formula.

**Impact:** Establishes the formal connection between quantum commutators and classical Poisson brackets, completing the "semiclassical limit" interpretation of the filtration.

**Catalog References:** `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (weylPrincipalSymbol, monomial_comm_degree_drop)

**Proof Strategy:** Define PoissonBracket on MvPolynomial (Fin 2) K using partial derivatives. Prove the Poisson bracket identity for monomials by direct calculation, then extend by bilinearity.

**Domain Bridges:** Algebra ↔ Classical Mechanics (Poisson brackets govern Hamiltonian dynamics), Algebra ↔ Deformation Quantization (A₁ is the canonical deformation of K[x, ξ])

**Lineage:** Extends weylPrincipalSymbol from a definition to a computational tool.

**Ambition:** Extension — substantial but achievable with current infrastructure.

---

## Direction 5: Computational Automorphism Search for Low-Degree Weyl Endomorphisms

**Conjecture:** Every algebra endomorphism of A₁(ℚ) whose generator images have total degree ≤ 2 is an automorphism. More precisely: if φ(x) = ∑ cᵢⱼ x^i d^j and φ(d) = ∑ c'ᵢⱼ x^i d^j with i+j ≤ 2 and [φ(d), φ(x)] = 1, then φ is surjective.

**Test:** Parameterize all degree-2 Weyl endomorphisms by their coefficients (6 free parameters for φ(x), 6 for φ(d), subject to the 1 Weyl relation constraint = 11 free parameters). For each parameter choice over a grid in ℚ with denominator ≤ 5, compute:
1. The induced polynomial map on gr(A₁)
2. Its Jacobian determinant
3. Whether the Jacobian map is a polynomial automorphism (for low-degree maps, this can be verified by computing the inverse)

A counterexample (a degree-2 Weyl endomorphism whose induced map is not invertible) would disprove the conjecture and provide insights into the structure of potential counterexamples to the full Dixmier conjecture.

**Impact:** Provides computational evidence for or against the Dixmier conjecture in the simplest non-trivial case. A counterexample at degree 2 would be a major result.

**Catalog References:** `Catalog/Algebra/Jacobian/WeylAlgebra.lean` (normalOrderWord, Deg1WeylEnd), `Catalog/Algebra/Jacobian/DruzkowskiTheory.lean` (druzkowskiMap)

**Proof Strategy:** Pure computational search. Implement the parameter space enumeration, Weyl relation solver, and polynomial automorphism checker in Python. For formal verification of any found automorphisms, translate to Lean and verify using the existing infrastructure.

**Domain Bridges:** Algebra ↔ Computational Algebra (Gröbner basis methods for automorphism checking), Algebra ↔ Number Theory (rationality constraints on coefficients)

**Lineage:** Extends the degree-1 analysis (Deg1WeylEnd) to degree 2.

**Ambition:** Grand Challenge — the search space is large but the potential payoff (a counterexample or strong evidence) is enormous.
