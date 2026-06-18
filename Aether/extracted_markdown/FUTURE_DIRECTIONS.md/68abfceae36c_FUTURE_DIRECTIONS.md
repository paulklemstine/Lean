# Future Directions: EML Differential Operators

## Synthesis

This research cycle established a rigorous Wronskian theory for second-order linear ODEs with EML coefficients. The central discovery is the **doubly-exponential Wronskian decay** for EML-coefficient ODEs: when p(x) = eˣ − ln(c), the Wronskian decays like exp(−eˣ), vastly faster than any polynomial-coefficient ODE. This connects to differential Galois theory through the monodromy representation — the rapid decay constrains possible Galois groups, suggesting that EML ODEs have highly restricted solvability.

The most promising cross-domain connection is between the EML Wronskian theory and the existing Catalog work on Galois obstruction (`Bridges/GaloisNeuralCorrespondence.lean`). The `prime_degree_divides_galois_order` theorem and the differential Galois group constraints from Wronskian decay could be unified into a comprehensive obstruction theory for transcendental extensions. The Sturm separation theorem also bridges to tropical geometry via the oscillation-exponential phase transition at discriminant zeros.

The highest breakthrough potential lies in Direction 1 (Kovacic algorithm formalization). A verified implementation of Kovacic's algorithm for EML coefficients would be the first formally verified decidability result for differential Galois theory, connecting algebraic algorithms with analytic ODE theory in a novel way. This would build directly on the Wronskian infrastructure established in this cycle.

---

### Direction 1: Kovacic Algorithm for EML-Coefficient ODEs

**Conjecture**: Kovacic's algorithm, when applied to the ODE y″ + q(x)y = 0 with q(x) = eˣ − ln(c) for any c > 0, terminates with "no Liouvillian solution" in all three cases. This would prove that no solution is expressible in terms of elementary functions.

**Test**: Implement the three cases of Kovacic's algorithm for q(x) = eˣ − C (where C = ln(c)): (1) Find rational solutions of the Riccati equation ω′ + ω² = q; (2) Find algebraic solutions of degree 2; (3) Find algebraic solutions of degree 4, 6, or 12. For each case, check the necessary conditions on the poles of q. Since q = eˣ − C has no poles (it's entire), the analysis simplifies dramatically — show that Cases 1-3 all fail.

**Impact**: If true, this provides a constructive proof that EML ODEs are "essentially non-elementary," extending the classical result for the Airy equation. If false (i.e., some EML ODE has Liouvillian solutions), it would identify a surprising solvability island within the EML class.

**Catalog References**: `Applications/EMLDiffOp.lean` (Abel's identity, Wronskian theory), `Bridges/GaloisNeuralCorrespondence.lean` (`prime_degree_divides_galois_order`)

**Proof Strategy**: (1) Formalize the Riccati equation ω′ + ω² = q in Lean; (2) Prove that rational functions cannot satisfy it when q is entire and transcendental; (3) Extend to algebraic solutions using degree bounds from Kovacic's algorithm; (4) Conclude non-Liouvillian solvability.

**Domain Bridges**: Algebra (Galois theory) <-> Applications (ODE solvability) <-> Computation (decidability of Kovacic's algorithm)

**Lineage**: Builds on this cycle's EMLDiffOperator, abel_wronskian_deriv, wronskian_nonzero_of_nonzero_at.

**Ambition**: grand_challenge

---

### Direction 2: Stokes Phenomenon for EML Differential Equations

**Conjecture**: The Stokes multipliers for the ODE y″ = eˣ · y exhibit a recursive structure: the Stokes multiplier Sₙ at the n-th anti-Stokes line satisfies Sₙ = f(Sₙ₋₁) where f is a specific EML-type function. This would connect Stokes phenomenon to EML dynamics.

**Test**: Compute the Stokes multipliers numerically for the exponential operator y″ = eˣy using WKB analysis in the complex plane. The anti-Stokes lines are the curves where Re(∫√q dz) = 0. For q = eᶻ, these form a specific pattern. Check if consecutive multipliers satisfy an EML recurrence.

**Impact**: If true, this would establish a new connection between classical asymptotic analysis (Stokes phenomenon) and the EML function class. The recursive structure would provide a "renormalization group" for Stokes multipliers. If false, the failure mode would reveal what aspect of the EML coefficient structure is lost in the WKB approximation.

**Catalog References**: `Applications/EMLDiffOp.lean` (expOperator, double_exp_lower_bound_informal), `EML/EMLv17Core.lean` (eml definition and properties)

**Proof Strategy**: (1) Compute WKB solutions exp(±∫√(eˣ) dx) = exp(±2e^{x/2}); (2) Analyze the connection formulae across Stokes lines using Borel resummation; (3) Extract the recursive structure from the monodromy.

**Domain Bridges**: Physics (WKB/semiclassical) <-> Applications (EML ODEs) <-> EML (EML function dynamics)

**Lineage**: Builds on this cycle's expOperator, exp_operator_wronskian_const, double_exp_lower_bound_informal.

**Ambition**: grand_challenge

---

### Direction 3: EML Wronskian Decay Rate Classification

**Conjecture**: For the family of ODEs y″ + p_α(x)y′ = 0 where p_α(x) = eˣ − α·ln(x) for α ∈ ℝ, the Wronskian decay rate W(x) ~ exp(−eˣ + α·x·ln(x)) exhibits a phase transition at α = 0: for α < 0, the Wronskian oscillates before decaying; for α > 0, it decays monotonically.

**Test**: Numerically solve the ODE for α ∈ {−2, −1, −0.5, 0, 0.5, 1, 2} on [0, 10] and plot the Wronskian. Check for sign changes (oscillation) in the α < 0 case. Formally prove the monotone decay for α ≥ 0 using the Wronskian positivity argument from Abel's identity.

**Impact**: This classifies the "dynamical regimes" of EML ODEs parametrically. The phase transition, if it exists, would be a new phenomenon in ODE theory.

**Catalog References**: `Applications/EMLDiffOp.lean` (eml_wronskian_decay_rate, abel_wronskian_deriv)

**Proof Strategy**: (1) Generalize eml_wronskian_decay_rate to p_α; (2) Compute the sign of the integral ∫₀ˣ p_α(t)dt; (3) Show that for α ≥ 0 the integral is positive and monotone increasing; (4) For α < 0, show the integral can become negative, allowing Wronskian growth before eventual decay.

**Domain Bridges**: Applications (EML ODEs) <-> EML (parametric EML functions)

**Lineage**: Direct extension of this cycle's eml_wronskian_decay_rate.

**Ambition**: extension

---

### Direction 4: Sturm-Liouville Eigenvalue Theory for EML Potentials

**Conjecture**: The eigenvalues λₙ of the Sturm-Liouville problem y″ + (λ − eml(x, c))y = 0 with y(0) = y(L) = 0 satisfy the asymptotic formula λₙ ~ eᴸ + (nπ/L)² as n → ∞. The dominant term eᴸ comes from the EML potential, and the correction (nπ/L)² is the standard free-particle spacing.

**Test**: Compute eigenvalues numerically using a shooting method for c = 1, L = 5, and n = 1, ..., 20. Fit the asymptotic formula and check the convergence rate. The key test: does λₙ − eᴸ converge to (nπ/L)² as n → ∞?

**Impact**: This would establish the spectral theory of EML potentials, connecting to quantum mechanics (the EML potential models a particle in an exponentially deep well with logarithmic corrections). The eigenvalue asymptotics would be a new result in spectral theory.

**Catalog References**: `Applications/EMLDiffOp.lean` (sturm_separation_sign_change, airy_discriminant_sign_change), `EML/EMLv17Core.lean`

**Proof Strategy**: (1) Formalize the eigenvalue problem as an EMLDiffOperator with q(x) = λ − eml(x, c); (2) Use the discriminant Δ = 4(eml(x,c) − λ) to identify oscillatory and exponential regions; (3) Apply WKB quantization ∫√(λ − q) dx = (n + ½)π; (4) Evaluate the integral asymptotically for large λ.

**Domain Bridges**: Applications (EML ODEs) <-> Physics (quantum mechanics) <-> EML (spectral theory)

**Lineage**: Builds on this cycle's EMLDiffOperator, discriminant analysis, Sturm separation.

**Ambition**: extension

---

### Direction 5: Differential Galois Group of the EML Wronskian ODE

**Conjecture**: The differential Galois group of the ODE w′ = −eml(x, c) · w (the Abel ODE for the Wronskian) is isomorphic to the multiplicative group Gₘ = GL(1) for all c > 0. This is the "smallest possible" non-trivial Galois group, reflecting the complete integrability of the Wronskian equation.

**Test**: The ODE w′ = −(eˣ − ln c)w has solution w = w₀ · exp(−eˣ + eˣ⁰ + (ln c)(x − x₀)). Check that this is a Picard-Vessiot extension with Galois group Gₘ by verifying that the differential automorphisms are exactly the scalings w ↦ αw for α ∈ ℂ*.

**Impact**: If confirmed, this provides the first explicit computation of a differential Galois group for an EML-coefficient equation. Combined with the Wronskian theory, it would give a complete algebraic characterization of the solution space structure for EML ODEs with q = 0.

**Catalog References**: `Applications/EMLDiffOp.lean` (abel_wronskian_deriv, eml_wronskian_decay_rate), `Bridges/GaloisNeuralCorrespondence.lean` (`prime_degree_divides_galois_order`)

**Proof Strategy**: (1) Construct the Picard-Vessiot extension by adjoining exp(−eˣ) to the coefficient field ℂ(x, eˣ, ln x); (2) Show that the extension is generated by a single exponential integral; (3) Identify the Galois group as Gₘ using Kolchin's classification.

**Domain Bridges**: Algebra (differential Galois theory) <-> Applications (EML Wronskian) <-> Bridges (Galois obstruction)

**Lineage**: Builds on this cycle's abel_wronskian_deriv, eml_wronskian_decay_rate, and Catalog's GaloisObstruction.

**Ambition**: extension
