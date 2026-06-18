**Mode:** `prove`

**Theorem (Tropical Satake Isomorphism for GL₃).** Let $F$ be a non-archimedean local field with uniformizer $\pi$ and valuation ring $\mathcal O$. Let $G = \mathrm{GL}_3(F)$ and $K = \mathrm{GL}_3(\mathcal O)$. Define the *tropical spherical Hecke algebra* $\mathcal H_{\mathrm{trop}}(G,K)$ as the semiring of compactly-supported functions $f : K\backslash G/K \to \mathrm{Trop}(\mathbb R)$ equipped with min-plus convolution
$$(f \circledast g)(z) = \min_{x,y \in K\backslash G/K} \bigl(f(x) + g(y) + \delta_{\mathrm{trop}}(x\cdot y,z)\bigr),$$
where $\delta_{\mathrm{trop}}$ is the tropicalized indicator of the double-coset multiplication. Let $S_3$ act on $\mathrm{Trop}(\mathbb R)[x_1^{\pm 1},x_2^{\pm 1},x_3^{\pm 1}]$ by permuting variables and let $\mathcal S_{\mathrm{trop}}^{S_3}$ denote the invariant subsemiring. For a dominant coweight $\lambda = (\lambda_1 \ge \lambda_2 \ge \lambda_3)$, let $\mathbf 1_{K\lambda(\pi)K}$ be the double-coset indicator and let $s_\lambda^{\mathrm{trop}}$ be the tropical Schur polynomial obtained by tropicalizing the Jacobi–Trudi determinant.

Prove that the tropical Satake transform
$$\mathcal S_{\mathrm{trop}} : \mathbf 1_{K\lambda(\pi)K} \longmapsto s_\lambda^{\mathrm{trop}}(x_1,x_2,x_3)$$
extends to an isomorphism of semirings $\mathcal H_{\mathrm{trop}}(G,K) \simeq^{+,\times} \mathcal S_{\mathrm{trop}}^{S_3}$, and that for the three fundamental coweights $\omega_1 = (1,0,0)$, $\omega_2 = (1,1,0)$, $\omega_3 = (1,1,1)$ the images are precisely the tropical elementary symmetric Laurent polynomials $e_1^{\mathrm{trop}}, e_2^{\mathrm{trop}}, e_3^{\mathrm{trop}}$.

**Target Lean 4 signature:**
```lean
import Mathlib

variable {F : Type*} [LocalField F] (π : Uniformizer F) (O : ValuationSubring F)

noncomputable def TropicalSphericalHeckeAlgebraGL3 : Type _ :=
  { f : GL (Fin 3) F → Tropical ℝ // Finsupp.IsCompactSupport f ∧
    ∀ k₁ k₂ x, f (k₁ * x * k₂) = f x }

noncomputable def tropicalSatakeTransform
  (f : TropicalSphericalHeckeAlgebraGL3 F π O) :
  { p : MvPolynomial (Fin 3) (Tropical ℝ) // p.IsSymmetric } := sorry

theorem satake_gl3_tropical_iso :
  ∃ φ : TropicalSphericalHeckeAlgebraGL3 F π O ≃+*
      { p : MvPolynomial (Fin 3) (Tropical ℝ) // p.IsSymmetric },
    (∀ λ : DominantCoweight (Fin 3),
      φ (doubleCosetIndicator λ) = tropicalSchurPolynomial λ) ∧
    φ (doubleCosetIndicator ⟨1,0,0⟩) = tropicalESymm 1 ∧
    φ (doubleCosetIndicator ⟨1,1,0⟩) = tropicalESymm 2 ∧
    φ (doubleCosetIndicator ⟨1,1,1⟩) = tropicalESymm 3 := by
```

**Proof strategy:**

1. **Parametrize double cosets via the Cartan decomposition.** Show that every $g \in \mathrm{GL}_3(F)$ factorizes as $k_1 \cdot \mathrm{diag}(\pi^{\lambda_1},\pi^{\lambda_2},\pi^{\lambda_3}) \cdot k_2$ with $k_i \in K$ and $\lambda_1 \ge \lambda_2 \ge \lambda_3$. Formalize this using Smith normal form over the DVR $\mathcal O$ (`Mathlib.LinearAlgebra.FreeModule.PID.smith_normal_form` or equivalently `Matrix.GeneralLinearGroup.exists_diagonal_cartan`) and read off the elementary divisors with `padic_val_nat` (or the generic valuation on the Dieudonné determinant). This identifies the Hecke basis with dominant coweights. Use `Finsupp.support` and `Finset.image` to prove that the min-plus convolution of two basis indicators is a finite minimum over a finite set of intermediate coweights, giving the Hecke algebra a well-defined semiring structure.

2. **Construct tropical Schur polynomials by tropicalizing Jacobi–Trudi.** For a $3$-part partition $\lambda$, define $s_\lambda^{\mathrm{trop}} = \mathrm{trop}\bigl(\det(e_{\lambda_i - i + j})_{1\le i,j\le 3}\bigr)$. Push `trop` past the determinant using `Matrix.det` over the tropical semiring together with `Tropical.trop_add` (pass through `OrderDual` to convert the built-in max-plus semiring into the min-plus setting) and `Tropical.trop_mul` (which yields ordinary addition). The sign factors from the classical determinant expansion are encoded via `Equiv.Perm.sign`. Show that the resulting piecewise-linear function is $S_3$-invariant by applying `MvPolynomial.isSymmetric` after symmetrizing over the Weyl group orbit with `Equiv.Perm.sumCongr`.

3. **Match tropical structure constants and prove bijectivity.** The classical product $\mathbf 1_{K\lambda K} * \mathbf 1_{K\mu K} = \sum_\nu c^\nu_{\lambda,\mu}(q)\,\mathbf 1_{K\nu K}$ is governed by Hall polynomials. Tropicalize this identity: replace $q$ by its valuation $1$, replace addition by $\min$, and multiplication by $+$, to obtain the tropical Hall coefficients. Prove that these coincide with the tropical Littlewood–Richardson coefficients governing the min-plus product $s_\lambda^{\mathrm{trop}} \otimes s_\mu^{\mathrm{trop}}$ in the invariant Laurent polynomial semiring; use `Finset.sum_image` to organize the finite sums over the Weyl group, and invoke `AddMonoidAlgebra` with a custom multiplication to encode the convolution. Bijectivity follows because the transition matrix between the double-coset basis $\{\mathbf 1_{K\lambda K}\}$ and the monomial basis in $\{e_i^{\mathrm{trop}}\}$ is upper unitriangular with respect to the dominance order on coweights; conclude by induction using the unitriangularity lemmas in `Mathlib.LinearAlgebra.Matrix.Unitriangular`.

**Why this matters.** This theorem establishes the tropical Satake correspondence for a reductive group of semisimple rank $2$. It is the critical inductive step beyond the rank-$1$ (GL₂) tropical Hecke algebra that appears in our catalog as a priority open problem. In rank $2$, the tropical Littlewood–Richardson rule is genuinely non-abelian, the associated Bruhat–Tits building is $2$-dimensional, and the local trace formula acquires both elliptic and non-elliptic orbital integrals. Proving the isomorphism for GL₃ therefore demonstrates that tropical geometry faithfully captures the representation theory of the dual group in a setting where novel geometric phenomena appear, closes the first step toward general GL$_n$, and provides the tropical trace formula equality required to connect our tropical certified robustness framework to Langlands-theoretic security reductions.

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

Research domain: Speculative
Research mode: prove
