# Future Directions: The Polynomial Method for Cap Sets and Beyond

## Overview

This document outlines 5 concrete, breakthrough-level research directions opened by the formalized cap set infrastructure. Each direction includes precise theorem statements, proposed Lean signatures, proof strategies, and cross-domain connections.

The current work establishes:
- A complete reduced polynomial representation theorem for functions on 𝔽₃ⁿ
- Linear independence of indicator polynomial evaluations
- Concrete cap set bounds for small dimensions (n=1,2)
- Additive energy infrastructure for cap sets
- The algebraic equivalence between 3-AP-freeness and sum-zero conditions

---

## Direction 1: Slice Rank and the Ellenberg–Gijswijt Bound

### Target Theorem
The cap set number in 𝔽₃ⁿ is at most O(2.756ⁿ), following Ellenberg–Gijswijt (2017).

### Proposed Lean Signature
```lean
theorem capset_ellenberg_gijswijt_bound :
    ∃ C : ℝ, C < 2.756 ∧ 0 < C ∧
    ∀ n : ℕ, ∀ A : Finset (F3Vec n),
      IsCapSet A → (A.card : ℝ) ≤ C ^ n
```

### Proof Strategies
1. **Direct slice rank approach**: Define slice rank for order-3 tensors T : V × V × V → k. Prove that the diagonal tensor restricted to a cap set A has slice rank |A|. Prove that the polynomial decomposition forces slice rank ≤ 3 · (number of monomials of degree ≤ 2n/3 with exponents < 3). Combine to get |A| ≤ 3 · binom(n, ≤ 2n/3, restricted).

2. **Partition rank variant**: Use the simpler notion of partition rank (Naslund 2020) which avoids some tensor formalism. Define a function F : A × A × A → 𝔽₃ that is "diagonal" (nonzero only when x = y = z) and show it has low partition rank.

3. **Combinatorial dimension argument**: Bypass tensors entirely. Use the polynomial method to show that the indicator functions {1_a : a ∈ A} restricted to a cap set, expressed as degree-≤-2n/3 polynomials, must be linearly independent. Count dimensions.

### Cross-Domain Connections
- **Algebraic complexity**: Slice rank is related to tensor rank, which governs matrix multiplication complexity. Formalizing slice rank creates infrastructure for Strassen-type lower bounds.
- **Communication complexity**: Tensor rank lower bounds imply communication complexity lower bounds for multiparty problems.
- **Quantum information**: Tensor decompositions appear in quantum entanglement classification.

---

## Direction 2: Generalized Progression-Free Bounds in 𝔽_p^n

### Target Theorem
Extend cap set bounds to arbitrary prime fields: for each prime p, progression-free sets in 𝔽_p^n have exponentially small density.

### Proposed Lean Signature
```lean
theorem progression_free_bound_general (p : ℕ) [hp : Fact (Nat.Prime p)] :
    ∃ C : ℝ, C < p ∧ 0 < C ∧
    ∀ n : ℕ, ∀ A : Finset (Fin n → ZMod p),
      ThreeAPFree (A : Set (Fin n → ZMod p)) →
      (A.card : ℝ) ≤ C ^ n
```

### Proof Strategies
1. **Generalize the reduced polynomial framework**: Replace ZMod 3 with ZMod p throughout. The key identity x^p = x holds in any 𝔽_p. Reduced polynomials have exponents < p in each variable, giving p^n monomials. The indicator polynomial becomes ∏ᵢ (1 - (xᵢ - aᵢ)^(p-1)).

2. **Chevalley–Warning style arguments**: Use the Chevalley–Warning theorem to bound the number of solutions to polynomial equations over finite fields. This provides an alternative route to progression-free bounds.

3. **Lucas-based asymptotics**: The monomial counting step requires bounding multinomial coefficients with restricted exponents. This connects to entropy optimization and can be handled via Stirling's approximation formalized in Lean.

### Cross-Domain Connections
- **Coding theory**: Progression-free sets in 𝔽_p^n correspond to codes with forbidden linear patterns. Generalizing to arbitrary p opens connections to Reed-Solomon and BCH codes.
- **Number theory**: The density Hales-Jewett theorem and Szemerédi's regularity lemma operate in similar territory but with different tools.

---

## Direction 3: The Function-Polynomial Isomorphism as a Linear Equivalence

### Target Theorem
The evaluation map from reduced polynomials to functions on 𝔽₃ⁿ is a linear isomorphism of vector spaces over 𝔽₃.

### Proposed Lean Signature
```lean
noncomputable def reducedPolyEquiv (n : ℕ) :
    {P : MvPolynomial (Fin n) (ZMod 3) // IsReduced P} ≃ₗ[ZMod 3]
    (F3Vec n → ZMod 3) where
  toFun := fun ⟨P, _⟩ => MvPolynomial.eval · P
  invFun := fun f => ⟨interpolationPoly f, interpolationPoly_isReduced f⟩
  map_add' := sorry
  map_smul' := sorry
  left_inv := sorry
  right_inv := sorry
```

### Proof Strategies
1. **Subtype approach**: Define the subtype of reduced polynomials, equip it with the submodule structure from `restrictDegree`, and show the evaluation map is bijective using `exists_reduced_poly_rep` and `reduced_poly_eval_injective`.

2. **Direct construction**: Build the linear equivalence using `interpolationPoly` as the inverse of evaluation. The main work is showing linearity of interpolation (which follows from linearity of the sum construction) and the left/right inverses (which follow from evaluation correctness and injectivity).

3. **Dimension argument**: Show both spaces have dimension 3^n (reduced monomials form a basis of the polynomial subspace, and functions on a 3^n-element set form a 3^n-dimensional space). A bijective linear map between equidimensional spaces is an isomorphism.

### Cross-Domain Connections
- **Algebraic geometry**: This is a concrete instance of the coordinate ring isomorphism for a finite variety. Formalizing it opens paths to algebraic geometry over finite fields.
- **Coding theory**: The evaluation map is precisely the encoding map of Reed-Muller codes over 𝔽₃.
- **Pseudorandomness**: The polynomial representation is fundamental to constructions of pseudorandom generators and extractors.

---

## Direction 4: Additive Energy Bounds from Cap Set Constraints

### Target Theorem
Cap sets have near-minimal additive energy: if A ⊆ 𝔽₃ⁿ is a cap set, then E(A) ≤ |A|² · (some explicit factor depending on n).

### Proposed Lean Signature
```lean
theorem capset_additive_energy_bound {n : ℕ} {A : Finset (F3Vec n)}
    (hA : IsCapSet A) :
    additiveEnergy A ≤ A.card ^ 2 * (2 * 3 ^ n) := sorry
```

### Proof Strategies
1. **Sumset bounds**: Show that cap sets have large sumsets (|A + A| ≥ |A|^{3/2} or similar). Combined with the Plünnecke-Ruzsa inequality, this bounds additive energy.

2. **Fourier analysis**: Express additive energy as a sum of fourth powers of Fourier coefficients. Cap set constraints force Fourier coefficients to be uniformly small, bounding the energy.

3. **Direct counting via polynomial vanishing**: Use the polynomial method to count solutions to a + b = c + d in A⁴. The progression-free constraint limits the "degenerate" solutions, and the polynomial space dimension limits the total.

### Cross-Domain Connections
- **Additive combinatorics**: This directly strengthens the existing `bounded_autocorr_bounded_energy` theorem in the catalog, creating a bridge between spectral methods and polynomial methods.
- **Ergodic theory**: Additive energy bounds are a key ingredient in ergodic-theoretic proofs of Szemerédi's theorem.
- **Cryptography**: Low additive energy is a requirement for certain hash function constructions and randomness extractors.

---

## Direction 5: Finite-Field Incidence Geometry via Polynomial Partitioning

### Target Theorem
The Kakeya conjecture over finite fields: a Kakeya set in 𝔽_q^n has size at least c_n · q^n for some constant c_n > 0 depending only on n.

### Proposed Lean Signature
```lean
def IsKakeyaSet {q n : ℕ} [Fintype (ZMod q)] (K : Set (Fin n → ZMod q)) : Prop :=
  ∀ d : Fin n → ZMod q, d ≠ 0 → ∃ a : Fin n → ZMod q,
    ∀ t : ZMod q, (a + t • d) ∈ K

theorem kakeya_finite_field {n : ℕ} (hn : 0 < n) (q : ℕ) [Fact (Nat.Prime q)] :
    ∃ c : ℝ, 0 < c ∧ ∀ K : Finset (Fin n → ZMod q),
      IsKakeyaSet (K : Set (Fin n → ZMod q)) →
      c * (q : ℝ) ^ n ≤ K.card := sorry
```

### Proof Strategies
1. **Dvir's polynomial method**: The original proof by Dvir (2009) uses the polynomial method directly. If K is a Kakeya set with |K| < binom(n+q-1, n), then there exists a nonzero polynomial of degree < q vanishing on K. But a polynomial of degree < q vanishing on a line in every direction must be zero (by the Schwartz-Zippel lemma applied along each line). Contradiction.

2. **Algebraic method with multiplicity**: Dvir-Kopparty-Saraf-Sudan strengthened this with multiplicity arguments. This requires formalizing polynomial multiplicities at points.

3. **Polynomial partitioning**: The Guth-Katz approach (for ℝ^n) uses polynomial partitioning, which could be adapted to finite fields for incidence geometry applications.

### Cross-Domain Connections
- **Harmonic analysis**: Kakeya sets are central to restriction theory and Bochner-Riesz conjectures.
- **PDEs**: Kakeya-type estimates govern dispersive properties of wave and Schrödinger equations.
- **Computer science**: Kakeya sets are connected to randomness extractors and derandomization.

---

## Implementation Priorities

### Immediate (Next Cycle)
1. Direction 3 (Linear equivalence) — builds directly on current infrastructure
2. Direction 4 (Additive energy) — extends existing additive combinatorics catalog
3. Begin Direction 1 (Slice rank definitions)

### Medium-Term (2-3 Cycles)
1. Complete Direction 1 (Ellenberg-Gijswijt bound)
2. Direction 2 (General 𝔽_p^n bounds)
3. Kakeya set definitions for Direction 5

### Long-Term (4+ Cycles)
1. Full slice rank theory with applications
2. Connections to algebraic complexity
3. Finite-field incidence geometry program
4. Gowers norms and inverse theorems

---

## Team Directive

- **Finite-field algebra lead**: Generalize ZMod 3 infrastructure to ZMod p. Build Chevalley-Warning.
- **Combinatorics lead**: Formalize sumset bounds, additive energy, Plünnecke-Ruzsa.
- **Linear algebra lead**: Build tensor rank and slice rank from scratch. Connect to Matrix API.
- **Complexity/cross-domain lead**: Extract coding-theoretic and computational implications.
- **Formalization engineer**: Minimize sorry count, optimize build times, maintain API coherence.
