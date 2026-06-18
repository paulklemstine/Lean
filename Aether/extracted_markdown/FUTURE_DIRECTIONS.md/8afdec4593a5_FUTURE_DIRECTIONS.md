# Future Directions: Integrated Information via Tensor Networks

## Conjecture 1: MPS Min-Cut Principle

**Conjecture.** For every normalized Matrix Product State ψ on a chain of n sites with bond dimension D, the integrated information rank equals the minimum contiguous-cut flattening rank:

$$\Phi^\#(\psi) = \min_{1 \le k < n} \operatorname{rank}(\operatorname{Flat}_{\{0,\ldots,k\}}(\psi))$$

In other words, the minimum over *all* nontrivial bipartitions (including non-contiguous ones) is always achieved by a contiguous cut for MPS states.

**Test.** Generate random MPS tensors with various bond dimensions D ∈ {2,3,4,5} and chain lengths n ∈ {3,...,8}, compute Φ# by exhaustive enumeration of all 2^n − 2 bipartitions, and compare against the minimum contiguous-cut rank. A single instance where Φ# < min contiguous-cut rank would falsify the conjecture. Our numerical experiments (1200+ trials) found zero counterexamples.

**Disproof criterion.** A concrete counterexample: an MPS state ψ and a non-contiguous partition A where rank(Flat_A(ψ)) < min_k rank(Flat_{0,...,k}(ψ)).

**Impact.** If true, this reduces the exponential bipartition search to a linear (in n) search over contiguous cuts, making integrated information efficiently computable for all MPS states. This would be the algorithmic foundation for practical IIT calculations in tensor-network physics.

---

## Conjecture 2: Area-Law Stabilization

**Conjecture.** For translation-invariant injective MPS with bond dimension D, the integrated information rank stabilizes and becomes independent of chain length once n ≥ 2D:

$$n \ge 2D \implies \Phi^\#(\psi_n) = \Phi^\#(\psi_{2D})$$

**Test.** Fix an injective transfer matrix T of dimension D × D (verify injectivity by checking that the set {T_i : i = 0,...,d-1} spans the full D² matrix space). Generate the corresponding MPS for n = 2D, 2D+1, ..., 4D and compute Φ# for each. The conjecture predicts all values are identical.

**Disproof criterion.** An injective MPS where Φ# changes between n = 3D and n = 4D for some D.

**Impact.** This would establish that integrated information obeys a strict area law for gapped systems — a deep connection between IIT and condensed matter physics. It would mean consciousness-like integration measures are thermodynamic quantities in the area-law sense.

---

## Conjecture 3: Multiplicativity Under Disconnected Tensor Products

**Conjecture.** For tensor states ψ on system ι and φ on system κ (disjoint), the integrated information rank of their tensor product satisfies:

$$\Phi^\#(\psi \otimes \phi) = \min(\Phi^\#(\psi), \Phi^\#(\phi))$$

**Test.** Construct pairs of random MPS states on separate chains, form their tensor product (a state on the disjoint union), and verify this equality. The key insight: for a bipartition that splits within one subsystem, the rank is determined by that subsystem's cut rank times the full dimension of the other — but for bipartitions that cross the subsystem boundary, the rank factors as a product.

**Disproof criterion.** A pair (ψ, φ) where Φ#(ψ ⊗ φ) ≠ min(Φ#(ψ), Φ#(φ)). Since the ≤ direction should be provable (a cut within ψ gives rank ≤ Φ#(ψ)), a disproof would require Φ#(ψ ⊗ φ) > min(Φ#(ψ), Φ#(φ)).

**Impact.** This would formalize the IIT axiom of exclusion: the integration of a disconnected system equals that of its least-integrated component. It provides a compositional semantics for integration.

---

## Conjecture 4: Rank-Entropy Equivalence for Generic States

**Conjecture.** For generic (full-measure) states on n qubits, the integrated information rank equals 2 raised to the floor of the minimum bipartite entanglement entropy:

$$\Phi^\#(\psi) = 2^{\lfloor S_{\min}(\psi) \rfloor}$$

where $S_{\min}(\psi) = \min_{A} S(\rho_A)$ is the minimum entanglement entropy across bipartitions and $\rho_A = \operatorname{Tr}_{A^c}(|\psi\rangle\langle\psi|)$.

**Test.** For small systems (n = 3, 4, 5 qubits), generate random states from the Haar measure, compute both Φ# and S_min via reduced density matrix eigenvalues, and check the proposed relation. Non-generic states (measure zero) are excluded.

**Disproof criterion.** A Haar-random state where the equality fails. Since this is a measure-theoretic statement, finding counterexamples in a large random sample would strongly suggest falsity.

**Impact.** This would establish a precise dictionary between the algebraic (rank-based) and entropic (von Neumann entropy) formulations of integrated information, bridging quantum information theory and IIT.

---

## Conjecture 5: Stabilizer Code Integration Bound

**Conjecture.** For a stabilizer code [[n, k, d]], any encoded state ψ (image of k logical qubits under the encoding isometry) satisfies:

$$\Phi^\#(\psi) \le 2^k$$

Moreover, this bound is tight: there exist stabilizer codes achieving $\Phi^\#(\psi) = 2^k$.

**Test.** Implement standard stabilizer codes (Steane [[7,1,3]], Shor [[9,1,3]], five-qubit [[5,1,3]]), generate encoded states, and compute Φ#. Verify Φ# ≤ 2^k = 2 for k=1 codes. For the tightness direction, search for codes where some encoded state achieves equality.

**Disproof criterion.** An explicit stabilizer code state with Φ# > 2^k, or a proof that no encoded state of a given code achieves Φ# = 2^k.

**Impact.** This would connect IIT to quantum error correction — the integration capacity of a quantum code is bounded by its logical dimension. This implies a fundamental trade-off: error-correcting redundancy limits the integration that encoded states can achieve.
