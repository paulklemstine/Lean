# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundations of arithmetic on the Poincaré disk: Möbius maps as hyperbolic translations, orbit containment by induction, orbit composition as the structural basis for factorization, and a trace-lattice duality bridging geometry to spectral theory. All 12 theorems were formally verified with no sorries.

The most promising cross-domain connection is the **spectral bridge**: the trace-lattice duality (Theorem `trace_lattice_sum` in `Speculative/HyperbolicNumberTheory.lean`) is a finite-dimensional shadow of the Selberg trace formula, which connects geometry of hyperbolic surfaces to eigenvalues of the Laplacian. Extending this from our finite orbit setting to infinite lattices under Fuchsian groups would connect hyperbolic number theory to the theory of automorphic forms and potentially to the Riemann Hypothesis via the Selberg zeta function.

The orbit composition theorem (`orbit_composition`) establishes that the additive structure of ℕ embeds into Möbius orbit composition. This means classical number theory results — primality, unique factorization, the prime number theorem — transfer to the hyperbolic setting by construction. The deeper question is whether the *geometry* of hyperbolic primes (their distribution in the disk) encodes new information beyond what the orbit index already tells us. The equidistribution conjecture (Direction 2) and tropical-hyperbolic duality (Direction 3) are the most promising avenues for discovering genuinely new phenomena.

---

### Direction 1: Selberg Zeta Function and Spectral Rigidity

**Conjecture**: For a Fuchsian group Γ of the first kind acting on the Poincaré disk, the hyperbolic zeta function ζ_H(s) = ∑_{γ∈Γ, γ≠id} |γ(0)|^{−2s} has a meromorphic continuation to ℂ and satisfies a functional equation relating s to 1−s. Its non-trivial zeros lie on Re(s) = 1/2.

**Test**: For the modular group Γ = PSL(2,ℤ) acting on the upper half-plane (conformally equivalent to the disk), compute ζ_H(s) for s along the critical line and verify the first 50 zeros have Re(s) = 1/2. Compare with the known Selberg zeta function zeros.

**Impact**: If true, this would establish a Riemann Hypothesis for hyperbolic zeta functions, potentially providing a geometric proof strategy for the classical RH via spectral methods. If false, the failure mode would reveal which geometric features of the lattice control the zero distribution.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Speculative/HyperbolicNumberTheory.lean` (hypZetaPartial, trace_lattice_sum)

**Proof Strategy**: (1) Prove meromorphic continuation using the Eisenstein series and spectral decomposition of L²(Γ\H). (2) Establish the functional equation via the Maass-Selberg relation. (3) Connect zeros of ζ_H to eigenvalues of the Laplacian on Γ\H. (4) Apply Selberg's result that eigenvalues are ≥ 1/4 for congruence subgroups.

**Domain Bridges**: NumberTheory <-> SpectralTheory, HyperbolicGeometry <-> AnalyticNumberTheory

**Lineage**: Builds on `orbit_stays_in_disk`, `trace_lattice_sum`, and `hypZetaPartial_nonneg` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Equidistribution of Hyperbolic Orbit Points

**Conjecture**: For a generator a ∈ D with 0 < |a| < 1 and arg(a) irrational (as a multiple of π), the angular distribution of the orbit points θ_n = arg(z_n) becomes equidistributed modulo 2π in the sense that for any arc [α, β] ⊂ [0, 2π):

lim_{N→∞} #{n ≤ N : θ_n ∈ [α,β]} / N = (β − α) / (2π)

**Test**: For the generator a = 0.3 + 0.2i, compute 10,000 orbit points and perform a Kolmogorov-Smirnov test against the uniform distribution on [0, 2π). The test should pass at the 5% significance level.

**Impact**: Equidistribution would connect hyperbolic orbits to ergodic theory of the geodesic flow and would justify treating the hyperbolic integers as a "random" lattice for statistical number theory purposes.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory.lean` (moebiusOrbitGen, orbit_stays_in_disk)

**Proof Strategy**: (1) Express the Möbius map in polar coordinates. (2) Show the induced map on angles is an irrational rotation modulo corrections from the radial component. (3) Apply Weyl's equidistribution theorem for irrational rotations. (4) Handle the radial coupling via mixing estimates.

**Domain Bridges**: HyperbolicGeometry <-> ErgodicTheory, NumberTheory <-> DynamicalSystems

**Lineage**: Builds on the orbit machinery (`moebiusOrbitGen`, `orbit_stays_in_disk`) from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical-Hyperbolic Duality

**Conjecture**: There exists a "tropicalization" functor T from hyperbolic arithmetic to tropical arithmetic such that:
- T(hypAdd(z, w)) = max(T(z), T(w))  (tropical addition)
- T(moebiusMap a z) = T(z) − T(a)  (tropical translation)
- The tropicalization T(z) = −log(1 − |z|²) maps the hyperbolic distance to the tropical metric.

**Test**: Verify the identities T(hypAdd(z, w)) = max(T(z), T(w)) for 1000 randomly sampled pairs (z, w) in the disk with |z|, |w| < 0.99. The identity should hold approximately (within numerical precision of 10⁻¹⁰).

**Impact**: A rigorous tropical-hyperbolic duality would bridge two seemingly unrelated areas: non-Euclidean geometry and combinatorial optimization. It would provide tropical geometry with a new source of examples from hyperbolic lattices, and give hyperbolic geometry access to tropical techniques (matroids, Newton polytopes, Bergman fans).

**Catalog References**: `Catalog/Tropical/` (tropical arithmetic), `Catalog/Speculative/HyperbolicNumberTheory.lean` (hypAdd, moebiusMap)

**Proof Strategy**: (1) Define the tropicalization map T(z) = −log(1 − |z|²). (2) Show T maps the disk (0 ≤ |z| < 1) to [0, ∞). (3) Compute T(φ_a(z)) using the normSq complement identity. (4) Show that in the limit |z|, |w| → 1, T(hypAdd(z,w)) → max(T(z), T(w)).

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, NumberTheory <-> CombinatorialOptimization

**Lineage**: Builds on `moebiusMap_normSq_complement` and `hypAdd` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Non-Commutative Factorization Theory

**Conjecture**: The monoid of Möbius orbit compositions (with composition as multiplication) is a *Garside monoid* — a cancelative monoid with lattice structure on its divisibility poset. Consequently, every element has a unique *greedy normal form* analogous to the left-greedy normal form in braid groups.

**Test**: For the golden generator, compute the orbit compositions for all n ≤ 100 and verify: (1) left and right cancellation hold; (2) the divisibility poset has a lattice structure; (3) the greedy normal form is computable in O(n log n) time.

**Impact**: Garside structure would import the powerful theory of braid groups and Artin groups into hyperbolic number theory. It would provide canonical "prime factorizations" that respect the non-commutativity, and could have applications in cryptography (non-commutative key exchange protocols using hyperbolic group elements).

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory.lean` (orbit_composition, hypAdd), `Catalog/Cryptography/` (cryptographic applications)

**Proof Strategy**: (1) Prove left and right cancellation from injectivity of Möbius maps. (2) Define the partial order by divisibility: a | b iff orbit(a, z_m, k) = z_n for some m, k. (3) Show the partial order is a lattice using the Euclidean algorithm on orbit indices. (4) Construct the greedy normal form.

**Domain Bridges**: HyperbolicGeometry <-> GroupTheory, NumberTheory <-> Cryptography

**Lineage**: Builds on `orbit_composition` from this cycle.

**Ambition**: extension

---

### Direction 5: Hyperbolic Lattice Point Counting and Weyl's Law

**Conjecture**: For a generator a ∈ D with |a|² = q ∈ (0,1), the number of orbit points with |z_n|² ≤ r satisfies:
$$N(r) = \frac{\log((1-q)^{-1})}{\log(q^{-1})} \cdot \log\left(\frac{1}{1-r}\right) + O(1) \quad \text{as } r \to 1^-$$

**Test**: For the golden generator (q ≈ 0.1459), compute N(r) for r = 0.9, 0.99, 0.999, 0.9999 and verify the linear relationship between N(r) and log(1/(1−r)). The slope should be approximately log((1−0.1459)^{−1})/log(0.1459^{−1}) ≈ 0.0817.

**Impact**: An explicit asymptotic for the lattice counting function would be the hyperbolic analog of the prime number theorem and would quantify how "dense" the hyperbolic integers are in different regions of the disk.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory.lean` (orbit_stays_in_disk, goldenGenerator_in_disk)

**Proof Strategy**: (1) Show |z_n|² is monotonically increasing for real generators. (2) Derive the recurrence |z_{n+1}|² = f(|z_n|²) where f(x) = (x + q − 2q√x cos θ)/(1 + qx − 2q√x cos θ). (3) For real generators (θ=0), simplify to f(x) = ((√x − √q)/(1 − √(qx)))². (4) Solve the recurrence asymptotically.

**Domain Bridges**: HyperbolicGeometry <-> AsymptoticAnalysis, NumberTheory <-> DynamicalSystems

**Lineage**: Builds on `orbit_stays_in_disk` and `goldenGenerator_in_disk` from this cycle.

**Ambition**: extension
