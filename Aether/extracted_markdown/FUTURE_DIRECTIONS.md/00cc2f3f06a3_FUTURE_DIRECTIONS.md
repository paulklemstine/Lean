# Future Directions: Tropical Satake Isomorphism

## Hypothesis 1: Tropical Littlewood-Richardson Coefficients

**Conjecture.** The structure constants of the tropical Hecke convolution algebra for GL_n (with respect to the basis of dominant-coweight indicator functions) are tropicalized Littlewood-Richardson coefficients. Specifically, if T_λ and T_μ are the basis Hecke operators indexed by dominant coweights λ and μ, then the tropical convolution T_λ ⊛ T_μ has support governed by the tropical LR rule: the coefficient at dominant coweight ν equals the minimum over all LR tableaux of shape ν/λ and content μ of the corresponding tropical weight.

**Test.** Implement tropical Hecke convolution for GL₃ and GL₄ using the min-plus semiring. Compute T_λ ⊛ T_μ for all pairs of dominant coweights with coordinates in [-3, 3]. Compare the support and values with those predicted by tropicalized LR coefficients (computed by substituting min for + and + for × in the classical LR algorithm).

**Refutation criterion.** A concrete pair (λ, μ) for GL₃ or GL₄ where the tropical convolution support or values differ from the tropical LR prediction.

**Impact.** If true, this would establish a direct computational bridge between tropical representation theory and classical combinatorics, enabling algorithmic computation of tropical Hecke structure constants via tableau combinatorics.

---

## Hypothesis 2: Tropical Satake as Adjoint Equivalence

**Conjecture.** The tropical Satake transform for GL_n can be realized as a pair of adjoint functors between the category of finitely supported min-plus modules over the coweight lattice and the category of W-invariant tropical polynomial modules, with the Satake equivalence being the unit/counit isomorphisms.

**Test.** Formalize candidate unit and counit natural transformations for n = 2, 3, 4. Define the categories explicitly (objects = finitely supported functions, morphisms = tropical-linear maps) and verify the triangle identities η ∘ ε = id and ε ∘ η = id computationally for small objects.

**Refutation criterion.** Failure of one triangle identity for a specific finitely supported min-plus module at n = 3, or an obstruction to defining the counit naturally.

**Impact.** If true, this would place tropical Satake within the framework of categorical Galois theory, connecting it to Lawvere's categorical foundations and opening tropical automorphic forms to topos-theoretic methods.

---

## Hypothesis 3: W-Invariant Tropical Polynomials Have Canonical Basis

**Conjecture.** For every n, the semiring TropPolyInv_n of W-invariant tropical polynomials is freely generated (as a tropical semiring under min and +) by the orbit-symmetrized tropical monomials {s_λ : λ dominant} defined by s_λ(μ) = min_{σ ∈ S_n} ⟨σ·λ, μ⟩. Equivalently, every finitely generated W-invariant tropical polynomial can be uniquely expressed as a finite tropical linear combination (min of shifted copies) of these generators.

**Test.** For n = 2, 3, 4, enumerate all W-invariant tropical polynomials with bounded support (affine forms with slopes in [-3,3]ⁿ) and attempt to decompose each as a tropical combination of the canonical generators. Check uniqueness of the decomposition.

**Refutation criterion.** A W-invariant tropical polynomial for n = 3 or n = 4 that cannot be expressed as a finite min of shifted orbit-symmetrized monomials, or two distinct decompositions of the same polynomial.

**Impact.** If true, this establishes a tropical analogue of the fundamental theorem of symmetric polynomials, with the orbit-symmetrized monomials playing the role of elementary symmetric polynomials. This would be foundational for tropical Schur theory.

---

## Hypothesis 4: Semiring Isomorphism with Explicit Convolution

**Conjecture.** The tropical Satake bijection for GL_n extends to a semiring isomorphism TropHecke_n ≃+* TropPolyInv_n, where:
- The Hecke semiring has tropical convolution: (H₁ ⊛ H₂)(ν) = min_{λ+μ=ν} (H₁(λ) + H₂(μ))
- The polynomial semiring has pointwise min and tropical convolution
- The Satake map intertwines both operations

**Test.** Define tropical convolution on TropHecke explicitly for n = 2, 3. Compute S(H₁ ⊛ H₂) and compare with S(H₁) ⊗ S(H₂) for all pairs of basis elements with support in [-2, 2]ⁿ. Verify that the Satake map preserves both the min (tropical addition) and convolution (tropical multiplication) operations.

**Refutation criterion.** A pair (H₁, H₂) for GL₂ or GL₃ where S(H₁ ⊛ H₂) ≠ S(H₁) ⊗ S(H₂), demonstrating that the bijection does not respect the convolution algebra structure at the semiring level.

**Impact.** If true, this completes the tropical Satake isomorphism at the algebraic level, establishing a genuine semiring isomorphism (not just a set bijection). This is the key step toward tropical automorphic computation.

---

## Hypothesis 5: Extension to Other Root Systems

**Conjecture.** The tropical Satake isomorphism extends to all finite Coxeter groups (W, S) acting on their coweight lattice Λ. Specifically, for each finite Coxeter group W:
1. Each W-orbit in Λ contains a unique element in the dominant chamber.
2. The restriction-extension bijection between W-invariant functions and functions on the dominant chamber holds.
3. The bijection specializes correctly for types B_n, C_n, D_n, and the exceptional types.

**Test.** Implement the orbit-dominance structure for the Weyl groups of types B₂, B₃, C₃, and G₂. For each, verify computationally that:
- Each orbit has a unique dominant representative.
- The Satake roundtrip identity holds.
- The number of dominant coweights matches the known Weyl group quotient.

**Refutation criterion.** A Weyl group orbit for type B₃ or G₂ that contains zero or more than one dominant element, or a roundtrip failure.

**Impact.** If true, this would establish a uniform tropical Satake isomorphism for all reductive groups, opening the full Langlands program to tropical/idempotent methods. The exceptional types (E₆, E₇, E₈, F₄, G₂) would be particularly interesting as they have no classical "matrix" realization but still admit tropical Satake.
