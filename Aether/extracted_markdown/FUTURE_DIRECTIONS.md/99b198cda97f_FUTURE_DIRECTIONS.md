# Future Research Directions: Conformal Spectral Transfer

## Synthesis

This cycle established the **Conformal Spectral Transfer** framework — a formal mathematical structure capturing how Laplacian eigenvalues transform under conformal maps between Riemannian manifolds. The central discovery is that conformal Laplacian eigenvalues on S^n are "almost perfect squares" (offset by exactly 1/4), and that the Yamabe correction n(n-2)/4 is uniquely determined by a spectral rigidity condition involving consecutive perfect squares. The hyperbolic spectral connection theorem (n(n-2)/4 + n/2 = (n/2)²) provides a clean algebraic bridge between spherical and hyperbolic geometry.

The most promising cross-domain connection is between the spectral rigidity theorem and number theory. The condition that 4C+1 and 4(n+C)+1 be perfect squares with roots differing by 2 is essentially a Pell-type equation. This connects conformal geometry to the arithmetic of quadratic forms, suggesting that the "almost perfect square" structure of conformal eigenvalues has deeper number-theoretic content than previously recognized. The Weyl law ∑(2i+1) = (L+1)² is itself a statement about sums of odd numbers — the most basic arithmetic identity — appearing here in a geometric context.

The framework naturally extends in several directions: to non-compact symmetric spaces (hyperbolic spaces, de Sitter space), to higher-order GJMS operators (which have conformal covariance analogous to the Yamabe operator but at higher polynomial degree), and to the full L² isometry theorem requiring measure-theoretic machinery.

---

### Direction 1: Spectral Rigidity of Higher GJMS Operators

**Conjecture**: For the k-th GJMS operator P_{2k} on S^n, the eigenvalues satisfy a "degree-k almost polynomial" identity:

  λ_l^{(k)} = ∏_{j=0}^{k-1} (l + (n-1)/2 + j)(l + (n-1)/2 - j) · (-1)^k · correction

where the correction is a polynomial in n of degree 2k determined by a higher-order spectral rigidity condition. For k=1 this reduces to our almost-square formula. For k=2, the GJMS operator is the Paneitz operator, and the conjecture predicts a "almost biquadratic" formula.

**Test**: Compute the eigenvalues of the Paneitz operator on S^n explicitly: they are ∏_{j=0}^{1} (l + (n-1)/2 + j)(l + (n-1)/2 - j - 1) = (l+(n-1)/2)(l+(n-1)/2 - 1)(l+(n-1)/2 + 1)(l+(n-1)/2) = ... Verify for n=4, l=0,1,2 against known Paneitz eigenvalues.

**Impact**: Would extend spectral rigidity from the Yamabe operator to the full GJMS hierarchy, connecting conformal geometry to higher-order PDEs and the theory of Q-curvature.

**Catalog References**: `Geometry/StereographicFourier/Defs.lean` (conformal_eigenvalue_almost_square, yamabe_correction_unique_square)

**Proof Strategy**: 
1. Define the k-th GJMS eigenvalue on S^n as ∏_{j=0}^{k-1} (l+j)(l+n-1-j)
2. Show this equals a polynomial in (l + (n-1)/2) plus lower-order correction
3. Prove the correction is uniquely determined by requiring it to factor over ℤ[(n-1)/2]
4. Verify computationally for k=2 (Paneitz) and k=3

**Domain Bridges**: Conformal Geometry <-> Algebraic Combinatorics (via factored polynomial identities), Conformal Geometry <-> Number Theory (via algebraic integer conditions on corrections)

**Lineage**: Builds on conformal_eigenvalue_almost_square and yamabe_correction_unique_square from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Conformal Spectral Transfer for de Sitter Space

**Conjecture**: There exists a "Lorentzian conformal spectral transfer" for de Sitter space dS^n that maps the discrete series representations of SO(1,n) to tempered distributions on ℝ^{n-1}, with a spectral shift of (n-1)(n-3)/4 (the Lorentzian Yamabe correction). The shift vanishes in dimension n=3 (2+1 dimensions), which is the critical dimension for conformal field theory.

**Test**: For dS^3 (n=3), compute the Yamabe correction: 3·1/4 = 3/4 ≠ 0. Wait — de Sitter dS^n has dimension n, so the Yamabe correction should use n-1 for the spatial dimension. For dS^3 with spatial dimension 2: correction = 2·0/4 = 0. Verify this matches the known conformal invariance of the wave equation in 2+1 dimensions.

**Impact**: Would provide a rigorous framework for the spectral theory of quantum fields on de Sitter space, relevant to inflationary cosmology. The vanishing of the Lorentzian Yamabe correction in 2+1 dimensions would give a new proof of the conformal invariance of the 3D wave equation.

**Catalog References**: `Geometry/StereographicFourier/Defs.lean` (ConformalSpectralTransfer structure, yamabe_correction_vanishes_dim2), `Geometry/StereographicNeuralField.lean` (conformal_weight_pos)

**Proof Strategy**:
1. Define the Lorentzian conformal factor for the embedding dS^n ↪ ℝ^{1,n}
2. Compute the Lorentzian Yamabe correction as the scalar curvature contribution
3. State and prove the analogue of conformal_eigenvalue_almost_square
4. Prove the vanishing theorem for the critical dimension

**Domain Bridges**: Conformal Geometry <-> Mathematical Physics (de Sitter quantum field theory), Spectral Theory <-> Representation Theory (discrete series of SO(1,n))

**Lineage**: Direct extension of the ConformalSpectralTransfer structure to the Lorentzian setting.

**Ambition**: grand_challenge

---

### Direction 3: The Plancherel Isometry via Mathlib Measure Theory

**Conjecture**: Using Mathlib's MeasureTheory library, one can formally prove that the stereographic Fourier transform

  T(f)(k) = ∫_{ℝ^n} f(φ^{-1}(y)) · W_n(|y|²)^{1/2} · e^{-2πi y·k} dy

is an isometry from L²(S^n, σ) to L²(ℝ^n, λ), where σ is the round measure on S^n and λ is Lebesgue measure.

**Test**: Verify the Plancherel identity ‖T(f)‖² = ‖f‖² for f = Y₁⁰ (the first spherical harmonic) on S² by computing both sides explicitly.

**Impact**: Would be the first formal verification of a non-trivial spectral isometry in a geometric setting, bridging Mathlib's measure theory with conformal geometry.

**Catalog References**: `Geometry/StereographicFourier/Defs.lean` (plancherelWeight, plancherel_weight_pos, plancherel_weight_inversion)

**Proof Strategy**:
1. Define the stereographic measure μ_n on ℝ^n as W_n · λ
2. Prove μ_n is a finite measure with total mass = vol(S^n)
3. Show the stereographic Fourier transform intertwines the sphere and Euclidean L² structures
4. Use the Plancherel theorem for the classical Fourier transform to deduce the spherical version

**Domain Bridges**: Conformal Geometry <-> Measure Theory (via Mathlib's MeasureTheory.Measure.MeasureSpace), Analysis <-> Geometry (via the Plancherel theorem)

**Lineage**: Builds on plancherel_weight_pos and plancherel_weight_inversion from this cycle.

**Ambition**: extension

---

### Direction 4: Spectral Zeta Function and the Universal 1/4

**Conjecture**: The spectral zeta function of the conformal Laplacian on S^n,

  ζ_n(s) = Σ_{l=0}^∞ m_l / ((l + (n-1)/2)² - 1/4)^s

has a meromorphic continuation to ℂ with a simple pole at s = n/2 whose residue encodes vol(S^n). The universal 1/4 shift ensures that the zeta function has no pole at s = 1 when n ≥ 3 (corresponding to the absence of a zero-mode obstruction).

**Test**: For n=2, compute ζ_2(s) = Σ_{l=0}^∞ (2l+1) / (l(l+1))^s = Σ_{l=1}^∞ (2l+1)/(l(l+1))^s (excluding l=0 where the eigenvalue vanishes). Verify the pole at s=1 has residue 2 = vol(S²)/(2π). For n=3, compute ζ_3(s) = Σ_{l=0}^∞ (l+1)² / ((l+1)² - 1/4)^s and verify the pole at s=3/2.

**Impact**: Connects the conformal spectral transfer to analytic number theory and the theory of spectral invariants. The universal 1/4 shift would appear as a regularization parameter in the zeta function, giving a geometric interpretation of zeta function regularization in quantum field theory.

**Catalog References**: `Geometry/StereographicFourier/Defs.lean` (conformal_eigenvalue_almost_square, multiplicity_dim2, weyl_law_dim2)

**Proof Strategy**:
1. Define the partial zeta function ζ_n^L(s) = Σ_{l=0}^L m_l · μ_l^{-s}
2. Use the Weyl law (proved in this cycle) to establish the abscissa of convergence
3. Prove the residue formula using the leading asymptotics of m_l
4. Show the 1/4 shift removes the l=0 singularity for n ≥ 3

**Domain Bridges**: Conformal Geometry <-> Analytic Number Theory (spectral zeta functions), Physics <-> Number Theory (zeta function regularization)

**Lineage**: Builds on conformal_eigenvalue_almost_square, multiplicity_dim2, and weyl_law_dim2 from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Spectral Transfer

**Conjecture**: There exists a "tropical conformal spectral transfer" where eigenvalues are replaced by tropical eigenvalues (max-plus algebra), the Yamabe correction becomes a tropical polynomial, and the spectral rigidity theorem has a tropical analogue involving tropical quadratic forms. Specifically, the tropical analogue of the almost-square identity should be:

  max(l + (n-1)/2, 0) ⊕ max(l + (n-1)/2, 0) ⊖ max(1/4, 0) = max(l, 0) ⊗ max(l + n - 1, 0) ⊕ max(n(n-2)/4, 0)

where ⊕ = max, ⊗ = +, ⊖ = - in the tropical semiring.

**Test**: Evaluate both sides for n=3, l=2: LHS = max(3.5, 3.5) - 0.25 = 3.25. RHS = max(2, 4) + 0.75 = 4.75. These are not equal in the tropical sense, so the naive tropicalization fails. Find the correct tropical analogue.

**Impact**: Would bridge conformal geometry with tropical geometry, potentially connecting sphere spectral theory to tropical algebraic curves.

**Catalog References**: `Tropical/Geometry/Hypersurface.lean` (tropical geometry foundations), `Geometry/StereographicFourier/Defs.lean` (spectral transfer structure)

**Proof Strategy**:
1. Define the tropical spectral data structure
2. Find the correct tropicalization of the almost-square identity (likely involves the Newton polygon of the eigenvalue polynomial)
3. Prove tropical spectral rigidity
4. Connect to tropical Hodge theory

**Domain Bridges**: Conformal Geometry <-> Tropical Geometry (via tropicalization of spectral data), Algebra <-> Geometry (via tropical semirings)

**Lineage**: New direction connecting this cycle's spectral transfer to the existing tropical geometry in the Catalog.

**Ambition**: grand_challenge
