# Future Directions: Quantum Code Bound Feasibility Theory

## Synthesis

The bound-feasibility framework established here—classifying quantum code parameters into Singleton-forbidden, degeneracy-forcing, and jointly feasible regions—opens a systematic research program at the intersection of combinatorics, topology, and quantum information theory. The central theme linking all directions below is the transformation of *bounds* into *structural classification principles*: not merely asking "does a code exist?" but "what *kind* of code must it be?" Each direction extends this philosophy to richer bound landscapes, higher-dimensional geometries, or deeper algebraic structures.

---

## Direction 1: LP Bound Integration and the Extended Feasibility Polytope

**Conjecture**: The linear programming (LP) bounds of Ashikhmin and Litsyn, combined with the Singleton and Hamming bounds, define a convex feasibility polytope in (n, k, d)-space whose faces correspond to extremal code families (MDS codes, perfect codes, BPT-saturating codes). The degeneracy-forcing region, currently defined by the Singleton–Hamming gap, is a proper subset of a larger "mechanism-forcing" region visible only through the LP bound.

**Test**: Implement the LP bound for stabilizer codes and compute the extended feasibility polytope for n ≤ 30. Compare the boundary of the LP-feasible region with the Hamming boundary. Identify parameter triples that are Hamming-admissible but LP-infeasible—these would represent a new class of "LP-forced degeneracy" that our current framework cannot detect.

**Impact**: This would create the first *complete* computationally-verified feasibility atlas for small quantum codes, immediately useful for stabilizer code search. It would also expose whether the LP and Hamming boundaries are generically transverse (suggesting independent mechanisms) or aligned (suggesting a deeper structural connection).

**Catalog References**: `Physics/Quantum/BoundFeasibility.lean` (Definitions 2.3–2.6, Theorem 1)

**Proof Strategy**: Extend the `BoundClassification` inductive type to include an `lpForbidden` variant. The LP bound requires solving a linear program, which can be certified via dual witnesses in Lean using rational arithmetic. The key lemma would be: LP infeasibility implies ¬NondegenerateCode, via the LP bound's proof structure.

**Domain Bridges**: Optimization theory (LP duality), combinatorial geometry (polytope face enumeration), algorithmic coding theory

**Lineage**: Extends the three-way classifier to a four-way classifier; motivated by the observation that Hamming alone leaves a large "jointly feasible" region that LP bounds can further partition.

**Ambition**: Grand challenge — requires formalizing LP bounds for quantum codes, which involves significant new Mathlib infrastructure.

---

## Direction 2: Topological Code Tradeoffs Beyond the Torus

**Conjecture**: For quantum codes defined on closed orientable surfaces of genus g, the rate–distance product satisfies (k/n)·(d/n) ≤ C·g/n for a universal constant C, generalizing our toric (g = 1) result. Furthermore, hyperbolic surface codes (g growing with n) can break the planar BPT barrier, achieving k·d² = Θ(n·log(n)).

**Test**: Formalize the Euler characteristic constraint for surface codes: k = 4g − 2 + (boundary terms) for CSS codes on genus-g surfaces. Verify the BPT bound k·d² ≤ c·n for g = 1 (already done for toric codes) and compute the rate–distance product for small hyperbolic codes (e.g., {5,4} tilings).

**Impact**: This would establish the first formally verified genus-dependent efficiency bounds for topological codes, directly relevant to proposals for hyperbolic quantum codes that claim asymptotic superiority over planar codes.

**Catalog References**: `Physics/Quantum/BoundFeasibility.lean` (Theorem 3, toric code family), `Catalog/FINAL/Physics/ToricCode.lean`

**Proof Strategy**: Define a `SurfaceCodeFamily` structure parameterized by genus. The key insight is that the Euler characteristic χ = 2 − 2g constrains k via the homology of the surface, giving k = 2 − χ = 2g for a closed surface. The rate bound then follows from k/n ≤ 2g/n combined with the BPT constraint d² ≤ n/k.

**Domain Bridges**: Algebraic topology (homology of surfaces), hyperbolic geometry (Gauss-Bonnet), graph theory (expander graphs on surfaces)

**Lineage**: Direct extension of Theorem 3 (toric codes) to higher-genus surfaces.

**Ambition**: Solid extension — the genus-1 case is complete; higher genus requires modest new formalization.

---

## Direction 3: The Degeneracy Frontier as a Phase Boundary

**Conjecture**: The degeneracy frontier d₀(n, k) (the smallest distance at which parameters become degeneracy-forcing for fixed n, k) satisfies d₀(n, k) ~ c·√(n − k) for large n − k, where c is a universal constant related to the Pauli ball growth rate. Furthermore, d₀ is monotone decreasing in k (for fixed n) and monotone increasing in n (for fixed k).

**Test**: (1) Compute d₀(n, k) for n ≤ 100 and fit the scaling relation. (2) Prove the monotonicity claims formally in Lean. (3) Interpret d₀ as a "phase boundary" in a statistical-mechanical model where Hamming feasibility plays the role of a thermodynamic constraint.

**Impact**: A precise scaling law for d₀ would provide the first quantitative prediction of when degeneracy becomes necessary as a function of redundancy. This has direct implications for fault-tolerance threshold calculations, where the distinction between degenerate and nondegenerate error correction affects threshold values.

**Catalog References**: `Physics/Quantum/BoundFeasibility.lean` (degeneracyForcing definition, computational examples), `Catalog/FINAL/Physics/StabilizerBounds.lean` (hamming_sum_t_one, hamming_sum_exponential_bound)

**Proof Strategy**: The key insight is that the Hamming sum grows polynomially in t for fixed n, while the syndrome space 2^(n−k) is exponential in n−k. The crossover point d₀ occurs where the polynomial catches the exponential. For the first two terms, 1 + 3n ≤ 2^(n−k) gives a lower bound on d₀. For the full sum, the binomial theorem gives V(n, n) = 4^n, providing an upper bound context.

**Domain Bridges**: Statistical mechanics (phase transitions in constraint satisfaction), analytic combinatorics (saddle-point approximations for binomial sums), information theory (channel coding analogy)

**Lineage**: Motivated by the computational observation (Demo 3) that the degeneracy-forcing region is upward-closed; seeks a quantitative explanation.

**Ambition**: Grand challenge — establishing a precise scaling law requires either proving asymptotic estimates for partial binomial sums or developing new combinatorial identities.

---

## Direction 4: Pauli Ball Geometry and Discrete Isoperimetry

**Conjecture**: The Pauli ball V(n, t) satisfies a discrete isoperimetric inequality: among all sets of n-qubit Pauli operators of size V(n, t), the ball minimizes the "Pauli boundary" (number of operators at Hamming distance exactly t+1). This is the quantum analogue of the classical isoperimetric inequality in ℤ₂ⁿ, adapted to the three-letter Pauli alphabet.

**Test**: (1) Formalize the Pauli Hamming metric as a function on Fin n → Fin 4. (2) Define the boundary of a set of Pauli operators. (3) Verify the isoperimetric conjecture computationally for n ≤ 8 by exhaustive enumeration. (4) Prove monotonicity of the shell volumes C(n, t)·3^t in a suitable range.

**Impact**: A discrete isoperimetric inequality for the Pauli metric would provide a deeper geometric foundation for the Hamming bound, potentially enabling tighter sphere-packing bounds for quantum codes. It would also connect quantum coding theory to the rich literature on discrete isoperimetry (Harper's theorem, edge-isoperimetric inequalities).

**Catalog References**: `Physics/Quantum/BoundFeasibility.lean` (pauliBallVolume, pauliBallVolume_mono), `Catalog/FINAL/Physics/StabilizerBounds.lean` (PauliError, PauliError.weight)

**Proof Strategy**: Use the compression technique (Bollobás–Leader) adapted to the ternary alphabet. The key insight is that the Pauli ball is a "canonical" initial segment in a suitable ordering of the Pauli group, and initial segments minimize boundary in this ordering.

**Domain Bridges**: Discrete geometry (isoperimetric inequalities), extremal combinatorics (compression methods), additive combinatorics (sumsets in non-binary groups)

**Lineage**: Extends pauliBallVolume_mono to a stronger structural result about the optimality of balls.

**Ambition**: Solid extension — the monotonicity is already proved; the full isoperimetric result would be a natural next step.

---

## Direction 5: Quantum LDPC Codes and the Feasibility Landscape

**Conjecture**: The recently discovered asymptotically good quantum LDPC codes (achieving constant rate and constant relative distance) lie in a narrow "corridor" of the jointly feasible region that is far from the degeneracy frontier. Specifically, for the known constructions (Panteleev–Kalachev, Leverrier–Zémor), the Hamming ratio V(n,t)/2^(n−k) is bounded away from 1 by a constant that depends on the expansion properties of the underlying graph.

**Test**: (1) Compute the Hamming ratio for known qLDPC parameter families (e.g., the Panteleev–Kalachev construction with n = Θ(ℓ²), k = Θ(n), d = Θ(√n)). (2) Plot the trajectory of these families in the (rate, Hamming_ratio) plane. (3) Compare with the degeneracy frontier to determine how far these codes are from the forced-degeneracy boundary.

**Impact**: Understanding where breakthrough qLDPC codes sit relative to the classical bounds would illuminate *why* they are possible—and suggest whether even better codes might exist closer to the degeneracy frontier.

**Catalog References**: `Physics/Quantum/BoundFeasibility.lean` (jointlyBoundFeasible, classify_jointly_feasible), `Catalog/FINAL/Physics/StabilizerBounds.lean` (binary_quantum_hamming_bound)

**Proof Strategy**: Define a `qLDPCFamily` structure with rate and relative distance parameterized by block length. The key insight is that constant-rate constant-distance codes have Hamming ratio V(n, cn)/2^((1-R)n) ≈ exp(n·h(c)) / exp(n·(1-R)·ln2), where h is the ternary entropy function. Feasibility requires h(c) < (1-R)·ln2.

**Domain Bridges**: Graph theory (expander graphs, Cayley graphs), probability theory (random code ensembles), computational complexity (locally testable codes)

**Lineage**: Applies the feasibility framework to the most important recent development in quantum coding theory.

**Ambition**: Grand challenge — connecting formal feasibility theory to the algebraic machinery of qLDPC codes would be a significant bridge between two active research communities.
