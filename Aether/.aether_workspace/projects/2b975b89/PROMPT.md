**Tropical Satake Isomorphism for GL₄ — Rank-4 Min-Plus Hecke Algebra**

Building on the verified tropical trace formula for GL₂ (`tropical_trace_formula_GL2` in `Tropical/Langlands/ArthurSelbergGL2.lean`), the prime-rank Satake correspondence (`tropical_trace_formula_prime` in `Tropical/Langlands/SatakeIsomorphism.lean`), and the rank-3 invariant extension (`satake_extend_invariant` in `Tropical/Langlands/TropicalSatakeGL3Algebra.lean`), we now have the exact inductive data needed to prove the tropical Satake isomorphism in the first non-prime, semisimple rank-4 case.

**Target theorem.** Establish the min-plus tropical Satake basis formula for GL₄ by showing that the tropical Satake transform sends each spherical Hecke basis element indexed by a dominant coweight to the corresponding tropical Schur polynomial:

```lean4
theorem tropical_satake_isomorphism_GL4 
  (μ : Fin 4 → ℤ) 
  (hμ : μ 0 ≥ μ 1 ∧ μ 1 ≥ μ 2 ∧ μ 2 ≥ μ 3)
  (z : Fin 4 → ℝ) :
  satakeTransformGL4 (basisDoubleCoset μ) z = 
  tropicalSchurPolynomial (coweightToPartition μ) z
```

**Proof strategy.**

1. *Parabolic reduction via the GL₂ trace formula.* Decompose the affine Grassmannian min-plus convolution kernel for GL₄ along the standard maximal parabolic P₂,₂ ≅ GL₂ × GL₂. Apply `tropical_trace_formula_GL2` to each block to reduce the geometric side of the Satake transform to a nested `inf` over unipotent upper-triangular entries. Then use `Finset.inf_image` together with `min_add_distrib` to push the tropical measure through the Levi factorization and collapse the 2×2 block integrals onto the known GL₂ spectral terms.

2. *Tropical Pieri rule and Schur polynomial evaluation.* Identify the multiplicative structure constants of `tropicalSchurPolynomial` under min-plus convolution by proving the tropical Pieri formula for the product of the basis element indexed by the fundamental coweight (1,0,0,0) with a general dominant coweight μ. Show that the min-plus convolution of the corresponding tropical Hecke basis elements evaluates precisely to the `inf` over semistandard Young tableaux of shape `coweightToPartition μ` with entries in {1,2,3,4}. Key Mathlib lemmas: `Equiv.Perm.sign_prod_list_swap` to handle the S₄ Weyl-group alternation cleanly, and `Finset.inf_le_inf` to bound the min-plus convolution measure against the tableau-weight `inf` that defines the tropical Schur polynomial.

3. *Lift S₄-invariance from the GL₃ extension.* Verify that the right-hand side is S₄-invariant by expressing `tropicalSchurPolynomial` as a `Finset.inf` over the W-orbit of the leading weight using `Equiv.Perm.prod_comp`. Then invoke `satake_extend_invariant` on the embedded (a,b,c)-subsystem to propagate the rank-3 invariant structure to the full rank-4 transform, completing the proof that the tropical Satake transform kernel descends to the Weyl-group quotient and agrees with the tropical Schur basis on the spectral side.

**Why this matters.** This theorem is the critical inductive step that systematizes the tropical Langlands correspondence beyond prime rank. It proves the Maslov dequantization of the classical Satake isomorphism commutes with Levi block embeddings for P₂,₂ ⊂ GL₄, resolving the rank-4 case required for an inductive proof of the general tropical Arthur–Selberg trace formula for GLₙ. The equality between affine Grassmannian min-plus convolution and W-invariant tropical Schur polynomials in four variables supplies the first formalized tropical spectral transform in the non-prime setting, directly supporting the priority open problem on tropical certified robustness by rigorously connecting Hecke eigenvalue spectra to piecewise-linear tropical geometry.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Tropical
Research mode: prove
