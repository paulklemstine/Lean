# Future Directions: Self-Avoiding Walk Research

## Synthesis

This cycle formalized the foundational theory of self-avoiding walks on ℤ² and the hexagonal lattice, establishing four interconnected pillars: (1) subadditive sequence theory including Fekete's key inequality, the multiplicative bound, and log-subadditivity; (2) the definition of SAWs with a complete proof of submultiplicativity of SAW counts—the most technically demanding result—yielding the existence of the connective constant with bounds 2 ≤ μ ≤ 4; (3) algebraic properties of the Nienhuis constant √(2+√2) including its degree-4 minimal polynomial, irrationality, and the critical fugacity identity; (4) bridge decomposition theory and its connection to tropical geometry through phase transitions in the max-plus semiring.

The most significant cross-domain connection discovered is between combinatorial path-counting (submultiplicativity), real analysis (Fekete's lemma for subadditive sequences), algebraic number theory (the minimal polynomial of the hexagonal connective constant), and tropical geometry (the Legendre-Fenchel duality at the critical fugacity). The tropical phase transition theorem provides a unifying lens: the connective constant μ appears as the critical parameter at which the tropical partition function transitions from bounded to unbounded behavior, mirroring the classical convergence/divergence of the SAW generating function.

The highest breakthrough potential lies in Direction 1 (discrete holomorphicity), which would open the door to a complete formalization of the Duminil-Copin–Smirnov theorem. Direction 3 (sharper bounds via bridge decomposition) is the most tractable next step and could be completed in a single research cycle. The connection to tropical convexity (Direction 4) offers a novel algebraic framework for understanding SAW phase transitions that has not been explored in the formal verification literature.

---

### Direction 1: Discrete Holomorphicity and the Parafermionic Observable

**Conjecture**: The parafermionic observable F(z) = Σ_{ω: a→z} x_c^{|ω|} e^{-iσθ(ω)} with σ = 5/8 and x_c = 1/√(2+√2) satisfies the discrete Cauchy-Riemann equations on the medial lattice of the hexagonal lattice. Formally, for any interior vertex v of the medial lattice, the "contour sum" of F around v vanishes.

**Test**: Define the medial lattice of a finite hexagonal patch (e.g., a hexagonal domain with radius 2). Enumerate all SAWs from a boundary point a to each vertex z within the patch. Compute F(z) numerically and verify the discrete Cauchy-Riemann equations hold to machine precision. In Lean, define the medial lattice as a finite graph and state the discrete CR equations as linear equations on F values.

**Impact**: This would be the first formalized step toward the Duminil-Copin–Smirnov theorem, which proved μ_hex = √(2+√2). A complete formalization would be a landmark in mathematical physics. If the conjecture can be verified computationally for small domains, it validates the approach before tackling the general proof. If it fails (e.g., due to boundary effects), it teaches us about the role of boundary conditions in discrete holomorphicity.

**Catalog References**: `Tropical/SAW/Nienhuis.lean` (Nienhuis constant properties), `Tropical/SAW/ConnectiveConstant.lean` (SAW definitions and submultiplicativity)

**Proof Strategy**: (1) Define the hexagonal lattice as a planar graph with vertices at hexagon centers and edges connecting adjacent hexagons. (2) Define the medial lattice (vertices at edge midpoints, edges connecting midpoints of adjacent edges around a face). (3) Define the winding angle θ(ω) for a walk ω on the medial lattice. (4) Define F(z) as a finite sum (for finite domains). (5) Prove the discrete CR equations by showing that contributions from walks ending at z cancel when summed around a vertex, using the identity x_c² + x_c⁶ = 1... wait, we showed this identity is false. The correct identity is 2x_c⁴ - 4x_c² + 1 = 0, or equivalently x_c²(1 - 2x_c²) = -(1-2x_c²). The relevant DCS identity involves the angle σ = 5/8 and the critical weight satisfying a specific relation derived from the minimal polynomial.

**Domain Bridges**: Combinatorics (SAW counting) ↔ Complex analysis (discrete holomorphicity) ↔ Algebraic number theory (critical fugacity polynomial) ↔ Statistical physics (conformal invariance at criticality)

**Lineage**: Builds on the Nienhuis constant formalization (nienhuis_minimal_poly, criticalFugacity_poly) and SAW definitions (IsSelfAvoiding, walkPosition) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Irrationality and Transcendence of the Square Lattice Connective Constant

**Conjecture**: The connective constant μ of the square lattice (ℤ²) is transcendental (and in particular, irrational). This is widely believed but completely open.

**Test**: As a first step, attempt to prove that μ is not a quadratic irrational (i.e., does not satisfy ax² + bx + c = 0 with a,b,c ∈ ℤ). This could be approached computationally: if μ satisfied such an equation, the continued fraction expansion of μ would be eventually periodic. Compute the first 1000 partial quotients of μ ≈ 2.6381585... and test for periodicity. A negative result supports (but does not prove) transcendence. In Lean, formalize the statement "μ does not satisfy any polynomial of degree ≤ 4 with integer coefficients bounded by 10^6" using interval arithmetic.

**Impact**: Any progress on the algebraic nature of the square lattice connective constant would be a major breakthrough. Even proving irrationality would be significant, as the current techniques (submultiplicativity, pattern theorems) give no information about algebraic properties. If the approach fails, it highlights the limitations of current techniques and motivates developing new tools (e.g., connections to modular forms or L-functions).

**Catalog References**: `Tropical/SAW/Nienhuis.lean` (nienhuis_irrational as a template for irrationality proofs), `Tropical/SAW/ConnectiveConstant.lean` (connectiveConstant definition and bounds)

**Proof Strategy**: For the quadratic case: (1) Assume μ satisfies aμ² + bμ + c = 0. (2) Use the bounds 2 ≤ μ ≤ 4 and the submultiplicativity of c(n) to derive constraints on a, b, c. (3) Show these constraints are inconsistent with known values of c(n) for small n. For general algebraic degree: use the theory of Liouville numbers and the precise asymptotic expansion c(n) ∼ Aμⁿn^γ to constrain approximation properties of μ.

**Domain Bridges**: Number theory (irrationality/transcendence) ↔ Combinatorics (SAW counts) ↔ Analysis (asymptotic expansions) ↔ Computation (high-precision numerical methods)

**Lineage**: Builds on connectiveConstant definition and bounds from this cycle. Inspired by the successful irrationality proof for the hexagonal lattice constant.

**Ambition**: grand_challenge

---

### Direction 3: Sharp Bounds via Bridge Decomposition

**Conjecture**: The bridge connective constant μ_bridge of the square lattice satisfies μ_bridge = μ (the SAW connective constant). The bridge generating function B(x) = Σ b(n)x^n converges for |x| < 1/μ and diverges for |x| > 1/μ, and the SAW generating function satisfies G(x) ≤ 1/(1 - 2B(x)).

**Test**: Enumerate bridges of length up to 20 on ℤ² computationally (in Python). Compute b(n)/c(n) ratios and verify they converge. Use the relation G(x) = Σ_k (2B(x))^k to derive improved upper bounds on μ. In Lean, prove that b(n) ≤ c(n) (every bridge is a SAW) and that the bridge decomposition of a SAW is unique.

**Impact**: The bridge decomposition provides the most effective analytical tool for computing rigorous bounds on μ. Formalizing it would enable machine-verified bounds tighter than 2 ≤ μ ≤ 4. The uniqueness of bridge decomposition has implications for the renewal structure of SAWs and connects to the theory of regenerative processes.

**Catalog References**: `Tropical/SAW/BridgeDecomposition.lean` (abstract bridge structure, height additivity), `Tropical/SAW/Subadditive.lean` (subadditive sequence theory)

**Proof Strategy**: (1) Define bridges concretely as SAWs where the y-coordinate at the endpoint exceeds all intermediate y-coordinates. (2) Prove that the decomposition into maximal bridges is unique (by induction on walk length). (3) Prove b(m+n) ≤ b(m)·b(n) (bridge submultiplicativity). (4) Use the factorization G(x) = 1/(1 - 2B(x)) to translate bounds on b(n) into bounds on c(n).

**Domain Bridges**: Combinatorics (bridge counting) ↔ Analysis (generating functions, Fekete's lemma) ↔ Probability (renewal theory) ↔ Tropical geometry (tropical factorization)

**Lineage**: Builds on BridgeDecomposition.lean (bridge_height_additive, tropical_geometric_phase_transition) and ConnectiveConstant.lean (sawCount_submultiplicative).

**Ambition**: extension

---

### Direction 4: Tropical Convexity of the SAW Free Energy

**Conjecture**: The SAW free energy function f(β) = lim_{n→∞} (1/n) log Z_n(β), where Z_n(β) = Σ_{ω ∈ SAW(n)} e^{-β|ω|}, is a convex function of β. The Legendre-Fenchel transform I(x) = sup_β (βx - f(β)) is the rate function for the large deviation principle governing the end-to-end distance of SAWs.

**Test**: Compute Z_n(β) numerically for n = 1, ..., 20 and β = 0, 0.1, ..., 2.0 on the square lattice. Plot f_n(β) = (1/n) log Z_n(β) and verify convexity. Compute the Legendre-Fenchel transform numerically and compare with the rate function estimated from SAW end-to-end distance distributions. In Lean, prove that the pointwise supremum of affine functions is convex (a general fact) and apply it to the tropical partition function.

**Impact**: The tropical convexity framework provides a novel algebraic lens for understanding SAW phase transitions. If the free energy is convex (which it should be by general principles of statistical mechanics), the rate function I(x) captures all the large deviation information about the SAW. This connects SAW theory to the broader theory of Gibbs measures and variational principles.

**Catalog References**: `Tropical/SAW/BridgeDecomposition.lean` (legendre_at_critical_point, tropical_geometric_phase_transition), `FINAL/Tropical/LegendreDuality.lean` (complete_the_square — existing Legendre duality infrastructure)

**Proof Strategy**: (1) Define the finite-volume partition function Z_n(β). (2) Prove log Z_n(β) is convex in β (standard: log-sum-exp is convex). (3) Show f_n(β) = (1/n) log Z_n(β) converges (using subadditivity). (4) Prove the limit is convex (pointwise limit of convex functions). (5) Compute the Legendre-Fenchel transform and relate to the rate function.

**Domain Bridges**: Tropical geometry (max-plus algebra) ↔ Convex analysis (Legendre-Fenchel duality) ↔ Statistical mechanics (free energy, Gibbs measures) ↔ Probability (large deviations)

**Lineage**: Builds on the tropical phase transition results from this cycle and the existing Legendre duality infrastructure in the Catalog.

**Ambition**: extension

---

### Direction 5: SAW Counts on General Graphs and the Graph Polynomial

**Conjecture**: For any finite connected graph G, the SAW polynomial P_G(x) = Σ_n c_G(n) x^n is a polynomial with positive integer coefficients and degree equal to |V(G)| - 1 (the maximum length of any SAW). The connective constant μ(G) = limsup c_G(n)^{1/n} equals 1/r where r is the radius of convergence of P_G. For infinite periodic graphs, μ(G) depends only on the local structure of G and satisfies monotonicity: if G is a subgraph of H, then μ(G) ≤ μ(H).

**Test**: Compute SAW polynomials for small graphs (paths, cycles, complete graphs, grid subgraphs) in Python. Verify the degree bound and monotonicity. In Lean, formalize the SAW polynomial for finite graphs using Mathlib's graph theory library and prove basic properties (non-negativity, degree bound).

**Impact**: The SAW polynomial provides a polynomial invariant of graphs that captures information about path complexity. For finite graphs, this is a well-defined combinatorial object that can be studied algebraically. Understanding its roots and coefficients could lead to new graph invariants related to connectivity and expansion.

**Catalog References**: `Tropical/SAW/BridgeDecomposition.lean` (connective_constant_monotone — monotonicity under subgraph inclusion), `Tropical/SAW/ConnectiveConstant.lean` (sawCount_le_four_pow — upper bounds)

**Proof Strategy**: (1) Define SAWs on general finite graphs using Mathlib's SimpleGraph. (2) Prove the SAW polynomial has degree ≤ |V| - 1. (3) Prove monotonicity of the polynomial under edge addition. (4) For infinite periodic graphs, define μ via the limit along exhausting sequences of finite subgraphs.

**Domain Bridges**: Graph theory (SAW polynomial) ↔ Algebra (polynomial invariants) ↔ Combinatorics (counting) ↔ Tropical geometry (Newton polytopes of SAW polynomials)

**Lineage**: Builds on the general formalization of SAW counts and connective constant monotonicity from this cycle.

**Ambition**: extension
