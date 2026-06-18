# Future Directions: Submultiplicative Growth and Tropical Bridges

## Synthesis

This cycle established the formal infrastructure connecting submultiplicative sequences (arising from self-avoiding walk enumeration) to subadditive analysis (Fekete's lemma) and tropical algebra (min-plus convergence). The central achievement is the **Fekete–Tropical Bridge Theorem**: for a submultiplicative sequence with growth rate μ > 0, the inequality −log(a(n)) + n·log(μ) ≤ 0 holds for all n ≥ 1, precisely characterizing the tropical convergence boundary. This theorem was fully machine-verified along with its prerequisites: the logarithmic conversion from submultiplicative to subadditive sequences, power bounds a(kn) ≤ a(n)^k · a(0), the infimum characterization of the growth rate, and degree bounds for connective constants.

The irrationality of the Nienhuis constant √(2+√2) was proved via a clean cascade argument (√2 irrational → 2+√2 irrational → √(2+√2) irrational), and its minimal polynomial x⁴ − 4x² + 2 = 0 was verified. These results connect to the Catalog's tropical infrastructure — the polynomial encodes algebraic structure that has a piecewise-linear tropical shadow.

The highest breakthrough potential lies in **Direction 1** (discrete holomorphicity), which would formalize the mathematical core of the Duminil-Copin–Smirnov Fields Medal work. **Direction 2** (tropical spectral bounds) offers a novel approach to connective constant estimation using tropical matrix theory. **Direction 3** (subadditive ergodic theorems) would generalize the Fekete–Tropical Bridge to random environments, with applications to disordered media and random graphs.

---

### Direction 1: Discrete Holomorphicity and the Parafermionic Observable

**Conjecture**: The parafermionic observable F(z) = Σ_{ω: a→z} x^{|ω|} e^{−i(5/8)θ(ω)} on the medial lattice of the hexagonal lattice satisfies the discrete Cauchy-Riemann equation Σ_{z ∈ ∂D} F(z)·(z_{out} − z_{in}) = 0 for every face of the medial lattice, where θ(ω) is the winding angle and x = 1/√(2+√2).

**Test**: Define the medial lattice of a 3×3 hexagonal patch in Lean. Define the parafermionic observable as a finite sum over SAWs. Verify the discrete Cauchy-Riemann equation computationally for this finite patch (using `#eval` with rational approximations). Then formalize the proof that the equation holds for arbitrary finite simply-connected domains.

**Impact**: A formal proof of discrete holomorphicity would provide a machine-verified foundation for the Duminil-Copin–Smirnov theorem, connecting it to the Catalog's existing work on the Nienhuis constant (which we verified satisfies x⁴ − 4x² + 2 = 0).

**Catalog References**: `Algebra/SAWTropical/GrowthRate.lean` (nienhuis_minimal_poly, nienhuis_irrational, NienhuisConstant)

**Proof Strategy**:
1. Define the hexagonal lattice as a graph with vertices at hexagonal centers and edges between adjacent cells.
2. Define the medial lattice as the graph whose vertices are edge-midpoints of the hexagonal lattice.
3. Define the winding angle θ(ω) for a path ω on the medial lattice.
4. Define F(z) as a sum over SAWs from a boundary point to z, weighted by x^{|ω|} e^{−i(5/8)θ(ω)}.
5. Prove the discrete Cauchy-Riemann equation by showing that contributions from opposite edges of each face cancel. The cancellation is exact at x = x_c = 1/√(2+√2) because of the specific angle 5/8.

**Domain Bridges**: Combinatorics (SAW enumeration) ↔ Complex Analysis (discrete Cauchy-Riemann) ↔ Algebra (the minimal polynomial x⁴ − 4x² + 2 = 0 determines the critical point)

**Lineage**: Builds on nienhuis_minimal_poly, nienhuis_irrational, and the SAWCount/LatticeGraph infrastructure from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Spectral Bounds for Connective Constants

**Conjecture**: For a lattice graph G with adjacency-like tropical matrix T (where T_{ij} = 0 if vertices i,j are adjacent, and T_{ij} = +∞ otherwise), the tropical eigenvalue λ_trop(T) satisfies λ_trop(T) ≤ log(μ_G), where μ_G is the connective constant. Moreover, equality holds for trees and graphs with no cycles of odd length.

**Test**: Compute the tropical eigenvalue of the adjacency matrix for the path graph P_n (a tree), the cycle graph C_n, and a 4×4 patch of the square lattice. Verify computationally that λ_trop ≤ log μ. For trees, check that λ_trop = log μ = log(degree − 1) when degree ≥ 2.

**Impact**: If the tropical spectral bound is tight or near-tight, it would provide a new computational method for estimating connective constants using tropical linear algebra (which is polynomial-time), avoiding the exponential cost of direct SAW enumeration.

**Catalog References**: `Catalog/Algebra/Tropical.lean` (Bellman-Ford tropical framework), `Algebra/SAWTropical/GrowthRate.lean` (submulGrowthRate, fekete_tropical_bridge)

**Proof Strategy**:
1. Define the tropical adjacency matrix T_G for a lattice graph G.
2. Define the tropical eigenvalue as λ_trop = min_v (T^n · e)_v / n as n → ∞ (tropical analogue of spectral radius).
3. Show that (T^n · e)_v counts the minimum-weight path of length n from v, which for the 0/∞ adjacency matrix counts walks.
4. Connect to SAW counts: since SAWs are a subset of all walks, the tropical spectral radius (from walks) is ≤ the SAW growth rate (from SAWs only).
5. For trees, walks and SAWs coincide (no cycles to create self-intersections), so equality holds.

**Domain Bridges**: Tropical Algebra (spectral theory) ↔ Graph Theory (adjacency matrices) ↔ Combinatorics (SAW enumeration)

**Lineage**: Builds on fekete_tropical_bridge from this cycle and `Catalog/Algebra/Tropical.lean` (Bellman-Ford).

**Ambition**: extension

---

### Direction 3: Subadditive Ergodic Theorems for Random Environments

**Conjecture**: For a submultiplicative sequence a(n, ω) indexed by a random environment ω (where submultiplicativity holds almost surely: a(m+n, ω) ≤ a(m, ω) · a(n, T^m ω) for an ergodic shift T), the growth rate μ(ω) = lim a(n, ω)^{1/n} exists almost surely and is constant (μ(ω) = μ a.s.). Furthermore, the Fekete–Tropical Bridge extends: −log(a(n, ω)) + n · log(μ) ≤ 0 almost surely for all n.

**Test**: Construct a concrete random submultiplicative sequence: let a(n, ω) be the number of SAWs of length n on a random subgraph of ℤ² (each edge present independently with probability p). Simulate for p = 0.5, 0.7, 0.9 and verify that a(n, ω)^{1/n} converges to a deterministic limit. Check the tropical bridge inequality numerically.

**Impact**: This would extend the Fekete–Tropical Bridge to random media, applicable to SAWs in disordered systems (polymer chains in random environments). The a.s. constancy of the growth rate is a deep consequence of ergodic theory (Kingman's subadditive ergodic theorem).

**Catalog References**: `Algebra/SAWTropical/GrowthRate.lean` (IsSubmultiplicative.log_subadditive, fekete_tropical_bridge)

**Proof Strategy**:
1. Formalize Kingman's subadditive ergodic theorem in Lean (this is a significant undertaking — check if Mathlib has it).
2. Define random submultiplicative sequences over a probability space with an ergodic shift.
3. Apply Kingman's theorem to log a(n, ω) to get a.s. convergence.
4. Transfer the tropical bridge inequality pointwise.

**Domain Bridges**: Probability Theory (ergodic theorems) ↔ Analysis (subadditive sequences) ↔ Tropical Algebra (convergence criteria)

**Lineage**: Builds on IsSubmultiplicative.log_subadditive and fekete_tropical_bridge from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Sharp Degree Bounds via Bridge Decomposition

**Conjecture**: For any lattice graph G with degree d and girth g (length of shortest cycle), the connective constant satisfies μ_G ≤ d − 1 + (d−1)^{1−g/2}. For the hexagonal lattice (d = 3, g = 6), this gives μ ≤ 2 + 2^{−2} = 2.25, which is tighter than the degree bound μ ≤ 3 = d but weaker than the exact value √(2+√2) ≈ 1.848.

**Test**: Verify the bound computationally for the square lattice (d = 4, g = 4): μ ≤ 3 + 3^{−1} = 3.333, compared to the known μ ≈ 2.638. For the triangular lattice (d = 6, g = 3): μ ≤ 5 + 5^{−1/2} ≈ 5.447, compared to μ ≈ 4.151. Check whether the bound is always valid using SAW enumeration data.

**Impact**: Improving the trivial degree bound μ ≤ d to include girth information would give the first formally verified non-trivial upper bounds on connective constants.

**Catalog References**: `Algebra/SAWTropical/GrowthRate.lean` (connectiveConstant_le_degree, LatticeGraph)

**Proof Strategy**:
1. Define the bridge decomposition of a SAW: decompose at the first return to the "boundary" of the starting vertex's neighborhood.
2. Count bridge-free segments: these are SAWs that never return to the starting vertex's neighborhood after leaving it.
3. Use the girth to bound the number of bridge-free segments of length < g (they behave like tree walks, giving factor d−1 per step).
4. Combine the bridge decomposition with the tree-walk bound to get the girth-improved estimate.

**Domain Bridges**: Graph Theory (girth, bridges) ↔ Combinatorics (SAW decomposition) ↔ Analysis (growth rate bounds)

**Lineage**: Builds on connectiveConstant_le_degree and LatticeGraph from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Polynomial Roots and Algebraic Connective Constants

**Conjecture**: The tropical polynomial T(v) = max(4v, 2v + log 4, log 2) has a tropical root at v₀ = (1/2) log 2, and this root corresponds to the log of the Nienhuis constant: v₀ = log(√(2+√2)) = (1/2) log(2+√2). The tropical polynomial encodes the same algebraic information as the minimal polynomial x⁴ − 4x² + 2 = 0 under the tropicalization map.

**Test**: Verify that T(v₀) has a "corner" (non-differentiability point) at v₀ = (1/2) log(2+√2). Check that the Newton polygon of x⁴ − 4x² + 2 recovers the slopes of T. Formalize the tropicalization of x⁴ − 4x² + 2 and verify that its tropical roots correspond to the valuations of the classical roots.

**Impact**: This would establish a formal connection between the algebraic theory of connective constants (minimal polynomials) and tropical geometry (Newton polygons, tropical varieties), potentially enabling tropical methods to predict algebraic properties of unknown connective constants.

**Catalog References**: `Algebra/SAWTropical/GrowthRate.lean` (nienhuis_minimal_poly, NienhuisConstant), `Catalog/Algebra/Tropical.lean`

**Proof Strategy**:
1. Define tropical polynomials as piecewise-linear functions max(a_i + i·v).
2. Define tropical roots as corners (points where the maximum is achieved by ≥ 2 linear terms).
3. Compute the tropicalization of x⁴ − 4x² + 2: coefficients are (1, 0, −4, 0, 2), so tropicalized coefficients are (0, −∞, log 4, −∞, log 2).
4. The tropical polynomial is max(4v, 2v + log 4, log 2) (ignoring −∞ terms).
5. Find tropical roots by equating adjacent terms and verify they correspond to valuations of classical roots.

**Domain Bridges**: Algebra (minimal polynomials) ↔ Tropical Geometry (Newton polygons) ↔ Number Theory (algebraic irrationals)

**Lineage**: Builds on nienhuis_minimal_poly from this cycle.

**Ambition**: extension
