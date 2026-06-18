# Future Directions: Isogeny-Based Cryptography Formalization

## Synthesis

This research cycle formalized the abstract algebraic foundations of isogeny-based cryptography, proving 20+ theorems about group actions, torsors, commitment schemes, twist endomorphisms, and security reductions — all without sorry. The central discovery is that the **connector algebra** — the system of equations satisfied by the map conn : X × X → G sending pairs of torsor points to their unique connecting group element — forms a **Čech 1-cocycle** satisfying triangle closure, translation invariance, and antisymmetry. This algebraic structure is not merely aesthetic: it is the precise mechanism by which all security reductions work, from commitment binding to special soundness extraction.

The most promising cross-domain connections are threefold. First, the **twist endomorphism** formalization (τ(g·x) = g⁻¹·τ(x) with connector inversion) provides a bridge to **Galois cohomology** and the arithmetic of imaginary quadratic fields — the twist is the algebraic shadow of complex conjugation on ideal classes. Second, the **vectorization problem** (group-action CDH) and its relationship to GAIP creates a **hardness hierarchy** that parallels the classical DLP → CDH → DDH chain, connecting to the Catalog's existing lattice cryptography work (`Cryptography/BerggrenLatticeCryptography.lean`). Third, the **connector translation invariance** theorem (conn(g·x, g·y) = conn(x,y)) is a form of **G-equivariance** that connects to the spectral theory of group representations and the Catalog's expander graph work.

The highest breakthrough potential lies in Direction 1 (Quantum Query Lower Bounds): resolving the exact quantum complexity of GAIP would either validate or refute the entire CSIDH security paradigm. Direction 2 (Concrete Class Group Instantiation) has the most immediate practical value. Direction 3 (Non-Abelian Extensions) opens entirely new mathematical territory.

---

### Direction 1: Quantum Query Lower Bounds for GAIP

**Conjecture**: The Group Action Inverse Problem for a free transitive action of an abelian group G on a set X requires Ω(|G|^{1/4}) quantum queries to the group action oracle. Specifically, for any quantum algorithm making T queries to the oracle act : G × X → X, the success probability of recovering g from (x₀, g·x₀) is at most O(T⁴/|G|).

**Test**: Implement a quantum circuit simulator for small group orders (|G| ≤ 2^10). For each order, run Grover-like quantum search with T queries and measure success probability. Plot success probability vs T⁴/|G| — the conjecture predicts this ratio should be bounded by a constant. If the ratio grows unboundedly for some group structure, the conjecture is false.

**Impact**: If true, this establishes CSIDH-512 as providing approximately 128 bits of quantum security (since |Cl(O)| ≈ 2^256, giving T ≥ 2^64 queries). If false, it identifies specific group structures vulnerable to faster quantum algorithms, potentially invalidating CSIDH parameter choices.

**Catalog References**: `Cryptography/BerggrenLatticeCryptography.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: The approach should formalize the **polynomial method** for quantum query complexity. Key steps:
1. Define the quantum query model for group actions: a unitary oracle O_act that maps |g, x, y⟩ → |g, x, y ⊕ act(g,x)⟩
2. Show that after T queries, the quantum state has degree ≤ T as a polynomial in the "planted" group element g
3. Apply the polynomial method (Beals et al.) to bound the success probability by O(T⁴/|G|) using the fact that free transitive actions have uniform spectral structure
4. The key lemma is that the Fourier transform of the indicator function of {g} over G has constant magnitude 1/|G| for abelian G

**Domain Bridges**: Quantum complexity theory ↔ algebraic number theory (class group structure), spectral graph theory ↔ cryptographic hardness (Ramanujan expansion ↔ query lower bounds)

**Lineage**: Builds on this cycle's formalization of FreeTrans, connector algebra, and GAIP structure. Extends the GAIP security model to the quantum setting.

**Ambition**: grand_challenge

---

### Direction 2: Concrete Class Group Instantiation

**Conjecture**: For the imaginary quadratic order O = ℤ[√(-p)] with p ≡ 3 (mod 8) prime, the class group Cl(O) acts freely and transitively on the set of supersingular j-invariants over 𝔽_p, and this action can be formally constructed as an EffectiveGroupAction with generators corresponding to the split primes ℓ₁ < ℓ₂ < ... < ℓₙ with ℓᵢ ≤ B.

**Test**: For p = 419 (class number h = 21), explicitly construct:
- The set X of supersingular j-invariants over 𝔽_p (should have |X| = (p-1)/12 + ε = 35 elements after correction)
- The class group Cl(O) and its generators
- The isogeny action map
- Verify |Cl(O)| = |X| (cardinality theorem)
- Verify the twist acts as inversion on connectors

**Impact**: Bridges the gap between abstract formalization and concrete cryptographic practice. Enables verified parameter generation for CSIDH/CSI-FiSh implementations.

**Catalog References**: `Cryptography/CSIFiSh.lean`, `Cryptography/CSIFiShAdvanced.lean`, `Cryptography/CSIFiShDeep.lean`

**Proof Strategy**:
1. Formalize imaginary quadratic orders and their ideal class groups using Mathlib's `NumberTheory.NumberField` infrastructure
2. Construct the set of supersingular j-invariants using Deuring's correspondence
3. Define the isogeny action via Vélu's formulas for prime-degree isogenies
4. Prove freeness from the endomorphism ring characterization
5. Prove transitivity from the class number formula h(O) = |SS_p|

**Domain Bridges**: Algebraic number theory (class field theory, Deuring's correspondence) ↔ algebraic geometry (elliptic curves, isogenies) ↔ cryptography (CSIDH parameters)

**Lineage**: Direct extension of this cycle's EffectiveGroupAction definition. The abstract properties proved here should specialize to the concrete instantiation.

**Ambition**: extension

---

### Direction 3: Non-Abelian Group Actions and OSIDH

**Conjecture**: The OSIDH protocol (Oriented Supersingular Isogeny Diffie-Hellman) can be formalized using a non-abelian version of FreeTrans where the group G is replaced by a groupoid (the category of oriented supersingular curves and isogenies). The connector algebra generalizes to a **groupoid cocycle** satisfying a non-commutative triangle identity.

**Test**: Define a `GroupoidAction` structure with:
- Objects: oriented supersingular curves
- Morphisms: isogenies
- Action: pushforward of orientation
Verify that the connector still satisfies the cocycle condition conn(x,z) = conn(y,z) ∘ conn(x,y) where ∘ is morphism composition, and that the triangle identity holds in the groupoid sense.

**Impact**: Extends the algebraic framework beyond abelian group actions, capturing OSIDH and potential new protocols based on non-commutative group actions. Opens connections to higher category theory and homotopy type theory.

**Catalog References**: `Cryptography/BerggrenGroupoidOrbit.lean`, `Algebra/AlgebraicTheoryOfAlgebra.lean`

**Proof Strategy**:
1. Define `CryptoGroupoidAction` generalizing `CryptoGroupAction` with source/target maps
2. Formalize the orientation data as a functor from the fundamental groupoid
3. Prove connector existence (from "transitivity" = path-connectedness of the groupoid)
4. The key challenge is formalizing uniqueness: in a groupoid, connectors are unique up to automorphisms of the target
5. Prove a non-abelian version of the binding theorem: commitment security reduces to the "groupoid inverse problem"

**Domain Bridges**: Category theory (groupoids, functors) ↔ algebraic geometry (moduli of oriented curves) ↔ homotopy theory (fundamental groupoid)

**Lineage**: Extends this cycle's FreeTrans and connector algebra to the non-abelian/groupoid setting.

**Ambition**: grand_challenge

---

### Direction 4: Expansion and Mixing in Isogeny Graphs

**Conjecture**: For the Cayley graph of the class group Cl(O) acting on supersingular curves with generator set S = {[ℓ₁], ..., [ℓₙ], [ℓ₁]⁻¹, ..., [ℓₙ]⁻¹}, the spectral gap is at least λ₁ ≥ 2√(2n-1)/(2n) (the Ramanujan bound). Equivalently, the second-largest eigenvalue of the adjacency matrix satisfies |λ₂| ≤ 2√(2n-1).

**Test**: For small class numbers (h ≤ 50), compute the adjacency matrix of the Cayley graph, find its eigenvalues, and verify the Ramanujan bound. If any eigenvalue violates the bound, the conjecture is false for that specific instance.

**Impact**: The Ramanujan property implies optimal mixing time O(log|G|) for random walks, which directly controls the security of hash-based constructions on isogeny graphs. It also provides a formal link between the spectral theory of the graph and the hardness of GAIP.

**Catalog References**: `Algebra/ClassicalGroupExpanders.lean` (if it exists), `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`

**Proof Strategy**:
1. Formalize the adjacency matrix of the Cayley graph using Mathlib's `Matrix` API
2. Define the Ramanujan property: |λ₂| ≤ 2√(d-1) where d = |S| is the degree
3. Prove that free transitive actions yield regular graphs (degree = |S|), using the existing `degree_eq_generators_of_free` theorem
4. The Ramanujan property for isogeny graphs follows from Eichler's theorem on Brandt matrices (deep result)
5. As a first step, prove the spectral gap is positive (i.e., the graph is connected) using transitivity

**Domain Bridges**: Spectral graph theory (Ramanujan graphs, eigenvalue bounds) ↔ automorphic forms (Eichler's theorem, Hecke operators) ↔ cryptographic mixing (random walk uniformity)

**Lineage**: Builds on this cycle's CayleyGraph formalization and the cayleyDiameterConjecture.

**Ambition**: extension

---

### Direction 5: Twist-Based Protocol Optimizations

**Conjecture**: The twist endomorphism τ can be used to halve the key space of CSIDH without reducing security. Specifically, if we identify each secret key s with its "twist-equivalent" s⁻¹ (since the public keys act(s, x₀) and act(s⁻¹, τ(x₀)) = τ(act(s, x₀)) carry the same information), then the effective key space is |G|/2 rather than |G|, and no polynomial-time attack exploits this identification.

**Test**: For ℤ/nℤ with n odd and the twist τ(x) = n-x:
1. Verify that the twist satisfies τ(g+x) = (-g) + τ(x) (the twist-action axiom)
2. Compute the number of "twist-equivalent pairs" (s, -s) — should be (n-1)/2 for n odd
3. Verify that knowing act(s, x₀) and τ does not help recover s (i.e., the additional information from τ is redundant given GAIP hardness)

**Impact**: Halving the key space reduces signature sizes and key sizes in CSI-FiSh by a factor of 2, a significant practical improvement. The formal proof that this optimization is sound requires the connector-twist inversion theorem proved in this cycle.

**Catalog References**: `Cryptography/CSIFiSh.lean`, this cycle's TwistStructure formalization

**Proof Strategy**:
1. Define the "twist-reduced key space" G/~ where s ~ s⁻¹
2. Prove that the public key map factors through G/~: if act(s, x₀) = pk, then τ(pk) = act(s⁻¹, τ(x₀)), so knowledge of τ(x₀) and pk determines τ(pk), giving no new information
3. The security reduction: any attack on the twist-reduced scheme yields an attack on the original scheme (by randomly choosing s or s⁻¹)
4. Key lemma: the twist_connector_product theorem from this cycle

**Domain Bridges**: Cryptographic optimization ↔ group quotient theory (G/~ structure) ↔ algebraic number theory (ideal class group involution)

**Lineage**: Directly builds on this cycle's TwistStructure and connector_twist theorem.

**Ambition**: extension
