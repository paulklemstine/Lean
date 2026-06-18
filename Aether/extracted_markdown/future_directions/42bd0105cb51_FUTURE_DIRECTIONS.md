# Future Directions: Primewise Birth Spectra and Arithmetic Persistence

## Synthesis

The separation theorem establishes that primewise torsion-birth spectra form a strictly finer invariant than the global torsion birth set. This opens an entire axis of investigation: wherever filtrations and torsion coexist, primary decomposition introduces a temporal dimension that the classical global invariant discards. The five directions below exploit this principle across algebraic topology, number theory, data science, and information theory. They are linked by a common thread: **arithmetic structure leaves detectable chronological signatures in filtered objects**, and these signatures connect to deep phenomena in multiple domains. The directions progress from immediate extensions (Directions 1–2), through ambitious cross-domain bridges (Directions 3–4), to a grand challenge that could reshape how we think about persistence (Direction 5).

---

## Direction 1: Prime-Resolved Persistence Barcodes

**Conjecture:** For filtered finitely generated abelian groups over ℤ, the primewise birth-death barcode (recording, for each prime p, the birth and death times of p-primary torsion generators) is a strictly finer invariant than the torsion subgroup barcode, and satisfies a Hausdorff-type stability theorem analogous to the classical bottleneck stability for persistence diagrams.

**Test:** Construct explicit filtered abelian groups (e.g., arising from simplicial filtrations of lens spaces) where the aggregate torsion barcode is identical but the 2-primary and 3-primary barcodes differ. Verify computationally on at least 5 non-trivial examples. Prove the stability theorem for interleavings of bounded shift.

**Impact:** This would give persistent homology a native prime-resolved mode, analogous to equipping a seismograph with frequency filters. Every topological data analysis pipeline that currently discards or aggregates torsion would gain a strictly finer invariant at no additional asymptotic computational cost.

**Catalog References:**
- `Pythagorean/PrimewiseTorsionStability.lean` — `pTorsionBirthSet_deltaClose`, `globalTorsionBirthSet_deltaClose_from_primewise`
- `Pythagorean/PrimewiseBirthSpectra.lean` — `mem_global_iff_exists_prime_mem_pTorsion`, `global_eq_of_primewise_eq`

**Proof Strategy:** Extend the existing `pTorsionBirthSet_deltaClose` stability result from birth sets to birth-death pairs. The key lemma would show that if a δ-interleaving preserves p-torsion (injective maps send p-torsion to p-torsion), then it preserves the p-primary barcode up to δ. Use the explicit FiltrationFamily model with ShiftedFiltrationMap.

**Domain Bridges:** Persistent homology (TDA), computational topology, algebraic topology of lens spaces.

**Lineage:** Direct extension of the separation theorem (Theorem 4.3) and the stability theory in the catalog.

**Ambition:** Solid extension — extends existing theory in a natural and well-motivated direction.

**The key insight is** that the existing stability infrastructure for primewise birth sets already provides the scaffolding for a full barcode stability theorem; what is needed is the extension from birth times to birth-death pairs, which requires tracking when p-torsion generators die (are mapped to zero) along the filtration.

**Why now?** The separation theorem provides the first formal proof that the primewise invariant carries information the global one does not. Without this, a primewise barcode would be conjectural enrichment; with it, we know it is a genuine refinement. The existing Lean infrastructure for interleavings and stability bounds makes formalization feasible.

---

## Direction 2: Arithmetic Entropy of Filtrations

**Conjecture:** The information-theoretic entropy of the primewise birth spectrum (defined as the Shannon entropy of the distribution of prime-channel activations across levels) provides a quantitative measure of the "arithmetic complexity" of a filtration. Two filtrations have the same global birth set if and only if they have the same total activation count, but they can have arbitrarily different spectral entropies.

**Test:** Compute spectral entropy for all profiles with max_level ≤ 6 and orders dividing 60. Characterize the set of achievable (global_entropy, spectral_entropy) pairs. Prove that for any ε > 0 and any target global birth set, there exist profiles with spectral entropy within ε of the maximum and minimum achievable values.

**Impact:** This creates a bridge between arithmetic algebra and information theory, providing a quantitative measure of "how much the global projection loses" for any given filtration. It could lead to optimal encoding schemes for torsion data in computational topology.

**Catalog References:**
- `Pythagorean/PrimewiseBirthSpectra.lean` — `global_eq_biUnion_primewise`, `pTorsionBirthSet_subset_global`

**Proof Strategy:** Define spectral entropy formally in Lean using Finset.sum and Real.log. The key lemma shows that spectral entropy ≥ global entropy (since the primewise spectrum refines the global birth set). Prove sharpness by constructing profiles that saturate or minimize the bound.

**Domain Bridges:** Information theory, coding theory, computational complexity of topological invariants.

**Lineage:** Motivated by the observation that the global projection is a lossy compression of the primewise data.

**Ambition:** Solid extension — connects existing results to a quantitative framework.

**The key insight is** that the map from primewise spectrum to global birth set is a many-to-one projection, and the fiber over each global birth set has a rich structure that entropy quantifies. The separation theorem shows these fibers are nontrivial; entropy measures their size.

**Why now?** The explicit computation of all six birth sets in `explicit_primewise_separation` provides concrete data for calibrating entropy measures. The combinatorial model (FiniteBirthProfile) makes exhaustive enumeration tractable.

---

## Direction 3: Spectral Signatures for Topological Data Analysis

**Conjecture:** In persistent homology of filtered simplicial complexes arising from point cloud data, the primewise birth spectrum of the torsion subgroup provides a topological signature that distinguishes spaces with identical Betti numbers and identical aggregate torsion. Specifically, for Rips filtrations of finite samples from lens spaces L(p,q), the primewise birth spectrum determines the parameters (p,q) with high probability as sample size grows.

**Test:** Implement primewise birth spectra computation in a persistent homology pipeline (e.g., extending GUDHI or Dionysus). Apply to Rips filtrations of random samples from L(6,1) vs L(6,2) (which have identical integral homology groups but different linking forms). Measure classification accuracy as a function of sample size and filtration resolution.

**Impact:** This would be the first practical application of arithmetic persistence to topological data analysis, demonstrating that prime-resolved torsion carries shape information invisible to existing invariants. It could open a new dimension of topological feature engineering for machine learning on point cloud data.

**Catalog References:**
- `Pythagorean/PrimewiseBirthSpectra.lean` — `exists_same_global_different_primewise`
- `Pythagorean/PrimewiseTorsionStability.lean` — `prime_channel_independence`

**Proof Strategy:** The theoretical foundation combines the separation theorem with known results on the torsion in homology of lens spaces. The computational component requires extending Smith normal form computation in persistence algorithms to track prime factorization of torsion orders.

**Domain Bridges:** Topological data analysis, machine learning, computational algebraic topology, geometric group theory.

**Lineage:** Cross-domain application of the separation theorem to a concrete data analysis setting.

**Ambition:** Grand challenge — requires both theoretical innovation and substantial software engineering.

**The key insight is** that lens spaces provide a natural testing ground because their torsion is well-understood algebraically but their filtration-level behavior (under Rips or Čech filtrations of finite samples) is not. The primewise spectrum adds a "frequency dial" to the topological microscope.

**Why now?** Recent advances in computing persistent homology with torsion (e.g., the algorithm of Dey-Hou 2023) make it computationally feasible to extract torsion information from large complexes. The separation theorem provides the mathematical guarantee that this information is non-redundant.

---

## Direction 4: p-Adic Valuations and Filtration Depth

**Conjecture:** For filtrations of abelian groups with torsion of p-power order, the p-adic valuation of the torsion order at each level defines a "depth function" v_p : ℕ → ℕ that is monotonically non-decreasing along the filtration (under suitable compatibility conditions on the structure maps). The primewise birth spectrum is the level-0 shadow of this deeper p-adic structure.

**Test:** Formalize the definition of the p-adic depth function for explicit filtrations of ℤ/p^k ℤ modules. Prove monotonicity under injective structure maps. Construct examples where the depth function distinguishes filtrations that the primewise birth spectrum cannot, establishing a strict hierarchy: p-adic depth > primewise spectrum > global birth set.

**Impact:** This would extend the theory from a binary "is p-torsion present?" to a quantitative "how deep is the p-torsion?", creating a richer invariant theory. It connects arithmetic persistence to p-adic analysis, potentially linking to Iwasawa theory and p-adic Hodge theory.

**Catalog References:**
- `Pythagorean/PrimewiseTorsionStability.lean` — `PTorsionBirthSet`, `FiltrationFamily`
- `Pythagorean/PrimewiseBirthSpectra.lean` — `FiniteBirthProfile`, `pTorsionBirthSet`

**Proof Strategy:** Define `padicDepth (p : ℕ) (F : FiltrationFamily) (i : ℕ) : ℕ` as the maximum k such that p^k-torsion is detected at level i. Prove monotonicity using the factorization of structure maps through p-power torsion subgroups. For the separation hierarchy, extend the finite model to record not just orders but their p-adic valuations.

**Domain Bridges:** p-adic analysis, Iwasawa theory, algebraic number theory, arithmetic geometry.

**Lineage:** Natural refinement of the primewise spectrum from binary (present/absent) to quantitative (how much).

**Ambition:** Grand challenge — connects to deep number theory.

**The key insight is** that the primewise birth spectrum records only whether p divides some torsion order at a given level, discarding the multiplicity. The p-adic valuation recovers this multiplicity, creating a hierarchy of invariants that parallels the passage from support to multiplicity in divisor theory.

**Why now?** The formalization of FiltrationFamily with structure maps in the catalog provides the infrastructure for studying how p-adic depth behaves under functorial maps. The finite model in PrimewiseBirthSpectra.lean can be extended to record valuations with minimal additional machinery.

---

## Direction 5: Universal Primewise Stability and the Arithmetic Interleaving Distance

**Conjecture:** There exists a natural metric on the space of primewise birth spectra — the **arithmetic interleaving distance** — that refines the existing Hausdorff-type stability for global birth sets, and satisfies a universal property: it is the finest metric on filtrations such that (i) close filtrations have close spectra, and (ii) the global birth set metric factors through it. Moreover, the space of primewise spectra equipped with this metric is a complete metric space whose topology encodes the prime factorization structure of ℕ.

**Test:** Define the arithmetic interleaving distance as the supremum over primes p of the Hausdorff distance between p-torsion birth sets. Prove it is a pseudometric. Show it refines the global Hausdorff distance. Construct a Cauchy sequence of primewise spectra and prove it converges. Prove or disprove: the metric topology on the space of primewise spectra is homeomorphic to a product of copies of the real line, one for each prime.

**Impact:** This would establish the primewise birth spectrum as a first-class metric invariant with its own stability theory, completeness, and universality. It would be the arithmetic-topological analogue of the Wasserstein metric on persistence diagrams, opening the door to statistical persistence with prime resolution.

**Catalog References:**
- `Pythagorean/PrimewiseTorsionStability.lean` — `NatSetDeltaClose`, `pTorsionBirthSet_deltaClose`, `FaithfulDeltaInterleaving`
- `Pythagorean/PrimewiseBirthSpectra.lean` — `primewiseBirthSpectrum`

**Proof Strategy:** The existing `pTorsionBirthSet_deltaClose` gives Hausdorff closeness of each prime channel under δ-interleavings. Take the supremum over primes to define the arithmetic distance. The triangle inequality follows from the triangle inequality for each channel. Completeness requires showing that Cauchy sequences of finitely-supported spectra converge in the space of all spectra. The universal property requires showing that any metric refining the global distance and satisfying a stability axiom is bounded below by the arithmetic distance.

**Domain Bridges:** Metric geometry, optimal transport, statistical TDA, algebraic signal processing.

**Lineage:** Unifies the stability theory in the catalog with the separation theorem in a single metric framework.

**Ambition:** Grand challenge / paradigm shift — would establish arithmetic persistence as a metric theory on par with classical persistence.

**The key insight is** that the existing stability results are channel-by-channel, but no one has taken the supremum to define a single metric that captures all prime channels simultaneously. This supremum metric is the natural analogue of the bottleneck distance for persistence diagrams, adapted to the arithmetic setting.

**Why now?** The catalog provides channel-by-channel stability (`pTorsionBirthSet_deltaClose`), the separation theorem provides the first example showing the metric is non-degenerate (the distance between F_witness and G_witness is nonzero for the arithmetic distance but zero for the global distance), and the formal infrastructure for interleavings is already in place. The time is ripe to unify these pieces.
