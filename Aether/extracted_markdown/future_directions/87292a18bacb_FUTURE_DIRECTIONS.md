# Future Directions: Newton-Order Phase Diagnostics

## Synthesis

The theorem package established in this cycle creates a new bridge between algebraic combinatorics (Newton inequalities, log-concavity), asymptotic analysis (Toeplitz determinants, Filter.atTop), and quantum physics (SSH model, entanglement spectra). The five directions below form a coherent research program: Direction 1 completes the analytic backbone, Direction 2 extends horizontally to new physical systems, Direction 3 deepens the algebraic theory, Direction 4 connects to information theory, and Direction 5 reaches toward a grand unification with tropical geometry. Each direction builds on the proven theorems (bounded_newton_of_uniform_pinching_family, unbounded_of_frequently_ge_log, critical_toeplitz_implies_unbounded_newton) and the newly introduced structures (ToeplitzNewtonAsymptotic, SpectrallyPinchedFamily).

---

## Direction 1: Complete the Fisher–Hartwig Asymptotic for SSH

**Conjecture:** For the critical SSH model (δ = 0), the block correlation matrix Toeplitz symbol has a Fisher–Hartwig singularity of type V₀(θ) = |1 − e^{iθ}|^{2α} with α = 1/2, and the corresponding elementary symmetric polynomial profile satisfies:

$$\max_{1 \le k \le m-1} \left[\log e_{k-1}^{(m)} + \log e_{k+1}^{(m)} - 2\log e_k^{(m)}\right] \ge c \cdot \log m - b$$

for some c > 0 and all sufficiently large m.

**Test:** Numerically compute the SSH block correlation matrix for m up to 256 using high-precision arithmetic (mpmath). Extract eigenvalues, compute esymm via the stable recurrence, and fit the supremal Newton gap against log(m). A positive slope with statistical significance (p < 0.01) confirms the conjecture. Use Richardson extrapolation to estimate c.

**Impact:** Completing this would turn the conditional Theorem C into an unconditional result, giving the first purely algebraic proof that a quantum phase transition is detectable by symmetric polynomial curvature. This would be publishable in a top mathematical physics journal.

**Catalog References:** `Pythagorean/SSHNewtonOrder.lean` — `critical_toeplitz_implies_unbounded_newton`, `ToeplitzNewtonAsymptotic`

**Proof Strategy:** Formalize the Deift–Its–Krasovsky theorem on Fisher–Hartwig asymptotics for Toeplitz determinants. The key input is: for symbols with algebraic singularities, det(T_n(a)) has precise asymptotic form involving Barnes G-function and n^{α²}. Extract coefficient asymptotics by saddle-point analysis of the generating polynomial det(I + tC_m). This requires:
  1. A formalization of the Fisher–Hartwig formula (major undertaking)
  2. Coefficient extraction from parametric determinantal asymptotics
  3. Second-difference estimates from the coefficient profile

**Domain Bridges:** Toeplitz analysis ↔ algebraic combinatorics ↔ quantum information

**Lineage:** Extends `critical_toeplitz_implies_unbounded_newton` by establishing the hypothesis

**Ambition:** ★★★★★ (Grand Challenge — requires formalizing deep analytic number theory)

---

## Direction 2: Newton Diagnostics for Higher-Dimensional Free Fermions

**Conjecture:** For the Kitaev honeycomb model at its gapless phase boundary, the Newton order parameter of the correlation spectrum diverges logarithmically with subsystem size, with a scaling exponent c that depends on the number of Dirac cones in the dispersion.

**Test:** Implement the Kitaev honeycomb model correlation matrix for rectangular subsystems of size m × n on the honeycomb lattice. Compute Newton gap profiles for m up to 32 at the isotropic point (J_x = J_y = J_z). Compare the growth rate c with the SSH value and with the central charge of the underlying CFT.

**Impact:** Would establish Newton diagnostics as a universal tool for free-fermion criticality in any dimension, not just 1D. The dependence of c on the Dirac cone count would connect the algebraic invariant to the topology of the Fermi surface.

**Catalog References:** `Pythagorean/SSHNewtonOrder.lean` — `bounded_newton_of_uniform_pinching_family`, `SpectrallyPinchedFamily`

**Proof Strategy:** The gapped case generalizes directly via SpectrallyPinchedFamily (the pinching theorem is dimension-independent). For the critical case, replace the 1D Toeplitz structure with a higher-dimensional Toeplitz analogue (block Toeplitz with Toeplitz blocks) and extend the Fisher–Hartwig analysis to multivariate symbols.

**Domain Bridges:** Condensed matter physics ↔ algebraic combinatorics ↔ multivariate Toeplitz theory

**Lineage:** Horizontal extension of SSH results to higher dimensions

**Ambition:** ★★★★☆ (Substantial — requires 2D free-fermion numerics and new Toeplitz theory)

---

## Direction 3: Tropical Newton Gaps and Lorentzian Polynomial Theory

**Conjecture:** The supremal Newton gap of a sequence (e₀, ..., eₘ) is related to the tropical curvature of the Newton polytope of the generating polynomial ∑ eₖ tᵏ. Specifically, for Lorentzian polynomials (in the sense of Brändén–Huh), the Newton gap is nonpositive everywhere, and the tropical curvature is nonneg. For "nearly Lorentzian" polynomials with small positive gaps, the tropical curvature develops saddle points whose magnitudes control the gap.

**Test:** For random polynomials with prescribed Newton polytopes, compute both the Newton gap profile and the tropical curvature of the amoeba complement. Establish empirical correlation. For SSH-type polynomials det(I + tC_m), compare the tropical discriminant with the maximizing index k*(m).

**Impact:** Would connect the Newton phase diagnostic to the rapidly developing Lorentzian polynomial theory, potentially yielding new characterizations of "almost log-concave" sequences relevant to combinatorics, algebraic geometry, and optimization.

**Catalog References:** `Pythagorean/SSHNewtonOrder.lean` — `pointwiseNewtonGap`, `supNewtonGap`; `Catalog/Pythagorean/NewtonErosion.lean` — `minkowskiErosion`

**Proof Strategy:** Use the fact that for Lorentzian polynomials, log-concavity follows from the Hodge–Riemann relations. Quantify the failure of these relations when the polynomial is "near the boundary" of the Lorentzian cone. Connect via the Alexandrov–Fenchel inequality to mixed volume estimates.

**Domain Bridges:** Tropical geometry ↔ algebraic combinatorics ↔ convex geometry ↔ quantum physics

**Lineage:** Builds on `NewtonErosion.lean` and connects to Lorentzian polynomial foundations

**Ambition:** ★★★★★ (Grand Challenge — bridges three deep mathematical areas)

---

## Direction 4: Newton Gaps as Information-Theoretic Observables

**Conjecture:** The supremal Newton gap of correlation eigenvalues is equivalent, up to bounded multiplicative constants, to the second derivative of the Rényi entropy S_α at α = 1 (von Neumann entropy) with respect to the Rényi parameter α. That is, ∂²S_α/∂α² |_{α=1} ~ supNewtonGap up to O(1) corrections.

**Test:** For SSH eigenvalue spectra at various m and δ, compute both S_α for α ∈ [0.5, 2] (numerical differentiation) and the Newton gap. Plot the correlation. For the critical case, check whether ∂²S_α/∂α² also diverges logarithmically.

**Impact:** Would give the Newton gap a direct information-theoretic interpretation: it measures the *curvature* of the entropy as a function of the Rényi parameter. This would connect the algebraic diagnostic to operational quantities in quantum information (channel capacities, state discrimination).

**Catalog References:** `Pythagorean/SSHNewtonOrder.lean` — all main theorems; `Catalog/Pythagorean/NewtonEntropyHierarchy.lean` — `renyiEntropy`, `fermionEntropy`

**Proof Strategy:** Express eₖ in terms of moments via Newton–Girard, then relate the Newton gap to derivatives of the moment-generating function. Use the Rényi entropy representation S_α = (1/(1-α)) log Tr(ρ^α) = (1/(1-α)) log ∑ f_α(λᵢ) and expand around α = 1.

**Domain Bridges:** Information theory ↔ algebraic combinatorics ↔ quantum thermodynamics

**Lineage:** Extends `NewtonEntropyHierarchy.lean` entropy results

**Ambition:** ★★★☆☆ (Solid extension — mostly analysis and computation)

---

## Direction 5: Newton Diagnostics for Determinantal Point Processes

**Conjecture:** For a determinantal point process (DPP) on a compact space with kernel K having eigenvalues λ₁, ..., λₘ, the supremal Newton gap of the marginal probabilities (which are elementary symmetric polynomials of the kernel eigenvalues) quantifies the *effective repulsion strength* of the DPP. For Poisson-like DPPs (weak repulsion, all λᵢ ≈ p), the gap is bounded; for strongly repulsive DPPs (eigenvalues spanning [0,1]), the gap grows with the number of points.

**Test:** Compare Newton gaps for:
1. Uniform DPPs (λᵢ = p for all i) — expect bounded gap
2. Projection DPPs (λᵢ ∈ {0, 1}) — expect maximal gap
3. GUE eigenvalue DPPs — expect intermediate, potentially logarithmic growth
4. Zeros of the Riemann zeta function (conjectured DPP structure)

**Impact:** Would establish a new repulsion measure for point processes, complementing existing measures (pair correlation function, nearest-neighbor spacing). Could yield new results in random matrix theory by connecting spectral statistics to symmetric polynomial curvature.

**Catalog References:** `Pythagorean/SSHNewtonOrder.lean` — `SpectrallyPinchedFamily`, `bounded_newton_of_uniform_pinching_family`

**Proof Strategy:** For projection DPPs, eₖ = C(n, k) (binomial coefficients) and the Newton gap is exactly computable: log C(n,k-1) + log C(n,k+1) - 2 log C(n,k) = log((k²)/((n-k+1)(n-k-1)·...)), which grows like log(n) for k ≈ n/2. For GUE, use the Heine identity det(x_i^{j-1}) to relate the DPP kernel to Toeplitz/Hankel determinants.

**Domain Bridges:** Probability theory ↔ random matrix theory ↔ algebraic combinatorics ↔ number theory

**Lineage:** New application of the SpectrallyPinchedFamily framework to probabilistic models

**Ambition:** ★★★★☆ (Substantial — connects to deep questions in RMT and analytic number theory)
