# Future Directions: Torsion Barcode Stability

## Synthesis

The stability of torsion barcodes via primary decomposition opens several interconnected research directions spanning algebraic topology, information theory, computational algebra, and applications in materials science and quantum computing. The central thread is the reduction principle: complex algebraic structures can be decomposed into simpler pieces (p-primary components) where powerful theorems apply. This principle extends naturally to multi-parameter persistence, derived functors, and connections with spectral geometry.

The following directions are ordered by a combination of tractability and impact. Directions 1-2 are direct extensions of our current work; Direction 3 bridges to quantum topology; Directions 4-5 are grand challenges that could reshape multiple fields.

---

## Direction 1: Sharp Torsion Stability Bound

**Conjecture:** The δ bound in torsion barcode stability is sharp. For every δ > 0 and prime p, there exist filtrations F, G of finite simplicial complexes such that:
- The interleaving distance between their torsion persistence modules is exactly δ
- The p-torsion bottleneck distance is exactly δ
- The ordinary (free-part) bottleneck distance is strictly less than δ

**Test:** 
1. Construct filtrations of RP² (p=2) and lens spaces L(p,1) (odd p) with a δ-shifted attaching map
2. Compute both torsion and ordinary barcodes
3. Verify: d_B(torsion) = δ and d_B(ordinary) < δ
4. Repeat for p ∈ {2, 3, 5, 7, 11} and δ ∈ {0.1, 0.5, 1.0}

**Impact:** If confirmed, this demonstrates that torsion barcodes are strictly more sensitive than ordinary barcodes to certain perturbations, making them essential (not just supplementary) descriptors in TDA.

**Catalog References:** `Pythagorean/TorsionBarcodeStability.lean` — `sharpTorsionStabilityConj`, `pprimary_interleaving_preservation`

**Proof Strategy:** Construct explicit examples using the mapping cylinder of the degree-p map on S¹. The key is to show that the free-part barcode "averages out" the perturbation while the torsion barcode preserves it.

**Domain Bridges:** Algebraic topology → Topological data analysis → Computational geometry

**Lineage:** Extends Cohen-Steiner–Edelsbrunner–Harer (2007) sharpness results to torsion.

**Ambition:** ★★★ — High-impact result that would change how practitioners think about barcode selection.

---

## Direction 2: Torsion Entropy Subadditivity

**Conjecture:** The torsion barcode entropy is subadditive under direct sums of filtrations:
$$H(\text{TorsionBarcode}(F \oplus G)) \leq H(\text{TorsionBarcode}(F)) + H(\text{TorsionBarcode}(G))$$

**Test:**
1. Construct filtrations F (RP²) and G (Klein bottle)
2. Compute torsion barcodes of F, G, and F ⊕ G
3. Verify H(F ⊕ G) ≤ H(F) + H(G) for various perturbation levels

**Impact:** Would establish torsion barcode entropy as a genuine information measure, enabling mutual information and conditional entropy computations for topological features.

**Catalog References:** `Pythagorean/TorsionBarcodeStability.lean` — `torsionBarcodeEntropy'`, `channel_capacity_torsion_bound'`, `prod_ptorsion_detected_iff`

**Proof Strategy:** Use the product decomposition theorem (`prod_ptorsion_detected_iff`) to relate the torsion of F ⊕ G to the torsions of F and G individually. The entropy subadditivity should follow from the classical subadditivity of Shannon entropy for independent distributions, plus the functoriality of p-primary decomposition.

**Domain Bridges:** Topological data analysis → Information theory → Statistical mechanics (entropy additivity)

**Lineage:** Builds on `channel_capacity_torsion_bound'` and the product decomposition theorems.

**Ambition:** ★★ — Solid extension with clear practical applications in multi-modal data analysis.

---

## Direction 3: Reidemeister Torsion Barcode Stability

**Conjecture:** The Reidemeister torsion (R-torsion) of a filtered manifold, viewed as a function of the filtration parameter, defines a "torsion invariant barcode" that satisfies the same δ-stability bound as the ordinary torsion barcode.

**Test:**
1. Compute R-torsion for triangulated lens spaces L(p,1) at each filtration level
2. Perturb the triangulation
3. Measure the change in the R-torsion function
4. Verify: ||R-torsion(F) - R-torsion(G)||_∞ ≤ C · δ for some explicit constant C

**Impact:** Would bridge persistent homology to spectral geometry (via the Cheeger-Müller theorem equating R-torsion with analytic torsion) and to quantum topology (via connections to Chern-Simons invariants and Turaev-Viro state sums).

**Catalog References:** `Pythagorean/TorsionBarcodeStability.lean` — `stability_reduction_step`, `pprimary_interleaving_preservation`

**Proof Strategy:** R-torsion is computed from the alternating product of determinants of the Laplacians on forms. The stability of individual torsion components (our main theorem) should imply stability of the alternating product, but with potentially different constants. The key challenge is controlling the interaction between different homological degrees.

**Domain Bridges:** Algebraic topology → Spectral geometry → Quantum field theory (Chern-Simons) → Quantum computing (topological codes)

**Lineage:** Grand challenge extending Cheeger-Müller theorem to the persistent setting.

**Ambition:** ★★★★ — Paradigm-shifting connection between TDA and mathematical physics.

---

## Direction 4: Multi-Parameter Torsion Persistence

**Conjecture:** For multi-parameter persistence modules over ℤ indexed by ℝ≥0 × ℝ≥0, the p-primary decomposition still reduces stability to the field-coefficient case, yielding a multi-parameter torsion barcode stability theorem.

**Test:**
1. Construct bi-filtered simplicial complexes with known torsion
2. Compute multi-parameter torsion invariants (rank invariant, fibered barcode)
3. Apply bi-parameter perturbations of magnitude δ
4. Verify that torsion invariants change by at most f(δ) for some function f

**Impact:** Multi-parameter persistence is the frontier of TDA. Establishing torsion stability in this setting would open multi-parameter torsion analysis for applications in:
- Multi-modal data analysis (time × scale)
- Persistent cohomology operations (Steenrod squares)
- Machine learning (multi-parameter topological features)

**Catalog References:** `Pythagorean/TorsionBarcodeStability.lean` — `PersistMod`, `Interleaving'`, `pPrimarySub`

**Proof Strategy:** The primary decomposition step extends directly (p-primary components are still modules over the field ℤ/pℤ). The difficulty is that multi-parameter modules over a field do not have unique barcode decompositions. One approach: use the fibered barcode (Lesnick-Wright) or the rank invariant (Carlsson-Zomorodian) instead of the full barcode, and prove stability of those invariants.

**Domain Bridges:** Algebraic topology → Commutative algebra → Machine learning → Signal processing

**Lineage:** Extends Lesnick (2015) multi-parameter stability to integer coefficients.

**Ambition:** ★★★★★ — Grand challenge that could unify the multi-parameter and integer-coefficient frontiers of TDA.

---

## Direction 5: Torsion Barcode Machine Learning

**Conjecture:** Stable torsion barcodes provide strictly more discriminative features than ordinary barcodes for classification tasks on datasets with intrinsic torsion (e.g., molecular configuration spaces, image patch spaces).

**Test:**
1. Construct datasets where ground-truth labels depend on torsion:
   - Molecular conformations with chiral centers (non-orientable rotations)
   - Synthetic point clouds on RP², Klein bottle, L(p,1)
2. Train classifiers using:
   (a) Ordinary barcode features only
   (b) Torsion barcode features only  
   (c) Combined features
3. Compare classification accuracy
4. Verify: accuracy(c) > accuracy(a) on torsion-dependent tasks

**Impact:** Would demonstrate practical machine learning value of torsion barcodes, potentially transforming:
- Drug discovery (chiral molecule classification)
- Materials informatics (defect classification)
- Computer vision (texture/shape discrimination)

**Catalog References:** `Pythagorean/TorsionBarcodeStability.lean` — `zmod2_selectivity'` (prime selectivity), `torsionBarcodeEntropy'` (feature engineering)

**Proof Strategy:** Not a mathematical proof per se, but a systematic empirical study. The stability theorem guarantees that torsion barcode features are robust to noise, which is a prerequisite for any ML application. The prime selectivity results suggest using per-prime features as a multi-channel input to neural networks.

**Domain Bridges:** Algebraic topology → Machine learning → Computational chemistry → Computer vision

**Lineage:** Extends Carlsson et al. (2008) Klein bottle discovery to a systematic ML pipeline.

**Ambition:** ★★★ — High practical impact, moderate mathematical depth, clear experimental protocol.
