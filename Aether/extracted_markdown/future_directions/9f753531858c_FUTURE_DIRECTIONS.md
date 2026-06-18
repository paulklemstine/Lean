# Future Research Directions: Gravity from Information

## Synthesis

This research cycle established the algebraic foundation for treating spacetime as a quantum error-correcting code. The central result — that the Bekenstein-Hawking entropy formula is algebraically identical to the quantum Singleton bound — bridges quantum information theory, gravitational physics, and coding theory in a formally verified framework. The holographic entropy cone constraints (monogamy of mutual information) were shown to follow from strong subadditivity applied to overlapping regions, while the AdS₃ specialization demonstrated exact Singleton saturation.

The most promising cross-domain connection is between the **holographic entropy cone** and **post-quantum cryptographic security bounds**. The SSA rigidity theorems (ssa_rigidity, ssa_sum_bound) constrain entropy vectors in ways that mirror security reduction arguments in cryptographic protocols. Meanwhile, the syndrome-curvature correspondence opens a bridge between **physical error correction** and **computational complexity** — if gravity is syndrome extraction, then gravitational dynamics is a particular form of decoding.

The highest breakthrough potential lies in **Direction 1** (Dynamical Holographic Codes), because extending the static framework to time-dependent codes would capture black hole formation and evaporation — directly addressing the information paradox. **Direction 3** (Holographic Entropy Cone for N Parties) also has high potential, as characterizing the full cone would yield new inequalities with applications in both quantum gravity and quantum information.

---

### Direction 1: Dynamical Holographic Codes and Black Hole Evaporation

**Conjecture**: There exists a one-parameter family of holographic codes C(t) = [[n(t), k(t), d(t)]] parameterizing the formation and evaporation of a black hole, such that:
1. k(t) follows the Page curve: k increases then decreases
2. d(t) decreases monotonically (the code distance shrinks as the black hole evaporates)
3. At all times, the quantum Singleton bound k(t) + 2d(t) ≤ n(t) + 2 is satisfied
4. The "Page time" t_P (where k is maximized) occurs at d(t_P) = n(t_P)/4

**Test**: Construct an explicit family C(t) for t ∈ {0, 1, ..., T} with n(t) = N - t (boundary shrinks as Hawking radiation is emitted), k(t) = min(t, N-t)/2 (Page curve), d(t) = (N-t)/4 (distance shrinks). Verify the Singleton bound at every time step. Compute the entanglement entropy between radiation and remaining black hole.

**Impact**: If true, this provides a coding-theoretic derivation of the Page curve without invoking the replica trick or gravitational path integrals. If false, it constrains which aspects of black hole evaporation can be captured by finite-dimensional codes.

**Catalog References**: `Cryptography/HolographicGravityCode.lean` (HolographicCode, ads3Code), `Computation/GravityOracle.lean` (IsGravOracle)

**Proof Strategy**: Define a `DynamicalHolographicCode` structure extending `HolographicCode` with time-dependent parameters. Prove the Page curve property as a theorem about min(t, N-t). The key lemma is that Singleton saturation at each time step forces the Page time to equal N/2. Use omega/linarith for the arithmetic.

**Domain Bridges**: Quantum Information ↔ General Relativity ↔ Cryptography (time-dependent security parameters)

**Lineage**: Builds on HolographicCode, ads3_saturated, page_curve_symmetry from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tensor Network Realization of Holographic Codes

**Conjecture**: The HAPPY (Harlow-Akers-Pastawski-Preskill-Yoshida) pentagon/hexagon tensor network on a hyperbolic tiling realizes a holographic code [[n, k, d]] where:
1. n = number of boundary legs
2. k = number of bulk legs
3. d = radius of the tiling (number of layers from center to boundary)
4. The code saturates the quantum Singleton bound when the bond dimension equals the local tensor dimension

**Test**: For a hyperbolic tiling {5,4} (pentagons, 4 meeting at a vertex) with L layers:
- Compute n(L), k(L), d(L) for L = 1, 2, 3, 4, 5
- Verify k(L) + 2d(L) ≤ n(L) + 2 at each layer
- Check whether saturation holds (is the code MDS-like?)

**Impact**: If true, provides a constructive realization of holographic codes from a concrete combinatorial object (tiling). The growth rates of n, k, d determine the effective spacetime dimension.

**Catalog References**: `Cryptography/HolographicGravityCode.lean` (HolographicCode, TensorNetwork), `Cryptography/HexHoneycomb/Basic.lean` (hex_patch_edge_boundary_minimal_at_hex_number)

**Proof Strategy**: Define a `HyperbolicTiling` structure with layer count, vertices per layer, and edge connectivity. Compute boundary/bulk counts combinatorially. The key insight is that for {p,q} tilings, the boundary grows exponentially while the bulk grows as a sum, so k/n → 0 — unlike the AdS₃ case where k/n → 2/3. This would distinguish 2D (tiling-based) from 3D (CFT-based) holographic codes.

**Domain Bridges**: Geometry (hyperbolic tilings) ↔ Quantum Information (tensor networks) ↔ Cryptography (code parameters)

**Lineage**: Builds on TensorNetwork, tensor_network_entropy_bound, and the hexagonal honeycomb results in the Catalog.

**Ambition**: extension

---

### Direction 3: Complete Characterization of the N-Party Holographic Entropy Cone

**Conjecture**: For N ≥ 4 boundary regions, the holographic entropy cone is strictly smaller than the quantum entropy cone, and the gap grows with N. Specifically, for N parties there exist at least N(N-1)(N-2)/6 independent holographic inequalities beyond strong subadditivity.

**Test**: For N = 4, enumerate all inequalities of the form Σ aᵢ S(Aᵢ) ≥ 0 satisfied by holographic entropies (computed via the Ryu-Takayanagi formula on graphs) but not by general quantum states. The known result is that for N = 4, there are exactly 5 independent holographic inequalities beyond SSA. Verify this count computationally.

**Impact**: Characterizing the holographic entropy cone determines precisely which entanglement structures are "geometric" (arise from spacetime) vs "non-geometric" (require more exotic quantum states). This has implications for the emergence of spacetime from entanglement.

**Catalog References**: `Cryptography/HolographicGravityCode.lean` (HolographicEntropy, mmi_implies_conditional_nonneg, ThreePartyHolographic, ssa_rigidity)

**Proof Strategy**: Extend ThreePartyHolographic to FourPartyHolographic with 15 entropy variables (2⁴ - 1 non-empty subsets). Formalize the 5 known inequalities for N=4. The key challenge is proving that these are independent — construct explicit holographic entropies (from graph models) that saturate each inequality individually.

**Domain Bridges**: Quantum Information (entropy cones) ↔ Convex Geometry (polyhedral cones) ↔ Graph Theory (min-cut max-flow)

**Lineage**: Builds on HolographicEntropy, mmi_implies_conditional_nonneg, ssa_rigidity from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Syndrome Dynamics and Linearized Gravity

**Conjecture**: The linearized Einstein equations around flat spacetime are equivalent to the syndrome update equations of a holographic code under single-qubit Pauli errors. Specifically, if the syndrome vector s(t) encodes the extrinsic curvature at time t, then the linearized constraint equations ∂ᵢπⁱⱼ = 0 (momentum constraint) correspond to the condition that the syndrome lies in the image of the parity-check matrix.

**Test**: For a 1+1 dimensional lattice model:
1. Define a stabilizer code with parity-check matrix H
2. Inject a single Pauli-X error at site j
3. Compute the syndrome s = He_j
4. Verify that s satisfies the discrete analog of the momentum constraint
5. Compare the syndrome propagation under code deformation with the wave equation

**Impact**: If true, this provides a microscopic derivation of linearized gravity from quantum error correction, completing the picture from "gravity = syndrome" at the kinematic level to the dynamical level.

**Catalog References**: `Cryptography/HolographicGravityCode.lean` (Syndrome, zero_syndrome_flat, nonzero_syndrome_curved), `Computation/GravityOracle.lean` (IsGravOracle, geodesic_oracle_idempotent)

**Proof Strategy**: Define a `StabilizerCode` structure with parity-check matrix H. Define syndrome dynamics as s(t+1) = H · e(t) where e(t) is the error pattern. Show that the constraint H^T s = 0 (always satisfied) is the discrete momentum constraint. The key lemma: for CSS codes, the X-syndrome and Z-syndrome decouple, corresponding to the scalar and tensor modes of linearized gravity.

**Domain Bridges**: Physics (linearized gravity) ↔ Quantum Information (stabilizer codes) ↔ Cryptography (syndrome decoding)

**Lineage**: Builds on Syndrome, zero_syndrome_flat, nonzero_syndrome_curved from this cycle.

**Ambition**: extension

---

### Direction 5: Holographic Codes and Quantum Cryptographic Protocols

**Conjecture**: The holographic code structure provides a natural framework for quantum secret sharing: the code distance d determines the number of boundary parties needed to reconstruct any bulk secret, and the MMI inequality ensures that no proper subset of fewer than d parties can extract information about the secret.

**Test**: Construct a quantum secret sharing protocol from the AdS₃ code:
1. The dealer encodes k secret qubits into n boundary qubits using the holographic encoding
2. Distribute the n qubits among m parties
3. Verify that any d parties can reconstruct the secret (completeness from bulk_reconstruction)
4. Verify that fewer than d parties have zero mutual information with the secret (security from the Singleton bound)

**Impact**: If true, holographic codes provide a new family of quantum secret sharing schemes with optimal rate and distance, parameterized by spacetime geometry. This bridges quantum gravity and practical quantum cryptography.

**Catalog References**: `Cryptography/HolographicGravityCode.lean` (HolographicCode, bulk_reconstruction, entanglement_wedge_nesting), `Cryptography/Foundation.lean` (soundness_error_bound), `Cryptography/Commitments.lean` (entropy_lower_bound_from_fiber)

**Proof Strategy**: Define a `HolographicSecretSharing` structure extending `HolographicCode` with a dealer and parties. The completeness theorem is essentially bulk_reconstruction. The security theorem requires showing that any set of < d parties has syndrome that is independent of the secret — this uses the properties of MDS codes. Connect to the existing soundness bounds in the Catalog.

**Domain Bridges**: Quantum Gravity (holographic codes) ↔ Cryptography (secret sharing) ↔ Information Theory (capacity bounds)

**Lineage**: Builds on HolographicCode, bulk_reconstruction, entanglement_wedge_nesting from this cycle, and soundness_error_bound, entropy_lower_bound_from_fiber from the Catalog.

**Ambition**: extension
