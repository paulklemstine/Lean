# Future Research Directions: EML Differential Equations

## Synthesis

This research cycle established the algebraic foundations for EML differential equation theory: the Wronskian pairing, Abel's identity, the logarithmic derivative's multiplicative-to-additive property, operator composition with the Leibniz correction, and the EML Solution Pair structure. These form a coherent framework connecting the EML function class (already well-developed in the catalog) to the theory of linear ODEs.

The most promising cross-domain connection is between the **EML operator algebra** and **tropical geometry**. Under the logarithmic coordinate change x ↦ log(x), the multiplicative structure of EML functions transforms into additive (tropical) structure. This suggests that the Wronskian theory developed here could have a natural tropical analogue, connecting to the tropical semiring work in `Tropical/` and potentially providing new computational tools for ODE analysis.

The highest breakthrough potential lies in Direction 1 (Generalized Wronskian for n-th Order EML Systems), because it would extend our 2-function theory to the full solution space and directly enable the differential Galois theory. The composition theorem (`linODE1_compose_eq`) already shows how n-th order operators decompose — the Wronskian generalization would provide the corresponding solution-space tool.

---

### Direction 1: Generalized Wronskian Matrix for n-th Order EML Systems

**Conjecture**: For an n-th order linear ODE L[y] = 0 with EML coefficients, the generalized Wronskian matrix W = [f_i^(j)] of n solutions satisfies det(W)' = -p₁(x)·det(W), where p₁ is the coefficient of y^(n-1). Furthermore, if all coefficients are EML, then det(W) is an EML function (it equals C·exp(-∫p₁) for some constant C).

**Test**: Formalize the 3×3 Wronskian for the third-order ODE y''' + p₁y'' + p₂y' + p₃y = 0. Compute det(W)' explicitly and verify the generalized Abel's identity. Test with concrete EML coefficients (e.g., p₁ = exp(x), p₂ = x, p₃ = 1) using numerical ODE solvers to check that det(W(x)) matches C·exp(-∫₀ˣ exp(t)dt).

**Impact**: This would give the complete algebraic framework for EML solution spaces of arbitrary order. The Wronskian matrix encodes the full differential Galois group action, so establishing its EML closure property would be a major step toward proving that the differential Galois group of an EML equation is an EML group.

**Catalog References**: `Applications/EMLDiffEq.lean` (abel_identity, wronskian_exp_exp), `EML/Core.lean` (EMLGenerated'), `EML/GaloisDuality.lean` (Galois insertion)

**Proof Strategy**: Define `WronskianMatrix n (fs : Fin n → ℝ → ℝ) (x : ℝ) : Matrix (Fin n) (Fin n) ℝ` where entry (i,j) = deriv^j(fs i)(x). Prove det(W)' = -p₁·det(W) by expanding the derivative of the determinant using the cofactor expansion and substituting from the ODE. The EML closure follows from the integral formula det(W) = C·exp(-∫p₁) combined with EML closure under integration of EML functions.

**Domain Bridges**: Applications (ODE theory) ↔ EML (function class closure) ↔ Algebra (matrix determinants)

**Lineage**: Builds on abel_identity and wronskian_exp_exp from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Kovacic Algorithm for EML Coefficients

**Conjecture**: The Kovacic algorithm, which decides whether a second-order linear ODE y'' = r(x)y with rational r(x) has Liouvillian solutions, can be extended to EML coefficients. Specifically, for r(x) an EML function, the algorithm's three cases (exponential solutions, product of exponential and algebraic, product involving error-function-type integrals) each have EML analogues that can be tested algorithmically.

**Test**: Implement the classical Kovacic algorithm for rational r(x) in Lean/Python, then test it on the Airy equation y'' = xy (Case 3 applies, no elementary solutions) and the harmonic equation y'' = y (Case 1 applies, exp(x) is a solution). Then attempt to extend Case 1 to EML coefficients.

**Impact**: This would provide a decision procedure for EML solvability of second-order linear ODEs — the differential equation analogue of Galois's criterion for polynomial solvability. It would be the first formalization of Kovacic's algorithm in any proof assistant.

**Catalog References**: `Applications/EMLDiffEq.lean` (LinODE2, abel_identity), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety), `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order)

**Proof Strategy**: Start with Kovacic's Case 1: seek solutions of the form y = exp(∫ω) where ω is in the coefficient field. For EML coefficients, ω should be EML. The necessary condition is that ω satisfies the Riccati equation ω' + ω² = r(x). Formalize the Riccati equation and prove that if r(x) is a polynomial (the simplest EML case), then the algorithm terminates.

**Domain Bridges**: Applications (Kovacic algorithm) ↔ Computation (decidability) ↔ Algebra (Galois theory)

**Lineage**: Builds on the LinODE2 structure and Abel's identity from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Wronskian and Min-Plus ODE Theory

**Conjecture**: Under the logarithmic coordinate change, the Wronskian W(f,g) = fg' - f'g transforms into a tropical (min-plus) expression. Specifically, if F = log(f) and G = log(g) are "tropicalized" versions of f and g, then the tropical Wronskian is min(F + G', F' + G) in the min-plus semiring, and the tropical Abel's identity becomes an additive relation.

**Test**: Compute the tropical Wronskian for the exponential pair (exp(αx), exp(βx)) and verify that it matches the tropicalization of the classical result (β-α)·exp((α+β)x). The tropical version should be (α+β)x + val(β-α) where val is the valuation.

**Impact**: If true, this would establish a bridge between ODE solution theory and tropical geometry, potentially providing new computational methods for analyzing ODE solutions via piecewise-linear optimization. The tropical framework could also connect to the neural network interpretation of EML functions.

**Catalog References**: `Tropical/FreivaldsLocal.lean` (nonzero_linear_form_zero_set_bound), `EML/EMLTropicalSemiring.lean`, `Applications/EMLDiffEq.lean` (wronskian_exp_exp)

**Proof Strategy**: Define the tropical Wronskian as the image of the classical Wronskian under the logarithmic valuation. Use the fact that log(fg' - f'g) can be expressed in terms of log(f), log(g), and their derivatives when f,g > 0. Verify the formula for exponential functions, then attempt to generalize.

**Domain Bridges**: Applications (Wronskian theory) ↔ Tropical (min-plus algebra) ↔ EML (logarithmic coordinates)

**Lineage**: Builds on wronskian_exp_exp and the EML Tropical Semiring from the catalog.

**Ambition**: extension

---

### Direction 4: EML Wronskian Closure and Picard-Vessiot Theory

**Conjecture**: The Wronskian of any two EML functions on (0,∞) is again an EML function. More precisely, if f and g belong to the EML closure of {exp, log, id}, then W(f,g) = fg' - f'g also belongs to this closure.

**Test**: Compute W for the pairs (exp(x), x·exp(x)), (log(x), x·log(x)), (exp(x), log(x)), and verify EML membership. The last case gives W = exp(x)/x - exp(x)·log(x)·... which involves products and quotients of EML functions.

**Impact**: Wronskian closure would mean that the EML class forms a "differential ring" in the sense of Picard-Vessiot theory — the Wronskian never escapes the class. This is a prerequisite for showing that the differential Galois group of an EML equation is itself EML.

**Catalog References**: `EML/Core.lean` (EMLGenerated', EMLClosure'), `EML/GaloisDuality.lean` (eml_galois_insertion_closed), `Applications/EMLDiffEq.lean` (wronskianAt, logDerivFn_mul)

**Proof Strategy**: Use structural induction on EMLGenerated'. The base cases (exp, log, id) can be verified by direct computation. The inductive step requires showing that the Wronskian commutes with each EML operation (add, mul, comp). The composition case is the hardest — it requires the chain rule and closure under differentiation.

**Domain Bridges**: Applications (Wronskian theory) ↔ EML (closure operators) ↔ Algebra (differential rings)

**Lineage**: Builds on wronskianAt, logDerivFn_mul, and the EMLClosure' operator from the catalog.

**Ambition**: extension

---

### Direction 5: Neural ODE Stability via Wronskian Analysis

**Conjecture**: For a neural ODE y'(t) = σ(W·y(t) + b) where σ is the softplus/sigmoid activation (an EML function), the Wronskian of the solution flow provides computable stability certificates. Specifically, the sign of W(y₁, y₂) for two nearby trajectories determines local Lyapunov stability, and Abel's identity connects this to the Jacobian of the neural network.

**Test**: For the 1D neural ODE y' = sigmoid(y) = exp(y)/(1+exp(y)), compute the Wronskian of two solutions and verify that Abel's identity (with p = -sigmoid'(y(t))) gives the correct stability prediction. Compare with numerical integration.

**Impact**: This would provide rigorous stability guarantees for neural ODEs — a major open problem in scientific machine learning. The EML framework is natural here because neural network activation functions are EML.

**Catalog References**: `Applications/EMLDiffEq.lean` (softplus_hasDerivAt, sigmoid_in_unit_interval, abel_identity), `EML/EMLNeuralNetworks.lean`, `MachineLearning/` (PAC-Bayes)

**Proof Strategy**: Start with the scalar case y' = σ(y). The linearized equation around a trajectory y₀(t) is δy' = σ'(y₀(t))·δy, which is a first-order linear ODE with EML coefficient σ'(y₀). Apply the exponential solution formula exp(-∫σ'(y₀)) and use sigmoid bounds (0 < σ' < 1) to get stability.

**Domain Bridges**: Applications (ODE stability) ↔ MachineLearning (neural ODEs) ↔ EML (activation functions)

**Lineage**: Builds on softplus_hasDerivAt, sigmoid_in_unit_interval from this cycle.

**Ambition**: extension
