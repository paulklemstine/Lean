# Future Directions: Scalable Arithmetic TDA Pipeline

## Synthesis

The torsion profile extraction pipeline established here opens five interconnected research directions, spanning computational topology, number theory, and data science. The central thread is that **torsion is a computable, meaningful, and under-exploited topological invariant** — and the tools of arithmetic (p-adic valuations, class groups, prime factorization) provide both the computational machinery and the conceptual framework for extracting it at scale.

Directions 1-2 extend the pipeline to persistent and parallel settings, making it practical for large-scale TDA. Direction 3 deepens the cross-domain bridge to arithmetic topology. Direction 4 tests the geometric boundedness conjecture computationally. Direction 5 proposes a paradigm-shifting unification of torsion-based TDA with spectral methods.

All directions build on the formally verified theorems in `Pythagorean/TorsionProfileTheorems.lean` and the definitions in `Pythagorean/TorsionProfileDefs.lean`, as well as the catalog results in `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`.

---

## Direction 1: Persistent Torsion Barcodes via Iterated SNF

**Conjecture:** For a filtered simplicial complex K₁ ⊂ K₂ ⊂ ⋯ ⊂ Kₙ, the persistent torsion — tracking the birth and death of torsion classes across filtration — can be computed in O(N³ · log M) time where N is the total number of simplices and M is the maximum SNF entry, by maintaining a persistent SNF decomposition that updates incrementally as simplices are added.

**Test:** Implement persistent SNF for Rips filtrations on random point clouds (n = 100, 500, 1000 in ℝ³). Compare timing to the naive approach (recompute SNF at each filtration step). The conjecture predicts a speedup of at least 10× for n ≥ 500.

**Impact:** Enables torsion-aware persistence diagrams, a strict generalization of standard persistence that captures non-orientable features. Would transform TDA from a field-homology tool to a full integral-homology tool.

**Catalog References:**
- `Pythagorean/TorsionProfileTheorems.lean`: `snfDiagToTorsionFactors_chain`, `padic_val_monotone_of_dvd_chain`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsion_persistence_functorial`, `exists_torsion_birth`

**Proof Strategy:** Formalize the persistent SNF update rule: when a simplex σ is added to the complex, the new boundary matrix differs from the old by a rank-1 update. Show that this induces at most O(N) changes to the SNF diagonal, using the stability of invariant factors under small perturbations.

**Domain Bridges:** Computational topology ↔ matrix perturbation theory ↔ numerical linear algebra

**Lineage:** Extends `padic_val_monotone_of_dvd_chain` from static to dynamic setting.

**Ambition:** ★★★☆☆ (Solid extension — persistent SNF is known to be possible but not formalized)

---

## Direction 2: GPU-Parallel SNF for Large-Scale TDA

**Conjecture:** The Smith Normal Form of sparse boundary matrices (with O(d) nonzeros per column, where d is the maximum simplex dimension) can be computed in O(N² / P + N log N) time on P processors using a block-diagonal decomposition that exploits the locality of boundary operators.

**Test:** Implement block-parallel SNF on GPU for Rips complexes with N = 10⁴, 10⁵, 10⁶ simplices. Measure speedup as a function of GPU cores (P = 256, 1024, 4096). The conjecture predicts near-linear speedup up to P = N / log N.

**Impact:** Makes torsion computation practical for industrial-scale datasets (millions of simplices), enabling torsion-aware TDA in production ML pipelines.

**Catalog References:**
- `Pythagorean/TorsionProfileTheorems.lean`: `linear_sieve_for_bounded_entries`
- `Pythagorean/TorsionProfileDefs.lean`: `EratosthenesSieve`

**Proof Strategy:** Decompose the boundary matrix into blocks corresponding to connected components of the dual graph. Show that SNF can be computed independently on each block, then merged in O(N log N) time using the Chinese Remainder Theorem for invariant factors.

**Domain Bridges:** Computational topology ↔ parallel computing ↔ sparse linear algebra

**Lineage:** Builds on `linear_sieve_for_bounded_entries` for the sieve parallelization.

**Ambition:** ★★★★☆ (Challenging — requires new algorithmic ideas for parallel integer linear algebra)

---

## Direction 3: Arithmetic Topology Bridge — Torsion as Class Group Analog (Grand Challenge)

**Conjecture:** For 3-manifolds M obtained as branched covers of S³ over a knot K, the torsion in H₁(M; ℤ) equals the class number of the associated number field F_K (under Mazur's arithmetic topology dictionary). Moreover, this correspondence can be made *computationally effective*: computing the torsion profile of a triangulation of M gives a computable upper bound on the class number of F_K.

**Test:** For the trefoil, figure-eight, and (2,5) torus knots, compute both sides:
- Triangulate the n-fold cyclic branched cover of S³ over K (for n = 2, 3, 5, 7)
- Compute H₁ via SNF and extract the torsion profile
- Compute the class group of the corresponding number field using PARI/GP
- Verify equality of the torsion order and the class number

**Impact:** Would establish the first *computational* bridge between algebraic number theory and topological data analysis. Class number computation is a fundamental problem in number theory; if TDA provides an alternative approach via topology, this would be paradigm-shifting.

**Catalog References:**
- `Pythagorean/TorsionProfileTheorems.lean`: `zmod_has_p_torsion_of_prime_dvd`, `zmod_no_torsion_of_coprime`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `tor1_vanishes_iff_no_n_torsion`, `prime_selectivity`

**Proof Strategy:** Formalize the Mazur dictionary for cyclic branched covers. The key step is showing that the Alexander polynomial of K, evaluated at roots of unity, gives the class number of the cyclotomic specialization. Then connect the Alexander polynomial to the SNF of the boundary matrix of the branched cover.

**Domain Bridges:** Algebraic topology ↔ algebraic number theory ↔ knot theory

**Lineage:** Extends `zmod_has_p_torsion_of_prime_dvd` and `zmod_no_torsion_of_coprime` from cyclic groups to branched cover homology.

**Ambition:** ★★★★★ (Grand challenge — connects two major mathematical disciplines)

---

## Direction 4: Geometric Boundedness Conjecture

**Conjecture (Geometric Boundedness):** For Rips complexes R_ε(X) on point clouds X ⊂ ℝᵈ with |X| = n, the maximum SNF diagonal entry M(n,d,ε) is bounded by d^{O(d)}, independent of n. Consequently, the prime sieving step in torsion extraction costs O(N) rather than O(N log N).

**Test:** For each d ∈ {2, 3, 5, 8, 12} and n ∈ {50, 100, 500, 1000}:
1. Generate 100 random point clouds in ℝᵈ
2. For each, compute the Rips complex at ε = median pairwise distance
3. Compute SNF of all boundary matrices
4. Record max diagonal entry M(n,d)
5. Plot M(n,d) vs n for fixed d

If M(n,d) grows with n for any d, the conjecture is falsified. If M(n,d) stabilizes, fit the bound as a function of d.

**Impact:** Would prove that torsion extraction is *strictly cheaper* than Betti number computation for geometric data, since the prime sieving becomes O(N) while the shared SNF cost remains O(N³).

**Catalog References:**
- `Pythagorean/TorsionProfileTheorems.lean`: `linear_sieve_for_bounded_entries`, `primeFactors_chain_last`

**Proof Strategy:** Use the nerve theorem to relate the Rips complex to the Čech complex, whose boundary entries are bounded by the combinatorics of unit ball coverings in ℝᵈ. The bound d^{O(d)} would follow from the kissing number bound in dimension d.

**Domain Bridges:** Computational topology ↔ discrete geometry ↔ combinatorics

**Lineage:** Directly tests the hypotheses underlying `linear_sieve_for_bounded_entries`.

**Ambition:** ★★★☆☆ (Testable conjecture with clear computational protocol)

---

## Direction 5: Torsion Spectroscopy — Prime Decomposition as Feature Engineering (Grand Challenge)

**Conjecture:** The *torsion spectrum* — the function p ↦ dim_𝔽_p H_k(X; 𝔽_p) − dim_ℚ H_k(X; ℚ) — is a strictly more powerful classifier than persistent Betti numbers for topological classification tasks. Specifically, for shape classification on the SHREC benchmark, torsion-augmented features improve accuracy by at least 5% over Betti-number-only features.

**Test:**
1. Compute persistent Betti numbers for all shapes in the SHREC'17 dataset
2. Compute torsion spectra at primes p = 2, 3, 5, 7 for all shapes
3. Train identical random forest classifiers on (a) Betti-only and (b) Betti+torsion features
4. Compare classification accuracy

**Impact:** Would establish torsion as a practical feature for machine learning on topological data, opening a new modality for topological neural networks.

**Catalog References:**
- `Pythagorean/TorsionProfileTheorems.lean`: `padic_val_product`, `total_p_rank_eq_sum_valuations`
- `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsion_invisible_wrong_characteristic`

**Proof Strategy:** The formal component would prove that torsion spectra are stable under small Hausdorff perturbations (following the stability theorem for persistent homology). The experimental component tests classification power directly.

**Domain Bridges:** Topological data analysis ↔ machine learning ↔ shape analysis

**Lineage:** Extends `torsion_invisible_wrong_characteristic` from a theoretical observation to a practical feature engineering method.

**Ambition:** ★★★★★ (Grand challenge — requires both theoretical and experimental validation)
