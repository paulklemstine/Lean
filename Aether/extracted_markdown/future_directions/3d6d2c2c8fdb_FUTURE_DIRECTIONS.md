# Future Directions: Homotopy Type Theory as Foundations

## Synthesis

This cycle established a formal bridge between Homotopy Type Theory (HoTT) and classical mathematics within Lean 4, proving theorems about truncation levels, winding numbers (modeling π₁(S¹) ≅ ℤ), the fiber characterization of equivalences, and the Structure Identity Principle for finite algebraic structures. The most promising cross-domain connection emerged between **tropical univalence** (from the existing Catalog at `Bridges/TropicalUnivalence.lean`) and our finite univalence model: both instantiate the abstract univalence principle in concrete, decidable settings. The tropical version works with weighted matrices under permutation, while ours works with Fin-types under cardinality equality. This suggests a general pattern — a "ladder of univalence" from decidable finite cases through metric/tropical cases to the full topological axiom.

The highest breakthrough potential lies in **Direction 1** (Synthetic Homotopy via Cubical Models), which could yield the first purely formal computation of π₂(S²) within a Lean-compatible framework. The cycle's winding number machinery provides the template: the encode-decode method scaled from S¹ to higher spheres. The fiber characterization (Direction 3) connects to machine learning applications through the `Bridges/HomologicalDeepLearning.lean` result on certified robustness from margin and Lipschitz bounds — the fiber structure of neural network predictions is precisely the geometric object that determines adversarial robustness.

The Structure Identity Principle (Direction 4) has the most immediate practical impact: it provides automatic transport of theorems across isomorphic structures, which would dramatically reduce proof engineering effort. Combined with the existing categorical bridges (`Bridges/CategoricalBridges.lean`), this could automate the "bridge composition" pattern that currently requires manual adjunction tracking.

---

### Direction 1: Synthetic Homotopy of S² via the Hopf Fibration

**Conjecture**: There exists a formal model of the Hopf fibration S¹ → S³ → S² within Lean 4's type theory (using an abstract higher inductive type encoding) such that the induced long exact sequence computes π₂(S²) ≅ ℤ, with the winding number of S¹-fibers providing the isomorphism.

**Test**: Formalize the Hopf map as a function `hopf : Fin 4 → Fin 3 → Fin 2` on discretized spheres. Compute the fiber over each point of S² (discretized) and verify each fiber is isomorphic to S¹ (discretized). Then verify that the induced map on second homotopy groups matches the degree map.

Computationally: for a triangulation of S² with N faces, the Hopf fiber over each face should have winding number ±1. Test with N = 20 (icosahedron).

**Impact**: This would be the first machine-verified computation of π₂(S²) via the Hopf fibration in a Lean-compatible setting. It would validate that the encode-decode method (proven for S¹ in this cycle) scales to higher-dimensional topology. If the conjecture fails, it reveals limitations of discrete/simplicial models for capturing continuous homotopy invariants.

**Catalog References**: `Bridges/HoTTFoundations.lean` (winding number, encode-decode), `Bridges/TropicalUnivalence.lean` (tropical isometry), `Bridges/CategoricalBridges.lean` (bridge hierarchy)

**Proof Strategy**:
1. Define a `HigherSphere` type for Sⁿ as a quotient of Fin-indexed simplicial complexes.
2. Construct the Hopf map as a specific simplicial map.
3. Show fibers are equivalent to S¹ using `finite_univalence_iff`.
4. Apply the long exact sequence (formalized as a chain complex in Mathlib) to compute π₂.
5. Use the winding number homomorphism from this cycle to identify the group.

Key lemmas needed: `fiber_of_hopf_is_circle`, `long_exact_sequence_of_fibration`, `pi2_from_les`.

**Domain Bridges**: Topology <-> Algebra, HoTT <-> Classical Algebraic Topology

**Lineage**: Builds on this cycle's `FormalLoop.winding_surjective`, `FormalLoop.winding_concat`, and `finite_univalence_iff`.

**Ambition**: grand_challenge

---

### Direction 2: Constructive Galois Theory via Univalent Splitting Fields

**Conjecture**: For any polynomial p ∈ ℚ[x] of degree n with distinct roots, the Galois group Gal(p) can be computed constructively as a subgroup of Sₙ using the univalent structure identity principle, and this computation agrees with the classical Galois group.

Formally: define `constructiveGaloisGroup (p : Polynomial ℚ) : Subgroup (Equiv.Perm (Fin n))` using the FinGroupEquiv structure, and prove it equals the classical Galois group when the latter is defined.

**Test**: Compute the constructive Galois group of x⁴ - 2 (should be the dihedral group D₄ of order 8), x³ - 2 (should be S₃ of order 6), and x⁵ - 1 (should be ℤ/4ℤ, the cyclic group of order 4). Verify these match known results.

**Impact**: Constructive Galois theory would provide algorithms for computing Galois groups that are correct by construction. This bridges the gap between computational algebra (which computes Galois groups heuristically) and formal mathematics (which proves properties but doesn't compute). A failure would indicate that the univalent approach doesn't simplify the combinatorial complexity of Galois group computation.

**Catalog References**: `Bridges/HoTTFoundations.lean` (FinGroupEquiv, fin_group_equiv_trans), `Algebra/Basic.lean`, `Bridges/CategoricalBridges.lean` (bridge_composition)

**Proof Strategy**:
1. Define splitting field as a quotient type using Mathlib's `Polynomial.SplittingField`.
2. Define the Galois group as automorphisms of the splitting field fixing ℚ.
3. Use `FinGroupEquiv` to identify this with a subgroup of Sₙ.
4. Prove the SIP transfers group properties automatically.
5. Compute explicit examples using `#eval` on the Fin-indexed representation.

Key lemmas: `galois_group_is_fin_group_equiv`, `sip_transfers_subgroup`, `splitting_field_fin_equiv`.

**Domain Bridges**: Algebra <-> Computation, NumberTheory <-> HoTT

**Lineage**: Builds on this cycle's `FinGroupEquiv`, `fin_group_equiv_refl/symm/trans`, and the foundation comparison framework.

**Ambition**: grand_challenge

---

### Direction 3: Fiber Geometry of Neural Network Decision Boundaries

**Conjecture**: For a ReLU neural network f : ℝⁿ → ℝᵏ with L layers and width w, the fiber f⁻¹(y) over a generic output y is a piecewise-linear manifold of dimension n - k, and the number of connected components of this fiber is bounded above by O((2w)^L).

**Test**: Train a 2-layer ReLU network on MNIST (n = 784, k = 10, w = 256). For 100 random test points, compute the local fiber dimension (should be 774 = 784 - 10) and count connected components of the decision region (should be ≤ (512)² = 262144). Verify these bounds hold empirically.

**Impact**: This connects the fiber characterization of equivalences (proved in this cycle) to deep learning interpretability. The fiber structure determines when two inputs are "equivalent" from the network's perspective — this is precisely the geometric content of adversarial robustness. If the bound on connected components is tight, it explains why deeper networks generalize better (fewer, larger decision regions). If false, it reveals that ReLU geometry is more complex than the naive count suggests.

**Catalog References**: `Bridges/HoTTFoundations.lean` (bijective_iff_unique_fibers), `Bridges/HomologicalDeepLearning.lean` (certified_robustness_from_margin_and_lipschitz)

**Proof Strategy**:
1. Formalize ReLU networks as piecewise-linear maps using Mathlib's `PiecewiseLinear` API.
2. Show fibers of PL maps are PL manifolds (generalize `bijective_of_unique_fibers`).
3. Bound connected components using the arrangement counting lemma.
4. Connect to the Lipschitz margin bound from `HomologicalDeepLearning.lean`.

Key lemmas: `relu_fiber_is_pl_manifold`, `pl_fiber_component_bound`, `component_bound_depth_dependence`.

**Domain Bridges**: MachineLearning <-> Topology, HoTT <-> DeepLearning

**Lineage**: Builds on this cycle's `bijective_iff_unique_fibers` and the existing `certified_robustness_from_margin_and_lipschitz`.

**Ambition**: extension

---

### Direction 4: Automated Transport via the Structure Identity Principle

**Conjecture**: For any first-order algebraic theory T (groups, rings, modules, etc.) formalized in Lean 4, the Structure Identity Principle can be implemented as a tactic `transport` that automatically transfers theorems from one T-model to an isomorphic one, with proof terms of size O(n) where n is the theorem size (not exponential in the number of isomorphism applications).

**Test**: Implement the `transport` tactic for groups. Test on three cases:
1. Transfer the classification of groups of order 4 from (ℤ/4ℤ, +) to any cyclic group of order 4.
2. Transfer Lagrange's theorem from one representation of S₃ to another.
3. Transfer the Chinese Remainder Theorem between ℤ/6ℤ and ℤ/2ℤ × ℤ/3ℤ.

Measure proof term size — it should grow linearly with the original theorem, not exponentially.

**Impact**: This would be a major practical contribution to formal mathematics. Currently, transferring results between isomorphic structures requires tedious manual work. An automated, efficient `transport` tactic would save thousands of lines of proof across Mathlib. The linear proof-term size conjecture, if true, means the tactic is practical even for large theorems. If false, it identifies a fundamental computational barrier to automatic transport.

**Catalog References**: `Bridges/HoTTFoundations.lean` (FinGroupEquiv, Structure Identity Principle), `Bridges/CategoricalBridges.lean` (bridge_composition, adjunction composition)

**Proof Strategy**:
1. Formalize first-order algebraic theories as `Structure` in Lean 4.
2. Define "displayed structures" following Ahrens-Lumsdaine-Voevodsky.
3. Prove the SIP for each theory by induction on the theory signature.
4. Implement transport as a recursive tactic that follows the SIP proof.
5. Prove the O(n) bound by analyzing the recursion depth.

Key lemmas: `sip_for_groups`, `sip_for_rings`, `transport_term_size_linear`.

**Domain Bridges**: Logic <-> Algebra, HoTT <-> Proof Engineering

**Lineage**: Builds on this cycle's `fin_group_equiv_refl/symm/trans` and the univalence model framework.

**Ambition**: extension

---

### Direction 5: Tropical Truncation Levels and Valuation-Theoretic Homotopy

**Conjecture**: The truncation level hierarchy from HoTT has a natural tropical analogue: define the "tropical truncation level" of a valued field (K, v) as the smallest n such that the n-th iterated valuation group Γₙ(K) is trivially ordered. Then for the p-adic numbers ℚₚ, the tropical truncation level is 1, and for the field of Hahn series over ℚₚ, it is 2.

**Test**: Compute tropical truncation levels for:
1. ℚₚ with the p-adic valuation (predict: level 1, since Γ₁ = ℤ is linearly ordered and Γ₂ is trivial)
2. ℚₚ((t)) with the t-adic + p-adic valuation (predict: level 2, since Γ₁ = ℤ², Γ₂ = ℤ, Γ₃ = 0)
3. ℝ with the trivial valuation (predict: level 0, since Γ₁ = 0)

**Impact**: This bridges HoTT's truncation levels with non-Archimedean geometry and tropical mathematics. If the correspondence holds, it provides a new invariant for valued fields and explains why p-adic geometry is "one level more complex" than real geometry. The Hahn series prediction, if true, connects to the depth hierarchy in the Catalog's `Computation/PadicValuationDepth.lean`.

**Catalog References**: `Bridges/HoTTFoundations.lean` (TruncationLevel, truncation_hierarchy_strict), `Bridges/TropicalUnivalence.lean` (tropical equivalence), `Computation/PadicValuationDepth.lean` (ValuationDepthMeasure)

**Proof Strategy**:
1. Define `tropicalTruncationLevel` for valued fields using iterated value groups.
2. Compute it for ℚₚ using Mathlib's `Valued` typeclass.
3. Compute it for Hahn series using `HahnSeries` from Mathlib.
4. Prove the correspondence with HoTT truncation levels via a functor from valued fields to the truncation hierarchy.

Key lemmas: `padic_tropical_trunc_eq_one`, `hahn_tropical_trunc_eq_two`, `tropical_trunc_functor`.

**Domain Bridges**: NumberTheory <-> Tropical, HoTT <-> p-adic Geometry

**Lineage**: Builds on this cycle's `TruncationLevel` and `conjectured_pi_n_trunc`, plus the Catalog's `ValuationDepthMeasure`.

**Ambition**: extension
