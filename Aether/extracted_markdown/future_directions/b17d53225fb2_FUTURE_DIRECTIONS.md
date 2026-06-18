# Future Research Directions

## Synthesis

This research cycle established a rigorous combinatorial-topological framework for "cakes"—stratified surfaces characterized by genus, boundary structure, and layer decomposition. The key achievements are: (1) a complete stratification theory proving that equidimensional stratifications in dimension n have exactly n layers with dims(i) = n − i; (2) the moduli-Euler duality theorem dim(M_g) = −3χ for closed surfaces of genus g ≥ 2; and (3) the moduli additivity formula dim(M_{g₁+g₂}) = dim(M_{g₁}) + dim(M_{g₂}) + 3, which encodes the geometry of degeneration.

The most promising cross-domain connection is between **stratification theory and discrete Morse theory** (building on `Geometry/DiscreteMorseInequalities.lean` in the Catalog). A stratification of a variety induces a filtration on its homology, and the codimension jumps of the stratification relate to the Morse indices of a compatible Morse function. This connects our cake framework to the strong algebraic inequality proved in the Catalog, suggesting a unified treatment of dimension-counting via Morse-theoretic methods.

The highest breakthrough potential lies in Direction 1 (Tropical Moduli of Cakes), which would connect our combinatorial framework to tropical geometry—a rapidly developing field where moduli spaces have rich combinatorial structure that may be more amenable to formalization than their classical counterparts.

---

### Direction 1: Tropical Moduli of Cakes

**Conjecture**: The tropical moduli space of genus-g metric graphs (tropical curves) has dimension 3g − 3, matching the classical moduli dimension. Moreover, the tropical analogue of our moduli-Euler relation holds: the dimension of the tropical moduli space equals −3 times the tropical Euler characteristic (defined as 1 − g for a connected graph of genus g).

**Test**: Construct the tropical moduli space M_g^trop for g = 2, 3, 4 as a polyhedral complex (union of cones in ℝ^{3g-3}). Verify the dimension computationally by enumerating all trivalent graphs of genus g and checking that the associated cones have the correct dimension. For g = 2, there are exactly 2 trivalent graphs, and the moduli space should be a 3-dimensional polyhedral fan.

**Impact**: If true, this establishes a formal tropical-classical correspondence for moduli dimensions, providing a combinatorial proof of the 3g − 3 formula that avoids the analytic machinery of Teichmüller theory. If false, it would reveal a gap between tropical and classical moduli that would be independently interesting.

**Catalog References**: `Geometry/DiscreteMorseInequalities.lean` (for dimension-counting techniques), `Tropical/` directory (for existing tropical formalization infrastructure)

**Proof Strategy**: (1) Define tropical curves as metric graphs (finite graphs with edge lengths in ℝ₊). (2) Define the tropical moduli space as the quotient of the space of metric graphs by graph isomorphism. (3) Prove that the top-dimensional cones correspond to trivalent graphs, which have exactly 3g − 3 edges (by Euler's formula: edges − vertices = g − 1, and trivalency gives 2·edges = 3·vertices, yielding edges = 3g − 3). (4) Conclude dim(M_g^trop) = 3g − 3.

**Domain Bridges**: Tropical geometry <-> Algebraic geometry (tropicalization), Combinatorics <-> Topology (graph genus = surface genus)

**Lineage**: Builds on the moduli dimension formula and Euler characteristic computations from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Stratification Morse Theory and Betti Number Bounds

**Conjecture**: For a stratified space with an equidimensional stratification of depth n, the alternating sum of Betti numbers equals the Euler characteristic, and the individual Betti numbers satisfy b_i ≤ C(n, i) (binomial coefficient bound) when the stratification arises from a "generic" flag of hyperplane sections.

**Test**: Formalize the weak Morse inequalities for stratified spaces: ∑_{i=0}^{k} (−1)^{k−i} b_i ≤ ∑_{i=0}^{k} (−1)^{k−i} c_i, where c_i is the number of critical points of index i. Verify for the standard stratification of ℂP^n (which has one critical point of each even index).

**Impact**: This would connect our stratification theory to the discrete Morse inequalities already in the Catalog, creating a unified framework for bounding topological invariants via combinatorial data. The binomial bound, if true, would be a new result constraining the topology of equidimensionally stratified spaces.

**Catalog References**: `Geometry/DiscreteMorseInequalities.lean` (strong_algebraic_inequality), `FINAL/Geometry/DiscreteMorseInequalities.lean`

**Proof Strategy**: (1) Define Betti numbers combinatorially via chain complexes. (2) Use the stratification to construct a compatible Morse-like function. (3) Apply the strong algebraic inequality from the Catalog to bound Betti numbers by critical point counts. (4) For equidimensional stratifications, relate critical point counts to binomial coefficients via a counting argument.

**Domain Bridges**: Topology <-> Combinatorics (Morse theory), Algebra <-> Geometry (chain complexes on stratified spaces)

**Lineage**: Builds on equidim_depth_eq_dim, equidim_dims_eq, and strong_algebraic_inequality from the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Moduli Additivity and Degeneration Theory

**Conjecture**: The moduli additivity formula dim(M_{g₁+g₂}) = dim(M_{g₁}) + dim(M_{g₂}) + 3 generalizes to k-fold decomposition: for g = g₁ + ⋯ + gₖ with all gᵢ ≥ 2, dim(M_g) = ∑ dim(M_{gᵢ}) + 3(k−1). Moreover, the "+3" can be replaced by "+1" when working with complex dimensions (reflecting the 1 complex parameter of the separating node).

**Test**: Verify the k-fold formula by induction from the binary case (already proved). Then test the complex-dimensional version: for g₁ = g₂ = 2, dim_ℂ(M_4) = 9 = dim_ℂ(M_2) + dim_ℂ(M_2) + 1·(2−1)·... Wait: dim_ℂ(M_4) = 9, dim_ℂ(M_2) = 3, and 3 + 3 + 3 = 9. ✓ For three components g₁ = g₂ = g₃ = 2: dim_ℂ(M_6) = 15, and 3 + 3 + 3 + 3·2 = 15. ✓

**Impact**: A clean k-fold additivity formula would provide a powerful inductive tool for computing moduli dimensions and would formalize the "degeneration" perspective on moduli spaces—understanding complicated moduli by cutting surfaces into simpler pieces.

**Catalog References**: `Algebra/UnifyingTheory.lean` (for algebraic structure of additivity), moduliDim_additivity from this cycle

**Proof Strategy**: (1) State the k-fold formula as a theorem about sums. (2) Prove by induction on k, using the binary case as the base. (3) For the complex dimension version, define complexModuliDim(g) = (3g − 3) / 1 (it's already an integer) and prove the analogous additivity.

**Domain Bridges**: Algebra <-> Geometry (additivity structures), Combinatorics <-> Topology (graph decomposition = surface decomposition)

**Lineage**: Builds on moduliDim_additivity and euler_char_connected_sum from this cycle.

**Ambition**: extension

---

### Direction 4: Frosting Sheaves and Line Bundle Classification

**Conjecture**: The frosting sheaf of a cake (a line bundle on the boundary) is classified by its first Chern class c₁ ∈ H²(∂B, ℤ). For a surface with b boundary components (each a circle S¹), H²(∂B, ℤ) = 0, so all frosting sheaves are trivial. This means: **frosting doesn't matter for classification**—only genus and boundary components determine the cake.

**Test**: Formalize the cohomology calculation H²(S¹, ℤ) = 0 and conclude that line bundles on a disjoint union of circles are trivial. Alternatively, use the classification of line bundles by homotopy classes of maps to ℂP^∞ and note that [S¹, ℂP^∞] = π₁(ℂP^∞) = 0.

**Impact**: If true (which it is, classically), this simplifies the classification: cakes are determined entirely by (g, b, stratification type). The frosting is "topologically invisible." This is a satisfying result that sharpens the Fundamental Theorem of Cakes. If the formalization reveals subtleties (e.g., in the smooth vs. topological category), those would be interesting in their own right.

**Catalog References**: fundamental_theorem_of_cakes from this cycle, `Algebra/Advanced.lean`

**Proof Strategy**: (1) Define line bundles as principal GL(1)-bundles. (2) Define the first Chern class via the exponential exact sequence. (3) Compute H²(S¹, ℤ) = 0 using the long exact sequence or cellular cohomology. (4) Conclude triviality.

**Domain Bridges**: Algebra <-> Topology (sheaf cohomology), Geometry <-> Algebra (Chern classes)

**Lineage**: Builds on fundamental_theorem_of_cakes and the CakeData formalization from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Enumeration of Cake Topologies

**Conjecture**: The number of topologically distinct "cake configurations" with genus g, b boundary components, and equidimensional stratification of depth n is exactly 1 (for fixed g, b, n with n > 0)—that is, the equidimensional stratification is unique. For non-equidimensional stratifications, the count equals the number of compositions of n into positive parts, which is 2^{n−1}.

**Test**: Enumerate all stratifications of depth k in dimension n = 4 by generating all strictly decreasing sequences from 4 to 0. Count them and verify the formula: for k = 1, there's 1 sequence (4, 0); for k = 2, there are C(3,1) = 3 sequences; for k = 3, there are C(3,2) = 3; for k = 4, there is C(3,3) = 1. Total = 8 = 2³ = 2^{n−1}. ✓

**Impact**: A complete enumeration formula for stratifications would close the classification problem for cakes: the moduli space of cakes decomposes into 2^{n−1} strata (one per stratification type), each of dimension determined by the moduli-Euler relation.

**Catalog References**: equidim_depth_eq_dim and stratification_total_codim from this cycle

**Proof Strategy**: (1) Establish a bijection between stratifications of depth k in dimension n and (k−1)-element subsets of {1, …, n−1} (the "jump points"). (2) Count subsets: ∑_{k=1}^{n} C(n−1, k−1) = 2^{n−1}. (3) For the uniqueness of equidimensional stratifications, use equidim_dims_eq.

**Domain Bridges**: Combinatorics <-> Geometry (enumeration of geometric objects), Algebra <-> Combinatorics (composition counting)

**Lineage**: Builds on stratification theory from this cycle, particularly equidim_depth_eq_dim.

**Ambition**: extension
