# Future Directions: Edge-Factor Lorentzian Closure Program

## Synthesis

The edge-factor Lorentzian closure theorem establishes that ferromagnetic partition polynomials are Lorentzian in every two-variable Hessian slice, via the vanishing diagonal mechanism of multiaffine polynomials. This opens five interconnected research directions: (1) extending the bivariate result to full iterated-derivative Lorentzianity, (2) generalizing from Ising to Potts and random-cluster models, (3) quantifying the Lorentzian gap for algorithmic applications, (4) connecting to quantum partition functions, and (5) building a hyperbolic optimization framework on partition function geometry. Each direction builds directly on the formally verified theorems in `Catalog/Pythagorean/LorentzianEdgeClosure.lean` and the mixing-time framework in `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`, with the anti-cancellation machinery of `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` providing the technical backbone for support-theoretic arguments.

---

## Direction 1: Full Positive-Orthant Iterated Derivative Closure

**Conjecture:** For every finite graph G with nonneg couplings and every sequence of d − 2 nonneg direction vectors, where d is the total degree of the multiaffine partition polynomial, the iterated directional derivative yields a quadratic form with at most one positive eigenvalue.

**Test:** Implement iterated directional derivatives for partition polynomials of K₃ through K₈ with random nonneg direction vectors. For each instance, compute the eigenvalues of the resulting 2×2 form and verify at most one is positive. A single counterexample refutes the conjecture; 10⁶ random tests without counterexample provides strong evidence.

**Impact:** This would complete the bridge from edge-factor decomposition to the full Brändén–Huh Lorentzian framework, making the entire Lorentzian polynomial toolkit available for Ising partition functions. It would immediately imply ultra-log-concavity of all coefficient sequences under positive specialization.

**The key insight is** that iterated directional derivatives of a multiaffine polynomial along positive directions reduce the degree while preserving multiaffinity and coefficient nonnegativity, so the vanishing-diagonal mechanism applies inductively at each derivative step.

**Why now?** The bivariate Hessian theorem (Theorem 6 in `LorentzianEdgeClosure.lean`) provides the base case. The formal infrastructure for iterated derivatives exists in Mathlib's `MvPolynomial.pderiv` API. What's needed is a clean inductive argument connecting degree reduction to Hessian signature preservation.

**Catalog References:** `Catalog/Pythagorean/LorentzianEdgeClosure.lean` (Theorems 1, 3, 6), `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (support exactness theorems)

**Proof Strategy:** Induction on degree. At each step, a directional derivative ∂_u with u ≥ 0 maps a multiaffine polynomial with nonneg coefficients to another multiaffine polynomial with nonneg coefficients. The Hessian of the derivative has zero diagonal by multiaffinity, so the off-diagonal determinant criterion applies.

**Domain Bridges:** Combinatorial Hodge theory → Statistical physics → Polynomial geometry

**Lineage:** Extends Theorems 1, 3, 6 of `LorentzianEdgeClosure.lean`

**Ambition:** Grand challenge — if proven, this would be a definitive bridge theorem connecting Brändén–Huh's Lorentzian framework to the full class of ferromagnetic partition functions.

---

## Direction 2: Potts Models and Random-Cluster Polynomials

**Conjecture:** The multivariate Tutte polynomial of a graph with parameters (q, v) in the ferromagnetic regime (q ≥ 1, v ≥ 0) is Lorentzian in a suitable positive-orthant sense, with the edge-factor decomposition generalizing from 2-state to q-state factors.

**Test:** Compute the Tutte polynomial of complete graphs K₃ through K₆ for q = 2, 3, 4 and v = 0.5, 1.0, 2.0. Verify the Hessian eigenvalue condition after specialization to two variables. The q = 2 case should reduce to the Ising result.

**Impact:** Would extend the Lorentzian closure program to the entire Potts model family, with implications for chromatic polynomials (q → integer) and reliability polynomials (v → −1).

**The key insight is** that the q-state edge factor (1 + v·δ(σᵤ, σᵥ)) can be rewritten as a multiaffine polynomial in indicator variables, and the resulting Hessian has a block structure that generalizes the 2×2 off-diagonal pattern.

**Why now?** The Fortuin–Kasteleyn representation already provides an edge-factor decomposition for random-cluster models. The Lorentzian framework needs only the appropriate generalization of the determinant criterion to higher-dimensional blocks.

**Catalog References:** `Catalog/Pythagorean/LorentzianEdgeClosure.lean` (edge factor structure), `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` (spectral gap framework)

**Proof Strategy:** Define q-state edge factors, compute their block Hessians, verify the Lorentzian condition for each block, then apply block-diagonal closure theorems.

**Domain Bridges:** Statistical physics (Potts models) → Graph theory (Tutte polynomial) → Probability (random-cluster measures)

**Lineage:** Generalizes Direction 1 from q = 2 to arbitrary q

**Ambition:** Solid extension — the mathematical framework is clear, and the computational tests are tractable.

---

## Direction 3: Quantitative Lorentzian Gap and Mixing Time Bounds

**Conjecture:** For a graph G with maximum degree Δ and uniform coupling w, the Lorentzian gap ε of the partition polynomial Hessian satisfies ε ≥ c · w · (1 − tanh(βwΔ)) for an absolute constant c > 0, implying O(n log n) mixing time for Glauber dynamics when βwΔ < 1.

**Test:** Compute the Lorentzian gap (minimum negative eigenvalue magnitude of the transverse Hessian) for regular graphs of increasing size with varying β. Plot ε vs. β and fit the functional form. The critical threshold βwΔ = 1 should be visible as a phase transition in the gap.

**Impact:** Would provide the first quantitative connection between Lorentzian polynomial geometry and Markov chain mixing times, potentially improving the Dobrushin condition by exploiting algebraic structure.

**The key insight is** that the Lorentzian gap encodes the strength of negative correlation in the Gibbs measure, and this negative correlation directly controls the Poincaré constant for single-site dynamics.

**Why now?** The Glauber mixing framework in `LorentzianGlauberMixing.lean` already formalizes the Poincaré-to-spectral-gap pipeline. What's missing is the quantitative bound on the Lorentzian gap itself, which requires combining the edge-factor structure with spectral graph theory.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` (spectral gap from Poincaré constant), `Catalog/Pythagorean/LorentzianEdgeClosure.lean` (edge factor Hessians)

**Proof Strategy:** Express the transverse Hessian as a graph Laplacian plus correction terms, bound the correction using coupling strengths and maximum degree, extract the spectral gap from the graph Laplacian's second eigenvalue.

**Domain Bridges:** Spectral graph theory → MCMC algorithms → Statistical physics phase transitions

**Lineage:** Combines Theorems from both `LorentzianEdgeClosure.lean` and `LorentzianGlauberMixing.lean`

**Ambition:** Solid extension with high impact — quantitative bounds are the currency of algorithmic applications.

---

## Direction 4: Quantum Spin Systems and Partition Function Geometry

**Conjecture:** For quantum Heisenberg ferromagnets at inverse temperature β, the partition function Z = Tr(e^{−βH}), when expressed as a polynomial in appropriate external field parameters, exhibits a Lorentzian-like signature condition on its Hessian, with the classical ferromagnetic result as the β → ∞ (classical) limit.

**Test:** Compute the partition function of the quantum Heisenberg model on small lattices (2×2, 2×3) numerically using exact diagonalization. Express Z as a function of external field parameters and verify the Hessian eigenvalue condition.

**Impact:** Would be the first connection between Lorentzian polynomial geometry and quantum statistical mechanics, potentially opening a path to quantum Lee–Yang theory via geometric methods.

**The key insight is** that the Suzuki–Trotter decomposition of the quantum partition function produces a classical partition function on an augmented graph (with an extra "imaginary time" dimension), and the classical Lorentzian condition on this augmented graph should imply properties of the original quantum system.

**Why now?** Quantum computing has renewed interest in efficient simulation of quantum spin systems. Lorentzian structure could provide new certificates for rapid mixing of quantum Monte Carlo algorithms.

**Catalog References:** `Catalog/Pythagorean/LorentzianEdgeClosure.lean` (classical edge-factor structure), `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean` (mixing framework)

**Proof Strategy:** Apply Suzuki–Trotter to reduce to a classical model, apply edge-factor closure on the augmented graph, take the Trotter limit.

**Domain Bridges:** Quantum physics → Classical statistical mechanics → Lorentzian geometry → Quantum algorithms

**Lineage:** Extends the entire classical program to the quantum setting

**Ambition:** Grand challenge — paradigm-shifting if successful, connecting three major research communities.

---

## Direction 5: Hyperbolic Optimization on Partition Function Geometry

**Conjecture:** The Lorentzian cone containing ferromagnetic partition polynomials admits efficient interior-point algorithms for optimization, with the partition function's Hessian serving as a natural barrier function. The resulting optimization framework can solve maximum-likelihood estimation for Ising models in polynomial time in the high-temperature regime.

**Test:** Implement a prototype interior-point optimizer that uses the Lorentzian Hessian as a barrier. Compare convergence rates on parameter estimation problems for Ising models on 20-50 vertex graphs against standard convex optimization solvers.

**Impact:** Would provide a new class of efficient algorithms for statistical inference in graphical models, exploiting the geometric structure discovered in this work.

**The key insight is** that the Lorentzian cone is a symmetric cone (after appropriate homogenization), and symmetric cone programming has well-developed polynomial-time algorithms. The partition function's natural residence in this cone turns inference into structured optimization.

**Why now?** The formal verification of the Lorentzian structure provides rigorous certificates that the optimization problem has the correct geometric structure. This eliminates the need for ad hoc convexity arguments in each application.

**Catalog References:** `Catalog/Pythagorean/LorentzianEdgeClosure.lean` (cone structure), `Catalog/Pythagorean/LorentzianAggregateAntiCancel.lean` (support geometry)

**Proof Strategy:** Formalize the Lorentzian cone as a symmetric cone, import the interior-point framework from convex optimization theory, prove that the partition function Hessian satisfies the barrier function axioms.

**Domain Bridges:** Convex optimization → Machine learning → Statistical physics → Computational complexity

**Lineage:** Application layer on top of the closure theorems

**Ambition:** Solid extension with transformative practical applications — bridges pure mathematics to algorithms.
