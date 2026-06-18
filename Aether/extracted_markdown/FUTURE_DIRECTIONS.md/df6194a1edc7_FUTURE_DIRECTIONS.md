# Future Directions: Min-Plus Harmonic Analysis

## Breakthrough Opportunities (ranked by impact)

### 1. Full Tropical Fourier Inversion (Fenchel-Moreau Theorem)

- **Theorem Statement**: For any proper lower semicontinuous convex function f : ℝⁿ → ℝ ∪ {+∞}, the double Legendre-Fenchel conjugate satisfies f**(x) = f(x) for all x.
- **Proof Strategy**:
  - **Approach A (Hahn-Banach Separation)**: If f(x₀) > f**(x₀), then (x₀, f**(x₀)) ∉ epi(f). Since epi(f) is closed convex, apply the Hahn-Banach separation theorem to obtain a separating hyperplane, which yields a dual variable ω with f*(ω) + ⟨ω, x₀⟩ < f(x₀), contradicting the definition of f**. Mathlib has `geometric_hahn_banach_closed_point`.
  - **Approach B (Epigraphical characterization)**: Show that epi(f**) = cl(conv(epi(f))) using Mathlib's convex hull and closure operations, then use that f is already closed convex.
  - **Approach C (Discrete finite-dimensional)**: For the finite case (Fin m), prove f̂̂ = f when f is the pointwise maximum of finitely many affine functions (tropical polynomial).
- **Why This Is Revolutionary**: Completes the identification of Legendre-Fenchel duality with tropical Fourier inversion. Every strong duality result in convex optimization becomes a Fourier inversion formula.
- **Catalog Leverage**: Build on `double_conjugate_le_general` (≤ direction already proved), `fenchel_young_discrete`, `idempotent_parseval`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 2. Tropical Uncertainty Principle (Finite Discrete Version)

- **Theorem Statement**: For f : Fin m → ℝ with row-normalized symmetric kernel W, define supp_ε(f) = {j : f(j) ≤ E(f) + ε} and supp_ε(f̂) similarly. Then |supp_ε(f)| · |supp_ε(f̂)| ≥ m for appropriate ε depending on the kernel.
- **Proof Strategy**:
  - **Approach A (Rank argument)**: The min-plus DFT matrix restricted to supp(f) × supp(f̂) must have full tropical rank. If |S|·|T| < m, the restricted matrix is tropically singular, contradicting the transform structure.
  - **Approach B (Energy method)**: Use Parseval to bound the energy on the complement of the support, then apply a counting argument.
  - **Approach C (Pigeonhole)**: For the DFT kernel W(j,k) = jk/m, show that the matrix entries on supp(f) × supp(f̂) must span enough values to cover all residues.
- **Why This Is Revolutionary**: First formal uncertainty principle in tropical mathematics. Direct application to certified robustness bounds for tropical neural networks.
- **Catalog Leverage**: `idempotent_parseval`, `spectral_support_mono`, `delta_transform_le`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 3. Tropical Wiener-Khinchin Theorem

- **Theorem Statement**: For f : Fin m → ℝ, define the tropical autocorrelation R_f(τ) = min_j [f(j) + f(j+τ)]. Then the min-plus transform of R_f equals 2·f̂, i.e., R̂_f(k) = 2·f̂(k).
- **Proof Strategy**: Direct computation. R̂_f(k) = min_τ min_j [f(j) + f(j+τ) + W(τ,k)]. Under appropriate kernel conditions, this equals min_j [f(j) + min_τ [f(j+τ) + W(τ,k)]] = min_j [f(j) + f̂(k)] = f̂(k) + f̂(k) (when the translation structure is compatible with W).
- **Why This Is Revolutionary**: Connects tropical time series analysis to spectral methods. Enables tropical spectral density estimation for scheduling and queuing networks.
- **Catalog Leverage**: `minPlusTransform_shift`, `minPlusTransform_const`, `inf'_add_const_left`
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 4. Tropical Shannon Entropy and Data Processing Inequality

- **Theorem Statement**: Define tropical entropy H_trop(f) = -E(f) = -min_j f(j). Then for any row-normalized kernel W (acting as a "tropical channel"), H_trop(f̂) = H_trop(f) (from Parseval). More generally, for a stochastic tropical channel T: H_trop(Tf) ≤ H_trop(f).
- **Proof Strategy**: The Parseval identity gives equality for row-normalized channels. For general channels (not necessarily row-normalized), show that min_k min_j [f(j) + T(j,k)] ≥ min_j f(j) when T has non-negative entries.
- **Why This Is Revolutionary**: Establishes foundations of tropical information theory, with applications to differential privacy (tropical noise) and secure computation.
- **Catalog Leverage**: `idempotent_parseval`, `idempotentEnergy_monotone`, `minPlusTransform_antitone`
- **Research Mode**: formalize
- **Estimated Depth**: 2

### 5. Tropical Convolution Theorem

- **Theorem Statement**: For f, g : Fin m → ℝ, define (f ⊛ g)(y) = min_x [f(x) + g(y-x)]. Then (f ⊛ g)^(k) = f̂(k) + ĝ(k) under the min-plus DFT kernel.
- **Proof Strategy**: Direct computation for the discrete case with appropriate group structure on Fin m (using modular arithmetic).
- **Why This Is Revolutionary**: Converts tropical convolution to pointwise addition in the frequency domain, enabling O(m²) computation of tropical convolutions via transform methods.
- **Catalog Leverage**: `minPlusTransform_shift`, `minPlusDFTKernel_symmetric`
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 6. Post-Quantum Security via Tropical Spectral Bounds

- **Theorem Statement**: For a lattice L ⊂ ℤⁿ, define the tropical theta function θ_L(ω) = min_{v ∈ L} ⟨ω, v⟩. Then the tropical spectral gap λ₁(θ̂_L) satisfies λ₁(θ̂_L) ≥ c · det(L)^{1/n} for a universal constant c.
- **Proof Strategy**: Use the min-plus DFT to relate the tropical theta function to lattice geometry, then apply Minkowski's convex body theorem in the tropical setting.
- **Why This Is Revolutionary**: Would provide new lower bounds for lattice problems relevant to post-quantum cryptographic security.
- **Catalog Leverage**: `tropical_lattice_dimension_bound`, `fenchel_young_discrete`
- **Research Mode**: discover
- **Estimated Depth**: 5

## Under-explored Territory

### Tropical Reproducing Kernel Hilbert Spaces
The tropical inner product ⟨f,g⟩_⊕ = max_x [f(x) + g(x)] (from the existing max-plus formalization) could support a tropical RKHS theory with applications to kernel methods in ML.

### Min-Plus Wavelets
Replace sine/cosine basis with piecewise-linear basis functions (tropical polynomials). The tropical wavelet transform would decompose functions into multi-scale tropical components.

### Tropical Sampling Theory
A tropical Nyquist theorem: if f is "band-limited" in the tropical sense (finite spectral support), how many samples suffice to reconstruct f?

### Idempotent Probability
Maslov measures (idempotent probability measures) replace ∫ with inf. The tropical Fourier transform of a Maslov measure is the tropical moment generating function. This connects to large deviations theory.

## Cross-Domain Bridges

1. **Tropical Harmonic Analysis ↔ Convex Optimization**: Every strong duality result is a tropical Fourier inversion. LP duality = tropical Parseval.
2. **Tropical Uncertainty ↔ Compressed Sensing**: The tropical uncertainty principle limits simultaneous sparsity in time and frequency, analogous to the restricted isometry property.
3. **Min-Plus Algebra ↔ Quantum Computing**: The tropical Fourier transform is the semiclassical limit of the quantum Fourier transform used in Shor's algorithm.
4. **Tropical Spectral Theory ↔ Graph Algorithms**: The min-plus DFT matrix eigenvalues relate to shortest-path structure in the complete graph.

## Open Problems Encountered

1. **Tropical Fourier Inversion for Non-Convex Functions**: What is the "convex envelope" interpretation of f̂̂ when f is not convex? Is it the largest tropically convex minorant?
2. **Tropical FFT**: Can the min-plus transform be computed in sub-quadratic time O(m log m) by exploiting structure in the DFT kernel?
3. **Tropical Uncertainty Constant**: What is the sharp constant in the tropical uncertainty principle? For the min-plus DFT kernel, is it exactly m?
4. **Infinite-Dimensional Parseval**: Does the Parseval identity extend to functions on infinite min-plus semimodules with appropriate topological hypotheses?
