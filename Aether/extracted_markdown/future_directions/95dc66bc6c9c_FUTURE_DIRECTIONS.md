# Future Directions: Smooth 4-Manifold Topology

## Synthesis

This research cycle established a formal foundation for the algebraic theory of intersection forms in 4-manifold topology. We formalized the key objects (unimodular symmetric bilinear forms, the E₈ lattice, Seiberg-Witten basic classes) and proved 15+ non-trivial theorems including the E₈ determinant computation, evenness, non-diagonalizability, and the Freedman-Donaldson obstruction theorem. The connection to existing catalog entries is primarily through the algebraic bridge: the `SymIntForm` structure connects naturally to `BilinForm` definitions in `Bridges/LorentzianRecognition.lean` and related Lorentzian lattice work, while the E₈ Cartan matrix connects to Lie algebra structures in the algebra catalog.

The most promising cross-domain connection is between intersection form theory and tropical geometry. The tropical semiring structure (from the Tropical catalog) could provide new invariants for lattice classification: the "tropical determinant" of an integer matrix Q computes the weight of the optimal assignment, which for unimodular matrices provides combinatorial information about the lattice structure invisible to the ordinary determinant. This connection between tropical linear algebra and 4-manifold invariants is unexplored.

The highest breakthrough potential lies in Direction 1 (Tropical Intersection Form Invariants), which could yield new computable invariants distinguishing smooth structures. Direction 2 (SOS Certificates) addresses a concrete computational challenge discovered during this cycle. Direction 3 (Kirby Calculus) would extend the formalization to handle the geometric side of 4-manifold theory.

---

### Direction 1: Tropical Intersection Form Invariants

**Conjecture**: The tropical permanent of a unimodular symmetric integer matrix Q (computed as the maximum-weight perfect matching in the bipartite graph defined by |Q_{ij}|) provides an invariant that distinguishes indefinite even unimodular forms of the same rank and signature that are not distinguished by the classical Hasse-Minkowski invariants.

**Test**: Compute the tropical permanent for the standard forms H^k ⊕ E₈^l and their non-standard variations (e.g., the Barnes-Wall lattice in dimension 16). If two forms of the same rank and signature have different tropical permanents, the conjecture gains evidence. If all forms of the same rank and signature share the same tropical permanent, the conjecture is refuted.

**Impact**: If true, this provides a new computable invariant for lattice classification that could potentially distinguish smooth structures on 4-manifolds via their intersection forms. The tropical structure would bridge algebraic topology and combinatorial optimization. If false, the failure pattern might reveal which aspects of lattice structure the tropical permanent captures.

**Catalog References**: `Tropical/`, `Bridges/LorentzianRecognition.lean`, `Speculative/Smooth4D/IntersectionForms.lean`

**Proof Strategy**: 
1. Define the tropical permanent for integer matrices in Lean
2. Compute it for standard forms (diagonal ±1, E₈, H) using #eval
3. Show it is invariant under integral congruence (P^T Q P for P ∈ GL_n(ℤ))
4. Check whether it distinguishes known non-isomorphic lattices

**Domain Bridges**: Tropical linear algebra <-> 4-manifold topology; Combinatorial optimization <-> Lattice theory

**Lineage**: Builds on this cycle's `SymIntForm` and E₈ formalization, and the Tropical catalog

**Ambition**: grand_challenge

---

### Direction 2: Integer SOS Certificates for Positive Definite Lattices

**Conjecture**: For any positive definite unimodular lattice of rank n, the Cholesky factorization over ℚ can be cleared to an identity M · Q(v) = Σᵢ cᵢ · lᵢ(v)² where M = lcm(1, 2, ..., n)² / det(Q), all cᵢ are positive integers, and lᵢ are integer-coefficient linear forms. This provides a machine-checkable certificate of positive definiteness.

**Test**: Compute the Cholesky factorization of the E₈ Cartan matrix over ℚ. The pivots are 2, 3/2, 4/3, 5/4, 6/5, 7/6, 8/7, 1/8. Clear denominators by multiplying by lcm of all denominators appearing in the L matrix entries. Verify the resulting integer identity computationally.

**Impact**: This would provide a general method for proving positive definiteness of integer quadratic forms in proof assistants, filling a significant gap in current Mathlib infrastructure. The certificate is independently verifiable by ring arithmetic.

**Catalog References**: `Speculative/Smooth4D/IntersectionForms.lean` (E8Form_posdef)

**Proof Strategy**:
1. Implement Cholesky factorization for integer matrices over ℚ
2. Track the exact rational entries of L and D
3. Compute M = lcm of all denominators in L and D^(1/2)
4. Verify M · Q = (L√D)^T (L√D) after clearing denominators
5. Express as a sum of squares of integer linear forms

**Domain Bridges**: Numerical linear algebra <-> Formal verification; Lattice theory <-> Optimization

**Lineage**: Builds on this cycle's E8_qeval_expand and the gap in proving E8Form_posdef

**Ambition**: extension

---

### Direction 3: Kirby Calculus and Handle Decompositions

**Conjecture**: Every simply-connected closed smooth 4-manifold with intersection form equivalent to the k-fold direct sum of the hyperbolic form H can be decomposed into a handle body with at most 2k 2-handles, k 1-handles, k 3-handles, and minimal 0- and 4-handles. The handle structure can be formalized as a combinatorial object (a Kirby diagram) in Lean.

**Test**: Formalize the notion of a handle decomposition for 4-manifolds. Verify that CP² # CP² (connected sum of two copies of complex projective plane, with form [[1,0],[0,-1]]) admits a handle decomposition with exactly two 2-handles and no 1-handles or 3-handles.

**Impact**: Kirby calculus is the primary computational tool for constructing and modifying 4-manifolds. Formalizing it would enable machine-verified constructions of specific smooth manifolds, potentially leading to new insights about the smooth Poincaré conjecture through systematic search of handle decompositions.

**Catalog References**: `Speculative/Smooth4D/IntersectionForms.lean` (SmoothFourManifoldData, HyperbolicForm)

**Proof Strategy**:
1. Define handle decomposition as a type in Lean (sequence of handle attachments)
2. Define the intersection form induced by a handle decomposition
3. Prove that the intersection form is an invariant of the resulting manifold
4. Implement Kirby moves (handle slides, cancellation) as operations on the type
5. Verify specific examples (S⁴, CP², S² × S²)

**Domain Bridges**: Combinatorics <-> Differential topology; Graph theory <-> 4-manifold surgery

**Lineage**: Builds on this cycle's SmoothFourManifoldData and SymIntForm

**Ambition**: grand_challenge

---

### Direction 4: Rohlin's Theorem and Spin Bordism

**Conjecture**: Rohlin's theorem (the signature of a smooth closed spin 4-manifold is divisible by 16) can be proved purely from algebraic properties of even unimodular forms combined with the Donaldson diagonalizability constraint, without reference to spin bordism theory.

**Test**: Attempt to prove: if Q is an even unimodular form that satisfies Donaldson's constraint (definite ⟹ diagonal), then the rank n satisfies n ≡ 0 (mod 16). This is a weaker form of Rohlin's theorem. Check whether the proof goes through with only the algebraic machinery formalized in this cycle.

**Impact**: A purely algebraic proof of Rohlin's theorem would significantly simplify the logical dependencies in 4-manifold topology and could be fully formalized in a proof assistant.

**Catalog References**: `Speculative/Smooth4D/IntersectionForms.lean` (even_definite_unimodular_rank_mod_8, IsEven, IsUnimodular)

**Proof Strategy**:
1. Classify even unimodular forms in small ranks (8, 16, 24)
2. Show that for definite forms, Donaldson's constraint forces diagonal form
3. Show that even + diagonal + unimodular is impossible for positive rank (proved this cycle)
4. For indefinite forms, use the Hasse-Minkowski classification
5. Derive the mod-16 constraint from the classification

**Domain Bridges**: Algebraic topology <-> Number theory (quadratic forms); Gauge theory <-> Bordism

**Lineage**: Builds on even_definite_unimodular_rank_mod_8 from this cycle

**Ambition**: extension

---

### Direction 5: Computational Enumeration of Exotic 4-Manifold Candidates

**Conjecture**: Among all unimodular even forms of rank ≤ 32, at most 3% admit smooth realizations satisfying both Donaldson's constraint and Furuta's bound. The remaining 97% represent "ghost manifolds" — topological 4-manifolds with no smooth structure.

**Test**: Enumerate all even unimodular lattices of rank 8, 16, and 24 (there are 1, 2, and 24 respectively, by the classification of Niemeier lattices). For each, check: (a) is it definite? If so, it fails Donaldson's constraint (smooth only if diagonal = trivial). (b) If indefinite, compute b⁺ and b⁻ and check Furuta's bound.

**Impact**: A systematic computational survey would reveal the "geography" of smooth 4-manifold invariants and could suggest patterns relevant to the smooth Poincaré conjecture. The enumeration might reveal unexpected correlations between lattice properties and smoothability.

**Catalog References**: `Speculative/Smooth4D/IntersectionForms.lean` (FurutaBound, ElevenEighthsBound, IsEven, IsUnimodular)

**Proof Strategy**:
1. Formalize the classification of even unimodular lattices in ranks 8 and 16
2. Implement computational checks for Donaldson and Furuta constraints
3. For each lattice, determine whether a smooth realization is possible
4. Compute statistics and look for patterns

**Domain Bridges**: Number theory (lattice enumeration) <-> Topology; Computation <-> Pure mathematics

**Lineage**: Builds on this cycle's formalization of constraints (Donaldson, Furuta, evenness, unimodularity)

**Ambition**: extension
