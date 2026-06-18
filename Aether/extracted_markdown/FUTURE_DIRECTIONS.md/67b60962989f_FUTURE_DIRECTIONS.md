# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational layer of hyperbolic arithmetic on the Poincaré disk: we defined hyperbolic integers as orbit points of PSL(2,ℤ), proved the Fricke trace identity connecting character varieties to the Markov surface, established the Chebyshev trace recurrence governing exponential growth of matrix powers, and showed that the trace spectrum of SL₂(ℤ) covers all of ℤ. The Vieta involution was proved to preserve the Markov surface, providing the mechanism that generates the infinite tree of Markov triples.

The most promising cross-domain connection is the **Fricke–Markov bridge**: the cubic surface x² + y² + z² − xyz = κ arises simultaneously from (1) the character variety of PSL(2,ℤ) through the Fricke identity, (2) the classical Markov equation from Diophantine approximation, and (3) the trace coordinates of representations of surface groups. This triple connection means that theorems proved in any one domain automatically transfer to the others. The Chebyshev trace recurrence provides the computational backbone, connecting matrix powers to orthogonal polynomials and spectral theory.

The highest breakthrough potential lies in Direction 1 (the hyperbolic zeta function), because the Selberg trace formula already provides machinery to analyze spectral properties of the Laplacian on Γ\𝔻, and our trace growth theorem (Theorem 4.2) gives the growth bounds needed to establish convergence of the Dirichlet series.

---

### Direction 1: The Hyperbolic Zeta Function and Spectral Theory

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{g ≠ id, g ∈ PSL(2,ℤ)} ℓ(g)^{-2s}, where ℓ(g) is the displacement length of g at the origin, converges for Re(s) > 1/2 and admits meromorphic continuation to ℂ with a simple pole at s = 1/2. The residue at this pole is related to the covolume π/3 of the fundamental domain.

**Test**: Compute ζ_H(s) numerically for s ∈ {1, 3/2, 2, 5/2} by truncating the sum over elements of word length ≤ 15 in the generators {S, T}. Verify convergence rates and compare the pole structure to the Selberg zeta function Z_Γ(s).

**Impact**: If confirmed, this would provide a "number-theoretic zeta function" living natively on the hyperbolic plane, distinct from but related to the Selberg zeta function. The connection between ζ_H and the spectral decomposition of L²(Γ\𝔻) could yield new insights into the distribution of eigenvalues of the Laplacian.

**Catalog References**: `MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean` (SL₂(ℤ) trace arithmetic), `Geometry/HyperbolicArithmetic/Theorems.lean` (Chebyshev recurrence, trace growth)

**Proof Strategy**: (1) Establish absolute convergence of ζ_H(s) for Re(s) > 1/2 using the trace growth bound tr(gⁿ) ≥ n·(tr(g)−1)+1 and the orbit counting estimate N(R) ~ Ce^R. (2) Use the Selberg trace formula to relate ζ_H to the spectrum of the Laplacian. (3) Prove meromorphic continuation by connecting to Eisenstein series.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry, SpectralTheory <-> AnalyticNumberTheory

**Lineage**: Builds on fricke_trace_identity, chebyshev_trace_recurrence, trace_growth_hyperbolic from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Markov Uniqueness via Trace Rigidity

**Conjecture**: The Markov Uniqueness Conjecture — that a Markov number uniquely determines its Markov triple up to permutation — can be proved by showing that the corresponding SL₂(ℤ) conjugacy class is determined by its trace. Specifically, if two primitive hyperbolic elements g, h ∈ SL₂(ℤ) have the same trace and both participate in a Markov triple via the Fricke identity, then they are conjugate in SL₂(ℤ).

**Test**: Verify computationally for all Markov numbers up to 10^6 that distinct Markov triples with the same maximal element do not exist. Formalize the uniqueness for the first 100 Markov numbers.

**Impact**: The Markov Uniqueness Conjecture has been open since 1913. A proof via trace rigidity would connect the combinatorial structure of the Markov tree to the geometric structure of closed geodesics on the modular surface. Even partial progress (e.g., proving uniqueness for Markov numbers that are prime) would be significant.

**Catalog References**: `MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean` (MarkovTriple, Vieta involution), `Geometry/HyperbolicArithmetic/Theorems.lean` (vieta_involution, fricke_implies_markov)

**Proof Strategy**: (1) Formalize the bijection between Markov triples and ideal triangulations of the once-punctured torus. (2) Prove that the Dehn twist action on ideal triangulations corresponds to the Vieta involution on traces. (3) Use the trace rigidity of PSL(2,ℤ) to show that the triangulation is determined by the maximal Markov number.

**Domain Bridges**: NumberTheory <-> TopologicalSurfaceTheory, Algebra <-> CombinatorialGeometry

**Lineage**: Builds on vieta_involution, fricke_implies_markov, markov_root_on_surface from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Limit of Hyperbolic Arithmetic

**Conjecture**: The Gromov product (a|b)_o = ½(d_H(a,o) + d_H(b,o) − d_H(a,b)) on the PSL(2,ℤ) orbit converges, as the orbit points are projected to the boundary ∂𝔻, to the tropical metric on the Farey graph. The Farey graph itself is the 1-skeleton of the ideal triangulation of the modular surface, and its tropical structure encodes the continued fraction expansion of real numbers.

**Test**: Compute the Gromov products for orbit points of word length ≤ 10 and verify that they approximate the tree distance on the Farey graph to within O(δ) where δ is the hyperbolicity constant of the Cayley graph.

**Impact**: This would establish a precise functor from hyperbolic arithmetic to tropical arithmetic, allowing tools from tropical geometry (Newton polygons, Berkovich spaces) to be applied to number-theoretic problems. It would also connect the Markov tree to the Stern-Brocot tree via a metric deformation.

**Catalog References**: `Tropical/Hyperbolicity.lean`, `Geometry/HyperbolicArithmetic/Defs.lean` (hypDist, möbiusParam)

**Proof Strategy**: (1) Define the Gromov product on orbit points using the formalized hyperbolic distance. (2) Show that the Gromov product satisfies the four-point condition with constant δ. (3) Identify the asymptotic cone (boundary tree) with the Farey graph. (4) Prove that the tropical metric on the Farey graph equals the limit of rescaled Gromov products.

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, NumberTheory <-> MetricGeometry

**Lineage**: Builds on hypDist, möbiusParam, DiskPoint from this cycle, plus `Tropical/Hyperbolicity.lean` from the Catalog.

**Ambition**: extension

---

### Direction 4: Quantum Modular Forms and Trace Statistics

**Conjecture**: The distribution of tr(g) mod p, as g ranges over elements of PSL(2,ℤ) with word length ≤ n, converges to the Sato-Tate distribution (semicircular) rescaled to [-2,2] as n → ∞, for each prime p > 2. More precisely, the fraction of elements with tr(g) ≡ t (mod p) converges to 1/p for each residue class t, but the joint distribution of (tr(g) mod p₁, tr(g) mod p₂) for distinct primes exhibits subtle correlations governed by the Ramanujan conjecture for the modular surface.

**Test**: Enumerate elements of word length ≤ 12 and compute the trace distribution modulo primes p = 3, 5, 7, 11, 13. Compare to the uniform distribution and measure the chi-squared statistic.

**Impact**: This would connect the combinatorial structure of the Cayley graph to deep results in automorphic forms (the Ramanujan-Petersson conjecture). Even the uniformity statement (equal distribution of traces mod p) is non-trivial and would imply spectral gap bounds for certain Cayley graphs.

**Catalog References**: `Geometry/HyperbolicArithmetic/Theorems.lean` (trace_spectrum_is_all, chebyshev_trace_recurrence), `EML/ModularForms.lean` (S_gen, T_sq)

**Proof Strategy**: (1) Reduce the trace distribution problem to counting paths on the Cayley graph of PSL(2,ℤ/pℤ). (2) Use the representation theory of SL₂(𝔽_p) to decompose the path-counting problem into character sums. (3) Apply the Weil bound for character sums to establish equidistribution.

**Domain Bridges**: NumberTheory <-> RepresentationTheory, Algebra <-> Probability

**Lineage**: Builds on trace_spectrum_is_all and the Chebyshev recurrence from this cycle.

**Ambition**: extension

---

### Direction 5: Displacement Length Spectrum and Length Rigidity

**Conjecture**: The displacement length spectrum {ℓ(g) : g ∈ PSL(2,ℤ), g hyperbolic} determines the fundamental domain of PSL(2,ℤ) up to isometry. That is, if Γ₁ and Γ₂ are two cofinite Fuchsian groups with the same displacement length spectrum, then Γ₁ and Γ₂ are conjugate in PSL(2,ℝ).

**Test**: Compute the displacement lengths of the first 1000 hyperbolic elements (sorted by word length) for PSL(2,ℤ) and for a congruence subgroup Γ(2). Verify that the spectra differ, confirming that non-conjugate groups have distinct spectra in these cases.

**Impact**: Length rigidity results are central to spectral geometry (the "Can you hear the shape of a drum?" problem). For Fuchsian groups, positive results are known for the *primitive* length spectrum (closed geodesics). Extending this to the displacement spectrum at a base point would connect lattice point counting to isospectral geometry.

**Catalog References**: `Geometry/HyperbolicArithmetic/Defs.lean` (displacementLength, HyperbolicLattice), `Geometry/HyperbolicArithmetic/Theorems.lean` (displacement_id)

**Proof Strategy**: (1) Formalize the displacement length as a function of the trace via ℓ(g) = 2·arccosh(|tr(g)|/2) for hyperbolic elements. (2) Show that the displacement spectrum determines the trace spectrum (by the arccosh bijection on [2,∞)). (3) Use Selberg's trace formula to show that the trace spectrum determines the spectral data of the Laplacian. (4) Apply the Sunada criterion or the Vignéras construction to show that spectral data determines the group up to conjugacy.

**Domain Bridges**: HyperbolicGeometry <-> SpectralGeometry, NumberTheory <-> DifferentialGeometry

**Lineage**: Builds on displacementLength, hypDist, and the trace growth results from this cycle.

**Ambition**: extension
