# Future Directions: Self-Avoiding Walk Research

## Synthesis

This cycle formalized three pillars of self-avoiding walk (SAW) theory: (1) the combinatorial definitions of lattice walks and self-avoidance on ℤ², (2) Fekete's lemma for subadditive sequences in division-bound form, establishing the analytic machinery for connective constants, and (3) the complete algebraic theory of the Nienhuis constant √(2+√2), including its minimal polynomial, irrationality, power recursion, and critical fugacity identity. The bridge between submultiplicative sequences (SAW counts) and subadditive sequences (their logarithms) was formally established, completing the theoretical chain from combinatorial counting to the existence of connective constants.

The most significant cross-domain connection discovered is the triple bridge: **combinatorics** (SAW counting and submultiplicativity) ↔ **real analysis** (Fekete's lemma, subadditive sequences, convergence) ↔ **algebraic number theory** (the quartic x⁴-4x²+2, irrationality of nested radicals). This connects the Catalog's existing algebraic infrastructure (minimal polynomials, irrationality proofs in `Algebra/NsqPlusOne.lean`) with new analytic and combinatorial machinery.

The highest breakthrough potential lies in Direction 1 (Discrete Holomorphicity), which would formalize the core technique behind the Duminil-Copin–Smirnov Fields Medal proof. However, Direction 2 (Bridge Decomposition) offers a more tractable intermediate target that could yield rigorous bounds on the square lattice connective constant using only the infrastructure built in this cycle.

---

### Direction 1: Discrete Holomorphicity and the Parafermionic Observable

**Conjecture**: On the medial lattice of the hexagonal lattice, the parafermionic observable F(z) = Σ_{ω: a→z} x_c^{|ω|} e^{-iσθ(ω)} with σ = 5/8 and x_c = 1/√(2+√2) satisfies the discrete Cauchy-Riemann equations: for each interior face with vertices z₁, z₂, z₃ of the medial lattice, (z₂-z₁)F(z₁) + (z₃-z₂)F(z₂) + (z₁-z₃)F(z₃) = 0.

**Test**: Implement the medial lattice of a small hexagonal patch (e.g., a single hexagon with 6 medial edges), enumerate all SAWs from a boundary point, compute F(z) exactly using algebraic arithmetic (in the field ℚ(√2, √(2+√2), i)), and verify the discrete Cauchy-Riemann identity holds. This can be done computationally in Lean via `#eval` or in Python.

**Impact**: This would be the first formally verified step toward the Duminil-Copin–Smirnov theorem. If the discrete CR equations are formalized, the telescoping argument that proves μ_hex = √(2+√2) follows by summing over faces — connecting the algebraic results from this cycle (critical_point_identity, nienhuis_minpoly_eval) to the combinatorial definitions.

**Catalog References**: `Algebra/SAW/NienhuisConstant.lean` (critical_point_identity, nienhuis_minpoly_eval), `Algebra/SAW/Defs.lean` (LatticeWalk, IsSelfAvoiding)

**Proof Strategy**: (1) Define the hexagonal lattice as a planar graph with vertices of degree 3. (2) Define the medial lattice (vertices = midpoints of edges). (3) Define the winding angle θ(ω) for walks on the medial lattice. (4) Define F(z) as an algebraic-valued sum. (5) Prove the discrete CR equations by a local cancellation argument: pairs of walks differing by a single edge contribute terms that cancel. The key algebraic identity is that x_c · (1 + 2cos(5π/8)) = 0 when x_c = 1/√(2+√2) and the spin σ = 5/8.

**Domain Bridges**: Combinatorics (walk enumeration) ↔ Complex Analysis (discrete CR equations) ↔ Algebraic Number Theory (Nienhuis constant) ↔ Statistical Physics (phase transitions)

**Lineage**: Builds on this cycle's μ_hex algebraic theory and SAW definitions.

**Ambition**: grand_challenge

---

### Direction 2: Bridge Decomposition and Connective Constant Bounds

**Conjecture**: For self-avoiding walks on ℤ², every SAW can be uniquely decomposed into a sequence of *bridges* — walks where the maximum x-coordinate is achieved only at the endpoint. The connective constant for bridges equals the overall connective constant: lim b_n^{1/n} = μ_square.

**Test**: Enumerate all SAWs of length ≤ 25 on ℤ², classify each as a sequence of bridges, and verify (a) uniqueness of the decomposition, (b) that b_n^{1/n} converges to the same limit as c_n^{1/n} ≈ 2.638. If the bridge count satisfies b_n ≥ c_n / poly(n) for all computed n, this supports the conjecture.

**Impact**: Bridge decomposition is a key technique for proving connective constant bounds. It would provide a rigorous lower bound on μ_square by giving μ ≥ lim inf b_n^{1/n}, which can be computed from shorter walks. Combined with the subadditivity infrastructure from this cycle, this would yield the first formally verified bounds on μ_square.

**Catalog References**: `Algebra/SAW/Subadditive.lean` (fekete_division_bound, subadditive_mul_le), `Algebra/SAW/Defs.lean` (LatticeWalk, endpoint, IsSelfAvoiding)

**Proof Strategy**: (1) Define bridges formally: a SAW w from origin to endpoint (d,0) with d > 0 and all intermediate x-coordinates < d. (2) Prove the bridge decomposition theorem: every SAW has a unique maximal decomposition into bridges separated by "renewal points" where the walk achieves a new maximum x-coordinate. (3) Prove bridge submultiplicativity: the bridge count b_n is submultiplicative. (4) Apply Fekete's lemma to conclude the bridge connective constant exists.

**Domain Bridges**: Combinatorics (bridge decomposition) ↔ Real Analysis (Fekete's lemma, from this cycle) ↔ Probability (renewal theory)

**Lineage**: Builds directly on this cycle's SAW definitions and Fekete's lemma.

**Ambition**: extension

---

### Direction 3: Tropical Self-Avoiding Walks and Max-Plus Counting

**Conjecture**: In the tropical (max-plus) semiring, the tropical analogue of the SAW generating function Σ c_n · x^n has a tropical radius of convergence equal to 1/μ, where μ is the connective constant. Moreover, the tropical version of Fekete's lemma (min-plus subadditivity) provides an alternative proof framework for the existence of connective constants.

**Test**: Compute the tropical SAW generating function for small lattices (e.g., ℤ² truncated to a 10×10 grid) and verify that the max-plus eigenvalue of the transfer matrix equals the connective constant to within numerical precision.

**Impact**: This would connect SAW theory to the Catalog's existing tropical algebra infrastructure, creating a bridge between statistical mechanics and tropical geometry. The tropical framework could also provide new computational tools for bounding connective constants on arbitrary graphs.

**Catalog References**: `Tropical/*.lean` (tropical semiring definitions), `Algebra/SAW/Subadditive.lean` (IsSubadditive, Fekete's lemma)

**Proof Strategy**: (1) Define tropical SAW counting via the max-plus semiring. (2) Show that the tropical transfer matrix formulation yields the same connective constant as the classical one. (3) Use the tropicalization of the Nienhuis polynomial x⁴-4x²+2 to study the tropical geometry of the critical point.

**Domain Bridges**: Tropical Geometry (max-plus semiring, tropical polynomials) ↔ Combinatorics (SAW counting) ↔ Linear Algebra (Perron-Frobenius for tropical matrices)

**Lineage**: Builds on this cycle's subadditive sequence theory and connects to existing Tropical catalog entries.

**Ambition**: grand_challenge

---

### Direction 4: Connective Constants of Archimedean Lattices

**Conjecture**: For each of the 11 Archimedean lattices (vertex-transitive tilings of the plane by regular polygons), the connective constant μ is algebraic. The lattices with odd-valent vertices (hexagonal: degree 3, (3,4,6,4): degree 3) have connective constants in the splitting field of a polynomial with degree ≤ 8 over ℚ.

**Test**: For the (4,8,8) lattice (square-octagon tiling, vertex degree 3), compute SAW counts to length 20 and use integer relation algorithms (LLL/PSLQ) to search for a minimal polynomial of the connective constant. If a polynomial of degree ≤ 8 is found, this supports the algebraic conjecture.

**Impact**: Extending the Nienhuis result beyond the hexagonal lattice would reveal whether algebraic connective constants are specific to the honeycomb or a general phenomenon of planar lattices. The algebraic infrastructure from this cycle (minimal polynomials, irrationality proofs) directly applies.

**Catalog References**: `Algebra/SAW/NienhuisConstant.lean` (quartic_four_real_roots, nienhuis_minpoly_eval), `Algebra/SAW/Subadditive.lean` (fekete_limsup_le)

**Proof Strategy**: (1) Define each Archimedean lattice as a planar graph. (2) Implement SAW enumeration on each lattice. (3) Compute c_n^{1/n} to high precision. (4) Search for algebraic relations. (5) For lattices where discrete holomorphicity applies (odd-valent), attempt to construct parafermionic observables.

**Domain Bridges**: Geometry (Archimedean tilings) ↔ Algebraic Number Theory (minimal polynomials) ↔ Combinatorics (SAW counting) ↔ Computational Mathematics (LLL algorithm)

**Lineage**: Extends this cycle's hexagonal lattice analysis to the full family of Archimedean lattices.

**Ambition**: extension

---

### Direction 5: Strengthening Fekete to Full Convergence

**Conjecture**: The full statement of Fekete's lemma — that lim a(n)/n = inf_{n≥1} a(n)/n and this limit is a Filter.Tendsto statement — can be formalized from the weak form (fekete_limsup_le) established in this cycle, using the characterization of convergence via limsup and liminf.

**Test**: Formalize the statement `Tendsto (fun n => a n / n) atTop (𝓝 (⨅ (n : {n : ℕ // 0 < n}), a n / n))` and verify it compiles in Lean. Then prove it using the weak form plus the observation that the infimum is also a lower bound (from subadditivity).

**Impact**: This would provide a complete, formally verified Fekete's lemma usable in any Mathlib-compatible project. It could be contributed upstream to Mathlib, filling a gap in the current library (Mathlib has subadditive/submodular structures but not Fekete's lemma as a standalone theorem).

**Catalog References**: `Algebra/SAW/Subadditive.lean` (fekete_limsup_le, fekete_division_bound, subadditive_mul_le)

**Proof Strategy**: (1) From fekete_limsup_le, the limsup of a(n)/n is ≤ a(q)/q for all q. Taking the infimum over q gives limsup ≤ inf. (2) The inf is ≤ liminf by definition (the infimum of all values is ≤ the eventually smallest values). (3) Since liminf ≤ limsup always, we get equality: liminf = limsup = inf, hence convergence.

**Domain Bridges**: Real Analysis (convergence, filters) ↔ Combinatorics (subadditivity) ↔ Formalization (Mathlib contribution)

**Lineage**: Directly extends this cycle's weak Fekete lemma.

**Ambition**: extension
