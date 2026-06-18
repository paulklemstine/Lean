Prove that the min-plus tropical spherical Hecke algebra for GL₃ is canonically isomorphic to the ring of S₃-invariant tropical Laurent polynomials on the A₂ coweight lattice, with the tropical Satake transform sending each double-coset basis element to the corresponding tropical Schur polynomial.

**Theorem statement.** Formalize and prove the following.

```lean
import Mathlib
import Tropical.Core.TropicalFactoring
import Tropical.Langlands.ArthurSelbergGL2
import Tropical.Langlands.SatakeIsomorphism

open Tropical

variable {F : Type*} [LocalField F] (O : ValuationSubring F)

/-- Min-plus tropical spherical Hecke algebra H_trop(GL₃(F)//GL₃(O)). -/
noncomputable abbrev TropHeckeGL3 :=
  TropicalSphericalHeckeAlgebra (GL (Fin 3) F) (GL (Fin 3) O)

/-- S₃-invariant tropical Laurent polynomials on the A₂-coweight lattice
    {v : Fin 3 → ℤ | v 0 + v 1 + v 2 = 0} with min-plus addition. -/
noncomputable abbrev TropInvLaurentGL3 :=
  InvariantTropicalLaurent
    {v : Fin 3 → ℤ // ∑ i, v i = 0}
    (Equiv.Perm (Fin 3))

theorem tropical_satake_isomorphism_GL3 :
    ∃ (S : TropHeckeGL3 O ≃ TropInvLaurentGL3),
      IsTropicalSatakeTransform S ∧
      (∀ λ_dom : DominantCoweight (Fin 3),
        S (tropicalHeckeBasis λ_dom) =
          tropicalSchurPolynomial λ_dom) := by
```

**Proof strategy.**

1. *Tropicalize the Gindikin–Karpelevich integral for the (2,1) maximal parabolic.* Decompose GL₃ via Iwasawa and write the tropical Satake transform of a double-coset basis element c_λ as a min-plus integral over the 2-dimensional unipotent radical U_{2,1}(F). Apply `tropical_trace_formula_GL2` (ArthurSelbergGL2.lean) to evaluate the GL₂-block contribution, which yields a min over the GL₂ coweight sub-lattice. Then invoke `tropical_lattice_min_max` (TropicalFactoring.lean) to merge the remaining additive root contribution into a single min expression over the full A₂ coweight lattice. The key lemma is `Finset.sum_tropical` to interchange the finite Weyl-group sum with the tropical integral.

2. *Establish S₃-invariance via the tropical Harish-Chandra c-function.* Show that the image of S is symmetric under the dot-action of S₃ on A₂-coweights by proving invariance under the simple reflections s₁ and s₂ separately. For each, use `Equiv.Perm.smul_def` and `Finsupp.mapDomain` to track how permuting the three tropical Satake parameters affects the min-plus monomial expansion. Control the local zeta integrals using `tropical_trace_formula_prime` (SatakeIsomorphism.lean), which guarantees that the tropicalization of the unramified principal series character is additive and hence lands in the S₃-invariant subring. The Mathlib workhorse is showing that the tropical c-function c^{trop}(λ) = min_{w∈S₃} ⟨wλ, ρ⟩ is unchanged under W via `Equiv.Perm.sum_mul`.

3. *Identify the Hecke basis with the tropical Schur basis.* Compute the tropical Hall polynomial for GL₃ explicitly: the min-plus convolution c_λ ⋆ c_μ equals the tropical Schur polynomial s_{λ+μ}^{trop} plus lower-order min terms governed by the tropicalized Littlewood–Richardson coefficients. Use `tropical_trace_formula_prime` to identify the q→0 limit of the classical Hall polynomial coefficients with the min over Gelfand–Tsetlin pattern weights. Then apply `Finset.inf_image` and `tropical_lattice_min_max` to collapse that min into the tropical Schur polynomial `tropicalSchurPolynomial λ_dom`, completing the isomorphism.

**Why this matters.** This result is the first machine-verified tropical Satake isomorphism in rank greater than 1. It lifts the 22 verified GL₂ theorems—especially `tropical_trace_formula_GL2` and `tropical_trace_formula_prime`—to the critical GL₃ case, providing the foundation for a formalized tropical Langlands correspondence. The tropical Schur identification is precisely the algebraic ingredient needed for the geometric trace formula in GL₃ and for tropical certified robustness of neural networks (a priority open problem), because it rigorously connects min-plus Hecke operators to piecewise-linear combinatorics in a way that Lean can verify natively.

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
