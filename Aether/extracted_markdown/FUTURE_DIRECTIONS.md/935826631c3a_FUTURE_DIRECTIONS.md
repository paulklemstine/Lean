# Future Directions: Scheme-Symmetric Lorentzian Stability

## Synthesis

The scheme-symmetric Lorentzian stability theory opens a new interface between algebraic combinatorics, spectral theory, and polynomial geometry. The central achievement—identifying the stability radius with a finite spectral minimum over primitive idempotent classes—creates a bridge from the abstract theory of Lorentzian polynomials to concrete computation via eigenmatrices of association schemes. The five directions below exploit this bridge in complementary ways: two extend the spectral framework to richer mathematical structures (continuous symmetric spaces, non-affine eigenvalue flows), two develop algorithmic and applied consequences (certified optimization, coding-theoretic invariants), and one pursues the deepest structural question (multi-positive signatures and higher Hodge theory). Together, they constitute a coherent research program that could transform how we understand stability in symmetric polynomial spaces.

---

## Direction 1: Continuous Extension to Gelfand Pairs and Symmetric Spaces

**Conjecture:** For a compact symmetric space G/K with Gelfand pair (G,K), the Lorentzian stability radius of a K-invariant polynomial family is determined by the first vanishing time of a zonal spherical function eigenvalue branch, generalizing the finite-scheme formula ρ = min_{j≥1} |a_j|/b_j to the continuous setting.

**Test:** For the sphere S^{n-1} (Gelfand pair (SO(n), SO(n-1))), compute the stability radius of the Gegenbauer polynomial family C_k^λ under coefficient perturbation and compare with the predicted spectral minimum from the Gegenbauer eigenvalue spectrum.

**Impact:** This would unify the finite theory (Johnson/Hamming schemes) with continuous harmonic analysis, potentially connecting Lorentzian stability to the theory of spherical designs, Christoffel functions, and approximation theory on symmetric spaces.

**Catalog References:**
- `Catalog/Pythagorean/SchemeLorentzian/Theorems.lean` — `stabilityRadius_eq_min_eigenRatio`
- `Catalog/Pythagorean/UniformMatroidLorentzian.lean` — `uniform_leaf_hessian_decomposition`

**Proof Strategy:** Model the continuous case as a limit of finite association schemes (e.g., J(n,k) → Grassmannian as n → ∞). Use the Weyl integration formula to convert sums over idempotent classes to integrals over the dual space. The key challenge is showing the infimum over continuous spectral parameters is attained.

**Domain Bridges:** Harmonic analysis on symmetric spaces ↔ Lorentzian polynomial geometry; approximation theory ↔ stability theory.

**Lineage:** Extends the finite Johnson scheme specialization (Theorem 3.7) to continuous analogues.

**Ambition:** Grand challenge — would require substantial new mathematical infrastructure but could reshape understanding of stability in geometric analysis.

---

## Direction 2: Non-Affine Eigenvalue Flows and Nonlinear Stability

**Conjecture:** When eigenvalues θ_j(t) depend polynomially (not affinely) on the perturbation parameter, the stability radius equals the smallest positive root of any nontrivial eigenvalue function: ρ = min_{j≥1} min{t > 0 : θ_j(t) = 0}.

**Test:** For degree-2 eigenvalue flows θ_j(t) = a_j + b_j t + c_j t² with randomly generated coefficients satisfying θ_j(0) < 0 and some θ_j(t) > 0 for large t, compute the stability radius by root-finding and compare with binary search on the actual Hessian eigenvalues.

**Impact:** Extends the spectral formula beyond the affine case, covering quadratic and higher-order perturbation families arising in trust-region optimization and polynomial homotopy continuation.

**Catalog References:**
- `Catalog/Pythagorean/SchemeLorentzian/Theorems.lean` — `eigenvalue_neg_before_vanishing`, `eigenvalue_pos_after_vanishing`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `lorentzian_stability_radius_exists`

**Proof Strategy:** Replace the affine vanishing time t_j = -a_j/b_j with the smallest positive root of θ_j(t). The key lemma is that θ_j changes sign at the root (by continuity) and the stability radius is the minimum such root. Use the intermediate value theorem and careful monotonicity arguments.

**Domain Bridges:** Numerical algebraic geometry (polynomial root-finding) ↔ Lorentzian stability; optimization (trust regions) ↔ spectral analysis.

**Lineage:** Directly extends the affine eigenvalue theory (Theorems 3.3–3.6).

**Ambition:** Solid extension — mathematically clean and computationally testable.

---

## Direction 3: Krawtchouk-Optimal Codes and Lorentzian Invariants

**Conjecture:** For a linear code C in H(n,q), the Lorentzian stability radius of the code's weight enumerator polynomial (viewed as a scheme-symmetric element) is a new code invariant that is bounded below by a function of the code's minimum distance and above by a function of its covering radius.

**Test:** Compute the Lorentzian stability radius for known optimal codes (Hamming codes, Golay codes, Reed-Muller codes) and correlate with classical code parameters (minimum distance, weight distribution, strength as a design).

**Impact:** Would establish Lorentzian stability as a new quality measure for codes, complementary to minimum distance. Could lead to new bounds in coding theory via the spectral formula.

**Catalog References:**
- `Catalog/Pythagorean/SchemeLorentzian/Theorems.lean` — `hammingScheme_radius_lowerBound`
- `Catalog/Pythagorean/SchemeLorentzian/Defs.lean` — `HammingLorentzianFamily`

**Proof Strategy:** For a code C ⊆ F_q^n with distance distribution B_0, ..., B_n, the weight enumerator is W_C(x) = ∑ B_i x^i. Express the leaf Hessian in the Krawtchouk basis and apply the spectral formula. The minimum distance d controls the first nonzero B_i, which constrains the eigenvalue ratios.

**Domain Bridges:** Coding theory (weight enumerators, distance distributions) ↔ Lorentzian geometry; design theory (strength) ↔ spectral gap.

**Lineage:** Builds on the Hamming scheme lower bound (Theorem 3.8).

**Ambition:** Solid extension with potential for significant impact in coding theory.

---

## Direction 4: Certified Spectral Algorithms for Lorentzian Optimization

**Conjecture:** The spectral stability radius provides a computable *trust region* for Lorentzian polynomial optimization: within the ball of radius ρ around a certified Lorentzian point, all polynomials remain Lorentzian and log-concavity-based sampling algorithms converge.

**Test:** Implement a trust-region Newton method for maximizing a Lorentzian polynomial over a polytope, using the spectral stability radius as the trust-region size. Compare convergence rates against standard methods on matroid intersection and log-concave sampling benchmarks.

**Impact:** Would provide the first numerically certified optimization algorithm for Lorentzian polynomials, with convergence guarantees derived from spectral data rather than ad hoc step-size rules.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `hasAtMostOnePositiveEigenvalue_of_gapped_perturbation`, `certifyStability_sound`
- `Catalog/Pythagorean/SchemeLorentzian/Defs.lean` — `schemeStabilityRadius`

**Proof Strategy:** Use the certified stability check (Algorithm 2) as an oracle within a trust-region framework. The key insight is that the spectral gap provides a natural trust-region radius that adapts to the local geometry. Prove convergence by showing the trust region contracts at a controlled rate.

**Domain Bridges:** Numerical optimization (trust regions, convergence theory) ↔ Lorentzian polynomials; certified computation ↔ spectral analysis.

**Lineage:** Extends the certified stability checker from the catalog.

**Ambition:** Solid extension — immediately applicable and algorithmically impactful.

---

## Direction 5: Multi-Positive Signatures and Higher Hodge Theory

**Conjecture:** The scheme-spectral framework extends from at-most-one-positive-eigenvalue (Lorentzian) signatures to at-most-k-positive-eigenvalue signatures, relevant for higher-order combinatorial Hodge theory. The stability radius for the k-positive boundary is determined by the (k+1)-st smallest vanishing time: ρ_k = t_{(k+1)} (the (k+1)-th order statistic of vanishing times).

**The key insight is** that Lorentzian polynomials enforce a single positive direction, but higher Hodge-Riemann relations enforce k positive directions, and the transition between k-positive and (k+1)-positive signatures occurs exactly when the (k+1)-st nontrivial eigenvalue crosses zero.

**Why now?** The spectral formula for k = 1 (the Lorentzian case) is now proved. The generalization to k > 1 requires the same idempotent decomposition but a different counting argument for eigenvalue crossings.

**Test:** For the Johnson scheme J(n, k) with k ≥ 4, compute the k-positive stability radii ρ_1, ρ_2, ..., ρ_k and verify that they equal the corresponding order statistics of vanishing times.

**Impact:** Would extend the theory from Lorentzian to higher Hodge-Riemann signature conditions, connecting to the Adiprasito–Huh–Katz theory of Hodge–Riemann relations for matroids.

**Catalog References:**
- `Catalog/Pythagorean/SchemeLorentzian/Theorems.lean` — `exists_vanishing_at_radius`, `stabilityRadius_le_vanishingTime`

**Proof Strategy:** Induction on k: at the base case k = 1, use the proved Lorentzian theorem. For the inductive step, observe that when the (k+1)-st eigenvalue crosses zero, the number of positive eigenvalues increases from k to k+1. The stability radius ρ_k is therefore the (k+1)-st vanishing time by the ordering of vanishing times.

**Domain Bridges:** Combinatorial Hodge theory (Hodge–Riemann relations) ↔ spectral stability; algebraic geometry (signature conditions) ↔ association schemes.

**Lineage:** Generalizes the Lorentzian spectral formula to higher-order signatures.

**Ambition:** Grand challenge — would unify Lorentzian stability with the full Hodge-theoretic program for matroids.
