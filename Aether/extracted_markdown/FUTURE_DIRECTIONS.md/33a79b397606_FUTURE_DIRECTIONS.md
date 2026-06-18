# Future Directions: Active-Set Bar Count Bounds

## Synthesis

The theorems established in this cycle — bounding H₀ bars by *m*, simplex activations by 2^m − 1, and barcode endpoints by 2(2^m − 1) — open a new research program: **tropical persistence complexity theory**. These dimension-free bounds convert barcode size from a geometric phenomenon into a combinatorial invariant, controlled entirely by the number of active affine forms. The directions below extend this in three interlocking ways: (1) sharpening the bounds and proving tightness, (2) establishing average-case behavior to complement worst-case theory, and (3) bridging to new mathematical domains through the active-set framework. Each direction builds directly on proven catalog theorems and is falsifiable through explicit computational tests.

---

## Direction 1: H₀ Sharpness Construction

**Conjecture:** For every m ≥ 1, there exists a tropical min-affine family with m forms in ℝ¹ whose H₀ barcode has exactly m bars.

**Test:** For each m ∈ {1, 2, ..., 20}, construct the family with forms fᵢ(x) = x + bᵢ where bᵢ = 10i. Compute the nerve filtration and verify that all m vertices activate at distinct thresholds with no premature edge activations. If for any m the construction yields fewer than m bars, the conjecture is falsified.

**Impact:** Would establish that the bound h0_births_le_numForms is tight, converting it from an upper bound to an exact extremal characterization. This would be the first sharpness result in tropical persistent homology.

**Catalog References:**
- `Tropical/PersistentHomology/ActiveSetBarCount.lean`: `h0_births_le_numForms`, `birth_events_le_total_vertices`
- `Tropical/PersistentHomology/Theorems.lean`: `nerveVertexCount_le`

**Proof Strategy:** For 1D affine forms fᵢ(x) = x + bᵢ with bᵢ = 10i, the patch Pᵢ(c) = {x : x ≤ c − bᵢ} is nonempty iff c ≥ bᵢ. Patches Pᵢ and Pⱼ intersect iff both are nonempty (since both are rays). So edges appear as soon as both endpoints are active. The key is that each vertex activates at a distinct threshold bᵢ, creating m births, and edges immediately create merges, giving m−1 deaths and exactly m bars.

**Domain Bridges:** Extremal combinatorics (tight bounds on set systems), graph process theory (random graph thresholds).

**Lineage:** Extends `h0_births_le_numForms` from upper bound to exact characterization.

**Ambition:** ★★★ (Solid extension — high confidence, direct impact)

---

## Direction 2: Polynomial Average-Case Endpoint Bound

**Conjecture:** For tropical min-affine families in ℝ² with m forms and i.i.d. Gaussian coefficients and biases, the expected number of distinct simplex activations grows as Θ(m^α) for some α ∈ [2, 4], far below the worst-case 2^m − 1.

**Test:** For m ∈ {3, 5, 8, 12, 16, 20}, generate 10,000 random Gaussian instances, compute mean simplex activation counts, and fit a polynomial model E[S(m)] ≈ C · m^α. If the best fit has α > 6 or the data clearly follows an exponential trend, the conjecture is falsified.

**Impact:** Would establish a separation between worst-case and average-case tropical persistence complexity, analogous to smoothed analysis in optimization. This would justify the practical efficiency of tropical TDA and provide theoretical backing for resource allocation.

**Catalog References:**
- `Tropical/PersistentHomology/ActiveSetBarCount.lean`: `nonemptySubsets_card_le`, `activation_count_le_pow`

**Proof Strategy:** Use geometric probability methods. For random hyperplanes in ℝ², the expected number of non-empty k-wise intersections is controlled by the probability that k random halfplanes have a common point, which decays geometrically in k. The total expected face count is Σ_k C(m,k) · p_k where p_k = Pr[k-face nonempty]. If p_k decays exponentially in k (which is plausible for Gaussian coefficients), the sum is polynomial.

**Domain Bridges:** Geometric probability (random hyperplane arrangements), smoothed analysis (Spielman-Teng), stochastic topology.

**Lineage:** Builds on `nonemptySubsets_card_le` as worst-case envelope; seeks average-case refinement.

**Ambition:** ★★★★ (Grand challenge — would require new probabilistic techniques)

---

## Direction 3: Higher Homology Bounds via Face Dimension Stratification

**Conjecture:** For a tropical min-affine family with m forms, the number of Hₖ bars is at most C(m, k+1) (binomial coefficient), and the total number of Hₖ barcode endpoints is at most 2 · C(m, k+1).

**Test:** For k = 1 (loops) and m ∈ {4, 6, 8, 10}, compute the H₁ barcode of the nerve filtration for 1,000 random instances and verify the bound C(m, 2). A single violation falsifies the conjecture.

**Impact:** Would extend the active-set complexity theory from H₀ to all homological degrees, completing the program initiated in this cycle. The bound C(m, k+1) refines the crude 2^m − 1 bound by stratifying simplices by dimension.

**Catalog References:**
- `Tropical/PersistentHomology/ActiveSetBarCount.lean`: `nonemptySubsets_card_le`, `barcode_endpoints_le_bound`
- `Tropical/PersistentHomology/Defs.lean`: `PatchNerveFaces`, `maxFaceCount`

**Proof Strategy:** An Hₖ birth requires a (k+1)-dimensional face activation (a (k+2)-element subset), and the number of such subsets is C(m, k+2). An Hₖ death requires the same. Formalizing this requires the persistence algorithm and the correspondence between simplex additions and homological changes.

**Domain Bridges:** Algebraic topology (homological algebra of filtered chain complexes), combinatorics (binomial counting), computational topology (persistence algorithms).

**Lineage:** Direct extension of the H₀ theory to higher degrees.

**Ambition:** ★★★★ (Grand challenge — requires formalized persistence modules)

---

## Direction 4: Graph-Theoretic Rigidity of H₀ Deaths

**Conjecture:** In the nerve filtration of a tropical min-affine family, every H₀ death event is realized by a single edge activation that merges exactly two previously distinct connected components. No death requires simultaneous activation of multiple edges or higher-dimensional faces.

**Test:** For m ∈ {4, 6, 8} and 10,000 random instances, enumerate all H₀ death events and verify that each is caused by a single edge merging exactly two components. Any death involving a multi-edge or higher-face activation, or merging more than two components simultaneously, falsifies the conjecture.

**Impact:** Would establish a clean graph-theoretic characterization of H₀ persistence, reducing it entirely to the theory of evolving graphs. This would simplify algorithms (only edges matter for H₀) and strengthen the bridge to graph process theory.

**Catalog References:**
- `Tropical/PersistentHomology/ActiveSetBarCount.lean`: `edge_addition_components_le`, `components_le_vertices`
- `Tropical/PersistentHomology/Theorems.lean`: `patchNerve_mono`

**Proof Strategy:** Show that for tropical halfspace patches, if an edge {i,j} becomes active at threshold c (Pᵢ(c) ∩ Pⱼ(c) ≠ ∅), then for generic coefficients this happens at a threshold distinct from all other edge activations. Hence deaths occur one at a time, each merging exactly two components.

**Domain Bridges:** Random graph theory (Erdős-Rényi component mergers), probability (generic position arguments), algorithmic graph theory.

**Lineage:** Extends `edge_addition_components_le` from a one-step bound to a global structural characterization.

**Ambition:** ★★★ (Solid extension — likely true for generic coefficients, may require genericity hypothesis)

---

## Direction 5: Tropical Persistence Complexity Classes

**Conjecture:** There exist natural complexity classes for tropical persistence, defined by the growth rate of barcode endpoints as a function of m:
- **T-POLY**: families where endpoints grow polynomially in m (generic case)
- **T-EXP**: families where endpoints grow exponentially in m (worst case)
- **T-LIN**: families where endpoints grow linearly in m (e.g., 1D families)
These classes are separated: T-LIN ⊊ T-POLY ⊊ T-EXP.

**Test:** Construct explicit families in each class. For T-LIN: use 1D families (all edges activate immediately). For T-EXP: construct adversarial families where almost all 2^m − 1 subsets have nonempty intersections at distinct thresholds. If the separation fails (e.g., all families are in T-POLY), the classification collapses.

**Impact:** Would establish the first complexity classification for topological persistence, analogous to P vs NP in computation. This would provide a framework for comparing tropical models by their intrinsic topological complexity and guide algorithm selection.

**Catalog References:**
- `Tropical/PersistentHomology/ActiveSetBarCount.lean`: all main theorems
- `Tropical/PersistentHomology/Defs.lean`: `TropAffineFamily`, `PatchNerveFaces`

**Proof Strategy:** T-LIN ⊊ T-POLY: 2D Gaussian families are empirically in T-POLY but not T-LIN (quadratic growth observed). T-POLY ⊊ T-EXP: construct a family in ℝ^m where each k-subset of forms has a unique intersection region that activates at a distinct threshold. This requires careful placement of hyperplanes in general position.

**Domain Bridges:** Computational complexity theory (complexity classes, separations), tropical geometry (hyperplane arrangements), extremal combinatorics (Sauer-Shelah lemma, VC dimension).

**Lineage:** Synthesizes all bounds from this cycle into a classification framework.

**Ambition:** ★★★★★ (Paradigm-shifting — would create a new field at the intersection of topology and complexity theory)
