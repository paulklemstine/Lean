# Future Directions: EML Differential Equations

## Synthesis

This research cycle established the polynomial layer of the EML differential equation theory, proving that no nonzero polynomial can satisfy y'' = q(x)y when deg(q) ≥ 1 (the "degree gap obstruction"), and that the Wronskian of solutions is constant for Airy-type ODEs. These results form the foundation upon which the full differential Galois theory and Kovacic algorithm rest.

The most promising cross-domain connection is the bridge between polynomial degree theory and symplectic geometry: the Wronskian constancy theorem shows that the solution space of y'' = q(x)y carries a natural symplectic structure, forcing the differential Galois group into SL₂. This connects the algebraic degree gap (a fact about polynomial rings) to the geometric structure of the solution space (a fact about Lie groups). The next cycle should exploit this bridge to formalize the full Galois group computation for specific equations like Airy.

The highest breakthrough potential lies in Direction 1 (Rational Function Obstruction), because extending from polynomial to rational function solutions covers Case 1 of the Kovacic algorithm — the most computationally tractable case — and would directly yield a partial formalization of the Kovacic decision procedure.

---

### Direction 1: Rational Function Solutions and the Kovacic Algorithm (Case 1)

**Conjecture**: For a second-order linear ODE y'' = q(x)y with q ∈ ℝ(x) a rational function, the equation has a solution of the form exp(∫r(x)dx) with r ∈ ℝ(x) rational if and only if certain algebraic conditions on the poles and residues of q are satisfied. Specifically, if q has a pole of order n at x₀, then the "local exponents" at x₀ must satisfy explicit integrality conditions.

**Test**: Formalize the notion of "local exponent" at a pole of q. Compute the local exponents for q(x) = x (Airy equation: irregular singular point at infinity) and q(x) = 1/x² (Euler equation: regular singular point at 0). Prove that the Airy equation fails the integrality conditions for Case 1, while the Euler equation satisfies them.

**Impact**: If successful, this would formalize the first case of the Kovacic algorithm, handling roughly 40% of all decidable second-order linear ODEs. It would bridge formal polynomial algebra (our degree gap results) with formal complex analysis (residue theory). If the integrality conditions are false as stated, the failure would reveal which aspect of the classical theory requires modification for formalization.

**Catalog References**: `Applications/PolynomialODE.lean` (degree gap obstruction), `Bridges/GaloisNeuralCorrespondence.lean` (Galois group structure), `EML/EMLv17Core.lean` (EML definitions)

**Proof Strategy**: 
1. Define rational function residues using Mathlib's `RatFunc` type.
2. Define the notion of "Riccati equation" associated with y'' = qy: w' + w² = q where w = y'/y.
3. Prove that polynomial solutions of the Riccati equation correspond to exp(∫poly dx) solutions of the original ODE.
4. Use partial fraction decomposition to reduce to local analysis at poles.
5. Apply our degree gap theorem to show that if q has poles of certain orders, the Riccati equation has no polynomial solution.

**Domain Bridges**: Polynomial algebra ↔ Complex analysis (residue theory), Differential equations ↔ Algebraic geometry (singularity classification)

**Lineage**: Builds on `poly_ode_degree_obstruction` and `airy_no_poly_solution` from this cycle. Extends the polynomial obstruction to the rational function setting.

**Ambition**: grand_challenge

---

### Direction 2: Higher-Order Degree Gap and the n-th Order Generalization

**Conjecture**: For an n-th order linear ODE y^(n) = q(x)y with q a nonzero polynomial of degree d ≥ 1, no nonzero polynomial solution exists. More precisely, the degree gap obstruction generalizes: differentiating n times reduces degree by n, while multiplying by q increases degree by d, and these are irreconcilable when d ≥ 1.

**Test**: Formalize the n-th derivative degree gap: if natDegree(p) ≥ n, then natDegree(p^(n)) = natDegree(p) - n (in characteristic 0). Then prove the higher-order obstruction for specific cases: n = 3 (y''' = xy), n = 4 (y'''' = xy). Attempt the general inductive proof.

**Impact**: The n-th order generalization would cover all linear ODEs of any order with nonconstant polynomial coefficients, vastly extending the scope of the obstruction. It would also illuminate the structure of the "iterated degree gap" phenomenon. Failure would indicate whether the n-th derivative degree result requires additional hypotheses beyond torsion-freeness.

**Catalog References**: `Applications/PolynomialODE.lean` (second_deriv_degree_gap, poly_ode_degree_obstruction), `EML/EMLv18Advanced.lean` (eml_second_difference — second-order difference analog)

**Proof Strategy**:
1. Prove by induction on n that the n-th derivative of a polynomial of degree ≥ n has degree exactly natDegree - n (in a torsion-free ring).
2. Verify the base case (n = 1, already in Mathlib) and inductive step (compose with our degree gap lemma).
3. Apply to the equation y^(n) = q·y: natDegree(LHS) = natDegree(p) - n vs natDegree(RHS) = d + natDegree(p), irreconcilable when d ≥ 1.

**Domain Bridges**: Polynomial ring theory ↔ Combinatorics (factorial growth of leading coefficients), Number theory ↔ ODE theory (characteristic of the base ring)

**Lineage**: Direct extension of `second_deriv_degree_gap` from this cycle.

**Ambition**: extension

---

### Direction 3: Wronskian Galois Obstruction — SL₂ is the Full Group

**Conjecture**: The differential Galois group of the Airy equation y'' = xy is exactly SL₂(ℂ). This can be proved by showing: (1) the Wronskian constancy forces G ⊆ SL₂ (established this cycle); (2) the polynomial obstruction eliminates reducible subgroups; (3) the exponential-polynomial obstruction eliminates imprimitive subgroups; (4) a monodromy argument eliminates finite subgroups.

**Test**: Formalize steps (1)-(3) in Lean 4. Step (1) is done (our Wronskian constancy). For step (2), show that if G were reducible, there would exist a solution of the form exp(∫r dx) with r rational, and derive a contradiction using the Riccati equation approach. For step (3), show that if G were imprimitive, there would exist a solution involving square roots of rational functions, and derive a contradiction from the growth rate of Airy functions.

**Impact**: A formal proof that G(Airy) = SL₂(ℂ) would be a landmark result in formal mathematics — the first complete differential Galois group computation in a proof assistant. It would definitively establish the non-elementarity of Airy functions in the strongest possible sense.

**Catalog References**: `Applications/WronskianTheory.lean` (airy_wronskian_const), `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety)

**Proof Strategy**:
1. Define the differential Galois group as the group of R-algebra automorphisms of the Picard-Vessiot extension.
2. Use our Wronskian constancy to prove G ⊆ SL₂.
3. Use the polynomial obstruction to eliminate the case G ⊆ Borel (upper triangular).
4. Use Stokes' phenomenon (asymptotic analysis) to eliminate finite subgroups.
5. Conclude G = SL₂ by exhaustion of Zariski-closed subgroups.

**Domain Bridges**: Differential algebra ↔ Algebraic group theory (classification of closed subgroups of SL₂), Analysis ↔ Algebra (Stokes phenomenon connects asymptotic growth to group structure)

**Lineage**: Builds on `airy_wronskian_const`, `airy_wronskian_deriv_zero`, and `airy_no_poly_solution` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: EML Integration Obstruction — Liouville's Theorem

**Conjecture**: The integral ∫exp(-x²)dx is not an EML function. More generally, if f is an EML function and ∫f dx is EML, then f satisfies specific algebraic constraints (Liouville's criterion). This formalizes the classical result that "most" EML functions do not have EML antiderivatives.

**Test**: Formalize Liouville's criterion for EML expressions: ∫f dx is EML if and only if there exist EML functions g₁, ..., gₙ and constants c₁, ..., cₙ such that f = g₀' + Σ cᵢ gᵢ'/gᵢ (the "logarithmic derivative" form). Apply this to f(x) = exp(-x²) and derive a contradiction.

**Impact**: This would formalize one of the most important classical results in differential algebra — the fact that EML functions are closed under differentiation but NOT under integration. It directly explains why the Airy equation is hard: even if we could express the solution as an integral, that integral might not be EML.

**Catalog References**: `Applications/EMLDerivClosure.lean` (EML derivative closure), `EML/EMLv17Core.lean` (EML definitions)

**Proof Strategy**:
1. Formalize the "tower of differential extensions" framework: ℝ(x) ⊆ ℝ(x, exp(f₁)) ⊆ ... ⊆ K.
2. Define "elementary extension" as adjunction of exp or log of an element.
3. Prove Liouville's criterion by induction on the tower height.
4. Apply to exp(-x²): assume ∫exp(-x²) = g₀ + Σ cᵢ log(gᵢ), differentiate, and derive a contradiction by comparing with exp(-x²).

**Domain Bridges**: Differential algebra ↔ Field theory (transcendence degree), EML complexity ↔ Integration theory (computability of antiderivatives)

**Lineage**: Extends `deriv_depth_le` and the EML closure results from this cycle into the integration domain.

**Ambition**: extension

---

### Direction 5: Tropical Airy Equation — Min-Plus Differential Equations

**Conjecture**: The "tropical Airy equation" — the min-plus analog of y'' = xy — has solutions that are piecewise-linear functions with breakpoints at the zeros of the classical Airy function. Specifically, if we replace addition with min and multiplication with addition, the tropical ODE val(y'') = x + val(y) (where val is the p-adic or tropical valuation) should have solutions whose "tropical curve" encodes the asymptotic behavior of the classical solutions.

**Test**: Define the tropical second derivative for piecewise-linear functions. Compute the solutions of val(y'') = x + val(y) explicitly. Compare the breakpoint structure with the known zeros of Ai(x) (approximately -2.338, -4.088, -5.521, ...).

**Impact**: This would establish a novel bridge between tropical geometry and classical ODE theory, showing that tropical methods can capture qualitative information (zero locations) about transcendental functions. This connection is unexpected and could open new computational approaches to Airy-type equations.

**Catalog References**: `Tropical/FreivaldsLocal.lean` (tropical algebraic methods), `Applications/PolynomialODE.lean` (classical Airy obstruction), `EML/UniversalApproxComplexity.lean` (EML complexity connections)

**Proof Strategy**:
1. Define "tropical derivative" as the slope change function for piecewise-linear functions.
2. Define the "tropical Airy equation" as slope_change² = x + f.
3. Solve explicitly using the recursive structure of piecewise-linear functions.
4. Compare breakpoints with classical Airy zeros using numerical verification (#eval).

**Domain Bridges**: Tropical geometry ↔ Classical analysis (Airy function zeros), Min-plus algebra ↔ ODE theory (tropicalization of differential equations)

**Lineage**: Bridges the tropical methods from `Tropical/FreivaldsLocal.lean` with the Airy equation analysis from this cycle.

**Ambition**: extension
