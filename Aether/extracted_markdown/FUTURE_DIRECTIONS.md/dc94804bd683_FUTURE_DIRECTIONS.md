# Future Research Directions

## Synthesis

This research cycle established the **Oracle Capability Lattice** (OCL), a formal algebraic framework for reasoning about different types of access to L-function data. The key discovery is that oracle capabilities decompose into a strict hierarchy where each level enables qualitatively different computations, and the separations between levels are witnessed by constructive barriers (explicit polynomial pairs that are oracle-indistinguishable but property-distinguishable).

The most promising cross-domain connection is between the barrier theorems and computational complexity theory. The vanishing detection duality — one evaluation at the target decides vanishing, but no evaluations elsewhere do — is a precise analogue of the oracle separation paradigm in complexity theory (Baker-Gill-Solovay, 1975). This suggests that the OCL framework could provide new lower bounds for arithmetic problems in classical complexity classes, connecting analytic number theory with computational complexity through the bridge of oracle hierarchies.

The cycle's results connect to the existing Catalog via the `MachineLearning/LFunctionOracle/Core.lean` hierarchy (extending it with constructive barriers and composition theory) and the `Bridges/` framework (providing a new bridge between analytic number theory and computational complexity). The highest breakthrough potential lies in Direction 1 (Oracle Complexity Classes), which could establish genuinely new connections between the Selberg class and computational complexity.

---

### Direction 1: Oracle Complexity Classes for Arithmetic Functions

**Conjecture**: Define complexity classes P^L(k) = problems solvable in polynomial time with k oracle calls to a level-L oracle (where L ∈ {point, derivative, zero-cert, full}). Then there exist natural arithmetic problems that separate P^{deriv}(1) from P^{point}(poly(n)) — that is, one derivative query is more powerful than polynomially many point queries for certain problems.

**Test**: Formalize the complexity classes P^L(k) in Lean 4. Prove that the vanishing-order-detection problem lies in P^{deriv}(1) but not in P^{point}(k) for any fixed k, using the barrier theorems from this cycle. Then identify a natural arithmetic problem (e.g., analytic rank computation for elliptic curves of conductor ≤ N) and prove tight query complexity bounds.

**Impact**: This would establish a formal connection between oracle hierarchies in analytic number theory and the polynomial hierarchy in computational complexity. If the separation is tight, it would provide the first provable query complexity lower bounds for BSD-type problems.

**Catalog References**: `Bridges/OracleCapabilityLattice.lean` (barrier theorems, derivative advantage), `MachineLearning/LFunctionOracle/Core.lean` (oracle hierarchy definitions)

**Proof Strategy**: Define P^L(k) as the class of decision problems decidable by polynomial-time Turing machines with k oracle calls to level L. Prove the separation by reduction from the barrier theorem: if vanishing-order detection were in P^{point}(k), extract k query points, apply the barrier to get indistinguishable witnesses, contradicting decidability.

**Domain Bridges**: Analytic Number Theory <-> Computational Complexity Theory <-> Oracle Computation

**Lineage**: Builds on the barrier theorems and derivative advantage theorem from this cycle. Extends the oracle hierarchy in `MachineLearning/LFunctionOracle/Core.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Oracle Barriers via Valuations

**Conjecture**: The vanishing polynomial barrier has a tropical analogue: for tropical L-functions (defined via the max-plus semiring), the "tropical vanishing order" at a point cannot be determined by finitely many tropical evaluations at other points. Moreover, the tropical barrier is *sharper* — the indistinguishable witness pair can be chosen to be piecewise-linear functions with at most |Q| + 1 pieces.

**Test**: Define tropical L-functions as piecewise-linear functions on ℝ. Define tropical vanishing order as the slope change at a point. Prove that the tropical barrier holds with the sharper bound. Compare the tropical barrier with the complex barrier to identify structural differences.

**Impact**: Tropical geometry provides a "skeleton" of algebraic geometry that is often computationally tractable. If tropical barriers are sharper, they could provide better lower bounds for oracle complexity. This also connects the OCL framework to the existing tropical mathematics in the Catalog.

**Catalog References**: `Tropical/` (tropical semiring foundations), `Bridges/TropicalMellin/` (tropical-analytic connections), `Bridges/OracleCapabilityLattice.lean`

**Proof Strategy**: Define tropical vanishing polynomial VP^trop_Q(x) = max_{q ∈ Q}(x - q). Show it equals 0 on Q and is positive off Q (in tropical sense). The barrier follows by the same argument as the complex case.

**Domain Bridges**: Tropical Geometry <-> Oracle Hierarchies <-> Computational Complexity

**Lineage**: Builds on the barrier theorems from this cycle and the tropical mathematics in `Tropical/`.

**Ambition**: extension

---

### Direction 3: Information-Theoretic Oracle Capacity

**Conjecture**: Define the "oracle capacity" C(P, L) of a decision problem P at oracle level L as the infimum of queries needed to decide P. Then for the vanishing detection problem V(s₀): C(V(s₀), point) = 1 if s₀ is in the query set, ∞ otherwise. For the vanishing order problem VO(s₀, k): C(VO(s₀, k), deriv) = k+1, and C(VO(s₀, k), point) = ∞.

**Test**: Prove the exact capacity formulas in Lean 4. For the vanishing order problem, prove both the upper bound (k+1 derivative queries suffice: evaluate f^(0)(s₀), ..., f^(k)(s₀)) and the lower bound (k queries don't suffice: construct indistinguishable witnesses).

**Impact**: Exact capacity formulas would give a complete picture of the information content of each oracle type. The capacity function C(·, ·) would be a new mathematical invariant connecting decision problems with oracle hierarchies.

**Catalog References**: `Bridges/OracleCapabilityLattice.lean` (barrier theorems, query subadditivity), `Computation/InfoEfficientAlgorithms.lean` (information-efficient computation)

**Proof Strategy**: Upper bound: construct an explicit algorithm. Lower bound: for each k, construct two functions with vanishing orders k and k+1 that agree on any k-element query set. Use the interpolation theory of complex polynomials.

**Domain Bridges**: Information Theory <-> Oracle Computation <-> Analytic Number Theory

**Lineage**: Builds on the query subadditivity and barrier theorems from this cycle.

**Ambition**: extension

---

### Direction 4: Selberg Class Enumeration via Oracle Fingerprints

**Conjecture**: Two L-functions in the Selberg class with the same conductor and degree are determined up to twist by their values at finitely many points (an "oracle fingerprint"). Specifically, evaluating at O(d² log N) points suffices to distinguish all L-functions of degree d and conductor N, where the constant is effective.

**Test**: For degree 1 (Dirichlet L-functions), prove that evaluating at O(log N) points suffices to determine the Dirichlet character. For degree 2 (modular form L-functions), prove or disprove that O(log² N) evaluations suffice. Compare with the counting bounds in `MachineLearning/LFunctionCensus/`.

**Impact**: Oracle fingerprints would provide an efficient "address system" for L-functions — a way to uniquely identify any L-function from a small number of samples. This has applications to the LMFDB and to algorithms that search for L-functions with specific properties.

**Catalog References**: `MachineLearning/LFunctionCensus/Defs.lean` (Selberg data, conductor counting), `MachineLearning/LFunctionUniverse/Defs.lean` (finite-description L-data), `MachineLearning/LFunctionOracle/Core.lean` (identity principle)

**Proof Strategy**: For degree 1: use the orthogonality of Dirichlet characters and the identity principle. The number of characters mod N is φ(N) = O(N), so log₂(φ(N)) = O(log N) evaluations suffice by a counting argument. For degree 2: use the Hecke theory of modular forms and the dimension formula for spaces of modular forms.

**Domain Bridges**: Analytic Number Theory <-> Information Theory <-> Database Theory

**Lineage**: Builds on the identity principle from `Core.lean` and the counting theory from `LFunctionCensus/`.

**Ambition**: grand_challenge

---

### Direction 5: Constructive Zero-Certificate Algorithms

**Conjecture**: For the Riemann zeta function, a zero-certificate for height T can be constructed from O(T log T) derivative evaluations at points on the critical line, using Turing's method and the argument principle.

**Test**: Formalize Turing's method for isolating zeros of ζ(s) using the argument principle. Prove that O(T log T) evaluations of ζ'(1/2 + it)/ζ(1/2 + it) suffice to certify all zeros up to height T. Compare the theoretical bound with the actual computational cost in the Platt verification.

**Impact**: This would give an explicit reduction from zero-certificate oracle to derivative oracle, collapsing one level of the hierarchy for the specific case of ζ(s). Understanding when and why levels collapse is key to understanding the true structure of the oracle lattice.

**Catalog References**: `Bridges/OracleCapabilityLattice.lean` (oracle hierarchy, RH decomposition), `MachineLearning/LFunctionOracle/Core.lean` (zero-certificate oracle definition)

**Proof Strategy**: Use the argument principle: the number of zeros in a rectangle equals (1/2πi) ∮ ζ'/ζ dz, which can be approximated by evaluating ζ'/ζ at discretization points. Bound the approximation error using the Euler-Maclaurin formula. The O(T log T) bound comes from the density of zeros up to height T.

**Domain Bridges**: Complex Analysis <-> Computational Number Theory <-> Oracle Hierarchies

**Lineage**: Builds on the RH decomposition and zero-certificate oracle from this cycle.

**Ambition**: extension
