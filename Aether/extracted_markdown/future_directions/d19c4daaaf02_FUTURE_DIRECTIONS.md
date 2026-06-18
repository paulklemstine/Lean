# Future Directions: EML Differential Equations

## Synthesis

This research cycle established the foundational theory of ODEs with EML coefficients, proving five key results: exponential ODE uniqueness, Abel's identity for the Wronskian, the impossibility of polynomial Airy solutions, tower height escalation under ODE solving, and constant-coefficient ODE uniqueness. These results create a bridge between the algebraic EML closure theory (developed in `Catalog/EML/GaloisDuality.lean` and the `EMLGenerated'` inductive) and the analytic world of differential equations.

The most promising cross-domain connection is between **tower height** and **differential Galois theory**. Our tower height escalation theorem (Theorem 6.1-6.2) shows that solving y' = eₙ(x)·y increases tower height by exactly 1, while the differential Galois group constrains which tower height increases are possible. This suggests a quantitative refinement of the Kovacic algorithm: rather than just deciding EML-solvability, one could compute the *minimum tower height* of any EML solution. The Airy equation's Galois group SL₂(ℂ) blocks *all* finite tower heights, but for equations with solvable Galois groups, the tower height of the solution should be computable from the group structure.

The cycle's most significant limitation was the inability to formalize the full growth-rate obstruction for the Airy equation (showing exp(⅔x^{3/2}) is not EML). This requires either formalizing asymptotic analysis of special functions or developing a new purely algebraic proof via the Kovacic algorithm. Both are viable paths for the next cycle.

---

### Direction 1: Formal Kovacic Algorithm for EML ODEs

**Conjecture**: The Kovacic algorithm can be formalized as a decision procedure in Lean, taking as input a second-order linear ODE y'' + p(x)y' + q(x)y = 0 with p, q ∈ ℚ(x), and outputting either an EML solution or a certificate of unsolvability.

**Test**: Implement and verify the algorithm on three test cases: (1) y'' = y (should find exp(x)), (2) y'' + y = 0 (should find sin/cos, or report non-EML depending on the function class), (3) y'' = xy (should certify no EML solution). A correct implementation must agree with known results on all three.

**Impact**: A verified Kovacic algorithm would be the first machine-checked decision procedure for elementary solvability of second-order linear ODEs. This would enable automated verification of claims about differential equation unsolvability in physics and engineering.

**Catalog References**: `EML/DiffEqODE.lean` (Wronskian theory, Abel's identity), `EML/GaloisDuality.lean` (EML closure structure), `EML/EMLv17Core.lean` (base EML definitions)

**Proof Strategy**: (1) Formalize rational functions ℚ(x) as Polynomial.RatFunc. (2) Define the three cases of Kovacic's algorithm as separate functions. (3) Prove termination by showing the search space is finite. (4) Prove soundness: if the algorithm outputs a solution, it satisfies the ODE. (5) Prove completeness: if no solution is output, the differential Galois group is non-solvable.

**Domain Bridges**: Computation (decision procedures) <-> EML (differential Galois theory) <-> Algebra (algebraic groups)

**Lineage**: Builds on wronskian_abel_identity and airy_no_polynomial_solution from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tower Height Bounds for Differential Galois Groups

**Conjecture**: For a second-order linear ODE y'' + p(x)y' + q(x)y = 0 with EML coefficients of tower height ≤ k, if the differential Galois group is solvable (a subgroup of the Borel group B₂), then the minimum tower height of any EML solution is at most 2k + 1.

**Test**: Verify the bound for k = 0 (polynomial coefficients): all solvable cases should yield solutions of tower height ≤ 1 (i.e., exponentials of polynomials). Check against the classification of Lamé equations.

**Impact**: This would establish a quantitative version of the Kovacic dichotomy, giving not just "solvable or not" but "how complex is the simplest solution." This has implications for computational complexity of ODE solving.

**Catalog References**: `EML/DiffEqODE.lean` (tower height definitions, escalation theorem), `EML/EMLv17Core.lean` (eml definition), `Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**: (1) Classify the solvable subgroups of GL₂: diagonal, triangular, finite. (2) For each case, bound the number of Liouville extensions needed. (3) Each Liouville extension (adjoin an integral or an exponential of an integral) increases tower height by at most 1. (4) Count the maximum chain length.

**Domain Bridges**: EML (tower height) <-> Algebra (algebraic groups, Borel subgroups) <-> Computation (complexity bounds)

**Lineage**: Extends eml_ode_tower_height_lower_bound and DiffGaloisAction from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Nonlinear EML ODEs and Painlevé Classification

**Conjecture**: The six Painlevé equations (PI through PVI) all have differential Galois groups that are non-solvable over ℂ(x), implying their solutions (the Painlevé transcendents) lie outside the EML class. Specifically, PI: y'' = 6y² + x should have the same SL₂ obstruction as the Airy equation.

**Test**: For PI linearized around a solution, compute the monodromy representation numerically and verify it generates a Zariski-dense subgroup of SL₂(ℂ). Compare with known results from isomonodromic deformation theory.

**Impact**: Would extend the EML boundary theory from linear to nonlinear ODEs, connecting to the Painlevé program in mathematical physics. The Painlevé transcendents are the simplest functions beyond the EML class that still satisfy "nice" ODEs.

**Catalog References**: `EML/DiffEqODE.lean` (Airy equation theory), `EML/EMLv19Advanced.lean` (EML functional equations)

**Proof Strategy**: (1) Formalize the definition of the six Painlevé equations. (2) For PI, reduce the nonlinear ODE to a linear isomonodromic problem. (3) Show the monodromy group of the linearization is SL₂(ℂ). (4) Apply the same obstruction as for the Airy equation.

**Domain Bridges**: EML (function class boundaries) <-> Physics (isomonodromic deformation) <-> Geometry (monodromy representations)

**Lineage**: Extends airy_no_polynomial_solution and the growth-rate obstruction from this cycle.

**Ambition**: extension

---

### Direction 4: EML Closure Under Integral Transforms

**Conjecture**: The EML class is *not* closed under the Fourier transform: there exists an EML function f such that its Fourier transform F[f] is not EML. Specifically, F[exp(-x²)](ξ) = √π · exp(-π²ξ²) is EML, but F[exp(-|x|³)](ξ) is not EML.

**Test**: Numerically compute F[exp(-|x|³)](ξ) for ξ = 0.1, 0.5, 1, 2, 5 and attempt to fit an EML expression of tower height ≤ 3. If the best fit has error > 10⁻³ for tower height 3 while the Gaussian has error < 10⁻¹⁰ for tower height 1, this supports the conjecture.

**Impact**: Would delineate the boundary between EML-preserving and EML-breaking operations, with implications for the theory of distributions and PDE solutions via Fourier methods.

**Catalog References**: `EML/DiffEqODE.lean` (EMLExpr syntax), `Bridges/EMLClosureCore.lean` (closure properties)

**Proof Strategy**: (1) Show F[exp(-|x|³)] satisfies a third-order ODE whose Galois group is non-solvable. (2) Apply the tower height obstruction. Key lemma: the Fourier transform of exp(-|x|^α) for non-even integer α satisfies an ODE with fractional-power coefficients.

**Domain Bridges**: EML (closure properties) <-> Physics (Fourier analysis) <-> Algebra (non-solvable Galois groups)

**Lineage**: Extends EMLExpr and tower height theory from this cycle.

**Ambition**: extension

---

### Direction 5: Wronskian Invariants for EML Function Spaces

**Conjecture**: For any finite-dimensional subspace V of EML functions of tower height ≤ k, the Wronskian W(f₁, ..., fₙ) of a basis is itself an EML function of tower height ≤ n·k. Moreover, this bound is tight for the space spanned by {exp(x), exp(2x), ..., exp(nx)}.

**Test**: Compute the Wronskian of {exp(x), exp(2x), exp(3x)} explicitly (should be a constant times exp(6x), tower height 1 = 3·0 + 1) and of {exp(exp(x)), x·exp(exp(x))} (should have tower height ≤ 4 = 2·2).

**Impact**: Would provide a tower-height-preserving version of the Wronskian theory, connecting the algebraic structure of EML spaces to their analytic properties. This has implications for approximation theory and complexity of EML function spaces.

**Catalog References**: `EML/DiffEqODE.lean` (Wronskian definition, Abel's identity), `EML/EMLv17Core.lean` (tower height)

**Proof Strategy**: (1) Prove by induction on n that the Wronskian of n EML functions of height ≤ k involves at most n layers of differentiation, each potentially adding 1 to tower height. (2) For the tight bound, construct explicit examples. (3) Use Abel's identity to reduce the n-dimensional Wronskian to iterated 2-dimensional ones.

**Domain Bridges**: EML (tower height) <-> Algebra (linear independence, determinants) <-> Geometry (Grassmannians)

**Lineage**: Extends wronskian_exp_xexp, wronskian_exp_negexp, and wronskian_abel_identity from this cycle.

**Ambition**: extension
