# Future Directions: Certified Numerical Lorentzian Geometry

## Synthesis

The spectral gap of quadratic leaf Hessians has emerged as the fundamental quantity controlling the numerical stability of Lorentzian recognition. Our formal verification of the perturbation theorem (`hasAtMostOnePositiveEigenvalue_of_gapped_perturbation`) establishes a clean separation: the spectral gap ε provides an exact budget for perturbation tolerance, and the residual gap theorem (`gapped_signature_perturbation_residual`) shows this budget degrades linearly. All five directions below build on this foundation, extending it toward sharp constants, new polynomial families, tropical geometry, probabilistic analysis, and computational hardness. Together they outline a program to develop *certified numerical algebraic geometry* — a field where every geometric property comes with a computable robustness certificate.

---

## Direction 1: Sharp Constants in the Dimension-Degree Stability Law

**Conjecture:** For every (n, d), the optimal constant C(n,d) such that entry-wise perturbation ≤ C(n,d)·ε preserves Lorentzianity satisfies C(n,d) = Θ(1/n) — linear in 1/n rather than the 1/n² from our entry-based bound.

**Test:** Compute C(n,d) numerically for e_k(x₁,...,xₙ) with n ≤ 20, k ≤ 10 via binary search on the destruction threshold. If C(n,d) · n is approximately constant across n, the conjecture is supported. A counterexample where C(n,d) · n → 0 would disprove it.

**Impact:** Sharp constants would close the 4–5× conservatism gap we observe empirically, making the certificate practically tight. This would make certified Lorentzian recognition competitive with uncertified numerical methods.

**Catalog References:** `Pythagorean/LorentzianStability.lean` — `quadFormBound_of_entry_bound`, `dimension_degree_stability_law_instance`

**Proof Strategy:** Replace the entry-based AM-GM bound with a tighter analysis using Schur complements or matrix concentration inequalities. The key is showing that random symmetric perturbations with independent entries have spectral radius O(√n · max_entry) rather than O(n · max_entry).

**Domain Bridges:** Numerical linear algebra (spectral radius of random matrices), high-dimensional probability (matrix Chernoff bounds)

**Lineage:** Directly extends Theorem 4.4 of the current work.

**Ambition:** Solid extension — would complete the quantitative picture opened by the perturbation theorem. ★★★

---

## Direction 2: Lorentzian Condition Numbers and Smoothed Analysis

**Conjecture:** Under smoothed analysis (Gaussian perturbation of coefficients with variance σ²), the probability that a degree-d polynomial near the Lorentzian boundary is misclassified decays as exp(−Ω(ε²/(nσ²))), where ε is the spectral gap.

**Test:** For polynomials with spectral gap ε close to 0, sample Gaussian perturbations at various σ and measure misclassification rate. Fit the exponential decay model. If the rate does not depend on ε²/σ² but on a different quantity, the conjecture fails.

**Impact:** Would establish Lorentzian recognition as numerically well-conditioned in the smoothed analysis sense, even for polynomials near the boundary. This is the strongest possible statement about practical reliability.

**Catalog References:** `Pythagorean/LorentzianStability.lean` — `HasGappedSignature`, `LorentzianConditionNumber`

**Proof Strategy:** Use the perturbation theorem to reduce to bounding P[‖E‖_op > ε] for Gaussian Wigner matrices E. Known tail bounds for the largest eigenvalue of GOE give the desired exponential decay.

**Domain Bridges:** Smoothed analysis (Spielman–Teng program), random matrix theory, computational complexity

**Lineage:** Extends the condition number concept from numerical linear algebra to algebraic combinatorics.

**Ambition:** Grand challenge — would merge Lorentzian polynomial theory with the Spielman–Teng paradigm. ★★★★★

---

## Direction 3: Tropical Shadows of Lorentzian Stability

**Conjecture:** The tropicalization of the Lorentzian stability radius (infimum of coefficient perturbations destroying Lorentzianity) equals the minimum tropical spectral gap across tropical quadratic leaves.

**Test:** Compute tropical quadratic leaves for small examples (complete graphs, uniform matroids). Compare the tropical spectral gap to the log of the exact stability radius. If they differ by more than O(log n), the conjecture fails.

**Impact:** Would provide a purely combinatorial proxy for the numerical stability radius, computable in polynomial time without eigenvalue decomposition. This could enable Lorentzian certification for polynomials with millions of variables.

**Catalog References:** `Pythagorean/LorentzianStability.lean` — `UniformSpectralMargin`; `Catalog/Tropical/` — various tropical geometry files

**Proof Strategy:** Use the Maslov dequantization: take the limit of log(stability_radius(tᵅ · f)) / log(t) as t → ∞. Show this limit equals the tropical spectral gap via the tropical eigenvalue theory of Akian, Gaubert, and Guterman.

**Domain Bridges:** Tropical geometry, max-plus algebra, combinatorial optimization

**Lineage:** Builds on both the stability theory (this work) and tropical Lorentzian theory.

**Ambition:** Grand challenge — would create a new bridge between numerical stability and tropical geometry. ★★★★★

---

## Direction 4: Certified Hyperbolicity via Lorentzian Leaf Margins

**Conjecture:** A homogeneous polynomial p is hyperbolic with respect to direction e if and only if every quadratic leaf of p (relative to e) has gapped Lorentzian signature, and the minimum gap provides a certified hyperbolicity margin.

**Test:** For known hyperbolic polynomials (determinant, elementary symmetric), compute quadratic leaf gaps relative to different directions e. Verify that the gap is positive exactly when p is hyperbolic w.r.t. e. Test non-hyperbolic polynomials to confirm the gap is zero or the signature fails.

**Impact:** Would extend our stability theory from Lorentzian polynomials to the broader class of hyperbolic polynomials, which arise in optimization (hyperbolic programming), PDEs (hyperbolic operators), and control theory.

**Catalog References:** `Pythagorean/LorentzianStability.lean` — `HasGappedSignature`, `lorentzian_stable_under_leaf_perturbation`

**Proof Strategy:** Use the Helton–Vinnikov theorem (every hyperbolic polynomial is a determinant of a linear matrix pencil) to reduce to spectral analysis of the pencil. The gap translates to the minimum eigenvalue gap of the pencil restricted to the hyperbolicity cone.

**Domain Bridges:** Hyperbolic programming, semidefinite optimization, PDE theory, robust control

**Lineage:** Extends the Lorentzian framework to encompass Gårding's hyperbolicity theory.

**Ambition:** Solid extension with grand-challenge potential if the characterization is complete. ★★★★

---

## Direction 5: Stability of Strongly Log-Concave Distributions Under Noisy Generating Functions

**Conjecture:** If a probability distribution μ on {0,1}ⁿ has a strongly log-concave generating polynomial (Lorentzian with spectral gap ε), then any distribution ν whose generating polynomial has coefficient-wise distance < C·ε from μ's is also strongly log-concave, with explicit mixing time bounds for Markov chains on ν's support.

**Test:** Sample from distributions near the uniform matroid measure. Compute the generating polynomial's spectral gap. Verify that the mixing time of the natural random walk scales as predicted by the gap. If mixing time depends on a different quantity, refine the conjecture.

**Impact:** Would provide the first certified mixing time bounds for sampling algorithms operating on approximately log-concave distributions — a central problem in machine learning and statistical physics.

**Catalog References:** `Pythagorean/LorentzianStability.lean` — `lorentzian_stability_radius_exists`, `reversed_cauchy_schwarz_of_gapped`

**Proof Strategy:** Use the stability radius to show the perturbed distribution has a Lorentzian generating polynomial. Then apply Anari–Oveis Gharan–Vinzant's framework linking Lorentzianity to modified log-Sobolev inequalities, which control mixing times.

**Domain Bridges:** Markov chain Monte Carlo, statistical physics (Glauber dynamics), machine learning (sampling from energy-based models)

**Lineage:** Connects the perturbation theorem to the probabilistic applications of Lorentzian polynomials.

**Ambition:** Solid extension — the pieces exist but assembling them requires careful analysis. ★★★★
