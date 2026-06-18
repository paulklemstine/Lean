# Future Directions: Persistent Torsion Detection via Tor₁

## Synthesis

The results formalized in this work — pointwise torsion detection, functoriality along filtrations, vanishing for free modules, and torsion birth existence — establish `Tor₁(ℤ/pℤ, -)` as a verified, prime-indexed observable for topological data analysis. This opens a program of **derived persistence theory**: extending TDA beyond field coefficients using the full machinery of homological algebra. The directions below build directly on our catalog theorems, progressing from concrete extensions (multi-prime decompositions, stability) to paradigm-shifting conjectures (spectral-sequence persistence, arithmetic phase classification).

---

## Direction 1: Multi-Prime Torsion Decomposition Theorem

**Conjecture**: For any finitely generated abelian group A, the full torsion structure of A is determined by the family {Tor₁(ℤ/pℤ, A) : p prime}. Moreover, for filtered complexes, the multi-prime torsion barcode {torsionSupport(p, H) : p prime} separates more filtered homotopy types than any single field-valued persistence module.

**Test**: Construct a benchmark suite of 50+ filtered triangulated surfaces and CW complexes. Compute standard Betti barcodes over ℚ, 𝔽₂, 𝔽₃, 𝔽₅ and the multi-prime torsion barcode. Verify that there exist pairs of filtrations with identical field barcodes but distinct multi-prime torsion barcodes. Specific test: filtered RP² vs filtered S² with matched Betti data.

**Impact**: Would establish torsion barcodes as a strictly finer invariant than the entire suite of field-valued barcodes, justifying the overhead of integral coefficient computation.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `tor1_vanishes_iff_no_n_torsion`, `prime_selectivity`, `torsion_invisible_wrong_characteristic`.

**Proof Strategy**: Use the structure theorem for finitely generated abelian groups to decompose A ≅ ℤ^r ⊕ ⊕ᵢ ℤ/pᵢ^{eᵢ}ℤ. Then Tor₁(ℤ/pℤ, A) ≅ ⊕ᵢ ℤ/gcd(p, pᵢ^{eᵢ})ℤ. By varying p over all primes, we recover the full list of prime powers pᵢ^{eᵢ}. Formalize this as a reconstruction theorem in Lean.

**Domain Bridges**: Algebraic topology ↔ Number theory ↔ Data science.

**Lineage**: Direct extension of `prime_selectivity` and `zmod_no_coprime_torsion`.

**Ambition**: ★★★ — Solid extension, computationally verifiable, publishable.

---

## Direction 2: Stability of Torsion Barcodes Under Filtration Perturbations

**Conjecture**: Under filtration refinements that preserve chain-homotopy type at each stage, the set of torsion birth indices is stable: birth indices change by at most the mesh of the refinement. More precisely, if two filtrations F and F' have interleaving distance δ, then their torsion barcodes are δ-matched in an appropriate bottleneck metric.

**Test**: Compute torsion barcodes for a filtration of RP² and its barycentric subdivision. Verify that birth indices differ by at most 1 refinement step. Test on 10+ examples with varying mesh sizes to establish empirical stability bounds.

**Impact**: A stability theorem for torsion barcodes would be the torsion analogue of the celebrated stability theorem for ordinary persistence (Cohen-Steiner, Edelsbrunner, Harer 2007). This would make torsion barcodes viable for noisy data.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `exists_torsion_birth`, `torsion_persistence_functorial`, `torPersistenceModule`.

**Proof Strategy**: Adapt the algebraic stability theorem using interleaving of persistence modules. The key difficulty: torsion modules over ℤ do not have interval decompositions in general (failure of Krull-Schmidt). Work instead with the support set `torsionSupport` and show that it is Hausdorff-stable under chain-homotopy equivalences.

**Domain Bridges**: Persistence theory ↔ Metric geometry ↔ Numerical analysis.

**Lineage**: Extends `exists_torsion_birth` and `pTorPersistence_map_comp`.

**Ambition**: ★★★★ — Technically deep, would be a significant advance in applied algebraic topology.

---

## Direction 3 (Grand Challenge): Ext-Tor Persistent Spectral Sequence

**Conjecture**: For a filtered chain complex C over ℤ, there exists a spectral sequence whose E₂ page involves Tor and Ext groups of the associated graded, converging to the integral homology of the total complex. The persistent version of this spectral sequence produces a hierarchy of torsion invariants: the d₂ differentials encode "secondary torsion operations" invisible to Tor₁ alone.

**Test**: Compute the E₂ page for explicit filtered triangulations of the mapping torus of the degree-2 map S¹ → S¹. Verify that d₂ detects torsion phenomena that Tor₁ alone misses (e.g., higher torsion in H₂ of lens spaces).

**Impact**: Would establish a "derived persistence theory" program — a systematic framework for extracting higher-order topological invariants from filtered complexes using the full power of homological algebra.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — all theorems; `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean` — `Tor1_ZMod_ZMod_equiv`, `Ext1_ZMod_ZMod_equiv`.

**Proof Strategy**: Construct the spectral sequence from the filtered complex using the standard construction (exact couple or Dress's approach). Formalize the E₂ identification using the universal coefficient theorem for Tor/Ext. The key challenge is formalizing spectral sequence convergence in Lean, building on Mathlib's emerging infrastructure.

**Domain Bridges**: Homological algebra ↔ Homotopy theory ↔ Mathematical physics (gauge theory anomalies).

**Lineage**: Natural generalization of pointwise Tor₁ detection to a spectral sequence framework.

**Ambition**: ★★★★★ — Paradigm-shifting. Would open an entirely new field of derived TDA.

---

## Direction 4 (Grand Challenge): Arithmetic Phase Classification for Materials

**Conjecture**: The multi-prime torsion barcode of the configuration space of a discrete physical system (e.g., spin lattice, molecular crystal) classifies its topological phase. Specifically: two systems are in the same topological phase if and only if their torsion barcodes agree for all primes p up to some bound P depending on the system size.

**Test**: Compute torsion barcodes for configuration spaces of:
(a) The Kitaev toric code on a torus (known Z₂ torsion),
(b) ℤ/3ℤ gauge theory on a lattice (known Z₃ torsion),
(c) Synthetic datasets with inserted topological defects.
Verify that phase transitions correspond exactly to torsion barcode changes.

**Impact**: Would provide a rigorous, computationally accessible topological order parameter that goes beyond the standard K-theory or cobordism classification, using the arithmetic structure of torsion.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `pTorPersistence_vanishes_of_free` (trivial phase = free = no torsion), `torsion_invisible_wrong_characteristic` (wrong probe misses the phase).

**Proof Strategy**: For lattice gauge theories, the configuration space is a product of finite groups, whose homology has explicit torsion coming from group cohomology. The torsion barcode of a filtration by energy level detects phase boundaries. Formalize the special case of ℤ/nℤ gauge theory using the concrete Tor₁ computations from the catalog.

**Domain Bridges**: Condensed matter physics ↔ Algebraic topology ↔ Quantum information.

**Lineage**: Extends `zmod_has_p_torsion`, `zmod6_has_both_torsions` to physical systems.

**Ambition**: ★★★★★ — Would bridge formal mathematics and experimental physics.

---

## Direction 5: Verified Torsion Barcode Algorithm

**Conjecture**: There exists a polynomial-time algorithm that, given a filtered simplicial complex K with N simplices and L filtration levels, computes the p-torsion barcode in time O(N³ · L · log(max coefficient)). Moreover, this algorithm can be formally verified in Lean, producing a certified torsion barcode with a machine-checked proof of correctness.

**Test**: Implement the algorithm using verified Smith Normal Form computation. Benchmark on:
(a) Random Rips complexes on point clouds (100-1000 points),
(b) Filtered triangulations of RP², Klein bottle, lens spaces,
(c) Cubical complexes from image data.
Compare performance with existing integral homology implementations (e.g., CHomP, Perseus).

**Impact**: Would make torsion barcodes practical for real-world TDA applications, with the added guarantee of formal correctness — essential for safety-critical applications in materials science and engineering.

**Catalog References**: `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — all theorems provide the mathematical specification that the algorithm must satisfy.

**Proof Strategy**: Use the Smith Normal Form algorithm for boundary matrices, extract invariant factors, and apply Tor₁ = gcd computation. The verification amounts to proving: (1) SNF correctness, (2) Homology = ker/im, (3) Tor₁ = n-torsion. Steps (2) and (3) are already formalized.

**Domain Bridges**: Verified computation ↔ Computational topology ↔ Software engineering.

**Lineage**: Computational instantiation of the theoretical framework.

**Ambition**: ★★★ — Practical and achievable, high impact for the TDA community.
