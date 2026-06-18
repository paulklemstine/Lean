# Future Directions: Primewise Persistent Homology and Isogeny Volcano Depth

## Synthesis

This research cycle established a rigorous mathematical bridge between topological data analysis (persistent homology) and arithmetic geometry (isogeny volcanos of elliptic curves). The central discovery is that the first cycle birth radius in the BFS neighborhood filtration of a vertex in an l-isogeny volcano exactly determines the vertex's depth — a fact proved formally in Lean 4 and verified computationally across thousands of test cases with 100% accuracy.

Three cross-domain connections emerged as particularly promising. First, the **Euler characteristic bridge** (χ = 1 - β₁ for connected graphs) links graph combinatorics to algebraic topology in a way that makes the depth-detection mechanism fully transparent: depth is detected by the transition from χ = 1 (tree) to χ = 0 (unicyclic). Second, the **subtree growth analysis** connects the geometric series formula for l-ary trees to the vertex/edge counts that determine β₁, providing quantitative bounds on computational cost. Third, the **persistence bar length anti-monotonicity** creates a total ordering on depth classes via a topological invariant, extending the Catalog's `certified_radius_decreases_with_depth` result to the arithmetic geometry setting.

The highest breakthrough potential lies in Direction 1 (Supersingular Extension), because supersingular isogeny graphs are Ramanujan graphs with rich spectral and topological structure, and any persistent homology invariant that distinguishes vertices in these graphs would have immediate implications for post-quantum cryptography. The tightest connection to existing Catalog work is through `persistence_separation_from_degree` and `closure_classifier_exists_radius`, which provide the formal framework for radius-based topological classifiers that this work instantiates for volcano graphs.

---

### Direction 1: Persistent Homology of Supersingular Isogeny Graphs

**Conjecture**: The l-isogeny graph on supersingular elliptic curves over 𝔽_{p²} (a (l+1)-regular Ramanujan graph on ~p/12 vertices) has non-trivial H₁ persistent homology in the BFS filtration, and the persistence barcode encodes information about the distance to a fixed basepoint in the graph. Specifically, for two supersingular curves E₁, E₂ with d(E₁, basepoint) ≠ d(E₂, basepoint), the persistence barcodes of their radius-R neighborhoods differ for sufficiently large R.

**Test**: For small primes p (say p ∈ {101, 103, 107, 109, 113}), construct the 2-isogeny graph on supersingular curves over 𝔽_{p²} using SageMath. Pick a basepoint E₀ (e.g., the curve with j-invariant 1728). For each vertex E, compute the BFS neighborhood complex at radii 1, 2, ..., diameter/2, and record β₁(r). Check whether the distance d(E, E₀) correlates with the first cycle birth radius. Refute by finding two vertices at different distances with identical persistence profiles for all reasonable R.

**Impact**: If true, this would provide a topological distance oracle for supersingular isogeny graphs — directly relevant to the security of CSIDH and SQISign post-quantum cryptographic protocols. It would also establish that Ramanujan graph structure (optimal spectral gap) has topological consequences detectable by persistence.

**Catalog References**: `MachineLearning/PrimewisePersistence/VolcanoDepth.lean`, `Catalog/Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**: 
1. Establish that the girth of the supersingular l-isogeny graph is Ω(log p), so small-radius neighborhoods are tree-like
2. Show that the mixing time of random walks on the graph (≈ log p due to Ramanujan property) bounds the radius at which cycles first appear
3. Prove that the eigenvalue gap implies different vertices "see" the global cycle structure at different rates
4. Key lemma needed: explicit cycle count in radius-r balls of (l+1)-regular Ramanujan graphs

**Domain Bridges**: NumberTheory <-> Topology, Cryptography <-> SpectralGraphTheory

**Lineage**: Builds on `firstCycleBirth_eq_depth`, `depth_separation`, and the BFS neighborhood complex construction from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Higher Persistent Homology (H₂) for Finer Invariants

**Conjecture**: The H₂ persistent homology of the Vietoris-Rips complex built from the shortest-path metric on volcano graphs detects invariants finer than depth — specifically, the position within a depth layer (the "angular" coordinate in the volcano) can be recovered from H₂ birth/death times.

**Test**: For a 2-isogeny volcano with crater size c ≥ 6 and depth d ≥ 3, build the Vietoris-Rips complex on the shortest-path metric at filtration parameters t = 1, 2, ..., diameter. Compute H₂ persistence and check whether vertices at the same depth but different angular positions have different H₂ barcodes. Focus on crater vertices: for two crater vertices at antipodal positions in the crater cycle, compare their H₂ barcodes at radius ⌊c/4⌋.

**Impact**: If true, this would show that persistent homology provides a complete invariant for vertex position in volcano graphs (not just depth), enabling full graph navigation via topology. This would also connect to the Catalog's tropical persistence constructions.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`, `exists_unique_barcode_from_rank_data`

**Proof Strategy**:
1. Show that the Vietoris-Rips complex at parameter t captures the t-neighborhood graph
2. Prove that H₂ classes correspond to "filled triangles" in the BFS ball, which depend on the angular position in the crater
3. Use the relationship between simplicial homology and graph minors to detect position-dependent invariants
4. Key lemma: the clique complex of the crater cycle at radius t has H₂ ≠ 0 iff t ≥ ⌈c/3⌉

**Domain Bridges**: Topology <-> GraphTheory, NumberTheory <-> SimplicialHomology

**Lineage**: Extends the H₁ depth detection from this cycle to higher homological dimensions

**Ambition**: extension

---

### Direction 3: Topological Obstructions to Isogeny Path-Finding

**Conjecture**: The persistence barcode of the BFS neighborhood complex provides a certificate that no isogeny path of length < k exists between two curves, when the persistence data of their respective neighborhoods is sufficiently different. Formally: if the bottleneck distance between the H₁ barcodes of B_R(E₁) and B_R(E₂) exceeds a threshold τ(R, l), then d(E₁, E₂) ≥ 2R - c, where c depends only on the crater geometry.

**Test**: For 2-isogeny volcanos of depth 4 with crater size 3, select pairs (E₁, E₂) at various distances. Compute their respective H₁ barcodes at radii R = 1, ..., 8. Compute the bottleneck distance between barcodes and plot against the true graph distance. Refute by finding pairs with large bottleneck distance but small graph distance.

**Impact**: If true, this would provide topological certificates for the hardness of isogeny path-finding — directly relevant to the security assumptions underlying isogeny-based cryptography. It would also create a novel connection between persistence stability theory and cryptographic hardness assumptions.

**Catalog References**: `MachineLearning/PrimewisePersistence/CycleRankFiltration.lean`, `Cryptography/BerggrenFingerprintRigidity.lean`

**Proof Strategy**:
1. Use the stability theorem for persistent homology: small perturbations in the filtration produce small changes in the barcode
2. Show that two vertices at distance d produce filtrations that differ by exactly d in the bottleneck distance
3. The key is that the "shift" in first cycle birth (Theorem 3.2) creates a bottleneck distance of exactly |k₁ - k₂| between the barcodes of vertices at depths k₁ and k₂
4. Extend to distances that cross depth boundaries

**Domain Bridges**: Cryptography <-> Topology, NumberTheory <-> PersistenceStability

**Lineage**: Builds on `barLength_anti` and `depth_separation` from this cycle

**Ambition**: grand_challenge

---

### Direction 4: Tropical Persistence and Volcano Depth

**Conjecture**: There is a functorial correspondence between the H₁ persistence barcode of a volcano neighborhood complex and a tropical curve obtained by tropicalizing the universal family of elliptic curves over the volcano. Specifically, the tropical cycle lengths in the tropicalization equal the persistence bar lengths in the neighborhood filtration.

**Test**: For small examples (l = 2, depth ≤ 3), construct both the persistence barcode and the tropical curve of the volcano graph (as a metric graph). Verify that the barcode intervals correspond to cycles in the tropical curve. Refute by exhibiting a barcode interval with no tropical cycle counterpart.

**Impact**: This would unify two seemingly unrelated approaches to the topology of arithmetic objects — persistence homology (from TDA) and tropical geometry (from algebraic geometry) — through the common structure of volcano graphs. The Catalog already has `exists_unique_barcode_from_rank_data` connecting tropical and persistence perspectives; this direction would instantiate that connection in the arithmetic setting.

**Catalog References**: `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`, `exists_unique_barcode_from_rank_data`, `Tropical/`

**Proof Strategy**:
1. Define the tropicalization of a volcano graph as a metric graph with edge lengths
2. Show that the tropical H₁ (cycle space of the metric graph) corresponds to the BFS-filtration H₁
3. Use the fact that volcano graphs are planar (for l = 2) to establish the correspondence
4. Key lemma: the first Betti number of a tropicalization equals the cycle rank of the graph

**Domain Bridges**: Tropical <-> NumberTheory, Topology <-> AlgebraicGeometry

**Lineage**: Connects `exists_unique_barcode_from_rank_data` to this cycle's volcano depth detection

**Ambition**: extension

---

### Direction 5: Machine Learning on Persistence Diagrams for Curve Classification

**Conjecture**: A simple feedforward neural network trained on vectorized persistence diagrams (using persistence images or persistence landscapes) of BFS neighborhood complexes can classify the CM discriminant of an ordinary elliptic curve E/𝔽_p with accuracy > 90% for p > 10^4, using only local isogeny graph information at radius ≤ 10.

**Test**: For primes p ∈ [10^4, 10^5], enumerate ordinary curves and compute their CM discriminants and persistence diagrams at radius 10 in the 2-isogeny graph. Train a neural network on 80% of curves and test on the remaining 20%. Refute by showing that the test accuracy plateaus below 90% as p increases.

**Impact**: This would demonstrate that topological features extracted from local graph neighborhoods encode global algebraic invariants (the CM discriminant), establishing persistent homology as a practical tool for arithmetic geometry. It connects the Catalog's machine learning frameworks to number theory.

**Catalog References**: `MachineLearning/ClosureNetworks.lean`, `closure_classifier_exists_radius`, `MachineLearning/OperadicDeepLearning/Foundations.lean`

**Proof Strategy**:
1. Establish that the persistence diagram encodes depth (by our main theorem)
2. Show that depth combined with volcano structure (crater size, branching factor) determines the CM discriminant up to finitely many choices
3. The neural network serves as a universal function approximator that learns the depth-to-discriminant mapping from data
4. Key empirical test: does accuracy improve with p? (it should, as exceptional vertices become rarer)

**Domain Bridges**: MachineLearning <-> NumberTheory, Topology <-> ArithmeticGeometry

**Lineage**: Builds on the depth classifier from this cycle and connects to `closure_classifier_exists_radius`

**Ambition**: extension
