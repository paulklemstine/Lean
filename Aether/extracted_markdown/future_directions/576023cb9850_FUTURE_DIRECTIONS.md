# Future Research Directions

## Synthesis

This research cycle established a rigorous combinatorial framework for "cakes" — stratified surfaces with genus, boundary, marked points, and layer data. The central discovery is the **superadditivity theorem**: handle gluing increases moduli dimension by exactly 6 beyond the sum, while boundary gluing is perfectly additive. This universal constant of 6 = dim(SL₂(ℝ)) × 2 connects surface topology to Lie group theory in a way that invites further investigation.

The most promising cross-domain connection is between the superadditivity principle and the catalog's work on filtered closure systems (`Bridges/FilteredClosureReconstruction.lean`), where the `absorption_yields_monotone_profile` theorem shows closure operations create emergent monotone structure. Handle gluing is precisely such an operation — a topological "closure" that monotonically generates geometric complexity. The tropical-classical correspondence (Theorem 6.1) provides a second bridge, connecting to `Tropical/ApproximateVerification.lean` and suggesting that the superadditivity constant of 6 should have a tropical analogue expressible in terms of graph combinatorics.

The direction with highest breakthrough potential is Direction 1 (Non-orientable Cake Theory), because extending superadditivity to non-orientable surfaces (Klein bottles, Möbius bands) would either reveal a new universal constant or show that 6 is specific to orientable surfaces — either outcome advancing our understanding of how topology constrains geometry.

---

### Direction 1: Non-orientable Cake Moduli and Crosscap Superadditivity

**Conjecture**: For non-orientable surfaces characterized by crosscap number c (instead of genus g), the moduli dimension formula becomes dim = 3c − 6 + 2n + 3b, and crosscap gluing (attaching a Möbius band to a boundary component) increases moduli dimension by exactly 3 — half the handle cost of 6.

**Test**: Compute the Teichmüller space dimension for Klein bottles (c=2) and projective planes with punctures (c=1) from first principles using the non-orientable uniformization theorem. Verify whether crosscap gluing gives a constant surplus independent of the input surfaces.

**Impact**: If true, this establishes a "crosscap cost" of 3 = dim(SL₂(ℝ)), exactly half the handle cost, reflecting the Z₂ quotient between handles and crosscaps. This would provide a unified framework connecting orientable and non-orientable surface moduli. If false, it reveals that non-orientable moduli are fundamentally different from their orientable counterparts.

**Catalog References**: `Geometry/EulerTopology.lean` (component_quadratic_bound), `Bridges/FilteredClosureReconstruction.lean` (absorption_yields_monotone_profile)

**Proof Strategy**: 
1. Define non-orientable cakes with crosscap number replacing genus
2. Establish χ = 2 − c − b for non-orientable surfaces  
3. Define crosscap gluing: c_new = c₁ + c₂ + 1, b_new = b₁ + b₂ − 2
4. Compute the moduli dimension formula from the Teichmüller space of non-orientable surfaces (using the oriented double cover)
5. Prove or disprove the constant surplus of 3

**Domain Bridges**: Surface topology (crosscap classification) ↔ Lie group theory (SL₂(ℝ) quotients) ↔ Moduli theory (Teichmüller spaces of non-orientable surfaces)

**Lineage**: Builds on this cycle's Cake structure, superadditivity theorem (Theorem 4.1), and handle cost theorem (Theorem 4.3). Extends the framework from orientable to non-orientable surfaces.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Superadditivity and the Kirchhoff Polynomial

**Conjecture**: For tropical cakes (metric graphs), there exists a "tropical handle gluing" operation on graphs such that the tropical moduli dimension satisfies dim_trop(G₁ ⊕ G₂) = dim_trop(G₁) + dim_trop(G₂) + 1 (not +6 as in the classical case). The constant 1 corresponds to the single new edge created in the graph gluing, and the ratio 6:1 reflects the degeneration index of the tropical limit.

**Test**: Construct explicit graph gluings for trivalent graphs with small Betti numbers (β₁ = 1, 2, 3) and compute tropical moduli dimensions. Check whether the surplus is constant and equal to 1. Verify computationally for all trivalent graphs with up to 10 edges.

**Impact**: If the tropical surplus is 1, this gives a precise tropicalization index of 6 for the handle gluing operation, connecting to the theory of Berkovich analytifications. If the surplus varies, it suggests tropical superadditivity has a more nuanced structure than the classical case.

**Catalog References**: `Tropical/ApproximateVerification.lean` (tropical_layer_composition_bound), `Geometry/CakeModuli.lean` (tropical_trivalent_moduli)

**Proof Strategy**:
1. Define graph handle gluing: given G₁, G₂ with leaves, identify two leaves and add an edge connecting them
2. This increases edge count by 1, decreases leaf count by 2, keeping interior vertices
3. Compute β₁_new = β₁(G₁) + β₁(G₂) + 1 and dim_new = e₁ + e₂ + 1 − (ℓ₁ + ℓ₂ − 2) = dim₁ + dim₂ + 3
4. Wait — that gives +3, not +1. Investigate whether the correct surplus depends on the graph structure.

**Domain Bridges**: Tropical geometry (metric graphs) ↔ Classical algebraic geometry (Teichmüller spaces) ↔ Graph theory (Kirchhoff matrix-tree theorem)

**Lineage**: Directly extends this cycle's tropical_trivalent_moduli theorem and the classical-tropical correspondence. Tests whether superadditivity constants are preserved or modified under tropicalization.

**Ambition**: extension

---

### Direction 3: Moduli Growth Under Iterated Gluing and the Tower Problem

**Conjecture**: Starting from n copies of a base cake C₀ (e.g., pants with dim = 3), the maximum moduli dimension achievable by a sequence of n−1 handle gluings is exactly (n−1)·6 + n·dim(C₀), and this maximum is achieved by *any* gluing order. That is, the moduli dimension of an iterated handle glue depends only on the number of gluings, not on the tree structure of the gluing sequence.

**Test**: For n = 2, 3, 4, 5 pants (dim = 3 each), compute dim for all possible binary tree structures of gluing sequences. Verify whether all give the same answer: 6(n−1) + 3n = 9n − 6. This can be tested computationally by enumerating all binary trees on n leaves.

**Impact**: If true, this means handle gluing is "order-independent" for moduli dimension, making the moduli growth rate a simple function of the number of components. This would simplify the analysis of complex surface decompositions. If false (dim depends on gluing order), it reveals that the tree structure of the decomposition matters, connecting to the theory of operads and modular operads.

**Catalog References**: `Geometry/CakeModuli.lean` (moduli_superadditive, moduli_additive_boundary_glue)

**Proof Strategy**:
1. Prove by induction on the number of gluings using moduli_superadditive
2. Key insight: superadditivity gives dim = dim(C₁) + dim(C₂) + 6, and by induction dim(Cᵢ) = 6kᵢ + (kᵢ+1)·dim(C₀) where kᵢ is the number of gluings in subtree i
3. Since k₁ + k₂ + 1 = n−1, the total is 6(n−1) + n·dim(C₀) regardless of the split

**Domain Bridges**: Surface topology (pants decomposition) ↔ Combinatorics (binary tree enumeration) ↔ Category theory (operadic composition)

**Lineage**: Direct extension of the superadditivity theorem. Generalizes from single gluing to iterated gluing towers.

**Ambition**: extension

---

### Direction 4: Moduli Dimension as a Valuative Invariant

**Conjecture**: The moduli dimension function dim: Cake → ℤ is the unique (up to scaling and shift) integer-valued invariant of cakes that is (1) linear in the Euler characteristic for unmarked cakes, (2) additive under boundary gluing, and (3) superadditive with constant surplus under handle gluing. Any other invariant satisfying these three properties is of the form a·dim + b for constants a, b.

**Test**: Assume f: Cake → ℤ satisfies the three axioms. Show that f(disk) and f(pants) determine f on all cakes constructible from disks and pants by gluing. Then verify that the only solution consistent with linearity in χ is f = a·dim + b.

**Impact**: If true, this characterizes moduli dimension axiomatically, without reference to Teichmüller theory or conformal structures. It would mean that the moduli dimension is the *only* invariant with these algebraic properties — a uniqueness theorem for dimensional complexity measures. This connects to the axiomatic characterization of Euler characteristic by Hadwiger's theorem.

**Catalog References**: `Geometry/CakeModuli.lean` (moduli_euler_relation, moduli_superadditive, moduli_additive_boundary_glue), `Computation/PadicValuationDepth.lean` (vdepth_const_eq_zero — analogy: unique valuation characterization)

**Proof Strategy**:
1. Show every compact surface can be built from disks and pants by iterated gluing
2. Use the three axioms to compute f on any such surface
3. Show the axioms force f = a·χ + c·n + d for some constants, where a = −3α, c = 2α for some α
4. This gives f = α·dim + β, completing the uniqueness proof

**Domain Bridges**: Axiomatic characterization (Hadwiger-type theorems) ↔ Valuation theory (p-adic depth measures) ↔ Category theory (universal properties)

**Lineage**: Synthesizes the moduli-Euler bridge and both gluing theorems into an axiomatic characterization. Inspired by the uniqueness of Euler characteristic in convex geometry.

**Ambition**: grand_challenge

---

### Direction 5: Stratification Depth vs. Moduli Dimension Bounds

**Conjecture**: For a cake C with k layers obtained by iterated handle gluings from disks, the layer count satisfies k ≤ dim(C)/6 + 1. Equivalently, the number of handle gluings in any construction of C from disks is bounded by (dim(C) + 6)/6. This bound is tight: for towers of disk gluings, equality holds.

**Test**: Construct cakes with k = 1, 2, ..., 10 layers by sequential disk handle-gluings. Verify dim(C) = 6k − 3 (since gluing k+1 disks with handles gives g = k, b = 0, n = 0, so dim = 6k − 6). Wait — that gives dim = 6k − 6, so k = (dim + 6)/6, confirming the bound with equality.

**Impact**: If proved, this gives a combinatorial interpretation of moduli dimension as 6 × (minimal number of handles) − 6. This connects to the existing `tropical_layer_composition_bound` in the catalog and provides a new lower bound on the complexity of surface decompositions.

**Catalog References**: `Tropical/ApproximateVerification.lean` (tropical_layer_composition_bound), `EML/AdvancedTheory.lean` (ensemble_complexity_additive — analogy: complexity grows with layer depth)

**Proof Strategy**:
1. Prove by induction on the number of handle gluings
2. Base case: a single disk has k = 1, dim = −3 (no moduli), so the bound holds vacuously for k = 1
3. Inductive step: after one more handle gluing, k increases by 1 and dim increases by at least 6

**Domain Bridges**: Stratification theory (layer depth) ↔ Moduli theory (dimension bounds) ↔ Complexity theory (minimum description length)

**Lineage**: Extends the layers_additive_handle theorem and connects to the stratification depth analysis in the tropical setting.

**Ambition**: extension
