# Future Research Directions

## 1. Extension to GL_n

The current framework handles GL₂ and GL₃. The natural next step is GL₄ and
general GL_n. Key challenges:

- **Combinatorial explosion**: S_n has n! permutations. For GL₄, 24 terms.
  Need efficient Finset-based formalization rather than explicit enumeration.
- **Weyl invariance proof strategy**: Instead of case-splitting on all permutations,
  develop a general proof using the fact that adjacent transpositions generate S_n.
- **Automated tropical Schur generation**: Define `tropicalSchurGLn (n : ℕ)` using
  Finset.univ over Equiv.Perm (Fin n).

## 2. Surjectivity of the Tropical Satake Transform

We proved injectivity of S_trop on dominant coweights. The other direction—showing
that every W-invariant tropical polynomial in the image—requires:

- **Tropical polynomial ring formalization**: Define the ring of piecewise-linear
  W-invariant functions on ℝ^n.
- **Tropical basis theorem**: Show that tropical Schur polynomials form a basis
  of this ring (tropical analogue of the fundamental theorem of symmetric functions).

## 3. Tropical Hecke Algebra Structure

The geometric side needs further development:

- **Min-plus convolution**: Formalize the tropical Hecke algebra as a min-plus
  convolution algebra on functions GL₃(F)/GL₃(O) → ℝ ∪ {+∞}.
- **Tropical matrix multiplication**: Connect to tropical linear algebra via the
  `Tropical` type in Mathlib (which already exists).
- **Hall-Littlewood polynomials**: Tropicalize the Hall-Littlewood basis of the
  Hecke algebra and verify the structure constants.

## 4. Connection to Crystal Bases

The tropical Satake correspondence is intimately related to Kashiwara's crystal bases:

- **Crystal graph for GL₃**: Formalize the crystal graph of the standard
  representation and its tensor products.
- **Littelmann path model**: The tropical Schur polynomial can be interpreted
  as a generating function over Littelmann paths.
- **MV polytopes**: Mirković-Vilonen polytopes give a geometric realization;
  their moment map images are tropical convex hulls.

## 5. Tropical Plancherel Formula

Strengthen the Plancherel measure results:

- **Explicit formula**: Show μ^trop(s) = Σ_{α>0} |⟨α, s⟩| for GL₃.
- **Inversion formula**: Prove the tropical Plancherel inversion, recovering
  the orbital integral from the Schur polynomial via tropical integration
  against the Plancherel measure.

## 6. Cross-Domain Connections

### 6.1 Tropical Spectral Theory
The existing `tropical_spectral_bound` theorem could be extended to show that
tropical eigenvalues of a matrix A are related to tropical Schur polynomials
of the associated coweight. Specifically, the tropical characteristic polynomial
det^trop(A - xI) should factor via tropical Schur polynomials.

### 6.2 Tropical Mirror Symmetry
The existing `tropical_mirror_theorem` (max a a = a) is the idempotent law in
max-plus algebra. Connect this to the tropical Satake correspondence via
Langlands duality: the Satake isomorphism is a form of mirror symmetry between
the geometric and spectral sides.

### 6.3 Newton Polygons
For GL₂, the tropical Schur polynomial at the fundamental weight gives the
tropical trace, which is related to Newton polygons of p-adic power series.
Extend this to GL₃ and connect to p-adic Hodge theory.

## 7. Computational Aspects

- **Tropical linear programming**: The concavity of tropical Schur polynomials
  means that optimizing over them reduces to linear programming in the
  tropical semiring.
- **Efficient evaluation**: Implement O(n log n) evaluation of tropical Schur
  polynomials using sorting (the dominant chamber formula reduces evaluation
  to sorting + inner product).

## 8. Open Problems

1. **Tropical Kazhdan-Lusztig polynomials**: Can the KL polynomial theory be
   tropicalized while preserving the positivity conjecture?

2. **Tropical Langlands functoriality**: Does the tropical Satake isomorphism
   respect Langlands functorial transfers (e.g., base change, symmetric power)?

3. **Quantitative tropicalization**: For a fixed prime p, how well does the
   tropical Schur polynomial approximate the actual orbital integral on GL₃(ℚ_p)?
   Can we bound the error in terms of p?
