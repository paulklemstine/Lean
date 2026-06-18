# Future Directions

## Synthesis

This research cycle established the **Spectral Pairing** as a novel algebraic structure axiomatizing the GL₁ Langlands correspondence. The key discovery is that the Jacobi symbol's properties — bilinearity, trichotomy, and quadratic reciprocity — can be cleanly separated into a set of axioms that capture the "shape-color duality" at the heart of class field theory. The spectral pairing framework revealed that reciprocity is not merely an identity but structural data: a ℤ/2ℤ-valued bilinear form (the reciprocity operator) that governs argument exchange.

The most promising cross-domain connection from this cycle links the **kernel theory** of spectral pairings to the **subgroup structure** studied in the Catalog's existing work on Galois obstructions (`Algebra/GaloisObstruction.lean`). The first kernel of the Jacobi spectral pairing at a prime p is exactly the quadratic residues mod p — a subgroup of index 2. For non-abelian extensions (GL₂ and beyond), the analogous "kernel" should be a more complex object: a representation-theoretic subgroup whose structure encodes the Langlands functoriality. This connection has the highest breakthrough potential because it could provide a concrete, computable bridge between the abelian (GL₁) and non-abelian (GL₂) Langlands programs.

The cycle's results also connect to the Catalog's `berggren_quadratic_form_invariant` through the bilinearity of the Jacobi symbol (both are multiplicative pairings taking values in {−1, 0, 1}), and to `galois_expressivity_degree_bound` through the Frobenius detector theorems (both use Galois-theoretic data to classify objects).

---

### Direction 1: Higher Spectral Pairings and Cubic Reciprocity

**Conjecture**: There exists a SpectralPairing-like structure over the Eisenstein integers ℤ[ω] (where ω = e^{2πi/3}) axiomatizing the cubic residue symbol, with reciprocity operator valued in {1, ω, ω²} rather than {−1, 1}. Specifically, define a CubicSpectralPairing as a map f : ℤ[ω] → ℤ[ω] → ℤ[ω] with values in {0, 1, ω, ω²}, multiplicativity in both arguments, and a cubic reciprocity law f(α, β) = R(α, β) · f(β, α) where R is a cube root of unity depending on the residue classes of α, β modulo (1 − ω)³.

**Test**: Verify the cubic reciprocity law computationally for all pairs of primary primes π, ρ in ℤ[ω] with norm up to 1000. For each pair, compute the cubic residue symbol (π/ρ)₃ and (ρ/π)₃ and verify that their ratio equals the predicted cubic reciprocity sign.

**Impact**: If the cubic SpectralPairing axioms are correct, they would extend the shape-color framework from GL₁ to a "GL₁ over ℤ[ω]" setting, providing the first formal axiomatization of cubic reciprocity as a structural object. This would be a concrete step toward higher reciprocity laws.

**Catalog References**: `Applications/LanglandsSpectrum.lean` (SpectralPairing definition), `Algebra/GaloisObstruction.lean` (Galois group structure)

**Proof Strategy**: (1) Define CubicSpectralPairing in Lean, extending SpectralPairing with ℤ[ω]-valued evaluations. (2) Construct the cubic residue symbol as an instance, using Mathlib's `GaussianInt` or custom Eisenstein integer formalization. (3) Prove the cubic reciprocity law as the reciprocity axiom, likely requiring significant new Mathlib infrastructure for cubic residue symbols.

**Domain Bridges**: Number Theory (reciprocity laws) ↔ Algebra (Eisenstein integers) ↔ Representation Theory (GL₁ over quadratic fields)

**Lineage**: Builds on this cycle's SpectralPairing definition and the Catalog's GL1LanglandsBilinear.lean

**Ambition**: grand_challenge

---

### Direction 2: Spectral Kernel Classification and Chebotarev

**Conjecture**: Two SpectralPairings with the same first kernel (i.e., {a : σ₁(a, p) = 1} = {a : σ₂(a, p) = 1} for all primes p) must be equal. In other words, the kernel determines the pairing. More precisely: if σ₁ and σ₂ are SpectralPairings such that for every prime p, σ₁(a, p) = 1 ⟺ σ₂(a, p) = 1 for all a, then σ₁ = σ₂.

**Test**: Construct two distinct SpectralPairings on small inputs (primes up to 50) and verify their kernels differ. Alternatively, verify that perturbing the Jacobi symbol at a single point changes the kernel at some prime.

**Impact**: This would establish a "uniqueness from kernels" theorem, analogous to how a linear functional is determined by its kernel. It would also connect to the Chebotarev density theorem, which says that the splitting behavior of primes in an extension determines the extension.

**Catalog References**: `Applications/LanglandsSpectrum.lean` (SpectralPairing.firstKernel), `Bridges/GaloisNeuralCorrespondence.lean` (Galois expressivity)

**Proof Strategy**: (1) Formalize the statement in Lean. (2) Show that the kernel at p determines σ(·, p) on units (since σ takes values in {−1, 0, 1}, and the kernel is the preimage of 1, knowing the kernel and the preimage of 0 determines the function). (3) Show the preimage of 0 is determined by gcd, which is independent of the pairing. (4) Conclude that the kernel determines σ at each prime, hence everywhere by multiplicativity.

**Domain Bridges**: Number Theory (Chebotarev) ↔ Algebra (spectral pairings) ↔ Machine Learning (kernel methods — the name is not coincidental!)

**Lineage**: Builds on this cycle's kernel theory (spectral_kernel_mul_closed, spectral_kernel_one)

**Ambition**: extension

---

### Direction 3: Spectral Pairings as Functors

**Conjecture**: The assignment d ↦ S_d (discriminant to splitting spectrum) defines a functor from the category of squarefree integers (with morphisms given by divisibility) to the category of multiplicative functions ℕ → {−1, 0, 1} (with morphisms given by pointwise comparison). Moreover, this functor preserves products: S_{d₁·d₂} = S_{d₁} · S_{d₂} (pointwise).

**Test**: Verify functoriality for all squarefree d₁, d₂ with |d₁|, |d₂| ≤ 30: check that S_{d₁·d₂}(p) = S_{d₁}(p) · S_{d₂}(p) for all primes p ≤ 100. Also check that if d₁ | d₂ (as squarefree integers), then the spectrum of d₂/d₁ is consistent with the ratio of spectra.

**Impact**: Establishing the categorical structure would connect the spectral pairing framework to the existing Catalog work on category-theoretic bridges (e.g., `Bridges/AlgebraEMLClosureComputation.lean`). It would also provide a clean framework for studying the "composition" of Langlands correspondences.

**Catalog References**: `Applications/LanglandsSpectrum.lean` (spectrum_product_compose, spectral_composition_assoc), `Bridges/AlgebraEMLClosureComputation.lean` (categorical structures)

**Proof Strategy**: (1) Define the source category (squarefree integers under multiplication, modulo squares). (2) Define the target category (multiplicative functions under pointwise product). (3) Construct the functor using `jacobiSym.mul_left`. (4) Prove functoriality (preservation of composition) using `spectral_composition_assoc`.

**Domain Bridges**: Number Theory (spectral pairings) ↔ Category Theory (functors) ↔ EML (algebraic max-closure, from `EML/AlgebraicMaxClosure.lean`)

**Lineage**: Builds on this cycle's spectrum_product_compose and spectral_composition_assoc

**Ambition**: extension

---

### Direction 4: GL₂ Spectral Matrix and Modularity

**Conjecture**: There exists a "GL₂ Spectral Matrix" M(E, p) for elliptic curves E over ℚ and primes p, where M(E, p) = p + 1 − #E(𝔽_p) (the trace of Frobenius). This matrix satisfies an analogue of the SpectralPairing axioms: (1) M(E₁ × E₂, p) relates to M(E₁, p) and M(E₂, p) via the product formula for L-functions. (2) The "reciprocity operator" is the functional equation of the L-function, which relates L(E, s) to L(E, 2−s). (3) The modularity theorem (Wiles) guarantees that each row of M is the Fourier coefficients of a weight-2 modular form.

**Test**: For the first 10 elliptic curves over ℚ (ordered by conductor), compute the GL₂ spectral matrix M(E, p) for primes p ≤ 100. Verify that the resulting sequences match the q-expansions of weight-2 newforms from the LMFDB database.

**Impact**: This would extend the spectral pairing framework from GL₁ (where the "spectrum" is a ±1-valued function) to GL₂ (where the "spectrum" is an integer-valued function satisfying the Hasse-Weil bound |a_p| ≤ 2√p). This is the natural next step in the Langlands program and would connect to the Catalog's existing work on elliptic curves and modular forms.

**Catalog References**: `Applications/LanglandsSpectrum.lean` (SpectralPairing), `Algebra/GaloisObstruction.lean` (Galois theory), `Cryptography/DiophantineCryptoCore.lean` (Diophantine equations)

**Proof Strategy**: (1) Define GL₂SpectralPairing in Lean, with evaluation map taking values in ℤ (not just {−1, 0, 1}). (2) Define the Hasse-Weil bound as an axiom. (3) Formalize the trace of Frobenius for specific elliptic curves (e.g., y² = x³ − x has conductor 32). (4) Verify computationally that the traces match modular form coefficients for small cases.

**Domain Bridges**: Number Theory (Langlands GL₂) ↔ Algebraic Geometry (elliptic curves) ↔ Analysis (modular forms) ↔ Cryptography (elliptic curve cryptography)

**Lineage**: Builds on this cycle's SpectralPairing and the Catalog's Galois obstruction theory

**Ambition**: grand_challenge

---

### Direction 5: Spectral Pairing Deformations and p-adic Langlands

**Conjecture**: The SpectralPairing axioms admit a continuous family of deformations parametrized by p-adic integers ℤ_p, where the Jacobi symbol is the "classical limit" (the value at the trivial character). Specifically, for each continuous p-adic character ψ : ℤ_p× → ℤ_p×, define σ_ψ(a, b) = ψ(a) · J(a, b). Then σ_ψ satisfies modified SpectralPairing axioms with a twisted reciprocity operator R_ψ(a, b) = ψ(a/b) · R(a, b).

**Test**: For p = 5, compute the deformed spectral pairing σ_ψ for the Teichmüller character ψ : (ℤ/5ℤ)× → ℤ₅× and verify that the modified reciprocity law holds for all pairs of odd integers up to 100.

**Impact**: p-adic deformations of the Langlands correspondence are at the frontier of current research (the p-adic Langlands program of Breuil, Colmez, Emerton). Formalizing even the GL₁ case would provide foundational infrastructure for this rapidly developing field.

**Catalog References**: `Applications/LanglandsSpectrum.lean`, `Computation/PadicValuationDepth.lean` (p-adic valuations)

**Proof Strategy**: (1) Formalize continuous p-adic characters using Mathlib's `PadicInt`. (2) Define the twisted spectral pairing σ_ψ. (3) Prove the modified reciprocity law by combining the classical reciprocity law with the multiplicativity of ψ.

**Domain Bridges**: Number Theory (p-adic Langlands) ↔ Analysis (p-adic analysis) ↔ Computation (p-adic arithmetic, from `Computation/PadicValuationDepth.lean`)

**Lineage**: Builds on this cycle's SpectralPairing and the Catalog's p-adic valuation theory

**Ambition**: grand_challenge
