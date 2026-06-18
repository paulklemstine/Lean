# Future Directions: EML Cryptographic Primitives

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical Hash Functions from Closure Operators

- **Theorem Statement**: For any EML closure operator on a tropical semiring (ℝ ∪ {∞}, min, +), the composition `closureMin ∘ tropical_eval` defines a collision-resistant hash function, with collision resistance reducing to the fixed-point membership problem of the closure operator.
- **Proof Strategy**:
  (a) Define tropical evaluation as a min-plus matrix-vector product.
  (b) Show that closureMin composed with tropical evaluation inherits idempotence.
  (c) Prove collision resistance by reduction: if two inputs collide, their closures must intersect, which contradicts a separation property of the closure operator.
- **Why This Is Revolutionary**: Connects tropical geometry (a rapidly growing field) to post-quantum hash function design. Min-plus operations are resistant to quantum Fourier transform attacks, potentially offering post-quantum security from a completely different mathematical foundation than lattices.
- **Catalog Leverage**: Build on `closureMin_idempotent`, `closure_closureMin_subset`, and `fiber_ge` from this module.
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 2. Certified Robustness via Closure Operators

- **Theorem Statement**: For a Lipschitz-continuous classifier `f : ℝⁿ → {0,...,k}`, define `cl_f(A) = {x : ∀ y ∈ A, f(x) = f(y)}`. Then `cl_f` is an EML closure operator, and the certified robustness radius of `f` at input `x` equals `inf{‖x - y‖ : y ∉ cl_f({x})}`.
- **Proof Strategy**:
  (a) Verify extensiveness (x classifies the same as itself), monotonicity, idempotence.
  (b) Show that the boundary distance equals the robustness radius using Lipschitz continuity.
  (c) Connect `closureMin` to the nearest adversarial example.
- **Why This Is Revolutionary**: Provides a unified algebraic framework for certified robustness in neural networks. Current approaches (randomized smoothing, interval bound propagation) are ad hoc; closure operators could unify them.
- **Catalog Leverage**: `closed_inter` (robustness regions intersect nicely), `fiber_ge` (adversarial examples are "above" the target).
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 3. Commutative Closure Classification

- **Theorem Statement**: Classify which pairs of EML closure operators on a finite lattice commute (`cl_A ∘ cl_B = cl_B ∘ cl_A`), and prove that commutativity is equivalent to the existence of a mutual fixed-point theorem.
- **Proof Strategy**:
  (a) Use `commuting_collapse` to show that commuting closures have a common refinement.
  (b) Prove that the common refinement is itself a closure operator.
  (c) Apply Tarski's fixed-point theorem to the common refinement.
- **Why This Is Revolutionary**: This is the EML analog of classifying commutative groups for Diffie-Hellman. Understanding which closure operators commute directly determines which pairs can be used for key exchange.
- **Catalog Leverage**: `commuting_collapse`, `commuting_symm`, `FixedPointKeyExchange`.
- **Research Mode**: formalize
- **Estimated Depth**: 3

### 4. Closure Operator Hardness Hierarchy

- **Theorem Statement**: Define a hierarchy of closure operators by the complexity of computing `closureMin`:
  - Level 0: Identity closure (O(1) — trivial)
  - Level 1: Interval closure (O(n) — linear scan)
  - Level 2: Transitive closure on graphs (O(n³) — Floyd-Warshall)
  - Level 3: Algebraic closure of polynomial ideals (EXP — Gröbner basis)
  Prove that each level is strictly harder and that security of the OWF increases with level.
- **Proof Strategy**: Formalize each closure operator as an `EMLClosureOperator` instance and prove the complexity bounds using step-counting.
- **Why This Is Revolutionary**: Creates a complexity-theoretic foundation for "closure-based cryptography" as a new paradigm, analogous to the lattice-based or code-based paradigms.
- **Catalog Leverage**: `ClosureOWF`, `identityClosure`, `closureMin_idempotent`.
- **Research Mode**: formalize
- **Estimated Depth**: 5

### 5. Idempotent Sigma Protocol for Graph Isomorphism

- **Theorem Statement**: The graph isomorphism language admits an idempotent sigma protocol where the closure operator is the automorphism closure of a graph.
- **Proof Strategy**:
  (a) Define `cl_G(A) = {σ(v) : σ ∈ Aut(G), v ∈ A}` as the orbit closure.
  (b) Verify EML axioms (extensive, monotone, idempotent by group closure).
  (c) Show that `closureMin` on the orbit closure gives the canonical form.
  (d) Apply `sigma_complete` and `sigma_special_soundness`.
- **Why This Is Revolutionary**: Graph isomorphism is a famous problem in complexity theory (in NP ∩ coAM but not known to be in P or NP-complete). An algebraic sigma protocol could provide new structural insights.
- **Catalog Leverage**: `sigma_complete`, `sigma_special_soundness`, `sigma_hvzk_false`.
- **Research Mode**: formalize
- **Estimated Depth**: 4

## Under-explored Territory

1. **Closure operators on infinite types**: Our formalization uses `[Fintype C]`. Extending to infinite types (with well-foundedness replacing finiteness) would capture undecidability-based security arguments.

2. **Non-commutative closure pairs**: Most of our key exchange theory assumes commutativity. The non-commutative case could yield protocols resistant to different attack models.

3. **Categorical closure operators**: Defining closure operators as endofunctors on a category of types could enable a more abstract, composable framework.

4. **Measurable closure operators**: Connecting to probability theory would enable formalization of randomized protocols and security reductions with negligible advantage bounds.

## Cross-Domain Bridges

1. **Closure Operators ↔ Galois Connections**: Every closure operator induces a Galois connection. Formalizing this bridge could connect to Mathlib's existing Galois connection infrastructure.

2. **Tropical Semirings ↔ Closure Min**: The `closureMin` function performs a tropical (min-plus) operation. Formalizing the connection to tropical semirings could unlock tropical geometry tools for cryptographic analysis.

3. **Lattice Cryptography ↔ Closure Lattices**: The fixed-point set of a closure operator forms a complete lattice. This connects to lattice-based cryptography (LWE, NTRU) through the algebraic structure of lattices.

4. **Formal Verification ↔ Proof Complexity**: The sigma protocol's special soundness is a statement about proof extraction. Connecting to proof complexity theory could yield bounds on the length of zero-knowledge proofs.

## Open Problems Encountered

1. **Does closureMin define a collision-resistant hash function for any non-trivial closure operator?** We proved fiber structure (each target has at least one preimage) but not collision resistance.

2. **When do commuting closure operators yield identical shared secrets?** We proved each party's secret is a fixed point of their own operator, but agreement requires additional structure.

3. **Can the idempotent sigma protocol achieve simulation-extractability?** Our HVZK proof is for honest verifiers; extending to malicious verifiers requires stronger algebraic properties.

4. **What is the minimum closure "depth" needed for cryptographic security?** The depth of the fixed-point lattice should relate to security level, but the precise relationship is unclear.
