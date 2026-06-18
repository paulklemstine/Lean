# Future Directions: Motivic Persistence Spectrum

## Synthesis

The motivic persistence spectrum establishes a rigorous formal corridor between three mathematical domains: arithmetic geometry (Frobenius eigenvalues, Weil zeta functions), signal processing (Prony reconstruction, Hankel analysis), and topological data analysis (persistence-type rank profiles). All five core theorems have been machine-verified, creating a trusted foundation for extending the framework in several directions. The directions below form a coherent research program: Direction 1 extends the persistence invariant to capture finer spectral information (slopes); Direction 2 scales the theory to families; Direction 3 connects to deep number-theoretic conjectures via random matrix theory; Direction 4 bridges to inverse problems and engineering applications; Direction 5 targets the ultimate goal of motivic decomposition. Each direction is falsifiable, computationally testable, and grounded in the formally verified catalog theorems.

---

## Direction 1: p-adic Slope Detection via Weighted Persistence Profiles

**Conjecture:** For a variety $X/\mathbf{F}_q$ with $q = p^a$, define a *weighted Hankel profile* using the $p$-adic filtration:

$$H_n^{(w)}(a)(i,j) = p^{-v_p(a(i+j))} \cdot a(i+j)$$

where $v_p$ is the $p$-adic valuation. The rank profile of $H_n^{(w)}$ detects the Newton polygon slopes of the Frobenius characteristic polynomial, not just the number of eigenvalues.

**Test:** Implement the weighted Hankel profile for supersingular and ordinary elliptic curves over $\mathbf{F}_{p^2}$. Supersingular curves have all slopes $= 1/2$; ordinary curves have slopes $0$ and $1$. The weighted profile should distinguish these cases even when the unweighted profile (which only detects $m=2$) does not.

**Impact:** This would give the first persistence-type invariant that captures slope data — the arithmetic analogue of "detecting the number of bars at each filtration level" in classical persistence. It would connect the Hankel framework directly to the Newton polygon and crystalline cohomology.

**Catalog References:** `Speculative/MotivicPersistence.lean` — `hankelRank_eq_of_injective`, `hankelRankProfile_mono`

**Proof Strategy:** Define the weighted Hankel matrix formally, prove the analogue of the Vandermonde factorization with $p$-adic weights, and show that the weighted rank detects slope multiplicities via a filtered version of the Vandermonde determinant.

**Domain Bridges:** Arithmetic geometry ↔ $p$-adic Hodge theory ↔ persistence theory

**Lineage:** Direct extension of Theorem 2 (Hankel rank bounds) and the Vandermonde factorization.

**Ambition:** 🔬 Solid extension — builds directly on proven infrastructure with computable predictions.

---

## Direction 2: Relative Persistence for Families of Varieties

**Conjecture:** For a family of varieties $\{X_t\}_{t \in S}$ over a base scheme $S$, the map $t \mapsto \mathrm{hankelRankProfile}(\mathrm{powerSumSignal}(X_t))$ is a constructible function on $S$. The loci where the profile jumps correspond to loci of geometric interest (e.g., special fibers, degeneration loci, isogeny classes).

**Test:** Compute the persistence profile for the universal family of elliptic curves $y^2 = x^3 + ax + b$ over $\mathbf{F}_p$ as $(a,b)$ vary. Map the profile to a 2D image. The contour lines should align with the supersingular/ordinary dichotomy and with isogeny classes.

**Impact:** This would create a "persistence landscape" for arithmetic families, analogous to persistence landscapes in TDA. It would provide a new computational tool for detecting geometric structure in moduli spaces.

**Catalog References:** `Speculative/MotivicPersistence.lean` — `persistenceProfile_detects_spectral_order`, `powerSums_determine_charpoly`

**Proof Strategy:** Use the formal identifiability theorem (Theorem 3) to show that the persistence profile is constant on isogeny classes. Use semicontinuity of rank to prove constructibility. The key new ingredient is a family version of the Vandermonde factorization.

**Domain Bridges:** Arithmetic geometry ↔ algebraic geometry of moduli spaces ↔ computational statistics

**Lineage:** Extension of the separation theorem (Theorem 4) from individual spectra to parametrized families.

**Ambition:** 🔭 Grand challenge — requires extending the formal framework to families, but the basic building blocks are in place.

---

## Direction 3: Random Matrix Statistics for Persistence Profiles

**Conjecture:** In a natural random family of varieties (e.g., hyperelliptic curves of genus $g$ over $\mathbf{F}_q$ as $q \to \infty$), the persistence profile of a generic member equals the "expected" profile (monotone staircase stabilizing at $2g$), and deviations from this profile are governed by random matrix statistics (specifically, the distribution of singular values of random Hankel matrices converges to a distribution related to the Tracy-Widom law).

**The key insight is** that the Frobenius eigenvalues of random curves distribute according to the Katz-Sarnak philosophy (matching random matrix ensembles), and this statistical behavior should be visible at the level of persistence profiles, providing a new statistical test for the Sato-Tate conjecture and its generalizations.

**Why now?** The Sato-Tate conjecture is now a theorem for elliptic curves (Taylor et al., 2011), and computational resources for large-scale point counting are available. The persistence profile provides a new summary statistic whose distribution can be computed and compared against random matrix predictions.

**Test:** Generate $10^4$ random hyperelliptic curves of genus 2 over $\mathbf{F}_p$ for several primes $p$, compute their persistence profiles, and compare the distribution of profiles against the prediction from random $4 \times 4$ unitary symplectic matrices.

**Impact:** Would provide the first connection between persistence invariants and random matrix theory in number theory, opening a new computational approach to the Katz-Sarnak program.

**Catalog References:** `Speculative/MotivicPersistence.lean` — `hankelRank_le_spectral`, `hankelRank_eq_of_injective`

**Proof Strategy:** For the formal component, prove that the Hankel rank profile is determined by the eigenvalue distribution (which follows from Theorem 2). For the random matrix component, compute the expected profile under the Haar measure on $USp(2g)$ and compare computationally.

**Domain Bridges:** Number theory ↔ random matrix theory ↔ statistical physics ↔ topological data analysis

**Lineage:** Connects the formal Hankel framework to the Katz-Sarnak philosophy.

**Ambition:** 🔭 Grand challenge — paradigm-shifting if the persistence profile provides a new way to test random matrix conjectures in arithmetic.

---

## Direction 4: Sparse Spectral Recovery with Certified Guarantees

**Conjecture:** The Prony reconstruction algorithm, when applied to noisy power-sum data (e.g., approximate point counts from probabilistic algorithms), achieves a reconstruction error bounded by $C \cdot m^2 \cdot \sigma / \Delta_{\min}$, where $\sigma$ is the noise level and $\Delta_{\min} = \min_{i \neq j} |\alpha_i - \alpha_j|$ is the minimum spectral separation. This bound can be formally verified.

**The key insight is** that the Vandermonde matrix condition number is controlled by the spectral separation, and the formally proved factorization $H = V V^\top$ provides exact bounds on the sensitivity of the reconstruction to perturbations.

**Why now?** Compressed sensing and sparse recovery have matured into a powerful applied mathematics toolkit, but rigorous certified guarantees for spectral recovery in the arithmetic setting are lacking. The formal infrastructure (Theorems 1-3) provides the algebraic backbone.

**Test:** Add Gaussian noise to power-sum signals and measure reconstruction error as a function of noise level and spectral separation. Compare against the theoretical bound.

**Impact:** Would provide the first formally verified noise analysis for Prony-type spectral reconstruction, with direct applications to approximate point counting and L-function computation.

**Catalog References:** `Speculative/MotivicPersistence.lean` — `powerSums_determine_charpoly`, `hankel_eq_vandermonde_mul_transpose`

**Proof Strategy:** Formalize perturbation bounds for the Vandermonde system using Mathlib's matrix norm infrastructure. The key step is bounding $\|V^{-1}\|$ in terms of $\Delta_{\min}$ (Vandermonde condition number estimates).

**Domain Bridges:** Signal processing ↔ numerical analysis ↔ arithmetic geometry ↔ formal verification

**Lineage:** Direct extension of the identifiability theorem (Theorem 3) to the approximate/noisy setting.

**Ambition:** 🔬 Solid extension — high-impact applied mathematics with clear formalization path.

---

## Direction 5: Motivic Persistence Modules

**Conjecture:** There exists a functor from the category of smooth projective varieties over $\mathbf{F}_q$ to the category of persistence modules (over the poset $(\mathbb{N}, \leq)$) that:
1. Assigns to $X$ the Hankel persistence module $n \mapsto \mathrm{colSpace}(H_n(X))$.
2. Has barcode that recovers the Frobenius eigenvalue multiset.
3. Is compatible with motivic decomposition: if $h(X) \cong \bigoplus_i h_i$ in the category of Chow motives, then the persistence module decomposes accordingly.

**The key insight is** that the Vandermonde factorization $H_n = V_n V_n^\top$ provides a natural filtration on the spectral data: the column space of $V_n$ grows with $n$ until it reaches the full spectral space. This filtration is functorial and compatible with the motivic structure.

**Why now?** The formal infrastructure proves that the Hankel rank profile is a well-defined invariant with the right properties (monotonicity, stabilization, separation). The missing piece is the categorical/functorial framework, which requires extending from rank profiles to actual persistence modules.

**Test:** Compute the full persistence module (not just rank profile) for products of elliptic curves and verify that it decomposes as the tensor product of the individual modules.

**Impact:** Would establish the first rigorous connection between persistence theory and the theory of motives — potentially providing new computable invariants for motivic decomposition.

**Catalog References:** `Speculative/MotivicPersistence.lean` — all theorems, especially `hankelRankProfile_mono` (monotonicity = persistence) and `hankelRank_eq_of_injective` (stabilization = barcode endpoint)

**Proof Strategy:** Define the persistence module using `Submodule.span` of Hankel column vectors at each level. Prove functoriality using the Vandermonde factorization. For the motivic compatibility, use the Künneth formula for Hankel matrices of product signals.

**Domain Bridges:** Algebraic geometry (motives) ↔ homological algebra ↔ topological data analysis ↔ category theory

**Lineage:** The ultimate goal of the motivic persistence program, building on all five core theorems.

**Ambition:** 🔭 Grand challenge — would open an entirely new field if successful.
