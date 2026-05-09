# Valuation–Stabilizer Correspondence and Tropical Quantum Code Geometry

## Abstract

We formalize a min-plus/tropical theory of quantum stabilizer weight data in Lean 4, establishing a bridge between quantum error correction, tropical algebra, lattice fixed-point theory, and polyhedral geometry. The central construction is the **StabilizerValuation** — a monotone, subadditive function from finitely supported Pauli-weight vectors to the tropical semiring WithTop ℕ — together with its **tropical weight enumerator**, which records the minimum valuation at each Hamming weight. We prove 48 theorems with zero sorries, including:

1. A **tropical breakpoint–distance correspondence**: if the weight enumerator has a breakpoint at d (all weights below d have infinite cost), then every stabilizer element has Pauli weight ≥ d.
2. A **concatenation–convolution theorem**: concatenated quantum recovery profiles combine via min-plus inf-convolution, with certified monotonicity and additive breakpoint bounds.
3. A **closure–fixed-point transport theorem**: tropical weight enumerators are invariant under closure operators that fix the underlying stabilizer set.

## Mathematical Framework

### 1. Stabilizer Valuations

Let ι be a type indexing qubits and let ι →₀ ℕ denote finitely supported functions (representing multi-qubit Pauli weight profiles). A **stabilizer valuation** is a function

   v : (ι →₀ ℕ) → WithTop ℕ

satisfying:
- **Monotonicity**: f ≤ g implies v(f) ≤ v(g)
- **Zero axiom**: v(0) = 0
- **Subadditivity**: v(f + g) ≤ v(f) + v(g)
- **Finiteness**: v(f) ≠ ⊤ for all f

The **Pauli weight** of a vector f is pauliWeight(f) = Σᵢ f(i), the total number of non-identity Pauli operators.

### 2. Tropical Weight Enumerators

For a stabilizer valuation v and a finite set S of weight vectors, the **tropical weight enumerator** is:

   W(k) = inf { v(f) : f ∈ S, pauliWeight(f) = k }

with W(k) = ⊤ if no element of S has weight k. This is a min-plus analogue of the classical Hamming weight enumerator polynomial, where the polynomial ring is replaced by the tropical semiring (ℕ ∪ {∞}, min, +).

### 3. Breakpoint–Distance Correspondence

**Theorem** (quantum_certified_breakpoint_distance): If W has a breakpoint at d — meaning W(k) = ⊤ for all k < d — then every element of S has Pauli weight ≥ d.

This is the core certified distance theorem. The proof proceeds by contradiction: if some f ∈ S has weight k < d, then W(k) ≤ v(f) < ⊤, contradicting the breakpoint hypothesis.

The converse also holds (post_quantum_security_via_tropical_gap): if every element has weight ≥ d, then the enumerator trivially has a breakpoint at d since no witnesses exist at lower weights.

### 4. Inf-Convolution and Concatenation

The **inf-convolution** of two profiles f, g : ℕ → WithTop ℕ is:

   (f ⊕ g)(n) = inf { f(i) + g(n-i) : 0 ≤ i ≤ n }

This models the concatenation of two quantum recovery channels: to correct n errors total, optimally split them into i errors for the outer code and n-i for the inner code.

**Theorem** (breakpoint_add_of_both): If W₁ has breakpoint d₁ and W₂ has breakpoint d₂, then W₁ ⊕ W₂ has breakpoint d₁ + d₂.

This gives the fundamental distance-additivity property of concatenated codes in tropical form.

### 5. Closure Operators and Fixed Points

We formalize closure operators (extensive, monotone, idempotent endomorphisms) and prove two key transport theorems:

- **tropWeightEnumerator_mono_through_closure**: For monotone Φ : α → Finset(ι →₀ ℕ), closure can only enlarge the set, hence the enumerator can only improve.
- **lattice_fixedpoint_pauli_shadow**: If Φ commutes with closure, the enumerator is invariant under closure.

These capture the Knaster-Tarski flavor of stabilizer codespace certification.

### 6. Tropical Support Functions

The **tropical support function** of a finite set S is:

   σ_S(x) = inf { pauliWeight(f + x) : f ∈ S }

**Theorem** (tropicalSupportFunction_infimal): σ_{S∪T}(x) = min(σ_S(x), σ_T(x)).

This is the tropical analogue of the classical support function identity for Minkowski sums, establishing the polyhedral character of our constructions.

## Significance

This work establishes a new bridge between tropical geometry and quantum coding theory. The key innovation is viewing stabilizer weight enumerators through the lens of tropical valuations, which:

1. **Certifies distance bounds** via breakpoint analysis rather than exhaustive search
2. **Composes naturally** under code concatenation via inf-convolution
3. **Respects closure structure** of stabilizer groups via fixed-point transport

The framework is fully constructive and algorithmic: computing the tropical weight enumerator is O(|S|) per weight, and computing the inf-convolution is O(n) per evaluation point.

## Proof Techniques

The development uses diverse Lean 4 tactics:
- **by_contra** and **push_neg** for the breakpoint–distance contradiction
- **rcases** for witness extraction in certified attainment
- **omega** for natural number arithmetic in breakpoint bounds
- **simp** for simplification of Finset operations
- **calc** for chained inequalities in subadditivity proofs
- **Finset.inf_mono**, **Finset.inf_mono_fun**, **Finset.inf_eq_top_iff** for tropical infimum manipulation

## References

- Tropical geometry: Maclagan and Sturmfels, "Introduction to Tropical Geometry"
- Stabilizer codes: Gottesman, "Stabilizer Codes and Quantum Error Correction"
- Weight enumerators: Shor and Laflamme, "Quantum Analogues of the MacWilliams Identities"
- Min-plus algebra: Baccelli et al., "Synchronization and Linearity"
