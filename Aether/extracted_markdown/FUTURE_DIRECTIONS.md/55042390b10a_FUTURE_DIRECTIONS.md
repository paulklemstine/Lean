# Future Directions: Self-Avoiding Walks and Tropical Geometry

## Synthesis

This cycle established the formal foundations connecting three mathematical domains through self-avoiding walk theory: combinatorial path-counting (submultiplicativity), real analysis (Fekete's lemma and the connective constant), and tropical algebra (tropical valuations and convergence criteria). The most significant achievement is the complete proof chain from submultiplicativity through Fekete-type bounds to the tropical convergence criterion, which precisely characterizes when the SAW generating function converges in terms of the tropical growth rate.

The irrationality of the Nienhuis constant √(2+√2) was established via reduction to the irrationality of √2, and its minimal polynomial x⁴ - 4x² + 2 = 0 was verified. This connects to the Catalog's existing tropical algebra infrastructure — the tropical polynomial max(4v, 2v + log 4, log 2) encodes the same algebraic structure in piecewise-linear form, creating a bridge to the `Tropical.TropicalStructure` module.

The highest breakthrough potential lies in Direction 1 (discrete holomorphicity), which would formalize the mathematical core of the Duminil-Copin–Smirnov theorem. Direction 2 (bridge decomposition bounds) offers a more tractable intermediate goal that could produce publishable sharp bounds. Direction 3 (tropical spectral theory for SAWs) could connect to the existing `Tropical.SpectralCryptanalysis` module in the Catalog.

---

### Direction 1: Discrete Holomorphicity on the Hexagonal Medial Lattice

**Conjecture**: The parafermionic observable F(z) = Σ_{ω: a→z} x_c^{|ω|} e^{-i(5/8)θ(ω)} satisfies discrete Cauchy-Riemann equations on the medial lattice of the hexagonal lattice, where θ(ω) is the winding angle and x_c = 1/√(2+√2).

**Test**: Define the medial lattice of a finite hexagonal domain (3×3 patch) as a graph in Lean. Define the parafermionic observable as a sum over SAWs. Verify the discrete Cauchy-Riemann equations computationally for this small domain using `#eval`. If they hold for several patch sizes, proceed to the general algebraic proof.

**Impact**: This would be the first step toward a complete formalization of the Duminil-Copin–Smirnov theorem, one of the landmark results in 21st-century mathematical physics. Success would demonstrate that discrete complex analysis can be fully mechanized.

**Catalog References**: `Tropical.SAW.ConnectiveConstant` (nienhuis constant definitions), `Tropical.SAW.TropicalBridge` (tropical convergence)

**Proof Strategy**:
1. Define the hexagonal lattice and its medial lattice as a planar graph
2. Define winding angle θ(ω) for walks on the medial lattice
3. Define the parafermionic observable F(z) as a formal sum
4. State discrete Cauchy-Riemann: for each medial vertex v, the sum of F over edges adjacent to v, weighted by edge directions, equals zero
5. Prove the identity algebraically using the self-avoiding property and x_c = 1/μ_hex

**Domain Bridges**: Combinatorics (SAW counting) ↔ Complex Analysis (discrete holomorphicity) ↔ Algebraic Number Theory (Nienhuis constant)

**Lineage**: Builds on this cycle's Nienhuis constant proofs (nienhuis_sq, nienhuis_minimal_poly, nienhuis_irrational)

**Ambition**: grand_challenge

---

### Direction 2: Sharp Bounds on the Square Lattice Connective Constant via Bridge Decomposition

**Conjecture**: Using the bridge decomposition, the square lattice connective constant μ_sq satisfies 2.620 < μ_sq < 2.680, with rigorous bounds provable from the first 20 terms of the bridge count sequence.

**Test**: Implement the bridge decomposition algorithm: a bridge SAW is one where the endpoint has strictly maximal first coordinate. Compute b(n) for n = 1,...,20. The identity c(n) = Σ_{compositions of n} Π b(k_i) (Hammersley-Welsh decomposition) combined with known c(n) values yields constraints. Verify the bound computationally, then formalize.

**Impact**: Would produce the first fully verified nontrivial numerical bounds on μ_sq, advancing the state of rigorous knowledge about the most important lattice in SAW theory.

**Catalog References**: `Tropical.SAW.Defs` (SAW definitions), `Tropical.SAW.ConnectiveConstant` (connective constant framework)

**Proof Strategy**:
1. Define bridge SAWs formally (endpoint has maximal x-coordinate)
2. Prove the Hammersley-Welsh bridge decomposition: every SAW has a unique decomposition into bridges
3. Establish b(n) ≤ c(n) ≤ Σ product-of-bridges identity
4. Compute b(1),...,b(20) explicitly (by enumeration with `native_decide` for small cases)
5. Derive two-sided bounds on μ from the computed values

**Domain Bridges**: Combinatorics (bridge decomposition) ↔ Analysis (generating function bounds) ↔ Computation (SAW enumeration algorithms)

**Lineage**: Builds on this cycle's submultiplicativity and Fekete lemma proofs

**Ambition**: extension

---

### Direction 3: Tropical Transfer Matrix for SAW on Strips

**Conjecture**: The connective constant of the SAW model on a strip of width W (ℤ × {0,...,W}) equals the tropical spectral radius of the W-dependent transfer matrix T_W, and as W → ∞, this converges to the full square lattice μ_sq.

**Test**: For W = 1, compute the transfer matrix T_1 explicitly (it's 2×2). The tropical spectral radius is max of diagonal entries in T_1^⊗n / n as n → ∞, where ⊗ is tropical matrix multiplication. Verify this equals the known strip connective constant. For W = 2, 3, check that the tropical spectral radius increases monotonically.

**Impact**: Would connect SAW theory to tropical linear algebra and matrix theory, potentially linking to the Catalog's existing `Tropical.Matrix` module. Could provide a computational pathway to ever-sharper lower bounds on μ_sq.

**Catalog References**: `Tropical.Matrix.Defs`, `Tropical.Matrix.Algebra`, `Tropical.SpectralCryptanalysis` (tropical spectral radius)

**Proof Strategy**:
1. Define the SAW transfer matrix T_W for strips of width W
2. Prove that the SAW partition function on a strip of length L equals (T_W^L)_{initial, final}
3. Define the tropical spectral radius as lim_{n→∞} (max entry of T^n)^{1/n}
4. Prove monotonicity in W: μ(W) ≤ μ(W+1) ≤ μ_sq
5. Establish convergence μ(W) → μ_sq as W → ∞

**Domain Bridges**: Tropical Algebra (spectral radius) ↔ Combinatorics (SAW on strips) ↔ Statistical Mechanics (transfer matrix formalism)

**Lineage**: Builds on this cycle's tropical bridge results and the Catalog's tropical matrix infrastructure

**Ambition**: extension

---

### Direction 4: SAW Generating Functions as Tropical Curves

**Conjecture**: The Newton polygon of the SAW generating function G(x,y) = Σ c_{m,n} x^m y^n (where c_{m,n} counts SAWs ending at (m,n)) tropicalizes to a tropical curve whose genus equals 0, reflecting the tree-like structure of SAW enumeration via bridge decomposition.

**Test**: Compute the first few terms of c_{m,n} for small m, n. Construct the Newton polygon. Tropicalize and check genus computationally using the formula g = # interior lattice points of the Newton polygon.

**Impact**: Would establish a deep connection between SAW combinatorics and tropical algebraic geometry, potentially linking walk enumeration to the well-developed theory of tropical curves and their moduli spaces.

**Catalog References**: `Tropical.SAW.TropicalBridge` (tropical SAW theory), `Tropical.TropicalStructure` (tropical algebra)

**Proof Strategy**:
1. Define the bivariate SAW generating function G(x,y) formally
2. Characterize its Newton polygon using submultiplicativity bounds
3. Tropicalize G to obtain a tropical curve
4. Compute the genus using the tropical genus formula
5. Connect genus 0 to the bridge decomposition structure

**Domain Bridges**: Tropical Geometry (tropical curves) ↔ Combinatorics (SAW endpoint distribution) ↔ Algebraic Geometry (Newton polygons)

**Lineage**: Builds on this cycle's tropical convergence results

**Ambition**: grand_challenge

---

### Direction 5: Universality of Critical Exponents via Tropical Renormalization

**Conjecture**: The critical exponent γ = 43/32 for the SAW model in 2D can be recovered as a fixed point of a tropical renormalization group transformation acting on the space of tropical polynomials.

**Test**: Define a tropical renormalization map R that coarsens the lattice by factor 2. Apply R repeatedly to the tropical SAW generating function and check whether the sequence of tropical polynomials converges to a fixed point. If so, extract the critical exponent from the slope of the fixed-point tropical polynomial at its root.

**Impact**: If successful, this would provide a completely new approach to proving universality of critical exponents, one of the central open problems in mathematical physics. Even partial results (e.g., proving γ exists as a tropical fixed point) would be highly significant.

**Catalog References**: `Tropical.SAW.TropicalBridge`, `Tropical.FourierAnalysis.Core`, `Tropical.PerformanceEnvelope.Core`

**Proof Strategy**:
1. Define tropical renormalization: R(f)(v) = (1/2) · f(2v) (tropical rescaling)
2. Prove that R maps tropical SAW polynomials to tropical SAW polynomials (at coarser scale)
3. Analyze fixed points of R in the space of piecewise-linear convex functions
4. Extract critical exponents from the derivative of the fixed-point map at the fixed point
5. Connect to the known physics prediction γ = 43/32

**Domain Bridges**: Statistical Mechanics (renormalization group) ↔ Tropical Geometry (piecewise-linear fixed points) ↔ Dynamical Systems (iteration convergence)

**Lineage**: Speculative extension building on all results from this cycle

**Ambition**: grand_challenge
